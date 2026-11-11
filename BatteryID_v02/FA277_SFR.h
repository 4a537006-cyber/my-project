; ******************************************************************************
; *
; * @file        FA277_SFR.h (Merged with pgm_head_MSE01PC1A.h)
; *
; * @brief       This is the header file of the SFR address.
; *
; * @par         Project
; *              FA277
; * @version     v0.01
; * @date        2025/11/13
; * @copyright   Copyright (c) 2019 MegaWin Technology Co., Ltd.
; *              All rights reserved.
; *
; ******************************************************************************

    .CHIP       R65C02
    .LINKLIST
    .SYMBOLS
    .LIST       ON
    .debug      asm

bit0    .EQU    00000001B
bit1    .EQU    00000010B
bit2    .EQU    00000100B
bit3    .EQU    00001000B
bit4    .EQU    00010000B
bit5    .EQU    00100000B
bit6    .EQU    01000000B
bit7    .EQU    10000000B

;-------------------------------------------------------------
; Interrupt 
;-------------------------------------------------------------
IRQ0_EN            EQU 3001h     ;IRQ Enable 0
; (bits in IRQ0_EN)
EBOF0              .EQU    7
EX2                .EQU    6
EX1                .EQU    5
EX0                .EQU    4
ETF1               .EQU    3
ETF0               .EQU    2
ETI1               .EQU    1
ERI1               .EQU    0

IRQ0_STS           EQU 00E1h     ;IRQ Status 0
; (bits in IRQ0_STS)
BOF0               .EQU    7
IE2                .EQU    6
IE1                .EQU    5
IE0                .EQU    4
TF1                .EQU    3
TF0                .EQU    2
TI1i               .EQU    1
RI1i               .EQU    0

IRQ1_EN            EQU 3002h     ;IRQ Enable 1
; (bits in IRQ1_EN)
EAC1R              .EQU    7
EAC1F              .EQU    6
EAC0R              .EQU    5
EAC0F              .EQU    4
EADCI              .EQU    3
EMCDF              .EQU    2
ERTCF              .EQU    1
EWDTF              .EQU    0

IRQ1_STS           EQU 00E2h     ;IRQ Status 1
; (bits in IRQ1_STS)
AC1RF              .EQU    7
AC1FF              .EQU    6
AC0RF              .EQU    5
AC0FF              .EQU    4
ADCI               .EQU    3
MCDF               .EQU    2
RTCF               .EQU    1
WDTF               .EQU    0

IRQ2_EN            EQU 3003h     ;IRQ Enable 2
; (bits in IRQ2_EN)
ERFW               .EQU    3
ERFI               .EQU    0

IRQ2_STS           EQU 00E3h     ;IRQ Status 2
; (bits in IRQ2_STS)
RFACT              .EQU    7
RFCYC              .EQU    6
RFWKP              .EQU    3
RFACK              .EQU    2
UCAC               .EQU    1
RFINT              .EQU    0

;-------------------------------------------------------------
; Port1 
;-------------------------------------------------------------
P1_PIN             EQU 00E4h     ;Port 1 Pin (R)
; (bits in P1_PIN)
P13                .EQU    3
P12                .EQU    2
P11                .EQU    1
P10                .EQU    0

P1_DAT             EQU 00E4h     ;Port 1 output Data (W)
P1                 EQU 00E4h     ;Port 1 (Alias)

P1M0               EQU 3004h     ;Port 1 Mode Control 0
; (bits in P1M0)
P13M1              .EQU    7
P13M0              .EQU    6
P12M1              .EQU    5
P12M0              .EQU    4
P11M1              .EQU    3
P11M0              .EQU    2
P10M1              .EQU    1
P10M0              .EQU    0

;-------------------------------------------------------------
; Port 3 
;-------------------------------------------------------------
P3_PIN             EQU 00E5h     ;Port 3 Pin (R)
; (bits in P3_PIN)
P33                .EQU    3
P32                .EQU    2
P31                .EQU    1
P30                .EQU    0
 
