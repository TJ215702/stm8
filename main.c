/* MAIN.C file
 * 
 * Copyright (c) 2002-2005 STMicroelectronics
 */
#include "stm8l15x.h"
#include "discover_board.h"

unsigned char AS3933_Wake = 0;
unsigned char WakeData_Flag = 0;
unsigned char Wake_Date[20];
unsigned char RSSI_Date[3];
unsigned char STM8L_ID[8];
unsigned char UserKey_Flag = 0;
unsigned long RF_SN;                
volatile u8 fac_us = 0;
unsigned long Data_High, Data_Low;

void RF_SendData(unsigned char Key);
void AS3933_WakeUp(void);



// CRC16  (CCITT: x^16 + x^12 + x^5 + 1)
uint16_t Calculate_CRC16(uint8_t *ptr, uint8_t len) {
    uint16_t crc = 0xFFFF;
    uint8_t i, j;
    for (i = 0; i < len; i++) {
        crc ^= (uint16_t)ptr[i] << 8;
        for (j = 0; j < 8; j++) {
            if (crc & 0x8000) {
                crc = (crc << 1) ^ 0x1021;
            } else {
                crc <<= 1;
            }
        }
    }
    return crc;
}

void Get_STM8L_UniqueID(void)        
{
     unsigned char i;
     uint16_t crc_result;
     
     STM8L_ID[0] = *(unsigned char*)(0x4926); // X
     STM8L_ID[1] = *(unsigned char*)(0x4928); // Y
     STM8L_ID[2] = *(unsigned char*)(0x492B); // LOT 1
     STM8L_ID[3] = *(unsigned char*)(0x492C); // LOT 2
     STM8L_ID[4] = *(unsigned char*)(0x492D); // LOT 3
     STM8L_ID[5] = *(unsigned char*)(0x492E); // LOT 4

     crc_result = Calculate_CRC16(STM8L_ID, 6);

     STM8L_ID[6] = (uint8_t)(crc_result >> 8);   // CRC High
     STM8L_ID[7] = (uint8_t)(crc_result & 0xFF); // CRC Low

     Data_High = ((uint32_t)STM8L_ID[0] << 24) |
                ((uint32_t)STM8L_ID[1] << 16) |
                ((uint32_t)STM8L_ID[2] << 8)  |
                ((uint32_t)STM8L_ID[3]);

    Data_Low  = ((uint32_t)STM8L_ID[4] << 24) |
                ((uint32_t)STM8L_ID[5] << 16) |
                ((uint32_t)STM8L_ID[6] << 8)  |
                ((uint32_t)STM8L_ID[7]);
}
void write_STM8L_UniqueID(void)
{
     unsigned char i;
     unsigned char JIMSTM8L_ID[12];

     for(i = 0; i < 12; i ++)
     {
          JIMSTM8L_ID[i] = *(unsigned char*)(0x4926 + i);
     }

     FLASH_Unlock(FLASH_MemType_Data);

     for (i = 0; i < 12; i++)
        FLASH_ProgramByte(0x00001080 + i, JIMSTM8L_ID[i]);

    FLASH_Lock(FLASH_MemType_Data);
}

void Delay_InIt(unsigned char clk)
{
    if(clk > 16) fac_us = (16 - 4)/4;
    else if(clk > 4) fac_us = (clk - 4)/4; 
    else fac_us = 1;
}

void Delay_us(unsigned int nus)
{
	unsigned int j;

	for(j=0;j<nus;j++)
		__asm("nop");

}
void Delay_us2(unsigned int nus)
{
	unsigned int j;

	for(j=0;j<nus/2;j++)
		__asm("nop");

}

void AS3933_SPI_Write_Byte(unsigned char addr,unsigned char byte)  
{
    unsigned char i;    
    unsigned int Write_Data = 0;
    
    AS3933_SDI_WriteZero;
    AS3933_SCL_WriteZero;
    AS3933_CS_WriteOne;
    
    Write_Data =  addr * 256 +  byte;   

    for(i = 0; i < 16; i++)
    {
         if(Write_Data & 0x8000)        
              AS3933_SDI_WriteOne;           
         else                          
           
              AS3933_SDI_WriteZero;
         Write_Data =  Write_Data << 1; 
         
         AS3933_SCL_WriteOne;           
         Delay_us(2);
         AS3933_SCL_WriteZero;
         Delay_us(1);
    }
    AS3933_SDI_WriteZero;
    AS3933_CS_WriteZero;
}

