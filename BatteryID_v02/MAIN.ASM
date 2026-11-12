;************************************************************************
;   MEGAWIN MLC-SERIES APPLICATION PROGRAM
;   THIS TEMPLATE IS SUITABLE FOR:
;   MSE01PC1A
;************************************************************************
;===================================================================
; PGM_HEAD.H ;()
;===================================================================
    .include FA277_SFR.h


MY_DEV_ID            .EQU   01h      ; 定義這台設備的 Device ID

P1_BUF         .DS    1      
PWR_CTL_TEMP   .DS    1

PWPR_Key             .EQU   5Ah ;PWPR key
;ADC_SYSCLKD2          EQU   20H
;ADC_RightJustified    EQU   10H
;ADC_HighestPower      EQU   00H
;ADC_AIN0              EQU   00H
;ADC_IntVREF           EQU   08H

RST_SRF0              EQU 3015h  ;Reset Source Flag
RST_SRF1              EQU 3016h  ;Reset Source Flag
WDT_CR0               EQU 3018h  ;Watch-Dog-Timer Control Register 0
WDT_CR1               EQU 3019h  ;Watch-Dog-Timer Control Register 0
ADCDH0                EQU 3022h  ;
RTC_CR                EQU 301Ah  ;Real-Time-Clock Control Register
RTC_TM                EQU 301Bh  ;Real-Time-Clock Timer Register
RTC_CS                EQU 301Ch  ;RTC Clock Select Register 4

BO1CR0                EQU 3028h  ;BOD1 Control 0
BO1CFG0               EQU 3029h  ;BOD1 Configuration 0
BO1CFG1               EQU 302Ah  ;BOD1 Configuration 1

AC0CR0                EQU 302Ch  ; Analog Comparator 0 Control Register 0
AC0CR1                EQU 302Dh  ; Analog Comparator 0 Control Register 1

OR08                  EQU 3108H

TRMCC_ADC01           EQU 724DH   
TRMCC_ADC0            EQU 7252H   
    .PAGE0
RAM00                .DS     1
RAM01                .DS     1
WAKEUP_FLAG          .DS     1   ; 標記 MCU 是否處於被喚醒狀態
RX_READY             .DS     1   ; 標記 UART 是否收到一筆新資料
RX_DATA              .DS     1   ; 存放 UART 收到的最新資料
TIMEOUT_L            .DS     1   ; 超時防護計數器 (低位元組)
TIMEOUT_H            .DS     1   ; 超時防護計數器 (高位元組)

SAVE_LEN             .DS     1   ; 備份原始收到的長度，回傳時要用
PKT_LEN              .DS     1   ; 封包剩餘長度計數器
CHK_SUM              .DS     1   ; 校驗和累加器
RX_TAG               .DS     1   ; 儲存上層傳來的亂數 Tag (回傳時使用)
RX_BUF               .DS     32  ; 存放收到的 [Tag, Mode, Cmd, Data...] (上限 16 bytes)
;(Warm Reset 時保留不歸零)
RTC_TICK             .DS     1   ; 記錄累積了幾秒的 RTC 中斷尚未處理
CAL_YEAR_L           .DS     1   ; 西元年低位元 (例如 2026 = 07EAh -> L=EAh)
CAL_YEAR_H           .DS     1   ; 西元年高位元 (例如 2026 = 07EAh -> H=07h)
CAL_MONTH            .DS     1   ; 月份 (1 ~ 12)
CAL_DAY              .DS     1   ; 日期 (1 ~ 31)
CAL_HOUR             .DS     1   ; 小時 (0 ~ 23)
CAL_MIN              .DS     1   ; 分鐘 (0 ~ 59)
CAL_SEC              .DS     1   ; 秒數 (0 ~ 59)
CAL_WEEK             .DS     1   ; 星期幾 (0=週日, 1=週一 ... 6=週六)
TEMP_Y_L             .DS     1   ; 世紀年
TEMP_Y_H             .DS     1   ; 世紀年
;(ADC VDD 變數)
ADC_RAW_L            .DS     1   ; ADC 12-bit 轉換結果低位元 (ADCDL)
ADC_RAW_H            .DS     1   ; ADC 12-bit 轉換結果高位元 (ADCDH0)
VDD_INT              .DS     1   ; 算出的 VDD 整數部分 (例如 3V -> 03h)
VDD_DEC              .DS     1   ; 算出的 VDD 小數部分 (例如 .30V -> 30 = 1Eh)
MATH_L               .DS     1   ; 24-bit 運算暫存器 (Low)
MATH_M               .DS     1   ; 24-bit 運算暫存器 (Mid)
MATH_H               .DS     1   ; 24-bit 運算暫存器 (High)
TEMP_R_L             .DS     1   ; 移位乘法暫存 (Low)
TEMP_R_M             .DS     1   ; 移位乘法暫存 (Mid)
TEMP_R_H             .DS     1   ; 移位乘法暫存 (High)

; <---ADC 10 次平均濾波專用變數 --->
ADC_CNT              .DS     1   ; 採樣次數計數器 (預設 10 次)
SUM_L                .DS     1   ; 10 次總和暫存 (低位元)
SUM_H                .DS     1   ; 10 次總和暫存 (高位元)
MAX_L                .DS     1   ; 紀錄 10 次中的最大值 (低位元)
MAX_H                .DS     1   ; 紀錄 10 次中的最大值 (高位元)
MIN_L                .DS     1   ; 紀錄 10 次中的最小值 (低位元)
MIN_H                .DS     1   ; 紀錄 10 次中的最小值 (高位元)
; <--- NTC 測溫與比例運算專用變數 --->
NTC_MODE             .DS     1   ; NTC 檔位狀態：1 = 大電流，0 = 小電流
IVR_RAW_L            .DS     1   ; 儲存 IVR 平均原始值，供 NTC 比例運算用
IVR_RAW_H            .DS     1   
TEMP_L               .DS     1   ; 比例運算暫存
TEMP_H               .DS     1
; <--- AC0 過溫喚醒專用變數 --->
AC0_WAKE_FLAG        .DS     1   ; 1 = 發生 AC0 過溫喚醒，需主動回傳 UART
OT_LOCK_FLAG         .DS     1   ; 1 = 目前處於 >55度過溫狀態，等待降溫後重開中斷
DEFAULT_OR08         .DS     1   ; 用來備份上電時原本的 OR08 預設值

; <--- BOD1 過高壓喚醒專用變數 --->
BOD1_WAKE_FLAG        .DS     1   ; 1 = VDD 超過 4.2V，需主動回傳 UART
VDD_LOCK_FLAG         .DS     1   ; 1 = 目前處於 >4.2V 過壓狀態，等待降壓後重開中斷
    .ENDS

;======================================================================
; --- 記憶體配置 ---	; FA277 17K Flash 起始位址
;======================================================================
    .ORG    BC00H

; ==============================================================================
; 系統啟動與重置 (System Reset)
; ==============================================================================

reset:  ;Main program start here
    SEI
    LDX #FFh
    TAX ;Initial stack point

    ; ---------------------------------------------------
    ; 1. 讀取並暫存重置旗標 RST_SRF0 RST_SRF1
    ; ---------------------------------------------------
    LDA RST_SRF0            ; 讀取 RST_SRF0 (0x3015)
    STA RAM00               ; 備份到 RAM00 用意:後續 SFR 被清除後查不到死因
	LDA RST_SRF1            ; 讀取 RST_SRF1 (0x3016)
    STA RAM01               ; 備份到 RAM01 用意:後續 SFR 被清除後查不到死因
	
	LDA #PWPR_Key           ;解除寫保護機制
	STA PWPR
    LDA #FFh                
    STA RST_SRF0            ; 將硬體旗標全部清零
	
	LDA #PWPR_Key           ;解除寫保護機制
	STA PWPR
	LDA #FFh                
    STA RST_SRF1            ; 將硬體旗標全部清零
	
	
	; ---------------------------------------------------
    ; 2. 優先初始化硬體 (為了能馬上使用 UART)
    ; ---------------------------------------------------
    JSR INIT_IO_PORTS       
    JSR INIT_UART
    ; ---------------------------------------------------
    ; 3. UART 印出重置旗標 (例如 "RST(RAM00)=80\r\n")
    ; ---------------------------------------------------
    ;JSR PRINT_RST_FLAG
	; ---------------------------------------------------
    ; 4. 逐一判定重置來源 (依優先級)
    ; ---------------------------------------------------
CHECK_POF:
    LDA RAM00
    AND #80h                ; 檢查 Bit 7: POF (Power-On Flag / 上電重置)
    BNE COLD_BOOT_FLOW      ; 若為上電，冷開機
CHECK_EXRF:
    LDA RAM00
    AND #40h                ; 檢查 Bit 6: EXRF (External Reset / 外部 RST 腳位觸發)
    BNE COLD_BOOT_FLOW      ; 若為外部手動重置，冷開機
CHECK_SWRF:
    LDA RAM00
    AND #20h                ; 假設 Bit 4 為 SWRF (software Reset / 軟體重置)
    BNE WARM_BOOT_FLOW      ; 暖開機
