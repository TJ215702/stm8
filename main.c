/* MAIN.C file – STM8S105K4T6 Keyless (103F3 → 105K4T6 移植版)
 *
 * I/O 對應：
 *   Learn Key       = PA2（高 = 按下）
 *   Mode Key        = PB4（高 = 按下）
 *   Lfsend Key      = PB5（高 = 按下）
 *   RF DO           = PD0（Active Low）
 *   RF SHDN         = PD2（Low = Enable）
 *   Learn LED       = PB2（高亮）
 *   Mode LED        = PB1（高亮）
 *   Lfsend LED      = PD3（高亮）
 *   Out LED         = PB3（高亮）
 *   125K carrier    = PB0 (TIM1_CH1N)  → 在 LF_Send.c 裡用 TIM1 產生
 *   125K_EN gate    = PE5（高 = 啟動）
 */

#include "stm8s.h"
#include "stm8s_conf.h"
#include "LF_Send.h"

/* ================= GPIO 宏定義 ================= */

/* Buzzer：如果 105 沒接，可以先留空或之後再改 */
#define BP_ON()              (GPIOD->ODR |=  (1<<4))
#define BP_OFF()             (GPIOD->ODR &= ~(1<<4))

/* Learn LED = PB2，高亮 */
#define Learn_LED_ON()       (GPIOB->ODR |=  (1<<2))
#define Learn_LED_OFF()      (GPIOB->ODR &= ~(1<<2))

/* Mode LED = PB1，高亮 */
#define Mode_LED_ON()        (GPIOB->ODR |=  (1<<1))
#define Mode_LED_OFF()       (GPIOB->ODR &= ~(1<<1))

/* Lfsend LED = PD3，高亮 */
#define Lfsend_LED_ON()      (GPIOD->ODR |=  (1<<3))
#define Lfsend_LED_OFF()     (GPIOD->ODR &= ~(1<<3))

/* Out LED = PB3，高亮 */
#define Out_LED_ON()         (GPIOB->ODR |=  (1<<3))
#define Out_LED_OFF()        (GPIOB->ODR &= ~(1<<3))

/* 按鍵：高 = 按下 */
#define Learn_Key_Pressed()  (GPIO_ReadInputPin(GPIOA, GPIO_PIN_2) != RESET)
#define Mode_Key_Pressed()   (GPIO_ReadInputPin(GPIOB, GPIO_PIN_4) != RESET)
#define Lfsend_Key_Pressed() (GPIO_ReadInputPin(GPIOB, GPIO_PIN_5) != RESET)

/* RF DO：Active Low（改成 PD0） */
#define RF_DATA_LOW()        (GPIO_ReadInputPin(GPIOD, GPIO_PIN_0) == RESET)

/* RF SHDN：PD2，Low = Enable */
#define RF_SHDN_ENABLE()     GPIO_WriteLow (GPIOD, GPIO_PIN_2)
#define RF_SHDN_DISABLE()    GPIO_WriteHigh(GPIOD, GPIO_PIN_2)

/* 125K EN：PE5，高啟動（ASK gate） */
#define LF_EN_ON()           GPIO_WriteHigh(GPIOE, GPIO_PIN_5)
#define LF_EN_OFF()          GPIO_WriteLow (GPIOE, GPIO_PIN_5)

/* ================= 常數 & 全域變數 ================= */

#define  TRUE        1
#define  FALSE       0
#define  TOUT        600           /* Out LED 維持時間 (10ms 為單位) */

#define RF_NUM       5
#define RF_Byte_LEN  3
#define RF_LEN       24

#define MCU_REG_NUM      26
#define RF_ACTIVE_LOW    1         /* idle 高、資料為低脈波 */

unsigned char RFFull = 0;
unsigned char RFBit;
unsigned char LL_w = 0;
unsigned char First_flag = 0;
unsigned char Buff_B[3];
unsigned char BitCount;

