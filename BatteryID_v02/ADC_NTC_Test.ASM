; ==============================================================================
; 常數與定義區 (EQU / DEFINITIONS)
; ==============================================================================
SET                 EQU 01H
CLR                 EQU 00H
DRV_Clr             EQU 00H
OR0F                EQU 310FH    
OR0D                EQU 310DH    
ADTS1_P             EQU 80H
ADTS0_P             EQU 40H

SPI_PORT            EQU P3    
SPI_MOSI_PIN        EQU 04H       
SPI_CLK_PIN         EQU 08H       

ADC_HighestPower    EQU 00H
ADC_MiddleHigh      EQU 40H
ADC_MiddleLow       EQU 80H
ADC_LowPower        EQU C0H

ADC_AIN0            EQU 00H
ADC_AIN1            EQU 01H
ADC_AIN2            EQU 02H
ADC_AIN3            EQU 03H
ADC_IntVREF         EQU 08H
ADC_AVSS            EQU 09H
ADC_Vcap            EQU 0AH

ADC_SYSCLK          EQU 00H
ADC_SYSCLKD2        EQU 20H
ADC_SYSCLKD4        EQU 40H
ADC_SYSCLKD8        EQU 60H
ADC_SYSCLKD16       EQU 80H
ADC_SYSCLKD32       EQU A0H
ADC_S1TOFD2         EQU C0H
ADC_T1OFD2          EQU E0H

ADC_LeftJustified   EQU 00H
ADC_RightJustified  EQU 10H     

ADC_Conversion_24CLK EQU 01H
ADC_Conversion_30CLK EQU 00H

DRV_ENABLE          EQU 01H
DRV_DISABLE         EQU 00H

CH_MASK             EQU 0FH     
CH_CLR_MASK         EQU F0H     
CLK_MASK            EQU E0H     
CLK_CLR_MASK        EQU 1FH     
ALIGN_MASK          EQU 10H     
ALIGN_CLR_MASK      EQU EFH     
PWR_MASK            EQU C0H     
PWR_CLR_MASK        EQU 3FH     
ACMTE               EQU 08H  
OR0B                EQU 310BH 
TST_CTL0            EQU 3017H   
V14OE               EQU 40H  
OR0A                EQU 310AH 
DEVICE_ID           EQU 01H
; ==============================================================================
; 變數與記憶體宣告區 (Zero Page / RAM)
; ==============================================================================
        .PAGE0
ZP_I_L:             .DS 1   
ZP_I_H:             .DS 1   
ZP_I:               .DS 1     
ZP_K:               .DS 1       
ZP_CMD1:            .DS 1   
ZP_CMD2:            .DS 1       
ZP_CMD3:            .DS 1   
ZP_CMD_L:           .DS 1    
ZP_CMD_H:           .DS 1      
ZP_RES_L:           .DS 1      
ZP_RES_H:           .DS 1       
ZP_DACV_L:          .DS 1
ZP_DACV_H:          .DS 1
ZP_PAGE_ADDR:       .DS 1
ZP_PAGE_DAT:        .DS 1
ZP_CHANNEL:         .DS 1      
ZP_DIGIT:           .DS 1  
ZP_LZ_FLAG:         .DS 1   
ZP_STR_PTR_L:       .DS 1  
ZP_STR_PTR_H:       .DS 1   

ZP_RX_STATE:        .DS 1       
ZP_RX_LEN:          .DS 1       
ZP_RX_CNT:          .DS 1       
ZP_RX_SUM:          .DS 1       
ZP_PACKET_READY:    .DS 1       
ZP_RX_BUF:          .DS 4       
ZP_VREF_L:          .DS 1       
ZP_VREF_H:          .DS 1
ZP_RX_TMP:          .DS 1       
ZP_RX_FLAG:         .DS 1       

ASCIICode           .DS 1    
ASCL                .DS 1
ASCH                .DS 1  
ZP_SPI_DATA         .DS 1    
ZP_SPI_I            .DS 1  
ZP_SAMPLE_CNT       .DS 1    
ZP_SAMPLE_CNT_NTC   .DS 1    
        .ENDS

        .CODE
