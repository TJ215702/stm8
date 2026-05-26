/* MAIN.C file
 * 
 * Copyright (c) 2002-2005 STMicroelectronics
 */
#include "stm8s.h"
#include "stm8s_conf.h"
#include "uart.h"
#include "rc522.h"
#include "lf_send.h"
#include <string.h>


unsigned char RFFull = 0;
unsigned char RFBit;
unsigned char LL_w = 0;
unsigned char First_flag = 0;
unsigned char Buff_B[8];
unsigned char RF_UartSend[10];
unsigned char secure_key[10];
u8 RF_set=0;
unsigned char BitCount;
unsigned char Time_1ms = 0;

/* Key cache in RAM (loaded from EEPROM before halt) */
uint8_t cached_key_count = 0;
uint8_t cached_keys[5][16];  // 5 x 16 bytes

#define RF_LEN       64
const uint8_t Secret_Key[8] = {0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0};


void RF_Remote(uint8_t);

enum pke_oper_state {
    PKE_OPER_STA_POWER_OFF,
    PKE_OPER_STA_POWER_ON,
    PKE_OPER_STA_WAIT,
    PKE_OPER_STA_IDLE,
    PKE_OPER_STA_LEARN,
    PKE_OPER_STA_BUSY,
    PKE_OPER_STA_ERROR
};

volatile struct PKE_config {
    uint8_t key_num;
    uint8_t rc522_num;
    volatile uint8_t oper_state;
    volatile uint8_t power_event_flag;
    volatile uint8_t learn_event_flag;
} TJTW_PKE;

#define BR_LIGHT_ON()      GPIO_WriteHigh(GPIOD, GPIO_PIN_3)
#define BR_LIGHT_OFF()     GPIO_WriteLow(GPIOD, GPIO_PIN_3)

#define BZ_ON()      GPIO_WriteHigh(GPIOB, GPIO_PIN_1)
#define BZ_OFF()     GPIO_WriteLow(GPIOB, GPIO_PIN_1)

#define LP_RIGHT_ON()      GPIO_WriteHigh(GPIOB, GPIO_PIN_3)
#define LP_RIGHT_OFF()     GPIO_WriteLow(GPIOB, GPIO_PIN_3)

#define MOTOR2_ON()     GPIO_WriteHigh(GPIOC, GPIO_PIN_2)
#define MOTOR2_OFF()    GPIO_WriteLow(GPIOC, GPIO_PIN_2)

#define MOTOR1_ON()     GPIO_WriteHigh(GPIOB, GPIO_PIN_0)
#define MOTOR1_OFF()    GPIO_WriteLow(GPIOB, GPIO_PIN_0)

#define MOTOR_FWD()  do{MOTOR1_ON(); MOTOR2_OFF();}while(0)
#define MOTOR_REV()  do{MOTOR1_OFF(); MOTOR2_ON();}while(0)
#define MOTOR_STOP() do{MOTOR1_OFF(); MOTOR2_OFF();}while(0)

#define RF_DATA_LOW()        (GPIO_ReadInputPin(GPIOD, GPIO_PIN_0) == RESET)   //RESET=0

#define KEY_BLOCK_SIZE       16    // 4 (RFID) + 8 (full Buff_B, include CRC) + 2 (wake up)
#define MAX_KEY_NUM          5
#define KEY_DATA_START_ADDR  0x00004110
#define KEY_COUNT_ADDR       0x00004100

//for ign to count down by 10s
#define IGN_TIMEOUT_MS      10000UL
#define IGN_IS_ON()         (GPIO_ReadInputPin(GPIOB, GPIO_PIN_5) != RESET)  //SET=1
#define IGN_detect()         GPIO_ReadInputPin(GPIOB, GPIO_PIN_5)

#define MCU_REG_NUM      26
const uint8_t mcu_user_config[MCU_REG_NUM] =
{
    0xA5,0x5A,0x01,0x7D,0x80,0x00,0x00,0x01,
    0xC3,0x3A,0x0C,0x01,0x00,0x15,0x00,0x01,
    0x01,0x81,0x32,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,
};

