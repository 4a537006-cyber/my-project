		.CHIP      R65C02
		.LINKLIST
		.SYMBOLS
		.LIST ON
		.debug     asm


;--------------------------
bit0	.EQU	1B
bit1	.EQU	10B
bit2	.EQU	100B
bit3	.EQU	1000B
bit4	.EQU	10000B
bit5	.EQU	100000B
bit6	.EQU	1000000B
bit7	.EQU	10000000B
;--------------------------
;=========================================================================

;=========================================================================
; INTERRUPT CONTROL
;=========================================================================
; --- IRQ 0 ($3001 / $00E1) ---
IRQ0_EN     EQU $3001   ; IRQ Enable 0
EBOF0       EQU $80     
EX2         EQU $40     
EX1         EQU $20     
EX0         EQU $10     
ETF1PWMX    EQU $08     
ETF0        EQU $04     
ETI1        EQU $02     
ERI1        EQU $01     

IRQ0_STS    EQU $00E1   ; IRQ Status 0
BOF0        EQU $80     
IE2         EQU $40     
IE1         EQU $20     
IE0         EQU $10     
TF1         EQU $08     
TF0         EQU $04     
TI1I        EQU $02     
RI1I        EQU $01     

; --- IRQ 1 ($3002 / $00E2) ---
IRQ1_EN     EQU $3002   ; IRQ Enable 1
EAC1REBO1R  EQU $80     
EAC1FEBO1F  EQU $40     
EAC0R       EQU $20     
EAC0F       EQU $10     
EADCI       EQU $08     
EMCDF       EQU $04     
ERTCF       EQU $02     
EWDTF       EQU $01     

IRQ1_STS    EQU $00E2   ; IRQ Status 1
AC1RFBO1RF  EQU $80     
AC1FFBO1FF  EQU $40     
AC0RF       EQU $20     
AC0FF       EQU $10     
ADCI        EQU $08     
MCDF        EQU $04     
RTCF        EQU $02     
WDTF        EQU $01     

; --- IRQ 2 ($3003 / $00E3) ---
IRQ2_EN     EQU $3003   ; IRQ Enable 2
ERFW        EQU $08     
ERFI        EQU $01     

IRQ2_STS    EQU $00E3   ; IRQ Status 2
RFACT       EQU $80     
RFCYC       EQU $40     
RFWKP       EQU $08     
RFACK       EQU $04     
UCAC        EQU $02     
RFINT       EQU $01     

;=========================================================================
; I/O PORTS
;=========================================================================
; --- Port 1 ---
P1_PIN      EQU $00E4   ; Port 1 Input
P1_DAT      EQU $00E4   ; Port 1 Output
P1					EQU $00E4   ; Port 1 Output
P1M0        EQU $3004   ; Port 1 Mode Control
P13M1       EQU $80     
P13M0       EQU $40     
P12M1       EQU $20     
P12M0       EQU $10     
P11M1       EQU $08     
P11M0       EQU $04     
P10M1       EQU $02     
P10M0       EQU $01     

; --- Port 3 ---
P3_PIN      EQU $00E5   ; Port 3 Input
P3_DAT      EQU $00E5   ; Port 3 Output
P3					EQU $00E5   ; Port 3 Output 
P3M0        EQU $3005   ; Port 3 Mode Control
P33M1       EQU $80     
P33M0       EQU $40     
P32M1       EQU $20     
P32M0       EQU $10     
P31M1       EQU $08     
P31M0       EQU $04     
P30M1       EQU $02     
P30M0       EQU $01     

;=========================================================================
; EXTERNAL INTERRUPT CONTROL
;=========================================================================
EICR0       EQU $3006   ; External INT Control 0
INT2ET      EQU $40     
INT1ET      EQU $20     
INT0ET      EQU $10     
INT2H       EQU $04     
INT1H       EQU $02     
INT0H       EQU $01     