unsigned char AS3933_SPI_Read_Byte(unsigned char addr)  
{
    unsigned char i,temp;
    
    AS3933_SDI_WriteZero;
    AS3933_SCL_WriteZero;
    AS3933_CS_WriteOne;                
    
    addr = addr | 0x40;		       
    
    for(i = 0; i < 8; i ++)            
    {
         if(addr & 0x80)   AS3933_SDI_WriteOne;
         else
              AS3933_SDI_WriteZero;
         addr = addr << 1;
  
         AS3933_SCL_WriteOne;          
         Delay_us(2);
         AS3933_SCL_WriteZero;
         Delay_us(1);        
    } 
    
    temp = 0x00;
    for(i = 0; i < 8; i ++)          
    {
         AS3933_SCL_WriteOne;           
         Delay_us(2);
         AS3933_SCL_WriteZero;
         Delay_us(1); 
         temp = temp << 1;
         if(AS3933_SDO_Read != 0)   temp = temp | 0x01;  
    }
    AS3933_SDI_WriteZero;
    AS3933_CS_WriteZero;
    return temp;
}

void AS3933_COMM(unsigned char Com)   
{
    unsigned char i;
    
    AS3933_SDI_WriteZero;
    AS3933_SCL_WriteZero;
    AS3933_CS_WriteOne;               
    
    for(i = 0; i < 8; i ++)          
    {
         if(Com & 0x80) AS3933_SDI_WriteOne;
         else
              AS3933_SDI_WriteZero;
         Com = Com << 1;
         
         AS3933_SCL_WriteOne;          
         Delay_us(2);
         AS3933_SCL_WriteZero;
         Delay_us(1);        
    } 
    AS3933_SDI_WriteZero;
    AS3933_CS_WriteZero;
}

void AS3933_RC_Check(void)
{
    unsigned char i = 0;
    unsigned char Com = 0xC2;    
    
    AS3933_SDI_WriteZero;
    AS3933_SCL_WriteZero;
    AS3933_CS_WriteOne;               
    
    for(i = 0; i < 8; i ++)          
    {
         if(Com & 0x80)
              AS3933_SDI_WriteOne;
         else
              AS3933_SDI_WriteZero;
         Com = Com << 1;
         
         AS3933_SCL_WriteOne;        
         Delay_us(2);
         AS3933_SCL_WriteZero;
         Delay_us(1);        
    } 

    for(i = 0;i < 65;i ++)           
    {
         AS3933_SCL_WriteZero;
         Delay_us(15); 
         AS3933_SCL_WriteOne; 
         Delay_us(14); 
    }
    
    AS3933_SDI_WriteZero;
    AS3933_SCL_WriteZero;
    AS3933_CS_WriteZero;
}

