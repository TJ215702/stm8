   1                     ; C Compiler for STM8 (COSMIC Software)
   2                     ; Parser V4.13.2 - 04 Jun 2024
   3                     ; Generator (Limited) V4.6.4 - 15 Jan 2025
  14                     	bsct
  15  0000               _RFFull:
  16  0000 00            	dc.b	0
  17  0001               _LL_w:
  18  0001 00            	dc.b	0
  19  0002               _First_flag:
  20  0002 00            	dc.b	0
  21  0003               _FLearn:
  22  0003 00            	dc.b	0
  23  0004               _COut:
  24  0004 0000          	dc.w	0
  25  0006               _CLearn:
  26  0006 0000          	dc.w	0
  27  0008               _CTLearn:
  28  0008 0000          	dc.w	0
  29  000a               _LF_Send_flag:
  30  000a 00            	dc.b	0
  31  000b               _Mode_Key_Old:
  32  000b 00            	dc.b	0
  33  000c               _Send_Key_Old:
  34  000c 00            	dc.b	0
  35  000d               _MLearn:
  36  000d 00            	dc.b	0
  37  000e               _CSend:
  38  000e 00            	dc.b	0
  39  000f               _Time_1ms:
  40  000f 00            	dc.b	0
  41  0010               _Time_Nms:
  42  0010 00            	dc.b	0
  43  0011               _User_LF_Send:
  44  0011 00            	dc.b	0
  45                     .const:	section	.text
  46  0000               _wCRCTalbeAbs:
  47  0000 0000          	dc.w	0
  48  0002 cc01          	dc.w	-13311
  49  0004 d801          	dc.w	-10239
  50  0006 1400          	dc.w	5120
  51  0008 f001          	dc.w	-4095
  52  000a 3c00          	dc.w	15360
  53  000c 2800          	dc.w	10240
  54  000e e401          	dc.w	-7167
  55  0010 a001          	dc.w	-24575
  56  0012 6c00          	dc.w	27648
  57  0014 7800          	dc.w	30720
  58  0016 b401          	dc.w	-19455
  59  0018 5000          	dc.w	20480
  60  001a 9c01          	dc.w	-25599
  61  001c 8801          	dc.w	-30719
  62  001e 4400          	dc.w	17408
  63  0020               _mcu_user_config:
  64  0020 a5            	dc.b	165
  65  0021 5a            	dc.b	90
  66  0022 01            	dc.b	1
  67  0023 7d            	dc.b	125
  68  0024 80            	dc.b	128
  69  0025 00            	dc.b	0
  70  0026 00            	dc.b	0
  71  0027 01            	dc.b	1
  72  0028 c3            	dc.b	195
  73  0029 3a            	dc.b	58
  74  002a 0c            	dc.b	12
  75  002b 01            	dc.b	1
  76  002c 00            	dc.b	0
  77  002d 15            	dc.b	21
  78  002e 00            	dc.b	0
  79  002f 01            	dc.b	1
  80  0030 01            	dc.b	1
  81  0031 81            	dc.b	129
  82  0032 32            	dc.b	50
  83  0033 00            	dc.b	0
  84  0034 00            	dc.b	0
  85  0035 00            	dc.b	0
  86  0036 00            	dc.b	0
  87  0037 00            	dc.b	0
  88  0038 00            	dc.b	0
  89  0039 00            	dc.b	0
 167                     ; 118 unsigned int GetCRC16(unsigned char *pchMsg, unsigned char wDataLen)
 167                     ; 119 { 
 169                     	switch	.text
 170  0000               _GetCRC16:
 172  0000 89            	pushw	x
 173  0001 5205          	subw	sp,#5
 174       00000005      OFST:	set	5
 177                     ; 120     unsigned int wCRC = 0xFFFF;
 179  0003 aeffff        	ldw	x,#65535
 180  0006 1f04          	ldw	(OFST-1,sp),x
 182                     ; 124     for (i = 0; i < wDataLen; i++)
 184  0008 5f            	clrw	x
 185  0009 1f01          	ldw	(OFST-4,sp),x
 188  000b 2055          	jra	L35
 189  000d               L74:
 190                     ; 126         chChar = *pchMsg++;
 192  000d 1e06          	ldw	x,(OFST+1,sp)
 193  000f 1c0001        	addw	x,#1
 194  0012 1f06          	ldw	(OFST+1,sp),x
 195  0014 1d0001        	subw	x,#1
 196  0017 f6            	ld	a,(x)
 197  0018 6b03          	ld	(OFST-2,sp),a
 199                     ; 127         wCRC = wCRCTalbeAbs[(chChar ^ wCRC) & 15] ^ (wCRC >> 4);
 201  001a 1e04          	ldw	x,(OFST-1,sp)
 202  001c 54            	srlw	x
 203  001d 54            	srlw	x
 204  001e 54            	srlw	x
 205  001f 54            	srlw	x
 206  0020 7b03          	ld	a,(OFST-2,sp)
 207  0022 1805          	xor	a,(OFST+0,sp)
 208  0024 a40f          	and	a,#15
 209  0026 905f          	clrw	y
 210  0028 9097          	ld	yl,a
 211  002a 9058          	sllw	y
 212  002c 01            	rrwa	x,a
 213  002d 90d80001      	xor	a,(_wCRCTalbeAbs+1,y)
 214  0031 01            	rrwa	x,a
 215  0032 90d80000      	xor	a,(_wCRCTalbeAbs,y)
 216  0036 01            	rrwa	x,a
 217  0037 1f04          	ldw	(OFST-1,sp),x
 219                     ; 128         wCRC = wCRCTalbeAbs[((chChar >> 4) ^ wCRC) & 15] ^ (wCRC >> 4);
 221  0039 1e04          	ldw	x,(OFST-1,sp)
 222  003b 54            	srlw	x
 223  003c 54            	srlw	x
 224  003d 54            	srlw	x
 225  003e 54            	srlw	x
 226  003f 7b03          	ld	a,(OFST-2,sp)
 227  0041 4e            	swap	a
 228  0042 a40f          	and	a,#15
 229  0044 1805          	xor	a,(OFST+0,sp)
 230  0046 a40f          	and	a,#15
 231  0048 905f          	clrw	y
 232  004a 9097          	ld	yl,a
 233  004c 9058          	sllw	y
 234  004e 01            	rrwa	x,a
 235  004f 90d80001      	xor	a,(_wCRCTalbeAbs+1,y)
 236  0053 01            	rrwa	x,a
 237  0054 90d80000      	xor	a,(_wCRCTalbeAbs,y)
 238  0058 01            	rrwa	x,a
 239  0059 1f04          	ldw	(OFST-1,sp),x
 241                     ; 124     for (i = 0; i < wDataLen; i++)
 243  005b 1e01          	ldw	x,(OFST-4,sp)
 244  005d 1c0001        	addw	x,#1
 245  0060 1f01          	ldw	(OFST-4,sp),x
 247  0062               L35:
 250  0062 7b0a          	ld	a,(OFST+5,sp)
 251  0064 5f            	clrw	x
 252  0065 97            	ld	xl,a
 253  0066 bf00          	ldw	c_x,x
 254  0068 1e01          	ldw	x,(OFST-4,sp)
 255  006a b300          	cpw	x,c_x
 256  006c 259f          	jrult	L74
 257                     ; 130     return wCRC;    
 259  006e 1e04          	ldw	x,(OFST-1,sp)
 262  0070 5b07          	addw	sp,#7
 263  0072 81            	ret
 290                     ; 133 void SystemClock_Init(void)
 290                     ; 134 {
 291                     	switch	.text
 292  0073               _SystemClock_Init:
 296                     ; 135     CLK_HSICmd(ENABLE);
 298  0073 a601          	ld	a,#1
 299  0075 cd0000        	call	_CLK_HSICmd
 302  0078               L17:
 303                     ; 136     while (CLK_GetFlagStatus(CLK_FLAG_HSIRDY) == RESET);
 305  0078 ae0102        	ldw	x,#258
 306  007b cd0000        	call	_CLK_GetFlagStatus
 308  007e 4d            	tnz	a
 309  007f 27f7          	jreq	L17
 310                     ; 137     CLK_HSIPrescalerConfig(CLK_PRESCALER_HSIDIV1);
 312  0081 4f            	clr	a
 313  0082 cd0000        	call	_CLK_HSIPrescalerConfig
 315                     ; 140     CLK_PeripheralClockConfig(CLK_PERIPHERAL_TIMER1, ENABLE);
 317  0085 ae0701        	ldw	x,#1793
 318  0088 cd0000        	call	_CLK_PeripheralClockConfig
 320                     ; 141     CLK_PeripheralClockConfig(CLK_PERIPHERAL_TIMER2, ENABLE);
 322  008b ae0501        	ldw	x,#1281
 323  008e cd0000        	call	_CLK_PeripheralClockConfig
 325                     ; 142 }
 328  0091 81            	ret
 356                     ; 144 void TIM2_Init(void)
 356                     ; 145 {
 357                     	switch	.text
 358  0092               _TIM2_Init:
 362                     ; 146     TIM2_DeInit();
 364  0092 cd0000        	call	_TIM2_DeInit
 366                     ; 147     TIM2_TimeBaseInit(TIM2_PRESCALER_16,100);   /* 0.1ms */
 368  0095 ae0064        	ldw	x,#100
 369  0098 89            	pushw	x
 370  0099 a604          	ld	a,#4
 371  009b cd0000        	call	_TIM2_TimeBaseInit
 373  009e 85            	popw	x
 374                     ; 148     TIM2_ITConfig(TIM2_IT_UPDATE , ENABLE);
 376  009f ae0101        	ldw	x,#257
 377  00a2 cd0000        	call	_TIM2_ITConfig
 379                     ; 149     TIM2_SetCounter(0x0000);
 381  00a5 5f            	clrw	x
 382  00a6 cd0000        	call	_TIM2_SetCounter
 384                     ; 150     TIM2_Cmd(ENABLE);
 386  00a9 a601          	ld	a,#1
 387  00ab cd0000        	call	_TIM2_Cmd
 389                     ; 151 }
 392  00ae 81            	ret
 441                     ; 153 void Read_EEpeomData(void)
 441                     ; 154 {
 442                     	switch	.text
 443  00af               _Read_EEpeomData:
 445  00af 521c          	subw	sp,#28
 446       0000001c      OFST:	set	28
 449                     ; 158     FLASH_Unlock(FLASH_MEMTYPE_DATA);
 451  00b1 a6f7          	ld	a,#247
 452  00b3 cd0000        	call	_FLASH_Unlock
 454                     ; 159     for (x = 0; x < SET_BUFF_MAX; x++)
 456  00b6 5f            	clrw	x
 457  00b7 1f1b          	ldw	(OFST-1,sp),x
 459  00b9               L721:
 460                     ; 160         EEprom_Buff[x] = FLASH_ReadByte(0x00004000 + x);
 462  00b9 1e1b          	ldw	x,(OFST-1,sp)
 463  00bb 1c4000        	addw	x,#16384
 464  00be cd0000        	call	c_uitolx
 466  00c1 be02          	ldw	x,c_lreg+2
 467  00c3 89            	pushw	x
 468  00c4 be00          	ldw	x,c_lreg
 469  00c6 89            	pushw	x
 470  00c7 cd0000        	call	_FLASH_ReadByte
 472  00ca 5b04          	addw	sp,#4
 473  00cc 96            	ldw	x,sp
 474  00cd 1c0001        	addw	x,#OFST-27
 475  00d0 72fb1b        	addw	x,(OFST-1,sp)
 476  00d3 f7            	ld	(x),a
 477                     ; 159     for (x = 0; x < SET_BUFF_MAX; x++)
 479  00d4 1e1b          	ldw	x,(OFST-1,sp)
 480  00d6 1c0001        	addw	x,#1
 481  00d9 1f1b          	ldw	(OFST-1,sp),x
 485  00db 1e1b          	ldw	x,(OFST-1,sp)
 486  00dd a3001a        	cpw	x,#26
 487  00e0 25d7          	jrult	L721
 488                     ; 161     FLASH_Lock(FLASH_MEMTYPE_DATA);
 490  00e2 a6f7          	ld	a,#247
 491  00e4 cd0000        	call	_FLASH_Lock
 493                     ; 163     if ((EEprom_Buff[0] == 0xA5) && (EEprom_Buff[1] == 0x5A)) 
 495  00e7 7b01          	ld	a,(OFST-27,sp)
 496  00e9 a1a5          	cp	a,#165
 497  00eb 2628          	jrne	L531
 499  00ed 7b02          	ld	a,(OFST-26,sp)
 500  00ef a15a          	cp	a,#90
 501  00f1 2622          	jrne	L531
 502                     ; 165         for (x = 0; x < SET_BUFF_MAX; x++)
 504  00f3 5f            	clrw	x
 505  00f4 1f1b          	ldw	(OFST-1,sp),x
 507  00f6               L731:
 508                     ; 166             Set_Buff[x] = EEprom_Buff[x];
 510  00f6 96            	ldw	x,sp
 511  00f7 1c0001        	addw	x,#OFST-27
 512  00fa 72fb1b        	addw	x,(OFST-1,sp)
 513  00fd f6            	ld	a,(x)
 514  00fe 1e1b          	ldw	x,(OFST-1,sp)
 515  0100 e700          	ld	(_Set_Buff,x),a
 516                     ; 165         for (x = 0; x < SET_BUFF_MAX; x++)
 518  0102 1e1b          	ldw	x,(OFST-1,sp)
 519  0104 1c0001        	addw	x,#1
 520  0107 1f1b          	ldw	(OFST-1,sp),x
 524  0109 1e1b          	ldw	x,(OFST-1,sp)
 525  010b a3001a        	cpw	x,#26
 526  010e 25e6          	jrult	L731
 527                     ; 167         LF_PLL_SET(LF_PLL);
 529  0110 b603          	ld	a,_Set_Buff+3
 530  0112 cd0000        	call	_LF_PLL_SET
 532  0115               L531:
 533                     ; 170     if (LF_ENABLE != 1)
 535  0115 b60c          	ld	a,_Set_Buff+12
 536  0117 a101          	cp	a,#1
 537  0119 2706          	jreq	L541
 538                     ; 171         Mode_LED_ON();
 540  011b 72125005      	bset	20485,#1
 542  011f 2004          	jra	L741
 543  0121               L541:
 544                     ; 173         Mode_LED_OFF();
 546  0121 72135005      	bres	20485,#1
 547  0125               L741:
 548                     ; 174 }  
 551  0125 5b1c          	addw	sp,#28
 552  0127 81            	ret
 590                     ; 176 void Write_EEpeomData(void)
 590                     ; 177 {
 591                     	switch	.text
 592  0128               _Write_EEpeomData:
 594  0128 88            	push	a
 595       00000001      OFST:	set	1
 598                     ; 180     FLASH_Unlock(FLASH_MEMTYPE_DATA);
 600  0129 a6f7          	ld	a,#247
 601  012b cd0000        	call	_FLASH_Unlock
 603                     ; 182     for (i = 0; i < MCU_REG_NUM; i++)
 605  012e 0f01          	clr	(OFST+0,sp)
 607  0130               L761:
 608                     ; 183         FLASH_ProgramByte(0x00004000 + i, mcu_user_config[i]);
 610  0130 7b01          	ld	a,(OFST+0,sp)
 611  0132 5f            	clrw	x
 612  0133 97            	ld	xl,a
 613  0134 d60020        	ld	a,(_mcu_user_config,x)
 614  0137 88            	push	a
 615  0138 7b02          	ld	a,(OFST+1,sp)
 616  013a 5f            	clrw	x
 617  013b 97            	ld	xl,a
 618  013c 1c4000        	addw	x,#16384
 619  013f cd0000        	call	c_itolx
 621  0142 be02          	ldw	x,c_lreg+2
 622  0144 89            	pushw	x
 623  0145 be00          	ldw	x,c_lreg
 624  0147 89            	pushw	x
 625  0148 cd0000        	call	_FLASH_ProgramByte
 627  014b 5b05          	addw	sp,#5
 628                     ; 182     for (i = 0; i < MCU_REG_NUM; i++)
 630  014d 0c01          	inc	(OFST+0,sp)
 634  014f 7b01          	ld	a,(OFST+0,sp)
 635  0151 a11a          	cp	a,#26
 636  0153 25db          	jrult	L761
 637                     ; 185     FLASH_Lock(FLASH_MEMTYPE_DATA);
 639  0155 a6f7          	ld	a,#247
 640  0157 cd0000        	call	_FLASH_Lock
 642                     ; 186 }
 645  015a 84            	pop	a
 646  015b 81            	ret
 681                     ; 188 void BEEP_BEEP(void)
 681                     ; 189 {
 682                     	switch	.text
 683  015c               _BEEP_BEEP:
 685  015c 88            	push	a
 686       00000001      OFST:	set	1
 689                     ; 192     for (i = 0; i < 100; i++)
 691  015d 0f01          	clr	(OFST+0,sp)
 693  015f               L312:
 694                     ; 194         BP_ON();
 696  015f 7218500f      	bset	20495,#4
 697                     ; 195         Delay_us(150);
 699  0163 ae0096        	ldw	x,#150
 700  0166 cd0000        	call	_Delay_us
 702                     ; 196         BP_OFF();
 704  0169 7219500f      	bres	20495,#4
 705                     ; 197         Delay_us(150);
 707  016d ae0096        	ldw	x,#150
 708  0170 cd0000        	call	_Delay_us
 710                     ; 192     for (i = 0; i < 100; i++)
 712  0173 0c01          	inc	(OFST+0,sp)
 716  0175 7b01          	ld	a,(OFST+0,sp)
 717  0177 a164          	cp	a,#100
 718  0179 25e4          	jrult	L312
 719                     ; 199 }
 722  017b 84            	pop	a
 723  017c 81            	ret
 756                     ; 203 void InIt(void)
 756                     ; 204 {
 757                     	switch	.text
 758  017d               _InIt:
 762                     ; 205     SystemClock_Init();
 764  017d cd0073        	call	_SystemClock_Init
 766                     ; 208     GPIO_Init(GPIOB, GPIO_PIN_1, GPIO_MODE_OUT_PP_LOW_FAST);  /* Mode LED  */
 768  0180 4be0          	push	#224
 769  0182 4b02          	push	#2
 770  0184 ae5005        	ldw	x,#20485
 771  0187 cd0000        	call	_GPIO_Init
 773  018a 85            	popw	x
 774                     ; 209     GPIO_Init(GPIOB, GPIO_PIN_2, GPIO_MODE_OUT_PP_LOW_FAST);  /* Learn LED */
 776  018b 4be0          	push	#224
 777  018d 4b04          	push	#4
 778  018f ae5005        	ldw	x,#20485
 779  0192 cd0000        	call	_GPIO_Init
 781  0195 85            	popw	x
 782                     ; 210     GPIO_Init(GPIOB, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);  /* Out LED   */
 784  0196 4be0          	push	#224
 785  0198 4b08          	push	#8
 786  019a ae5005        	ldw	x,#20485
 787  019d cd0000        	call	_GPIO_Init
 789  01a0 85            	popw	x
 790                     ; 211     GPIO_Init(GPIOD, GPIO_PIN_3, GPIO_MODE_OUT_PP_LOW_FAST);  /* Lfsend LED*/
 792  01a1 4be0          	push	#224
 793  01a3 4b08          	push	#8
 794  01a5 ae500f        	ldw	x,#20495
 795  01a8 cd0000        	call	_GPIO_Init
 797  01ab 85            	popw	x
 798                     ; 214     GPIO_Init(GPIOD, GPIO_PIN_4, GPIO_MODE_OUT_PP_LOW_FAST);
 800  01ac 4be0          	push	#224
 801  01ae 4b10          	push	#16
 802  01b0 ae500f        	ldw	x,#20495
 803  01b3 cd0000        	call	_GPIO_Init
 805  01b6 85            	popw	x
 806                     ; 217     GPIO_Init(GPIOB, GPIO_PIN_0, GPIO_MODE_OUT_PP_LOW_FAST);  /* 125K PWM (TIM1_CH1N) */
 808  01b7 4be0          	push	#224
 809  01b9 4b01          	push	#1
 810  01bb ae5005        	ldw	x,#20485
 811  01be cd0000        	call	_GPIO_Init
 813  01c1 85            	popw	x
 814                     ; 218     GPIO_Init(GPIOE, GPIO_PIN_5, GPIO_MODE_OUT_PP_LOW_FAST);  /* 125K_EN gate */
 816  01c2 4be0          	push	#224
 817  01c4 4b20          	push	#32
 818  01c6 ae5014        	ldw	x,#20500
 819  01c9 cd0000        	call	_GPIO_Init
 821  01cc 85            	popw	x
 822                     ; 221     GPIO_Init(GPIOD, GPIO_PIN_0, GPIO_MODE_IN_PU_NO_IT);      /* RF DO */
 824  01cd 4b40          	push	#64
 825  01cf 4b01          	push	#1
 826  01d1 ae500f        	ldw	x,#20495
 827  01d4 cd0000        	call	_GPIO_Init
 829  01d7 85            	popw	x
 830                     ; 222     GPIO_Init(GPIOD, GPIO_PIN_2, GPIO_MODE_OUT_PP_HIGH_FAST); /* SHDN¡A¹w³]Ãö³¬ */
 832  01d8 4bf0          	push	#240
 833  01da 4b04          	push	#4
 834  01dc ae500f        	ldw	x,#20495
 835  01df cd0000        	call	_GPIO_Init
 837  01e2 85            	popw	x
 838                     ; 225     GPIO_Init(GPIOA, GPIO_PIN_2, GPIO_MODE_IN_PU_NO_IT);      /* Learn Key */
 840  01e3 4b40          	push	#64
 841  01e5 4b04          	push	#4
 842  01e7 ae5000        	ldw	x,#20480
 843  01ea cd0000        	call	_GPIO_Init
 845  01ed 85            	popw	x
 846                     ; 226     GPIO_Init(GPIOB, GPIO_PIN_4, GPIO_MODE_IN_PU_NO_IT);      /* Mode Key  */
 848  01ee 4b40          	push	#64
 849  01f0 4b10          	push	#16
 850  01f2 ae5005        	ldw	x,#20485
 851  01f5 cd0000        	call	_GPIO_Init
 853  01f8 85            	popw	x
 854                     ; 227     GPIO_Init(GPIOB, GPIO_PIN_5, GPIO_MODE_IN_PU_NO_IT);      /* Lfsend Key*/
 856  01f9 4b40          	push	#64
 857  01fb 4b20          	push	#32
 858  01fd ae5005        	ldw	x,#20485
 859  0200 cd0000        	call	_GPIO_Init
 861  0203 85            	popw	x
 862                     ; 229     Delay_InIt(16);
 864  0204 a610          	ld	a,#16
 865  0206 cd0000        	call	_Delay_InIt
 867                     ; 230     TIM2_Init();
 869  0209 cd0092        	call	_TIM2_Init
 871                     ; 231     LF_ClockOccurs(125);                                      /* 125k carrier */
 873  020c a67d          	ld	a,#125
 874  020e cd0000        	call	_LF_ClockOccurs
 876                     ; 234     RF_SHDN_ENABLE();
 878  0211 4b04          	push	#4
 879  0213 ae500f        	ldw	x,#20495
 880  0216 cd0000        	call	_GPIO_WriteLow
 882  0219 84            	pop	a
 883                     ; 236     Write_EEpeomData();
 885  021a cd0128        	call	_Write_EEpeomData
 887                     ; 237     Read_EEpeomData();
 889  021d cd00af        	call	_Read_EEpeomData
 891                     ; 239     BEEP_BEEP();
 893  0220 cd015c        	call	_BEEP_BEEP
 895                     ; 240     enableInterrupts();
 898  0223 9a            rim
 900                     ; 241 }
 904  0224 81            	ret
1012                     ; 245 void RF_Remote(void)                  
1012                     ; 246 {
1013                     	switch	.text
1014  0225               _RF_Remote:
1016  0225 5214          	subw	sp,#20
1017       00000014      OFST:	set	20
1020                     ; 248     unsigned char HF_Key = 0;
1022                     ; 254     for (i = 0; i < RF_Byte_LEN; i++)
1024  0227 0f14          	clr	(OFST+0,sp)
1026  0229               L772:
1027                     ; 255         Buffer[i] = Buff_B[i];
1029  0229 96            	ldw	x,sp
1030  022a 1c0010        	addw	x,#OFST-4
1031  022d 9f            	ld	a,xl
1032  022e 5e            	swapw	x
1033  022f 1b14          	add	a,(OFST+0,sp)
1034  0231 2401          	jrnc	L42
1035  0233 5c            	incw	x
1036  0234               L42:
1037  0234 02            	rlwa	x,a
1038  0235 7b14          	ld	a,(OFST+0,sp)
1039  0237 905f          	clrw	y
1040  0239 9097          	ld	yl,a
1041  023b 90e601        	ld	a,(_Buff_B,y)
1042  023e f7            	ld	(x),a
1043                     ; 254     for (i = 0; i < RF_Byte_LEN; i++)
1045  023f 0c14          	inc	(OFST+0,sp)
1049  0241 7b14          	ld	a,(OFST+0,sp)
1050  0243 a103          	cp	a,#3
1051  0245 25e2          	jrult	L772
1052                     ; 257     HF_Key = Buffer[RF_Byte_LEN - 1] & 0x0F;
1054  0247 7b12          	ld	a,(OFST-2,sp)
1055  0249 a40f          	and	a,#15
1056  024b 6b0f          	ld	(OFST-5,sp),a
1058                     ; 258     Buffer[RF_Byte_LEN - 1] &= 0xF0;
1060  024d 7b12          	ld	a,(OFST-2,sp)
1061  024f a4f0          	and	a,#240
1062  0251 6b12          	ld	(OFST-2,sp),a
1064                     ; 260     for (i = 0; i < RF_Byte_LEN + 1; i++)
1066  0253 0f14          	clr	(OFST+0,sp)
1068  0255               L503:
1069                     ; 261         RF_UartSend[i + 2] = Buffer[i];    
1071  0255 96            	ldw	x,sp
1072  0256 1c0006        	addw	x,#OFST-14
1073  0259 9f            	ld	a,xl
1074  025a 5e            	swapw	x
1075  025b 1b14          	add	a,(OFST+0,sp)
1076  025d 2401          	jrnc	L62
1077  025f 5c            	incw	x
1078  0260               L62:
1079  0260 02            	rlwa	x,a
1080  0261 89            	pushw	x
1081  0262 96            	ldw	x,sp
1082  0263 1c0012        	addw	x,#OFST-2
1083  0266 9f            	ld	a,xl
1084  0267 5e            	swapw	x
1085  0268 1b16          	add	a,(OFST+2,sp)
1086  026a 2401          	jrnc	L03
1087  026c 5c            	incw	x
1088  026d               L03:
1089  026d 02            	rlwa	x,a
1090  026e f6            	ld	a,(x)
1091  026f 85            	popw	x
1092  0270 f7            	ld	(x),a
1093                     ; 260     for (i = 0; i < RF_Byte_LEN + 1; i++)
1095  0271 0c14          	inc	(OFST+0,sp)
1099  0273 7b14          	ld	a,(OFST+0,sp)
1100  0275 a104          	cp	a,#4
1101  0277 25dc          	jrult	L503
1102                     ; 263     RF_UartSend[0] = 0;
1104  0279 0f04          	clr	(OFST-16,sp)
1106                     ; 264     RF_UartSend[1] = 0;
1108  027b 0f05          	clr	(OFST-15,sp)
1110                     ; 265     RF_UartSend[2] = 0xFA; 
1112  027d a6fa          	ld	a,#250
1113  027f 6b06          	ld	(OFST-14,sp),a
1115                     ; 266     RF_UartSend[3] = 0xDD;
1117  0281 a6dd          	ld	a,#221
1118  0283 6b07          	ld	(OFST-13,sp),a
1120                     ; 267     for (i = 0; i < RF_Byte_LEN; i++)
1122  0285 0f14          	clr	(OFST+0,sp)
1124  0287               L313:
1125                     ; 268         RF_UartSend[4 + i] = Buffer[i];   
1127  0287 96            	ldw	x,sp
1128  0288 1c0008        	addw	x,#OFST-12
1129  028b 9f            	ld	a,xl
1130  028c 5e            	swapw	x
1131  028d 1b14          	add	a,(OFST+0,sp)
1132  028f 2401          	jrnc	L23
1133  0291 5c            	incw	x
1134  0292               L23:
1135  0292 02            	rlwa	x,a
1136  0293 89            	pushw	x
1137  0294 96            	ldw	x,sp
1138  0295 1c0012        	addw	x,#OFST-2
1139  0298 9f            	ld	a,xl
1140  0299 5e            	swapw	x
1141  029a 1b16          	add	a,(OFST+2,sp)
1142  029c 2401          	jrnc	L43
1143  029e 5c            	incw	x
1144  029f               L43:
1145  029f 02            	rlwa	x,a
1146  02a0 f6            	ld	a,(x)
1147  02a1 85            	popw	x
1148  02a2 f7            	ld	(x),a
1149                     ; 267     for (i = 0; i < RF_Byte_LEN; i++)
1151  02a3 0c14          	inc	(OFST+0,sp)
1155  02a5 7b14          	ld	a,(OFST+0,sp)
1156  02a7 a103          	cp	a,#3
1157  02a9 25dc          	jrult	L313
1158                     ; 269     RF_UartSend[RF_Byte_LEN + 4] = HF_Key;
1160  02ab 7b0f          	ld	a,(OFST-5,sp)
1161  02ad 6b0b          	ld	(OFST-9,sp),a
1163                     ; 271     crc = GetCRC16(&RF_UartSend[2], RF_Byte_LEN + 3);   
1165  02af 4b06          	push	#6
1166  02b1 96            	ldw	x,sp
1167  02b2 1c0007        	addw	x,#OFST-13
1168  02b5 cd0000        	call	_GetCRC16
1170  02b8 84            	pop	a
1171  02b9 1f02          	ldw	(OFST-18,sp),x
1173                     ; 272     RF_UartSend[RF_Byte_LEN + 5] = (uint8_t)(crc >> 8);
1175  02bb 7b02          	ld	a,(OFST-18,sp)
1176  02bd 6b0c          	ld	(OFST-8,sp),a
1178                     ; 273     RF_UartSend[RF_Byte_LEN + 6] = (uint8_t)(crc & 0xFF);   
1180  02bf 7b03          	ld	a,(OFST-17,sp)
1181  02c1 a4ff          	and	a,#255
1182  02c3 6b0d          	ld	(OFST-7,sp),a
1184                     ; 274     RF_UartSend[RF_Byte_LEN + 7] = 0xEE;	
1186  02c5 a6ee          	ld	a,#238
1187  02c7 6b0e          	ld	(OFST-6,sp),a
1189                     ; 276     RFFull = 0;                                
1191  02c9 3f00          	clr	_RFFull
1192                     ; 278     if (FLearn) 		                              
1194  02cb 3d03          	tnz	_FLearn
1195  02cd 2603          	jrne	L45
1196  02cf cc03af        	jp	L123
1197  02d2               L45:
1198                     ; 280         BP_ON();
1200  02d2 7218500f      	bset	20495,#4
1201                     ; 281         Delay_us(450);
1203  02d6 ae01c2        	ldw	x,#450
1204  02d9 cd0000        	call	_Delay_us
1206                     ; 282         BP_OFF();
1208  02dc 7219500f      	bres	20495,#4
1209                     ; 284         disableInterrupts();                          
1212  02e0 9b            sim
1214                     ; 285         FLASH_Unlock(FLASH_MEMTYPE_DATA);
1217  02e1 a6f7          	ld	a,#247
1218  02e3 cd0000        	call	_FLASH_Unlock
1220                     ; 287         for (i = 0; i < RF_NUM; i++)
1222  02e6 0f14          	clr	(OFST+0,sp)
1224  02e8               L323:
1225                     ; 289             for (j = 0; j < RF_Byte_LEN; j++)
1227  02e8 0f13          	clr	(OFST-1,sp)
1229  02ea               L133:
1230                     ; 291                 if (Buffer[j] != FLASH_ReadByte(0x00004000  + SET_BUFF_MAX + i * RF_Byte_LEN + j + 1))
1232  02ea 7b14          	ld	a,(OFST+0,sp)
1233  02ec 97            	ld	xl,a
1234  02ed a603          	ld	a,#3
1235  02ef 42            	mul	x,a
1236  02f0 01            	rrwa	x,a
1237  02f1 1b13          	add	a,(OFST-1,sp)
1238  02f3 2401          	jrnc	L63
1239  02f5 5c            	incw	x
1240  02f6               L63:
1241  02f6 02            	rlwa	x,a
1242  02f7 1c401b        	addw	x,#16411
1243  02fa cd0000        	call	c_itolx
1245  02fd be02          	ldw	x,c_lreg+2
1246  02ff 89            	pushw	x
1247  0300 be00          	ldw	x,c_lreg
1248  0302 89            	pushw	x
1249  0303 cd0000        	call	_FLASH_ReadByte
1251  0306 5b04          	addw	sp,#4
1252  0308 6b01          	ld	(OFST-19,sp),a
1254  030a 96            	ldw	x,sp
1255  030b 1c0010        	addw	x,#OFST-4
1256  030e 9f            	ld	a,xl
1257  030f 5e            	swapw	x
1258  0310 1b13          	add	a,(OFST-1,sp)
1259  0312 2401          	jrnc	L04
1260  0314 5c            	incw	x
1261  0315               L04:
1262  0315 02            	rlwa	x,a
1263  0316 f6            	ld	a,(x)
1264  0317 1101          	cp	a,(OFST-19,sp)
1265  0319 2608          	jrne	L533
1266                     ; 292                     break;
1268                     ; 289             for (j = 0; j < RF_Byte_LEN; j++)
1270  031b 0c13          	inc	(OFST-1,sp)
1274  031d 7b13          	ld	a,(OFST-1,sp)
1275  031f a103          	cp	a,#3
1276  0321 25c7          	jrult	L133
1277  0323               L533:
1278                     ; 294             if (j == RF_Byte_LEN)
1280  0323 7b13          	ld	a,(OFST-1,sp)
1281  0325 a103          	cp	a,#3
1282  0327 260f          	jrne	L143
1283                     ; 296                 CTLearn = 1000;
1285  0329 ae03e8        	ldw	x,#1000
1286  032c bf08          	ldw	_CTLearn,x
1287                     ; 297                 FLASH_Lock(FLASH_MEMTYPE_DATA);
1289  032e a6f7          	ld	a,#247
1290  0330 cd0000        	call	_FLASH_Lock
1292                     ; 298                 enableInterrupts();
1295  0333 9a            rim
1297                     ; 299                 return;
1300  0334 ac3e043e      	jpf	L25
1301  0338               L143:
1302                     ; 287         for (i = 0; i < RF_NUM; i++)
1304  0338 0c14          	inc	(OFST+0,sp)
1308  033a 7b14          	ld	a,(OFST+0,sp)
1309  033c a105          	cp	a,#5
1310  033e 25a8          	jrult	L323
1311                     ; 303         RF_num = FLASH_ReadByte(0x00004000 + SET_BUFF_MAX);
1313  0340 ae401a        	ldw	x,#16410
1314  0343 89            	pushw	x
1315  0344 ae0000        	ldw	x,#0
1316  0347 89            	pushw	x
1317  0348 cd0000        	call	_FLASH_ReadByte
1319  034b 5b04          	addw	sp,#4
1320  034d 6b0f          	ld	(OFST-5,sp),a
1322                     ; 304         if (RF_num > RF_NUM) RF_num = 0;        
1324  034f 7b0f          	ld	a,(OFST-5,sp)
1325  0351 a106          	cp	a,#6
1326  0353 2502          	jrult	L343
1329  0355 0f0f          	clr	(OFST-5,sp)
1331  0357               L343:
1332                     ; 306         for (i = 0; i < RF_Byte_LEN; i++)
1334  0357 0f14          	clr	(OFST+0,sp)
1336  0359               L543:
1337                     ; 307             FLASH_ProgramByte(0x00004000 + SET_BUFF_MAX + RF_num * RF_Byte_LEN + i + 1,Buffer[i]);
1339  0359 96            	ldw	x,sp
1340  035a 1c0010        	addw	x,#OFST-4
1341  035d 9f            	ld	a,xl
1342  035e 5e            	swapw	x
1343  035f 1b14          	add	a,(OFST+0,sp)
1344  0361 2401          	jrnc	L24
1345  0363 5c            	incw	x
1346  0364               L24:
1347  0364 02            	rlwa	x,a
1348  0365 f6            	ld	a,(x)
1349  0366 88            	push	a
1350  0367 7b10          	ld	a,(OFST-4,sp)
1351  0369 97            	ld	xl,a
1352  036a a603          	ld	a,#3
1353  036c 42            	mul	x,a
1354  036d 01            	rrwa	x,a
1355  036e 1b15          	add	a,(OFST+1,sp)
1356  0370 2401          	jrnc	L44
1357  0372 5c            	incw	x
1358  0373               L44:
1359  0373 02            	rlwa	x,a
1360  0374 1c401b        	addw	x,#16411
1361  0377 cd0000        	call	c_itolx
1363  037a be02          	ldw	x,c_lreg+2
1364  037c 89            	pushw	x
1365  037d be00          	ldw	x,c_lreg
1366  037f 89            	pushw	x
1367  0380 cd0000        	call	_FLASH_ProgramByte
1369  0383 5b05          	addw	sp,#5
1370                     ; 306         for (i = 0; i < RF_Byte_LEN; i++)
1372  0385 0c14          	inc	(OFST+0,sp)
1376  0387 7b14          	ld	a,(OFST+0,sp)
1377  0389 a103          	cp	a,#3
1378  038b 25cc          	jrult	L543
1379                     ; 309         RF_num = RF_num + 1;
1381  038d 0c0f          	inc	(OFST-5,sp)
1383                     ; 310         FLASH_ProgramByte(0x00004000 + SET_BUFF_MAX , RF_num);
1385  038f 7b0f          	ld	a,(OFST-5,sp)
1386  0391 88            	push	a
1387  0392 ae401a        	ldw	x,#16410
1388  0395 89            	pushw	x
1389  0396 ae0000        	ldw	x,#0
1390  0399 89            	pushw	x
1391  039a cd0000        	call	_FLASH_ProgramByte
1393  039d 5b05          	addw	sp,#5
1394                     ; 312         FLASH_Lock(FLASH_MEMTYPE_DATA);  
1396  039f a6f7          	ld	a,#247
1397  03a1 cd0000        	call	_FLASH_Lock
1399                     ; 314         Learn_LED_OFF();
1401  03a4 72155005      	bres	20485,#2
1402                     ; 315         FLearn = 0;
1404  03a8 3f03          	clr	_FLearn
1405                     ; 316         enableInterrupts();
1408  03aa 9a            rim
1412  03ab ac3e043e      	jpf	L353
1413  03af               L123:
1414                     ; 320         disableInterrupts();
1417  03af 9b            sim
1419                     ; 322         for (i = 0; i < RF_NUM; i++)
1422  03b0 0f14          	clr	(OFST+0,sp)
1424  03b2               L553:
1425                     ; 324             for (j = 0; j < RF_Byte_LEN; j++)
1427  03b2 0f13          	clr	(OFST-1,sp)
1429  03b4               L363:
1430                     ; 326                 if (Buffer[j] != FLASH_ReadByte(0x00004000  + SET_BUFF_MAX + i * RF_Byte_LEN + j + 1))
1432  03b4 7b14          	ld	a,(OFST+0,sp)
1433  03b6 97            	ld	xl,a
1434  03b7 a603          	ld	a,#3
1435  03b9 42            	mul	x,a
1436  03ba 01            	rrwa	x,a
1437  03bb 1b13          	add	a,(OFST-1,sp)
1438  03bd 2401          	jrnc	L64
1439  03bf 5c            	incw	x
1440  03c0               L64:
1441  03c0 02            	rlwa	x,a
1442  03c1 1c401b        	addw	x,#16411
1443  03c4 cd0000        	call	c_itolx
1445  03c7 be02          	ldw	x,c_lreg+2
1446  03c9 89            	pushw	x
1447  03ca be00          	ldw	x,c_lreg
1448  03cc 89            	pushw	x
1449  03cd cd0000        	call	_FLASH_ReadByte
1451  03d0 5b04          	addw	sp,#4
1452  03d2 6b01          	ld	(OFST-19,sp),a
1454  03d4 96            	ldw	x,sp
1455  03d5 1c0010        	addw	x,#OFST-4
1456  03d8 9f            	ld	a,xl
1457  03d9 5e            	swapw	x
1458  03da 1b13          	add	a,(OFST-1,sp)
1459  03dc 2401          	jrnc	L05
1460  03de 5c            	incw	x
1461  03df               L05:
1462  03df 02            	rlwa	x,a
1463  03e0 f6            	ld	a,(x)
1464  03e1 1101          	cp	a,(OFST-19,sp)
1465  03e3 2608          	jrne	L763
1466                     ; 327                     break; 			
1468                     ; 324             for (j = 0; j < RF_Byte_LEN; j++)
1470  03e5 0c13          	inc	(OFST-1,sp)
1474  03e7 7b13          	ld	a,(OFST-1,sp)
1475  03e9 a103          	cp	a,#3
1476  03eb 25c7          	jrult	L363
1477  03ed               L763:
1478                     ; 329             if (j == RF_Byte_LEN)
1480  03ed 7b13          	ld	a,(OFST-1,sp)
1481  03ef a103          	cp	a,#3
1482  03f1 263f          	jrne	L373
1483                     ; 331                 if (COut == 0)
1485  03f3 be04          	ldw	x,_COut
1486  03f5 2633          	jrne	L573
1487                     ; 333                     if ((HF_Key & 0x01) == 0x01)  Out_LED_ON();
1489  03f7 7b0f          	ld	a,(OFST-5,sp)
1490  03f9 a401          	and	a,#1
1491  03fb a101          	cp	a,#1
1492  03fd 2604          	jrne	L773
1495  03ff 72165005      	bset	20485,#3
1496  0403               L773:
1497                     ; 334                     if ((HF_Key & 0x02) == 0x02)  Out_LED_ON();
1499  0403 7b0f          	ld	a,(OFST-5,sp)
1500  0405 a402          	and	a,#2
1501  0407 a102          	cp	a,#2
1502  0409 2604          	jrne	L104
1505  040b 72165005      	bset	20485,#3
1506  040f               L104:
1507                     ; 335                     if ((HF_Key & 0x04) == 0x04)  Out_LED_ON();
1509  040f 7b0f          	ld	a,(OFST-5,sp)
1510  0411 a404          	and	a,#4
1511  0413 a104          	cp	a,#4
1512  0415 2604          	jrne	L304
1515  0417 72165005      	bset	20485,#3
1516  041b               L304:
1517                     ; 336                     if ((HF_Key & 0x08) == 0x08)  Out_LED_ON();
1519  041b 7b0f          	ld	a,(OFST-5,sp)
1520  041d a408          	and	a,#8
1521  041f a108          	cp	a,#8
1522  0421 2604          	jrne	L504
1525  0423 72165005      	bset	20485,#3
1526  0427               L504:
1527                     ; 337                     BEEP_BEEP();
1529  0427 cd015c        	call	_BEEP_BEEP
1531  042a               L573:
1532                     ; 339                 COut = TOUT;
1534  042a ae0258        	ldw	x,#600
1535  042d bf04          	ldw	_COut,x
1536                     ; 340                 enableInterrupts();
1539  042f 9a            rim
1541                     ; 341                 break;                   
1544  0430 200b          	jra	L163
1545  0432               L373:
1546                     ; 322         for (i = 0; i < RF_NUM; i++)
1548  0432 0c14          	inc	(OFST+0,sp)
1552  0434 7b14          	ld	a,(OFST+0,sp)
1553  0436 a105          	cp	a,#5
1554  0438 2403          	jruge	L65
1555  043a cc03b2        	jp	L553
1556  043d               L65:
1557  043d               L163:
1558                     ; 344         enableInterrupts();
1561  043d 9a            rim
1563  043e               L353:
1564                     ; 346 }
1565  043e               L25:
1568  043e 5b14          	addw	sp,#20
1569  0440 81            	ret
1614                     ; 350 void Key_Scan(void)           
1614                     ; 351 {
1615                     	switch	.text
1616  0441               _Key_Scan:
1618  0441 88            	push	a
1619       00000001      OFST:	set	1
1622                     ; 355     if (Learn_Key_Pressed()) 
1624  0442 4b04          	push	#4
1625  0444 ae5000        	ldw	x,#20480
1626  0447 cd0000        	call	_GPIO_ReadInputPin
1628  044a 5b01          	addw	sp,#1
1629  044c 4d            	tnz	a
1630  044d 2765          	jreq	L524
1631                     ; 357         CLearn++;
1633  044f be06          	ldw	x,_CLearn
1634  0451 1c0001        	addw	x,#1
1635  0454 bf06          	ldw	_CLearn,x
1636                     ; 358         if (CLearn == 10)
1638  0456 be06          	ldw	x,_CLearn
1639  0458 a3000a        	cpw	x,#10
1640  045b 260d          	jrne	L724
1641                     ; 360             Learn_LED_ON();
1643  045d 72145005      	bset	20485,#2
1644                     ; 361             FLearn  = 1;
1646  0461 35010003      	mov	_FLearn,#1
1647                     ; 362             CTLearn = 1000;
1649  0465 ae03e8        	ldw	x,#1000
1650  0468 bf08          	ldw	_CTLearn,x
1651  046a               L724:
1652                     ; 365         if (CLearn == 500)
1654  046a be06          	ldw	x,_CLearn
1655  046c a301f4        	cpw	x,#500
1656  046f 2646          	jrne	L154
1657                     ; 367             Learn_LED_OFF();
1659  0471 72155005      	bres	20485,#2
1660                     ; 368             FLearn = 0;
1662  0475 3f03          	clr	_FLearn
1663                     ; 370             FLASH_Unlock(FLASH_MEMTYPE_DATA);
1665  0477 a6f7          	ld	a,#247
1666  0479 cd0000        	call	_FLASH_Unlock
1668                     ; 371             for (i = 0; i < RF_NUM * RF_Byte_LEN + 1; i++)
1670  047c 0f01          	clr	(OFST+0,sp)
1672  047e               L334:
1673                     ; 372                 FLASH_ProgramByte(0x00004000 + SET_BUFF_MAX + i, 0);
1675  047e 4b00          	push	#0
1676  0480 7b02          	ld	a,(OFST+1,sp)
1677  0482 5f            	clrw	x
1678  0483 97            	ld	xl,a
1679  0484 1c401a        	addw	x,#16410
1680  0487 cd0000        	call	c_itolx
1682  048a be02          	ldw	x,c_lreg+2
1683  048c 89            	pushw	x
1684  048d be00          	ldw	x,c_lreg
1685  048f 89            	pushw	x
1686  0490 cd0000        	call	_FLASH_ProgramByte
1688  0493 5b05          	addw	sp,#5
1689                     ; 371             for (i = 0; i < RF_NUM * RF_Byte_LEN + 1; i++)
1691  0495 0c01          	inc	(OFST+0,sp)
1695  0497 7b01          	ld	a,(OFST+0,sp)
1696  0499 a110          	cp	a,#16
1697  049b 25e1          	jrult	L334
1698                     ; 373             FLASH_Lock(FLASH_MEMTYPE_DATA);
1700  049d a6f7          	ld	a,#247
1701  049f cd0000        	call	_FLASH_Lock
1703                     ; 375             CLearn = 0;
1705  04a2 5f            	clrw	x
1706  04a3 bf06          	ldw	_CLearn,x
1708  04a5               L544:
1709                     ; 376             while (Learn_Key_Pressed());
1711  04a5 4b04          	push	#4
1712  04a7 ae5000        	ldw	x,#20480
1713  04aa cd0000        	call	_GPIO_ReadInputPin
1715  04ad 5b01          	addw	sp,#1
1716  04af 4d            	tnz	a
1717  04b0 26f3          	jrne	L544
1718  04b2 2003          	jra	L154
1719  04b4               L524:
1720                     ; 381         CLearn = 0;
1722  04b4 5f            	clrw	x
1723  04b5 bf06          	ldw	_CLearn,x
1724  04b7               L154:
1725                     ; 384     if (CTLearn > 0)
1727  04b7 be08          	ldw	x,_CTLearn
1728  04b9 2711          	jreq	L354
1729                     ; 386         CTLearn--;
1731  04bb be08          	ldw	x,_CTLearn
1732  04bd 1d0001        	subw	x,#1
1733  04c0 bf08          	ldw	_CTLearn,x
1734                     ; 387         if (CTLearn == 0)
1736  04c2 be08          	ldw	x,_CTLearn
1737  04c4 2606          	jrne	L354
1738                     ; 389             Learn_LED_OFF();
1740  04c6 72155005      	bres	20485,#2
1741                     ; 390             FLearn = 0;
1743  04ca 3f03          	clr	_FLearn
1744  04cc               L354:
1745                     ; 395     if (Mode_Key_Pressed())
1747  04cc 4b10          	push	#16
1748  04ce ae5005        	ldw	x,#20485
1749  04d1 cd0000        	call	_GPIO_ReadInputPin
1751  04d4 5b01          	addw	sp,#1
1752  04d6 4d            	tnz	a
1753  04d7 2738          	jreq	L754
1754                     ; 397         if (!Mode_Key_Old)
1756  04d9 3d0b          	tnz	_Mode_Key_Old
1757  04db 2636          	jrne	L764
1758                     ; 399             Mode_Key_Old = 1;
1760  04dd 3501000b      	mov	_Mode_Key_Old,#1
1761                     ; 401             if (LF_ENABLE == 0)
1763  04e1 3d0c          	tnz	_Set_Buff+12
1764  04e3 260a          	jrne	L364
1765                     ; 403                 LF_ENABLE = 1;
1767  04e5 3501000c      	mov	_Set_Buff+12,#1
1768                     ; 404                 Mode_LED_OFF();
1770  04e9 72135005      	bres	20485,#1
1772  04ed 2006          	jra	L564
1773  04ef               L364:
1774                     ; 408                 LF_ENABLE = 0;
1776  04ef 3f0c          	clr	_Set_Buff+12
1777                     ; 409                 Mode_LED_ON();
1779  04f1 72125005      	bset	20485,#1
1780  04f5               L564:
1781                     ; 412             FLASH_Unlock(FLASH_MEMTYPE_DATA);
1783  04f5 a6f7          	ld	a,#247
1784  04f7 cd0000        	call	_FLASH_Unlock
1786                     ; 413             FLASH_ProgramByte(0x00004000 + 12, LF_ENABLE);
1788  04fa 3b000c        	push	_Set_Buff+12
1789  04fd ae400c        	ldw	x,#16396
1790  0500 89            	pushw	x
1791  0501 ae0000        	ldw	x,#0
1792  0504 89            	pushw	x
1793  0505 cd0000        	call	_FLASH_ProgramByte
1795  0508 5b05          	addw	sp,#5
1796                     ; 414             FLASH_Lock(FLASH_MEMTYPE_DATA);
1798  050a a6f7          	ld	a,#247
1799  050c cd0000        	call	_FLASH_Lock
1801  050f 2002          	jra	L764
1802  0511               L754:
1803                     ; 419         Mode_Key_Old = 0;
1805  0511 3f0b          	clr	_Mode_Key_Old
1806  0513               L764:
1807                     ; 423     if (Lfsend_Key_Pressed())
1809  0513 4b20          	push	#32
1810  0515 ae5005        	ldw	x,#20485
1811  0518 cd0000        	call	_GPIO_ReadInputPin
1813  051b 5b01          	addw	sp,#1
1814  051d 4d            	tnz	a
1815  051e 2712          	jreq	L174
1816                     ; 425         if (!Send_Key_Old)
1818  0520 3d0c          	tnz	_Send_Key_Old
1819  0522 2610          	jrne	L774
1820                     ; 427             Send_Key_Old = 1;
1822  0524 3501000c      	mov	_Send_Key_Old,#1
1823                     ; 428             if (LF_ENABLE == 0)
1825  0528 3d0c          	tnz	_Set_Buff+12
1826  052a 2608          	jrne	L774
1827                     ; 429                 User_LF_Send = 1;
1829  052c 35010011      	mov	_User_LF_Send,#1
1830  0530 2002          	jra	L774
1831  0532               L174:
1832                     ; 434         Send_Key_Old = 0;
1834  0532 3f0c          	clr	_Send_Key_Old
1835  0534               L774:
1836                     ; 436 }
1839  0534 84            	pop	a
1840  0535 81            	ret
1875                     ; 440 @far @interrupt void pc_irqhandler(void)
1875                     ; 441 {
1877                     	switch	.text
1878  0536               f_pc_irqhandler:
1880  0536 8a            	push	cc
1881  0537 84            	pop	a
1882  0538 a4bf          	and	a,#191
1883  053a 88            	push	a
1884  053b 86            	pop	cc
1885  053c 3b0002        	push	c_x+2
1886  053f be00          	ldw	x,c_x
1887  0541 89            	pushw	x
1888  0542 3b0002        	push	c_y+2
1889  0545 be00          	ldw	x,c_y
1890  0547 89            	pushw	x
1893                     ; 442     TIM2_ClearITPendingBit(TIM2_IT_UPDATE);
1895  0548 a601          	ld	a,#1
1896  054a cd0000        	call	_TIM2_ClearITPendingBit
1898                     ; 443     Time_1ms++;
1900  054d 3c0f          	inc	_Time_1ms
1901                     ; 445     if (Time_1ms >= 10)
1903  054f b60f          	ld	a,_Time_1ms
1904  0551 a10a          	cp	a,#10
1905  0553 251a          	jrult	L115
1906                     ; 447         Time_1ms = 0;
1908  0555 3f0f          	clr	_Time_1ms
1909                     ; 448         Time_Nms++;
1911  0557 3c10          	inc	_Time_Nms
1912                     ; 450         if ((LF_ENABLE == 1) && (LF_Send_Tim > 0))
1914  0559 b60c          	ld	a,_Set_Buff+12
1915  055b a101          	cp	a,#1
1916  055d 260d          	jrne	L315
1918  055f be00          	ldw	x,_LF_Send_Tim
1919  0561 2709          	jreq	L315
1920                     ; 451             LF_Send_Tim--; 
1922  0563 be00          	ldw	x,_LF_Send_Tim
1923  0565 1d0001        	subw	x,#1
1924  0568 bf00          	ldw	_LF_Send_Tim,x
1926  056a 2003          	jra	L115
1927  056c               L315:
1928                     ; 453             LF_Send_Tim = 0;
1930  056c 5f            	clrw	x
1931  056d bf00          	ldw	_LF_Send_Tim,x
1932  056f               L115:
1933                     ; 456     if (RFFull)
1935  056f 3d00          	tnz	_RFFull
1936  0571 2704          	jreq	L66
1937  0573 ac150615      	jpf	L46
1938  0577               L66:
1939                     ; 457         return; 
1941                     ; 459     if (RF_DATA_LOW())
1943  0577 4b01          	push	#1
1944  0579 ae500f        	ldw	x,#20495
1945  057c cd0000        	call	_GPIO_ReadInputPin
1947  057f 5b01          	addw	sp,#1
1948  0581 4d            	tnz	a
1949  0582 2608          	jrne	L125
1950                     ; 461         LL_w++;
1952  0584 3c01          	inc	_LL_w
1953                     ; 462         RFBit = 0;
1955  0586 3f04          	clr	_RFBit
1957  0588 ac150615      	jpf	L325
1958  058c               L125:
1959                     ; 466         if (!RFBit)
1961  058c 3d04          	tnz	_RFBit
1962  058e 2704ac110611  	jrne	L525
1963                     ; 468             if (!First_flag)
1965  0594 3d02          	tnz	_First_flag
1966  0596 261a          	jrne	L725
1967                     ; 470                 if ((LL_w > 40) && (LL_w < 60))
1969  0598 b601          	ld	a,_LL_w
1970  059a a129          	cp	a,#41
1971  059c 2571          	jrult	L335
1973  059e b601          	ld	a,_LL_w
1974  05a0 a13c          	cp	a,#60
1975  05a2 246b          	jruge	L335
1976                     ; 472                     First_flag = 1;
1978  05a4 35010002      	mov	_First_flag,#1
1979                     ; 473                     BitCount   = 0;
1981  05a8 3f00          	clr	_BitCount
1982                     ; 474                     Buff_B[0] = Buff_B[1] = Buff_B[2] = 0;
1984  05aa 3f03          	clr	_Buff_B+2
1985  05ac 3f02          	clr	_Buff_B+1
1986  05ae 3f01          	clr	_Buff_B
1987  05b0 205d          	jra	L335
1988  05b2               L725:
1989                     ; 479                 if ((LL_w > 3) && (LL_w <= 7))
1991  05b2 b601          	ld	a,_LL_w
1992  05b4 a104          	cp	a,#4
1993  05b6 2526          	jrult	L535
1995  05b8 b601          	ld	a,_LL_w
1996  05ba a108          	cp	a,#8
1997  05bc 2420          	jruge	L535
1998                     ; 481                     if (BitCount < RF_LEN)
2000  05be b600          	ld	a,_BitCount
2001  05c0 a118          	cp	a,#24
2002  05c2 243d          	jruge	L145
2003                     ; 483                         Buff_B[BitCount>>3] <<= 1;
2005  05c4 b600          	ld	a,_BitCount
2006  05c6 44            	srl	a
2007  05c7 44            	srl	a
2008  05c8 44            	srl	a
2009  05c9 5f            	clrw	x
2010  05ca 97            	ld	xl,a
2011  05cb 6801          	sll	(_Buff_B,x)
2012                     ; 484                         Buff_B[BitCount>>3] |= 0x01;
2014  05cd b600          	ld	a,_BitCount
2015  05cf 44            	srl	a
2016  05d0 44            	srl	a
2017  05d1 44            	srl	a
2018  05d2 5f            	clrw	x
2019  05d3 97            	ld	xl,a
2020  05d4 e601          	ld	a,(_Buff_B,x)
2021  05d6 aa01          	or	a,#1
2022  05d8 e701          	ld	(_Buff_B,x),a
2023                     ; 485                         BitCount++;
2025  05da 3c00          	inc	_BitCount
2026  05dc 2023          	jra	L145
2027  05de               L535:
2028                     ; 488                 else if ((LL_w >= 8) && (LL_w < 13))
2030  05de b601          	ld	a,_LL_w
2031  05e0 a108          	cp	a,#8
2032  05e2 2519          	jrult	L345
2034  05e4 b601          	ld	a,_LL_w
2035  05e6 a10d          	cp	a,#13
2036  05e8 2413          	jruge	L345
2037                     ; 490                     if (BitCount < RF_LEN)
2039  05ea b600          	ld	a,_BitCount
2040  05ec a118          	cp	a,#24
2041  05ee 2411          	jruge	L145
2042                     ; 492                         Buff_B[BitCount>>3] <<= 1;
2044  05f0 b600          	ld	a,_BitCount
2045  05f2 44            	srl	a
2046  05f3 44            	srl	a
2047  05f4 44            	srl	a
2048  05f5 5f            	clrw	x
2049  05f6 97            	ld	xl,a
2050  05f7 6801          	sll	(_Buff_B,x)
2051                     ; 493                         BitCount++;
2053  05f9 3c00          	inc	_BitCount
2054  05fb 2004          	jra	L145
2055  05fd               L345:
2056                     ; 498                     First_flag = 0;
2058  05fd 3f02          	clr	_First_flag
2059                     ; 499                     BitCount   = 0;
2061  05ff 3f00          	clr	_BitCount
2062  0601               L145:
2063                     ; 502                 if (BitCount >= RF_LEN)
2065  0601 b600          	ld	a,_BitCount
2066  0603 a118          	cp	a,#24
2067  0605 2508          	jrult	L335
2068                     ; 504                     BitCount   = 0;
2070  0607 3f00          	clr	_BitCount
2071                     ; 505                     First_flag = 0;
2073  0609 3f02          	clr	_First_flag
2074                     ; 506                     RFFull     = 1;
2076  060b 35010000      	mov	_RFFull,#1
2077  060f               L335:
2078                     ; 509             LL_w = 0;
2080  060f 3f01          	clr	_LL_w
2081  0611               L525:
2082                     ; 511         RFBit = 1;
2084  0611 35010004      	mov	_RFBit,#1
2085  0615               L325:
2086                     ; 513 }
2087  0615               L46:
2090  0615 85            	popw	x
2091  0616 bf00          	ldw	c_y,x
2092  0618 320002        	pop	c_y+2
2093  061b 85            	popw	x
2094  061c bf00          	ldw	c_x,x
2095  061e 320002        	pop	c_x+2
2096  0621 80            	iret
2128                     ; 517 void main(void)
2128                     ; 518 {
2130                     	switch	.text
2131  0622               _main:
2133  0622 5205          	subw	sp,#5
2134       00000005      OFST:	set	5
2137                     ; 519     InIt();
2139  0624 cd017d        	call	_InIt
2141  0627               L365:
2142                     ; 523         if (RFFull)
2144  0627 3d00          	tnz	_RFFull
2145  0629 2703          	jreq	L765
2146                     ; 524             RF_Remote();     
2148  062b cd0225        	call	_RF_Remote
2150  062e               L765:
2151                     ; 526         if (Time_Nms >= 10)           
2153  062e b610          	ld	a,_Time_Nms
2154  0630 a10a          	cp	a,#10
2155  0632 2522          	jrult	L175
2156                     ; 528             Time_Nms = 0;
2158  0634 3f10          	clr	_Time_Nms
2159                     ; 529             Key_Scan();	
2161  0636 cd0441        	call	_Key_Scan
2163                     ; 531             if (COut > 0)
2165  0639 be04          	ldw	x,_COut
2166  063b 270f          	jreq	L375
2167                     ; 533                 COut--;
2169  063d be04          	ldw	x,_COut
2170  063f 1d0001        	subw	x,#1
2171  0642 bf04          	ldw	_COut,x
2172                     ; 534                 if (COut == 0)
2174  0644 be04          	ldw	x,_COut
2175  0646 2604          	jrne	L375
2176                     ; 535                     Out_LED_OFF();
2178  0648 72175005      	bres	20485,#3
2179  064c               L375:
2180                     ; 538             if (LF_ENABLE == 1)
2182  064c b60c          	ld	a,_Set_Buff+12
2183  064e a101          	cp	a,#1
2184  0650 2604          	jrne	L175
2185                     ; 539                 Mode_LED_OFF();
2187  0652 72135005      	bres	20485,#1
2188  0656               L175:
2189                     ; 542         if ((LF_ENABLE == 1) && (LF_Send_Tim == 0)) 
2191  0656 b60c          	ld	a,_Set_Buff+12
2192  0658 a101          	cp	a,#1
2193  065a 265c          	jrne	L106
2195  065c be00          	ldw	x,_LF_Send_Tim
2196  065e 2658          	jrne	L106
2197                     ; 544             Lfsend_LED_ON();
2199  0660 7216500f      	bset	20495,#3
2200                     ; 545             LF_SendData(PATTERN1,PATTERN2,PATTREN_BIT,LF_SEND_CH1);
2202  0664 4b01          	push	#1
2203  0666 3b0007        	push	_Set_Buff+7
2204  0669 b609          	ld	a,_Set_Buff+9
2205  066b 97            	ld	xl,a
2206  066c b608          	ld	a,_Set_Buff+8
2207  066e 95            	ld	xh,a
2208  066f cd0000        	call	_LF_SendData
2210  0672 85            	popw	x
2211                     ; 546             LF_Send_Tim = (INTERVAL1 >> 4) * 1000
2211                     ; 547                         + (INTERVAL1 & 0x0F) * 100
2211                     ; 548                         + (INTERVAL2 >> 4) * 10
2211                     ; 549                         + (INTERVAL2 & 0x0F);
2213  0673 b60e          	ld	a,_Set_Buff+14
2214  0675 a40f          	and	a,#15
2215  0677 6b05          	ld	(OFST+0,sp),a
2217  0679 b60e          	ld	a,_Set_Buff+14
2218  067b 4e            	swap	a
2219  067c a40f          	and	a,#15
2220  067e 5f            	clrw	x
2221  067f 97            	ld	xl,a
2222  0680 a60a          	ld	a,#10
2223  0682 cd0000        	call	c_bmulx
2225  0685 1f03          	ldw	(OFST-2,sp),x
2227  0687 b60d          	ld	a,_Set_Buff+13
2228  0689 a40f          	and	a,#15
2229  068b 97            	ld	xl,a
2230  068c a664          	ld	a,#100
2231  068e 42            	mul	x,a
2232  068f 1f01          	ldw	(OFST-4,sp),x
2234  0691 b60d          	ld	a,_Set_Buff+13
2235  0693 4e            	swap	a
2236  0694 a40f          	and	a,#15
2237  0696 5f            	clrw	x
2238  0697 97            	ld	xl,a
2239  0698 90ae03e8      	ldw	y,#1000
2240  069c cd0000        	call	c_imul
2242  069f 72fb01        	addw	x,(OFST-4,sp)
2243  06a2 72fb03        	addw	x,(OFST-2,sp)
2244  06a5 01            	rrwa	x,a
2245  06a6 1b05          	add	a,(OFST+0,sp)
2246  06a8 2401          	jrnc	L27
2247  06aa 5c            	incw	x
2248  06ab               L27:
2249  06ab b701          	ld	_LF_Send_Tim+1,a
2250  06ad 9f            	ld	a,xl
2251  06ae b700          	ld	_LF_Send_Tim,a
2252                     ; 550             Lfsend_LED_OFF();
2254  06b0 7217500f      	bres	20495,#3
2256  06b4 ac270627      	jpf	L365
2257  06b8               L106:
2258                     ; 552         else if (User_LF_Send)
2260  06b8 3d11          	tnz	_User_LF_Send
2261  06ba 2603          	jrne	L47
2262  06bc cc0627        	jp	L365
2263  06bf               L47:
2264                     ; 554             User_LF_Send = 0;
2266  06bf 3f11          	clr	_User_LF_Send
2267                     ; 555             Lfsend_LED_ON();
2269  06c1 7216500f      	bset	20495,#3
2270                     ; 556             LF_SendData(PATTERN1,PATTERN2,PATTREN_BIT,LF_SEND_CH1);
2272  06c5 4b01          	push	#1
2273  06c7 3b0007        	push	_Set_Buff+7
2274  06ca b609          	ld	a,_Set_Buff+9
2275  06cc 97            	ld	xl,a
2276  06cd b608          	ld	a,_Set_Buff+8
2277  06cf 95            	ld	xh,a
2278  06d0 cd0000        	call	_LF_SendData
2280  06d3 85            	popw	x
2281                     ; 557             Lfsend_LED_OFF();          
2283  06d4 7217500f      	bres	20495,#3
2284  06d8 ac270627      	jpf	L365
2482                     	xdef	_main
2483                     	xdef	f_pc_irqhandler
2484                     	xdef	_InIt
2485                     	xdef	_BEEP_BEEP
2486                     	xdef	_Write_EEpeomData
2487                     	xdef	_Read_EEpeomData
2488                     	xdef	_TIM2_Init
2489                     	xdef	_SystemClock_Init
2490                     	xdef	_GetCRC16
2491                     	xdef	_mcu_user_config
2492                     	xdef	_wCRCTalbeAbs
2493                     	xdef	_RF_Remote
2494                     	xdef	_Key_Scan
2495                     	xdef	_User_LF_Send
2496                     	xdef	_Time_Nms
2497                     	xdef	_Time_1ms
2498                     	xdef	_CSend
2499                     	xdef	_MLearn
2500                     	xdef	_Send_Key_Old
2501                     	xdef	_Mode_Key_Old
2502                     	xdef	_LF_Send_flag
2503                     	xdef	_CTLearn
2504                     	xdef	_CLearn
2505                     	xdef	_COut
2506                     	xdef	_FLearn
2507                     	switch	.ubsct
2508  0000               _BitCount:
2509  0000 00            	ds.b	1
2510                     	xdef	_BitCount
2511  0001               _Buff_B:
2512  0001 000000        	ds.b	3
2513                     	xdef	_Buff_B
2514                     	xdef	_First_flag
2515                     	xdef	_LL_w
2516  0004               _RFBit:
2517  0004 00            	ds.b	1
2518                     	xdef	_RFBit
2519                     	xdef	_RFFull
2520                     	xref	_LF_SendData
2521                     	xref	_LF_PLL_SET
2522                     	xref	_LF_ClockOccurs
2523                     	xref	_Delay_us
2524                     	xref	_Delay_InIt
2525                     	xref.b	_LF_Send_Tim
2526                     	xref.b	_Set_Buff
2527                     	xref	_FLASH_ReadByte
2528                     	xref	_FLASH_ProgramByte
2529                     	xref	_FLASH_Lock
2530                     	xref	_FLASH_Unlock
2531                     	xref	_TIM2_ClearITPendingBit
2532                     	xref	_TIM2_SetCounter
2533                     	xref	_TIM2_ITConfig
2534                     	xref	_TIM2_Cmd
2535                     	xref	_TIM2_TimeBaseInit
2536                     	xref	_TIM2_DeInit
2537                     	xref	_CLK_GetFlagStatus
2538                     	xref	_CLK_HSIPrescalerConfig
2539                     	xref	_CLK_PeripheralClockConfig
2540                     	xref	_CLK_HSICmd
2541                     	xref	_GPIO_ReadInputPin
2542                     	xref	_GPIO_WriteLow
2543                     	xref	_GPIO_Init
2544                     	xref.b	c_lreg
2545                     	xref.b	c_x
2546                     	xref.b	c_y
2566                     	xref	c_bmulx
2567                     	xref	c_bmuly
2568                     	xref	c_imul
2569                     	xref	c_itolx
2570                     	xref	c_uitolx
2571                     	end