EICR1       EQU $3007   ; External INT Control 1
EI2ES1      EQU $20     
EI2ES0      EQU $10     
EI1ES1      EQU $08     
EI1ES0      EQU $04     
EI0ES1      EQU $02     
EI0ES0      EQU $01     

;=========================================================================
; TIMERS & PWM
;=========================================================================
; --- Timer 0 ---
T0CNT       EQU $00E6   ; Timer 0 Counter


T0CTL       EQU $00E7   ; Timer 0 Control
ENT0        EQU $80     
T0RL        EQU $40      (Renamed to avoid conflict with Reg T0RL)
T0K2        EQU $04     
T0K1        EQU $02     
T0K0        EQU $01     

; --- Timer 1 ---
T1CNT       EQU $00E8   ; Timer 1 Counter
T1RL        EQU $00E8   ; Timer 1 Reload (Register)

T1CTL       EQU $00E9   ; Timer 1 Control
ENT1        EQU $80     
T1RL_CTL    EQU $40      (Renamed to avoid conflict with Reg T1RL)
T1M1        EQU $10     
T1M0        EQU $08     
T1K2        EQU $04     
T1K1        EQU $02     
T1K0        EQU $01     

; --- PWM Control ---
TCON        EQU $3008   ; Timer/PWM Control
T1ORWE      EQU $80     
T1OR        EQU $40     
T0ORWE      EQU $20     
T0OR        EQU $10     
T1CKOE      EQU $08     
T0CKOE      EQU $04     
EPWM1       EQU $02     
EPWM0       EQU $01     

PWM0DA      EQU $3009   ; PWM 0 Data

;=========================================================================
; UART INTERFACE (Serial 1)
;=========================================================================
S1CON       EQU $3030   ; Serial 1 Control
SM01        EQU $80     
SM11        EQU $40     
SM21        EQU $20     
REN1        EQU $10     
TB81        EQU $08     
RB81        EQU $04     
TI1         EQU $02     
RI1         EQU $01     

S1BUF       EQU $3031   ; Serial 1 Buffer
S1BRT       EQU $3032   ; Baud Rate Timer
S1BRC       EQU $3033   ; Baud Rate Counter

S1CFG       EQU $3034   ; Serial 1 Configuration
SM31        EQU $80     
S1MOD3      EQU $40     
S1DOR       EQU $20     
S1TR        EQU $10     
S1MOD1      EQU $08     
S1TX16      EQU $04     
S1CKOE      EQU $02     
S1TME       EQU $01     

;=========================================================================
; ADC MODULE
;=========================================================================
ADCON       EQU $3020   ; ADC Control
ADCEN       EQU $80     
ADCS        EQU $40     
IVREN       EQU $20     
ADTM0       EQU $10     
CHS3        EQU $08     
CHS2        EQU $04     
CHS1        EQU $02     
CHS0        EQU $01     

ADCDL       EQU $3021   ; ADC Data Low
ADCDH0       EQU $3022   ; ADC Data High

ADCFG0      EQU $3023   ; ADC Config 0
ADCKS2      EQU $80     
ADCKS1      EQU $40     
ADCKS0      EQU $20     
ADRJ        EQU $10     
ADHS        EQU $08     
IAOFF       EQU $04     
AAOFF       EQU $02     
AAHLT       EQU $01     

ADCFG1      EQU $3024   ; ADC Config 1
ADPS1       EQU $80     
ADPS0       EQU $40     


ADCFG2      EQU $3025   ; ADC Config 2


;=========================================================================
; ANALOG COMPARATOR (AC0)
;=========================================================================
; --- AC0 Module (Address $302C) ---
AC0CON      EQU $302C   ; AC0 Control
AC0LP       EQU $80     
AC1PD       EQU $40     
AC1OUT      EQU $20     
AC1F        EQU $10     
AC0EN       EQU $08     
AC1INV      EQU $04     
AC0M1       EQU $02     
AC0M0       EQU $01     

AC0CFG0     EQU $302D   ; AC0 Config 0
AC0CS3      EQU $80     
AC0CS2      EQU $40     
AC0CS1      EQU $20     
AC0CS0      EQU $10     
AC0TD1      EQU $08     
AC0TD0      EQU $04     
SWE1        EQU $02     
ASE1        EQU $01     

