
#ifndef __UART_H
#define __UART_H
#include "stm8s_uart2.h"

/* Private macro -------------------------------------------------------------*/
#define countof(a)   (sizeof(a) / sizeof(*(a)))
#define RxBufferSize 64

void Uart_Init(void);
void UART2_SendByte(u8 data);
void UART2_SendString(u8* Data,u16 len);
u8 UART2_ReceiveByte(void);
void UART2_SendStr(char* str);

#endif