unsigned char FLearn = 0;		
unsigned int  COut   = 0;                
unsigned int  CLearn = 0;               
unsigned int  CTLearn = 0;
unsigned char LF_Send_flag = 0;		
unsigned char Mode_Key_Old = 0;         
unsigned char Send_Key_Old = 0;       
unsigned char MLearn = 0;		
unsigned char CSend = 0;                

unsigned char Time_1ms = 0;
unsigned char Time_Nms = 0;

unsigned char User_LF_Send = 0;

/* 前置宣告 */
void Key_Scan(void);
void RF_Remote(void);

/* ================= CRC Table & 預設參數 ================= */

const unsigned int wCRCTalbeAbs[] =
{
    0x0000, 0xCC01, 0xD801, 0x1400,
    0xF001, 0x3C00, 0x2800, 0xE401,
    0xA001, 0x6C00, 0x7800, 0xB401,
    0x5000, 0x9C01, 0x8801, 0x4400,
};

const uint8_t mcu_user_config[MCU_REG_NUM] =
{
    0xA5,0x5A,0x01,0x7D,0x80,0x00,0x00,0x01,
    0xC3,0x3A,0x0C,0x01,0x00,0x15,0x00,0x01,
    0x01,0x81,0x32,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,
};

/* ================= 函式實作 ================= */

unsigned int GetCRC16(unsigned char *pchMsg, unsigned char wDataLen)
{ 
    unsigned int wCRC = 0xFFFF;
    unsigned int i;
    unsigned char chChar;  
    
    for (i = 0; i < wDataLen; i++)
    {
        chChar = *pchMsg++;
        wCRC = wCRCTalbeAbs[(chChar ^ wCRC) & 15] ^ (wCRC >> 4);
        wCRC = wCRCTalbeAbs[((chChar >> 4) ^ wCRC) & 15] ^ (wCRC >> 4);
    }
    return wCRC;    
} 

void SystemClock_Init(void)
{
    CLK_HSICmd(ENABLE);
    while (CLK_GetFlagStatus(CLK_FLAG_HSIRDY) == RESET);
    CLK_HSIPrescalerConfig(CLK_PRESCALER_HSIDIV1);

    /* 建議把 TIM1/TIM2 clock 打開（保險） */
    CLK_PeripheralClockConfig(CLK_PERIPHERAL_TIMER1, ENABLE);
    CLK_PeripheralClockConfig(CLK_PERIPHERAL_TIMER2, ENABLE);
}

void TIM2_Init(void)
{
    TIM2_DeInit();
    TIM2_TimeBaseInit(TIM2_PRESCALER_16,100);   /* 0.1ms */
    TIM2_ITConfig(TIM2_IT_UPDATE , ENABLE);
    TIM2_SetCounter(0x0000);
    TIM2_Cmd(ENABLE);
}

void Read_EEpeomData(void)
{
    unsigned int x;
    unsigned char EEprom_Buff[SET_BUFF_MAX];

    FLASH_Unlock(FLASH_MEMTYPE_DATA);
    for (x = 0; x < SET_BUFF_MAX; x++)
        EEprom_Buff[x] = FLASH_ReadByte(0x00004000 + x);
    FLASH_Lock(FLASH_MEMTYPE_DATA);

    if ((EEprom_Buff[0] == 0xA5) && (EEprom_Buff[1] == 0x5A)) 
    {
        for (x = 0; x < SET_BUFF_MAX; x++)
            Set_Buff[x] = EEprom_Buff[x];
        LF_PLL_SET(LF_PLL);
    }

    if (LF_ENABLE != 1)
        Mode_LED_ON();
    else
        Mode_LED_OFF();
}  

void Write_EEpeomData(void)
{
    unsigned char i;

    FLASH_Unlock(FLASH_MEMTYPE_DATA);

    for (i = 0; i < MCU_REG_NUM; i++)
        FLASH_ProgramByte(0x00004000 + i, mcu_user_config[i]);

    FLASH_Lock(FLASH_MEMTYPE_DATA);
}

