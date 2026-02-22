/********************  ********************

    |--------------------|
    |  SPI_MISO-PC7      |
    |  SPI_MOSI-PC6      |
    |  SPI_CLK--PC5      |
    |  SPI_CS---PC4      |
    |  RST ---  PC3      |
    |--------------------|


***********************************************************************************/

//#include "include.h"
#include "rc522.h"
#include "stm8s.h"
#include "stm8s_conf.h"
#include <string.h>

unsigned char CT[2];
unsigned char SN[4];
unsigned char key[6] = {0xff,0xff,0xff,0xff,0xff,0xff};

/*
void delay_ns(u32 ns)
{
  u32 i;
  for(i=0;i<ns;i++)
  {
		__asm("nop");
		__asm("nop");
		__asm("nop");
  }
}
*/

u8 SPIWriteByte(u8 Byte)
{

  /* Loop while DR register in not emplty */
  while (SPI_GetFlagStatus( SPI_FLAG_TXE) == RESET);

  /* Send byte through the SPI1 peripheral */
  SPI_SendData(Byte);

  /* Wait to receive a byte */
  while (SPI_GetFlagStatus(SPI_FLAG_RXNE) == RESET);

  /* Return the byte read from the SPI bus */
  return SPI_ReceiveData();	
    
        
}
void SPI2_Init(void)	
{
  
    SPI_Init(SPI_FIRSTBIT_MSB, SPI_BAUDRATEPRESCALER_2, SPI_MODE_MASTER,\
            SPI_CLOCKPOLARITY_LOW, SPI_CLOCKPHASE_1EDGE, \
            SPI_DATADIRECTION_2LINES_FULLDUPLEX, SPI_NSS_SOFT, 0x07);
    SPI_Cmd(ENABLE);
    GPIO_Init( RC522NSS_GPIO_PORT, RC522NSS_GPIO_PIN, GPIO_MODE_OUT_PP_HIGH_FAST);
    GPIO_Init( RC522RST_GPIO_PORT, RC522RST_GPIO_PIN, GPIO_MODE_OUT_PP_HIGH_FAST);

}

void InitRc522(void)
{
  SPI2_Init();
  PcdReset();
  PcdAntennaOff();  
  PcdAntennaOn();
  M500PcdConfigISOType( 'A' );
}
void Reset_RC522(void)
{
  PcdReset();
  PcdAntennaOff();  
  PcdAntennaOn();    
}                         
/////////////////////////////////////////////////////////////////////
//功 能：尋卡
//參數說明: req_code[IN]:尋卡方式
// 0x52 = 尋感應區內所有符合14443A標準的卡片
// 0x26 = 尋找未進入休眠狀態的卡片
// pTagType[OUT]：卡片類型代碼
// 0x4400 = Mifare_UltraLight
// 0x0400 = Mifare_One(S50)
// 0x0200 = Mifare_One(S70)
// 0x0800 = Mifare_Pro(X)
// 0x4403 = Mifare_DESFire
//返 回: 成功返回MI_OK
/////////////////////////////////////////////////////////////////////
char PcdRequest(u8   req_code,u8 *pTagType)
{
	char   status;  
	u8   unLen;
	u8   ucComMF522Buf[MAXRLEN]; 

	ClearBitMask(Status2Reg,0x08);
	WriteRawRC(BitFramingReg,0x07);
	SetBitMask(TxControlReg,0x03);
 
	ucComMF522Buf[0] = req_code;

	status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,1,ucComMF522Buf,&unLen);

	if ((status == MI_OK) && (unLen == 0x10))
	{    
		*pTagType     = ucComMF522Buf[0];
		*(pTagType+1) = ucComMF522Buf[1];
	}
	else
	{   status = MI_ERR;   }
   
	return status;
}

/////////////////////////////////////////////////////////////////////
//功 能：防衝撞
//參數說明: pSnr[OUT]:卡片序號，4位元組
//返 回: 成功返回MI_OK
/////////////////////////////////////////////////////////////////////  
char PcdAnticoll(u8 *pSnr)
{
    char   status;
    u8   i,snr_check=0;
    u8   unLen;
    u8   ucComMF522Buf[MAXRLEN]; 
    

    ClearBitMask(Status2Reg,0x08);
    WriteRawRC(BitFramingReg,0x00);
    ClearBitMask(CollReg,0x80);
 
    ucComMF522Buf[0] = PICC_ANTICOLL1;
    ucComMF522Buf[1] = 0x20;

    status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,2,ucComMF522Buf,&unLen);

    if (status == MI_OK)
    {
    	 for (i=0; i<4; i++)
         {   
             *(pSnr+i)  = ucComMF522Buf[i];
             snr_check ^= ucComMF522Buf[i];
         }
         if (snr_check != ucComMF522Buf[i])
         {   status = MI_ERR;    }
    }
    
    SetBitMask(CollReg,0x80);
    return status;
}

