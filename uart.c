/********************  ********************
    |--------------------|
    |  USART1_RX-PD4     |
    |  USART1_TX-PD5     |
    |--------------------|
**********************************************************************************/

#include "uart.h"
#include "stm8s_uart2.h"
#include "stm8s_clk.h"

/* ********************************************
UART2  configured as follow:
  - BaudRate = 9600 baud  
  - Word Length = 8 Bits
  - One Stop Bit
  - No parity
  - Receive and transmit enabled
 -  Receive interrupt
  - UART1 Clock disabled
*********************************************/
void Uart_Init(void)
{
    UART2_DeInit();
    UART2_Init((u32)9600, UART2_WORDLENGTH_8D, UART2_STOPBITS_1, \
    UART2_PARITY_NO , UART2_SYNCMODE_CLOCK_DISABLE , UART2_MODE_TXRX_ENABLE);
    UART2_ITConfig(UART2_IT_RXNE_OR,ENABLE  );
    UART2_Cmd(ENABLE );
  
}

void UART2_SendByte(u8 data)
{
    UART2_SendData8((unsigned char)data);
  /* Loop until the end of transmission */
  while (UART2_GetFlagStatus(UART2_FLAG_TXE) == RESET);
}

void UART2_SendString(u8* Data,u16 len)
{
  u16 i=0;
  for(;i<len;i++)
    UART2_SendByte(Data[i]);
  
}

void UART2_SendStr(char* str)
{
  UART2_SendByte('\n');
  UART2_SendByte('\r');
    while (*str != '\0')
    {
        UART2_SendByte((u8)(*str));
        str++;
    }
}

u8 UART2_ReceiveByte(void)
{
     u8 USART2_RX_BUF; 
     while (UART2_GetFlagStatus(UART2_FLAG_RXNE) == RESET);
     USART2_RX_BUF=UART2_ReceiveData8();
     return  USART2_RX_BUF;
    
}

