/********************  ********************

    |--------------------|
    |  SPI_MISO-PC7      |
    |  SPI_MOSI-PC6      |
    |  SPI_CLK--PC5      |
    |  SPI_CS---PE5      |
    |  RST ---  PC3      |
    |--------------------|


***********************************************************************************/

//#include "include.h"
#include "rc522.h"
#include "stm8s.h"
#include <string.h>

unsigned char CT[2];
unsigned char SN[4];
unsigned char key[6] = {0xff,0xff,0xff,0xff,0xff,0xff};

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
            SPI_CLOCKPOLARITY_HIGH, SPI_CLOCKPHASE_2EDGE, \
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
// Function: Card request (REQA / WUPA)
// Parameters:
//   req_code [IN] : Request command
//     0x52 = WUPA: Request all ISO/IEC 14443A cards in the field (including HALT cards)
//     0x26 = REQA: Request cards that are not in HALT state
//   pTagType [OUT]: Card type code (ATQA)
//     0x4400 = Mifare_UltraLight
//     0x0400 = Mifare_One (S50)
//     0x0200 = Mifare_One (S70)
//     0x0800 = Mifare_Pro (X)
//     0x4403 = Mifare_DESFire
// Return:
//   MI_OK on success
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
// Function: Anti-collision (UID acquisition)
// Parameters:
//   pSnr [OUT]: Card UID (4 bytes)
// Return:
//   MI_OK on success
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
// Function: Select card (UID selection)
// Parameters:
//   pSnr [IN]: Card UID (4 bytes)
// Return:
//   MI_OK on success
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
// Function: MIFARE Classic authentication
// Parameters:
//   auth_mode [IN]: Authentication command
//     0x60 = Key A authentication
//     0x61 = Key B authentication
//   addr [IN]: Block address
//   pKey [IN]: 6-byte secret key
//   pSnr [IN]: Card UID (4 bytes)
// Return:
//   MI_OK on success
/////////////////////////////////////////////////////////////////////
char PcdAuthState(u8 auth_mode,u8 addr,u8 *pKey,u8 *pSnr)
{
    char   status;
    u8   unLen;
    u8   ucComMF522Buf[MAXRLEN]; 

    ucComMF522Buf[0] = auth_mode;
    ucComMF522Buf[1] = addr;
    memcpy(&ucComMF522Buf[2], pKey, 6); 
    memcpy(&ucComMF522Buf[8], pSnr, 4); 
    
    status = PcdComMF522(PCD_AUTHENT,ucComMF522Buf,12,ucComMF522Buf,&unLen);
    if ((status != MI_OK) || (!(ReadRawRC(Status2Reg) & 0x08)))
    {   status = MI_ERR;   }
    
    return status;
}

/////////////////////////////////////////////////////////////////////
// Function: Read MIFARE Classic (M1) block
// Parameters:
//   addr [IN] : Block address
//   p    [OUT]: Output data buffer (16 bytes)
// Return:
//   MI_OK on success
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
// Function: Write MIFARE Classic (M1) block
// Parameters:
//   addr [IN] : Block address
//   p    [IN] : Input data buffer (16 bytes)
// Return:
//   MI_OK on success
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
// Function: Halt card (ISO/IEC 14443A HALT)
// Return:
//   MI_OK on success
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
// Function: Calculate CRC16 using the MFRC522 hardware CRC unit
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
// Function: Reset the MFRC522
// Return:
//   MI_OK on success
/////////////////////////////////////////////////////////////////////
char PcdReset(void)
{

    GPIO_HIGH(RC522RST_GPIO_PORT,RC522RST_GPIO_PIN);
    delay_ns(10);

    GPIO_LOW(RC522RST_GPIO_PORT,RC522RST_GPIO_PIN);
    delay_ns(10);

    GPIO_HIGH(RC522RST_GPIO_PORT,RC522RST_GPIO_PIN);
    delay_ns(10);
    WriteRawRC(CommandReg,PCD_RESETPHASE);
    WriteRawRC(CommandReg,PCD_RESETPHASE);
    delay_ns(10);
    
    WriteRawRC(ModeReg,0x3D);            // MIFARE card communication, CRC initial value set to 0x6363

    WriteRawRC(TReloadRegL,30);           
    WriteRawRC(TReloadRegH,0);
    WriteRawRC(TModeReg,0x8D);
    WriteRawRC(TPrescalerReg,0x3E);
	
    WriteRawRC(TxAutoReg,0x40);//// This step must not be omitted
   
    return MI_OK;
}