; ==============================================================================
; 主程式 ADC_NTC_Test
; ==============================================================================
ADC_NTC_Test:
        SEI
        LDA     #0CH
        STA     MCK_CTL
	LDA	#F7H
	STA	P1_DAT
        LDA     #40H        
        STA     P1M0
        LDA     #FFH
        STA     P3M0
        LDA     P3M0
        AND     #57H            
        STA     P3M0
        
        JSR     INIT_UART_115200_in12MHz 

        LDA     #<TST_CTL0
        ORA     #V14OE          
        TAX                    
        LDA     #<TST_CTL0
        JSR     PageP_Write

        LDA     #DRV_ENABLE
        JSR     ADC_IVREF_Cmd

        LDA     AC0CR1
        ORA     #08H
        STA     AC0CR1

        JSR     ADC_initial
        LDA     #DRV_DISABLE
        JSR     ADC_ACMTE_Cmd
        
        LDA     #ADC_SYSCLK
        JSR     ADC_Clock_Select
        LDA     #0
        JSR     ADC_SetExtenSampleTime_CMP
        LDA     #DRV_ENABLE
        JSR     ADC_Cmd
        LDA     #ADC_Conversion_30CLK
        JSR     ADC_SetConversionSpeed
        JSR     Delay_30000_CMP  

        ; 初始化 RX 狀態機與旗標
        LDA     #0
        STA     ZP_RX_STATE
        STA     ZP_PACKET_READY
        STA     ZP_RX_FLAG
        CLI                     

	LDA     #5AH
        STA     PWPR
        LDA     #0AH
        STA     PWR_CTL
        
	.if 0
        ; 開機 Debug 字串，
        LDA     #<STR_BOOT
        LDX     #>STR_BOOT
        JSR     WriteString2Uart

		LDA     #DEVICE_ID      ; 將設定的 deviceN 載入 A 暫存器
        JSR     PRINT_ACC       ; 轉換為 2 碼 ASCII Hex 印出 

	; 補上換行符號 (CR+LF)
        LDA     #0DH
        JSR     UART1_Send_Data
        LDA     #0AH
        JSR     UART1_Send_Data
        .endif

; ==============================================================================
; 主迴圈 (輪詢中斷旗標與 AAP 解析)
; ==============================================================================
L_Main_Loop:        

        
        LDA     ZP_RX_FLAG
        BNE     L_Has_RX_Data   
        JMP     L_Check_Packet  

L_Has_RX_Data:
        LDA     #0
        STA     ZP_RX_FLAG      

        LDA     ZP_RX_STATE
        CMP     #0
        BEQ     ST_WAIT_FF
        CMP     #1
        BEQ     ST_WAIT_55
        CMP     #2
        BEQ     ST_WAIT_LEN
        CMP     #3
        BEQ     ST_READ_PAYLOAD
        CMP     #4
        BEQ     ST_READ_CHK
        JMP     ST_RESET

ST_WAIT_FF:
        LDA     ZP_RX_TMP
        CMP     #0FFH
        BNE     L_Rx_State_End
        LDA     #1
        STA     ZP_RX_STATE
        JMP     L_Rx_State_End

ST_WAIT_55:
        LDA     ZP_RX_TMP
        CMP     #55H
        BNE     ST_RESET
        LDA     #2
        STA     ZP_RX_STATE
        JMP     L_Rx_State_End

ST_WAIT_LEN:
        LDA     ZP_RX_TMP
        STA     ZP_RX_LEN
        STA     ZP_RX_SUM       
        LDA     #0
        STA     ZP_RX_CNT
        LDA     #3
        STA     ZP_RX_STATE
        JMP     L_Rx_State_End

ST_READ_PAYLOAD:
        LDA     ZP_RX_TMP
        CLC
        ADC     ZP_RX_SUM       
        STA     ZP_RX_SUM
        
        LDX     ZP_RX_CNT
        CPX     #4              
        BCS     L_Skip_Store
        LDA     ZP_RX_TMP
        STA     ZP_RX_BUF,X
L_Skip_Store:
        INC     ZP_RX_CNT
        LDA     ZP_RX_CNT
        CMP     ZP_RX_LEN       
        BNE     L_Rx_State_End
        LDA     #4
        STA     ZP_RX_STATE
        JMP     L_Rx_State_End

ST_READ_CHK:
        LDA     #0
        SEC
        SBC     ZP_RX_SUM
        STA     ZP_RX_SUM       
        LDA     ZP_RX_TMP       
        CMP     ZP_RX_SUM
        BNE     ST_RESET        
        
        LDA     #1
        STA     ZP_PACKET_READY 
        ;JMP     L_Rx_State_End