AC0CFG1     EQU $302E   ; AC0 Config 1
R2S3        EQU $80     
R2S2        EQU $40     
R2S1        EQU $20     
R2S0        EQU $10     

; --- BOD1 Dynamic Control (Address $3028) ---
;AC0CON  EQU $3028   ; BOD AC0 Control
;AC0LP   EQU $80     
;AC0PD   EQU $40     
;AC0OUT  EQU $20     
;AC0F    EQU $10     
;AC0EN   EQU $08     
;AC0INV  EQU $04     
;AC0M1   EQU $02     
;AC0M0   EQU $01     
;
;AC0CFG0 EQU $3029   ; BOD AC0 Config 0
;AC0CS3  EQU $80     
;AC0CS2  EQU $40     
;AC0CS1  EQU $20     
;AC0CS0  EQU $10     
;AC0TD1  EQU $08     
;AC0TD0  EQU $04     
;SWE0        EQU $02     
;ASE0        EQU $01     
;
;AC0CFG1 EQU $302A   ; BOD AC0 Config 1
;R4HS3       EQU $80     
;R4HS2       EQU $40     
;R4HS1       EQU $20     
;R4HS0       EQU $10     
;R3HEN       EQU $08     
;R2HEN       EQU $04     
;AC0NIH      EQU $02     
;AC0HE       EQU $01     
;
;AC0CFG2 EQU $302B   ; BOD AC0 Config 2
;R4LS3       EQU $80     
;R4LS2       EQU $40     
;R4LS1       EQU $20     
;R4LS0       EQU $10     
;R3LEN       EQU $08     
;R2LEN       EQU $04     
;AC0NIL      EQU $02     
;AC0LE       EQU $01     

;=========================================================================
; NFC / RF BUFFER
;=========================================================================
RF_ID0      EQU $3040   ; RF UID0
RF_ID1      EQU $3041   ; RF UID1
RF_ID2      EQU $3042   ; RF UID2
RF_ID3      EQU $3043   ; RF UID3
RF_ID4      EQU $3044   ; RF UID4
RF_ID5      EQU $3045   ; RF UID5
RF_ID6      EQU $3046   ; RF UID6
RF_INIT     EQU $3047   ; RF Configuration

RF_CMD      EQU $3060   ; RF Command
RF_Page     EQU $3061   ; RF Page
RF_Parm     EQU $3062   ; RF Parameter
RF_STS      EQU $3063   ; RF Status
RF_DA0      EQU $3064   ; RF Data 0
RF_DA1      EQU $3065   ; RF Data 1
RF_DA2      EQU $3066   ; RF Data 2
RF_DA3      EQU $3067   ; RF Data 3
RF_DA4      EQU $3068   ; RF Data 4
RF_DA5      EQU $3069   ; RF Data 5
RF_DA6      EQU $306A   ; RF Data 6
RF_DA7      EQU $306B   ; RF Data 7
RF_DA8      EQU $306C   ; RF Data 8
RF_DA9      EQU $306D   ; RF Data 9
RF_DA10     EQU $306E   ; RF Data 10
RF_DA11     EQU $306F   ; RF Data 11
RF_DA12     EQU $3070   ; RF Data 12
RF_DA13     EQU $3071   ; RF Data 13
RF_DA14     EQU $3072   ; RF Data 14
RF_DA15     EQU $3073   ; RF Data 15

;=========================================================================
; GPL / CRC
;=========================================================================
BOREV       EQU $00EA   ; Bit Order Reversed
CRC0DA      EQU $00EB   ; CRC0 Data
CRC0CR      EQU $300C   ; CRC0 Control
PAR         EQU $80     
CRCDS1      EQU $02     
CRCDS0      EQU $01     

