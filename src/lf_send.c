#include "stm8s.h"
#include "lf_Send.h"

unsigned char Set_Buff[SET_BUFF_MAX];     
unsigned int Bit_element;
unsigned int Carrier_Time;
unsigned int LF_Send_Tim;      

volatile unsigned char fac_us = 0;

void Delay_InIt(unsigned char clk)
{
    if(clk > 16) fac_us = (16 - 4)/4;
    else if(clk > 4) fac_us = (clk - 4)/4; 
    else fac_us = 1;
}

void Delay_us(unsigned int nus)
{
    unsigned int j;
    for (j = 0; j < nus; j++)
        __asm("nop");
}

/* ===== 125kHz Carrier：改成 TIM1_CH1N → PB0 ===== */
void LF_ClockOccurs(uint16_t lf_khz)
{
    uint32_t tim_clk_hz = 16000000UL;      // TIM1 clock (假設16MHz)
    uint32_t target_hz  = (uint32_t)lf_khz * 1000UL;
    uint16_t arr;
    uint16_t ccr;

    if (lf_khz == 0) return;               // 避免除以0

    // ARR = (Fclk / Fout) - 1
    arr = (uint16_t)((tim_clk_hz / target_hz) - 1UL);

    // 50% duty：CCR = (ARR+1)/2
    ccr = (uint16_t)((arr + 1U) / 2U);

    TIM1_DeInit();

    // Time base：Prescaler=0，Period=ARR
    TIM1_TimeBaseInit(
        0,                                 // Prescaler = 0
        TIM1_COUNTERMODE_UP,
        arr,
        0                                  // RepetitionCounter (一般用0)
    );

    // CH1 PWM：只要 N 輸出，所以 OutputState=DISABLE, OutputNState=ENABLE
    TIM1_OC1Init(
        TIM1_OCMODE_PWM1,
        TIM1_OUTPUTSTATE_DISABLE,           // CH1 不輸出
        TIM1_OUTPUTNSTATE_ENABLE,           // 只輸出 CH1N
        ccr,                                // Pulse
        TIM1_OCPOLARITY_HIGH,
        TIM1_OCNPOLARITY_HIGH,
        TIM1_OCIDLESTATE_RESET,
        TIM1_OCNIDLESTATE_RESET
    );

    TIM1_OC1PreloadConfig(ENABLE);          // 等同你原本 OC1PE
    TIM1_ARRPreloadConfig(ENABLE);          // 等同你原本 ARPE

    // Main Output Enable：等同你原本 BKR.MOE
    TIM1_CtrlPWMOutputs(ENABLE);

    // Counter = 0：等同你原本 CNTRH/CNTRL = 0
    TIM1_SetCounter(0);

    TIM1_Cmd(ENABLE);                       // 啟動計數器
}
/*
 * LF_Pll：你原本的寫法是 (16000 / LF_Pll) - 1
 * 代表 LF_Pll 單位通常是 kHz（例如 125 => 125kHz）
 *
 * 16MHz / 125kHz = 128 (counts)
 * ARR = 128 - 1 = 127
 * 50% duty => CCR = (ARR+1)/2 = 64
 */
void LF_PLL_SET(uint8_t LF_Pll)
{
    uint16_t arr;
    uint16_t ccr;

    if (LF_Pll == 0) return;                 // 避免除以 0

    // ARR = (F_CPU / F_out) - 1
    // 你原本用 16000 / LF_Pll - 1（16MHz / (LF_Pll*kHz) - 1）
    arr = (uint16_t)((16000UL / LF_Pll) - 1);

    // 50% duty：用 (ARR+1)/2 會比 ARR/2 更貼近真正 50%
    ccr = (uint16_t)((arr + 1) / 2);

    // 先停表，避免動態改 ARR/CCR 造成毛刺
    TIM1_Cmd(DISABLE);

    // Time base：PSC=0、ARR=arr、Up counter
    TIM1_TimeBaseInit(
        0,                          // Prescaler
        TIM1_COUNTERMODE_UP,        // Counter mode
        arr,                        // Period (ARR)
        0                           // RepetitionCounter
    );

    // CH1 PWM：High true、啟用輸出、CCR=ccr
    TIM1_OC1Init(
        TIM1_OCMODE_PWM1,
        TIM1_OUTPUTSTATE_ENABLE,
        TIM1_OUTPUTNSTATE_DISABLE,
        ccr,
        TIM1_OCPOLARITY_HIGH,
        TIM1_OCNPOLARITY_HIGH,
        TIM1_OCIDLESTATE_RESET,
        TIM1_OCNIDLESTATE_RESET
    );

    // 使能 preload（等效你在用 preload 的常見做法，更新更穩）
    TIM1_OC1PreloadConfig(ENABLE);
    TIM1_ARRPreloadConfig(ENABLE);

    // 高級計時器輸出需要 MOE（主輸出使能）
    TIM1_CtrlPWMOutputs(ENABLE);

    // 開始計時
    TIM1_Cmd(ENABLE);
}

