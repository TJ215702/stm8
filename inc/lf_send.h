#ifndef __LF_SEND_H
#define __LF_SEND_H

#include "stm8s.h"

/* 103: CH1 gate = PC7 ¡÷ 105: §ï¥Î PE5 ·í 125K_EN */
#define CH1_GPIO_OPEN   (GPIOE->ODR |= (uint8_t)0x20)    /* PE5 = 1, enable 125K driver */
#define CH1_GPIO_CLOCK  (GPIOE->ODR &= (uint8_t)~0x20)  /* PE5 = 0, disable 125K driver */

#define CH2_GPIO_OPEN   GPIOC->ODR |= 0x08    
#define CH2_GPIO_CLOCK  GPIOC->ODR &= ~(0x08) 
#define CH3_GPIO_OPEN   GPIOC->ODR |= 0x10    
#define CH3_GPIO_CLOCK  GPIOC->ODR &= ~(0x10) 

#define  LF_SEND_CH1    1		      
#define  LF_SEND_CH2    2
#define  LF_SEND_CH3    3
#define  Patt_16bit     0
#define  Patt_32bit     1

#define USER_BUFF_MAX 10
#define SET_BUFF_MAX  (USER_BUFF_MAX + 16)

#define SET_ENABLE1 Set_Buff[0]   
#define SET_ENABLE2 Set_Buff[1]   
#define DEVICE_ID   Set_Buff[2]	  
#define LF_PLL      Set_Buff[3]	  
#define RC_PLL1     Set_Buff[4]	  
#define RC_PLL2     Set_Buff[5]	  
#define ONOFF_SCAN  Set_Buff[6]   
#define PATTREN_BIT Set_Buff[7]   
#define PATTERN1    Set_Buff[8]   
#define PATTERN2    Set_Buff[9]   
#define LFBIT_NxRC  Set_Buff[10]  
#define LFSENDMODE  Set_Buff[11]  
#define LF_ENABLE   Set_Buff[12]  
#define INTERVAL1   Set_Buff[13]  
#define INTERVAL2   Set_Buff[14]  
#define ACTIVE_NUM  Set_Buff[15]  
#define ACTIVE_ID1  Set_Buff[16]  
#define ACTIVE_ID2  Set_Buff[17]  
#define ACTIVE_ID3  Set_Buff[18]  
#define ACTIVE_ID4  Set_Buff[19]  
#define ACTIVE_ID5  Set_Buff[20]  
#define ACTIVE_ID6  Set_Buff[21]  
#define ACTIVE_ID7  Set_Buff[22]  
#define ACTIVE_ID8  Set_Buff[23]  
#define ACTIVE_ID9  Set_Buff[24]  
#define ACTIVE_ID10 Set_Buff[25]  

extern unsigned char Set_Buff[SET_BUFF_MAX];    
extern unsigned int Bit_element;
extern unsigned int Carrier_Time;
extern unsigned int LF_Send_Tim;       

extern void Delay_InIt(unsigned char clk);
extern void Delay_us(unsigned int nus);
extern void LF_ClockOccurs(unsigned char LF_Pll);
extern void LF_PLL_SET(unsigned char LF_Pll);
extern void Timecalculate(void);	        
extern void LF_SendData(unsigned char R6_Dat,
                        unsigned char R5_Dat,
                        unsigned char Patt16_32,
                        unsigned char LF_Send_CHx);

#endif
