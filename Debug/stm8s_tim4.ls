   1                     ; C Compiler for STM8 (COSMIC Software)
   2                     ; Parser V4.13.2 - 04 Jun 2024
   3                     ; Generator (Limited) V4.6.4 - 15 Jan 2025
  14                     	bsct
  15  0000               L3_count:
  16  0000 0000          	dc.w	0
  45                     ; 52 void TIM4_DeInit(void)
  45                     ; 53 {
  47                     	switch	.text
  48  0000               _TIM4_DeInit:
  52                     ; 54   TIM4->CR1 = TIM4_CR1_RESET_VALUE;
  54  0000 725f5340      	clr	21312
  55                     ; 55   TIM4->IER = TIM4_IER_RESET_VALUE;
  57  0004 725f5341      	clr	21313
  58                     ; 56   TIM4->CNTR = TIM4_CNTR_RESET_VALUE;
  60  0008 725f5344      	clr	21316
  61                     ; 57   TIM4->PSCR = TIM4_PSCR_RESET_VALUE;
  63  000c 725f5345      	clr	21317
  64                     ; 58   TIM4->ARR = TIM4_ARR_RESET_VALUE;
  66  0010 35ff5346      	mov	21318,#255
  67                     ; 59   TIM4->SR1 = TIM4_SR1_RESET_VALUE;
  69  0014 725f5342      	clr	21314
  70                     ; 60 }
  73  0018 81            	ret
 179                     ; 68 void TIM4_TimeBaseInit(TIM4_Prescaler_TypeDef TIM4_Prescaler, uint8_t TIM4_Period)
 179                     ; 69 {
 180                     	switch	.text
 181  0019               _TIM4_TimeBaseInit:
 185                     ; 71   assert_param(IS_TIM4_PRESCALER_OK(TIM4_Prescaler));
 187                     ; 73   TIM4->PSCR = (uint8_t)(TIM4_Prescaler);
 189  0019 9e            	ld	a,xh
 190  001a c75345        	ld	21317,a
 191                     ; 75   TIM4->ARR = (uint8_t)(TIM4_Period);
 193  001d 9f            	ld	a,xl
 194  001e c75346        	ld	21318,a
 195                     ; 76 }
 198  0021 81            	ret
 253                     ; 84 void TIM4_Cmd(FunctionalState NewState)
 253                     ; 85 {
 254                     	switch	.text
 255  0022               _TIM4_Cmd:
 259                     ; 87   assert_param(IS_FUNCTIONALSTATE_OK(NewState));
 261                     ; 90   if (NewState != DISABLE)
 263  0022 4d            	tnz	a
 264  0023 2706          	jreq	L711
 265                     ; 92     TIM4->CR1 |= TIM4_CR1_CEN;
 267  0025 72105340      	bset	21312,#0
 269  0029 2004          	jra	L121
 270  002b               L711:
 271                     ; 96     TIM4->CR1 &= (uint8_t)(~TIM4_CR1_CEN);
 273  002b 72115340      	bres	21312,#0
 274  002f               L121:
 275                     ; 98 }
 278  002f 81            	ret
 336                     ; 110 void TIM4_ITConfig(TIM4_IT_TypeDef TIM4_IT, FunctionalState NewState)
 336                     ; 111 {
 337                     	switch	.text
 338  0030               _TIM4_ITConfig:
 340  0030 89            	pushw	x
 341       00000000      OFST:	set	0
 344                     ; 113   assert_param(IS_TIM4_IT_OK(TIM4_IT));
 346                     ; 114   assert_param(IS_FUNCTIONALSTATE_OK(NewState));
 348                     ; 116   if (NewState != DISABLE)
 350  0031 9f            	ld	a,xl
 351  0032 4d            	tnz	a
 352  0033 2709          	jreq	L351
 353                     ; 119     TIM4->IER |= (uint8_t)TIM4_IT;
 355  0035 9e            	ld	a,xh
 356  0036 ca5341        	or	a,21313
 357  0039 c75341        	ld	21313,a
 359  003c 2009          	jra	L551
 360  003e               L351:
 361                     ; 124     TIM4->IER &= (uint8_t)(~TIM4_IT);
 363  003e 7b01          	ld	a,(OFST+1,sp)
 364  0040 43            	cpl	a
 365  0041 c45341        	and	a,21313
 366  0044 c75341        	ld	21313,a
 367  0047               L551:
 368                     ; 126 }
 371  0047 85            	popw	x
 372  0048 81            	ret
 408                     ; 134 void TIM4_UpdateDisableConfig(FunctionalState NewState)
 408                     ; 135 {
 409                     	switch	.text
 410  0049               _TIM4_UpdateDisableConfig:
 414                     ; 137   assert_param(IS_FUNCTIONALSTATE_OK(NewState));
 416                     ; 140   if (NewState != DISABLE)
 418  0049 4d            	tnz	a
 419  004a 2706          	jreq	L571
 420                     ; 142     TIM4->CR1 |= TIM4_CR1_UDIS;
 422  004c 72125340      	bset	21312,#1
 424  0050 2004          	jra	L771
 425  0052               L571:
 426                     ; 146     TIM4->CR1 &= (uint8_t)(~TIM4_CR1_UDIS);
 428  0052 72135340      	bres	21312,#1
 429  0056               L771:
 430                     ; 148 }
 433  0056 81            	ret
 491                     ; 158 void TIM4_UpdateRequestConfig(TIM4_UpdateSource_TypeDef TIM4_UpdateSource)
 491                     ; 159 {
 492                     	switch	.text
 493  0057               _TIM4_UpdateRequestConfig:
 497                     ; 161   assert_param(IS_TIM4_UPDATE_SOURCE_OK(TIM4_UpdateSource));
 499                     ; 164   if (TIM4_UpdateSource != TIM4_UPDATESOURCE_GLOBAL)
 501  0057 4d            	tnz	a
 502  0058 2706          	jreq	L722
 503                     ; 166     TIM4->CR1 |= TIM4_CR1_URS;
 505  005a 72145340      	bset	21312,#2
 507  005e 2004          	jra	L132
 508  0060               L722:
 509                     ; 170     TIM4->CR1 &= (uint8_t)(~TIM4_CR1_URS);
 511  0060 72155340      	bres	21312,#2
 512  0064               L132:
 513                     ; 172 }
 516  0064 81            	ret
 573                     ; 182 void TIM4_SelectOnePulseMode(TIM4_OPMode_TypeDef TIM4_OPMode)
 573                     ; 183 {
 574                     	switch	.text
 575  0065               _TIM4_SelectOnePulseMode:
 579                     ; 185   assert_param(IS_TIM4_OPM_MODE_OK(TIM4_OPMode));
 581                     ; 188   if (TIM4_OPMode != TIM4_OPMODE_REPETITIVE)
 583  0065 4d            	tnz	a
 584  0066 2706          	jreq	L162
 585                     ; 190     TIM4->CR1 |= TIM4_CR1_OPM;
 587  0068 72165340      	bset	21312,#3
 589  006c 2004          	jra	L362
 590  006e               L162:
 591                     ; 194     TIM4->CR1 &= (uint8_t)(~TIM4_CR1_OPM);
 593  006e 72175340      	bres	21312,#3
 594  0072               L362:
 595                     ; 196 }
 598  0072 81            	ret
 666                     ; 218 void TIM4_PrescalerConfig(TIM4_Prescaler_TypeDef Prescaler, TIM4_PSCReloadMode_TypeDef TIM4_PSCReloadMode)
 666                     ; 219 {
 667                     	switch	.text
 668  0073               _TIM4_PrescalerConfig:
 672                     ; 221   assert_param(IS_TIM4_PRESCALER_RELOAD_OK(TIM4_PSCReloadMode));
 674                     ; 222   assert_param(IS_TIM4_PRESCALER_OK(Prescaler));
 676                     ; 225   TIM4->PSCR = (uint8_t)Prescaler;
 678  0073 9e            	ld	a,xh
 679  0074 c75345        	ld	21317,a
 680                     ; 228   TIM4->EGR = (uint8_t)TIM4_PSCReloadMode;
 682  0077 9f            	ld	a,xl
 683  0078 c75343        	ld	21315,a
 684                     ; 229 }
 687  007b 81            	ret
 723                     ; 237 void TIM4_ARRPreloadConfig(FunctionalState NewState)
 723                     ; 238 {
 724                     	switch	.text
 725  007c               _TIM4_ARRPreloadConfig:
 729                     ; 240   assert_param(IS_FUNCTIONALSTATE_OK(NewState));
 731                     ; 243   if (NewState != DISABLE)
 733  007c 4d            	tnz	a
 734  007d 2706          	jreq	L533
 735                     ; 245     TIM4->CR1 |= TIM4_CR1_ARPE;
 737  007f 721e5340      	bset	21312,#7
 739  0083 2004          	jra	L733
 740  0085               L533:
 741                     ; 249     TIM4->CR1 &= (uint8_t)(~TIM4_CR1_ARPE);
 743  0085 721f5340      	bres	21312,#7
 744  0089               L733:
 745                     ; 251 }
 748  0089 81            	ret
 797                     ; 260 void TIM4_GenerateEvent(TIM4_EventSource_TypeDef TIM4_EventSource)
 797                     ; 261 {
 798                     	switch	.text
 799  008a               _TIM4_GenerateEvent:
 803                     ; 263   assert_param(IS_TIM4_EVENT_SOURCE_OK(TIM4_EventSource));
 805                     ; 266   TIM4->EGR = (uint8_t)(TIM4_EventSource);
 807  008a c75343        	ld	21315,a
 808                     ; 267 }
 811  008d 81            	ret
 845                     ; 275 void TIM4_SetCounter(uint8_t Counter)
 845                     ; 276 {
 846                     	switch	.text
 847  008e               _TIM4_SetCounter:
 851                     ; 278   TIM4->CNTR = (uint8_t)(Counter);
 853  008e c75344        	ld	21316,a
 854                     ; 279 }
 857  0091 81            	ret
 891                     ; 287 void TIM4_SetAutoreload(uint8_t Autoreload)
 891                     ; 288 {
 892                     	switch	.text
 893  0092               _TIM4_SetAutoreload:
 897                     ; 290   TIM4->ARR = (uint8_t)(Autoreload);
 899  0092 c75346        	ld	21318,a
 900                     ; 291 }
 903  0095 81            	ret
 926                     ; 298 uint8_t TIM4_GetCounter(void)
 926                     ; 299 {
 927                     	switch	.text
 928  0096               _TIM4_GetCounter:
 932                     ; 301   return (uint8_t)(TIM4->CNTR);
 934  0096 c65344        	ld	a,21316
 937  0099 81            	ret
 961                     ; 309 TIM4_Prescaler_TypeDef TIM4_GetPrescaler(void)
 961                     ; 310 {
 962                     	switch	.text
 963  009a               _TIM4_GetPrescaler:
 967                     ; 312   return (TIM4_Prescaler_TypeDef)(TIM4->PSCR);
 969  009a c65345        	ld	a,21317
 972  009d 81            	ret
1051                     ; 322 FlagStatus TIM4_GetFlagStatus(TIM4_FLAG_TypeDef TIM4_FLAG)
1051                     ; 323 {
1052                     	switch	.text
1053  009e               _TIM4_GetFlagStatus:
1055  009e 88            	push	a
1056       00000001      OFST:	set	1
1059                     ; 324   FlagStatus bitstatus = RESET;
1061                     ; 327   assert_param(IS_TIM4_GET_FLAG_OK(TIM4_FLAG));
1063                     ; 329   if ((TIM4->SR1 & (uint8_t)TIM4_FLAG)  != 0)
1065  009f c45342        	and	a,21314
1066  00a2 2706          	jreq	L105
1067                     ; 331     bitstatus = SET;
1069  00a4 a601          	ld	a,#1
1070  00a6 6b01          	ld	(OFST+0,sp),a
1073  00a8 2002          	jra	L305
1074  00aa               L105:
1075                     ; 335     bitstatus = RESET;
1077  00aa 0f01          	clr	(OFST+0,sp)
1079  00ac               L305:
1080                     ; 337   return ((FlagStatus)bitstatus);
1082  00ac 7b01          	ld	a,(OFST+0,sp)
1085  00ae 5b01          	addw	sp,#1
1086  00b0 81            	ret
1121                     ; 347 void TIM4_ClearFlag(TIM4_FLAG_TypeDef TIM4_FLAG)
1121                     ; 348 {
1122                     	switch	.text
1123  00b1               _TIM4_ClearFlag:
1127                     ; 350   assert_param(IS_TIM4_GET_FLAG_OK(TIM4_FLAG));
1129                     ; 353   TIM4->SR1 = (uint8_t)(~TIM4_FLAG);
1131  00b1 43            	cpl	a
1132  00b2 c75342        	ld	21314,a
1133                     ; 354 }
1136  00b5 81            	ret
1200                     ; 363 ITStatus TIM4_GetITStatus(TIM4_IT_TypeDef TIM4_IT)
1200                     ; 364 {
1201                     	switch	.text
1202  00b6               _TIM4_GetITStatus:
1204  00b6 88            	push	a
1205  00b7 89            	pushw	x
1206       00000002      OFST:	set	2
1209                     ; 365   ITStatus bitstatus = RESET;
1211                     ; 367   uint8_t itstatus = 0x0, itenable = 0x0;
1215                     ; 370   assert_param(IS_TIM4_IT_OK(TIM4_IT));
1217                     ; 372   itstatus = (uint8_t)(TIM4->SR1 & (uint8_t)TIM4_IT);
1219  00b8 c45342        	and	a,21314
1220  00bb 6b01          	ld	(OFST-1,sp),a
1222                     ; 374   itenable = (uint8_t)(TIM4->IER & (uint8_t)TIM4_IT);
1224  00bd c65341        	ld	a,21313
1225  00c0 1403          	and	a,(OFST+1,sp)
1226  00c2 6b02          	ld	(OFST+0,sp),a
1228                     ; 376   if ((itstatus != (uint8_t)RESET ) && (itenable != (uint8_t)RESET ))
1230  00c4 0d01          	tnz	(OFST-1,sp)
1231  00c6 270a          	jreq	L555
1233  00c8 0d02          	tnz	(OFST+0,sp)
1234  00ca 2706          	jreq	L555
1235                     ; 378     bitstatus = (ITStatus)SET;
1237  00cc a601          	ld	a,#1
1238  00ce 6b02          	ld	(OFST+0,sp),a
1241  00d0 2002          	jra	L755
1242  00d2               L555:
1243                     ; 382     bitstatus = (ITStatus)RESET;
1245  00d2 0f02          	clr	(OFST+0,sp)
1247  00d4               L755:
1248                     ; 384   return ((ITStatus)bitstatus);
1250  00d4 7b02          	ld	a,(OFST+0,sp)
1253  00d6 5b03          	addw	sp,#3
1254  00d8 81            	ret
1290                     ; 394 void TIM4_ClearITPendingBit(TIM4_IT_TypeDef TIM4_IT)
1290                     ; 395 {
1291                     	switch	.text
1292  00d9               _TIM4_ClearITPendingBit:
1296                     ; 397   assert_param(IS_TIM4_IT_OK(TIM4_IT));
1298                     ; 400   TIM4->SR1 = (uint8_t)(~TIM4_IT);
1300  00d9 43            	cpl	a
1301  00da c75342        	ld	21314,a
1302                     ; 401 }
1305  00dd 81            	ret
1334                     ; 403 void TIM4_Init(void) {
1335                     	switch	.text
1336  00de               _TIM4_Init:
1340                     ; 404 		TIM4_DeInit();
1342  00de cd0000        	call	_TIM4_DeInit
1344                     ; 405     TIM4_TimeBaseInit(TIM4_PRESCALER_64, 124); 
1346  00e1 ae067c        	ldw	x,#1660
1347  00e4 cd0019        	call	_TIM4_TimeBaseInit
1349                     ; 406 		TIM4_ClearFlag(TIM4_FLAG_UPDATE);
1351  00e7 a601          	ld	a,#1
1352  00e9 adc6          	call	_TIM4_ClearFlag
1354                     ; 407     TIM4_ITConfig(TIM4_IT_UPDATE, DISABLE);
1356  00eb ae0100        	ldw	x,#256
1357  00ee cd0030        	call	_TIM4_ITConfig
1359                     ; 408     TIM4_Cmd(ENABLE);
1361  00f1 a601          	ld	a,#1
1362  00f3 cd0022        	call	_TIM4_Cmd
1365  00f6               L116:
1366                     ; 410 		while(SET !=TIM4_GetFlagStatus(TIM4_FLAG_UPDATE));
1368  00f6 a601          	ld	a,#1
1369  00f8 ada4          	call	_TIM4_GetFlagStatus
1371  00fa a101          	cp	a,#1
1372  00fc 26f8          	jrne	L116
1373                     ; 411 }
1376  00fe 81            	ret
1411                     ; 413 void Delay_ms(uint32_t ms) {
1412                     	switch	.text
1413  00ff               _Delay_ms:
1415       00000000      OFST:	set	0
1418  00ff 2002          	jra	L536
1419  0101               L336:
1420                     ; 416 		TIM4_Init();
1422  0101 addb          	call	_TIM4_Init
1424  0103               L536:
1425                     ; 415 	 while(ms--)
1427  0103 96            	ldw	x,sp
1428  0104 1c0003        	addw	x,#OFST+3
1429  0107 cd0000        	call	c_ltor
1431  010a 96            	ldw	x,sp
1432  010b 1c0003        	addw	x,#OFST+3
1433  010e a601          	ld	a,#1
1434  0110 cd0000        	call	c_lgsbc
1436  0113 cd0000        	call	c_lrzmp
1438  0116 26e9          	jrne	L336
1439                     ; 417 }
1442  0118 81            	ret
1477                     ; 419 void Delay_ms_int(uint16_t ms) {
1478                     	switch	.text
1479  0119               _Delay_ms_int:
1481  0119 89            	pushw	x
1482       00000000      OFST:	set	0
1485                     ; 420 	count=0;
1487  011a 5f            	clrw	x
1488  011b bf00          	ldw	L3_count,x
1490  011d               L366:
1491                     ; 421 	while(count != ms);
1493  011d be00          	ldw	x,L3_count
1494  011f 1301          	cpw	x,(OFST+1,sp)
1495  0121 26fa          	jrne	L366
1496                     ; 422 }
1499  0123 85            	popw	x
1500  0124 81            	ret
1525                     ; 425 @far @interrupt void Tim4Update_isr(void) {
1527                     	switch	.text
1528  0125               f_Tim4Update_isr:
1530  0125 8a            	push	cc
1531  0126 84            	pop	a
1532  0127 a4bf          	and	a,#191
1533  0129 88            	push	a
1534  012a 86            	pop	cc
1535  012b 3b0002        	push	c_x+2
1536  012e be00          	ldw	x,c_x
1537  0130 89            	pushw	x
1538  0131 3b0002        	push	c_y+2
1539  0134 be00          	ldw	x,c_y
1540  0136 89            	pushw	x
1543                     ; 427 	count++;
1545  0137 be00          	ldw	x,L3_count
1546  0139 1c0001        	addw	x,#1
1547  013c bf00          	ldw	L3_count,x
1548                     ; 428 	TIM4_ClearITPendingBit(TIM4_IT_UPDATE);
1550  013e a601          	ld	a,#1
1551  0140 ad97          	call	_TIM4_ClearITPendingBit
1553                     ; 429 }
1556  0142 85            	popw	x
1557  0143 bf00          	ldw	c_y,x
1558  0145 320002        	pop	c_y+2
1559  0148 85            	popw	x
1560  0149 bf00          	ldw	c_x,x
1561  014b 320002        	pop	c_x+2
1562  014e 80            	iret
1590                     ; 431 void MX_TIM4_Init(void)
1590                     ; 432 {
1592                     	switch	.text
1593  014f               _MX_TIM4_Init:
1597                     ; 433 	TIM4_DeInit();
1599  014f cd0000        	call	_TIM4_DeInit
1601                     ; 434 	TIM4_TimeBaseInit(TIM4_PRESCALER_64, 124);
1603  0152 ae067c        	ldw	x,#1660
1604  0155 cd0019        	call	_TIM4_TimeBaseInit
1606                     ; 435 	TIM4_ARRPreloadConfig(ENABLE);
1608  0158 a601          	ld	a,#1
1609  015a cd007c        	call	_TIM4_ARRPreloadConfig
1611                     ; 437 	TIM4_ClearFlag(TIM4_FLAG_UPDATE);
1613  015d a601          	ld	a,#1
1614  015f cd00b1        	call	_TIM4_ClearFlag
1616                     ; 440 	TIM4_ITConfig(TIM4_IT_UPDATE, ENABLE);
1618  0162 ae0101        	ldw	x,#257
1619  0165 cd0030        	call	_TIM4_ITConfig
1621                     ; 441 	TIM4_Cmd(ENABLE);
1623  0168 a601          	ld	a,#1
1624  016a cd0022        	call	_TIM4_Cmd
1626                     ; 444 }
1629  016d 81            	ret
1653                     	xdef	f_Tim4Update_isr
1654                     	xdef	_MX_TIM4_Init
1655                     	xdef	_Delay_ms_int
1656                     	xdef	_Delay_ms
1657                     	xdef	_TIM4_Init
1658                     	xdef	_TIM4_ClearITPendingBit
1659                     	xdef	_TIM4_GetITStatus
1660                     	xdef	_TIM4_ClearFlag
1661                     	xdef	_TIM4_GetFlagStatus
1662                     	xdef	_TIM4_GetPrescaler
1663                     	xdef	_TIM4_GetCounter
1664                     	xdef	_TIM4_SetAutoreload
1665                     	xdef	_TIM4_SetCounter
1666                     	xdef	_TIM4_GenerateEvent
1667                     	xdef	_TIM4_ARRPreloadConfig
1668                     	xdef	_TIM4_PrescalerConfig
1669                     	xdef	_TIM4_SelectOnePulseMode
1670                     	xdef	_TIM4_UpdateRequestConfig
1671                     	xdef	_TIM4_UpdateDisableConfig
1672                     	xdef	_TIM4_ITConfig
1673                     	xdef	_TIM4_Cmd
1674                     	xdef	_TIM4_TimeBaseInit
1675                     	xdef	_TIM4_DeInit
1676                     	xref.b	c_x
1677                     	xref.b	c_y
1696                     	xref	c_lrzmp
1697                     	xref	c_lgsbc
1698                     	xref	c_ltor
1699                     	end
