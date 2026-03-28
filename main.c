/* MAIN.C file
 * 
 * Copyright (c) 2002-2005 STMicroelectronics
 */
#include "stm8s.h"
#include "stm8s_conf.h"
#include "uart.h"
#include "rc522.h"
#include "lf_send.h"


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

#define RF_NUM       5
#define RF_Byte_LEN  3
#define RF_LEN       24


void Key_Scan(void);
void RF_Remote(void);

enum pke_oper_state {
    PKE_OPER_STA_POWER_OFF,
    PKE_OPER_STA_POWER_ON,
    PKE_OPER_STA_WAIT,
    PKE_OPER_STA_IDLE,
    PKE_OPER_STA_LEARN,
    PKE_OPER_STA_BUSY,
    PKE_OPER_STA_ERROR
};

volatile struct PKE_config {
    uint8_t key_num;
    uint8_t rc522_num;
    volatile uint8_t oper_state;
    volatile uint8_t power_event_flag;
    volatile uint8_t learn_event_flag;
} TJTW_PKE;

#define BR_LIGHT_ON()      GPIO_WriteHigh(GPIOD, GPIO_PIN_3)
#define BR_LIGHT_OFF()     GPIO_WriteLow(GPIOD, GPIO_PIN_3)

#define BZ_ON()      GPIO_WriteHigh(GPIOB, GPIO_PIN_1)
#define BZ_OFF()     GPIO_WriteLow(GPIOB, GPIO_PIN_1)

#define LP_RIGHT_ON()      GPIO_WriteHigh(GPIOB, GPIO_PIN_3)
#define LP_RIGHT_OFF()     GPIO_WriteLow(GPIOB, GPIO_PIN_3)

#define MOTOR2_ON()     GPIO_WriteHigh(GPIOC, GPIO_PIN_2)
#define MOTOR2_OFF()    GPIO_WriteLow(GPIOC, GPIO_PIN_2)

#define MOTOR1_ON()     GPIO_WriteHigh(GPIOB, GPIO_PIN_0)
#define MOTOR1_OFF()    GPIO_WriteLow(GPIOB, GPIO_PIN_0)

#define MOTOR_FWD()  do{MOTOR1_ON(); MOTOR2_OFF();}while(0)
#define MOTOR_REV()  do{MOTOR1_OFF(); MOTOR2_ON();}while(0)
#define MOTOR_STOP() do{MOTOR1_OFF(); MOTOR2_OFF();}while(0)

#define RF_DATA_LOW()        (GPIO_ReadInputPin(GPIOD, GPIO_PIN_0) == RESET)   //RESET=0

#define RC522KEY_COUNT_ADDR   0x00004100
#define RC522KEY_START_ADDR   0x00004110
#define RC522KEY_SIZE         4
#define MAX_RC522KEY_NUM      5

//for ign to count down by 10s
#define IGN_TIMEOUT_MS      10000UL
#define IGN_IS_ON()         (GPIO_ReadInputPin(GPIOB, GPIO_PIN_5) != RESET)  //SET=1
#define IGN_detect()         GPIO_ReadInputPin(GPIOB, GPIO_PIN_5)

#define MCU_REG_NUM      26
const uint8_t mcu_user_config[MCU_REG_NUM] =
{
    0xA5,0x5A,0x01,0x7D,0x80,0x00,0x00,0x01,
    0xC3,0x3A,0x0C,0x01,0x00,0x15,0x00,0x01,
    0x01,0x81,0x32,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,
};

const unsigned int wCRCTalbeAbs[] =
{
    0x0000, 0xCC01, 0xD801, 0x1400,
    0xF001, 0x3C00, 0x2800, 0xE401,
    0xA001, 0x6C00, 0x7800, 0xB401,
    0x5000, 0x9C01, 0x8801, 0x4400,
};

u8 Tx_Buffer[] = "RFID---test";
#define  BufferSize (countof(Tx_Buffer)-1)


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