/////////////////////////////////////////////////////////////////////
//功 能：選定卡片
//參數說明: pSnr[IN]:卡片序號，4位元組
//返 回: 成功返回MI_OK
/////////////////////////////////////////////////////////////////////
char PcdSelect(u8 *pSnr)
{
    char   status;
    u8   i;
    u8   unLen;
    u8   ucComMF522Buf[MAXRLEN]; 
    
    ucComMF522Buf[0] = PICC_ANTICOLL1;
    ucComMF522Buf[1] = 0x70;
    ucComMF522Buf[6] = 0;
    for (i=0; i<4; i++)
    {
    	ucComMF522Buf[i+2] = *(pSnr+i);
    	ucComMF522Buf[6]  ^= *(pSnr+i);
    }
    CalulateCRC(ucComMF522Buf,7,&ucComMF522Buf[7]);
  
    ClearBitMask(Status2Reg,0x08);

    status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,9,ucComMF522Buf,&unLen);
    
    if ((status == MI_OK) && (unLen == 0x18))
    {   status = MI_OK;  }
    else
    {   status = MI_ERR;    }

    return status;
}

/////////////////////////////////////////////////////////////////////
//功 能：驗證卡片密碼
//參數說明: auth_mode[IN]: 密碼驗證模式
// 0x60 = 驗證A金鑰
// 0x61 = 驗證B金鑰
// addr[IN]：區塊位址
// pKey[IN]：密碼
// pSnr[IN]：卡片序號，4位元組
//返 回: 成功返回MI_OK
/////////////////////////////////////////////////////////////////////               
char PcdAuthState(u8 auth_mode,u8 addr,u8 *pKey,u8 *pSnr)
{
    char   status;
    u8   unLen;
    u8   ucComMF522Buf[MAXRLEN]; 

    ucComMF522Buf[0] = auth_mode;
    ucComMF522Buf[1] = addr;
//    for (i=0; i<6; i++)
//    {    ucComMF522Buf[i+2] = *(pKey+i);   }
//    for (i=0; i<6; i++)
//    {    ucComMF522Buf[i+8] = *(pSnr+i);   }
    memcpy(&ucComMF522Buf[2], pKey, 6); 
    memcpy(&ucComMF522Buf[8], pSnr, 4); 
    
    status = PcdComMF522(PCD_AUTHENT,ucComMF522Buf,12,ucComMF522Buf,&unLen);
    if ((status != MI_OK) || (!(ReadRawRC(Status2Reg) & 0x08)))
    {   status = MI_ERR;   }
    
    return status;
}

/////////////////////////////////////////////////////////////////////
//功 能：讀取M1卡一塊數據
//參數說明: addr[IN]：區塊位址
// p [OUT]：讀出的數據，16位元組
//返 回: 成功返回MI_OK
///////////////////////////////////////////////////////////////////// 
char PcdRead(u8   addr,u8 *p )
{
    char   status;
    u8   unLen;
    u8   i,ucComMF522Buf[MAXRLEN]; 

    ucComMF522Buf[0] = PICC_READ;
    ucComMF522Buf[1] = addr;
    CalulateCRC(ucComMF522Buf,2,&ucComMF522Buf[2]);
   
    status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,4,ucComMF522Buf,&unLen);
    if ((status == MI_OK) && (unLen == 0x90))
 //   {   memcpy(p , ucComMF522Buf, 16);   }
    {
        for (i=0; i<16; i++)
        {    *(p +i) = ucComMF522Buf[i];   }
    }
    else
    {   status = MI_ERR;   }
    
    return status;
}