ST_RESET:
        LDA     #0
        STA     ZP_RX_STATE

L_Rx_State_End:
        JMP     L_Check_Packet  

L_Check_Packet:
        LDA     ZP_PACKET_READY
        BNE     L_Packet_Ready_Yes  
        JMP     L_Main_Loop         

L_Packet_Ready_Yes:
        LDA     #0
        STA     ZP_PACKET_READY

        LDA     ZP_RX_LEN
        CMP     #04H
        BNE     L_Check_Fail
        LDA     ZP_RX_BUF+0     
        CMP     #DEVICE_ID
        BNE     L_Check_Fail
        LDA     ZP_RX_BUF+2     ; 確認 Command H = 00H
        CMP     #00H
        BNE     L_Check_Fail
        
        LDA     ZP_RX_BUF+1     ; 判斷 Mode
        CMP     #01H
        BEQ     L_Check_Mode1
        CMP     #02H
        BEQ     L_Check_Mode2
        JMP     L_Check_Fail

L_Check_Mode1:
        LDA     ZP_RX_BUF+3     ; 確認 Mode 1 的 Command L
        CMP     #01H
        BNE     L_Check_Fail
        JMP     L_Cmd_ADC       ; 執行原本的 ADC 轉換

L_Check_Mode2:
        LDA     ZP_RX_BUF+3     ; 確認 Mode 2 的 Command L
        CMP     #01H
        BEQ     L_Cmd_Fuse      ; 執行原本的 fuse trigger (00 01)
        CMP     #02H
        BEQ     L_Cmd_Fuse_Reset; 執行新的復位指令 (00 02)
        JMP     L_Check_Fail

L_Check_Fail:
        JMP     L_Main_Loop     
        
; --- 原本的 02 指令處理區塊 (Command L = 01) ---
L_Cmd_Fuse:
        ; === 回傳 AAP 格式資料：FF 55 05 01 02 00 01 01 F6 ===
        LDA     #0FFH           
        JSR     Print_Byte_Space
        LDA     #55H            
        JSR     Print_Byte_Space
        
        LDA     #05H            ; Length = 05H
        STA     ZP_RX_SUM       
        JSR     Print_Byte_Space
        
        LDA     #DEVICE_ID       ; Device ID
        JSR     Sum_And_Print_Byte
        LDA     #02H            ; Mode = 02H
        JSR     Sum_And_Print_Byte
        LDA     #00H            ; Command H = 00H
        JSR     Sum_And_Print_Byte
        LDA     #01H            ; Command L = 01H
        JSR     Sum_And_Print_Byte
        LDA     #01H            ; Param 1   = 01H
        JSR     Sum_And_Print_Byte
        
        ; 計算 AAP Checksum = 0x100 - 0x0A = 0xF6
        LDA     #0
        SEC
        SBC     ZP_RX_SUM
        JSR     Print_Byte_Space

        ; 補上換行符號 (CR+LF)
        LDA     #0DH
        JSR     UART1_Send_Data
        LDA     #0AH
        JSR     UART1_Send_Data

        LDA	P1_PIN
	ORA	#08H
	STA	P1_DAT
	LDX   	#05H              ; 將計數器設為 5 (迴圈跑 5 次)
DELAY_LOOP:
	JSR   	Delay_30000_CMP   ; 呼叫延遲副程式
	DEX                     ; 計數器減 1
	BNE   	DELAY_LOOP        ; 若計數器不為 0，則跳回 DELAY_LOOP 繼續
	LDA	P1_PIN
	AND	#F7H
	STA	P1_DAT
	
        JMP     L_Main_Loop

