   1                     ; C Compiler for STM8 (COSMIC Software)
   2                     ; Parser V4.13.2 - 04 Jun 2024
   3                     ; Generator (Limited) V4.6.4 - 15 Jan 2025
  74                     ; 92 void FLASH_Unlock(FLASH_MemType_TypeDef FLASH_MemType)
  74                     ; 93 {
  76                     	switch	.text
  77  0000               _FLASH_Unlock:
  81                     ; 95   assert_param(IS_MEMORY_TYPE_OK(FLASH_MemType));
  83                     ; 98   if(FLASH_MemType == FLASH_MEMTYPE_PROG)
  85  0000 a1fd          	cp	a,#253
  86  0002 260a          	jrne	L73
  87                     ; 100     FLASH->PUKR = FLASH_RASS_KEY1;
  89  0004 35565062      	mov	20578,#86
  90                     ; 101     FLASH->PUKR = FLASH_RASS_KEY2;
  92  0008 35ae5062      	mov	20578,#174
  94  000c 2008          	jra	L14
  95  000e               L73:
  96                     ; 106     FLASH->DUKR = FLASH_RASS_KEY2; /* Warning: keys are reversed on data memory !!! */
  98  000e 35ae5064      	mov	20580,#174
  99                     ; 107     FLASH->DUKR = FLASH_RASS_KEY1;
 101  0012 35565064      	mov	20580,#86
 102  0016               L14:
 103                     ; 109 }
 106  0016 81            	ret
 141                     ; 117 void FLASH_Lock(FLASH_MemType_TypeDef FLASH_MemType)
 141                     ; 118 {
 142                     	switch	.text
 143  0017               _FLASH_Lock:
 147                     ; 120   assert_param(IS_MEMORY_TYPE_OK(FLASH_MemType));
 149                     ; 123   FLASH->IAPSR &= (uint8_t)FLASH_MemType;
 151  0017 c4505f        	and	a,20575
 152  001a c7505f        	ld	20575,a
 153                     ; 124 }
 156  001d 81            	ret
 179                     ; 131 void FLASH_DeInit(void)
 179                     ; 132 {
 180                     	switch	.text
 181  001e               _FLASH_DeInit:
 185                     ; 133   FLASH->CR1 = FLASH_CR1_RESET_VALUE;
 187  001e 725f505a      	clr	20570
 188                     ; 134   FLASH->CR2 = FLASH_CR2_RESET_VALUE;
 190  0022 725f505b      	clr	20571
 191                     ; 135   FLASH->NCR2 = FLASH_NCR2_RESET_VALUE;
 193  0026 35ff505c      	mov	20572,#255
 194                     ; 136   FLASH->IAPSR &= (uint8_t)(~FLASH_IAPSR_DUL);
 196  002a 7217505f      	bres	20575,#3
 197                     ; 137   FLASH->IAPSR &= (uint8_t)(~FLASH_IAPSR_PUL);
 199  002e 7213505f      	bres	20575,#1
 200                     ; 138   (void) FLASH->IAPSR; /* Reading of this register causes the clearing of status flags */
 202  0032 c6505f        	ld	a,20575
 203                     ; 139 }
 206  0035 81            	ret
 261                     ; 147 void FLASH_ITConfig(FunctionalState NewState)
 261                     ; 148 {
 262                     	switch	.text
 263  0036               _FLASH_ITConfig:
 267                     ; 150   assert_param(IS_FUNCTIONALSTATE_OK(NewState));
 269                     ; 152   if(NewState != DISABLE)
 271  0036 4d            	tnz	a
 272  0037 2706          	jreq	L711
 273                     ; 154     FLASH->CR1 |= FLASH_CR1_IE; /* Enables the interrupt sources */
 275  0039 7212505a      	bset	20570,#1
 277  003d 2004          	jra	L121
 278  003f               L711:
 279                     ; 158     FLASH->CR1 &= (uint8_t)(~FLASH_CR1_IE); /* Disables the interrupt sources */
 281  003f 7213505a      	bres	20570,#1
 282  0043               L121:
 283                     ; 160 }
 286  0043 81            	ret
 320                     ; 169 void FLASH_EraseByte(uint32_t Address)
 320                     ; 170 {
 321                     	switch	.text
 322  0044               _FLASH_EraseByte:
 324       00000000      OFST:	set	0
 327                     ; 172   assert_param(IS_FLASH_ADDRESS_OK(Address));
 329                     ; 175   *(PointerAttr uint8_t*) (MemoryAddressCast)Address = FLASH_CLEAR_BYTE; 
 331  0044 1e05          	ldw	x,(OFST+5,sp)
 332  0046 7f            	clr	(x)
 333                     ; 176 }
 336  0047 81            	ret
 379                     ; 186 void FLASH_ProgramByte(uint32_t Address, uint8_t Data)
 379                     ; 187 {
 380                     	switch	.text
 381  0048               _FLASH_ProgramByte:
 383       00000000      OFST:	set	0
 386                     ; 189   assert_param(IS_FLASH_ADDRESS_OK(Address));
 388                     ; 190   *(PointerAttr uint8_t*) (MemoryAddressCast)Address = Data;
 390  0048 7b07          	ld	a,(OFST+7,sp)
 391  004a 1e05          	ldw	x,(OFST+5,sp)
 392  004c f7            	ld	(x),a
 393                     ; 191 }
 396  004d 81            	ret
 430                     ; 200 uint8_t FLASH_ReadByte(uint32_t Address)
 430                     ; 201 {
 431                     	switch	.text
 432  004e               _FLASH_ReadByte:
 434       00000000      OFST:	set	0
 437                     ; 203   assert_param(IS_FLASH_ADDRESS_OK(Address));
 439                     ; 206   return(*(PointerAttr uint8_t *) (MemoryAddressCast)Address); 
 441  004e 1e05          	ldw	x,(OFST+5,sp)
 442  0050 f6            	ld	a,(x)
 445  0051 81            	ret
 488                     ; 217 void FLASH_ProgramWord(uint32_t Address, uint32_t Data)
 488                     ; 218 {
 489                     	switch	.text
 490  0052               _FLASH_ProgramWord:
 492       00000000      OFST:	set	0
 495                     ; 220   assert_param(IS_FLASH_ADDRESS_OK(Address));
 497                     ; 223   FLASH->CR2 |= FLASH_CR2_WPRG;
 499  0052 721c505b      	bset	20571,#6
 500                     ; 224   FLASH->NCR2 &= (uint8_t)(~FLASH_NCR2_NWPRG);
 502  0056 721d505c      	bres	20572,#6
 503                     ; 227   *((PointerAttr uint8_t*)(MemoryAddressCast)Address)       = *((uint8_t*)(&Data));
 505  005a 7b07          	ld	a,(OFST+7,sp)
 506  005c 1e05          	ldw	x,(OFST+5,sp)
 507  005e f7            	ld	(x),a
 508                     ; 229   *(((PointerAttr uint8_t*)(MemoryAddressCast)Address) + 1) = *((uint8_t*)(&Data)+1); 
 510  005f 7b08          	ld	a,(OFST+8,sp)
 511  0061 1e05          	ldw	x,(OFST+5,sp)
 512  0063 e701          	ld	(1,x),a
 513                     ; 231   *(((PointerAttr uint8_t*)(MemoryAddressCast)Address) + 2) = *((uint8_t*)(&Data)+2); 
 515  0065 7b09          	ld	a,(OFST+9,sp)
 516  0067 1e05          	ldw	x,(OFST+5,sp)
 517  0069 e702          	ld	(2,x),a
 518                     ; 233   *(((PointerAttr uint8_t*)(MemoryAddressCast)Address) + 3) = *((uint8_t*)(&Data)+3); 
 520  006b 7b0a          	ld	a,(OFST+10,sp)
 521  006d 1e05          	ldw	x,(OFST+5,sp)
 522  006f e703          	ld	(3,x),a
 523                     ; 234 }
 526  0071 81            	ret
 571                     ; 242 void FLASH_ProgramOptionByte(uint16_t Address, uint8_t Data)
 571                     ; 243 {
 572                     	switch	.text
 573  0072               _FLASH_ProgramOptionByte:
 575  0072 89            	pushw	x
 576       00000000      OFST:	set	0
 579                     ; 245   assert_param(IS_OPTION_BYTE_ADDRESS_OK(Address));
 581                     ; 248   FLASH->CR2 |= FLASH_CR2_OPT;
 583  0073 721e505b      	bset	20571,#7
 584                     ; 249   FLASH->NCR2 &= (uint8_t)(~FLASH_NCR2_NOPT);
 586  0077 721f505c      	bres	20572,#7
 587                     ; 252   if(Address == 0x4800)
 589  007b a34800        	cpw	x,#18432
 590  007e 2607          	jrne	L542
 591                     ; 255     *((NEAR uint8_t*)Address) = Data;
 593  0080 7b05          	ld	a,(OFST+5,sp)
 594  0082 1e01          	ldw	x,(OFST+1,sp)
 595  0084 f7            	ld	(x),a
 597  0085 200c          	jra	L742
 598  0087               L542:
 599                     ; 260     *((NEAR uint8_t*)Address) = Data;
 601  0087 7b05          	ld	a,(OFST+5,sp)
 602  0089 1e01          	ldw	x,(OFST+1,sp)
 603  008b f7            	ld	(x),a
 604                     ; 261     *((NEAR uint8_t*)((uint16_t)(Address + 1))) = (uint8_t)(~Data);
 606  008c 7b05          	ld	a,(OFST+5,sp)
 607  008e 43            	cpl	a
 608  008f 1e01          	ldw	x,(OFST+1,sp)
 609  0091 e701          	ld	(1,x),a
 610  0093               L742:
 611                     ; 263   FLASH_WaitForLastOperation(FLASH_MEMTYPE_PROG);
 613  0093 a6fd          	ld	a,#253
 614  0095 cd0227        	call	_FLASH_WaitForLastOperation
 616                     ; 266   FLASH->CR2 &= (uint8_t)(~FLASH_CR2_OPT);
 618  0098 721f505b      	bres	20571,#7
 619                     ; 267   FLASH->NCR2 |= FLASH_NCR2_NOPT;
 621  009c 721e505c      	bset	20572,#7
 622                     ; 268 }
 625  00a0 85            	popw	x
 626  00a1 81            	ret
 662                     ; 275 void FLASH_EraseOptionByte(uint16_t Address)
 662                     ; 276 {
 663                     	switch	.text
 664  00a2               _FLASH_EraseOptionByte:
 666  00a2 89            	pushw	x
 667       00000000      OFST:	set	0
 670                     ; 278   assert_param(IS_OPTION_BYTE_ADDRESS_OK(Address));
 672                     ; 281   FLASH->CR2 |= FLASH_CR2_OPT;
 674  00a3 721e505b      	bset	20571,#7
 675                     ; 282   FLASH->NCR2 &= (uint8_t)(~FLASH_NCR2_NOPT);
 677  00a7 721f505c      	bres	20572,#7
 678                     ; 285   if(Address == 0x4800)
 680  00ab a34800        	cpw	x,#18432
 681  00ae 2603          	jrne	L762
 682                     ; 288     *((NEAR uint8_t*)Address) = FLASH_CLEAR_BYTE;
 684  00b0 7f            	clr	(x)
 686  00b1 2009          	jra	L172
 687  00b3               L762:
 688                     ; 293     *((NEAR uint8_t*)Address) = FLASH_CLEAR_BYTE;
 690  00b3 1e01          	ldw	x,(OFST+1,sp)
 691  00b5 7f            	clr	(x)
 692                     ; 294     *((NEAR uint8_t*)((uint16_t)(Address + (uint16_t)1 ))) = FLASH_SET_BYTE;
 694  00b6 1e01          	ldw	x,(OFST+1,sp)
 695  00b8 a6ff          	ld	a,#255
 696  00ba e701          	ld	(1,x),a
 697  00bc               L172:
 698                     ; 296   FLASH_WaitForLastOperation(FLASH_MEMTYPE_PROG);
 700  00bc a6fd          	ld	a,#253
 701  00be cd0227        	call	_FLASH_WaitForLastOperation
 703                     ; 299   FLASH->CR2 &= (uint8_t)(~FLASH_CR2_OPT);
 705  00c1 721f505b      	bres	20571,#7
 706                     ; 300   FLASH->NCR2 |= FLASH_NCR2_NOPT;
 708  00c5 721e505c      	bset	20572,#7
 709                     ; 301 }
 712  00c9 85            	popw	x
 713  00ca 81            	ret
 776                     ; 308 uint16_t FLASH_ReadOptionByte(uint16_t Address)
 776                     ; 309 {
 777                     	switch	.text
 778  00cb               _FLASH_ReadOptionByte:
 780  00cb 5204          	subw	sp,#4
 781       00000004      OFST:	set	4
 784                     ; 310   uint8_t value_optbyte, value_optbyte_complement = 0;
 786                     ; 311   uint16_t res_value = 0;
 788                     ; 314   assert_param(IS_OPTION_BYTE_ADDRESS_OK(Address));
 790                     ; 316   value_optbyte = *((NEAR uint8_t*)Address); /* Read option byte */
 792  00cd f6            	ld	a,(x)
 793  00ce 6b01          	ld	(OFST-3,sp),a
 795                     ; 317   value_optbyte_complement = *(((NEAR uint8_t*)Address) + 1); /* Read option byte complement */
 797  00d0 e601          	ld	a,(1,x)
 798  00d2 6b02          	ld	(OFST-2,sp),a
 800                     ; 320   if(Address == 0x4800)	 
 802  00d4 a34800        	cpw	x,#18432
 803  00d7 2608          	jrne	L523
 804                     ; 322     res_value =	 value_optbyte;
 806  00d9 7b01          	ld	a,(OFST-3,sp)
 807  00db 5f            	clrw	x
 808  00dc 97            	ld	xl,a
 809  00dd 1f03          	ldw	(OFST-1,sp),x
 812  00df 2023          	jra	L723
 813  00e1               L523:
 814                     ; 326     if(value_optbyte == (uint8_t)(~value_optbyte_complement))
 816  00e1 7b02          	ld	a,(OFST-2,sp)
 817  00e3 43            	cpl	a
 818  00e4 1101          	cp	a,(OFST-3,sp)
 819  00e6 2617          	jrne	L133
 820                     ; 328       res_value = (uint16_t)((uint16_t)value_optbyte << 8);
 822  00e8 7b01          	ld	a,(OFST-3,sp)
 823  00ea 5f            	clrw	x
 824  00eb 97            	ld	xl,a
 825  00ec 4f            	clr	a
 826  00ed 02            	rlwa	x,a
 827  00ee 1f03          	ldw	(OFST-1,sp),x
 829                     ; 329       res_value = res_value | (uint16_t)value_optbyte_complement;
 831  00f0 7b02          	ld	a,(OFST-2,sp)
 832  00f2 5f            	clrw	x
 833  00f3 97            	ld	xl,a
 834  00f4 01            	rrwa	x,a
 835  00f5 1a04          	or	a,(OFST+0,sp)
 836  00f7 01            	rrwa	x,a
 837  00f8 1a03          	or	a,(OFST-1,sp)
 838  00fa 01            	rrwa	x,a
 839  00fb 1f03          	ldw	(OFST-1,sp),x
 842  00fd 2005          	jra	L723
 843  00ff               L133:
 844                     ; 333       res_value = FLASH_OPTIONBYTE_ERROR;
 846  00ff ae5555        	ldw	x,#21845
 847  0102 1f03          	ldw	(OFST-1,sp),x
 849  0104               L723:
 850                     ; 336   return(res_value);
 852  0104 1e03          	ldw	x,(OFST-1,sp)
 855  0106 5b04          	addw	sp,#4
 856  0108 81            	ret
 930                     ; 345 void FLASH_SetLowPowerMode(FLASH_LPMode_TypeDef FLASH_LPMode)
 930                     ; 346 {
 931                     	switch	.text
 932  0109               _FLASH_SetLowPowerMode:
 934  0109 88            	push	a
 935       00000000      OFST:	set	0
 938                     ; 348   assert_param(IS_FLASH_LOW_POWER_MODE_OK(FLASH_LPMode));
 940                     ; 351   FLASH->CR1 &= (uint8_t)(~(FLASH_CR1_HALT | FLASH_CR1_AHALT)); 
 942  010a c6505a        	ld	a,20570
 943  010d a4f3          	and	a,#243
 944  010f c7505a        	ld	20570,a
 945                     ; 354   FLASH->CR1 |= (uint8_t)FLASH_LPMode; 
 947  0112 c6505a        	ld	a,20570
 948  0115 1a01          	or	a,(OFST+1,sp)
 949  0117 c7505a        	ld	20570,a
 950                     ; 355 }
 953  011a 84            	pop	a
 954  011b 81            	ret
1012                     ; 363 void FLASH_SetProgrammingTime(FLASH_ProgramTime_TypeDef FLASH_ProgTime)
1012                     ; 364 {
1013                     	switch	.text
1014  011c               _FLASH_SetProgrammingTime:
1018                     ; 366   assert_param(IS_FLASH_PROGRAM_TIME_OK(FLASH_ProgTime));
1020                     ; 368   FLASH->CR1 &= (uint8_t)(~FLASH_CR1_FIX);
1022  011c 7211505a      	bres	20570,#0
1023                     ; 369   FLASH->CR1 |= (uint8_t)FLASH_ProgTime;
1025  0120 ca505a        	or	a,20570
1026  0123 c7505a        	ld	20570,a
1027                     ; 370 }
1030  0126 81            	ret
1055                     ; 377 FLASH_LPMode_TypeDef FLASH_GetLowPowerMode(void)
1055                     ; 378 {
1056                     	switch	.text
1057  0127               _FLASH_GetLowPowerMode:
1061                     ; 379   return((FLASH_LPMode_TypeDef)(FLASH->CR1 & (uint8_t)(FLASH_CR1_HALT | FLASH_CR1_AHALT)));
1063  0127 c6505a        	ld	a,20570
1064  012a a40c          	and	a,#12
1067  012c 81            	ret
1092                     ; 387 FLASH_ProgramTime_TypeDef FLASH_GetProgrammingTime(void)
1092                     ; 388 {
1093                     	switch	.text
1094  012d               _FLASH_GetProgrammingTime:
1098                     ; 389   return((FLASH_ProgramTime_TypeDef)(FLASH->CR1 & FLASH_CR1_FIX));
1100  012d c6505a        	ld	a,20570
1101  0130 a401          	and	a,#1
1104  0132 81            	ret
1138                     ; 397 uint32_t FLASH_GetBootSize(void)
1138                     ; 398 {
1139                     	switch	.text
1140  0133               _FLASH_GetBootSize:
1142  0133 5204          	subw	sp,#4
1143       00000004      OFST:	set	4
1146                     ; 399   uint32_t temp = 0;
1148                     ; 402   temp = (uint32_t)((uint32_t)FLASH->FPR * (uint32_t)512);
1150  0135 c6505d        	ld	a,20573
1151  0138 5f            	clrw	x
1152  0139 97            	ld	xl,a
1153  013a 90ae0200      	ldw	y,#512
1154  013e cd0000        	call	c_umul
1156  0141 96            	ldw	x,sp
1157  0142 1c0001        	addw	x,#OFST-3
1158  0145 cd0000        	call	c_rtol
1161                     ; 405   if(FLASH->FPR == 0xFF)
1163  0148 c6505d        	ld	a,20573
1164  014b a1ff          	cp	a,#255
1165  014d 2611          	jrne	L354
1166                     ; 407     temp += 512;
1168  014f ae0200        	ldw	x,#512
1169  0152 bf02          	ldw	c_lreg+2,x
1170  0154 ae0000        	ldw	x,#0
1171  0157 bf00          	ldw	c_lreg,x
1172  0159 96            	ldw	x,sp
1173  015a 1c0001        	addw	x,#OFST-3
1174  015d cd0000        	call	c_lgadd
1177  0160               L354:
1178                     ; 411   return(temp);
1180  0160 96            	ldw	x,sp
1181  0161 1c0001        	addw	x,#OFST-3
1182  0164 cd0000        	call	c_ltor
1186  0167 5b04          	addw	sp,#4
1187  0169 81            	ret
1296                     ; 422 FlagStatus FLASH_GetFlagStatus(FLASH_Flag_TypeDef FLASH_FLAG)
1296                     ; 423 {
1297                     	switch	.text
1298  016a               _FLASH_GetFlagStatus:
1300  016a 88            	push	a
1301       00000001      OFST:	set	1
1304                     ; 424   FlagStatus status = RESET;
1306                     ; 426   assert_param(IS_FLASH_FLAGS_OK(FLASH_FLAG));
1308                     ; 429   if((FLASH->IAPSR & (uint8_t)FLASH_FLAG) != (uint8_t)RESET)
1310  016b c4505f        	and	a,20575
1311  016e 2706          	jreq	L525
1312                     ; 431     status = SET; /* FLASH_FLAG is set */
1314  0170 a601          	ld	a,#1
1315  0172 6b01          	ld	(OFST+0,sp),a
1318  0174 2002          	jra	L725
1319  0176               L525:
1320                     ; 435     status = RESET; /* FLASH_FLAG is reset*/
1322  0176 0f01          	clr	(OFST+0,sp)
1324  0178               L725:
1325                     ; 439   return status;
1327  0178 7b01          	ld	a,(OFST+0,sp)
1330  017a 5b01          	addw	sp,#1
1331  017c 81            	ret
1356                     ; 442 void GPIO_Init_LED(void) {
1357                     	switch	.text
1358  017d               _GPIO_Init_LED:
1362                     ; 443     GPIO_DeInit(LED_PORT);
1364  017d ae5005        	ldw	x,#20485
1365  0180 cd0000        	call	_GPIO_DeInit
1367                     ; 444     GPIO_Init(LED_PORT, LED_PIN, GPIO_MODE_OUT_PP_LOW_FAST);
1369  0183 4be0          	push	#224
1370  0185 4b20          	push	#32
1371  0187 ae5005        	ldw	x,#20485
1372  018a cd0000        	call	_GPIO_Init
1374  018d 85            	popw	x
1375                     ; 445 }
1378  018e 81            	ret
1402                     ; 447 void LED_Toggle(void) {
1403                     	switch	.text
1404  018f               _LED_Toggle:
1408                     ; 448     GPIO_WriteReverse(LED_PORT, LED_PIN);
1410  018f 4b20          	push	#32
1411  0191 ae5005        	ldw	x,#20485
1412  0194 cd0000        	call	_GPIO_WriteReverse
1414  0197 84            	pop	a
1415                     ; 449 }
1418  0198 81            	ret
1444                     ; 451 void Flash_WriteData(void) {
1445                     	switch	.text
1446  0199               _Flash_WriteData:
1450                     ; 452     FLASH_Unlock(FLASH_MEMTYPE_DATA); 
1452  0199 a6f7          	ld	a,#247
1453  019b cd0000        	call	_FLASH_Unlock
1455                     ; 454     FLASH_ProgramByte(FLASH_START_ADDR + 0, 0x01); 
1457  019e 4b01          	push	#1
1458  01a0 ae4000        	ldw	x,#16384
1459  01a3 89            	pushw	x
1460  01a4 ae0000        	ldw	x,#0
1461  01a7 89            	pushw	x
1462  01a8 cd0048        	call	_FLASH_ProgramByte
1464  01ab 5b05          	addw	sp,#5
1465                     ; 455     FLASH_ProgramByte(FLASH_START_ADDR + 1, 0x02); 
1467  01ad 4b02          	push	#2
1468  01af ae4001        	ldw	x,#16385
1469  01b2 89            	pushw	x
1470  01b3 ae0000        	ldw	x,#0
1471  01b6 89            	pushw	x
1472  01b7 cd0048        	call	_FLASH_ProgramByte
1474  01ba 5b05          	addw	sp,#5
1475                     ; 456 		FLASH_ProgramByte(FLASH_START_ADDR + 2, 0x09);
1477  01bc 4b09          	push	#9
1478  01be ae4002        	ldw	x,#16386
1479  01c1 89            	pushw	x
1480  01c2 ae0000        	ldw	x,#0
1481  01c5 89            	pushw	x
1482  01c6 cd0048        	call	_FLASH_ProgramByte
1484  01c9 5b05          	addw	sp,#5
1485                     ; 457     FLASH_ProgramByte(FLASH_START_ADDR + 3, 0x06);
1487  01cb 4b06          	push	#6
1488  01cd ae4003        	ldw	x,#16387
1489  01d0 89            	pushw	x
1490  01d1 ae0000        	ldw	x,#0
1491  01d4 89            	pushw	x
1492  01d5 cd0048        	call	_FLASH_ProgramByte
1494  01d8 5b05          	addw	sp,#5
1495                     ; 458 		FLASH_ProgramByte(FLASH_START_ADDR + 4, 0x05);
1497  01da 4b05          	push	#5
1498  01dc ae4004        	ldw	x,#16388
1499  01df 89            	pushw	x
1500  01e0 ae0000        	ldw	x,#0
1501  01e3 89            	pushw	x
1502  01e4 cd0048        	call	_FLASH_ProgramByte
1504  01e7 5b05          	addw	sp,#5
1505                     ; 459 		FLASH_ProgramByte(FLASH_START_ADDR + 5, 0x0F);
1507  01e9 4b0f          	push	#15
1508  01eb ae4005        	ldw	x,#16389
1509  01ee 89            	pushw	x
1510  01ef ae0000        	ldw	x,#0
1511  01f2 89            	pushw	x
1512  01f3 cd0048        	call	_FLASH_ProgramByte
1514  01f6 5b05          	addw	sp,#5
1515                     ; 460     FLASH_Lock(FLASH_MEMTYPE_DATA); 
1517  01f8 a6f7          	ld	a,#247
1518  01fa cd0017        	call	_FLASH_Lock
1520                     ; 461 }
1523  01fd 81            	ret
1558                     ; 463 uint8_t Flash_ReadData(uint32_t address) {
1559                     	switch	.text
1560  01fe               _Flash_ReadData:
1562       00000000      OFST:	set	0
1565                     ; 464     return FLASH_ReadByte(address);
1567  01fe 1e05          	ldw	x,(OFST+5,sp)
1568  0200 89            	pushw	x
1569  0201 1e05          	ldw	x,(OFST+5,sp)
1570  0203 89            	pushw	x
1571  0204 cd004e        	call	_FLASH_ReadByte
1573  0207 5b04          	addw	sp,#4
1576  0209 81            	ret
1602                     ; 467 void Flash_Verify(void) {	
1603                     	switch	.text
1604  020a               _Flash_Verify:
1608                     ; 469     data1 = Flash_ReadData(FLASH_START_ADDR);
1610  020a ae4000        	ldw	x,#16384
1611  020d 89            	pushw	x
1612  020e ae0000        	ldw	x,#0
1613  0211 89            	pushw	x
1614  0212 adea          	call	_Flash_ReadData
1616  0214 5b04          	addw	sp,#4
1617  0216 b705          	ld	_data1,a
1618                     ; 470     data2 = Flash_ReadData(FLASH_START_ADDR + 1);
1620  0218 ae4001        	ldw	x,#16385
1621  021b 89            	pushw	x
1622  021c ae0000        	ldw	x,#0
1623  021f 89            	pushw	x
1624  0220 addc          	call	_Flash_ReadData
1626  0222 5b04          	addw	sp,#4
1627  0224 b704          	ld	_data2,a
1628                     ; 471 }
1631  0226 81            	ret
1724                     ; 586 IN_RAM(FLASH_Status_TypeDef FLASH_WaitForLastOperation(FLASH_MemType_TypeDef FLASH_MemType)) 
1724                     ; 587 {
1725                     	switch	.text
1726  0227               _FLASH_WaitForLastOperation:
1728  0227 5203          	subw	sp,#3
1729       00000003      OFST:	set	3
1732                     ; 588   uint8_t flagstatus = 0x00;
1734  0229 0f03          	clr	(OFST+0,sp)
1736                     ; 589   uint16_t timeout = OPERATION_TIMEOUT;
1738  022b aeffff        	ldw	x,#65535
1739  022e 1f01          	ldw	(OFST-2,sp),x
1741                     ; 594     if(FLASH_MemType == FLASH_MEMTYPE_PROG)
1743  0230 a1fd          	cp	a,#253
1744  0232 2628          	jrne	L766
1746  0234 200e          	jra	L556
1747  0236               L356:
1748                     ; 598         flagstatus = (uint8_t)(FLASH->IAPSR & (uint8_t)(FLASH_IAPSR_EOP |
1748                     ; 599                                                         FLASH_IAPSR_WR_PG_DIS));
1750  0236 c6505f        	ld	a,20575
1751  0239 a405          	and	a,#5
1752  023b 6b03          	ld	(OFST+0,sp),a
1754                     ; 600         timeout--;
1756  023d 1e01          	ldw	x,(OFST-2,sp)
1757  023f 1d0001        	subw	x,#1
1758  0242 1f01          	ldw	(OFST-2,sp),x
1760  0244               L556:
1761                     ; 596       while((flagstatus == 0x00) && (timeout != 0x00))
1763  0244 0d03          	tnz	(OFST+0,sp)
1764  0246 261c          	jrne	L366
1766  0248 1e01          	ldw	x,(OFST-2,sp)
1767  024a 26ea          	jrne	L356
1768  024c 2016          	jra	L366
1769  024e               L566:
1770                     ; 607         flagstatus = (uint8_t)(FLASH->IAPSR & (uint8_t)(FLASH_IAPSR_HVOFF |
1770                     ; 608                                                         FLASH_IAPSR_WR_PG_DIS));
1772  024e c6505f        	ld	a,20575
1773  0251 a441          	and	a,#65
1774  0253 6b03          	ld	(OFST+0,sp),a
1776                     ; 609         timeout--;
1778  0255 1e01          	ldw	x,(OFST-2,sp)
1779  0257 1d0001        	subw	x,#1
1780  025a 1f01          	ldw	(OFST-2,sp),x
1782  025c               L766:
1783                     ; 605       while((flagstatus == 0x00) && (timeout != 0x00))
1785  025c 0d03          	tnz	(OFST+0,sp)
1786  025e 2604          	jrne	L366
1788  0260 1e01          	ldw	x,(OFST-2,sp)
1789  0262 26ea          	jrne	L566
1790  0264               L366:
1791                     ; 621   if(timeout == 0x00 )
1793  0264 1e01          	ldw	x,(OFST-2,sp)
1794  0266 2604          	jrne	L576
1795                     ; 623     flagstatus = FLASH_STATUS_TIMEOUT;
1797  0268 a602          	ld	a,#2
1798  026a 6b03          	ld	(OFST+0,sp),a
1800  026c               L576:
1801                     ; 626   return((FLASH_Status_TypeDef)flagstatus);
1803  026c 7b03          	ld	a,(OFST+0,sp)
1806  026e 5b03          	addw	sp,#3
1807  0270 81            	ret
1870                     ; 636 IN_RAM(void FLASH_EraseBlock(uint16_t BlockNum, FLASH_MemType_TypeDef FLASH_MemType))
1870                     ; 637 {
1871                     	switch	.text
1872  0271               _FLASH_EraseBlock:
1874  0271 89            	pushw	x
1875  0272 5206          	subw	sp,#6
1876       00000006      OFST:	set	6
1879                     ; 638   uint32_t startaddress = 0;
1881                     ; 648   assert_param(IS_MEMORY_TYPE_OK(FLASH_MemType));
1883                     ; 649   if(FLASH_MemType == FLASH_MEMTYPE_PROG)
1885  0274 7b0b          	ld	a,(OFST+5,sp)
1886  0276 a1fd          	cp	a,#253
1887  0278 260c          	jrne	L137
1888                     ; 651     assert_param(IS_FLASH_PROG_BLOCK_NUMBER_OK(BlockNum));
1890                     ; 652     startaddress = FLASH_PROG_START_PHYSICAL_ADDRESS;
1892  027a ae8000        	ldw	x,#32768
1893  027d 1f05          	ldw	(OFST-1,sp),x
1894  027f ae0000        	ldw	x,#0
1895  0282 1f03          	ldw	(OFST-3,sp),x
1898  0284 200a          	jra	L337
1899  0286               L137:
1900                     ; 656     assert_param(IS_FLASH_DATA_BLOCK_NUMBER_OK(BlockNum));
1902                     ; 657     startaddress = FLASH_DATA_START_PHYSICAL_ADDRESS;
1904  0286 ae4000        	ldw	x,#16384
1905  0289 1f05          	ldw	(OFST-1,sp),x
1906  028b ae0000        	ldw	x,#0
1907  028e 1f03          	ldw	(OFST-3,sp),x
1909  0290               L337:
1910                     ; 665     pwFlash = (PointerAttr uint32_t *)(MemoryAddressCast)(startaddress + ((uint32_t)BlockNum * FLASH_BLOCK_SIZE));
1912  0290 1e07          	ldw	x,(OFST+1,sp)
1913  0292 a680          	ld	a,#128
1914  0294 cd0000        	call	c_cmulx
1916  0297 96            	ldw	x,sp
1917  0298 1c0003        	addw	x,#OFST-3
1918  029b cd0000        	call	c_ladd
1920  029e be02          	ldw	x,c_lreg+2
1921  02a0 1f01          	ldw	(OFST-5,sp),x
1923                     ; 669   FLASH->CR2 |= FLASH_CR2_ERASE;
1925  02a2 721a505b      	bset	20571,#5
1926                     ; 670   FLASH->NCR2 &= (uint8_t)(~FLASH_NCR2_NERASE);
1928  02a6 721b505c      	bres	20572,#5
1929                     ; 674     *pwFlash = (uint32_t)0;
1931  02aa 1e01          	ldw	x,(OFST-5,sp)
1932  02ac a600          	ld	a,#0
1933  02ae e703          	ld	(3,x),a
1934  02b0 a600          	ld	a,#0
1935  02b2 e702          	ld	(2,x),a
1936  02b4 a600          	ld	a,#0
1937  02b6 e701          	ld	(1,x),a
1938  02b8 a600          	ld	a,#0
1939  02ba f7            	ld	(x),a
1940                     ; 682 }
1943  02bb 5b08          	addw	sp,#8
1944  02bd 81            	ret
2048                     ; 693 IN_RAM(void FLASH_ProgramBlock(uint16_t BlockNum, FLASH_MemType_TypeDef FLASH_MemType, 
2048                     ; 694                         FLASH_ProgramMode_TypeDef FLASH_ProgMode, uint8_t *Buffer))
2048                     ; 695 {
2049                     	switch	.text
2050  02be               _FLASH_ProgramBlock:
2052  02be 89            	pushw	x
2053  02bf 5206          	subw	sp,#6
2054       00000006      OFST:	set	6
2057                     ; 696   uint16_t Count = 0;
2059                     ; 697   uint32_t startaddress = 0;
2061                     ; 700   assert_param(IS_MEMORY_TYPE_OK(FLASH_MemType));
2063                     ; 701   assert_param(IS_FLASH_PROGRAM_MODE_OK(FLASH_ProgMode));
2065                     ; 702   if(FLASH_MemType == FLASH_MEMTYPE_PROG)
2067  02c1 7b0b          	ld	a,(OFST+5,sp)
2068  02c3 a1fd          	cp	a,#253
2069  02c5 260c          	jrne	L7001
2070                     ; 704     assert_param(IS_FLASH_PROG_BLOCK_NUMBER_OK(BlockNum));
2072                     ; 705     startaddress = FLASH_PROG_START_PHYSICAL_ADDRESS;
2074  02c7 ae8000        	ldw	x,#32768
2075  02ca 1f03          	ldw	(OFST-3,sp),x
2076  02cc ae0000        	ldw	x,#0
2077  02cf 1f01          	ldw	(OFST-5,sp),x
2080  02d1 200a          	jra	L1101
2081  02d3               L7001:
2082                     ; 709     assert_param(IS_FLASH_DATA_BLOCK_NUMBER_OK(BlockNum));
2084                     ; 710     startaddress = FLASH_DATA_START_PHYSICAL_ADDRESS;
2086  02d3 ae4000        	ldw	x,#16384
2087  02d6 1f03          	ldw	(OFST-3,sp),x
2088  02d8 ae0000        	ldw	x,#0
2089  02db 1f01          	ldw	(OFST-5,sp),x
2091  02dd               L1101:
2092                     ; 714   startaddress = startaddress + ((uint32_t)BlockNum * FLASH_BLOCK_SIZE);
2094  02dd 1e07          	ldw	x,(OFST+1,sp)
2095  02df a680          	ld	a,#128
2096  02e1 cd0000        	call	c_cmulx
2098  02e4 96            	ldw	x,sp
2099  02e5 1c0001        	addw	x,#OFST-5
2100  02e8 cd0000        	call	c_lgadd
2103                     ; 717   if(FLASH_ProgMode == FLASH_PROGRAMMODE_STANDARD)
2105  02eb 0d0c          	tnz	(OFST+6,sp)
2106  02ed 260a          	jrne	L3101
2107                     ; 720     FLASH->CR2 |= FLASH_CR2_PRG;
2109  02ef 7210505b      	bset	20571,#0
2110                     ; 721     FLASH->NCR2 &= (uint8_t)(~FLASH_NCR2_NPRG);
2112  02f3 7211505c      	bres	20572,#0
2114  02f7 2008          	jra	L5101
2115  02f9               L3101:
2116                     ; 726     FLASH->CR2 |= FLASH_CR2_FPRG;
2118  02f9 7218505b      	bset	20571,#4
2119                     ; 727     FLASH->NCR2 &= (uint8_t)(~FLASH_NCR2_NFPRG);
2121  02fd 7219505c      	bres	20572,#4
2122  0301               L5101:
2123                     ; 731   for(Count = 0; Count < FLASH_BLOCK_SIZE; Count++)
2125  0301 5f            	clrw	x
2126  0302 1f05          	ldw	(OFST-1,sp),x
2128  0304               L7101:
2129                     ; 733     *((PointerAttr uint8_t*) (MemoryAddressCast)startaddress + Count) = ((uint8_t)(Buffer[Count]));
2131  0304 1e0d          	ldw	x,(OFST+7,sp)
2132  0306 72fb05        	addw	x,(OFST-1,sp)
2133  0309 f6            	ld	a,(x)
2134  030a 1e03          	ldw	x,(OFST-3,sp)
2135  030c 72fb05        	addw	x,(OFST-1,sp)
2136  030f f7            	ld	(x),a
2137                     ; 731   for(Count = 0; Count < FLASH_BLOCK_SIZE; Count++)
2139  0310 1e05          	ldw	x,(OFST-1,sp)
2140  0312 1c0001        	addw	x,#1
2141  0315 1f05          	ldw	(OFST-1,sp),x
2145  0317 1e05          	ldw	x,(OFST-1,sp)
2146  0319 a30080        	cpw	x,#128
2147  031c 25e6          	jrult	L7101
2148                     ; 735 }
2151  031e 5b08          	addw	sp,#8
2152  0320 81            	ret
2194                     	xdef	_FLASH_WaitForLastOperation
2195                     	xdef	_FLASH_ProgramBlock
2196                     	xdef	_FLASH_EraseBlock
2197                     	xdef	_Flash_Verify
2198                     	xdef	_Flash_WriteData
2199                     	xdef	_LED_Toggle
2200                     	xdef	_GPIO_Init_LED
2201                     	xdef	_Flash_ReadData
2202                     	xdef	_FLASH_GetFlagStatus
2203                     	xdef	_FLASH_GetBootSize
2204                     	xdef	_FLASH_GetProgrammingTime
2205                     	xdef	_FLASH_GetLowPowerMode
2206                     	xdef	_FLASH_SetProgrammingTime
2207                     	xdef	_FLASH_SetLowPowerMode
2208                     	xdef	_FLASH_EraseOptionByte
2209                     	xdef	_FLASH_ProgramOptionByte
2210                     	xdef	_FLASH_ReadOptionByte
2211                     	xdef	_FLASH_ProgramWord
2212                     	xdef	_FLASH_ReadByte
2213                     	xdef	_FLASH_ProgramByte
2214                     	xdef	_FLASH_EraseByte
2215                     	xdef	_FLASH_ITConfig
2216                     	xdef	_FLASH_DeInit
2217                     	xdef	_FLASH_Lock
2218                     	xdef	_FLASH_Unlock
2219                     	switch	.ubsct
2220  0000               _i:
2221  0000 00000000      	ds.b	4
2222                     	xdef	_i
2223  0004               _data2:
2224  0004 00            	ds.b	1
2225                     	xdef	_data2
2226  0005               _data1:
2227  0005 00            	ds.b	1
2228                     	xdef	_data1
2229                     	xref	_GPIO_WriteReverse
2230                     	xref	_GPIO_Init
2231                     	xref	_GPIO_DeInit
2232                     	xref.b	c_lreg
2233                     	xref.b	c_x
2234                     	xref.b	c_y
2254                     	xref	c_ladd
2255                     	xref	c_cmulx
2256                     	xref	c_ltor
2257                     	xref	c_lgadd
2258                     	xref	c_rtol
2259                     	xref	c_umul
2260                     	end