/////////////////////////////////////////////////////////////////////
//功 能：寫資料到M1卡一塊
//參數說明: addr[IN]：區塊位址
// p [IN]：寫入的數據，16位元組
//返 回: 成功返回MI_OK
/////////////////////////////////////////////////////////////////////                  
char PcdWrite(u8 addr,u8 *p )
{
    char   status;
    u8   unLen;
    u8   i,ucComMF522Buf[MAXRLEN]; 
    
    ucComMF522Buf[0] = PICC_WRITE;
    ucComMF522Buf[1] = addr;
    CalulateCRC(ucComMF522Buf,2,&ucComMF522Buf[2]);
 
    status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,4,ucComMF522Buf,&unLen);

    if ((status != MI_OK) || (unLen != 4) || ((ucComMF522Buf[0] & 0x0F) != 0x0A))
    {   status = MI_ERR;   }
        
    if (status == MI_OK)
    {
        //memcpy(ucComMF522Buf, p , 16);
        for (i=0; i<16; i++)
        {    
        	ucComMF522Buf[i] = *(p +i);   
        }
        CalulateCRC(ucComMF522Buf,16,&ucComMF522Buf[16]);

        status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,18,ucComMF522Buf,&unLen);
        if ((status != MI_OK) || (unLen != 4) || ((ucComMF522Buf[0] & 0x0F) != 0x0A))
        {   status = MI_ERR;   }
    }
    
    return status;
}

/////////////////////////////////////////////////////////////////////
//功 能：指令卡進入休眠狀態
//返 回: 成功返回MI_OK
/////////////////////////////////////////////////////////////////////
char PcdHalt(void)
{
    u8   status;
    u8   unLen;
    u8   ucComMF522Buf[MAXRLEN]; 

    ucComMF522Buf[0] = PICC_HALT;
    ucComMF522Buf[1] = 0;
    CalulateCRC(ucComMF522Buf,2,&ucComMF522Buf[2]);
 
    status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,4,ucComMF522Buf,&unLen);

    return MI_OK;
}

/////////////////////////////////////////////////////////////////////
//用MF522计算CRC16函数
/////////////////////////////////////////////////////////////////////
void CalulateCRC(u8 *pIn ,u8   len,u8 *pOut )
{
    u8   i,n;
    ClearBitMask(DivIrqReg,0x04);
    WriteRawRC(CommandReg,PCD_IDLE);
    SetBitMask(FIFOLevelReg,0x80);
    for (i=0; i<len; i++)
    {   WriteRawRC(FIFODataReg, *(pIn +i));   }
    WriteRawRC(CommandReg, PCD_CALCCRC);
    i = 0xFF;
    do 
    {
        n = ReadRawRC(DivIrqReg);
        i--;
    }
    while ((i!=0) && !(n&0x04));
    pOut [0] = ReadRawRC(CRCResultRegL);
    pOut [1] = ReadRawRC(CRCResultRegM);
}

/////////////////////////////////////////////////////////////////////
//功 能：重設RC522
//返 回: 成功返回MI_OK
/////////////////////////////////////////////////////////////////////
char PcdReset(void)
{
	//PORTD|=(1<<RC522RST);
	//SET_RC522RST;
    GPIO_HIGH(RC522RST_GPIO_PORT,RC522RST_GPIO_PIN);
    //delay_ns(10);
    Delay_ms(1);
	//PORTD&=~(1<<RC522RST);
	//CLR_RC522RST;
    GPIO_LOW(RC522RST_GPIO_PORT,RC522RST_GPIO_PIN);
    //delay_ns(10);
    Delay_ms(1);
	//PORTD|=(1<<RC522RST);
	//SET_RC522RST;
    GPIO_HIGH(RC522RST_GPIO_PORT,RC522RST_GPIO_PIN);
    //delay_ns(10);
    Delay_ms(1);
    WriteRawRC(CommandReg,PCD_RESETPHASE);
    WriteRawRC(CommandReg,PCD_RESETPHASE);
    //delay_ns(10);
    Delay_ms(1);
    
    WriteRawRC(ModeReg,0x3D);            //和Mifare卡通讯，CRC初始值0x6363
    WriteRawRC(TReloadRegL,30);           
    WriteRawRC(TReloadRegH,0);
    WriteRawRC(TModeReg,0x8D);
    WriteRawRC(TPrescalerReg,0x3E);
	
    WriteRawRC(TxAutoReg,0x40);//必须要
   
    return MI_OK;
}
//////////////////////////////////////////////////////////////////////
//设置RC632的工作方式 
//////////////////////////////////////////////////////////////////////
char M500PcdConfigISOType(u8   type)
{
   if (type == 'A')                     //ISO14443_A
   { 
      ClearBitMask(Status2Reg,0x08);
      WriteRawRC(ModeReg,0x3D);//3F
      WriteRawRC(RxSelReg,0x86);//84
      WriteRawRC(RFCfgReg,0x7F);   //4F
      WriteRawRC(TReloadRegL,30);//tmoLength);// TReloadVal = 'h6a =tmoLength(dec) 
      WriteRawRC(TReloadRegH,0);
      WriteRawRC(TModeReg,0x8D);
      WriteRawRC(TPrescalerReg,0x3E);
      //delay_ns(1000);
      Delay_ms(1);
      PcdAntennaOn();
   }
   else
   {
     return 1; 
   }
   
   return MI_OK;
}
/////////////////////////////////////////////////////////////////////
//功 能：讀RC532暫存器
//參數說明：Address[IN]:暫存器位址
//返 回：讀出的值
/////////////////////////////////////////////////////////////////////
u8 ReadRawRC(u8   Address)
{
    u8   ucAddr;
    u8   ucResult=0;
    //	CLR_SPI_CS;
    GPIO_LOW(RC522NSS_GPIO_PORT,RC522NSS_GPIO_PIN);
    ucAddr = ((Address<<1)&0x7E)|0x80;
        
    SPIWriteByte(ucAddr);
    ucResult=SPIReadByte();
    //	SET_SPI_CS;
    GPIO_HIGH(RC522NSS_GPIO_PORT,RC522NSS_GPIO_PIN);
    return ucResult;
}