void Clock_Config(void)
{
	
	//enable internal HSI clock(16MHZ)
	CLK_HSICmd(ENABLE);

	//make sure internal clock(HSI) is stable
	while (CLK_GetFlagStatus(CLK_FLAG_HSIRDY) == RESET);

	//set HSI DIV(High speed internal clock prescaler: 1)
	CLK_HSIPrescalerConfig(CLK_PRESCALER_HSIDIV1);
	CLK_PeripheralClockConfig(CLK_PERIPHERAL_SPI,   ENABLE);
    CLK_PeripheralClockConfig(CLK_PERIPHERAL_TIMER2, ENABLE);

}

void Clear_PKE_EEPROM(void)
{
    uint8_t i;

    FLASH_Unlock(FLASH_MEMTYPE_DATA);

    for (i = 0; i < 16; i++)
    {
        FLASH_ProgramByte(0x00004000 + i, 0x00);
    }

    FLASH_ProgramByte(0x00004100, 0x00);

    for (i = 0; i < 16; i++)
    {
        FLASH_ProgramByte(0x00004110 + i, 0x00);
    }

    FLASH_Lock(FLASH_MEMTYPE_DATA);
}

u8 Rebuild_KeyCount(void)
{
    u8 i, real_count = 0;
    uint16_t addr;

    for (i = 0; i < MAX_RC522KEY_NUM; i++)
    {
        addr = RC522KEY_START_ADDR + (i * RC522KEY_SIZE);
        FLASH_Unlock(FLASH_MEMTYPE_DATA);
        if (FLASH_ReadByte(addr) != 0x00 ||
            FLASH_ReadByte(addr+1) != 0x00 ||
            FLASH_ReadByte(addr+2) != 0x00 ||
            FLASH_ReadByte(addr+3) != 0x00)
        {
            real_count++;
        }
        FLASH_Lock(FLASH_MEMTYPE_DATA);
    }

    return real_count;
}

void Write_EEpeomData(unsigned char *rc522)
{
    unsigned char i;
    u8 num, match;
    uint16_t write_addr;
    uint16_t read_addr;

    FLASH_Unlock(FLASH_MEMTYPE_DATA);
    num = FLASH_ReadByte(RC522KEY_COUNT_ADDR);
    if (num >= MAX_RC522KEY_NUM)
    {
        num = Rebuild_KeyCount();
        FLASH_ProgramByte(RC522KEY_COUNT_ADDR, num);
        FLASH_Lock(FLASH_MEMTYPE_DATA);
        return;
    }
    match=0;
    for (i = 0; i < num; i++)
    {
        read_addr = RC522KEY_START_ADDR + (i * RC522KEY_SIZE);
        if ((FLASH_ReadByte(read_addr) == rc522[0]) &&
            (FLASH_ReadByte(read_addr + 1) == rc522[1]) &&
            (FLASH_ReadByte(read_addr + 2) == rc522[2]) &&
            (FLASH_ReadByte(read_addr + 3) == rc522[3]))
        {
            match = 1;
            FLASH_Lock(FLASH_MEMTYPE_DATA);
            return;
        }
    }

    write_addr = RC522KEY_START_ADDR + (num * RC522KEY_SIZE);

    for (i = 0; i < RC522KEY_SIZE; i++)
        FLASH_ProgramByte(write_addr  + i, rc522[i]);


    num++;
    FLASH_ProgramByte(RC522KEY_COUNT_ADDR, num);
    FLASH_Lock(FLASH_MEMTYPE_DATA);
}


u8 Check_RC522Key(unsigned char *rc522)
{
    u8 i,j;
    uint16_t read_addr;
    u8 num, match;

    FLASH_Unlock(FLASH_MEMTYPE_DATA);

    num = FLASH_ReadByte(RC522KEY_COUNT_ADDR);

    if (num > MAX_RC522KEY_NUM)
        num = Rebuild_KeyCount();

    for (i = 0; i < num; i++)
    {
        match=1;
        read_addr = RC522KEY_START_ADDR + (i * RC522KEY_SIZE);
        for(j=0;j<RC522KEY_SIZE;j++)
        {
            if(FLASH_ReadByte(read_addr + j) != rc522[j])
            {
                match=0;
                break;
            }
        }
        if(match == 1)
        {
            FLASH_Lock(FLASH_MEMTYPE_DATA);
            return 1;   // found
        }

    }

    FLASH_Lock(FLASH_MEMTYPE_DATA);
    return 0;   // not found
}
/* 20ms pulse */
static void Motor_Pulse_Fwd_20ms(void)
{
    MOTOR_FWD();
    Delay_ms(20);
    MOTOR_STOP();
}