CHECK_WRF:
    LDA RAM00
    AND #10h                ; 假設 Bit 4 為 WRF (Watchdog Reset / 看門狗超時)
    BNE WARM_BOOT_FLOW      ; 若為超時，暖開機
CHECK_IARF:
    LDA RAM00
    AND #08h                ; 假設 Bit 3 為 IARF (Illegal Address Reset / 非法位址或跑飛)
    BNE WARM_BOOT_FLOW      ; 進入非法指標專屬處理，暖開機

WARM_BOOT_FLOW:    ;warm reset
    JSR CLEAR_WDT               ; 餵狗
    ; <--- Warm Reset 後 SFR 會被硬體歸零，需重新配置周邊與開啟中斷 --->
    JSR INIT_ILRCO_in_stop_mode 
	JSR INIT_ADC
	JSR INIT_RTC
	JSR INIT_AC0
	JSR INIT_BOD1
    LDA #00h
    STA WAKEUP_FLAG
    STA RX_READY
    CLI                         ; 重新開啟全域中斷
    JMP main_loop
	
COLD_BOOT_FLOW:    ;cold reset
	; <--- 冷開機清除 RAM 狀態旗標 --->
	LDA #00h
    STA WAKEUP_FLAG
	STA AC0_WAKE_FLAG           
    STA OT_LOCK_FLAG            
	STA BOD1_WAKE_FLAG          
    STA VDD_LOCK_FLAG           
    STA RX_READY
    STA P1_BUF
    STA RTC_TICK
	
	LDA #01h                    ; <--- 預設從「大電流檔」開始
    STA NTC_MODE
	
	; 備份上電時原本的 OR08 數值供後續恢復使用
    LDA OR08
    STA DEFAULT_OR08
	
	; <--- 冷開機初始化萬年曆預設時間 (以 MAIN.c 的 2022/4/8 16:08:50 週五 為例) --->
    LDA #EAh                    ; 2026 = 07EAh (低位元 EAh)
    STA CAL_YEAR_L
    LDA #07h                    ; 2026 高位元 07h
    STA CAL_YEAR_H
    LDA #02h                    ; 2 月 (February)
    STA CAL_MONTH
    LDA #1Ch                    ; 28 日 (十進位的 28 = 1Ch)
    STA CAL_DAY
    LDA #17h                    ; 23 時 (十進位的 23 = 17h)
    STA CAL_HOUR
    LDA #3Bh                    ; 59 分 (十進位的 59 = 3Bh)
    STA CAL_MIN
    LDA #32h                    ; 50 秒 (32h)
    STA CAL_SEC
    LDA #01h                    ; 星期
    STA CAL_WEEK
	
	
	JSR INIT_IO_PORTS
	JSR INIT_UART
	JSR INIT_ILRCO_in_stop_mode
	JSR INIT_ADC
	JSR INIT_RTC
	JSR INIT_WDT
	JSR INIT_AC0
	JSR INIT_BOD1
	CLI
	;LDA #5Ah ; 'z'
    ;JSR UART_SEND_BYTE
	
main_loop:
    JSR CLEAR_WDT
	
CHECK_RTC_LOOP:
    LDA RTC_TICK
    BEQ CHECK_BOD1_WAKE         ; <--- 秒數更新完後，先檢查是否為 BOD1 過溫喚醒
    DEC RTC_TICK                ; 消耗 1 秒
    JSR UPDATE_CALENDAR         ; 執行 6502 萬年曆進位 (耗時僅數十微秒)
    JMP CHECK_RTC_LOOP          ; 若剛剛收長封包累積了 2 秒，把它一次補齊

CHECK_BOD1_WAKE:
    LDA BOD1_WAKE_FLAG
    BEQ CHECK_AC0_WAKE          ; 若不是 BOD1 過壓喚醒，繼續檢查是否為 AC0 過溫喚醒

    LDA #00h
    STA BOD1_WAKE_FLAG          ; 清除過壓喚醒旗標

    ; 主動填入封包前 3 個 Bytes: [Tag, Device ID, Cmd]
    LDA #0DDh                   ; 自訂過壓告警 Tag (DDh，與過溫的 EEh 區分)
    STA RX_BUF                  ; RX_BUF[0] = Tag
    LDA #MY_DEV_ID              
    STA RX_BUF+1                ; RX_BUF[1] = 01h (Device ID)
    LDA #02h                   
    STA RX_BUF+2                ; RX_BUF[2] = 01h (Command，也可改為 02h 區分)

    ; 取樣 RTC + IVR14 + VDD + NTC 並填入 RX_BUF+3 ~ +16
    JSR FILL_CALENDAR_RESP
    ; 透過 UART 主動將封包傳送出去
    JSR SEND_RESPONSE_WITH_TAG
    ; 傳送完畢，直接準備進入休眠
    JMP SLEEP_AGAIN

CHECK_AC0_WAKE:
    LDA AC0_WAKE_FLAG
    BEQ CHECK_UART_WAKE         ; 若不是過溫喚醒，繼續檢查是否為 UART 喚醒

    LDA #00h
    STA AC0_WAKE_FLAG           ; 清除過溫喚醒旗標

    ; 主動填入封包前 3 個 Bytes: [Tag, Device ID, Cmd]
    LDA #0EEh                   ; 自訂主動告警 Tag (例如 EEh，或使用 LDA RX_TAG)
    STA RX_BUF                  ; RX_BUF[0] = Tag
    LDA #MY_DEV_ID              
    STA RX_BUF+1                ; RX_BUF[1] = 01h (Device ID)
    LDA #01h                   
    STA RX_BUF+2                ; RX_BUF[2] = 01h (Command)

    ; 取樣 RTC + IVR14 + VDD + NTC 並填入 RX_BUF+3 ~ +16
    JSR FILL_CALENDAR_RESP
    ; 透過 UART 主動將 17 Bytes 封包傳送出去
    JSR SEND_RESPONSE_WITH_TAG
    ; 傳送完畢，直接準備進入休眠
    JMP SLEEP_AGAIN


CHECK_UART_WAKE:
    LDA WAKEUP_FLAG
    BEQ GO_SLEEP                ; 若不是被 UART 喚醒的 (純粹是 RTC 醒來更新秒數)，立刻回去睡覺！
	
	CLD
; ===================================================
    ; 階段 1：等待 55h (第一個 FF 已作為喚醒信號消耗掉)
    ; ===================================================
RELOAD_55_TIMEOUT:
    JSR WAIT_UART_BYTE          ; 呼叫帶 Timeout 的等待收 Byte 副程式
    BCS SLEEP_AGAIN             ; 若 Carry=1 代表 Timeout 超時，直接去睡覺！

    LDA RX_DATA
    CMP #0FFh                   ; 如果剛好收到殘留的 FFh (例如沒睡著時收到的)
    BEQ RELOAD_55_TIMEOUT       ; 忽略 FFh，重置 Timeout 繼續等 55h！

    CMP #55h                    ; 確認是否為 55h？
    BNE SLEEP_AGAIN             ; 不是 55h，代表是雜訊，立刻回去睡覺省電！

    ; ===================================================
    ; 階段 2：收到 55h 了！等待 Length 欄位
    ; ===================================================
    LDA #00h
    STA CHK_SUM                 ; Checksum 累加器清零

    JSR WAIT_UART_BYTE
    BCS SLEEP_AGAIN             ; Timeout 則放棄去睡覺

    LDA RX_DATA
    CMP #03h                    ; 檢查最小長度 (至少要有 Tag + Mode + Cmd = 3 bytes)
    BCC SLEEP_AGAIN             ; Length < 3 視為異常，去睡覺
    CMP #20h                    ; 檢查最大長度 (不得超過 RX_BUF 32 bytes)
    BCS SLEEP_AGAIN             ; Length >= 32 視為異常，保護 RAM 去睡覺

    STA PKT_LEN                 ; 存入長度計數器
	STA SAVE_LEN                ; <---備份起來給回傳副程式用
    STA CHK_SUM                 ; Length 本身是第一個加入 Checksum 的數值

    ; ===================================================
    ; 階段 3：依序接收 [Tag, Mode, Cmd, Data...] 共 PKT_LEN 個 Bytes
    ; ===================================================
    LDX #00h                    ; X 作為 RX_BUF 的索引指標