; --- 新增的 02 復位指令處理區塊 (Command L = 02) ---
L_Cmd_Fuse_Reset:
	LDA	P1_PIN
	AND	#F7H
	STA	P1_DAT
        ; === 回傳 AAP 格式資料：FF 55 05 01 02 00 02 01 F5 ===
        LDA     #0FFH           
        JSR     Print_Byte_Space
        LDA     #55H            
        JSR     Print_Byte_Space
        
        LDA     #05H            ; Length = 05H
        STA     ZP_RX_SUM       
        JSR     Print_Byte_Space
        
        LDA     #DEVICE_ID       ; Device ID (01H)
        JSR     Sum_And_Print_Byte
        LDA     #02H            ; Mode = 02H
        JSR     Sum_And_Print_Byte
        LDA     #00H            ; Command H = 00H
        JSR     Sum_And_Print_Byte
        LDA     #02H            ; Command L = 02H
        JSR     Sum_And_Print_Byte
        LDA     #01H            ; Param 1   = 01H
        JSR     Sum_And_Print_Byte
        
        ; 計算 AAP Checksum = 0x100 - (05+01+02+00+02+01 = 0x0B) = 0xF5
        LDA     #0
        SEC
        SBC     ZP_RX_SUM
        JSR     Print_Byte_Space

        ; 補上換行符號 (CR+LF)
        LDA     #0DH
        JSR     UART1_Send_Data
        LDA     #0AH
        JSR     UART1_Send_Data
        
        JMP     L_Main_Loop
; --- 原本的 01 指令中繼站 ---
L_Cmd_ADC:
        JMP     L_Check_Pass    ; 驗證全過，跳往原本下方的 L_Check_Pass 區塊
L_Check_Pass:
        ;LDA     #<STR_PACKET
        ;LDX     #>STR_PACKET
        ;JSR     WriteString2Uart

        LDA     #ADC_IntVREF
        JSR     ADC_Channel_Select
        JSR     ADC_StartConversion
L_Wait_VREF:              
        ;clear_WDT
        JSR     ADC_GetConversionFlag
        CMP     #DRV_Clr
        BEQ     L_Wait_VREF
        JSR     ADC_ClearFlag        
        JSR     ADC_GetConversionData  
        STA     ZP_VREF_L
        STX     ZP_VREF_H

        LDA     #ADC_AIN0
        JSR     ADC_Channel_Select
        JSR     ADC_StartConversion
L_Wait_NTC:              
        ;clear_WDT
        JSR     ADC_GetConversionFlag
        CMP     #DRV_Clr
        BEQ     L_Wait_NTC
        JSR     ADC_ClearFlag        
        JSR     ADC_GetConversionData  
        STA     ZP_RES_L        
        STX     ZP_RES_H        

        LDA     #0FFH           
        ;JSR     UART1_Send_Data
        JSR     Print_Byte_Space
        LDA     #55H            
        ;JSR     UART1_Send_Data
        JSR     Print_Byte_Space
        
        LDA     #08H            
        ;JSR     UART1_Send_Data
        ;STA     ZP_RX_SUM      
        STA     ZP_RX_SUM       ; 初始化發送 Checksum 累加
        JSR     Print_Byte_Space
        
        LDA     #DEVICE_ID           
        ;JSR     Send_And_Sum
        JSR     Sum_And_Print_Byte
        LDA     #01H            
        ;JSR     Send_And_Sum
        JSR     Sum_And_Print_Byte
        LDA     #00H            
        ;JSR     Send_And_Sum
        JSR     Sum_And_Print_Byte
        LDA     #01H            
        ;JSR     Send_And_Sum
        JSR     Sum_And_Print_Byte
        
        LDA     ZP_VREF_H       
        ;JSR     Send_And_Sum
        JSR     Sum_And_Print_Byte
        LDA     ZP_VREF_L       
        ;JSR     Send_And_Sum
        JSR     Sum_And_Print_Byte
        
        LDA     ZP_RES_H        
        ;JSR     Send_And_Sum
        JSR     Sum_And_Print_Byte
        LDA     ZP_RES_L        
        ;JSR     Send_And_Sum
        JSR     Sum_And_Print_Byte
        
        LDA     #0
        SEC
        SBC     ZP_RX_SUM
        ;JSR     UART1_Send_Data
	JSR     Print_Byte_Space

	; 發送換行符號 (CR+LF) 讓每次回傳獨立成行
        LDA     #0DH
        JSR     UART1_Send_Data
        LDA     #0AH
        JSR     UART1_Send_Data

        JMP     L_Main_Loop

; ------------------------------------------------------------------------------
; 輔助函式：累加 Checksum 並轉成 ASCII 印出
; ------------------------------------------------------------------------------
Sum_And_Print_Byte:
        PHA                     
        CLC
        ADC     ZP_RX_SUM       
        STA     ZP_RX_SUM
        PLA                     
        ; 順勢往下執行 Print_Byte_Space