P3_DAT             EQU 00E5h     ;Port 3 output Data (W)
P3                 EQU 00E5h     ;Port 3 (Alias)

P3M0               EQU 3005h     ;Port 3 Mode Control 0
; (bits in P3M0)
P33M1              .EQU    7
P33M0              .EQU    6
P32M1              .EQU    5
P32M0              .EQU    4
P31M1              .EQU    3
P31M0              .EQU    2
P30M1              .EQU    1
P30M0              .EQU    0

;-------------------------------------------------------------
; External Interrupt 
;-------------------------------------------------------------
EICR0              EQU 3006h     ;Exteranl INT Control 0
; (bits in EICR0)
INT2ET             .EQU    6
INT1ET             .EQU    5
INT0ET             .EQU    4
INT2H              .EQU    2
INT1H              .EQU    1
INT0H              .EQU    0

EICR1              EQU 3007h     ;External INT Control 1
; (bits in EICR1)
EI2ES1             .EQU    5
EI2ES0             .EQU    4
EI1ES1             .EQU    3
EI1ES0             .EQU    2
EI0ES1             .EQU    1
EI0ES0             .EQU    0

;-------------------------------------------------------------
; Timer 0 
;-------------------------------------------------------------
T0CNT              EQU 00E6h     ;Timer 0 Counter Reg. (R)
T0CTL              EQU 00E7h     ;Timer 0 Control Reg.
; (bits in T0CTL)
ENT0               .EQU    7
T0RL               .EQU    6
T0K2               .EQU    2
T0K1               .EQU    1
T0K0               .EQU    0

;-------------------------------------------------------------
; Timer 1 / PWM1 
;-------------------------------------------------------------
T1CNT              EQU 00E8h     ;Timer 1 Counter Reg. (R)
T1CTL              EQU 00E9h     ;Timer 1 Control Reg.
; (bits in T1CTL)
ENT1               .EQU    7
T1RL               .EQU    6
T1M1               .EQU    4
T1M0               .EQU    3
T1K2               .EQU    2
T1K1               .EQU    1
T1K0               .EQU    0

;-------------------------------------------------------------
; PWM Control 
;-------------------------------------------------------------
TCON               EQU 3008h     ;Timer Control
; (bits in TCON)
T1ORWE             .EQU    7
T1OR               .EQU    6
T0ORWE             .EQU    5
T0OR               .EQU    4
T1CKOE             .EQU    3
T0CKOE             .EQU    2
EPWM1              .EQU    1
EPWM0              .EQU    0

PWM0DA             EQU 3009h     ;PWM 0 Data

;-------------------------------------------------------------
; UART Interface 
;-------------------------------------------------------------
S1CON              EQU 3030h     ;Serial 1 Control
; (bits in S1CON)
SM01               .EQU    7
SM11               .EQU    6
SM21               .EQU    5
REN1               .EQU    4
TB81               .EQU    3
RB81               .EQU    2
TI1                .EQU    1
RI1                .EQU    0

S1BUF              EQU 3031h     ;Serial 1 Buffer
S1BRT              EQU 3032h     ;S1 Baud Rate Timer
S1BRC              EQU 3033h     ;S1 Baud Rate Counter
S1CFG              EQU 3034h     ;S1 Configuration
; (bits in S1CFG)
SM31               .EQU    7
S1MOD3             .EQU    6
S1DOR              .EQU    5
S1TR               .EQU    4
S1MOD1             .EQU    3
S1TX16             .EQU    2
S1CKOE             .EQU    1
S1TME              .EQU    0

;-------------------------------------------------------------
; ADC Module 
;-------------------------------------------------------------
ADCON              EQU 3020h     ;ADC Control
; (bits in ADCON)
ADCEN              .EQU    7
ADCS               .EQU    6
IVREN              .EQU    5
ADTM0              .EQU    4
CHS3               .EQU    3
CHS2               .EQU    2
CHS1               .EQU    1
CHS0               .EQU    0

