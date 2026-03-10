/* MAIN.C file
 * 
 * Copyright (c) 2002-2005 STMicroelectronics
 */
#include "stm8s.h"
#include "stm8s_conf.h"
#include "uart.h"
#include "rc522.h"
#include "lf_send.h"

enum pke_oper_state {
    PKE_OPER_STA_POWER_OFF,
    PKE_OPER_STA_POWER_ON,
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

#define RC522KEY_COUNT_ADDR   0x00004100
#define RC522KEY_START_ADDR   0x00004110
#define RC522KEY_SIZE         4
#define MAX_RC522KEY_NUM      5

//for ign to count down by 10s
#define IGN_TIMEOUT_MS      10000UL
#define IGN_IS_ON()         (GPIO_ReadInputPin(GPIOB, GPIO_PIN_5) != RESET)

u8 Tx_Buffer[] = "RFID---test";
#define  BufferSize (countof(Tx_Buffer)-1)

void Clock_Config(void)
{
	
	//enable internal HSI clock(16MHZ)
	CLK_HSICmd(ENABLE);

	//make sure internal clock(HSI) is stable
	while (CLK_GetFlagStatus(CLK_FLAG_HSIRDY) == RESET);

	//set HSI DIV(High speed internal clock prescaler: 1)
	CLK_HSIPrescalerConfig(CLK_PRESCALER_HSIDIV1);
	CLK_PeripheralClockConfig(CLK_PERIPHERAL_SPI,   ENABLE);

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
    Delay_ms_int(20);
    MOTOR_STOP();
}

static void Motor_Pulse_Rev_20ms(void)
{
    MOTOR_REV();
    Delay_ms_int(20);
    MOTOR_STOP();
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

    /* init gpio status */
    BR_LIGHT_OFF();
    LP_RIGHT_OFF();
    MOTOR_STOP();
    BZ_OFF();
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

main()
{
    int i,ret,idle;
		
		//for ign using 
		uint32_t ign_start_tick = 0;
		uint8_t ign_prev = 0;
		uint8_t ign_now = 0;
		uint8_t ign_wait = 0;
		uint8_t ign_active = 0;
		
    u8 set=0;
    uint16_t brightness = 0; // bright pwm (0 åˆ° 999)
    uint8_t up = 1;
    unsigned char rc522_SN[4];
    TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
    TJTW_PKE.power_event_flag = 0;
    TJTW_PKE.learn_event_flag = 0;
    idle=0;
		ign_wait = 0;
		ign_start_tick = 0;
		
    Clock_Config();
    GPIO_Config();
    EXTI_Config();
    //TIM4_DeInit();
    //TIM4_Init();
		MX_TIM4_Init();
    Uart_Init();
    InitRc522();
    Delay_ms_int(100);
    TIM2_PWM_Config();
    //Clear_PKE_EEPROM();
    enableInterrupts();
		
    UART2_SendStr("system start!");
		
    while(1)
    {
        switch(TJTW_PKE.oper_state) {
            case PKE_OPER_STA_POWER_OFF:
                UART2_SendStr("PKE_OPER_STA_POWER_OFF in!");
                enableInterrupts();
								MOTOR_STOP();
								Delay_ms_int(50);
                halt();
								Delay_ms_int(50);
                Clock_Config();
								MX_TIM4_Init();      // ¦pªG HALT «á timer »Ý­n­««Ø
								Uart_Init();         // ¦pªG UART ª¬ºA¤£«OÃÒ
								InitRc522();
								Delay_ms_int(50);

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
                    Delay_ms_int(100);

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
								
										if(IGN_IS_ON()) {
												ign_wait = 0;
												ign_active = 1;
												ign_prev = 1;
												ign_start_tick = 0;
												UART2_SendStr("IGN already ON");
										} else {
												ign_wait = 1;
												ign_active = 0;
												ign_prev = 0;
												ign_start_tick = tim4_tick;
												UART2_SendStr("IGN wait start");
										}
								
										TJTW_PKE.oper_state = PKE_OPER_STA_IDLE;
								} else {
										ign_wait = 0;
										ign_active = 0;
										ign_prev = 0;
										ign_start_tick = 0;
										TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
								}
                UART2_SendStr("PKE_OPER_STA_POWER_ON out!");
                break;
            case PKE_OPER_STA_IDLE:
                if(idle==0) {
                    UART2_SendStr("PKE_OPER_STA_IDLE in!");
                    idle=1;
                    TIM2_CCxCmd(TIM2_CHANNEL_2, ENABLE);
                }
                BR_PWM(&brightness, &up);
                Delay_ms_int(10);	
								ign_now = 0;
								if(IGN_IS_ON()) {
										ign_now = 1;
								}
								
								/* Step 1: wait for IGN ON */
								if(ign_wait) {
										if(ign_now) {
												ign_wait = 0;
												ign_active = 1;
												ign_prev = 1;
												ign_start_tick = 0;
												UART2_SendStr("IGN detected");
										}
										else if((uint32_t)(tim4_tick - ign_start_tick) >= IGN_TIMEOUT_MS) {
												UART2_SendStr("IGN timeout");
								
												Motor_Pulse_Rev_20ms();
								
												ign_wait = 0;
												ign_active = 0;
												ign_prev = 0;
												ign_start_tick = 0;
								
												TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
												TIM2_CCxCmd(TIM2_CHANNEL_2, DISABLE);
												GPIO_Init(GPIOD, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);
												UART2_SendStr("PKE_OPER_STA_IDLE out!");
												idle = 0;
												break;
										}
								}
								
								/* Step 2: IGN ON ,check ON -> OFF */
								else if(ign_active) {
										if((ign_prev == 1) && (ign_now == 0)) {
												UART2_SendStr("IGN OFF detected");
								
												Motor_Pulse_Rev_20ms();
								
												ign_wait = 0;
												ign_active = 0;
												ign_prev = 0;
												ign_start_tick = 0;
								
												TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
												TIM2_CCxCmd(TIM2_CHANNEL_2, DISABLE);
												GPIO_Init(GPIOD, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);
												UART2_SendStr("PKE_OPER_STA_IDLE out!");
												idle = 0;
												break;
										}
								
										ign_prev = ign_now;
								}
                if(TJTW_PKE.power_event_flag)
                {
                    TJTW_PKE.power_event_flag = 0;
										/* Power OFF event => Motor reverse 20ms */
										Motor_Pulse_Rev_20ms();
                    TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                    TIM2_CCxCmd(TIM2_CHANNEL_2, DISABLE);
                    GPIO_Init(GPIOD, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);
                    UART2_SendStr("PKE_OPER_STA_IDLE out!");
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
                    Delay_ms_int(100);
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
                    Delay_ms_int(100);
                }
								ign_wait = 0;
								ign_start_tick = 0;
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