Print_Byte_Space:
        PHA                     ; 備份原始數值
        JSR     PRINT_ACC       ; 轉換為 2 碼 ASCII Hex 字元發送
        LDA     #' '            ; 發送一個空白字元分開數值
        JSR     UART1_Send_Data
        PLA                     ; 恢復原始數值
        RTS

Send_And_Sum:
        PHA                     
        CLC
        ADC     ZP_RX_SUM       
        STA     ZP_RX_SUM
        PLA                     
        JMP     UART1_Send_Data 

; ==============================================================================
; UART1 RX 硬體中斷常式
; ==============================================================================
irq_isr:
        PHA                     

        LDA     IRQ0_STS
        AND     #01H            
        BEQ     L_ISR_END       

        LDA     S1BUF           
        STA     ZP_RX_TMP       
        LDA     #01H
        STA     ZP_RX_FLAG      

        LDA     #51H            
        STA     S1CON

L_ISR_END:
        PLA                     
        RTI                     

; ==============================================================================
; ADC 基本控制指令區
; ==============================================================================
ADC_Cmd:
        CMP     #DRV_ENABLE
        BEQ     CMD_ENABLE_LABEL
        LDA     ADCON
        AND     #7FH            
        STA     ADCON
        RTS
CMD_ENABLE_LABEL:
        LDA     ADCON
        ORA     #80H            
        STA     ADCON
        RTS

ADC_SetConversionSpeed:
        CMP     #ADC_Conversion_24CLK
        BEQ     CMD_ADHS_LABEL
        LDA     ADCFG0
        AND     #0F7H           
        STA     ADCFG0
        RTS
CMD_ADHS_LABEL:
        LDA     ADCFG0
        ORA     #08H          
        STA     ADCFG0
        RTS

ADC_Channel_Select:
        PHA                
        LDA     ADCON
        AND     #CH_CLR_MASK    
        STA     ADCON
        PLA                 
        AND     #CH_MASK        
        ORA     ADCON          
        STA     ADCON
        RTS

ADC_StartConversion:
        LDA     ADCON
        ORA     #40H            
        STA     ADCON
        RTS

ADC_GetConversionFlag:
        LDA     IRQ1_STS
        AND     #08H            
        BEQ     FLAG_ZERO_LABEL
        LDA     #01H
        RTS
FLAG_ZERO_LABEL:
        LDA     #00H
        RTS

ADC_ClearFlag:
        LDA     IRQ1_STS
        ORA     #08H            
        STA     IRQ1_STS
        RTS

ADC_Clock_Select:
        PHA
        LDA     ADCFG0
        AND     #CLK_CLR_MASK   
        STA     ADCFG0
        PLA
        AND     #CLK_MASK        
        ORA     ADCFG0
        STA     ADCFG0
        RTS

ADC_DataAlignment_Select:
        PHA
        LDA     ADCFG0
        AND     #ALIGN_CLR_MASK      
        STA     ADCFG0
        PLA
        ORA     ADCFG0          
        STA     ADCFG0
        RTS

ADC_SetConversionPower:
        PHA
        LDA     ADCFG1
        AND     #PWR_CLR_MASK   
        STA     ADCFG1
        PLA
        ORA     ADCFG1          
        STA     ADCFG1
        RTS

ADC_GetConversionData:
        LDX     ADCDH0          
        LDA     ADCDL            
        RTS

ADC_ACMTE_Cmd:
        CMP     #DRV_ENABLE
        BEQ     ACMTE_CMD_ENABLE_LABEL
        LDA     ADCFG1
        AND     #0F7H           
        STA     ADCFG1
        RTS
ACMTE_CMD_ENABLE_LABEL:
        LDA     ADCFG1
        ORA     #08H          
        STA     ADCFG1
        RTS

ADC_SetExtenSampleTime_CMP:    
        STA     ADCFG2
        RTS

ADC_initial:
        LDA     #ADC_SYSCLKD2
        JSR     ADC_Clock_Select
        LDA     #ADC_RightJustified
        JSR     ADC_DataAlignment_Select
        LDA     #ADC_AIN0
        JSR     ADC_Channel_Select
        LDA     #ADC_HighestPower
        JSR     ADC_SetConversionPower
        LDA     #DRV_ENABLE
        JSR     ADC_Cmd
        RTS