ADCDL              EQU 3021h     ;ADC Data Low Byte
ADCDH              EQU 3022h     ;ADC Data High Byte

ADCFG0             EQU 3023h     ;ADC Configuration 0
; (bits in ADCFG0)
ADCKS2             .EQU    7
ADCKS1             .EQU    6
ADCKS0             .EQU    5
ADRJ               .EQU    4
ADHS               .EQU    3
IAOFF              .EQU    2
AAOFF              .EQU    1
AAHLT              .EQU    0

ADCFG1             EQU 3024h     ;ADC Configuration 1
; (bits in ADCFG1)
SHT7               .EQU    7
SHT6               .EQU    6
SHT5               .EQU    5
SHT4               .EQU    4
SHT3               .EQU    3
SHT2               .EQU    2
SHT1               .EQU    1
SHT0               .EQU    0

ADCFG2             EQU 3025h     ;ADC Configuration 2

;-------------------------------------------------------------
; AC0 Module 
;-------------------------------------------------------------
AC0CON             EQU 3028h     ;AC0 Control
; (bits in AC0CON)
AC0LP              .EQU    7
AC0PD              .EQU    6
AC0OUT             .EQU    5
AC0EN              .EQU    3

AC0CFG0            EQU 3029h     ;AC0 Configuration 0
; (bits in AC0CFG0)
AC0CS3             .EQU    7
AC0CS2             .EQU    6
AC0CS1             .EQU    5
AC0CS0             .EQU    4
AC0TD1             .EQU    3
AC0TD0             .EQU    2
SWE0               .EQU    1
ASE0               .EQU    0

AC0CFG1            EQU 302Ah     ;AC0 Configuration 1
; (bits in AC0CFG1)
R4HS3              .EQU    7
R4HS2              .EQU    6
R4HS1              .EQU    5
R4HS0              .EQU    4
R3HEN              .EQU    3
R2HEN              .EQU    2
AC0NIH             .EQU    1
AC0HE              .EQU    0

AC0CFG2            EQU 302Bh     ;AC0 Configuration 2
; (bits in AC0CFG2)
R4LS3              .EQU    7
R4LS2              .EQU    6
R4LS1              .EQU    5
R4LS0              .EQU    4
R3LEN              .EQU    3
R2LEN              .EQU    2
AC0NIL             .EQU    1
AC0LE              .EQU    0

;-------------------------------------------------------------
; AC1 Module 
;-------------------------------------------------------------
AC1CON             EQU 302Ch     ;AC1 Control
; (bits in AC1CON)
AC1LP              .EQU    7
AC1PD              .EQU    6
AC1OUT             .EQU    5
AC1EN              .EQU    3
RL1E               .EQU    1
CCEN               .EQU    0

AC1CFG0            EQU 302Dh     ;AC1 Configuration 0
; (bits in AC1CFG0)
AC1CS3             .EQU    7
AC1CS2             .EQU    6
AC1CS1             .EQU    5
AC1CS0             .EQU    4
AC1TD1             .EQU    3
AC1TD0             .EQU    2
ASE1               .EQU    0

AC1CFG1            EQU 302Eh     ;AC1 Configuration 1
; (bits in AC1CFG1)
R2S3               .EQU    7
R2S2               .EQU    6
R2S1               .EQU    5
R2S0               .EQU    4

;-------------------------------------------------------------
; Auxiliary Registers (AUXR)
;-------------------------------------------------------------
AUXR0              EQU 303Fh     ;Auxiliary Register 0
; (bits in AUXR0)
PSS11              .EQU    7
PSS10              .EQU    6
PSEI21             .EQU    5
PSEI20             .EQU    4
PSEI11             .EQU    3
PSEI10             .EQU    2
PSEI01             .EQU    1
PSEI00             .EQU    0