void BEEP_BEEP(void)
{
    unsigned char i;

    for (i = 0; i < 100; i++)
    {
        BP_ON();
        Delay_us(150);
        BP_OFF();
        Delay_us(150);
    }
}

/* ================= 初始化 ================= */

void InIt(void)
{
    SystemClock_Init();
    
    /* LED & Out */
    GPIO_Init(GPIOB, GPIO_PIN_1, GPIO_MODE_OUT_PP_LOW_FAST);  /* Mode LED  */
    GPIO_Init(GPIOB, GPIO_PIN_2, GPIO_MODE_OUT_PP_LOW_FAST);  /* Learn LED */
    GPIO_Init(GPIOB, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);  /* Out LED   */
    GPIO_Init(GPIOD, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);  /* Lfsend LED*/

    /* Buzzer：PD4 */
    GPIO_Init(GPIOD, GPIO_PIN_4, GPIO_MODE_OUT_PP_LOW_FAST);

    /* LF：PB0 / PE5 */
    GPIO_Init(GPIOB, GPIO_PIN_0, GPIO_MODE_OUT_PP_LOW_FAST);  /* 125K PWM (TIM1_CH1N) */
    GPIO_Init(GPIOE, GPIO_PIN_5, GPIO_MODE_OUT_PP_LOW_FAST);  /* 125K_EN gate */

    /* RF：DO + SHDN */
    GPIO_Init(GPIOD, GPIO_PIN_0, GPIO_MODE_IN_PU_NO_IT);      /* RF DO */
    GPIO_Init(GPIOD, GPIO_PIN_2, GPIO_MODE_OUT_PP_HIGH_FAST); /* SHDN，預設關閉 */

    /* Keys：高有效 */
    GPIO_Init(GPIOA, GPIO_PIN_2, GPIO_MODE_IN_PU_NO_IT);      /* Learn Key */
    GPIO_Init(GPIOB, GPIO_PIN_4, GPIO_MODE_IN_PU_NO_IT);      /* Mode Key  */
    GPIO_Init(GPIOB, GPIO_PIN_5, GPIO_MODE_IN_PU_NO_IT);      /* Lfsend Key*/

    Delay_InIt(16);
    TIM2_Init();
    LF_ClockOccurs(125);                                      /* 125k carrier */

    /* 啟動 RF 接收器 */
    RF_SHDN_ENABLE();

    Write_EEpeomData();
    Read_EEpeomData();

    BEEP_BEEP();
    enableInterrupts();
}

/* ================= RF_Remote（照你 103 版移植） ================= */