void Out_125K(unsigned int tim, unsigned char LF_Send_CHx)
{      
    switch(LF_Send_CHx)
    {
        case LF_SEND_CH1:
            CH1_GPIO_OPEN;
            Delay_us(tim);
            break;
        case LF_SEND_CH2:
            CH2_GPIO_OPEN;
            Delay_us(tim);
            break;	
        case LF_SEND_CH3:
            CH3_GPIO_OPEN;
            Delay_us(tim);
            break;
        default:
            break;
    }
}

void Clock_125K(unsigned int tim, unsigned char LF_Send_CHx)
{      
    switch(LF_Send_CHx)
    {
        case LF_SEND_CH1:
            CH1_GPIO_CLOCK;
            Delay_us(tim);
            break;
        case LF_SEND_CH2:
            CH2_GPIO_CLOCK;
            Delay_us(tim);
            break;	
        case LF_SEND_CH3:
            CH3_GPIO_CLOCK;
            Delay_us(tim);
            break;
        default:
            break;
    }
}

void Timecalculate(void)
{
    unsigned char Tcarr;
    unsigned char Tclk;
    
    Tcarr = 1000 / LF_PLL;    
    Tclk  = 1000000 / (RC_PLL1 * 256 + RC_PLL2); 
    Tclk  = 256 - Tclk;       
    Tclk  = Tclk;             
    
    Bit_element = LFBIT_NxRC + Tclk * LFBIT_NxRC;   

    if(ONOFF_SCAN)      // 超碼模式
    {
        if((LF_PLL >= 15) && (LF_PLL <= 23))
        {
            Carrier_Time = 220 * Tclk + 8 * Tcarr;
            Carrier_Time =  Carrier_Time + 500;    //us
        }
        else if((LF_PLL > 23) && (LF_PLL <= 40))
        {         
            Carrier_Time = 224 * Tclk + 16 * Tcarr;
            Carrier_Time =  Carrier_Time + 500;    //us
        }
        else if((LF_PLL > 40) && (LF_PLL <= 65))
        {
            Carrier_Time = 180 * Tclk + 16 * Tcarr;
            Carrier_Time =  Carrier_Time + 500;    //us
        }	
        else if((LF_PLL > 65) && (LF_PLL <= 95))
        {
            Carrier_Time = 92 * Tclk + 16 * Tcarr;
            Carrier_Time =  Carrier_Time + 500;    //us
        }	
        else if((LF_PLL > 95) && (LF_PLL <= 150))
        {
            Carrier_Time = 80 * Tclk + 16 * Tcarr;
            Carrier_Time =  Carrier_Time + 500;    //us
        }
        else
            Carrier_Time =  3000;    //us	       
    }    
    else                // ON/OFF 模式
    {
        if((LF_PLL >= 15) && (LF_PLL <= 23))
        {
            Carrier_Time = 92 * Tclk + 8 * Tcarr;
            Carrier_Time =  Carrier_Time + 500;    //us
        }
        else if((LF_PLL > 23) && (LF_PLL <= 40))
        {         
            Carrier_Time = 96 * Tclk + 16 * Tcarr;
            Carrier_Time =  Carrier_Time + 500;    //us
        }
        else if((LF_PLL > 40) && (LF_PLL <= 65))
        {
            Carrier_Time = 52 * Tclk + 16 * Tcarr;
            Carrier_Time =  Carrier_Time + 500;    //us
        }	
        else if((LF_PLL > 65) && (LF_PLL <= 95))
        {
            Carrier_Time = 28 * Tclk + 16 * Tcarr;
            Carrier_Time =  Carrier_Time + 500;    //us
        }	
        else if((LF_PLL > 95) && (LF_PLL <= 150))
        {
            Carrier_Time = 16 * Tclk + 16 * Tcarr;
            Carrier_Time =  Carrier_Time + 1000;   //us
        }
        else
            Carrier_Time =  2000;    //us	
    }    
}