ADC_IVREF_Cmd:
        CMP     #DRV_ENABLE
        BEQ     IVREF_CMD_ENABLE_LABEL
        LDA     ADCON
        AND     #0DFH           
        STA     ADCON
        RTS
IVREF_CMD_ENABLE_LABEL:
        LDA     ADCON
        ORA     #20H
        STA     ADCON
        RTS

; ==============================================================================
; UART 共用模組
; ==============================================================================
INIT_UART_115200_in12MHz:
        LDA     #253
        STA     S1BRC
        STA     S1BRT
        LDA     #50H
        STA     S1CON
        LDA     S1CFG
        ORA     #1CH
        STA     S1CFG
        LDA     IRQ0_EN         
        ORA     #01H
        STA     IRQ0_EN
        RTS

WriteString2Uart:
        STA     ZP_STR_PTR_L
        STX     ZP_STR_PTR_H
        LDY     #0
L_WS_Loop:
        LDA     (ZP_STR_PTR_L), Y
        BEQ     L_WS_Done          
        JSR     UART1_Send_Data     
        INY    
        BNE     L_WS_Loop          
        INC     ZP_STR_PTR_H      
        JMP     L_WS_Loop    
L_WS_Done:
        RTS      

UART1_Send_Data:        
        STA     S1BUF
L_Wait_TI0:
        ;clear_WDT
        LDA     S1CON
        AND     #02H            
        BEQ     L_Wait_TI0   
        LDA     #52H            
        STA     S1CON
        RTS

UART_Print_Num_Space:
        JSR     Print_12bit_Decimal
        LDA     #' '            
        JSR     UART1_Send_Data  
        RTS

UART_Print_Num_Newline:
        JSR     Print_12bit_Decimal
        LDA     #0DH            
        JSR     UART1_Send_Data
        LDA     #0AH            
        JSR     UART1_Send_Data
        RTS

PRINT_ACC:
        STA     ASCIICode
        JSR     Hex2String
        LDA     ASCH
        JSR     UART1_Send_Data
        LDA     ASCL                    
        JSR     UART1_Send_Data
        RTS

Hex2String:
        LDA     ASCIICode
        AND     #0FH
        TAX
        LDA     ASCII,X
        STA     ASCL
        LDA     ASCIICode
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        AND     #0FH
        TAX
        LDA     ASCII,X
        STA     ASCH
        RTS

Print_12bit_Decimal:
        LDA     #0
        STA     ZP_LZ_FLAG      
        LDX     #0              
L_Next_Digit:
        LDA     #0
        STA     ZP_DIGIT 
L_Sub_Loop:
        ;clear_WDT
        LDA     ZP_RES_L
        SEC
        SBC     Table_Pow10_L,X
        TAY                   
        LDA     ZP_RES_H
        SBC     Table_Pow10_H,X
        BCC     L_Sub_Underflow 
        STA     ZP_RES_H
        STY     ZP_RES_L
        INC     ZP_DIGIT
        JMP     L_Sub_Loop
L_Sub_Underflow:
        LDA     ZP_DIGIT
        BNE     L_Print_Digit  
        CPX     #3             
        BEQ     L_Print_Digit
        LDA     ZP_LZ_FLAG
        BEQ     L_Skip_Print    
L_Print_Digit:
        LDA     #1
        STA     ZP_LZ_FLAG     
        LDA     ZP_DIGIT
        ORA     #30H          
        JSR     UART1_Send_Data 
L_Skip_Print:
        INX                    
        CPX     #4             
        BNE     L_Next_Digit
        RTS

; ==============================================================================
; SPI 軟體共用模組
; ==============================================================================
initial_SPI:
        RTS

soft_SPI_delaytime:
        PHY
        LDY     #5          
SPI_Delay_Loop:
        DEY            
        BNE     SPI_Delay_Loop
        PLY
        RTS

WriteByte2SPI:
        STA     ZP_SPI_DATA 
        PHX
        LDX     #8         
L_SPI_Tx_Loop:
        ASL     ZP_SPI_DATA
        BCC     L_Set_MOSI_0
L_Set_MOSI_1:
        LDA     SPI_PORT
        ORA     #SPI_MOSI_PIN
        STA     SPI_PORT
        BRA     L_Clock_Tick
L_Set_MOSI_0:
        LDA     SPI_PORT
        AND     #0FBH           
        STA     SPI_PORT