//////////////////////////////////////////////////////////////////////
// Function: Set RC632 operating mode
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
      delay_ns(1000);
      PcdAntennaOn();
   }
   else
   {
     return 1; 
   }
   
   return MI_OK;
}

/////////////////////////////////////////////////////////////////////
// Function: Read a register from RC532
// Parameters:
//   Address [IN]: Register address
// Return:
//   Register value
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
// Function: Write a register to RC632
// Parameters:
//   Address [IN]: Register address
//   value   [IN]: Register value
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
// Function: Set bit mask in RC522 register
// Parameters:
//   reg  [IN]: Register address
//   mask [IN]: Bit mask
/////////////////////////////////////////////////////////////////////
void SetBitMask(u8   reg,u8   mask)  
{
    char   tmp = 0x0;
    tmp = ReadRawRC(reg);
    WriteRawRC(reg,tmp | mask);  // set bit mask
}

/////////////////////////////////////////////////////////////////////
// Function: Clear bit mask in RC522 register
// Parameters:
//   reg  [IN]: Register address
//   mask [IN]: Bit mask
/////////////////////////////////////////////////////////////////////
void ClearBitMask(u8   reg,u8   mask)  
{
    char   tmp = 0x0;
    tmp = ReadRawRC(reg);
    WriteRawRC(reg, tmp & ~mask);  // clear bit mask
} 

/////////////////////////////////////////////////////////////////////
// Function: RC522 communication with ISO/IEC 14443 card
// Parameters:
//   Command     [IN] : RC522 command code
//   pIn         [IN] : Transmit data buffer
//   InLenByte   [IN] : Transmit length in bytes
//   pOut        [OUT]: Receive data buffer
//   *pOutLenBit [OUT]: Receive length in bits
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
    ClearBitMask(ComIrqReg,0x80);	// Clear all interrupt status flags
    WriteRawRC(CommandReg,PCD_IDLE);
    SetBitMask(FIFOLevelReg,0x80);	 	// Clear FIFO
    
    for (i=0; i<InLenByte; i++)
    {   
      WriteRawRC(FIFODataReg, pIn [i]);    
    }
    WriteRawRC(CommandReg, Command);	  
//   	 n = ReadRawRC(CommandReg);
    
    if (Command == PCD_TRANSCEIVE)
    {    
      SetBitMask(BitFramingReg,0x80);           // Start transmission
    }	 
    										 
    //i = 600;// Adjust according to clock frequency; maximum wait time for MIFARE Classic (M1) card operation is 25 ms

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
// Enable antenna
// There must be at least a 1 ms interval between enabling and disabling
// the antenna transmission
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
// Disable antenna
/////////////////////////////////////////////////////////////////////
void PcdAntennaOff(void)
{
	ClearBitMask(TxControlReg, 0x03);
}

/////////////////////////////////////////////////////////////////////
// Function: Debit / Credit (Value Block operation)
// Parameters:
//   dd_mode [IN]: Command code
//     0xC0 = Debit
//     0xC1 = Credit
//   addr    [IN]: Value block address
//   pValue  [IN]: 4-byte increment/decrement value (LSB first)
// Return:
//   MI_OK on success
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

void showcard(u8 Tx_Buffer[64],u8 *set)
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
			status=PcdAuthState(0x60,3,key,SN) ;  
		}  
	 if (status==MI_OK)
		{
			status = PcdHalt();
		}
}