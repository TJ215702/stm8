#include "stm8s.h"

/* ============================================================
 * RC522 GPIO definition
 * ============================================================ */
#define RC522RST_GPIO_PORT                   GPIOC
#define RC522NSS_GPIO_PORT                   GPIOC
#define RC522RST_GPIO_PIN                    GPIO_PIN_3
#define RC522NSS_GPIO_PIN                    GPIO_PIN_4

#define GPIO_HIGH(a,b)       a->ODR |=  (b)
#define GPIO_LOW(a,b)        a->ODR &= ~(b)
#define GPIO_TOGGLE(a,b)     a->ODR ^=  (b)

/* ============================================================
 * MFRC522 command definitions
 * ============================================================ */
#define PCD_IDLE              0x00   // Cancel current command
#define PCD_AUTHENT           0x0E   // Authentication
#define PCD_RECEIVE           0x08   // Receive data
#define PCD_TRANSMIT          0x04   // Transmit data
#define PCD_TRANSCEIVE        0x0C   // Transmit and receive data
#define PCD_RESETPHASE        0x0F   // Reset
#define PCD_CALCCRC           0x03   // CRC calculation

/* ============================================================
 * MIFARE Classic (MIFARE One) card command codes
 * ============================================================ */
#define PICC_REQIDL           0x26   // Request cards not in HALT state
#define PICC_REQALL           0x52   // Request all cards in antenna field
#define PICC_ANTICOLL1        0x93   // Anti-collision (cascade level 1)
#define PICC_ANTICOLL2        0x95   // Anti-collision (cascade level 2)
#define PICC_AUTHENT1A        0x60   // Authenticate with Key A
#define PICC_AUTHENT1B        0x61   // Authenticate with Key B
#define PICC_READ             0x30   // Read block
#define PICC_WRITE            0xA0   // Write block
#define PICC_DECREMENT        0xC0   // Decrement (debit)
#define PICC_INCREMENT        0xC1   // Increment (credit)
#define PICC_RESTORE          0xC2   // Restore block data to buffer
#define PICC_TRANSFER         0xB0   // Transfer buffer data to block
#define PICC_HALT             0x50   // Halt card

/* ============================================================
 * MFRC522 FIFO length definition
 * ============================================================ */
#define DEF_FIFO_LENGTH       64     // FIFO size = 64 bytes
#define MAXRLEN               18

/* ============================================================
 * MFRC522 register definitions
 * ============================================================ */
/* PAGE 0 */
#define RFU00                 0x00
#define CommandReg            0x01
#define ComIEnReg             0x02
#define DivlEnReg             0x03
#define ComIrqReg             0x04
#define DivIrqReg             0x05
#define ErrorReg              0x06
#define Status1Reg            0x07
#define Status2Reg            0x08
#define FIFODataReg           0x09
#define FIFOLevelReg          0x0A
#define WaterLevelReg         0x0B
#define ControlReg            0x0C
#define BitFramingReg         0x0D
#define CollReg               0x0E
#define RFU0F                 0x0F

/* PAGE 1 */
#define RFU10                 0x10
#define ModeReg               0x11
#define TxModeReg             0x12
#define RxModeReg             0x13
#define TxControlReg          0x14
#define TxAutoReg             0x15
#define TxSelReg              0x16
#define RxSelReg              0x17
#define RxThresholdReg        0x18
#define DemodReg              0x19
#define RFU1A                 0x1A
#define RFU1B                 0x1B
#define MifareReg             0x1C
#define RFU1D                 0x1D
#define RFU1E                 0x1E
#define SerialSpeedReg        0x1F

/* PAGE 2 */
#define RFU20                 0x20
#define CRCResultRegM         0x21
#define CRCResultRegL         0x22
#define RFU23                 0x23
#define ModWidthReg           0x24
#define RFU25                 0x25
#define RFCfgReg              0x26
#define GsNReg                0x27
#define CWGsCfgReg            0x28
#define ModGsCfgReg           0x29
#define TModeReg              0x2A
#define TPrescalerReg         0x2B
#define TReloadRegH           0x2C
#define TReloadRegL           0x2D
#define TCounterValueRegH     0x2E
#define TCounterValueRegL     0x2F

/* PAGE 3 */
#define RFU30                 0x30
#define TestSel1Reg           0x31
#define TestSel2Reg           0x32
#define TestPinEnReg          0x33
#define TestPinValueReg       0x34
#define TestBusReg            0x35
#define AutoTestReg           0x36
#define VersionReg            0x37
#define AnalogTestReg         0x38
#define TestDAC1Reg           0x39
#define TestDAC2Reg           0x3A
#define TestADCReg            0x3B
#define RFU3C                 0x3C
#define RFU3D                 0x3D
#define RFU3E                 0x3E
#define RFU3F                 0x3F

/* ============================================================
 * MFRC522 return status codes
 * ============================================================ */
#define MI_OK                 0
#define MI_NOTAGERR           1
#define MI_ERR                2

/* ============================================================
 * Application command codes (custom)
 * ============================================================ */
#define SHAQU1                0x01
#define KUAI4                 0x04
#define KUAI7                 0x07
#define REGCARD               0xA1
#define CONSUME               0xA2
#define READCARD              0xA3
#define ADDMONEY              0xA4

/* ============================================================
 * SPI interface
 * ============================================================ */
#define SPIReadByte()         SPIWriteByte(0)

u8  SPIWriteByte(u8 byte);
void SPI2_Init(void);

#define SET_SPI_CS            (GPIOB->BSRR = 0x01)
#define CLR_SPI_CS            (GPIOB->BRR  = 0x01)

#define SET_RC522RST          (GPIOB->BSRR = 0x02)
#define CLR_RC522RST          (GPIOB->BRR  = 0x02)

/* ============================================================
 * RC522 function prototypes
 * ============================================================ */
void InitRc522(void);
void ClearBitMask(u8 reg, u8 mask);
void WriteRawRC(u8 Address, u8 value);
void SetBitMask(u8 reg, u8 mask);
char PcdComMF522(u8 Command,
                 u8 *pIn,
                 u8 InLenByte,
                 u8 *pOut,
                 u8 *pOutLenBit);
void CalulateCRC(u8 *pIn, u8 len, u8 *pOut);
u8   ReadRawRC(u8 Address);

char PcdReset(void);
char PcdRequest(unsigned char req_code, unsigned char *pTagType);
void PcdAntennaOn(void);
void PcdAntennaOff(void);
char M500PcdConfigISOType(unsigned char type);
char PcdAnticoll(unsigned char *pSnr);
char PcdSelect(unsigned char *pSnr);
char PcdAuthState(unsigned char auth_mode, unsigned char addr,
                  unsigned char *pKey, unsigned char *pSnr);
char PcdWrite(unsigned char addr, unsigned char *pData);
char PcdRead(unsigned char addr, unsigned char *pData);
char PcdHalt(void);
void Reset_RC522(void);
char PcdValue(u8 dd_mode, u8 addr, u8 *pValue);

/* ============================================================
 * Utility functions
 * ============================================================ */
void chipSet(u8 chip);
void Hex2String(u8 hex, u8 *str);
void cardNo2String(u8 *cardNo, u8 *str);
void showcard(u8 *, u8 *);