WAIT_PAYLOAD_LOOP:
    JSR WAIT_UART_BYTE
    BCS SLEEP_AGAIN             ; 中途斷線 Timeout 則去睡覺

    LDA RX_DATA
    STA RX_BUF,X               ; 依序存入 RX_BUF (RX_BUF+0 就是 Tag！)
    
    CLC
    ADC CHK_SUM                 ; 累加進 Checksum
    STA CHK_SUM

    INX
    DEC PKT_LEN                 ; 剩餘長度 - 1
    BNE WAIT_PAYLOAD_LOOP       ; 還沒收完就繼續收

    ; ===================================================
    ; 階段 4：接收最後 1 個 Byte (Checksum) 並驗證
    ; ===================================================
    JSR WAIT_UART_BYTE
    BCS SLEEP_AGAIN

    LDA RX_DATA
    CLC
    ADC CHK_SUM                 ; 把收到的 Checksum 加進總和
    BNE SLEEP_AGAIN             ; 【關鍵】若總和 != 00h，代表 Checksum 錯誤，丟棄去睡覺！

    ; ===================================================
    ; 階段 5：封包 100% 正確！提取 Tag 並檢查 Mode / ID
    ; ===================================================
    LDA RX_BUF                  ; RX_BUF[0] 就是上層定義的亂數 Tag
    STA RX_TAG                  ; 把 Tag 留存起來！

    LDA RX_BUF+1                ; RX_BUF[1] 是 Mode (或 Device ID)
	BEQ CHECK_COMMAND           ; 如果 ID 是 00h (通用)，跳過比對
    CMP #MY_DEV_ID              ; 檢查是不是找我的 (01h)
    BNE SLEEP_AGAIN             ; 不是找我的，直接去睡覺

CHECK_COMMAND:
    ; --- 指令分發 ---
    LDA RX_BUF+2                ; 取出 Command (RX_BUF+2)
    
    CMP #01h                    ; 【修改】將原本的 AAh 改成 01h (查詢時間指令)
    BEQ CMD_01_HANDLER
    
    CMP #00h                    ; 【新增】判斷是否為 00h (設定時間指令)
    BEQ CMD_00_HANDLER

CMD_01_HANDLER:
    JSR FILL_CALENDAR_RESP      ; 填入時間與感測器資料
    JMP NORMAL_ECHO_RESP

CMD_00_HANDLER:
    JSR UPDATE_RTC_FROM_UART    ; 呼叫更新時間副程式
    JMP NORMAL_ECHO_RESP        ; 更新完畢後，把原封包 Echo 回去作為 ACK (確認)

NORMAL_ECHO_RESP:
    JSR SEND_RESPONSE_WITH_TAG

SLEEP_AGAIN:
    LDA #00h
    STA WAKEUP_FLAG             ; 把喚醒旗標清零

GO_SLEEP:
    JSR PREPARE_SLEEP           ; 關 UART、開 INT2、進 STOP
    JMP main_loop 
; =====================================================
; 透過 UART 接收到的 00h 指令封包來更新萬年曆時間
; 封包格式：FF 55 Length Tag ID Cmd(00) 年H 年L 月 日 時 分 秒 週 [CheckSum]
; =====================================================
UPDATE_RTC_FROM_UART:
    LDA RX_BUF+3
    STA CAL_YEAR_H              ; 年 (高位，例如 07h)
    LDA RX_BUF+4
    STA CAL_YEAR_L              ; 年 (低位，例如 EAh = 2026)
    LDA RX_BUF+5
    STA CAL_MONTH               ; 月 (1~12)
    LDA RX_BUF+6
    STA CAL_DAY                 ; 日 (1~31)
    LDA RX_BUF+7
    STA CAL_HOUR                ; 時 (0~23)
    LDA RX_BUF+8
    STA CAL_MIN                 ; 分 (0~59)
    LDA RX_BUF+9
    STA CAL_SEC                 ; 秒 (0~59)
    LDA RX_BUF+10
    STA CAL_WEEK                ; 週 (0~6)
    
    ; 清除 RTC_TICK，避免剛寫入新時間後，前一次休眠殘留的秒數又觸發進位
    LDA #00h
    STA RTC_TICK
    
    RTS
	
; =====================================================
; 初始化 BOD1 監控 VDD > 4.2V 
; =====================================================
INIT_BOD1:
    ; 1. 開啟 BOD1 模組時脈 (MCK_CTL Bit 5: BO1CE = 1)
    LDA #PWPR_Key
    STA PWPR
    LDA MCK_CTL
    ORA #20h
    STA MCK_CTL

    ; 2. 寫入真正的 4.2V 門檻 (硬體實際上是有 BO1CFG0 的！)
    LDA #PWPR_Key
    STA PWPR
    LDA #88h
    STA BO1CFG0
    
    ; 3. 設定 BO1CR0 為 Static 模式
    LDA #PWPR_Key
    STA PWPR
    LDA #00h
    STA BO1CR0

    ; 4. 啟用 BOD1 (AWBOD1=1, EBOD1=1 -> 0Ah)
    LDA #PWPR_Key
    STA PWPR
    LDA PWR_CR1
    AND #0Fh                    ; 確保高位元乾淨
    ORA #0Ah                    ; 啟用 BOD1
    STA PWR_CR1

    ; 5. 延遲等待 BOD1 比較器電壓穩定 (約 200us)
    LDX #0FFh
WAIT_BOD1_INIT:
    DEX
    BNE WAIT_BOD1_INIT

    ; 6. 清除 BO1RF/BO1FF 歷史中斷旗標
    LDA #C0h
    STA IRQ1_STS
    RTS
; =====================================================
; 初始化 AC0 為 NTC ACMP 模式 (Sleep 時維持開啟)
; =====================================================
INIT_AC0:
    ; 1. 開啟 AC0 模組時脈 (MCK_CTL Bit 4: AC0CE = 1)
    LDA #PWPR_Key
    STA PWPR
    LDA MCK_CTL
    ORA #10h
    STA MCK_CTL

    ; 2. 設定 AC0CFG1 (0x302E) 內部電阻分壓閾值 R2S[3:0] (預設 80h，可依 55度硬體設計調整)
     ;LDA #08h
     ;STA AC0CR1

    ; 3. 開啟恆流源 (AC0CR1: 08h=小電流 CCA1=1, 0Ch=大電流 CCA1=1&CCA0=1)
    LDA #0Ch                    ; 依您 55度硬體設定選擇 #0Ch (大電流) 或 #08h (小電流)
    STA AC0CR1

    ; 4. 設定 AC0CR0 (0x302C):
    ;    Bit 6 (AC0PDX) = 1 (STOP 模式下繼續運作)
    ;    Bit 3 (AC0EN)  = 1 (致能 AC0)
    ;    Bit 1:0 (AC0M) = 01b (Static ACMP for NTC) -> 0100_1001b = 49h
    LDA #49h
    STA AC0CR0

    ; 5. 稍微延遲讓比較器輸出穩定後，再清除旗標
    LDX #FFh