;=========================================================================
; MATH ACCELERATION (MDU)
;=========================================================================
MDU_A       EQU $3036   ; MDU A Register
MDU_B       EQU $3037   ; MDU B Register
MDUCR       EQU $3038   ; MDU Control
MDUM0       EQU $04     
MDUST       EQU $02     
MDUS        EQU $01     

;=========================================================================
; AES128 CRYPTO
;=========================================================================
AES_CR0     EQU $00EF   ; AES Control 0
AES_RST     EQU $80     
KIN_RDY     EQU $40     
AES_M1      EQU $08     
AES_M0      EQU $04     
ENCPT       EQU $02     
AES_STR     EQU $01     

AES_DA0     EQU $00F0   
AES_DA1     EQU $00F1
AES_DA2     EQU $00F2
AES_DA3     EQU $00F3
AES_DA4     EQU $00F4
AES_DA5     EQU $00F5
AES_DA6     EQU $00F6
AES_DA7     EQU $00F7
AES_DA8     EQU $00F8
AES_DA9     EQU $00F9
AES_DA10    EQU $00FA
AES_DA11    EQU $00FB
AES_DA12    EQU $00FC
AES_DA13    EQU $00FD
AES_DA14    EQU $00FE
AES_DA15    EQU $00FF 


;=========================================================================
; AUXILIARY REGISTERS
;=========================================================================
AUXR0       EQU $303F
PSS11       EQU $80     
PSS10       EQU $40     
PSEI21      EQU $20     
PSEI20      EQU $10     
PSEI11      EQU $08     
PSEI10      EQU $04     
PSEI01      EQU $02     
PSEI00      EQU $01     

AUXR1       EQU $303E
PSRO1       EQU $80     
PSRO0       EQU $40     
PSS1CO      EQU $10     
PSS1MI      EQU $08     
PST1        EQU $04     
PSPWM1      EQU $02     
PSPWM0      EQU $01     

AUXR2       EQU $303D
BO1O        EQU $02     
BO0O        EQU $01     

;=========================================================================
; IAP / PROTECT
;=========================================================================
IAP_PR      EQU $300A   ; IAP Write Protect Key


IFMT        EQU $300B   ; IAP Command
IAPEN       EQU $80     
IMS1        EQU $02     
IMS0        EQU $01     

PWPR        EQU $300F   ; Protect Write Pattern


;=========================================================================
; POWER & CLOCK CONTROL
;=========================================================================
PWR_CTL     EQU $3010   ; Power Control
SCKS2       EQU $80     
SCKS1       EQU $40     
SCKS0       EQU $20     
HSEPSM0     EQU $10     
OSCS1       EQU $08     
OSCS0       EQU $04     
STOP        EQU $02     
HALT        EQU $01     

CK_CTL      EQU $3011   ; Clock Control
GFILDS      EQU $80     
NFCE        EQU $40     
LSCKS       EQU $20     
XTGS        EQU $10     
MCDX        EQU $08     
MCDE        EQU $04     
XTEN        EQU $02     
IHEN        EQU $01     

MCK_CTL     EQU $3012   ; Module Clock Control
AESCE       EQU $80     
GPLCE       EQU $40     
AC1CE       EQU $20     
AC0CE       EQU $10     
ADCKE       EQU $08     
URCE        EQU $04     
TM1CE       EQU $02     
TM0CE       EQU $01     

CKS_STS     EQU $3013   ; Clock Switch Status
XTOR        EQU $80     
LS_CK       EQU $40     
CKST3       EQU $08     
CKST2       EQU $04     
CKST1       EQU $02     
CKST0       EQU $01     

PWR_CR1     EQU $301E   ; Power Control 1
BO1S2       EQU $80     
BO1S1       EQU $40     
BO1S0       EQU $20     
AWBOD1      EQU $08     
AWBOD0      EQU $04     
EBOD1       EQU $02     
EBOD0       EQU $01     

PWR_CR2     EQU $301F   ; Power Control 2
LVRDS       EQU $80     
BODLVW      EQU $40     
ILDS        EQU $20     
FLDO        EQU $02     
LDOL        EQU $01     