void CarrierBurst(unsigned char LF_Send_CHx)     
{      
    unsigned char i;
    CH1_GPIO_CLOCK;
    CH2_GPIO_CLOCK;
    CH3_GPIO_CLOCK;

    Timecalculate(); 
    Out_125K(Carrier_Time,LF_Send_CHx);
    Clock_125K(Bit_element,LF_Send_CHx);
    
    if(LFSENDMODE)    
    {  
        for(i = 0; i < 8; i++)    
        {
            Out_125K(Bit_element,LF_Send_CHx);
            Clock_125K(Bit_element,LF_Send_CHx);
        }
    }
}

void Pattern(unsigned char R6_Dat,
             unsigned char R5_Dat,
             unsigned char Patt16_32,
             unsigned char LF_Send_CHx)    
{
    unsigned char i;
    unsigned int Patt_Data = 0;
    unsigned int Temp_x    = 0;
    
    Patt_Data = (unsigned int)R6_Dat * 256 + R5_Dat;
    Temp_x = 0x8000;
    
    if(Patt16_32 == Patt_32bit)
    {
        for(i = 0; i < 16; i++)
        {
            if(Patt_Data & Temp_x) 		 
            {
                Out_125K(Bit_element,LF_Send_CHx);
                Clock_125K(Bit_element,LF_Send_CHx); 	
            }
            else
            {
                Clock_125K(Bit_element,LF_Send_CHx);
                Out_125K(Bit_element,LF_Send_CHx);
            }
            Patt_Data = (unsigned int)(Patt_Data << 1);		
        }
    }
    else
    {
        for(i = 0; i < 16; i++)    
        {
            if(Patt_Data & Temp_x)
            {
                Out_125K(Bit_element,LF_Send_CHx);
            }
            else
            {								
                Clock_125K(Bit_element,LF_Send_CHx);
            }
            Patt_Data = (unsigned int)(Patt_Data << 1);			
        }
    }
}

void LF_SendData(unsigned char R6_Dat,
                 unsigned char R5_Dat,
                 unsigned char Patt16_32,
                 unsigned char LF_Send_CHx)
{
    unsigned char i,j;
    unsigned char Data_Buff[20];    

    if((LFBIT_NxRC < 4) || (LFBIT_NxRC > 32))
        return;
	
    Data_Buff[0] = ACTIVE_NUM + 2;
    Data_Buff[1] = DEVICE_ID;
    Data_Buff[ACTIVE_NUM + 2] = 0;
    
    for(i = 0; i < ACTIVE_NUM; i++)
        Data_Buff[i+2] = Set_Buff[i+16];
    
    for(i = 0; i < ACTIVE_NUM; i++)
        Data_Buff[ACTIVE_NUM + 2] += Set_Buff[i+16];
    
    disableInterrupts();
    
    CarrierBurst(LF_Send_CHx);	
    Pattern(R6_Dat,R5_Dat,Patt16_32,LF_Send_CHx);
    
    for(i = 0; i < ACTIVE_NUM+3; i++)
    {
        for(j = 0; j < 8; j++)
        {
            if(Data_Buff[i] & 0x80)
            {
                Out_125K(Bit_element,LF_Send_CHx);
                Clock_125K(Bit_element,LF_Send_CHx);
            }
            else
            {								
                Clock_125K(Bit_element,LF_Send_CHx);	
                Out_125K(Bit_element,LF_Send_CHx);						
            }
            Data_Buff[i]= Data_Buff[i] << 1;
        }
    }
    enableInterrupts();        		
}