/////////////////////////////////////////////////////////////////////
//功 能：寫RC632暫存器
//參數說明：Address[IN]:暫存器位址
// value[IN]:寫入的值
/////////////////////////////////////////////////////////////////////
void WriteRawRC(u8   Address, u8   value)
{  
    u8   ucAddr;

    GPIO_LOW(RC522NSS_GPIO_PORT,RC522NSS_GPIO_PIN);
    ucAddr = ((Address<<1)&0x7E);

    SPIWriteByte(ucAddr);
    SPIWriteByte(value);

    GPIO_HIGH(RC522NSS_GPIO_PORT,RC522NSS_GPIO_PIN);

}
/////////////////////////////////////////////////////////////////////
//功 能：置RC522暫存器位
//參數說明：reg[IN]:暫存器位址
// mask[IN]:置位值
/////////////////////////////////////////////////////////////////////
void SetBitMask(u8   reg,u8   mask)  
{
    char   tmp = 0x0;
    tmp = ReadRawRC(reg);
    WriteRawRC(reg,tmp | mask);  // set bit mask
}

/////////////////////////////////////////////////////////////////////
//功 能：清RC522暫存器位
//參數說明：reg[IN]:暫存器位址
// mask[IN]:清位元值
/////////////////////////////////////////////////////////////////////
void ClearBitMask(u8   reg,u8   mask)  
{
    char   tmp = 0x0;
    tmp = ReadRawRC(reg);
    WriteRawRC(reg, tmp & ~mask);  // clear bit mask
} 

/////////////////////////////////////////////////////////////////////
//功 能：透過RC522及ISO14443卡通訊
//參數說明：Command[IN]:RC522指令字
// pIn [IN]:透過RC522傳送到卡片的數據
// InLenByte[IN]:傳送資料的位元組長度
// pOut [OUT]:接收到的卡片回傳數據
// *pOutLenBit[OUT]:傳回資料的位元長度
/////////////////////////////////////////////////////////////////////
char PcdComMF522(u8   Command, 
                 u8 *pIn , 
                 u8   InLenByte,
                 u8 *pOut , 
                 u8 *pOutLenBit)
{
    char   status = MI_ERR;
    u8   irqEn   = 0x00;
    u8   waitFor = 0x00;
    u8   lastBits;
    u8   n;
    u16   i;
    switch (Command)
    {
        case PCD_AUTHENT:
                irqEn   = 0x12;
                waitFor = 0x10;
                break;
        case PCD_TRANSCEIVE:
                irqEn   = 0x77;
                waitFor = 0x30;
                break;
        default:
                break;
    }
   
    WriteRawRC(ComIEnReg,irqEn|0x80);
    ClearBitMask(ComIrqReg,0x80);	//清所有中断位
    WriteRawRC(CommandReg,PCD_IDLE);
    SetBitMask(FIFOLevelReg,0x80);	 	//清FIFO
    
    for (i=0; i<InLenByte; i++)
    {   
      WriteRawRC(FIFODataReg, pIn [i]);    
    }
    WriteRawRC(CommandReg, Command);	  
//   	 n = ReadRawRC(CommandReg);
    
    if (Command == PCD_TRANSCEIVE)
    {    
      SetBitMask(BitFramingReg,0x80);           //開始傳送
    }	 
    										 
    //i = 600;//根據時脈頻率調整，操作M1卡最大等待時間25ms
    i = 10000;
    do 
    {
        n = ReadRawRC(ComIrqReg);
        i--;
    }
    while ((i!=0) && !(n&0x01) && !(n&waitFor));
    ClearBitMask(BitFramingReg,0x80);

    if (i!=0)
    {    
        if(!(ReadRawRC(ErrorReg)&0x1B))
        {
            status = MI_OK;
            if (n & irqEn & 0x01)
            {   
              status = MI_NOTAGERR;   
            }
            if (Command == PCD_TRANSCEIVE)
            {
               	n = ReadRawRC(FIFOLevelReg);
              	lastBits = ReadRawRC(ControlReg) & 0x07;
                if (lastBits)
                {   
                  *pOutLenBit = (n-1)*8 + lastBits;   
                }
                else
                {   
                  *pOutLenBit = n*8;   
                }
                if (n == 0)
                {  
                  n = 1;    
                }
                if (n > MAXRLEN)
                {   
                  n = MAXRLEN;   
                }
                for (i=0; i<n; i++)
                {   
                  pOut[i] = ReadRawRC(FIFODataReg);    
                }
            }
        }
        else
        {   
          status = MI_ERR;   
        }
        
    }
   

    SetBitMask(ControlReg,0x80);           // stop timer now
    WriteRawRC(CommandReg,PCD_IDLE); 
    return status;
}

