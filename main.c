/* MAIN.C file
 * 
 * Copyright (c) 2002-2005 STMicroelectronics
 */


#include "stm8s.h"
#include "stm8s_conf.h"
#include "string.h"
#include "uart.h"
#include "rc522.h"

void Delay(u32 nCount);
extern u8 RxBuffer[RxBufferSize];
extern u8 UART_RX_NUM;

unsigned char CT[2];//卡?型
unsigned char SN[4]; //卡?

unsigned char write[16] = {0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x10};
unsigned char read[16] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
unsigned char key[6] = {0xFF,0xFF,0xFF,0xFF,0xFF,0xFF};


/* Private macro -------------------------------------------------------------*/
#define countof(a) (sizeof(a) / sizeof(*(a)))
#define  BufferSize (countof(Tx_Buffer)-1)
/* Private variables ---------------------------------------------------------*/
u8 Tx_Buffer[] = "STM8S RFID TEST: RFID test";
u8 Rx_Buffer[BufferSize];
u32 FLASH_ID ;
/* Private defines -----------------------------------------------------------*/
/* Private function prototypes -----------------------------------------------*/
void cardNo2String(u8 *cardNo, u8 *str);
/* Private functions ---------------------------------------------------------*/


u8 RxBuffer[RxBufferSize];
u8 UART_RX_NUM=0;

void Clock_Config(void)
{
	//enable internal HSI clock(16MHZ)
	CLK_HSICmd(ENABLE);

	//make sure internal clock(HSI) is stable
	while (CLK_GetFlagStatus(CLK_FLAG_HSIRDY) == RESET);

	//set HSI DIV(High speed internal clock prescaler: 1)
	CLK_HSIPrescalerConfig(CLK_PRESCALER_HSIDIV1);

}

main()
{
	unsigned char status;
	Clock_Config();
	GPIO_Init(GPIOA, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);
	MX_TIM4_Init();
	status = memcmp(read,write,16);
	Uart_Init();
	InitRc522();
	rim();
	UART1_SendString(Tx_Buffer,BufferSize);
	

	while (1) {
		status = PcdRequest(PICC_REQALL,CT);      /*?描卡*/
    status = PcdAnticoll(SN);                 /*防?撞*/      
    if (status==MI_OK)
    {
        GPIO_LOW(GPIOA, GPIO_PIN_3);   
				UART1_SendString("The card Id iszzz:",15); 
        cardNo2String(SN, Tx_Buffer);
        UART1_SendString(Tx_Buffer, 17);        
        
        Reset_RC522();
    }
    else
    {
        GPIO_HIGH(GPIOA, GPIO_PIN_3);
    }   
	}

}

void Delay(u32 nCount)
{
  /* Decrement nCount value */
  while (nCount != 0)
  {
    nCount--;
  }
}

void Hex2String(u8 hex,u8 *str)
{
  str[0] = (hex / 100) + '0';
  str[1] = (hex % 100 / 10) + '0';
  str[2] = (hex % 10) + '0';
}

void cardNo2String(u8 *cardNo, u8 *str)
{
    u8 Count = 0;
    for(Count = 0; Count < 4; Count++)
    {
        Hex2String(cardNo[Count], str + Count * 4);
        if(Count == 3)
        {
          str[15] = '\n';
        }
        else
        {
          str[Count * 4 + 3] = ':';
        }
    }
}
/*
@far @interrupt void UART1_RX_IRQHandler(void)
{
	  u8 Res;
    if(UART1_GetITStatus(UART1_IT_RXNE )!= RESET)  
    {
			Res =UART1_ReceiveData8();
			if(( UART_RX_NUM&0x80)==0)
			{
				if( UART_RX_NUM&0x40)
				{
					if(Res!=0x0a) UART_RX_NUM=0;
					else  UART_RX_NUM|=0x80;	
				}
				else 
				{	
					if(Res==0x0d) UART_RX_NUM|=0x40;
					else
					{
						RxBuffer[ UART_RX_NUM&0X3F]=Res ;
						UART_RX_NUM++;
						if( UART_RX_NUM>63) UART_RX_NUM=0;
					}		 
				}
			}  		 
		}
}
*/