void RF_Remote(void)                  
{
    unsigned char i,j;
    unsigned char HF_Key = 0;
    unsigned char Buffer[RF_Byte_LEN];  
    unsigned char RF_UartSend[RF_Byte_LEN + 8];
    unsigned char RF_num;
    unsigned int  crc;
       
    for (i = 0; i < RF_Byte_LEN; i++)
        Buffer[i] = Buff_B[i];
                    
    HF_Key = Buffer[RF_Byte_LEN - 1] & 0x0F;
    Buffer[RF_Byte_LEN - 1] &= 0xF0;

    for (i = 0; i < RF_Byte_LEN + 1; i++)
        RF_UartSend[i + 2] = Buffer[i];    
        
    RF_UartSend[0] = 0;
    RF_UartSend[1] = 0;
    RF_UartSend[2] = 0xFA; 
    RF_UartSend[3] = 0xDD;
    for (i = 0; i < RF_Byte_LEN; i++)
        RF_UartSend[4 + i] = Buffer[i];   
    RF_UartSend[RF_Byte_LEN + 4] = HF_Key;
    
    crc = GetCRC16(&RF_UartSend[2], RF_Byte_LEN + 3);   
    RF_UartSend[RF_Byte_LEN + 5] = (uint8_t)(crc >> 8);
    RF_UartSend[RF_Byte_LEN + 6] = (uint8_t)(crc & 0xFF);   
    RF_UartSend[RF_Byte_LEN + 7] = 0xEE;	
  
    RFFull = 0;                                
		
    if (FLearn) 		                              
    {    
        BP_ON();
        Delay_us(450);
        BP_OFF();

        disableInterrupts();                          
        FLASH_Unlock(FLASH_MEMTYPE_DATA);

        for (i = 0; i < RF_NUM; i++)
        {
            for (j = 0; j < RF_Byte_LEN; j++)
            {
                if (Buffer[j] != FLASH_ReadByte(0x00004000  + SET_BUFF_MAX + i * RF_Byte_LEN + j + 1))
                    break;
            }
            if (j == RF_Byte_LEN)
            {
                CTLearn = 1000;
                FLASH_Lock(FLASH_MEMTYPE_DATA);
                enableInterrupts();
                return;
            }
        }
        
        RF_num = FLASH_ReadByte(0x00004000 + SET_BUFF_MAX);
        if (RF_num > RF_NUM) RF_num = 0;        
        
        for (i = 0; i < RF_Byte_LEN; i++)
            FLASH_ProgramByte(0x00004000 + SET_BUFF_MAX + RF_num * RF_Byte_LEN + i + 1,Buffer[i]);

        RF_num = RF_num + 1;
        FLASH_ProgramByte(0x00004000 + SET_BUFF_MAX , RF_num);
     
        FLASH_Lock(FLASH_MEMTYPE_DATA);  
        
        Learn_LED_OFF();
        FLearn = 0;
        enableInterrupts();
    } 
    else
    {
        disableInterrupts();
          
        for (i = 0; i < RF_NUM; i++)
        {
            for (j = 0; j < RF_Byte_LEN; j++)
            {
                if (Buffer[j] != FLASH_ReadByte(0x00004000  + SET_BUFF_MAX + i * RF_Byte_LEN + j + 1))
                    break; 			
            }
            if (j == RF_Byte_LEN)
            {
                if (COut == 0)
                {
                    if ((HF_Key & 0x01) == 0x01)  Out_LED_ON();
                    if ((HF_Key & 0x02) == 0x02)  Out_LED_ON();
                    if ((HF_Key & 0x04) == 0x04)  Out_LED_ON();
                    if ((HF_Key & 0x08) == 0x08)  Out_LED_ON();
                    BEEP_BEEP();
                }                 
                COut = TOUT;
                enableInterrupts();
                break;                   
            }
        }
        enableInterrupts();
    }
}

/* ================= Key_Scan（改成高有效版本） ================= */

void Key_Scan(void)           
{
    unsigned char i;

    /* Learn Key：短按進 Learn，長按清 EEPROM */
    if (Learn_Key_Pressed()) 
    {
        CLearn++;
        if (CLearn == 10)
        {
            Learn_LED_ON();
            FLearn  = 1;
            CTLearn = 1000;
        }

        if (CLearn == 500)
        {
            Learn_LED_OFF();
            FLearn = 0;

            FLASH_Unlock(FLASH_MEMTYPE_DATA);
            for (i = 0; i < RF_NUM * RF_Byte_LEN + 1; i++)
                FLASH_ProgramByte(0x00004000 + SET_BUFF_MAX + i, 0);
            FLASH_Lock(FLASH_MEMTYPE_DATA);

            CLearn = 0;
            while (Learn_Key_Pressed());
        }
    }
    else
    {
        CLearn = 0;
    }
    
    if (CTLearn > 0)
    {
        CTLearn--;
        if (CTLearn == 0)
        {
            Learn_LED_OFF();
            FLearn = 0;
        }
    }  
    
    /* Mode Key：短按切換 LF_ENABLE */
    if (Mode_Key_Pressed())
    {
        if (!Mode_Key_Old)
        {
            Mode_Key_Old = 1;

            if (LF_ENABLE == 0)
            {
                LF_ENABLE = 1;
                Mode_LED_OFF();
            }
            else
            {
                LF_ENABLE = 0;
                Mode_LED_ON();
            }

            FLASH_Unlock(FLASH_MEMTYPE_DATA);
            FLASH_ProgramByte(0x00004000 + 12, LF_ENABLE);
            FLASH_Lock(FLASH_MEMTYPE_DATA);
        }
    }
    else
    {
        Mode_Key_Old = 0;
    }
    
    /* Lfsend Key：LF_ENABLE=0 時按一下送一次 LF */
    if (Lfsend_Key_Pressed())
    {
        if (!Send_Key_Old)
        {
            Send_Key_Old = 1;
            if (LF_ENABLE == 0)
                User_LF_Send = 1;
        }
    }
    else
    {
        Send_Key_Old = 0;
    }
}

