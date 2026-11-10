import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import serial
import serial.tools.list_ports
import time
from datetime import datetime
import math
import random
import os
import sys
from PIL import Image, ImageTk
from collections import deque

import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import matplotlib.dates as mdates

def resource_path(relative_path):
    """ 取得資源絕對路徑 (支援 PyInstaller 打包成單一 .exe 檔案) """
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

class SensorMonitorApp:
    def __init__(self, root):
        self.root = root
        
        try:
            img = Image.open(resource_path("logo.jpg"))
            self.photo = ImageTk.PhotoImage(img)
            self.root.iconphoto(False, self.photo)
        except Exception as e:
            print(f"載入 Logo 失敗: {e} (不影響主程式運行)")
            
        self.root.title("FA277 智慧感測與萬年曆監控工具 (含即時圖表)")
        self.root.geometry("950x850")
        
        self.ser = None
        self.is_connected = False

        self.rx_buffer = bytearray()

        self.time_data = deque(maxlen=100)
        self.temp_data = deque(maxlen=100)
        self.vdd_data = deque(maxlen=100)

        # --- 1. 連線設定介面 ---
        conn_frame = ttk.LabelFrame(root, text=" Serial Port 連線設定 ", padding=10)
        conn_frame.pack(fill="x", padx=10, pady=5)

        ttk.Label(conn_frame, text="連接埠:").grid(row=0, column=0, sticky="w", padx=5)
        
        ports = [port.device for port in serial.tools.list_ports.comports()]
        self.port_combo = ttk.Combobox(conn_frame, values=ports, width=12)
        if ports:
            self.port_combo.current(0)
        self.port_combo.grid(row=0, column=1, padx=5)

        ttk.Label(conn_frame, text="鮑率:").grid(row=0, column=2, sticky="w", padx=5)
        self.baud_combo = ttk.Combobox(conn_frame, values=["9600", "115200"], width=8)
        self.baud_combo.set("9600")
        self.baud_combo.grid(row=0, column=3, padx=5)

        self.btn_connect = ttk.Button(conn_frame, text="開啟連線", command=self.toggle_connect)
        self.btn_connect.grid(row=0, column=4, padx=10)

        # --- 2. 控制與發送指令區 ---
        action_frame = ttk.LabelFrame(root, text=" 指令控制 ", padding=10)
        action_frame.pack(fill="x", padx=10, pady=5)

        self.btn_request = ttk.Button(action_frame, text="查詢時間與狀態 (Cmd 01h)", command=self.send_request_cmd, state="disabled")
        self.btn_request.pack(side="left", padx=5)

        self.btn_sync_time = ttk.Button(action_frame, text="同步電腦時間 (Cmd 00h)", command=self.send_sync_time_cmd, state="disabled")
        self.btn_sync_time.pack(side="left", padx=5)

        self.auto_poll_var = tk.BooleanVar(value=False)
        self.chk_auto_poll = ttk.Checkbutton(action_frame, text="自動輪詢 (1秒/次)", variable=self.auto_poll_var)
        self.chk_auto_poll.pack(side="left", padx=15)

        # --- 建立中間的 Frame ---
        middle_frame = ttk.Frame(root)
        middle_frame.pack(fill="x", padx=10, pady=5)

        # --- 3. 解析結果顯示區 ---
        result_frame = ttk.LabelFrame(middle_frame, text=" 即時解析數據 ", padding=10)
        result_frame.pack(side="left", fill="both", expand=True, padx=(0, 5))

        self.lbl_time     = self.create_info_row(result_frame, "系統時間:", 0)
        self.lbl_ivr      = self.create_info_row(result_frame, "IVR 原始值:", 1)
        self.lbl_battery  = self.create_info_row(result_frame, "Battery 電壓:", 2)
        self.lbl_ntc      = self.create_info_row(result_frame, "NTC 狀態與數值:", 3)
        self.lbl_ntc_elec = self.create_info_row(result_frame, "P10 電壓 / 阻值:", 4)
        self.lbl_temp     = self.create_info_row(result_frame, "推算環境溫度:", 5)

        # --- 4. 原始封包 log 顯示區 ---
        log_frame = ttk.LabelFrame(middle_frame, text=" 原始封包紀錄 (Raw Data) ", padding=10)
        log_frame.pack(side="right", fill="both", expand=True, padx=(5, 0))
        
        text_frame = tk.Frame(log_frame)
        text_frame.pack(side="top", fill="both", expand=True)

        self.txt_log = tk.Text(text_frame, height=8, width=45)
        self.txt_log.pack(side="left", fill="both", expand=True)
        scrollbar = ttk.Scrollbar(text_frame, orient="vertical", command=self.txt_log.yview)
        scrollbar.pack(side="right", fill="y")
        self.txt_log.configure(yscrollcommand=scrollbar.set)

        btn_log_frame = tk.Frame(log_frame)
        btn_log_frame.pack(side="bottom", fill="x", pady=(5, 0))
        
        self.btn_clear_log = ttk.Button(btn_log_frame, text="清空紀錄", command=self.clear_all_logs)
        self.btn_clear_log.pack(side="left")

        self.btn_save_log = ttk.Button(btn_log_frame, text="匯出 Raw Data", command=self.save_log_to_file)
        self.btn_save_log.pack(side="right")

        # --- 5. Matplotlib 即時圖表區 ---
        chart_frame = ttk.LabelFrame(root, text=" 實時趨勢圖 (溫度 vs 電壓) ", padding=10)
        chart_frame.pack(fill="both", expand=True, padx=10, pady=5)

        self.fig, self.ax_temp = plt.subplots(figsize=(8, 3.2), dpi=100)
        self.ax_vdd = self.ax_temp.twinx()
        self.fig.tight_layout(pad=2.5)

        self.canvas = FigureCanvasTkAgg(self.fig, master=chart_frame)
        self.canvas.get_tk_widget().pack(fill="both", expand=True)

        self.root.after(100, self.read_serial_data)
        self.root.after(1000, self.auto_poll_task)

    def create_info_row(self, parent, label_text, row):
        ttk.Label(parent, text=label_text, font=("Arial", 11, "bold")).grid(row=row, column=0, sticky="w", pady=4)
        val_label = ttk.Label(parent, text="--", font=("Arial", 11), foreground="blue")
        val_label.grid(row=row, column=1, sticky="w", padx=10, pady=4)
        return val_label

    def toggle_connect(self):
        if not self.is_connected:
            port = self.port_combo.get()
            baud = int(self.baud_combo.get())
            try:
                self.ser = serial.Serial(port, baud, timeout=0.1)
                self.is_connected = True
                self.rx_buffer.clear()
                self.btn_connect.config(text="關閉連線")
                self.btn_request.config(state="normal")
                self.btn_sync_time.config(state="normal")
                
                self.clear_all_logs()
                messagebox.showinfo("成功", f"已成功連接到 {port}")
            except Exception as e:
                messagebox.showerror("錯誤", f"無法開啟序列埠: {e}")
        else:
            if self.ser and self.ser.is_open:
                self.ser.close()
            self.is_connected = False
            self.rx_buffer.clear()
            self.btn_connect.config(text="開啟連線")
            self.btn_request.config(state="disabled")
            self.btn_sync_time.config(state="disabled")
            self.auto_poll_var.set(False)
            messagebox.showinfo("提示", "已斷開連線")

    def clear_all_logs(self):
        self.txt_log.delete("1.0", tk.END)
        self.time_data.clear()
        self.temp_data.clear()
        self.vdd_data.clear()
        self.update_plot()

    def calc_checksum(self, payload_bytes):
        return ((~sum(payload_bytes) + 1) & 0xFF)

    def send_request_cmd(self):
        if self.ser and self.ser.is_open:
            tag = random.randint(0x00, 0xFF)
            payload = [0x03, tag, 0x01, 0x01]
            chk = self.calc_checksum(payload)
            cmd_bytes = bytes([0xFF, 0x55] + payload + [chk])
            self.ser.write(cmd_bytes)
            hex_formatted = " ".join(f"{b:02X}" for b in cmd_bytes)
            self.log_message(f"發送查詢 (Tag={tag:02X}h): {hex_formatted}")

    def send_sync_time_cmd(self):
        if self.ser and self.ser.is_open:
            now = datetime.now()
            tag = random.randint(0x00, 0xFF)
            payload = [0x0B, tag, 0x00, 0x00, (now.year >> 8) & 0xFF, now.year & 0xFF, now.month, now.day, now.hour, now.minute, now.second, now.isoweekday() % 7]
            chk = self.calc_checksum(payload)
            cmd_bytes = bytes([0xFF, 0x55] + payload + [chk])
            
            self.ser.write(cmd_bytes)
            hex_formatted = " ".join(f"{b:02X}" for b in cmd_bytes)
            self.log_message(f"發送時間同步 (Tag={tag:02X}h): {hex_formatted}")

    def auto_poll_task(self):
        if self.is_connected and self.auto_poll_var.get():
            self.send_request_cmd()
        self.root.after(1000, self.auto_poll_task)

    def read_serial_data(self):
        if self.is_connected and self.ser and self.ser.is_open:
            try:
                if self.ser.in_waiting > 0:
                    raw_data = self.ser.read(self.ser.in_waiting)
                    if raw_data:
                        self.rx_buffer.extend(raw_data)
                        self.process_rx_buffer()
            except Exception as e:
                pass
        self.root.after(100, self.read_serial_data)

    def process_rx_buffer(self):
        while len(self.rx_buffer) >= 15:
            header_idx = -1
            for i in range(len(self.rx_buffer) - 1):
                if self.rx_buffer[i] == 0xFF and self.rx_buffer[i+1] == 0x55:
                    header_idx = i
                    break
            
            if header_idx == -1:
                self.rx_buffer.clear()
                break
            
            if header_idx > 0:
                del self.rx_buffer[:header_idx]

            if len(self.rx_buffer) < 3:
                break

            length_field = self.rx_buffer[2]
            total_pkt_len = 2 + 1 + length_field + 1

            if len(self.rx_buffer) < total_pkt_len:
                break

            pkt = bytes(self.rx_buffer[:total_pkt_len])
            del self.rx_buffer[:total_pkt_len]

            self.handle_complete_packet(pkt)

    def handle_complete_packet(self, pkt):
        hex_str = " ".join(f"{b:02X}" for b in pkt)
        self.log_message(f"收到: {hex_str}")

        if len(pkt) == 15 and pkt[2] == 0x0B and pkt[5] == 0x00:
            tag = pkt[3]
            self.log_message(f">>> [ACK] MCU 已寫入時間 (回應 Tag: {tag:02X}h)")
            return

        if len(pkt) == 21 and pkt[2] == 0x11:
            self.decode_packet(pkt)
            return

    def calculate_ntc_temp(self, vdd, ntc_adc, is_large_current):
        R0, B_VALUE, T0_KELVIN, ADC_RES = 10000.0, 3435.0, 298.15, 4096.0
        current_ua = 45.32 if is_large_current else 17.92
        v_p10 = vdd * (ntc_adc / ADC_RES)

        if v_p10 <= 0.0001 or current_ua <= 0:
            return v_p10, 0.0, None

        r_ntc = (v_p10 * 1_000_000.0) / current_ua
        if r_ntc <= 0:
            return v_p10, r_ntc, None

        inv_t = (1.0 / T0_KELVIN) + (math.log(r_ntc / R0) / B_VALUE)
        temp_c = (1.0 / inv_t) - 273.15
        return v_p10, r_ntc, temp_c

    def decode_packet(self, pkt):
        try:
            year = (pkt[6] << 8) | pkt[7]
            month = pkt[8]
            day = pkt[9]
            hour = pkt[10]
            minute = pkt[11]
            second = pkt[12]
            week_map = ["週日", "週一", "週二", "週三", "週四", "週五", "週六"]
            week = week_map[pkt[13]] if pkt[13] < 7 else "未知"

            time_str = f"{year}年 {month:02d}月 {day:02d}日 {hour:02d}:{minute:02d}:{second:02d} ({week})"
            self.lbl_time.config(text=time_str)

            ivr_val = (pkt[14] << 8) | pkt[15]
            self.lbl_ivr.config(text=f"{ivr_val} (Hex: {pkt[14]:02X} {pkt[15]:02X})")

            vdd_int, vdd_dec = pkt[16], pkt[17]
            vdd_val = vdd_int + (vdd_dec / 100.0)
            
            is_over_voltage = (vdd_val > 4.2)
            battery_color = "red" if is_over_voltage else "blue"
            battery_status_str = "過壓" if is_over_voltage else "正常"
            
            self.lbl_battery.config(text=f"{vdd_int}.{vdd_dec:02d} V 【{battery_status_str}】", foreground=battery_color)

            ntc_h, ntc_l = pkt[18], pkt[19]
            is_large_current = (ntc_h & 0x80) != 0
            is_ot_lock = (ntc_h & 0x40) != 0
            is_ac0_o = (ntc_h & 0x20) != 0
            ntc_adc = ((ntc_h & 0x0F) << 8) | ntc_l

            current_str = "大電流" if is_large_current else "小電流"
            status_str = "【過溫】" if is_ot_lock else "【正常】"
            ac0_str = "(AC0O=1)" if is_ac0_o else "(AC0O=0)"

            self.lbl_ntc.config(text=f"ADC: {ntc_adc} | {current_str} | {status_str} {ac0_str}")

            v_p10, r_ntc, temp_c = self.calculate_ntc_temp(vdd_val, ntc_adc, is_large_current)
            self.lbl_ntc_elec.config(text=f"{v_p10:.4f} V  |  {r_ntc / 1000.0:.3f} kΩ")

            if temp_c is not None:
                is_over_temp = (temp_c >= 55.0 or is_ot_lock)
                ntc_color = "red" if is_over_temp else "blue"
                temp_color = "red" if is_over_temp else "green"

                self.lbl_ntc.config(foreground=ntc_color)
                self.lbl_temp.config(text=f"{temp_c:.2f} °C", foreground=temp_color, font=("Arial", 12, "bold"))
                
                self.time_data.append(datetime.now())
                self.temp_data.append(temp_c)
                self.vdd_data.append(vdd_val)
                self.update_plot()
            else:
                self.lbl_temp.config(text="計算異常", foreground="gray")

        except Exception as e:
            print(f"解析錯誤: {e}")

    def update_plot(self):
        self.ax_temp.clear()
        self.ax_vdd.clear()

        if len(self.time_data) == 0:
            self.canvas.draw()
            return

        self.ax_temp.plot(self.time_data, self.temp_data, color='red', marker='.', linestyle='-', linewidth=1.5)
        self.ax_temp.set_ylabel('Temperature (°C)', color='red', fontweight='bold')
        self.ax_temp.tick_params(axis='y', labelcolor='red')
        self.ax_temp.set_xlabel('Time (HH:MM:SS)', fontweight='bold')

        self.ax_vdd.plot(self.time_data, self.vdd_data, color='blue', marker='.', linestyle='-', linewidth=1.5)
        self.ax_vdd.set_ylabel('VDD Voltage (V)', color='blue', fontweight='bold')
        self.ax_vdd.tick_params(axis='y', labelcolor='blue')
        self.ax_vdd.yaxis.set_label_position("right")
        self.ax_vdd.yaxis.tick_right()

        self.ax_temp.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
        self.fig.autofmt_xdate(rotation=30)
        
        self.ax_temp.grid(True, linestyle='--', alpha=0.6)
        self.fig.tight_layout(pad=2.0)
        self.canvas.draw()

    def log_message(self, msg):
        timestamp = time.strftime("[%H:%M:%S] ")
        self.txt_log.insert(tk.END, timestamp + msg + "\n")
        self.txt_log.see(tk.END)

    def save_log_to_file(self):
        default_filename = f"FA277_RawData_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
        file_path = filedialog.asksaveasfilename(
            title="儲存 Raw Data 紀錄",
            defaultextension=".txt",
            initialfile=default_filename,
            filetypes=[("Text Files", "*.txt"), ("All Files", "*.*")]
        )
        if file_path:
            try:
                log_content = self.txt_log.get("1.0", tk.END)
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(log_content)
                messagebox.showinfo("儲存成功", f"紀錄已成功匯出！")
            except Exception as e:
                messagebox.showerror("儲存失敗", f"寫入檔案錯誤：\n{e}")

if __name__ == "__main__":
    root = tk.Tk()
    app = SensorMonitorApp(root)
    root.mainloop()