AUXR1              EQU 303Eh     ;Auxiliary Register 1
; (bits in AUXR1)
PSRO1              .EQU    7
PSRO0              .EQU    6
PSS1CO             .EQU    4
PSS1MI             .EQU    3
PST1               .EQU    2
PSPWM1             .EQU    1
PSPWM0             .EQU    0

AUXR2              EQU 303Dh     ;Auxiliary Register 2
; (bits in AUXR2)
BO1O               .EQU    1
BO0O               .EQU    0

;-------------------------------------------------------------
; Hardware Options (ORxx)
;-------------------------------------------------------------
OR00               EQU 3100h
; (bits in OR00)
NLOCK              .EQU    4
OSCS               .EQU    0

OR01               EQU 3101h
; (bits in OR01)
WDTWFWP            .EQU    7
NSWDT              .EQU    6
HWENW              .EQU    5
WRENO              .EQU    4
HWIDL              .EQU    3
HWPS2              .EQU    2
HWPS1              .EQU    1
HWPS0              .EQU    0

OR2                EQU 3102h            
OR3                EQU 3103h                          
OR4                EQU 3104h                         
OR5                EQU 3105h                
OR6                EQU 3106h           
OR7                EQU 3107h

;-------------------------------------------------------------
; NFC Buffer 
;-------------------------------------------------------------
RF_ID0             EQU 3040h     ;RF UID0
RF_ID1             EQU 3041h     ;RF UID1
RF_ID2             EQU 3042h     ;RF UID2
RF_ID3             EQU 3043h     ;RF UID3
RF_ID4             EQU 3044h     ;RF UID4
RF_ID5             EQU 3045h     ;RF UID5
RF_ID6             EQU 3046h     ;RF UID6
RF_INIT            EQU 3047h     ;RF Configuration

RF_CMD             EQU 3060h     ;RF Command
RF_Page            EQU 3061h     ;RF Page
RF_Parm            EQU 3062h     ;RF CMD Parameter
RF_STS             EQU 3063h     ;RF Status
RF_DA0             EQU 3064h     ;RF Data Byte 0
RF_DA1             EQU 3065h     ;RF Data Byte 1
RF_DA2             EQU 3066h     ;RF Data Byte 2
RF_DA3             EQU 3067h     ;RF Data Byte 3
RF_DA4             EQU 3068h     ;RF Data Byte 4
RF_DA5             EQU 3069h     ;RF Data Byte 5
RF_DA6             EQU 306Ah     ;RF Data Byte 6
RF_DA7             EQU 306Bh     ;RF Data Byte 7
RF_DA8             EQU 306Ch     ;RF Data Byte 8
RF_DA9             EQU 306Dh     ;RF Data Byte 9
RF_DA10            EQU 306Eh     ;RF Data Byte 10
RF_DA11            EQU 306Fh     ;RF Data Byte 11
RF_DA12            EQU 3070h     ;RF Data Byte 12
RF_DA13            EQU 3071h     ;RF Data Byte 13
RF_DA14            EQU 3072h     ;RF Data Byte 14
RF_DA15            EQU 3073h     ;RF Data Byte 15

;-------------------------------------------------------------
; GPL / CRC 
;-------------------------------------------------------------
BOREV              EQU 00EAh     ;Bit Order Reversed
CRC0DA             EQU 00EBh     ;CRC0 Data Register
CRC0CR             EQU 300Ch     ;CRC0 Control 0
; (bits in CRC0CR)
PAR                .EQU    7
CRCDS1             .EQU    1
CRCDS0             .EQU    0

;-------------------------------------------------------------
; MDU 
;-------------------------------------------------------------
MDU_A              EQU 3036h     ;MDU A Register
MDU_B              EQU 3037h     ;MDU B Register
MDUCR              EQU 3038h     ;MDU Control Register
; (bits in MDUCR)
MDUM0              .EQU    2
MDUST              .EQU    1
MDUS               .EQU    0