;=========================================================================
; RESET CONTROL
;=========================================================================
RST_CTL     EQU $3014   ; Reset Control
SWR         EQU $80     
UIDWE       EQU $40     
RFPG        EQU $20     
RFPORN      EQU $10     
NVREN       EQU $01     

RST_SRF0    EQU $3015   ; Reset Source Flag 0
POF         EQU $80     
EXRF        EQU $40     
SWRF        EQU $20     
WRF         EQU $10     
IARF        EQU $08     

RST_SRF1    EQU $3016   ; Reset Source Flag 1
PNDF        EQU $80     
PORF0       EQU $40     
DBLVR       EQU $20     
LVRF0       EQU $10     
DPORF       EQU $08     
PORF        EQU $01     


;=========================================================================
; WATCH DOG TIMER (WDT)
;=========================================================================
WDT_CR0     EQU $3018   ; WDT Control 0
WREN        EQU $80     
NSW         EQU $40     
WTCS1       EQU $20     
WTCS0       EQU $10     
WIDL        EQU $08     
WPS2        EQU $04     
WPS1        EQU $02     
WPS0        EQU $01     

WDT_CR1     EQU $3019   ; WDT Control 1
CLRW        EQU $80     
ENW         EQU $40     
WDTFS       EQU $10     

;=========================================================================
; REAL TIME CLOCK (RTC)
;=========================================================================
RTC_CR      EQU $301A   ; RTC Control
RTCE        EQU $80     
RTCO        EQU $40     
RTCRL5      EQU $20     
RTCRL4      EQU $10     
RTCRL3      EQU $08     
RTCRL2      EQU $04     
RTCRL1      EQU $02     
RTCRL0      EQU $01     

RTC_TM      EQU $301B   ; RTC Timer
RPSC1       EQU $80     
RPSC0       EQU $40     
RTCCT5      EQU $20     
RTCCT4      EQU $10     
RTCCT3      EQU $08     
RTCCT2      EQU $04     
RTCCT1      EQU $02     
RTCCT0      EQU $01     

RTC_CS      EQU $301C   ; RTC Clock Select
RCSS2       EQU $80     
RCSS1       EQU $40     
RCSS0       EQU $20     
RPSC2       EQU $10     
RTCCS3      EQU $08     
RTCCS2      EQU $04     
RTCCS1      EQU $02     
RTCCS0      EQU $01     

RTC_CR1     EQU $301D   ; RTC Control 1
CKOR_ST     EQU $80     
CKORM       EQU $40     

;=========================================================================
; HARDWARE OPTIONS (ORxx)
;=========================================================================
OR00        EQU $3100
NLOCK       EQU $10     
OSCS        EQU $01     

OR01        EQU $3101
WDTWFWP     EQU $80
NSWDT       EQU $40
HWENW       EQU $20
WRENO       EQU $10
HWIDL       EQU $08
HWPS2       EQU $04
HWPS1       EQU $02
HWPS0       EQU $01

OR2         EQU $3102            
OR3         EQU $3103                          
OR4         EQU $3104                         
OR5         EQU $3105                
OR6         EQU $3106           
OR7         EQU $3107                                         

;--------------------------------------------------------------------------------

;=====================================================
;	MACRO DEFINITION
;=====================================================
;--- Watch-Dog Timer Clear ---
clear_WDT	.MACRO              
	LDA	#5Ah                    
	STA	PWPR                    
	LDA	WDT_CR1
	ORA	#80H
	STA WDT_CR1      
	.ENDM                       

;--- system initial command ---
system_init .macro
	SEI		;disable IRQ interrupt
	.endm

set_stack_pointer_to .macro stack_start
	LDX	#.low.stack_start
	TXS
	.endm

clear_RAM_from_00_to .macro clear_RAM_end
	LDX	#00h
  ?clear_RAM:
	STZ	00h,x
	CPX	#clear_RAM_end
	BEQ	?clear_RAM_done
	INX
	BRA	?clear_RAM
  ?clear_RAM_done:
	.endm