L_Clock_Tick:
        JSR     soft_SPI_delaytime
        LDA     SPI_PORT
        AND     #0F7H           
        STA     SPI_PORT
        JSR     soft_SPI_delaytime
        LDA     SPI_PORT
        ORA     #SPI_CLK_PIN
        STA     SPI_PORT
        DEX            
        BNE     L_SPI_Tx_Loop 
        PLX
        RTS

; ==============================================================================
; DAC 控制模組
; ==============================================================================
INIT_DAC8562_CHIP:
        LDA     #38H
        LDX     #00H
        LDY     #00H
        JSR     SendCMD_DAC
        LDA     #C2H
        LDX     #FFH
        LDY     #FFH
        JSR     SendCMD_DAC
        LDA     #30H
        LDX     #FFH
        LDY     #FFH
        JSR     SendCMD_DAC
        RTS

SendCMD_DAC:
        STA     ZP_CMD1
        STX     ZP_CMD2
        STY     ZP_CMD3
        LDA     P3
        AND     #FEH
        STA     P3
        LDA     ZP_CMD1
        JSR     WriteByte2SPI
        LDA     ZP_CMD2
        JSR     WriteByte2SPI
        LDA     ZP_CMD3
        JSR     WriteByte2SPI
        LDA     P3
        ORA     #01H
        STA     P3
        RTS

SetDAC0_Vout:
        STA     ZP_CMD_L
        STX     ZP_CMD_H
        LDA     P3
        AND     #FEH
        STA     P3
        LDA     #18H
        JSR     WriteByte2SPI
        LDA     ZP_CMD_H
        JSR     WriteByte2SPI
        LDA     ZP_CMD_L
        JSR     WriteByte2SPI
        LDA     P3
        ORA     #01H
        STA     P3
        RTS

SetDAC1_Vout:
        STA     ZP_CMD_L
        STX     ZP_CMD_H
        LDA     P3
        AND     #FEH
        STA     P3
        LDA     #19H
        JSR     WriteByte2SPI
        LDA     ZP_CMD_H
        JSR     WriteByte2SPI
        LDA     ZP_CMD_L
        JSR     WriteByte2SPI
        LDA     P3
        ORA     #01H
        STA     P3
        RTS

DAC8562_CHIP_PowerDown:
        LDA     #20H
        LDX     #00H
        LDY     #33H
        JSR     SendCMD_DAC
        RTS

DAC8562_CHIP_PowerUp:
        LDA     #20H
        LDX     #00H
        LDY     #03H
        JSR     SendCMD_DAC
        RTS

; ==============================================================================
; Page API / Trim 控制區
; ==============================================================================
PageP_Read:
        RTS

PageP_Write:
        STX     ZP_PAGE_DAT
        TAX
        LDA     #5AH
        STA     PWPR
        LDA     ZP_PAGE_DAT
        STA     3100H,X
        RTS

Trim_ADC_offset:
        STA     ZP_I_L
        LDA     #ADC_AVSS
        JSR     ADC_Channel_Select
        LDA     #31
        STA     ZP_I_L   
L_Trim_Loop_I:
        LDA     OR0F
        AND     #07H
        TAX
        LDA     ZP_I_L
        ASL     A
        ASL     A
        ASL     A
        AND     #F8H
        STA     ZP_I_H
        TXA
        ORA     ZP_I_H
        TAX
        LDA     #<OR0F
        JSR     PageP_Write
        LDA     OR0F
        JSR     PRINT_ACC    
        LDA     #<30000
        STA     ZP_DACV_L
        LDA     #>30000
        STA     ZP_DACV_H
L_Trim_Delay1:
        ;clear_WDT
        LDA     ZP_DACV_L
        BNE     L_DecL1
        DEC     ZP_DACV_H
L_DecL1:
        DEC     ZP_DACV_L
        LDA     ZP_DACV_L
        ORA     ZP_DACV_H
        BNE     L_Trim_Delay1
        LDA     #0
        STA     ZP_RES_L
        STA     ZP_RES_H
        STA     ZP_K
L_Trim_Loop_K:
        JSR     ADC_StartConversion