static void Motor_Pulse_Rev_20ms(void)
{
    MOTOR_REV();
    Delay_ms(20);
    MOTOR_STOP();
}

void Read_EEpeomData_125(void)
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

}

void Write_EEpeomData_125(void)
{
    unsigned char i;

    FLASH_Unlock(FLASH_MEMTYPE_DATA);

    for (i = 0; i < MCU_REG_NUM; i++)
        FLASH_ProgramByte(0x00004000 + i, mcu_user_config[i]);

    FLASH_Lock(FLASH_MEMTYPE_DATA);
}


static void GPIO_Config(void)
{

    GPIO_Init(GPIOD, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST); /* D3 BR_LIGHT */
    GPIO_Init(GPIOB, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST); /* B3 LP_RIGHT */
    GPIO_Init(GPIOC, GPIO_PIN_2, GPIO_MODE_OUT_PP_LOW_FAST); /* Motor IN2 */
    GPIO_Init(GPIOB, GPIO_PIN_0, GPIO_MODE_OUT_PP_LOW_FAST); /* Motor IN1 */
    GPIO_Init(GPIOB, GPIO_PIN_1, GPIO_MODE_OUT_PP_LOW_FAST); /* BZ */

    GPIO_Init(GPIOB, GPIO_PIN_4, GPIO_MODE_IN_PU_IT);  //POWER KEY
    GPIO_Init(GPIOA, GPIO_PIN_2, GPIO_MODE_IN_FL_NO_IT); //LEARN KEY
    GPIO_Init(GPIOB, GPIO_PIN_5, GPIO_MODE_IN_FL_NO_IT); //IGN KEY

    GPIO_Init(GPIOD, GPIO_PIN_2, GPIO_MODE_OUT_PP_HIGH_FAST); //syn531 default disable
    GPIO_Init(GPIOD, GPIO_PIN_0, GPIO_MODE_IN_PU_NO_IT);    //RF DO
    GPIO_Init(GPIOE, GPIO_PIN_5, GPIO_MODE_OUT_PP_LOW_FAST);  //125k enable

    /* init gpio status */
    BR_LIGHT_OFF();
    LP_RIGHT_OFF();
    MOTOR_STOP();
    BZ_OFF();
    GPIO_WriteLow (GPIOD, GPIO_PIN_2);  //syn531 enable
}

/* ================= EXTI ================= */

static void EXTI_Config(void)
{
    /* PORTB rising edge */
    EXTI_SetExtIntSensitivity(EXTI_PORT_GPIOB,
                              EXTI_SENSITIVITY_RISE_ONLY);
}

/* ================= ISR ================= */

INTERRUPT_HANDLER(EXTI_PORTB_IRQHandler, 4)
{
    TJTW_PKE.power_event_flag = 1;
}

void TIM2_Init(void)
{
    TIM2_DeInit();
    TIM2_TimeBaseInit(TIM2_PRESCALER_16,100);   /* 0.1ms */
    TIM2_ITConfig(TIM2_IT_UPDATE , ENABLE);
    TIM2_SetCounter(0x0000);
    TIM2_Cmd(ENABLE);
}


void RF_Remote(void)
{
    unsigned char i,j;
    unsigned char HF_Key = 0;
    unsigned char Buffer[RF_Byte_LEN];
    unsigned char RF_UartSend[RF_Byte_LEN + 8];
    unsigned char RF_num;
    unsigned int  crc;
    unsigned char string_buffer[12];
    const char hex_chars[] = "0123456789ABCDEF";
    char hex_out[4];

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

    UART2_SendString("\r\nRF Data: ", 11);
    for (i = 0; i < 11; i++) {
            uint8_t val = RF_UartSend[i];

            hex_out[0] = hex_chars[(val >> 4) & 0x0F];

            hex_out[1] = hex_chars[val & 0x0F];

            hex_out[2] = ' ';

            UART2_SendString((unsigned char*)hex_out, 3);
        }
        UART2_SendString("\r\n", 2); // ??

}