WAIT_AC0_INIT:
    DEX
    BNE WAIT_AC0_INIT

    ; 6. 寫 1 清除 AC0RF (Bit 5) 與 AC0FF (Bit 4) 歷史旗標
    LDA #30h
    STA IRQ1_STS

    ; 7. 開啟 AC0RF 中斷 (IRQ1_EN Bit 5: EAC0R = 20h；若為負緣/低準位則改用 #10h EAC0F)
    LDA IRQ1_EN
    ORA #20h
    STA IRQ1_EN
    RTS
; =====================================================
; 初始化 ADC 硬體設定 
; =====================================================
INIT_ADC:
    ; 1. 開啟 ADC 模組時脈 (MCK_CTL 的 ADCE 位元，若預設已開可保留)
	LDA #PWPR_Key           ; 載入 5Ah 密碼以解除寫保護機制[cite: 1]
    STA PWPR
    LDA MCK_CTL
    ORA #08h                    ; 確保 ADC Clock Enable 開啟
    STA MCK_CTL

    ; 2. 設定 ADCFG0：時脈 = SYSCLK/2 (ADC_SYSCLKD2) + 向右對齊 (ADRJ)
    ;LDA #ADC_SYSCLKD2
    ;ORA #ADC_RightJustified
	LDA ADCFG0
	ORA #30h
    STA ADCFG0

    ; 3. 設定 ADCFG1：最高轉換功耗 (ADC_HighestPower)
    ;LDA #ADC_HighestPower
    LDA ADCFG1
	AND #3Fh
    STA ADCFG1

    ; 4. 預設先關閉 ADC 省電，等要量測時再開啟
    LDA #00h
    STA ADCON
    RTS

; =====================================================
; 共用副程式：取 10 次 ADC、去頭去尾、平均 8 次
; 輸入：A 暫存器帶入要寫入 ADCON 的設定值
; 輸出：ADC_RAW_H, ADC_RAW_L 為精華平均值
; =====================================================
GET_ADC_AVG_10X:
    STA ADCON                   ; 寫入通道與開啟 ADC
    ; 初始化濾波變數
    LDA #00h
    STA SUM_L
    STA SUM_H
    STA MAX_L
    STA MAX_H
    LDA #0FFh
    STA MIN_L
    STA MIN_H
    LDA #0Ah
    STA ADC_CNT
    
    LDX #0FFh                   ; 延遲等待電壓穩定
WAIT_ADC_STB:
    DEX
    BNE WAIT_ADC_STB

ADC_SAMPLE_LOOP:
    LDA IRQ1_STS
    ORA #08h                    ; 寫 1 清除 ADCI
    STA IRQ1_STS
    LDA ADCON
    ORA #40h                    ; ADCS = 1 (啟動)
    STA ADCON

WAIT_ADC_RDY:
    LDA IRQ1_STS
    AND #08h
    BEQ WAIT_ADC_RDY
    LDA #08h
    STA IRQ1_STS

    LDA ADCDL
    STA ADC_RAW_L
    LDA ADCDH0
    AND #0Fh
    STA ADC_RAW_H

    ; 累加 SUM
    CLC
    LDA SUM_L
    ADC ADC_RAW_L
    STA SUM_L
    LDA SUM_H
    ADC ADC_RAW_H
    STA SUM_H

    ; 更新 MAX
    LDA ADC_RAW_H
    CMP MAX_H
    BCC CHECK_MIN
    BNE UPDATE_MAX
    LDA ADC_RAW_L
    CMP MAX_L
    BCC CHECK_MIN
    BEQ CHECK_MIN
UPDATE_MAX:
    LDA ADC_RAW_L
    STA MAX_L
    LDA ADC_RAW_H
    STA MAX_H

    ; 更新 MIN
CHECK_MIN:
    LDA ADC_RAW_H
    CMP MIN_H
    BCC UPDATE_MIN
    BNE NEXT_SAMPLE
    LDA ADC_RAW_L
    CMP MIN_L
    BCS NEXT_SAMPLE
UPDATE_MIN:
    LDA ADC_RAW_L
    STA MIN_L
    LDA ADC_RAW_H
    STA MIN_H

NEXT_SAMPLE:
    DEC ADC_CNT
    BNE ADC_SAMPLE_LOOP

    ; 關閉 ADC 省電
    LDA ADCON
    AND #.not.0A0h              ; 清除 ADCEN, IVREN
    STA ADCON

    ; 去頭去尾 (SUM - MAX - MIN)
    SEC
    LDA SUM_L
    SBC MAX_L
    STA SUM_L
    LDA SUM_H
    SBC MAX_H
    STA SUM_H

    SEC
    LDA SUM_L
    SBC MIN_L
    STA SUM_L
    LDA SUM_H
    SBC MIN_H
    STA SUM_H

    ; 平均 8 次 (右移 3 次)
    LDX #03h
SHIFT_AVG_LOOP:
    LSR SUM_H
    ROR SUM_L
    DEX
    BNE SHIFT_AVG_LOOP

    LDA SUM_L
    STA ADC_RAW_L
    LDA SUM_H
    STA ADC_RAW_H
    RTS

; =====================================================
; 以 Polling 方式量測 IVR (1.4V) 並反推回傳 VDD_INT 與 VDD_DEC
; 公式：VDD = 5734.4 / ADC_RAW
; =====================================================
READ_VDD_BY_IVR:

	
    ; --- 步驟 1：選擇 IVR 通道並開啟 ADC (ADCEN) ---
    LDA #08h               ; <--- VR 1.4V 的通道
    ORA #A0h                  ; 同時設 ADCEN = 1 & IVREN = 1
    STA ADCON

    ; 稍微延遲 讓內部 IVR 參考電壓與取樣電容穩定
    LDX #0FFh
WAIT_ADC_STABLE:
    DEX
    BNE WAIT_ADC_STABLE

; =================================================
    ; 開始 10 次 ADC 採樣迴圈
    ; =================================================
    JSR GET_ADC_AVG_10X
; 備份 IVR 數值供 NTC 換檔判定使用！
    LDA ADC_RAW_L
    STA IVR_RAW_L
    LDA ADC_RAW_H
    STA IVR_RAW_H

    ; 防呆
    ORA ADC_RAW_L
    BNE CALC_VDD_START
    LDA #00h
    STA VDD_INT
    STA VDD_DEC
    RTS

CALC_VDD_START:
    ; =================================================
    ; 步驟 5：計算整數部分 VDD_INT = 5734 / ADC_RAW
    ;         5734 的十六進位 = 1666h
    ; =================================================
    LDA #66h
    STA MATH_L
    LDA #16h
    STA MATH_M
    LDA #00h
    STA VDD_INT

DIV_INT_LOOP:
    ; 比較 MATH_M:MATH_L 是否 >= ADC_RAW_H:ADC_RAW_L
    LDA MATH_M
    CMP ADC_RAW_H
    BCC DIV_INT_DONE            ; 若 MATH_M < ADC_RAW_H，不夠減了
    BNE DO_SUB_INT              ; 若 MATH_M > ADC_RAW_H，直接減
    LDA MATH_L
    CMP ADC_RAW_L
    BCC DIV_INT_DONE            ; 若相等且 MATH_L < ADC_RAW_L，不夠減了

DO_SUB_INT:
    SEC
    LDA MATH_L
    SBC ADC_RAW_L
    STA MATH_L
    LDA MATH_M
    SBC ADC_RAW_H
    STA MATH_M
    INC VDD_INT                 ; 整數商 + 1
    JMP DIV_INT_LOOP

DIV_INT_DONE:
    ; =================================================
    ; 步驟 6：計算小數後兩位 VDD_DEC = (餘數 * 100 + 40) / ADC_RAW
    ; 技巧：餘數 * 100 = (餘數 * 4) + (餘數 * 32) + (餘數 * 64)
    ; =================================================
    ; 先把餘數 MATH_M:MATH_L 複製到 TEMP_R，並設最高位為 0
    LDA MATH_L
    STA TEMP_R_L
    LDA MATH_M
    STA TEMP_R_M
    LDA #00h
    STA TEMP_R_H

    ; 1. 計算 餘數 * 4 (左移 2 次)
    ASL TEMP_R_L
    ROL TEMP_R_M
    ROL TEMP_R_H
    ASL TEMP_R_L
    ROL TEMP_R_M
    ROL TEMP_R_H

    ; 把 (餘數 * 4) 加上常數 40 (28h，補償 5734.4 的 .4) 存入 MATH (作為累加器)
    CLC
    LDA TEMP_R_L
    ADC #28h                    ; + 40
    STA MATH_L
    LDA TEMP_R_M
    ADC #00h
    STA MATH_M
    LDA TEMP_R_H
    ADC #00h
    STA MATH_H

    ; 2. 繼續左移 3 次變成 (餘數 * 32)
    ASL TEMP_R_L
    ROL TEMP_R_M
    ROL TEMP_R_H
    ASL TEMP_R_L
    ROL TEMP_R_M
    ROL TEMP_R_H
    ASL TEMP_R_L
    ROL TEMP_R_M
    ROL TEMP_R_H

    ; 累加 (餘數 * 32) 到 MATH
    CLC
    LDA MATH_L
    ADC TEMP_R_L
    STA MATH_L
    LDA MATH_M
    ADC TEMP_R_M
    STA MATH_M
    LDA MATH_H
    ADC TEMP_R_H
    STA MATH_H

    ; 3. 再左移 1 次變成 (餘數 * 64)
    ASL TEMP_R_L
    ROL TEMP_R_M
    ROL TEMP_R_H

    ; 累加 (餘數 * 64) 到 MATH -> 此時 MATH_H:MATH_M:MATH_L = 餘數 * 100 + 40
    CLC
    LDA MATH_L
    ADC TEMP_R_L
    STA MATH_L
    LDA MATH_M
    ADC TEMP_R_M
    STA MATH_M
    LDA MATH_H
    ADC TEMP_R_H
    STA MATH_H

    ; 4. 進行 24-bit 減法迴圈：VDD_DEC = MATH / ADC_RAW
    LDA #00h
    STA VDD_DEC

DIV_DEC_LOOP:
    ; 若最高位 MATH_H > 0，代表一定大於 12-bit 的 ADC_RAW，直接減！
    LDA MATH_H
    BNE DO_SUB_DEC
    ; 若 MATH_H == 0，比較 MATH_M:MATH_L 與 ADC_RAW_H:ADC_RAW_L
    LDA MATH_M
    CMP ADC_RAW_H
    BCC DIV_DEC_DONE
    BNE DO_SUB_DEC
    LDA MATH_L
    CMP ADC_RAW_L
    BCC DIV_DEC_DONE

DO_SUB_DEC:
    SEC
    LDA MATH_L
    SBC ADC_RAW_L
    STA MATH_L
    LDA MATH_M
    SBC ADC_RAW_H
    STA MATH_M
    LDA MATH_H
    SBC #00h
    STA MATH_H
    INC VDD_DEC                 ; 小數商 + 1
    JMP DIV_DEC_LOOP

DIV_DEC_DONE:
    RTS

; =====================================================
; 自動換檔讀取 NTC 溫度 (使用 6502 交叉比例算法)
; =====================================================
READ_NTC_AUTO:

; <--- 量測 ADC 前先將 AC0EN 設為 0，讓內部電流源切換至 ADC 路徑且不誤觸發中斷 --->
    LDA #00h
    STA AC0CR0
    ; 1. 根據 NTC_MODE 設定 AC0C (CCA 恆流源輸出)
    LDA NTC_MODE
    BEQ SET_SMALL_CURR
	
SET_LARGE_CURR:
    LDA #PWPR_Key
    STA PWPR
    LDA TRMCC_ADC01             ; 讀取 724Dh (大電流校準值)
    STA OR08                    ; 寫入 3108h
    LDA #0Ch                    ; 大電流：CCA1=1, CCA0=1
    JMP APPLY_AC0CR1

SET_SMALL_CURR:
    LDA #PWPR_Key
    STA PWPR
    LDA TRMCC_ADC0              ; 讀取 7252h (小電流校準值)
    STA OR08                    ; 寫入 3108h
    LDA #08h                    ; 小電流：CCA1=1, CCA0=0

APPLY_AC0CR1:
    STA AC0CR1                  ; 寫入 0x302D

; 稍微延遲讓恆流源流過外部 NTC 電阻的電壓穩定
    LDX #40h
WAIT_CC_STABLE:
    DEX
    BNE WAIT_CC_STABLE

    ; 2. 取樣 AIN0 (P1.0)
    LDA #80h                    ; ADCEN = 1, 通道 = 00h (AIN0)
    JSR GET_ADC_AVG_10X

    ; 3. 判定是否需要換檔
    LDA NTC_MODE
    BEQ CHECK_TO_LARGE          ; 若目前是小電流，檢查是否低於 0.5V

    ; -------------------------------------------------
    ; 大電流檢查：若 V_NTC > 1.6V (即 NTC*7 > IVR*8)，切換小電流
    ; -------------------------------------------------
CHECK_TO_SMALL:
    ; 計算 MATH = NTC * 7 (NTC*8 - NTC)
    LDA ADC_RAW_L
    STA MATH_L
    LDA ADC_RAW_H
    STA MATH_H
    ASL MATH_L
    ROL MATH_H
    ASL MATH_L
    ROL MATH_H
    ASL MATH_L
    ROL MATH_H                  ; MATH = NTC * 8
    SEC
    LDA MATH_L
    SBC ADC_RAW_L
    STA MATH_L
    LDA MATH_H
    SBC ADC_RAW_H
    STA MATH_H                  ; MATH = NTC * 7

    ; 計算 TEMP = IVR * 8
    LDA IVR_RAW_L
    STA TEMP_L
    LDA IVR_RAW_H
    STA TEMP_H
    ASL TEMP_L
    ROL TEMP_H
    ASL TEMP_L
    ROL TEMP_H
    ASL TEMP_L
    ROL TEMP_H                  ; TEMP = IVR * 8

    ; 比較 MATH > TEMP
    LDA TEMP_H
    CMP MATH_H
    BCC DO_SWITCH_SMALL         ; 若 MATH_H > TEMP_H
    BNE KEEP_MODE               ; 若 MATH_H < TEMP_H
    LDA TEMP_L
    CMP MATH_L
    BCC DO_SWITCH_SMALL         ; 若 MATH_L > TEMP_L
    JMP KEEP_MODE               

DO_SWITCH_SMALL:
    LDA #00h
    STA NTC_MODE
    JMP READ_NTC_AUTO           ; 立刻切換小電流並重新量測！

    ; -------------------------------------------------
    ; 小電流檢查：若 V_NTC < 0.5V (即 NTC*14 < IVR*5)，切換大電流
    ; -------------------------------------------------
CHECK_TO_LARGE:
    ; 計算 MATH = NTC * 14 (NTC*16 - NTC*2)
    LDA ADC_RAW_L
    ASL A
    STA TEMP_R_L
    LDA ADC_RAW_H
    ROL A
    STA TEMP_R_H                ; TEMP_R = NTC * 2
    
    LDA TEMP_R_L
    STA MATH_L
    LDA TEMP_R_H
    STA MATH_H
    ASL MATH_L
    ROL MATH_H
    ASL MATH_L
    ROL MATH_H
    ASL MATH_L
    ROL MATH_H                  ; MATH = NTC * 16
    
    SEC
    LDA MATH_L
    SBC TEMP_R_L
    STA MATH_L
    LDA MATH_H
    SBC TEMP_R_H
    STA MATH_H                  ; MATH = NTC * 14

    ; 計算 TEMP = IVR * 5 (IVR*4 + IVR)
    LDA IVR_RAW_L
    STA TEMP_L
    LDA IVR_RAW_H
    STA TEMP_H
    ASL TEMP_L
    ROL TEMP_H
    ASL TEMP_L
    ROL TEMP_H                  ; TEMP = IVR * 4
    CLC
    LDA TEMP_L
    ADC IVR_RAW_L
    STA TEMP_L
    LDA TEMP_H
    ADC IVR_RAW_H
    STA TEMP_H                  ; TEMP = IVR * 5

    ; 比較 MATH < TEMP
    LDA MATH_H
    CMP TEMP_H
    BCC DO_SWITCH_LARGE
    BNE KEEP_MODE
    LDA MATH_L
    CMP TEMP_L
    BCC DO_SWITCH_LARGE
    JMP KEEP_MODE

DO_SWITCH_LARGE:
    LDA #01h
    STA NTC_MODE
    JMP READ_NTC_AUTO           ; 立刻切換大電流並重新量測！

KEEP_MODE:
    ; <--- 量測完畢，將 OR08 恢復為原本預設值，並開啟 AC0 睡眠監控模式 --->
    LDA #PWPR_Key
    STA PWPR
    LDA DEFAULT_OR08            ; 恢復原本的 OR08 數值
    STA OR08

    LDA #0Ch                    ; 依您需求：睡眠時維持給 AC0 的電流源設定
    STA AC0CR1
    LDA #49h                    ; 保持 AC0PDX=1, AC0EN=1, AC0M=01b (Static NTC ACMP)
    STA AC0CR0

    ; 延遲等待比較器穩定
    LDY #08h
WAIT_AC0_RES_OUTER:
    LDX #0FFh
WAIT_AC0_RES_INNER:
    DEX
    BNE WAIT_AC0_RES_INNER
    DEY
    BNE WAIT_AC0_RES_OUTER

    LDA #30h
    STA IRQ1_STS
    RTS
; =====================================================
; 將萬年曆 8 個 Bytes 填入 RX_BUF+3 ~ RX_BUF+10 準備回傳
; =====================================================
FILL_CALENDAR_RESP:
    LDA CAL_YEAR_H              
    STA RX_BUF+3                
    LDA CAL_YEAR_L              
    STA RX_BUF+4                
    LDA CAL_MONTH               
    STA RX_BUF+5                
    LDA CAL_DAY                 
    STA RX_BUF+6                
    LDA CAL_HOUR                
    STA RX_BUF+7                

    LDA CAL_MIN                 
    STA RX_BUF+8                
    LDA CAL_SEC                 
    STA RX_BUF+9                
    LDA CAL_WEEK                
    STA RX_BUF+10               

; <--- Polling 讀取 IVR 並計算 VDD (例如 3.30V -> 03h, 1Eh) --->
    JSR READ_VDD_BY_IVR

    ; 放入未經計算的 12-bit ADC IVR14原始讀值 (High Byte & Low Byte)
    LDA ADC_RAW_H               ; 計算前：ADC 原始高 4-bit (例如 07h)
    STA RX_BUF+11
    LDA ADC_RAW_L               ; 計算前：ADC 原始低 8-bit (例如 CEh)
    STA RX_BUF+12

    ; 放入計算後的 VDD 整數與小數後兩位
    LDA VDD_INT                 ; 計算後：VDD 整數部分 (例如 03h)
    STA RX_BUF+13
    LDA VDD_DEC                 ; 計算後：VDD 小數後兩位 (例如 00h)
    STA RX_BUF+14

;  Polling 讀取 NTC (含自動換檔)
    JSR READ_NTC_AUTO

    ; 3. 組合 NTC 回傳格式：
    ;    Bit 7 = NTC_MODE (1:大電流, 0:小電流)
    ;    Bit 6 = OT_LOCK_FLAG (1:過溫鎖定中, 0:未鎖定)  <-- 【新增檢查點】
    ;    Bit 5 = AC0O 即時狀態 (1:AC0O=1過溫, 0:AC0O=0常溫) <-- 【新增檢查點】
    ;    Bit 3:0 = ADC_RAW_H (12-bit ADC 高 4 位元)
    LDA ADC_RAW_H
    AND #0Fh                    ; 確保只取低 4 bits

    ; --- 塞入 Bit 7: 大小電流旗標 ---
    LDX NTC_MODE
    BEQ PACK_CHECK_AC0O         ; 若為小電流 (0)，Bit 7 維持 0
    ORA #80h                    ; 若為大電流 (1)，Bit 7 設為 1

PACK_CHECK_AC0O:
    ; --- 【新增檢查點 1】塞入 Bit 5: 讀取 AC0CR0 的 Bit 5 (AC0O 即時輸出) ---
    PHA                         ; 先把 A 存起來
    LDA AC0CR0
    AND #20h                    ; 只取出 Bit 5 (AC0O)
    STA TEMP_L                  ; 暫存到 TEMP_L
    PLA                         ; 取回 A
    ORA TEMP_L                  ; 把 AC0O 塞進 Bit 5！
; --- 【新增檢查點 2】塞入 Bit 6: 讀取 OT_LOCK_FLAG ---
    LDX OT_LOCK_FLAG
    BEQ PACK_CHECK_VDD_LOCK     ; <--- 【修正】若未過溫，跳去檢查過壓鎖定！
    ORA #40h                    ; 若處於過溫鎖定狀態，Bit 6 設為 1！

PACK_CHECK_VDD_LOCK:
    ; --- 【新增檢查點 3】塞入 Bit 4: 讀取 VDD_LOCK_FLAG (>4.2V 過壓鎖定) ---
    LDX VDD_LOCK_FLAG
    BEQ PACK_NTC_DONE
    ORA #10h                    ; 若處於 >4.2V 過壓鎖定狀態，Bit 4 設為 1！

PACK_NTC_DONE:
    STA RX_BUF+15
    LDA ADC_RAW_L
    STA RX_BUF+16

    LDA #11h                    ; 回傳總長 = 17 (11h) bytes
    STA SAVE_LEN                
    RTS
; =====================================================
; 6502 萬年曆每秒更新副程式 (對應 MAIN.c 邏輯，含閏年判斷)
; =====================================================
UPDATE_CALENDAR:
    CLD
    ; 1. 秒進位 (0 ~ 59)
    INC CAL_SEC
    LDA CAL_SEC
    CMP #60
    BCC CAL_END                 ; 若 < 60 秒，直接結束！
    LDA #00h
    STA CAL_SEC                 ; 秒歸零

    ; 2. 分進位 (0 ~ 59)
    INC CAL_MIN
    LDA CAL_MIN
    CMP #60
    BCC CAL_END                 ; 若 < 60 分，直接結束！
    LDA #00h
    STA CAL_MIN                 ; 分歸零

    ; 3. 時進位 (0 ~ 23)
    INC CAL_HOUR
    LDA CAL_HOUR
    CMP #24
    BCC CAL_END                 ; 若 < 24 時，直接結束！
    LDA #00h
    STA CAL_HOUR                ; 時歸零

    ; 4. 星期進位 (0=週日 ~ 6=週六)
    INC CAL_WEEK
    LDA CAL_WEEK
    CMP #07h
    BCC CHECK_DAY_CARRY
    LDA #00h
    STA CAL_WEEK

    ; 5. 日進位 (需查表判斷當月有幾天，以及是否為閏年 2 月)
CHECK_DAY_CARRY:
    LDX CAL_MONTH               ; 取出當前月份 (1 ~ 12)
    LDA MONTH_DAYS_TABLE-1,X   ; 查表取得該月最大天數 (存入 A)
    
    CPX #02h                    ; 檢查現在是不是 2 月 (February)？[cite: 10]
    BNE COMPARE_MAX_DAY         ; 不是 2 月就直接比對天數

; 是 2 月！呼叫剛剛包好的副程式來決定這年 2 月是 28 還是 29 天
    JSR CHECK_LEAP_YEAR         ; 執行完後，A 暫存器會自動帶入 #1Ch 或 #1Dh

COMPARE_MAX_DAY:
    ; 此時 A 暫存器為當月最大天數 (28/29/30/31)
    INC CAL_DAY                 ; 日期 + 1
    CMP CAL_DAY                 ; 比較 (當月最大天數 - 當前日期)
    BCS CAL_END                 ; 若 最大天數 >= CAL_DAY，代表還沒月底，結束！

    ; 超過當月最大天數，日期歸為 1 號，準備月進位
    LDA #01h
    STA CAL_DAY

    ; 6. 月進位 (1 ~ 12)
    INC CAL_MONTH
    LDA CAL_MONTH
    CMP #13
    BCC CAL_END                 ; 若 < 13 月，結束！
    LDA #01h
    STA CAL_MONTH               ; 回到 1 月

    ; 7. 年進位 (16-bit 加 1)
    INC CAL_YEAR_L
    BNE CAL_END
    INC CAL_YEAR_H

CAL_END:
    RTS

; 1~12 月份天數常數表 (對應 MAIN.c 的 MonthDays[])[cite: 10]
MONTH_DAYS_TABLE:
    .DB 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31

; =====================================================
; 萬年曆精準閏年判斷副程式 (支援任意年份，包含 400 年規則)
; 輸出：A 暫存器帶入 2 月天數 (#1Dh = 29天，#1Ch = 28天)
; =====================================================
CHECK_LEAP_YEAR:
    PHA
    TXA
    PHA                         ; 保護 A 與 X 暫存器

    ; -------------------------------------------------
    ; 規則 1：能被 4 整除的年份通常是閏年[cite: 13]
    ; -------------------------------------------------
    LDA CAL_YEAR_L
    AND #03h                    
    BNE NOT_LEAP_YEAR_RET       ; 不能被 4 整除 -> 絕對是平年 (28天)

    ; 將年份複製到 TEMP_Y 準備進行 16-bit 減法
    LDA CAL_YEAR_L
    STA TEMP_Y_L
    LDA CAL_YEAR_H
    STA TEMP_Y_H

    ; -------------------------------------------------
    ; 規則 3：除非同時能被 400 整除，這時又會變成閏年[cite: 13]
    ; (連續減去 400，十六進位為 0190h)
    ; -------------------------------------------------
SUB_400_LOOP:
    LDA TEMP_Y_H
    CMP #01h
    BCC CHECK_400_REM           ; 高位 < 1 (數值 < 256 < 400)，結束減法
    BNE DO_SUB_400              ; 高位 > 1 (數值 >= 512 > 400)，繼續減
    LDA TEMP_Y_L
    CMP #90h
    BCC CHECK_400_REM           ; 高位 = 1 且 低位 < 90h (數值 < 400)，結束減法

DO_SUB_400:
    SEC
    LDA TEMP_Y_L
    SBC #90h
    STA TEMP_Y_L
    LDA TEMP_Y_H
    SBC #01h
    STA TEMP_Y_H
    JMP SUB_400_LOOP            ; 迴圈直到 TEMP_Y < 400

CHECK_400_REM:
    ; 檢查減完 400 後餘數是否為 0
    LDA TEMP_Y_H
    BNE SUB_100_LOOP
    LDA TEMP_Y_L
    BNE SUB_100_LOOP
    JMP IS_LEAP_YEAR_RET        ; 餘數為 0，代表能被 400 整除 -> 閏年！

    ; -------------------------------------------------
    ; 規則 2：如果能被 100 整除，則不是閏年[cite: 13]
    ; (此時 TEMP_Y 小於 400，繼續連續減去 100，十六進位為 0064h)
    ; -------------------------------------------------
SUB_100_LOOP:
    LDA TEMP_Y_H
    BNE DO_SUB_100              ; 高位 > 0 (數值 >= 256 > 100)，繼續減
    LDA TEMP_Y_L
    CMP #64h
    BCC CHECK_100_REM           ; 高位 = 0 且 低位 < 64h (數值 < 100)，結束減法

DO_SUB_100:
    SEC
    LDA TEMP_Y_L
    SBC #64h
    STA TEMP_Y_L
    LDA TEMP_Y_H
    SBC #00h
    STA TEMP_Y_H
    JMP SUB_100_LOOP            ; 迴圈直到 TEMP_Y < 100

CHECK_100_REM:
    ; 檢查減完 100 後餘數是否為 0 (此時高位必定為 0，只查低位)
    LDA TEMP_Y_L
    BEQ NOT_LEAP_YEAR_RET       ; 餘數為 0，能被 100 整除但不能被 400 整除 -> 平年！[cite: 13]

    ; -------------------------------------------------
    ; 排除所有例外後，剩下能被 4 整除的皆為閏年
    ; -------------------------------------------------
IS_LEAP_YEAR_RET:
    PLA
    TAX
    PLA
    LDA #1Dh                    ; 閏年 2 月有 29 天 (Hex 1Dh)
    RTS

NOT_LEAP_YEAR_RET:
    PLA
    TAX
    PLA
    LDA #1Ch                    ; 平年 2 月有 28 天 (Hex 1Ch)
    RTS

; =====================================================
; 等待接收 1 個 UART Byte (含 Timeout 與餵狗保護)
; 輸出：成功時 Carry = 0 (資料在 RX_DATA)
;       超時時 Carry = 1
; =====================================================
WAIT_UART_BYTE:
    LDA #0FFh
    STA TIMEOUT_L
    STA TIMEOUT_H   
WAIT_BYTE_LOOP:
    JSR CLEAR_WDT
    LDA RX_READY
    BNE GOT_BYTE                ; 收到資料了！
    
    DEC TIMEOUT_L 
    BNE WAIT_BYTE_LOOP
    DEC TIMEOUT_H 
    BNE WAIT_BYTE_LOOP
    
    SEC                         ; Timeout 發生！設定 Carry = 1 代表失敗
    RTS
GOT_BYTE:
    LDA #00h
    STA RX_READY                ; 清除接收旗標
    CLC                         ; 清除 Carry = 0 代表成功
    RTS

; =====================================================
; 使用留存的 RX_TAG 回傳封包給上層
; 回傳範例：FF 55 [Len=03] [RX_TAG] [Mode=01] [收到的Data] [Checksum]
; =====================================================
SEND_RESPONSE_WITH_TAG:
    LDA #0FFh
    JSR UART_SEND_BYTE          ; 1. 送出 FF
    LDA #55h
    JSR UART_SEND_BYTE          ; 2. 送出 55

    LDA SAVE_LEN                
    STA CHK_SUM                 ; 初始化 Checksum
    JSR UART_SEND_BYTE          ; 3. 送出 Length

    LDX #00h                    ; 準備迴圈讀取 RX_BUF
SEND_PAYLOAD_LOOP:
    LDA RX_BUF,X               ; 讀取 Payload Data
    CLC
    ADC CHK_SUM                 ; 累加 Checksum
    STA CHK_SUM
    
    LDA RX_BUF,X               ; 再次載入 Data 準備發送
    JSR UART_SEND_BYTE          ; 4. 送出 Data

    INX
    DEC SAVE_LEN                ; 利用 SAVE_LEN 作為倒數計數器
    BNE SEND_PAYLOAD_LOOP       ; 迴圈直到 Payload 全數送出

    ; 5. 送出 Checksum
    LDA CHK_SUM
    EOR #0FFh                   ; 1 補數
    CLC
    ADC #01h                    ; 變成 2 補數
    JSR UART_SEND_BYTE
    RTS

; =====================================================
; 初始化 IO 狀態
; =====================================================
INIT_IO_PORTS:
    ; Initial GPIO to PP mode
    ; 54h = 0101 0100B -> 將 P1.3, P1.2, P1.1  設為 01 (Push-Pull 推輓輸出) P1.0 設為 00 (AIO)
    LDA #50h
    STA P1M0
    ; FFh = 1111 1111B -> 將 P3.3, P3.2, P3.1, P3.0 皆設為 11 (Quasi-Bidirectional 準雙向模式)
    LDA #FFh 
    STA P3M0
    RTS
; =====================================================
; 初始化 INT2 狀態
; =====================================================
INIT_EXT_INT:
    ; 10h = 0001 0000B -> 設置 EI2ES(Bit5:4) 為 01 (負緣觸發)
    LDA EICR1
    AND #0CFh           ; 清除 Bit 5:4
    ORA #10h            ; 設為 01
    STA EICR1
	
    ; 70h = 0100 0000B -> 寫 1 清除 Bit 6 (IE2) 旗標
    LDA #40h 
    STA IRQ0_STS                ; (IRQ Status 0, 00E1h)
    
    ; 70h = 0100 0000B -> 將 Bit 6 (EX2) 設為 1 開啟中斷
	LDA IRQ0_EN
    ORA #40h 
    STA IRQ0_EN                 ; (IRQ Enable 0, 3001h)
    RTS
; =====================================================
; 初始化 RTC 狀態(設定每 1 秒溢位觸發一次 RTCF 中斷)
; =====================================================
INIT_RTC:
    ; 1. 先確定 RTCE = 0 才能寫入 RTC_TM 與 RTC_CS[cite: 1]
    LDA #PWPR_Key
    STA PWPR
    LDA #3Fh                    ; RTCE=0, RTCO=0, RTCRL=3Fh (63，每數 1 下就溢位 = 1秒)[cite: 1]
    STA RTC_CR

    ; 2. 設定 Clock Source = ILRCO (RCSS=001), Step = 1秒 (RTCCS=0000)[cite: 1, 9]
    LDA #PWPR_Key
    STA PWPR
    LDA #20h                    ; 0010_0000B[cite: 1, 9]
    STA RTC_CS

    ; 3. 設定當前計數器初值 RTCCT = 3Fh (63)[cite: 1]
    LDA #PWPR_Key
    STA PWPR
    LDA #3Fh                    ; RPSC=00, RTCCT=3Fh[cite: 1]
    STA RTC_TM

    ; 4. 清除 RTCF 歷史旗標 (IRQ1_STS Bit 1 寫 1 清零)[cite: 1]
    LDA #02h
    STA IRQ1_STS

    ; 5. 開啟 RTC 中斷 (IRQ1_EN Bit 1: ERTCF = 1，允許從 STOP 模式喚醒)[cite: 1]
    LDA IRQ1_EN
    ORA #02h
    STA IRQ1_EN

    ; 6. 啟動 RTC (將 RTC_CR 的 Bit 7 RTCE 設為 1，同時維持 RTCRL=3Fh -> BAh/BFh)[cite: 1]
    LDA #PWPR_Key
    STA PWPR
    LDA #0BFh                   ; 1011_1111B (RTCE=1, RTCO=0, RTCRL=3Fh)[cite: 1]
    STA RTC_CR

    RTS

; =====================================================
; 進入休眠準備 (將 P3.0 接收權交給 INT2)
; =====================================================
PREPARE_SLEEP:
    LDA #PWPR_Key
    STA PWPR
    LDA DEFAULT_OR08
    STA OR08

    ; --- 檢查是否處於 >4.2V 過壓鎖定狀態，若已降回 <4.2V (BO1O == 1) 則解除鎖定 ---
    LDA VDD_LOCK_FLAG
    BEQ CHECK_AC0_LOCK_SLEEP

    LDA PWR_CR1
    AND #20h                    
    BEQ CHECK_AC0_LOCK_SLEEP    ; 若 BO1O = 0 (仍在 4.2V 以上)，保持鎖定

    ; 已降回 4.2V 以下 (BO1O == 1)！解除過壓鎖定
    LDA #00h
    STA VDD_LOCK_FLAG

CHECK_AC0_LOCK_SLEEP:

    ; --- 檢查是否處於過溫鎖定狀態，若已降溫 (AC0O == 0) 則重新開啟 AC0 喚醒中斷 ---
    LDA OT_LOCK_FLAG
    BEQ SLEEP_CFG_UART          

    LDA AC0CR0
    AND #20h                    
    BNE SLEEP_CFG_UART          

    LDA #00h
    STA OT_LOCK_FLAG
    LDA #30h
    STA IRQ1_STS                
    LDA IRQ1_EN
    ORA #20h                    
    STA IRQ1_EN

SLEEP_CFG_UART:
    LDA IRQ0_EN
    AND #0FEh           
    STA IRQ0_EN
	
    LDA #40h            
    STA S1CON
	JSR INIT_EXT_INT

	LDA #PWPR_Key
	STA PWPR
	LDA #02h
	STA PWR_CTL
	RTS
; =====================================================
; 初始化 WDT 狀態
; =====================================================
INIT_WDT:
	; 初始化 WDT
    ; WDT_CR0 = 0x8E (WREN=1, NSW=0 休眠暫停, WPS=110 1s)
	LDA #PWPR_Key
	STA PWPR
    LDA #8Eh               
    STA WDT_CR0
    ; WDT_CR1 = 0xC0 (CLRW=1 餵狗, ENW=1 啟動)
	LDA #PWPR_Key
	STA PWPR
	LDA #C0h               
    STA WDT_CR1
	RTS
; =====================================================
; 餵狗 (Clear WDT) 副程式
; 說明：解除 SFR 寫入保護，並清除 WDT 計數器以避免系統重置
; =====================================================
CLEAR_WDT:
    LDA #PWPR_Key           ; 載入 5Ah 密碼以解除寫保護機制
    STA PWPR                ; 寫入 PWPR 暫存器
    
    LDA #C0h                ; Bit 7 (CLRW) = 1 清除計數器, Bit 6 (ENW) = 1 保持啟動
    STA WDT_CR1             ; 寫入看門狗控制暫存器 1
    
    RTS                     ; 返回呼叫點
; =====================================================
; 初始化 ILRCO再stop mode狀態
; =====================================================
INIT_ILRCO_in_stop_mode:
    ;CK_CTL = 0x80 (ILPDX= 1 ILRCO control in PD mode)
	LDA #PWPR_Key           ; 載入 5Ah 密碼以解除寫保護機制
    STA PWPR
	LDA CK_CTL
	ORA #80h
	STA CK_CTL
	RTS
; =====================================================
; UART 副程式區 Baud rate =9600
; =====================================================
INIT_UART:
    LDA CK_CTL
    ORA #01h                    ; Bit 0 (IHEN) = 1，開啟內部高頻振盪器 (IHRCO)
    STA CK_CTL
    LDA PWR_CTL
    AND #0F3h                   ; 清除 Bit 3 (OSCS1) 與 Bit 2 (OSCS0)，確保時脈源設定正確
    STA PWR_CTL
    LDA MCK_CTL
    ORA #04h                    ; Bit 2 (URCE) = 1，啟用 UART 模組時脈
    STA MCK_CTL
    LDA #0FDh                   ; S1BRT 設定：寫入鮑率計時器重載值 (依系統時脈對應 9600 bps)
    STA S1BRT
    ; 50h = 0101 0000B -> Bit 6 (SM11) = 1 啟用 8-bit UART，Bit 4 (REN1) = 1 允許接收
    LDA #50h                    ; S1CON 設定 
    STA S1CON
    ; 38h = 0011 1000B -> 設置 S1MOD3, S1DOR, S1TR (鮑率時脈產生器相關配置)
    LDA #38h                    ; S1CFG 設定
    STA S1CFG
    ; 等待 TXD 空閒
    LDX #00h
WAIT_TXD_IDLE:
    NOP
    DEX
    BNE WAIT_TXD_IDLE
    RTS
UART_SEND_BYTE:
    STA S1BUF                   ; 將 A 暫存器內容寫入 UART 緩衝區 (S1BUF, 3031h) 開始傳送
WAIT_TI1:
    LDA S1CON
    AND #02h                    ; 等待傳送完成 (檢查 TI1 flag, Bit 1)
    BEQ WAIT_TI1                
    LDA S1CON
    AND #0FCh                   
    ORA #02h                    ; 寫入 1 至 Bit 1 來清除 TI1 旗標 (Megawin 特殊清旗標機制)
    STA S1CON
    RTS
; =====================================================
; [更新] 印出重置旗標副程式 (Hex 轉 ASCII)
; =====================================================
PRINT_RST_FLAG:
    ; --- 印出 "RST0=" ---
    LDA #52h ; 'R'
    JSR UART_SEND_BYTE
    LDA #53h ; 'S'
    JSR UART_SEND_BYTE
    LDA #54h ; 'T'
    JSR UART_SEND_BYTE
    LDA #30h ; '0'
    JSR UART_SEND_BYTE
    LDA #3Dh ; '='
    JSR UART_SEND_BYTE

    ; 轉換並印出 RAM00 (RST_SRF0)
    LDA RAM00
    LSR A
    LSR A
    LSR A
    LSR A
    JSR NIBBLE_TO_ASCII
    JSR UART_SEND_BYTE
    LDA RAM00
    AND #0Fh
    JSR NIBBLE_TO_ASCII
    JSR UART_SEND_BYTE

    ; --- 印出 ", RST1=" ---
    LDA #2Ch ; ','
    JSR UART_SEND_BYTE
    LDA #20h ; ' '
    JSR UART_SEND_BYTE
    LDA #52h ; 'R'
    JSR UART_SEND_BYTE
    LDA #53h ; 'S'
    JSR UART_SEND_BYTE
    LDA #54h ; 'T'
    JSR UART_SEND_BYTE
    LDA #31h ; '1'
    JSR UART_SEND_BYTE
    LDA #3Dh ; '='
    JSR UART_SEND_BYTE

    ; 轉換並印出 RAM01 (RST_SRF1)
    LDA RAM01
    LSR A
    LSR A
    LSR A
    LSR A
    JSR NIBBLE_TO_ASCII
    JSR UART_SEND_BYTE
    LDA RAM01
    AND #0Fh
    JSR NIBBLE_TO_ASCII
    JSR UART_SEND_BYTE

    ; --- 印出換行 \r\n ---
    LDA #0Dh
    JSR UART_SEND_BYTE
    LDA #0Ah
    JSR UART_SEND_BYTE
    RTS

; 將 0x0~0xF 轉換為 ASCII ('0'~'9', 'A'~'F')
NIBBLE_TO_ASCII:
    CMP #0Ah
    BCC ADD_30
    ADC #06h
ADD_30:
    ADC #30h
    RTS
;=============================================
; INTERRUPT SERVICE ROUTINE 
;=============================================
irq_isr:
    PHA

    ; ---------------------------------------------------
    ; 1. 檢查 UART1 接收 (RI1i)
    ; ---------------------------------------------------
CHECK_UART_RX:
    LDA IRQ0_STS
    AND #01h             ; 檢查 Bit 0: RI1i
    BEQ CHECK_INT2       

    ; --- 執行真正資料的接收 ---
    LDA S1CON
    AND #0FCh            
    ORA #01h
    STA S1CON            ; 寫 1 清除 RI1 旗標
    
    LDA S1BUF            ; 讀取 UART 資料
    STA RX_DATA          ; 存入變數
    
    LDA #01h
    STA RX_READY         ; 標記「資料已備妥」，通知主迴圈

    ; ---------------------------------------------------
    ; 2. 檢查 INT2 (P3.0) 喚醒
    ; ---------------------------------------------------
CHECK_INT2:
    LDA IRQ0_STS
    AND #40h             ; 檢查 Bit 6: IE2
    BEQ CHECK_RTC      

    ; --- 執行 INT2 喚醒處理 ---
    LDA #40h             
    STA IRQ0_STS         ; 清除 IE2 旗標

    LDA IRQ0_EN
    AND #0BFh            
    STA IRQ0_EN          ; 關閉 INT2 中斷 (EX2=0)
WAIT_RX_HIGH:
    LDA P3_PIN           ; 讀取 Port 3 腳位狀態 (00E5h)
    AND #01h             ; 檢查 P3.0 (RXD1)
    BEQ WAIT_RX_HIGH     ; 如果還是 Low，代表 Dummy Byte 還沒傳完，原地等它變 High

    ; P3.0 已經回到 Stop Bit (High)，現在開啟 REN1 絕對不會錯位
    LDA #50h             ; SM11=1, REN1=1 (重新開啟 UART 接收引擎)
    STA S1CON            

    LDA S1CON
    ORA #01h             
    STA S1CON            ; 清除 RI1 旗標 (丟棄 Dummy 造成的亂碼)

    LDA IRQ0_EN
    ORA #01h             
    STA IRQ0_EN          ; 開啟 UART 接收中斷 (ERI1=1)

    LDA #01h
    STA WAKEUP_FLAG      ; 標記「MCU 已喚醒」，通知主迴圈別再睡了

    ; ---------------------------------------------------
    ; 3. 檢查 RTC 1 秒中斷 (Bit 1: RTCF)
    ; ---------------------------------------------------
CHECK_RTC:
    LDA IRQ1_STS         ; 讀取 00E2h
    AND #02h             ; 檢查 Bit 1: RTCF
    BEQ CHECK_BOD1

    LDA #02h
    STA IRQ1_STS         ; 寫 1 清除 RTCF 旗標

    INC RTC_TICK         ; 標記「過了 1 秒」，交給主迴圈去算萬年曆！
; ---------------------------------------------------
    ; 4. 檢查 BOD1 過高壓狀態 (VDD > 4.2V 時 PWR_CR1 Bit 5 BO1O 為 0)
    ; ---------------------------------------------------
CHECK_BOD1:
    ; 若已經在過壓鎖定狀態 (VDD_LOCK_FLAG != 0)，直接跳過不重複觸發
    LDA VDD_LOCK_FLAG
    BNE CHECK_AC0

    ; 直接檢查 PWR_CR1 的 Bit 5 (BO1O)：
    ; 3.3V 時為 1 (2Bh)，超過 4.2V 時變為 0 (0Bh)！
    LDA PWR_CR1
    AND #20h
    BNE CHECK_AC0               ; 若 Bit 5 != 0 (代表 VDD < 4.2V 正常)，直接跳去 CHECK_AC0！

    ; 確認真的超過 4.2V (BO1O == 0)！
    LDA #01h
    STA BOD1_WAKE_FLAG          ; 通知 main_loop 立即主動發送過壓告警封包 (Tag=DDh, Cmd=02h)
    STA VDD_LOCK_FLAG           ; 進入過壓鎖定狀態 (對應封包 RX_BUF+15 的 Bit 4 檢查點會變 1)
	
; ---------------------------------------------------
    ; 4. 檢查 AC0 過溫中斷 (Bit 5: AC0RF)
    ; ---------------------------------------------------
CHECK_AC0:
    ; 若目前已經處於過溫鎖定狀態 (OT_LOCK_FLAG != 0)，
    ; 代表這次是 RTC 或 UART 進來的中斷，直接跳過不處理 AC0！
    LDA OT_LOCK_FLAG
    BNE irq_isr_end

    LDA IRQ1_STS
    AND #20h                    ; 檢查 Bit 5: AC0RF
    BEQ irq_isr_end

    ; 先寫 1 清除 AC0RF / AC0FF 旗標
    LDA #30h
    STA IRQ1_STS

    ; 確認 AC0CR0 的 Bit 5 (AC0O) 現在真的處於 1 (過溫狀態)
    LDA AC0CR0
    AND #20h                    ; 檢查 AC0O 是否為 1
    BEQ irq_isr_end             ; 若 AC0O 是 0，直接忽略

    ; 確認真的過溫 (AC0O == 1)！關閉 EAC0R 中斷致能
    LDA IRQ1_EN
    AND #0DFh                   ; 清除 Bit 5: EAC0R
    STA IRQ1_EN

    LDA #01h
    STA AC0_WAKE_FLAG           ; 通知 main_loop 立即主動取樣並發送 UART
    STA OT_LOCK_FLAG            ; 標記進入過溫鎖定狀態，待降溫後再重開中斷

irq_isr_end:
    PLA
    RTI

;=============================================
; INTERRUPT VECTOR SECTION ;()
;=============================================
    .org FFFCH
VECTOR:

    .DB .LOW.reset      ;reset
    .DB .HIGH.reset     ;reset
    .DB .LOW.irq_isr    ;IRQ interrupt vector
    .DB .HIGH.irq_isr   ;IRQ interrupt vector