/* ================= TIM2 Update ISR ================= */

@far @interrupt void pc_irqhandler(void)
{
    TIM2_ClearITPendingBit(TIM2_IT_UPDATE);
    Time_1ms++;

    if (Time_1ms >= 10)
    {
        Time_1ms = 0;
        Time_Nms++;

        if ((LF_ENABLE == 1) && (LF_Send_Tim > 0))
            LF_Send_Tim--; 
        else
            LF_Send_Tim = 0;
    }

    if (RFFull)
        return; 

    if (RF_DATA_LOW())
    {           /* Low 區間累積 */
        LL_w++;
        RFBit = 0;
    }
    else
    {           /* High 邊緣：處理剛過去的 Low 寬度 */
        if (!RFBit)
        {
            if (!First_flag)
            {
                if ((LL_w > 40) && (LL_w < 60))
                {
                    First_flag = 1;
                    BitCount   = 0;
                    Buff_B[0] = Buff_B[1] = Buff_B[2] = 0;
                }
            }
            else
            {
                if ((LL_w > 3) && (LL_w <= 7))
                {
                    if (BitCount < RF_LEN)
                    {
                        Buff_B[BitCount>>3] <<= 1;
                        Buff_B[BitCount>>3] |= 0x01;
                        BitCount++;
                    }
                }
                else if ((LL_w >= 8) && (LL_w < 13))
                {
                    if (BitCount < RF_LEN)
                    {
                        Buff_B[BitCount>>3] <<= 1;
                        BitCount++;
                    }
                }
                else
                {
                    First_flag = 0;
                    BitCount   = 0;
                }

                if (BitCount >= RF_LEN)
                {
                    BitCount   = 0;
                    First_flag = 0;
                    RFFull     = 1;
                }
            }
            LL_w = 0;
        }
        RFBit = 1;
    }  
}

/* ================= main ================= */

void main(void)
{
    InIt();

    while (1)
    {      
        if (RFFull)
            RF_Remote();     
        
        if (Time_Nms >= 10)           
        {
            Time_Nms = 0;
            Key_Scan();	

            if (COut > 0)
            {
                COut--;
                if (COut == 0)
                    Out_LED_OFF();
            }

            if (LF_ENABLE == 1)
                Mode_LED_OFF();
        }

        if ((LF_ENABLE == 1) && (LF_Send_Tim == 0)) 
        {
            Lfsend_LED_ON();
            LF_SendData(PATTERN1,PATTERN2,PATTREN_BIT,LF_SEND_CH1);
            LF_Send_Tim = (INTERVAL1 >> 4) * 1000
                        + (INTERVAL1 & 0x0F) * 100
                        + (INTERVAL2 >> 4) * 10
                        + (INTERVAL2 & 0x0F);
            Lfsend_LED_OFF();
        }
        else if (User_LF_Send)
        {
            User_LF_Send = 0;
            Lfsend_LED_ON();
            LF_SendData(PATTERN1,PATTERN2,PATTREN_BIT,LF_SEND_CH1);
            Lfsend_LED_OFF();          
        }
    } 
}