/////////////////////////////////////////////////////////////////////
//關閉天線 
//每次啟動或關閉天險發射之間應至少有1ms的間隔
/////////////////////////////////////////////////////////////////////
void PcdAntennaOn(void)
{
    u8   i;
    i = ReadRawRC(TxControlReg);
    if (!(i & 0x03))
    {
        SetBitMask(TxControlReg, 0x03);
    }
}


/////////////////////////////////////////////////////////////////////
//關閉天線
/////////////////////////////////////////////////////////////////////
void PcdAntennaOff(void)
{
	ClearBitMask(TxControlReg, 0x03);
}

/////////////////////////////////////////////////////////////////////
//功 能：扣款與儲值
//參數說明: dd_mode[IN]：命令字
// 0xC0 = 扣款
// 0xC1 = 儲值
// addr[IN]：錢包位址
// pValue[IN]：4位元組增(減)值，低位在前
//返 回: 成功返回MI_OK
/////////////////////////////////////////////////////////////////////                 
char PcdValue(u8 dd_mode,u8 addr,u8 *pValue)
{
    char status;
    u8  unLen;
    u8 ucComMF522Buf[MAXRLEN]; 
    //u8 i;
	
    ucComMF522Buf[0] = dd_mode;
    ucComMF522Buf[1] = addr;
    CalulateCRC(ucComMF522Buf,2,&ucComMF522Buf[2]);
 
    status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,4,ucComMF522Buf,&unLen);

    if ((status != MI_OK) || (unLen != 4) || ((ucComMF522Buf[0] & 0x0F) != 0x0A))
    {   
      status = MI_ERR;   
    }
        
    if (status == MI_OK)
    {
        memcpy(ucComMF522Buf, pValue, 4);
        //for (i=0; i<16; i++)
        //{    ucComMF522Buf[i] = *(pValue+i);   }
        CalulateCRC(ucComMF522Buf,4,&ucComMF522Buf[4]);
        unLen = 0;
        status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,6,ucComMF522Buf,&unLen);
		if (status != MI_ERR)
        {    status = MI_OK;    }
    }
    
    if (status == MI_OK)
    {
        ucComMF522Buf[0] = PICC_TRANSFER;
        ucComMF522Buf[1] = addr;
        CalulateCRC(ucComMF522Buf,2,&ucComMF522Buf[2]); 
   
        status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,4,ucComMF522Buf,&unLen);

        if ((status != MI_OK) || (unLen != 4) || ((ucComMF522Buf[0] & 0x0F) != 0x0A))
        {   status = MI_ERR;   }
    }
    return status;
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

void showcard(u8 Tx_Buffer[64],u8 *set,unsigned char *rc522)
{
	unsigned char status;
	status = PcdRequest(PICC_REQIDL,CT); 
	if (status==MI_OK)
    {
        status = PcdAnticoll(SN); 
    }
	if (status==MI_OK)
    {
        status = PcdSelect(SN);
    }
	if (status==MI_OK)
    {
        cardNo2String(SN, Tx_Buffer);
        *set=1;
        rc522[0]=SN[0];
        rc522[1]=SN[1];
        rc522[2]=SN[2];
        rc522[3]=SN[3];
        status=PcdAuthState(0x60,3,key,SN);
    }
    if (status==MI_OK)
    {
        status = PcdHalt();
    }
}