@far @interrupt void tim2_irqhandler(void)
{
    /* Clear TIM2 update interrupt flag */
    TIM2_ClearITPendingBit(TIM2_IT_UPDATE);

    /* -------------------------------------------------------------
     * Time base: 1 ms tick and 10 ms tick
     * ------------------------------------------------------------- */
    Time_1ms++;

    if (Time_1ms >= 10)
    {
        Time_1ms = 0;
        Time_Nms++;

        /* LF send timer countdown (clamp to 0) */
        if ((LF_ENABLE == 1) && (LF_Send_Tim > 0))
            LF_Send_Tim--;
        else
            LF_Send_Tim = 0;
    }

    /* If an RF frame is already captured, skip decoding */
    if (RFFull)
        return;

    /* -------------------------------------------------------------
     * RF OOK decoding:
     * - Measure LOW pulse width (LL_w) while RF_DATA is low
     * - On rising edge (LOW -> HIGH), interpret the LOW width
     * ------------------------------------------------------------- */
    if (RF_DATA_LOW())
    {
        /* Accumulate LOW width in ticks */
        LL_w++;
        RFBit = 0;   /* Mark current level as LOW */
    }
    else
    {
        /* Rising edge: process the LOW width that just ended */
        if (!RFBit)
        {
            if (!First_flag)
            {
                /* Detect sync/preamble LOW width */
                if ((LL_w > 40) && (LL_w < 60))
                {
                    First_flag = 1;
                    BitCount   = 0;
                    Buff_B[0] = Buff_B[1] = Buff_B[2] = 0;
                }
            }
            else
            {
                /* Decode data bits by LOW width */
                if ((LL_w > 3) && (LL_w <= 7))
                {
                    /* Bit '1' */
                    if (BitCount < RF_LEN)
                    {
                        Buff_B[BitCount >> 3] <<= 1;
                        Buff_B[BitCount >> 3] |= 0x01;
                        BitCount++;
                    }
                }
                else if ((LL_w >= 8) && (LL_w < 13))
                {
                    /* Bit '0' */
                    if (BitCount < RF_LEN)
                    {
                        Buff_B[BitCount >> 3] <<= 1;
                        BitCount++;
                    }
                }
                else
                {
                    /* Invalid width: reset decoder state */
                    First_flag = 0;
                    BitCount   = 0;
                }

                /* Frame complete */
                if (BitCount >= RF_LEN)
                {
                    BitCount   = 0;
                    First_flag = 0;
                    RFFull     = 1;
                }
            }

            /* Reset LOW width counter after processing */
            LL_w = 0;
        }

        RFBit = 1;   /* Mark current level as HIGH */
    }
}

