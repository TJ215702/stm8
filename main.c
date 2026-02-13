/* MAIN.C file
 * 
 * Copyright (c) 2002-2005 STMicroelectronics
 */
#include "stm8s.h"
#include "stm8s_conf.h"
#include "uart.h"
#include "rc522.h"

/* ================= IO 定義 ================= */

#define D3_ON()      GPIO_WriteHigh(GPIOD, GPIO_PIN_3)
#define D3_OFF()     GPIO_WriteLow(GPIOD, GPIO_PIN_3)

#define B3_ON()      GPIO_WriteHigh(GPIOB, GPIO_PIN_3)
#define B3_OFF()     GPIO_WriteLow(GPIOB, GPIO_PIN_3)

#define IN1_ON()     GPIO_WriteHigh(GPIOC, GPIO_PIN_2)
#define IN1_OFF()    GPIO_WriteLow(GPIOC, GPIO_PIN_2)

#define IN2_ON()     GPIO_WriteHigh(GPIOB, GPIO_PIN_0)
#define IN2_OFF()    GPIO_WriteLow(GPIOB, GPIO_PIN_0)

#define MOTOR_FWD()  do{IN1_ON(); IN2_OFF();}while(0)
#define MOTOR_REV()  do{IN1_OFF(); IN2_ON();}while(0)
#define MOTOR_STOP() do{IN1_OFF(); IN2_OFF();}while(0)

/* PB4 */
#define PB4_PRESSED() (GPIO_ReadInputPin(GPIOB, GPIO_PIN_4) == RESET)
u8 Tx_Buffer[] = "RFID---test";
#define  BufferSize (countof(Tx_Buffer)-1)

/* ================= Delay ================= */

static void delay_ms(uint16_t ms)
{
    uint16_t i;
    while(ms--)
    {
        for(i=0;i<600;i++)
            __asm("nop");
    }
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

}

/* ================= GPIO ================= */

static void GPIO_Config(void)
{
    /* D3 output */
    GPIO_Init(GPIOD, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);

    /* 這些腳位你說 init 就會設定好（但我仍保留 Init，且不在 main() 控） */
    GPIO_Init(GPIOB, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST); /* B3 */
    GPIO_Init(GPIOC, GPIO_PIN_2, GPIO_MODE_OUT_PP_LOW_FAST); /* IN1 */
    GPIO_Init(GPIOB, GPIO_PIN_0, GPIO_MODE_OUT_PP_LOW_FAST); /* IN2 */

    /* PB4 input floating + interrupt (依你原碼不改) */
    GPIO_Init(GPIOB, GPIO_PIN_4, GPIO_MODE_IN_FL_IT);

    /* 上電預設狀態：避免亂亮（不在 main() 做） */
    D3_OFF();
    B3_OFF();
    MOTOR_STOP();
}

/* ================= EXTI ================= */

static void EXTI_Config(void)
{
    /* 依你原碼：PORTB rising edge */
    EXTI_SetExtIntSensitivity(EXTI_PORT_GPIOB,
                              EXTI_SENSITIVITY_RISE_ONLY);
}

/* ================= ISR ================= */

INTERRUPT_HANDLER(EXTI_PORTB_IRQHandler, 4)
{
    /* 空 ISR：只用來喚醒 HALT */
}

/* ================= HALT ================= */

static void Enter_HALT(void)
{
    /* 3) 進入 HALT：全滅（此處只處理 D3，B3/馬達不在 main() 出現也不在這裡動） */
    D3_OFF();

    /* 避免按著就睡，先等放開 */
    while(PB4_PRESSED());
    delay_ms(20);

    enableInterrupts();
    halt();                 /* sleep */
    /* 返回代表已喚醒 */

    delay_ms(20);           /* stabilize */
}

main()
{
	/* D3 閃爍狀態（10ms tick, 50 次 = 0.5s） */
    uint16_t d3_tick_10ms = 0;
    uint8_t  d3_state = 0;      /* 0=OFF,1=ON */

    /* Power key release-to-arm */
    uint8_t pb_arm = 1;

    Clock_Config();
    GPIO_Config();
    EXTI_Config();

    enableInterrupts();

    while(1)
    {
        delay_ms(10);

        /* 1) Power button：醒著時按下 -> 進 HALT；HALT 期間靠 EXTI 喚醒 */
        if(pb_arm && PB4_PRESSED())
        {
            pb_arm = 0;

            Enter_HALT();

            /* 4) 喚醒後重新計數：D3 從 OFF 開始，重新等滿 0.5s 才翻 */
            d3_tick_10ms = 0;
            d3_state = 0;
            D3_OFF();
        }

        if(!pb_arm && !PB4_PRESSED())
        {
            pb_arm = 1;
        }

        /* 2) 醒著時：D3 每 0.5s 閃一下 */
        if(d3_tick_10ms < 49)
        {
            d3_tick_10ms++;
        }
        else
        {
            d3_tick_10ms = 0;
            d3_state ^= 1;

            if(d3_state) D3_ON();
            else         D3_OFF();
        }
    }
	/*unsigned char status;
	u8 set=0;
	Clock_Config();
	GPIO_Init(GPIOE, GPIO_PIN_5, GPIO_MODE_OUT_PP_LOW_FAST);

	TIM4_Init();
	InitRc522();
	Uart_Init();
	UART2_SendString(Tx_Buffer,BufferSize);

	while (1){
		Delay_ms(100);
		
		showcard(Tx_Buffer,&set);
		Reset_RC522();
		if(set ==1) {
			UART2_SendString(Tx_Buffer, 17);
			set=0;
		}
		
		*/
}