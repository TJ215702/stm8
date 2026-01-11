/* MAIN.C file
 * 
 * Copyright (c) 2002-2005 STMicroelectronics
 */
#include "stm8s.h"
#include "stm8s_conf.h"
#include "uart.h"
#include "rc522.h"


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

main()
{
	unsigned char status;
	u8 set=0;
	Clock_Config();
	GPIO_Init(GPIOE, GPIO_PIN_5, GPIO_MODE_OUT_PP_LOW_FAST);
	GPIO_Init(GPIOA, GPIO_PIN_1, GPIO_MODE_OUT_PP_LOW_FAST);
	GPIO_Init(GPIOA, GPIO_PIN_2, GPIO_MODE_OUT_PP_LOW_FAST);
	GPIO_Init(GPIOD, GPIO_PIN_7, GPIO_MODE_OUT_PP_LOW_FAST);
	
	GPIO_Init(GPIOB, GPIO_PIN_2, GPIO_MODE_OUT_PP_LOW_FAST);
	GPIO_Init(GPIOB, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);
	GPIO_Init(GPIOB, GPIO_PIN_1, GPIO_MODE_OUT_PP_LOW_FAST);
	GPIO_Init(GPIOD, GPIO_PIN_0, GPIO_MODE_OUT_PP_LOW_FAST);
	GPIO_Init(GPIOD, GPIO_PIN_2, GPIO_MODE_OUT_PP_LOW_FAST);
	GPIO_Init(GPIOB, GPIO_PIN_0, GPIO_MODE_OUT_PP_LOW_FAST);
	MX_TIM4_Init();
	//TIM4_Init();
	InitRc522();
	Uart_Init();
	rim();
	UART2_SendString(Tx_Buffer,BufferSize);
	GPIO_WriteHigh(GPIOB, GPIO_PIN_2);
	GPIO_WriteHigh(GPIOB, GPIO_PIN_3);
	GPIO_WriteHigh(GPIOB, GPIO_PIN_1);
	
	GPIO_WriteLow(GPIOB, GPIO_PIN_0);
	GPIO_WriteLow(GPIOD, GPIO_PIN_0);
	GPIO_WriteLow(GPIOD, GPIO_PIN_2);
	
	while (1){
		GPIO_WriteReverse(GPIOE, GPIO_PIN_5);
		//GPIO_WriteReverse(GPIOA, GPIO_PIN_1);
		//GPIO_WriteReverse(GPIOA, GPIO_PIN_2);
		//GPIO_WriteReverse(GPIOD, GPIO_PIN_7);
		////GPIO_WriteReverse(GPIOC, GPIO_PIN_2);
		////Delay_ms_int(1000);
		Delay_ms(500);
		//GPIO_WriteReverse(GPIOB, GPIO_PIN_2);
		//GPIO_WriteReverse(GPIOB, GPIO_PIN_3);
		//GPIO_WriteReverse(GPIOB, GPIO_PIN_1);
	
		//GPIO_WriteReverse(GPIOB, GPIO_PIN_0);
		//GPIO_WriteReverse(GPIOD, GPIO_PIN_0);
		//GPIO_WriteReverse(GPIOD, GPIO_PIN_2);
		
		showcard(Tx_Buffer,&set);
		Reset_RC522();
		if(set ==1) {
			UART2_SendString(Tx_Buffer, 17);
			set=0;
		}
		
		
	}
}