u8 Tx_Buffer[] = "RFID---test";
#define  BufferSize (countof(Tx_Buffer)-1)

uint16_t Calculate_CRC16(uint8_t *ptr, uint8_t len, uint8_t ran) {
    uint16_t crc = 0xFFFF;
    uint8_t i, j;
    if (ran == 1)
        crc = 0xFFFF;
    else if (ran == 2)
        crc = 0x1234;

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

void Simple_Crypt(uint8_t *data, uint8_t len) {
    uint8_t i;
    for (i = 0; i < len; i++) {
        // 1. encrypt XOR with  Secret_Key
        data[i] ^= Secret_Key[i % 8];

        // 2. use not to increase complexity
        data[i] = ~data[i];

     // 3. (option) prevent consecutive identical characters.
        data[i] ^= i;
    }
}

void Clock_Config(void)
{
	
	//enable internal HSI clock(16MHZ)
	CLK_HSICmd(ENABLE);

	//make sure internal clock(HSI) is stable
	while (CLK_GetFlagStatus(CLK_FLAG_HSIRDY) == RESET);

	//set HSI DIV(High speed internal clock prescaler: 1)
	CLK_HSIPrescalerConfig(CLK_PRESCALER_HSIDIV1);
	CLK_PeripheralClockConfig(CLK_PERIPHERAL_SPI,   ENABLE);
    CLK_PeripheralClockConfig(CLK_PERIPHERAL_TIMER2, ENABLE);

}

void Clear_PKE_EEPROM(void)
{
    uint8_t i;

    FLASH_Unlock(FLASH_MEMTYPE_DATA);

    for (i = 0; i < 16; i++)
    {
        FLASH_ProgramByte(0x00004000 + i, 0x00);
    }

    FLASH_ProgramByte(0x00004100, 0x00);

    for (i = 0; i < 80; i++)
    {
        FLASH_ProgramByte(0x00004110 + i, 0x00);
    }

    FLASH_Lock(FLASH_MEMTYPE_DATA);
}

u8 Save_Combined_Key(uint8_t *rfid, uint8_t *rf433_full) {
    uint8_t num, i, k;
    uint16_t addr;
    uint8_t rfid_match, rf433_match,write_index;
    uint8_t existing_rfid[4];
    uint8_t existing_rf433[8];

    FLASH_Unlock(FLASH_MEMTYPE_DATA);
    num = FLASH_ReadByte(KEY_COUNT_ADDR);
    if (num > MAX_KEY_NUM)
        num = 0;

    // --- first：check exist or not ---
    for (i = 0; i < num; i++) {
        addr = KEY_DATA_START_ADDR + (i * KEY_BLOCK_SIZE);

        rfid_match = 1;
        rf433_match = 1;

        // check RFID is exist or not(4 bytes)
        for (k = 0; k < 4; k++) {
            if (FLASH_ReadByte(addr + k) != rfid[k]) {
                rfid_match = 0;
                break;
            }
        }

        // check 433M is exist or not (8 bytes, 含 CRC)
        for (k = 0; k < 8; k++) {
            if (FLASH_ReadByte(addr + 4 + k) != rf433_full[k]) {
                rf433_match = 0;
                break;
            }
        }

        // if any of them exist, abandon the write operation
        if (rfid_match || rf433_match) {
            UART2_SendStr("Key already exists! Skip saving.");
            FLASH_Lock(FLASH_MEMTYPE_DATA);
            return 1;
        }
    }

    // --- 第二部分：確定不存在，執行寫入 ---
    // 這裡我們採用循環覆蓋邏輯，若 num=5 則從 0 開始存
    write_index = (num >= MAX_KEY_NUM) ? 0 : num;
    addr = KEY_DATA_START_ADDR + (write_index * KEY_BLOCK_SIZE);

    // 寫入 RFID
    for (k = 0; k < 4; k++) {
        FLASH_ProgramByte(addr + k, rfid[k]);
    }
    // 寫入 433MHz (含 CRC 共 10 bytes) 最後2byte是8byte raw key的crc也是新的喚醒碼
    for (k = 0; k < 10; k++) {
        FLASH_ProgramByte(addr + 4 + k, rf433_full[k]);
    }

    // 更新數量 (如果還沒滿才增加，滿了就維持 MAX_KEY_NUM)
    if (num < MAX_KEY_NUM) {
        FLASH_ProgramByte(KEY_COUNT_ADDR, num + 1);
    }

    FLASH_Lock(FLASH_MEMTYPE_DATA);
    UART2_SendStr("New Key saved successfully.");
    return 0;
}


/* 20ms pulse */
static void motor_turn_on(void)
{
    MOTOR_FWD();
    Delay_ms(20);
    MOTOR_STOP();
}

static void motor_turn_off(void)
{
    MOTOR_REV();
    Delay_ms(20);
    MOTOR_STOP();
}

u8 Check_Combined_433M(uint8_t *target_rf433) {
    uint8_t i, k, match, num;
    uint16_t addr;

    FLASH_Unlock(FLASH_MEMTYPE_DATA);
    num = FLASH_ReadByte(KEY_COUNT_ADDR);
    if (num > MAX_KEY_NUM) num = MAX_KEY_NUM;

    for (i = 0; i < num; i++) {
        addr = KEY_DATA_START_ADDR + (i * KEY_BLOCK_SIZE);
        match = 1;
        // 從偏移量 +4 開始比對 8 bytes (含 CRC)
        for (k = 0; k < 8; k++) {
            if (FLASH_ReadByte(addr + 4 + k) != target_rf433[k]) {
                match = 0;
                break;
            }
        }
        if (match) {
            FLASH_Lock(FLASH_MEMTYPE_DATA);
            return 1;
        }
    }
    FLASH_Lock(FLASH_MEMTYPE_DATA);
    return 0;
}

u8 Check_Combined_RFID(uint8_t *target_rfid) {
    uint8_t i, k, match, num;
    uint16_t addr;

    FLASH_Unlock(FLASH_MEMTYPE_DATA);
    num = FLASH_ReadByte(KEY_COUNT_ADDR);
    if (num > MAX_KEY_NUM) num = MAX_KEY_NUM;

    for (i = 0; i < num; i++) {
        addr = KEY_DATA_START_ADDR + (i * KEY_BLOCK_SIZE);
        match = 1;
        // 從偏移量 +0 開始比對 4 bytes
        for (k = 0; k < 4; k++) {
            if (FLASH_ReadByte(addr + k) != target_rfid[k]) {
                match = 0;
                break;
            }
        }
        if (match) {
            FLASH_Lock(FLASH_MEMTYPE_DATA);
            return 1;
        }
    }
    FLASH_Lock(FLASH_MEMTYPE_DATA);
    return 0;
}

/* Load all keys from EEPROM to RAM cache before halt */
void Load_Keys_To_Cache(void) {
    uint8_t i, k;
    uint16_t addr;

    FLASH_Unlock(FLASH_MEMTYPE_DATA);

    /* Read key count */
    cached_key_count = FLASH_ReadByte(KEY_COUNT_ADDR);
    if (cached_key_count > MAX_KEY_NUM)
        cached_key_count = MAX_KEY_NUM;

    /* Load all keys (RFID + secure_key) to RAM */
    for (i = 0; i < cached_key_count; i++) {
        addr = KEY_DATA_START_ADDR + (i * KEY_BLOCK_SIZE);
        for (k = 0; k < KEY_BLOCK_SIZE; k++) {
            cached_keys[i][k] = FLASH_ReadByte(addr + k);
        }
    }

    FLASH_Lock(FLASH_MEMTYPE_DATA);
    UART2_SendStr("Keys loaded to RAM cache!");
}

/* Check 433M key against cached keys in RAM */
u8 Check_Combined_433M_Cached(uint8_t *target_rf433) {
    uint8_t i, k, match;

    for (i = 0; i < cached_key_count; i++) {
        match = 1;
        /* Compare from offset +4 (8 bytes of secure_key with CRC) */
        for (k = 0; k < 8; k++) {
            if (cached_keys[i][4 + k] != target_rf433[k]) {
                match = 0;
                break;
            }
        }
        if (match) {
            return 1;
        }
    }
    return 0;
}

static void GPIO_Config(void)
{

    GPIO_Init(GPIOD, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST); /* D3 BR_LIGHT */
    GPIO_Init(GPIOB, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST); /* B3 LP_RIGHT */
    GPIO_Init(GPIOC, GPIO_PIN_2, GPIO_MODE_OUT_PP_LOW_FAST); /* Motor IN2 */
    GPIO_Init(GPIOB, GPIO_PIN_0, GPIO_MODE_OUT_PP_LOW_FAST); /* Motor IN1 */
    GPIO_Init(GPIOB, GPIO_PIN_1, GPIO_MODE_OUT_PP_LOW_FAST); /* BZ */

    GPIO_Init(GPIOB, GPIO_PIN_4, GPIO_MODE_IN_PU_IT);  //POWER KEY
    GPIO_Init(GPIOA, GPIO_PIN_2, GPIO_MODE_IN_FL_NO_IT); //LEARN KEY
    GPIO_Init(GPIOB, GPIO_PIN_5, GPIO_MODE_IN_FL_NO_IT); //IGN KEY

    GPIO_Init(GPIOD, GPIO_PIN_2, GPIO_MODE_OUT_PP_HIGH_FAST); //syn531 default disable
    GPIO_Init(GPIOD, GPIO_PIN_0, GPIO_MODE_IN_PU_NO_IT);    //RF DO
    GPIO_Init(GPIOE, GPIO_PIN_5, GPIO_MODE_OUT_PP_LOW_FAST);  //125k enable

    /* init gpio status */
    BR_LIGHT_OFF();
    LP_RIGHT_OFF();
    MOTOR_STOP();
    BZ_OFF();
    GPIO_WriteLow (GPIOD, GPIO_PIN_2);  //syn531 enable
}

/* ================= EXTI ================= */

static void EXTI_Config(void)
{
    /* PORTB rising edge */
    EXTI_SetExtIntSensitivity(EXTI_PORT_GPIOB,
                              EXTI_SENSITIVITY_RISE_ONLY);
}

/* ================= ISR ================= */

INTERRUPT_HANDLER(EXTI_PORTB_IRQHandler, 4)
{
    TJTW_PKE.power_event_flag = 1;
}

void TIM2_Init(void)
{
    TIM2_DeInit();
    TIM2_TimeBaseInit(TIM2_PRESCALER_16,100);   /* 0.1ms */
    TIM2_ITConfig(TIM2_IT_UPDATE , ENABLE);
    TIM2_OC2Init(TIM2_OCMODE_PWM1, TIM2_OUTPUTSTATE_ENABLE, 0, TIM2_OCPOLARITY_HIGH);
    TIM2_OC2PreloadConfig(ENABLE);
    TIM2_SetCounter(0x0000);
    TIM2_Cmd(ENABLE);
		/* TIM2 IRQ13 highest priority (level 0) */
		ITC->ISPR4 &= (uint8_t)(~0x0C);
}


void RF_Remote(uint8_t level)
{
    unsigned char i;
    const char hex_chars[] = "0123456789ABCDEF";
    char hex_out[4];
    uint16_t received_crc, calculated_crc, final_crc;
    disableInterrupts();
    for (i = 0; i < 8; i++) {
        RF_UartSend[i] = Buff_B[i];
    }
    received_crc = ((uint16_t)RF_UartSend[6] << 8) | (uint16_t)RF_UartSend[7];
    calculated_crc = Calculate_CRC16(RF_UartSend, 6,1);

    RFFull = 0;
    if (level == 2) {
        /* POWER_ON: key should return secure key directly.
           Only validate and print received packet; do not derive again. */
        if (calculated_crc == received_crc ) {
            UART2_SendString("\r\nRF Data: ", 11);
            for (i = 0; i < 8; i++) {
                uint8_t val = RF_UartSend[i];
                hex_out[0] = hex_chars[(val >> 4) & 0x0F];
                hex_out[1] = hex_chars[val & 0x0F];
                hex_out[2] = ' ';
                UART2_SendString((unsigned char*)hex_out, 3);
            }
            RF_set = 1;
        } else {
            UART2_SendString("\r\nRF Data CRC/Header Error in POWER_ON! ", 40);
        }
    } else if (calculated_crc == received_crc && RF_UartSend[0] == 0x54 && RF_UartSend[1] == 0x4A) {
        RF_set = 1;
        UART2_SendString("\r\nRF Data: ", 11);
        for (i = 0; i < 8; i++) {
            uint8_t val = RF_UartSend[i];
            hex_out[0] = hex_chars[(val >> 4) & 0x0F];
            hex_out[1] = hex_chars[val & 0x0F];
            hex_out[2] = ' ';
            UART2_SendString((unsigned char*)hex_out, 3);
        }
        if(level ==1) {
            calculated_crc = Calculate_CRC16(RF_UartSend, 8, 2);
            RF_UartSend[8] = (uint8_t)(calculated_crc >> 8);   // CRC High
            RF_UartSend[9] = (uint8_t)(calculated_crc & 0xFF); // CRC Low
            memcpy(secure_key, RF_UartSend, 6);
            Simple_Crypt(secure_key, 6);
            final_crc = Calculate_CRC16(secure_key, 6, 1);
            secure_key[6] = (uint8_t)(final_crc >> 8);
            secure_key[7] = (uint8_t)(final_crc & 0xFF);
            secure_key[8] = (uint8_t)(calculated_crc >> 8);   // CRC High
            secure_key[9] = (uint8_t)(calculated_crc & 0xFF); // CRC Low

        }

    } else {
        if (calculated_crc != received_crc) {
            UART2_SendString("\r\nRF Data CRC Error! ", 22);
        } else {
            UART2_SendString("\r\nRF Data Header Error! ", 23);
        }
    }
    enableInterrupts();
    UART2_SendString("\r\n", 2);
}


@far @interrupt void tim2_irqhandler(void)
{
    /* Clear TIM2 update interrupt flag */
    TIM2_ClearITPendingBit(TIM2_IT_UPDATE);

    /* -------------------------------------------------------------
     * Time base: 1 ms tick and 10 ms tick
     * ------------------------------------------------------------- */
    Time_1ms++;

    if (Time_1ms >= 10)
    {
        Time_1ms = 0;

        /* LF send timer countdown (clamp to 0) */
        if ((LF_ENABLE == 1) && (LF_Send_Tim > 0))
            LF_Send_Tim--;
        else
            LF_Send_Tim = 0;
    }

    /* If an RF frame is already captured, skip decoding */
    if (RFFull)
        return;

    /* -------------------------------------------------------------
     * RF OOK decoding:
     * - Measure LOW pulse width (LL_w) while RF_DATA is low
     * - On rising edge (LOW -> HIGH), interpret the LOW width
     * ------------------------------------------------------------- */
    if (RF_DATA_LOW())
    {
        /* Accumulate LOW width in ticks */
        LL_w++;
        RFBit = 0;   /* Mark current level as LOW */
    }
    else
    {
        /* Rising edge: process the LOW width that just ended */
        if (!RFBit)
        {
            if (!First_flag)
            {
                /* Detect sync/preamble LOW width */
               // if ((LL_w > 40) && (LL_w < 60))
							 if ((LL_w >= 35) && (LL_w <= 65)) // Relax the detection range of the sync header.
                {
                    First_flag = 1;
                    BitCount   = 0;
                    Buff_B[0] = Buff_B[1] = Buff_B[2] = 0;
                    Buff_B[3] = Buff_B[4] = Buff_B[5] = 0;
                    Buff_B[6] = Buff_B[7] = 0;
                }
            }
            else
            {
                /* Decode data bits by LOW width */
                //if ((LL_w > 3) && (LL_w <= 7))
								if ((LL_w >= 2) && (LL_w <= 7))  // Relax the lower limit of Bit 1 to 2 (enhance weak signal detection).
                {
                    /* Bit '1' */
                    if (BitCount < RF_LEN)
                    {
                        Buff_B[BitCount >> 3] <<= 1;
                        Buff_B[BitCount >> 3] |= 0x01;
                        BitCount++;
                    }
                }
                //else if ((LL_w >= 8) && (LL_w < 13))
								else if ((LL_w >= 8) && (LL_w <= 15)) // Relax the upper limit of Bit 0 to 15 (tolerate noise-extended waveforms)
                {
                    /* Bit '0' */
                    if (BitCount < RF_LEN)
                    {
                        Buff_B[BitCount >> 3] <<= 1;
                        BitCount++;
                    }
                }
                else
                {
                    /* Invalid width: reset decoder state */
                    First_flag = 0;
                    BitCount   = 0;
                }

                /* Frame complete */
                if (BitCount >= RF_LEN)
                {
                    BitCount   = 0;
                    First_flag = 0;
                    RFFull     = 1;
                }
            }

            /* Reset LOW width counter after processing */
            LL_w = 0;
        }

        RFBit = 1;   /* Mark current level as HIGH */
    }
}

void main()
{
    int i,ret,idle;
    uint8_t cfg_idx;
    uint8_t ign_wait = 0;
    u8 rfid_set=0;
    int wait_count = 0;

    uint16_t brightness = 0; // bright pwm (0 到 999)
    uint8_t up = 1;
    unsigned char rc522_SN[4];
    TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
    TJTW_PKE.power_event_flag = 0;
    TJTW_PKE.learn_event_flag = 0;
    idle=0;

    Clock_Config();
    GPIO_Config();
    EXTI_Config();
    TIM4_DeInit();
    TIM4_Init();
	//MX_TIM4_Init();
    Uart_Init();
    InitRc522();
    Delay_ms(100);
    //TIM2_PWM_Config();
    //Clear_PKE_EEPROM();

    LF_ClockOccurs(125);
    for (cfg_idx = 0; cfg_idx < MCU_REG_NUM; cfg_idx++) {
        Set_Buff[cfg_idx] = mcu_user_config[cfg_idx];
    }
    LF_PLL_SET(LF_PLL);

    Delay_InIt(16);
    TIM2_Init();   //need ro mask  TIM2_PWM_Config()
    enableInterrupts();
    /* Load all keys to RAM cache before entering main loop */
    Load_Keys_To_Cache();
		
    UART2_SendStr("system start!");
		
    while(1)
    {
        // LF_SendData(PATTERN1,PATTERN2,PATTREN_BIT,LF_SEND_CH1);
        // Delay_ms(250);
        // if (RFFull) {
        //     RF_Remote();
        // }
       
        switch(TJTW_PKE.oper_state) {
            case PKE_OPER_STA_POWER_OFF:
                UART2_SendStr("PKE_OPER_STA_POWER_OFF in!");
                enableInterrupts();
                MOTOR_STOP();
                Delay_ms(50);
                motor_turn_off();  /* Turn off motor before halt */
                halt();
                Delay_ms(50);
                Clock_Config();
                GPIO_Config();
                TIM4_Init();
                Uart_Init();
                InitRc522();
                Delay_ms(50);

                if(TJTW_PKE.power_event_flag) {
                    TJTW_PKE.power_event_flag = 0;
                    /* Reload keys to cache after wake up */
                    Load_Keys_To_Cache();
                    if(GPIO_ReadInputPin(GPIOA, GPIO_PIN_2))
                    {
                        TJTW_PKE.oper_state = PKE_OPER_STA_LEARN;
                    }
                    else
                    {
                        TJTW_PKE.oper_state = PKE_OPER_STA_POWER_ON;
                    }
                }
                Uart_Init();
                UART2_SendStr("PKE_OPER_STA_POWER_OFF out!");
                break;
            case PKE_OPER_STA_POWER_ON:
                UART2_SendStr("PKE_OPER_STA_POWER_ON in!");
                enableInterrupts();
                i=0;
                ret=0;

                UART2_SendStr("check RFID key!");
                if (ret == 0) {
                    for(i=0;i<3;i++) {
                        Delay_ms(100);

                        showcard(Tx_Buffer,&rfid_set,rc522_SN);
                        Reset_RC522();
                        if(rfid_set ==1) {
                            UART2_SendString(Tx_Buffer, 17);
                            rfid_set=0;
                            i=50;
                            ret=Check_Combined_RFID(rc522_SN);
                        }
                    }
                }
								if (ret == 0) {
                    UART2_SendStr("Check 433m key!");
                    i = 0;
                    wait_count = 0;
                    while(i < cached_key_count) {
                        while(wait_count < 6) {  // 1. Increase retry count to 6 times to greatly improve long-range fault tolerance
                            
                            // 2. [Critical Fix] Before sending LF, forcibly clear the previous receive state and interrupt flags on the mainboard
                            disableInterrupts();
                            RFFull = 0;
                            First_flag = 0;
                            BitCount = 0;
                            memset(Buff_B, 0, sizeof(Buff_B)); // Clear receive buffer
                            enableInterrupts();

                            // 3. Send 125kHz LF wake-up signal
                            LF_SendData(cached_keys[i][12], cached_keys[i][13], PATTREN_BIT, LF_SEND_CH1, 0x01, 0x01);
                            
                            // 4. [Major Fix] Replace the original blocking 200ms delay with "segmented micro-delay dynamic monitoring"
                            // Check RFFull every 5ms, wait up to 250ms total.
                            // Once the KEY responds, the mainboard immediately reads and unlocks!
                            {
                                uint8_t delay_loop;
                                for(delay_loop = 0; delay_loop < 70; delay_loop++) {
                                    Delay_ms(5);
                                    if (RFFull) {
                                        break; // 433M data from KEY detected, exit waiting immediately
                                    }
                                }
                            }
                            
                            // 5. Start decoding and matching
                            if (RFFull) {
                                RF_Remote(2);
                                if (Check_Combined_433M_Cached(RF_UartSend)) {
                                    UART2_SendStr("433m key matched!");
                                    ret = 1;
                                    wait_count = 10;  /* Match successful, exit inner loop */
                                    break;
                                }
                                else {
                                    UART2_SendStr("433m key not matched or CRC error, retry...");
                                    RFFull = 0;  /* Clear status and allow next retry attempt */
                                }
                            }
                            wait_count++;
                        }

                        if(ret == 1) break;  /* Matching key found, exit outer polling loop */
                        wait_count = 0;      /* Reset counter and test next cached key */
                        i++;
                    }
                }
                if(ret == 1) {
                        motor_turn_on();
                        TJTW_PKE.oper_state = PKE_OPER_STA_WAIT;
                        ign_wait=0;
                } else {
                        LP_RIGHT_ON();
                        TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                        Delay_ms(500);
                        LP_RIGHT_OFF();
                }
                UART2_SendStr("PKE_OPER_STA_POWER_ON out!");
                break;
            case PKE_OPER_STA_WAIT:
                UART2_SendStr("PKE_OPER_STA_WAIT in!");
                if(IGN_IS_ON()) {  //ign on
                    TJTW_PKE.oper_state = PKE_OPER_STA_IDLE;
                    UART2_SendStr("IGN_ON PKE_OPER_STA_WAIT out!");
                }
                else {
                    if(ign_wait >=10) {
                        TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                        ign_wait=0;
                        motor_turn_off();
                        UART2_SendStr("PKE_OPER_STA_WAIT out!");
                    }
                    else {
                        Delay_ms(1000);
                        ign_wait++;
                    }
                }

                break;
            case PKE_OPER_STA_IDLE:
                if(idle==0) {
                    UART2_SendStr("PKE_OPER_STA_IDLE in!");
                    idle=1;
                    //TIM2_CCxCmd(TIM2_CHANNEL_2, ENABLE);
                    TIM2_CCxCmd(TIM2_CHANNEL_2, DISABLE);
                }
                //BR_PWM(&brightness, &up);
                //Delay_ms(10);
                BR_LIGHT_ON(); //blue
                if(TJTW_PKE.power_event_flag)
                {
                    TJTW_PKE.power_event_flag = 0;
                    motor_turn_off();  //Power OFF event => Motor off
                    TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                    TIM2_CCxCmd(TIM2_CHANNEL_2, DISABLE);
                    BR_LIGHT_OFF();
                    UART2_SendStr("PKE_OPER_STA_IDLE out!");
                    idle=0;
                }
                else if (!IGN_IS_ON()) {  //ign off
                    motor_turn_off();
                    TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                    TIM2_CCxCmd(TIM2_CHANNEL_2, DISABLE);
                    BR_LIGHT_OFF();
                    UART2_SendStr("IGN_OFF PKE_OPER_STA_IDLE out!");
                    idle=0;
                }
                break;
            case PKE_OPER_STA_LEARN:
                UART2_SendStr("PKE_OPER_STA_LEARN in!");
                TIM2_Init();
                TIM2_CCxCmd(TIM2_CHANNEL_2, DISABLE);
                GPIO_Init(GPIOD, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);
                enableInterrupts();
                for(i=0;i<25;i++) {
                    //BZ_ON();
                    LP_RIGHT_ON(); //red
                    BR_LIGHT_ON(); //blue
                    Delay_ms(100);
                    showcard(Tx_Buffer,&rfid_set,rc522_SN);
                    Reset_RC522();
                    if(rfid_set == 1) {
                        UART2_SendString(Tx_Buffer, 17);
                        i=50;
                    }
                    //BZ_OFF();
                    LP_RIGHT_OFF();
                    BR_LIGHT_OFF();
                    Delay_ms(100);
                }
                if(rfid_set == 1) {
                    UART2_SendStr("433m key learned!");
                    i=0;
                    while(i<16) {
                        BR_LIGHT_ON(); //blue
                        LF_SendData(0xc3,0x3a,PATTREN_BIT,LF_SEND_CH1, 0x01, 0x01);
                        Delay_ms(100);
                        BR_LIGHT_OFF();
                        Delay_ms(150);
                        if (RFFull) {
                            RF_Remote(1);
                            UART2_SendStr("Get 433m key!");
                            BR_LIGHT_OFF();
                            break;
                        }
                        i++;
                    }

                    if (RF_set == 1) {
                        LF_SendData(0xc3,0x3a, PATTREN_BIT, LF_SEND_CH1, RF_UartSend[8], RF_UartSend[9]);
                        ret = Save_Combined_Key(rc522_SN, secure_key);
                        if (ret > 0) {
                            UART2_SendStr("Add 2 keys to eeprom failed!");
                            /* Flash red light 500ms for failed save */
                            LP_RIGHT_ON();
                            Delay_ms(500);
                            LP_RIGHT_OFF();
                        }
                        else {
                            UART2_SendStr("Add 2 keys to eeprom!");
                            /* Reload keys to cache after new key saved */
                            Load_Keys_To_Cache();
                        }
                    }
                    else {
                        UART2_SendStr("433m key not learned!");
                        /* Flash red light 500ms for no 433m key */
                        LP_RIGHT_ON();
                        Delay_ms(500);
                        LP_RIGHT_OFF();
                    }
                }
                 else {
                    UART2_SendStr("RFID key not learned!");
                    /* Flash red light 500ms for no RFID key */
                    LP_RIGHT_ON();
                    Delay_ms(500);
                    LP_RIGHT_OFF();
                }

                RF_set=0;
                rfid_set=0;
                TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                UART2_SendStr("PKE_OPER_STA_LEARN out!");
                break;
            default:
                UART2_SendStr("Default state");
                TJTW_PKE.oper_state = PKE_OPER_STA_POWER_OFF;
                break;
        }

    }
}