L_Wait_ADC:
        ;clear_WDT
        JSR     ADC_GetConversionFlag
        CMP     #0          
        BEQ     L_Wait_ADC
        JSR     ADC_ClearFlag
        JSR     ADC_GetConversionData
        CLC
        ADC     ZP_RES_L
        STA     ZP_RES_L
        TXA
        ADC     ZP_RES_H
        STA     ZP_RES_H
        INC     ZP_K
        LDA     ZP_K
        CMP     #64
        BCC     L_Trim_Loop_K
        LDA     ZP_I_L
        JSR     PRINT_ACC        
        LDA     ZP_RES_H
        JSR     PRINT_ACC            
        LDA     ZP_RES_L
        JSR     PRINT_ACC        
        LDA     #0DH            
        JSR     UART1_Send_Data
        LDA     #0AH            
        JSR     UART1_Send_Data
        LDA     ZP_RES_H
        BNE     L_Check_Next_I      
        LDA     ZP_RES_L
        CMP     #32
        BCS     L_Check_Next_I      
        LDA     ZP_I_L
        BEQ     L_Check_Next_I    
        JMP     L_Trim_Loop_I_End
L_Check_Next_I:
        DEC     ZP_I_L
        LDA     ZP_I_L
        CMP     #0FFH              
        BEQ     L_SkipTrimJump    
        JMP     L_Trim_Loop_I
L_SkipTrimJump:
L_Trim_Loop_I_End:
        LDA     OR0F
        JSR     PRINT_ACC        
        LDA     #0DH            
        JSR     UART1_Send_Data
        LDA     #0AH            
        JSR     UART1_Send_Data
        LDA     #<30000
        STA     ZP_DACV_L
        LDA     #>30000
        STA     ZP_DACV_H
L_Trim_Delay2:
        ;clear_WDT
        LDA     ZP_DACV_L
        BNE     L_DecL2
        DEC     ZP_DACV_H
L_DecL2:
        DEC     ZP_DACV_L
        LDA     ZP_DACV_L
        ORA     ZP_DACV_H
        BNE     L_Trim_Delay2
        LDA     P1
        ORA     #01H
        STA     P1
        LDA     P1M0
        AND     #FCH
        STA     P1M0
        RTS

; ==============================================================================
; 共用延遲函數區 (Delays)
; ==============================================================================
Delay_65535:
        LDA     #0
        STA     ZP_RES_L
        STA     ZP_RES_H
L_Delay_Loop:
        ;clear_WDT
        DEC     ZP_RES_L
        BNE     L_Delay_Loop
        DEC     ZP_RES_H
        BNE     L_Delay_Loop
        RTS

Delay_30000_CMP:
        LDA     #<30000
        STA     ZP_DACV_L
        LDA     #>30000
        STA     ZP_DACV_H
L_D30K_Loop_CMP:
        ;clear_WDT
        LDA     ZP_DACV_L
        BNE     L_D30K_Dec_CMP
        DEC     ZP_DACV_H
L_D30K_Dec_CMP:
        DEC     ZP_DACV_L
        LDA     ZP_DACV_L
        ORA     ZP_DACV_H
        BNE     L_D30K_Loop_CMP
        RTS

; ==============================================================================
; 字串與查表區 (Strings & Tables)
; ==============================================================================
;ASCII:          .ASCII "0123456789ABCDEF"
ASCII:          .DB 30H, 31H, 32H, 33H, 34H, 35H, 36H, 37H, 38H, 39H, 41H, 42H, 43H, 44H, 45H, 46H
Table_Pow10_L:  .DB     <1000, <100, <10, <1
Table_Pow10_H:  .DB     >1000, >100, >10, >1

; --- 開機與通訊測試字串 ---
STR_BOOT:       .DB     "[Boot OK] DEVICE_ID = ", 0
STR_PACKET:     .DB     "[Packet OK]", 0DH, 0AH, 0

; --- Trim 與舊有測試遺留的字串 ---
STR_OR0F:       .DB     "OR0F:", 0
STR_OR0F_End:   .DB     "OR0F_End:", 0
STR_test:       .DB     "test point:", 0          
STR_AIN0_START: .DB     "Start Sampling External AIN0 Voltage...", 0AH, 0
STR_AIN0_VAL:   .DB     "ADC AIN0 = ", 0
STR_NTC_START:  .DB     "Start Sampling External NTC Voltage...", 0AH, 0
STR_NTC_VAL:    .DB     "ADC NTC = ", 0
STR_VREF_VAL:   .BYTE   "internal Vref = ", 0
STR_FUSE:       .DB     "fuse trigger", 0           ; <--- 新增這一行