main()
{
    int i,ret,idle;
    uint8_t ign_wait = 0;
		
    u8 set=0;
    uint16_t brightness = 0; // bright pwm (0 到 999)
    uint8_t up = 1;
    unsigned char rc522_SN[4];
    TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
    TJTW_PKE.power_event_flag = 0;
    TJTW_PKE.learn_event_flag = 0;
    idle=0;
		
    Clock_Config();
    GPIO_Config();
    EXTI_Config();
    TIM4_DeInit();
    TIM4_Init();
	//MX_TIM4_Init();
    Uart_Init();
    InitRc522();
    Delay_ms(100);
    TIM2_PWM_Config();
    //Clear_PKE_EEPROM();

    LF_ClockOccurs(125);
    Write_EEpeomData_125();
    Read_EEpeomData_125();

    //Delay_InIt(16);
    //TIM2_Init();   //need ro mask  TIM2_PWM_Config()

    enableInterrupts();
		
    UART2_SendStr("system start!");
		
    while(1)
    {
        //if (RFFull)
        //    RF_Remote();
       
        switch(TJTW_PKE.oper_state) {
            case PKE_OPER_STA_POWER_OFF:
                UART2_SendStr("PKE_OPER_STA_POWER_OFF in!");
                enableInterrupts();
                MOTOR_STOP();
                Delay_ms(50);
                halt();
                Delay_ms(50);
                Clock_Config();
                TIM4_Init();
                Uart_Init();
                InitRc522();
                Delay_ms(50);

                if(TJTW_PKE.power_event_flag) {
                    TJTW_PKE.power_event_flag = 0;
                    if(GPIO_ReadInputPin(GPIOA, GPIO_PIN_2))
                    {
                        TJTW_PKE.oper_state = PKE_OPER_STA_LEARN;
                    }
                    else
                    {
                        TJTW_PKE.oper_state = PKE_OPER_STA_POWER_ON;
                    }
                }
                Uart_Init();
                UART2_SendStr("PKE_OPER_STA_POWER_OFF out!");
                break;
            case PKE_OPER_STA_POWER_ON:
                UART2_SendStr("PKE_OPER_STA_POWER_ON in!");
                //check 433 key
                //check 13.56m key
                //if(key is right) {
                //    TJTW_PKE.oper_state = PKE_OPER_STA_IDLE;
                //} else {
                //    TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                //}
                ret=0;
                for(i=0;i<50;i++) {
                    Delay_ms(100);

                    showcard(Tx_Buffer,&set,rc522_SN);
                    Reset_RC522();
                    if(set ==1) {
                        UART2_SendString(Tx_Buffer, 17);
                        set=0;
                        i=50;
                        ret=Check_RC522Key(rc522_SN);
                    }
                }
                if(ret == 1) {
                        Motor_Pulse_Fwd_20ms();
                        TJTW_PKE.oper_state = PKE_OPER_STA_WAIT;
                } else {
                        TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                }
                UART2_SendStr("PKE_OPER_STA_POWER_ON out!");
                break;
            case PKE_OPER_STA_WAIT:
                UART2_SendStr("PKE_OPER_STA_WAIT in!");
                if(IGN_IS_ON()) {  //ign on
                    TJTW_PKE.oper_state = PKE_OPER_STA_IDLE;
                    UART2_SendStr("IGN_ON PKE_OPER_STA_WAIT out!");
                }
                else {
                    if(ign_wait >=10) {
                        TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                        ign_wait=0;
			Motor_Pulse_Rev_20ms();
                        UART2_SendStr("PKE_OPER_STA_WAIT out!");
                    }
                    else {
                        Delay_ms(1000);
                        ign_wait++;
                    }
                }

                break;
            case PKE_OPER_STA_IDLE:
                if(idle==0) {
                    UART2_SendStr("PKE_OPER_STA_IDLE in!");
                    idle=1;
                    TIM2_CCxCmd(TIM2_CHANNEL_2, ENABLE);
                }
                BR_PWM(&brightness, &up);
                Delay_ms(10);	
                if(TJTW_PKE.power_event_flag)
                {
                    TJTW_PKE.power_event_flag = 0;
					Motor_Pulse_Rev_20ms();  //Power OFF event => Motor reverse 20ms
                    TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                    TIM2_CCxCmd(TIM2_CHANNEL_2, DISABLE);
                    GPIO_Init(GPIOD, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);
                    UART2_SendStr("PKE_OPER_STA_IDLE out!");
                    idle=0;
                }
		else if (!IGN_IS_ON()) {  //ign off
			Motor_Pulse_Rev_20ms();
			TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
			UART2_SendStr("IGN_OFF PKE_OPER_STA_IDLE out!");
			idle=0;
		}
                break;
            case PKE_OPER_STA_LEARN:
                UART2_SendStr("PKE_OPER_STA_LEARN in!");
                TIM2_CCxCmd(TIM2_CHANNEL_2, DISABLE);
                GPIO_Init(GPIOD, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);
                for(i=0;i<50;i++) {
                    BZ_ON();
                    LP_RIGHT_ON();
                    BR_LIGHT_ON();
                    Delay_ms(100);
                    showcard(Tx_Buffer,&set,rc522_SN);
                    Reset_RC522();
                    if(set ==1) {
                        UART2_SendString(Tx_Buffer, 17);
                        set=0;
                        i=50;
                        Write_EEpeomData(rc522_SN);
                    }
                    BZ_OFF();
                    LP_RIGHT_OFF();
                    BR_LIGHT_OFF();
                    Delay_ms(100);
                }
                TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                UART2_SendStr("PKE_OPER_STA_LEARN out!");
                break;
            default:
                UART2_SendStr("Default state");
                TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                break;
        }

    }
}