;-------------------------------------------------------------
; AES128 
;-------------------------------------------------------------
AES_CR0            EQU 00EFh     ;AES Control 0
; (bits in AES_CR0)
AES_RST            .EQU    7
AES_M1             .EQU    3
AES_M0             .EQU    2
ENCPT              .EQU    1
AES_STR            .EQU    0

AES_DA0            EQU 00F0h     ;AES Data Byte 0
AES_DA1            EQU 00F1h     ;AES Data Byte 1
AES_DA2            EQU 00F2h     ;AES Data Byte 2
AES_DA3            EQU 00F3h     ;AES Data Byte 3
AES_DA4            EQU 00F4h     ;AES Data Byte 4
AES_DA5            EQU 00F5h     ;AES Data Byte 5
AES_DA6            EQU 00F6h     ;AES Data Byte 6
AES_DA7            EQU 00F7h     ;AES Data Byte 7
AES_DA8            EQU 00F8h     ;AES Data Byte 8
AES_DA9            EQU 00F9h     ;AES Data Byte 9
AES_DA10           EQU 00FAh     ;AES Data Byte 10
AES_DA11           EQU 00FBh     ;AES Data Byte 11
AES_DA12           EQU 00FCh     ;AES Data Byte 12
AES_DA13           EQU 00FDh     ;AES Data Byte 13
AES_DA14           EQU 00FEh     ;AES Data Byte 14
AES_DA15           EQU 00FFh     ;AES Data Byte 15

;-------------------------------------------------------------
; In Application Programming (IAP) 
;-------------------------------------------------------------
IAP_PR             EQU 300Ah     ;IAP Write Protect Key (W)
; (bits in IAP_PR)
IPR7               .EQU    7
IPR6               .EQU    6
IPR5               .EQU    5
IPR4               .EQU    4
IPR3               .EQU    3
IPR2               .EQU    2
IPR1               .EQU    1
IPR0               .EQU    0

IFMT               EQU 300Bh     ;IAP Command
; (bits in IFMT)
IAPEN              .EQU    7
IMS1               .EQU    1
IMS0               .EQU    0

;-------------------------------------------------------------
; Protect Write Key 
;-------------------------------------------------------------
PWPR               EQU 300Fh     ;Proteck Write Pattern (W)
; (bits in PWPR)
PR7                .EQU    7
PR6                .EQU    6
PR5                .EQU    5
PR4                .EQU    4
PR3                .EQU    3
PR2                .EQU    2
PR1                .EQU    1
PR0                .EQU    0

;-------------------------------------------------------------
; Power & Clock 
;-------------------------------------------------------------
PWR_CTL            EQU 3010h     ;Power Control
; (bits in PWR_CTL)
SCKS2              .EQU    7
SCKS1              .EQU    6
SCKS0              .EQU    5
HSE                .EQU    4
OSCS1              .EQU    3
OSCS0              .EQU    2
STOP               .EQU    1
HALT               .EQU    0

CK_CTL             EQU 3011h     ;Clock Control
; (bits in CK_CTL)
ILDS               .EQU    7
NFCE               .EQU    6
MCDX               .EQU    3
MCDE               .EQU    2
XTEN               .EQU    1
IHEN               .EQU    0

MCK_CTL            EQU 3012h     ;Module Clock Control
; (bits in MCK_CTL)
AESCE              .EQU    7
GPLCE              .EQU    6
AC1CE              .EQU    5
AC0CE              .EQU    4
ADCKE              .EQU    3
URCE               .EQU    2
TM1CE              .EQU    1
TM0CE              .EQU    0

CKS_STS            EQU 3013h     ;Clock Switch Status (R)
; (bits in CKS_STS)
XTOR               .EQU    7
CKST3              .EQU    3
CKST2              .EQU    2
CKST1              .EQU    1
CKST0              .EQU    0

PWR_CR1            EQU 301Eh     ;Power Control 1
; (bits in PWR_CR1)
BO1