void AS3933_Register_Set(void)
{
    AS3933_COMM(0xC4);
    Delay_us(5000);              
    
    AS3933_SPI_Write_Byte(0x11,0x18);  //set R17(L1)  12pf ->  16+8=24  25*0.5=12
    Delay_us(1000);                    
    AS3933_SPI_Write_Byte(0x10,0x41);	 //turn on L1 test mode
    Delay_us(10000);                    
    AS3933_SPI_Write_Byte(0x10,0x00); //turn off L1 test mode
  
    AS3933_SPI_Write_Byte(0x12,0x0E);   //set R18(L2)  7pf ->  8+4+2=14  14*0.5=7
    Delay_us(1000);                    
    AS3933_SPI_Write_Byte(0x10,0x42);	//turn on L2 test mode
    Delay_us(10000);                    
    AS3933_SPI_Write_Byte(0x10,0x00);  //turn off L2 test mode
    
    AS3933_SPI_Write_Byte(0x13,0x18);   //set R19(L3)  12pf ->  16+8=24  25*0.5=12
    Delay_us(1000);                     
    AS3933_SPI_Write_Byte(0x10,0x44);	//turn on L3 test mode
    Delay_us(10000);                  
    AS3933_SPI_Write_Byte(0x10, 0x00);  //turn off L3 test mode
    
    AS3933_SPI_Write_Byte(0x00, 0xDE);  //enable L1/L2/L3 ,automatic scan mode , internal clock
    AS3933_SPI_Write_Byte(0x01, 0x2A);	    //Bit 3:1  -12dB , Bit 6(0) use 16 bit wake up                       
    AS3933_RC_Check();                 
    AS3933_RC_Check();  
    AS3933_SPI_Write_Byte(0x02, 0x20);  
    AS3933_SPI_Write_Byte(0x03, 0xBA); 
    AS3933_SPI_Write_Byte(0x04, 0x30);   //off time set , set max Damping resistor
    AS3933_SPI_Write_Byte(0x05, 0x3A);   //wake up low Pattern
    AS3933_SPI_Write_Byte(0x06, 0xC3);   //wake up high Pattern
    AS3933_SPI_Write_Byte(0x07, 0x8B); 
    AS3933_SPI_Write_Byte(0x08, 0x00);  
    AS3933_SPI_Write_Byte(0x09, 0x00);
}

void GPIO_LowPower_Config(void) 
{
    GPIO_Init(GPIOA, GPIO_Pin_All, GPIO_Mode_Out_PP_Low_Slow);
    GPIO_Init(GPIOB, GPIO_Pin_All, GPIO_Mode_Out_PP_Low_Slow);
    GPIO_Init(GPIOC, GPIO_Pin_All, GPIO_Mode_Out_PP_Low_Slow);
    GPIO_Init(GPIOD, GPIO_Pin_All, GPIO_Mode_Out_PP_Low_Slow);  
    GPIO_Init(GPIOA, GPIO_Pin_2|GPIO_Pin_3, GPIO_Mode_Out_PP_Low_Slow);
    GPIO_Init(GPIOB, GPIO_Pin_3|GPIO_Pin_4|GPIO_Pin_5, GPIO_Mode_Out_PP_Low_Slow);
    GPIO_Init(GPIOB, GPIO_Pin_0|GPIO_Pin_1, GPIO_Mode_In_FL_IT);
    GPIO_Init(GPIOB, GPIO_Pin_2|GPIO_Pin_6|GPIO_Pin_7, GPIO_Mode_In_FL_No_IT);
    GPIO_Init(GPIOC, GPIO_Pin_0|GPIO_Pin_1|GPIO_Pin_4|GPIO_Pin_5|GPIO_Pin_6, GPIO_Mode_Out_PP_Low_Slow);  
    
    EXTI_SetPinSensitivity(EXTI_Pin_0,EXTI_Trigger_Falling_Low);    
    EXTI_SetPinSensitivity(EXTI_Pin_1,EXTI_Trigger_Rising );       
}

main()
{
    int j;
    CLK_HSICmd(ENABLE);
    CLK_SYSCLKSourceConfig(CLK_SYSCLKSource_HSI);  
    CLK_SYSCLKDivConfig(CLK_SYSCLKDiv_1);         
    while(CLK_GetFlagStatus(CLK_FLAG_HSIRDY) == RESET);  
    Get_STM8L_UniqueID();
    //write_STM8L_UniqueID();
    GPIO_LowPower_Config();                       
    Delay_InIt(16);                              
    AS3933_Register_Set();                        
    CLK_HaltConfig(CLK_Halt_FastWakeup,ENABLE);   
    PWR_FastWakeUpCmd(ENABLE);                    
    PWR_UltraLowPowerCmd(ENABLE);             
    Delay_InIt(8);  
	
	while (1){
		
		LED_OFF;              
		halt();
		
		CLK_SYSCLKSourceConfig(CLK_SYSCLKSource_HSI);  
		CLK_SYSCLKDivConfig(CLK_SYSCLKDiv_2);          
		while(CLK_GetFlagStatus(CLK_FLAG_HSIRDY) == RESET);  
		
		if(AS3933_Wake)                                
		 {
				 AS3933_Wake = 0;
				 AS3933_WakeUp();
				 if(WakeData_Flag)             
				 {                  
						 
						 WakeData_Flag = 0;
				 } RF_SendData(0x02);
		 }
		 if(UserKey_Flag)
		 {
				 UserKey_Flag = 0;
				 RF_SendData(0x01);
		 }
        
			//	LED_TOGGLE;
      //Delay_us(100);
    }
	
}


