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
		
		
	}
}