void AS3933_WakeUp(void)                   
{
      unsigned char i,j;
      unsigned int Wait_Time = 0;
      
      if(AS3933_Wake_Read)                
      {
           if(WakeData_Flag)  
           {
                AS3933_COMM(0xC0);	    
                return;
           }
           Wake_Date[0] = 0;
           
           for(j = 0; j < 8; j ++)                
           {
                Wait_Time = 0;
                while(AS3933_DAT_CLK_Read == 0)   
                {
                     Wait_Time ++;
                     Delay_us(1);
                     if(Wait_Time > 1200)
                     {
                         AS3933_COMM(0xC0);	  
                         return;
                     }
                }
                Wake_Date[0] = Wake_Date[0] << 1;
                if(AS3933_DAT_Read) 
                         Wake_Date[0] = Wake_Date[0] | 0x01;
                
                while(AS3933_DAT_CLK_Read);        
            }            
           
            for(i = 0; i < Wake_Date[0]; i ++)    
            {                         
                for(j = 0; j < 8; j ++)
                {
                     Wait_Time = 0;
                     while(AS3933_DAT_CLK_Read == 0)   
                     {
                         Wait_Time ++;
                         Delay_us(1);
                         if(Wait_Time > 1200)
                         {
                              AS3933_COMM(0xC0);	     
                              return;
                         }
                     }
                        
                     Wake_Date[i + 1] = Wake_Date[i + 1] << 1;
                     if(AS3933_DAT_Read) 
                            Wake_Date[i + 1] = Wake_Date[i + 1] | 0x01;
                     
                     while(AS3933_DAT_CLK_Read);        
                }
            }
            RSSI_Date[0] = AS3933_SPI_Read_Byte(0x0a);
            RSSI_Date[1] = AS3933_SPI_Read_Byte(0x0b);
            RSSI_Date[2] = AS3933_SPI_Read_Byte(0x0c);
            WakeData_Flag = 1;
            AS3933_COMM(0xC0);
       }            
}

void RF_SendData(unsigned char Key)
{
     unsigned char i,j,k;
     unsigned long MSB_Temp = 0x00800000;
     
     unsigned long Current_Data;

     RF_SN =  RF_SN & 0xf0;     
     RF_SN =  RF_SN | Key;
     RF_SN = 0x12345678;

     
     for(i = 0; i < 2; i ++)
     {    
          LED_TOGGLE;
          MSB_Temp = 0x80000000;

          for(j = 0; j < 12; j ++)
          {
              RF_ON;
              Delay_us2(450);
              RF_OFF;
              Delay_us2(450);
          }
          RF_ON;                               
          Delay_us2(450);
          RF_OFF;
          for(j = 0; j < 10; j ++)  Delay_us2(400);     
          LED_TOGGLE;

          for(k = 0; k < 2; k++)
          {
               if(k == 0) Current_Data = Data_High;
               else       Current_Data = Data_Low;
               MSB_Temp = 0x80000000;
               for(j = 0; j < 32; j ++)
               {
                    if((Current_Data & MSB_Temp) != 0)
                    {
                         RF_ON;
                         Delay_us2(900);
                         RF_OFF;
                         Delay_us2(450);
                    }
                    else
                    {
                         RF_ON;
                         Delay_us2(450);
                         RF_OFF;
                         Delay_us2(900);
                    }
                    MSB_Temp = MSB_Temp >> 1;
               }
          }
     }
}


@far @interrupt void exti0_irqhandler(void)
{
	EXTI_ClearITPendingBit(EXTI_IT_Pin0);   
    if(!User_Key_Read)
        UserKey_Flag = 1;
}

@far @interrupt void exti1_irqhandler(void)
{
	//disableInterrupts();
    EXTI_ClearITPendingBit(EXTI_IT_Pin1);  
      
    if(AS3933_Wake_Read)                   
          AS3933_Wake = 1;
}
