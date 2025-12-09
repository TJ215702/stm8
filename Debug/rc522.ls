   1                     ; C Compiler for STM8 (COSMIC Software)
   2                     ; Parser V4.13.2 - 04 Jun 2024
   3                     ; Generator (Limited) V4.6.4 - 15 Jan 2025
  14                     	bsct
  15  0000               _key:
  16  0000 ff            	dc.b	255
  17  0001 ff            	dc.b	255
  18  0002 ff            	dc.b	255
  19  0003 ff            	dc.b	255
  20  0004 ff            	dc.b	255
  21  0005 ff            	dc.b	255
  74                     ; 23 void delay_ns(u32 ns)
  74                     ; 24 {
  76                     	switch	.text
  77  0000               _delay_ns:
  79  0000 5204          	subw	sp,#4
  80       00000004      OFST:	set	4
  83                     ; 26   for(i=0;i<ns;i++)
  85  0002 ae0000        	ldw	x,#0
  86  0005 1f03          	ldw	(OFST-1,sp),x
  87  0007 ae0000        	ldw	x,#0
  88  000a 1f01          	ldw	(OFST-3,sp),x
  91  000c 200c          	jra	L73
  92  000e               L33:
  93                     ; 28 		__asm("nop");
  96  000e 9d            nop
  98                     ; 29 		__asm("nop");
 101  000f 9d            nop
 103                     ; 30 		__asm("nop");
 106  0010 9d            nop
 108                     ; 26   for(i=0;i<ns;i++)
 110  0011 96            	ldw	x,sp
 111  0012 1c0001        	addw	x,#OFST-3
 112  0015 a601          	ld	a,#1
 113  0017 cd0000        	call	c_lgadc
 116  001a               L73:
 119  001a 96            	ldw	x,sp
 120  001b 1c0001        	addw	x,#OFST-3
 121  001e cd0000        	call	c_ltor
 123  0021 96            	ldw	x,sp
 124  0022 1c0007        	addw	x,#OFST+3
 125  0025 cd0000        	call	c_lcmp
 127  0028 25e4          	jrult	L33
 128                     ; 32 }
 131  002a 5b04          	addw	sp,#4
 132  002c 81            	ret
 169                     ; 35 u8 SPIWriteByte(u8 Byte)
 169                     ; 36 {
 170                     	switch	.text
 171  002d               _SPIWriteByte:
 173  002d 88            	push	a
 174       00000000      OFST:	set	0
 177  002e               L36:
 178                     ; 39   while (SPI_GetFlagStatus( SPI_FLAG_TXE) == RESET);
 180  002e a602          	ld	a,#2
 181  0030 cd0000        	call	_SPI_GetFlagStatus
 183  0033 4d            	tnz	a
 184  0034 27f8          	jreq	L36
 185                     ; 42   SPI_SendData(Byte);
 187  0036 7b01          	ld	a,(OFST+1,sp)
 188  0038 cd0000        	call	_SPI_SendData
 191  003b               L17:
 192                     ; 45   while (SPI_GetFlagStatus(SPI_FLAG_RXNE) == RESET);
 194  003b a601          	ld	a,#1
 195  003d cd0000        	call	_SPI_GetFlagStatus
 197  0040 4d            	tnz	a
 198  0041 27f8          	jreq	L17
 199                     ; 48   return SPI_ReceiveData();	
 201  0043 cd0000        	call	_SPI_ReceiveData
 205  0046 5b01          	addw	sp,#1
 206  0048 81            	ret
 232                     ; 52 void SPI2_Init(void)	
 232                     ; 53 {
 233                     	switch	.text
 234  0049               _SPI2_Init:
 238                     ; 55     SPI_Init(SPI_FIRSTBIT_MSB, SPI_BAUDRATEPRESCALER_2, SPI_MODE_MASTER,\
 238                     ; 56             SPI_CLOCKPOLARITY_HIGH, SPI_CLOCKPHASE_2EDGE, \
 238                     ; 57             SPI_DATADIRECTION_2LINES_FULLDUPLEX, SPI_NSS_SOFT, 0x07);
 240  0049 4b07          	push	#7
 241  004b 4b02          	push	#2
 242  004d 4b00          	push	#0
 243  004f 4b01          	push	#1
 244  0051 4b02          	push	#2
 245  0053 4b04          	push	#4
 246  0055 5f            	clrw	x
 247  0056 cd0000        	call	_SPI_Init
 249  0059 5b06          	addw	sp,#6
 250                     ; 58     SPI_Cmd(ENABLE);
 252  005b a601          	ld	a,#1
 253  005d cd0000        	call	_SPI_Cmd
 255                     ; 59     GPIO_Init( RC522NSS_GPIO_PORT, RC522NSS_GPIO_PIN, GPIO_MODE_OUT_PP_HIGH_FAST);
 257  0060 4bf0          	push	#240
 258  0062 4b10          	push	#16
 259  0064 ae500a        	ldw	x,#20490
 260  0067 cd0000        	call	_GPIO_Init
 262  006a 85            	popw	x
 263                     ; 60     GPIO_Init( RC522RST_GPIO_PORT, RC522RST_GPIO_PIN, GPIO_MODE_OUT_PP_HIGH_FAST);
 265  006b 4bf0          	push	#240
 266  006d 4b08          	push	#8
 267  006f ae500a        	ldw	x,#20490
 268  0072 cd0000        	call	_GPIO_Init
 270  0075 85            	popw	x
 271                     ; 62 }
 274  0076 81            	ret
 302                     ; 64 void InitRc522(void)
 302                     ; 65 {
 303                     	switch	.text
 304  0077               _InitRc522:
 308                     ; 66   SPI2_Init();
 310  0077 add0          	call	_SPI2_Init
 312                     ; 67   PcdReset();
 314  0079 cd0412        	call	_PcdReset
 316                     ; 68   PcdAntennaOff();  
 318  007c cd067a        	call	_PcdAntennaOff
 320                     ; 69   PcdAntennaOn();
 322  007f cd0664        	call	_PcdAntennaOn
 324                     ; 70   M500PcdConfigISOType( 'A' );
 326  0082 a641          	ld	a,#65
 327  0084 cd047e        	call	_M500PcdConfigISOType
 329                     ; 71 }
 332  0087 81            	ret
 358                     ; 72 void Reset_RC522(void)
 358                     ; 73 {
 359                     	switch	.text
 360  0088               _Reset_RC522:
 364                     ; 74   PcdReset();
 366  0088 cd0412        	call	_PcdReset
 368                     ; 75   PcdAntennaOff();  
 370  008b cd067a        	call	_PcdAntennaOff
 372                     ; 76   PcdAntennaOn();    
 374  008e cd0664        	call	_PcdAntennaOn
 376                     ; 77 }                         
 379  0091 81            	ret
 455                     ; 91 char PcdRequest(u8   req_code,u8 *pTagType)
 455                     ; 92 {
 456                     	switch	.text
 457  0092               _PcdRequest:
 459  0092 88            	push	a
 460  0093 5214          	subw	sp,#20
 461       00000014      OFST:	set	20
 464                     ; 97 	ClearBitMask(Status2Reg,0x08);
 466  0095 ae0808        	ldw	x,#2056
 467  0098 cd0511        	call	_ClearBitMask
 469                     ; 98 	WriteRawRC(BitFramingReg,0x07);
 471  009b ae0d07        	ldw	x,#3335
 472  009e cd04e0        	call	_WriteRawRC
 474                     ; 99 	SetBitMask(TxControlReg,0x03);
 476  00a1 ae1403        	ldw	x,#5123
 477  00a4 cd04fd        	call	_SetBitMask
 479                     ; 101 	ucComMF522Buf[0] = req_code;
 481  00a7 7b15          	ld	a,(OFST+1,sp)
 482  00a9 6b03          	ld	(OFST-17,sp),a
 484                     ; 103 	status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,1,ucComMF522Buf,&unLen);
 486  00ab 96            	ldw	x,sp
 487  00ac 1c0001        	addw	x,#OFST-19
 488  00af 89            	pushw	x
 489  00b0 96            	ldw	x,sp
 490  00b1 1c0005        	addw	x,#OFST-15
 491  00b4 89            	pushw	x
 492  00b5 4b01          	push	#1
 493  00b7 96            	ldw	x,sp
 494  00b8 1c0008        	addw	x,#OFST-12
 495  00bb 89            	pushw	x
 496  00bc a60c          	ld	a,#12
 497  00be cd0526        	call	_PcdComMF522
 499  00c1 5b07          	addw	sp,#7
 500  00c3 6b02          	ld	(OFST-18,sp),a
 502                     ; 105 	if ((status == MI_OK) && (unLen == 0x10))
 504  00c5 0d02          	tnz	(OFST-18,sp)
 505  00c7 2613          	jrne	L361
 507  00c9 7b01          	ld	a,(OFST-19,sp)
 508  00cb a110          	cp	a,#16
 509  00cd 260d          	jrne	L361
 510                     ; 107 		*pTagType     = ucComMF522Buf[0];
 512  00cf 7b03          	ld	a,(OFST-17,sp)
 513  00d1 1e18          	ldw	x,(OFST+4,sp)
 514  00d3 f7            	ld	(x),a
 515                     ; 108 		*(pTagType+1) = ucComMF522Buf[1];
 517  00d4 7b04          	ld	a,(OFST-16,sp)
 518  00d6 1e18          	ldw	x,(OFST+4,sp)
 519  00d8 e701          	ld	(1,x),a
 521  00da 2004          	jra	L561
 522  00dc               L361:
 523                     ; 111 	{   status = MI_ERR;   }
 525  00dc a602          	ld	a,#2
 526  00de 6b02          	ld	(OFST-18,sp),a
 528  00e0               L561:
 529                     ; 113 	return status;
 531  00e0 7b02          	ld	a,(OFST-18,sp)
 534  00e2 5b15          	addw	sp,#21
 535  00e4 81            	ret
 620                     ; 121 char PcdAnticoll(u8 *pSnr)
 620                     ; 122 {
 621                     	switch	.text
 622  00e5               _PcdAnticoll:
 624  00e5 89            	pushw	x
 625  00e6 5216          	subw	sp,#22
 626       00000016      OFST:	set	22
 629                     ; 124     u8   i,snr_check=0;
 631  00e8 0f03          	clr	(OFST-19,sp)
 633                     ; 129     ClearBitMask(Status2Reg,0x08);
 635  00ea ae0808        	ldw	x,#2056
 636  00ed cd0511        	call	_ClearBitMask
 638                     ; 130     WriteRawRC(BitFramingReg,0x00);
 640  00f0 ae0d00        	ldw	x,#3328
 641  00f3 cd04e0        	call	_WriteRawRC
 643                     ; 131     ClearBitMask(CollReg,0x80);
 645  00f6 ae0e80        	ldw	x,#3712
 646  00f9 cd0511        	call	_ClearBitMask
 648                     ; 133     ucComMF522Buf[0] = PICC_ANTICOLL1;
 650  00fc a693          	ld	a,#147
 651  00fe 6b04          	ld	(OFST-18,sp),a
 653                     ; 134     ucComMF522Buf[1] = 0x20;
 655  0100 a620          	ld	a,#32
 656  0102 6b05          	ld	(OFST-17,sp),a
 658                     ; 136     status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,2,ucComMF522Buf,&unLen);
 660  0104 96            	ldw	x,sp
 661  0105 1c0001        	addw	x,#OFST-21
 662  0108 89            	pushw	x
 663  0109 96            	ldw	x,sp
 664  010a 1c0006        	addw	x,#OFST-16
 665  010d 89            	pushw	x
 666  010e 4b02          	push	#2
 667  0110 96            	ldw	x,sp
 668  0111 1c0009        	addw	x,#OFST-13
 669  0114 89            	pushw	x
 670  0115 a60c          	ld	a,#12
 671  0117 cd0526        	call	_PcdComMF522
 673  011a 5b07          	addw	sp,#7
 674  011c 6b02          	ld	(OFST-20,sp),a
 676                     ; 138     if (status == MI_OK)
 678  011e 0d02          	tnz	(OFST-20,sp)
 679  0120 2647          	jrne	L132
 680                     ; 140     	 for (i=0; i<4; i++)
 682  0122 0f16          	clr	(OFST+0,sp)
 684  0124               L332:
 685                     ; 142              *(pSnr+i)  = ucComMF522Buf[i];
 687  0124 7b16          	ld	a,(OFST+0,sp)
 688  0126 5f            	clrw	x
 689  0127 97            	ld	xl,a
 690  0128 72fb17        	addw	x,(OFST+1,sp)
 691  012b 89            	pushw	x
 692  012c 96            	ldw	x,sp
 693  012d 1c0006        	addw	x,#OFST-16
 694  0130 9f            	ld	a,xl
 695  0131 5e            	swapw	x
 696  0132 1b18          	add	a,(OFST+2,sp)
 697  0134 2401          	jrnc	L22
 698  0136 5c            	incw	x
 699  0137               L22:
 700  0137 02            	rlwa	x,a
 701  0138 f6            	ld	a,(x)
 702  0139 85            	popw	x
 703  013a f7            	ld	(x),a
 704                     ; 143              snr_check ^= ucComMF522Buf[i];
 706  013b 96            	ldw	x,sp
 707  013c 1c0004        	addw	x,#OFST-18
 708  013f 9f            	ld	a,xl
 709  0140 5e            	swapw	x
 710  0141 1b16          	add	a,(OFST+0,sp)
 711  0143 2401          	jrnc	L42
 712  0145 5c            	incw	x
 713  0146               L42:
 714  0146 02            	rlwa	x,a
 715  0147 7b03          	ld	a,(OFST-19,sp)
 716  0149 f8            	xor	a,(x)
 717  014a 6b03          	ld	(OFST-19,sp),a
 719                     ; 140     	 for (i=0; i<4; i++)
 721  014c 0c16          	inc	(OFST+0,sp)
 725  014e 7b16          	ld	a,(OFST+0,sp)
 726  0150 a104          	cp	a,#4
 727  0152 25d0          	jrult	L332
 728                     ; 145          if (snr_check != ucComMF522Buf[i])
 730  0154 96            	ldw	x,sp
 731  0155 1c0004        	addw	x,#OFST-18
 732  0158 9f            	ld	a,xl
 733  0159 5e            	swapw	x
 734  015a 1b16          	add	a,(OFST+0,sp)
 735  015c 2401          	jrnc	L62
 736  015e 5c            	incw	x
 737  015f               L62:
 738  015f 02            	rlwa	x,a
 739  0160 f6            	ld	a,(x)
 740  0161 1103          	cp	a,(OFST-19,sp)
 741  0163 2704          	jreq	L132
 742                     ; 146          {   status = MI_ERR;    }
 744  0165 a602          	ld	a,#2
 745  0167 6b02          	ld	(OFST-20,sp),a
 747  0169               L132:
 748                     ; 149     SetBitMask(CollReg,0x80);
 750  0169 ae0e80        	ldw	x,#3712
 751  016c cd04fd        	call	_SetBitMask
 753                     ; 150     return status;
 755  016f 7b02          	ld	a,(OFST-20,sp)
 758  0171 5b18          	addw	sp,#24
 759  0173 81            	ret
 834                     ; 158 char PcdSelect(u8 *pSnr)
 834                     ; 159 {
 835                     	switch	.text
 836  0174               _PcdSelect:
 838  0174 89            	pushw	x
 839  0175 5214          	subw	sp,#20
 840       00000014      OFST:	set	20
 843                     ; 165     ucComMF522Buf[0] = PICC_ANTICOLL1;
 845  0177 a693          	ld	a,#147
 846  0179 6b02          	ld	(OFST-18,sp),a
 848                     ; 166     ucComMF522Buf[1] = 0x70;
 850  017b a670          	ld	a,#112
 851  017d 6b03          	ld	(OFST-17,sp),a
 853                     ; 167     ucComMF522Buf[6] = 0;
 855  017f 0f08          	clr	(OFST-12,sp)
 857                     ; 168     for (i=0; i<4; i++)
 859  0181 0f14          	clr	(OFST+0,sp)
 861  0183               L103:
 862                     ; 170     	ucComMF522Buf[i+2] = *(pSnr+i);
 864  0183 96            	ldw	x,sp
 865  0184 1c0004        	addw	x,#OFST-16
 866  0187 9f            	ld	a,xl
 867  0188 5e            	swapw	x
 868  0189 1b14          	add	a,(OFST+0,sp)
 869  018b 2401          	jrnc	L23
 870  018d 5c            	incw	x
 871  018e               L23:
 872  018e 02            	rlwa	x,a
 873  018f 7b14          	ld	a,(OFST+0,sp)
 874  0191 905f          	clrw	y
 875  0193 9097          	ld	yl,a
 876  0195 72f915        	addw	y,(OFST+1,sp)
 877  0198 90f6          	ld	a,(y)
 878  019a f7            	ld	(x),a
 879                     ; 171     	ucComMF522Buf[6]  ^= *(pSnr+i);
 881  019b 7b14          	ld	a,(OFST+0,sp)
 882  019d 5f            	clrw	x
 883  019e 97            	ld	xl,a
 884  019f 72fb15        	addw	x,(OFST+1,sp)
 885  01a2 7b08          	ld	a,(OFST-12,sp)
 886  01a4 f8            	xor	a,(x)
 887  01a5 6b08          	ld	(OFST-12,sp),a
 889                     ; 168     for (i=0; i<4; i++)
 891  01a7 0c14          	inc	(OFST+0,sp)
 895  01a9 7b14          	ld	a,(OFST+0,sp)
 896  01ab a104          	cp	a,#4
 897  01ad 25d4          	jrult	L103
 898                     ; 173     CalulateCRC(ucComMF522Buf,7,&ucComMF522Buf[7]);
 900  01af 96            	ldw	x,sp
 901  01b0 1c0009        	addw	x,#OFST-11
 902  01b3 89            	pushw	x
 903  01b4 4b07          	push	#7
 904  01b6 96            	ldw	x,sp
 905  01b7 1c0005        	addw	x,#OFST-15
 906  01ba cd03b2        	call	_CalulateCRC
 908  01bd 5b03          	addw	sp,#3
 909                     ; 175     ClearBitMask(Status2Reg,0x08);
 911  01bf ae0808        	ldw	x,#2056
 912  01c2 cd0511        	call	_ClearBitMask
 914                     ; 177     status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,9,ucComMF522Buf,&unLen);
 916  01c5 96            	ldw	x,sp
 917  01c6 1c0001        	addw	x,#OFST-19
 918  01c9 89            	pushw	x
 919  01ca 96            	ldw	x,sp
 920  01cb 1c0004        	addw	x,#OFST-16
 921  01ce 89            	pushw	x
 922  01cf 4b09          	push	#9
 923  01d1 96            	ldw	x,sp
 924  01d2 1c0007        	addw	x,#OFST-13
 925  01d5 89            	pushw	x
 926  01d6 a60c          	ld	a,#12
 927  01d8 cd0526        	call	_PcdComMF522
 929  01db 5b07          	addw	sp,#7
 930  01dd 6b14          	ld	(OFST+0,sp),a
 932                     ; 179     if ((status == MI_OK) && (unLen == 0x18))
 934  01df 0d14          	tnz	(OFST+0,sp)
 935  01e1 260a          	jrne	L703
 937  01e3 7b01          	ld	a,(OFST-19,sp)
 938  01e5 a118          	cp	a,#24
 939  01e7 2604          	jrne	L703
 940                     ; 180     {   status = MI_OK;  }
 942  01e9 0f14          	clr	(OFST+0,sp)
 945  01eb 2004          	jra	L113
 946  01ed               L703:
 947                     ; 182     {   status = MI_ERR;    }
 949  01ed a602          	ld	a,#2
 950  01ef 6b14          	ld	(OFST+0,sp),a
 952  01f1               L113:
 953                     ; 184     return status;
 955  01f1 7b14          	ld	a,(OFST+0,sp)
 958  01f3 5b16          	addw	sp,#22
 959  01f5 81            	ret
1053                     ; 197 char PcdAuthState(u8 auth_mode,u8 addr,u8 *pKey,u8 *pSnr)
1053                     ; 198 {
1054                     	switch	.text
1055  01f6               _PcdAuthState:
1057  01f6 89            	pushw	x
1058  01f7 5214          	subw	sp,#20
1059       00000014      OFST:	set	20
1062                     ; 203     ucComMF522Buf[0] = auth_mode;
1064  01f9 9e            	ld	a,xh
1065  01fa 6b03          	ld	(OFST-17,sp),a
1067                     ; 204     ucComMF522Buf[1] = addr;
1069  01fc 9f            	ld	a,xl
1070  01fd 6b04          	ld	(OFST-16,sp),a
1072                     ; 209     memcpy(&ucComMF522Buf[2], pKey, 6); 
1074  01ff 96            	ldw	x,sp
1075  0200 1c0005        	addw	x,#OFST-15
1076  0203 bf00          	ldw	c_x,x
1077  0205 1619          	ldw	y,(OFST+5,sp)
1078  0207 90bf00        	ldw	c_y,y
1079  020a ae0006        	ldw	x,#6
1080  020d               L63:
1081  020d 5a            	decw	x
1082  020e 92d600        	ld	a,([c_y.w],x)
1083  0211 92d700        	ld	([c_x.w],x),a
1084  0214 5d            	tnzw	x
1085  0215 26f6          	jrne	L63
1086                     ; 210     memcpy(&ucComMF522Buf[8], pSnr, 4); 
1088  0217 96            	ldw	x,sp
1089  0218 1c000b        	addw	x,#OFST-9
1090  021b bf00          	ldw	c_x,x
1091  021d 161b          	ldw	y,(OFST+7,sp)
1092  021f 90bf00        	ldw	c_y,y
1093  0222 ae0004        	ldw	x,#4
1094  0225               L04:
1095  0225 5a            	decw	x
1096  0226 92d600        	ld	a,([c_y.w],x)
1097  0229 92d700        	ld	([c_x.w],x),a
1098  022c 5d            	tnzw	x
1099  022d 26f6          	jrne	L04
1100                     ; 212     status = PcdComMF522(PCD_AUTHENT,ucComMF522Buf,12,ucComMF522Buf,&unLen);
1102  022f 96            	ldw	x,sp
1103  0230 1c0001        	addw	x,#OFST-19
1104  0233 89            	pushw	x
1105  0234 96            	ldw	x,sp
1106  0235 1c0005        	addw	x,#OFST-15
1107  0238 89            	pushw	x
1108  0239 4b0c          	push	#12
1109  023b 96            	ldw	x,sp
1110  023c 1c0008        	addw	x,#OFST-12
1111  023f 89            	pushw	x
1112  0240 a60e          	ld	a,#14
1113  0242 cd0526        	call	_PcdComMF522
1115  0245 5b07          	addw	sp,#7
1116  0247 6b02          	ld	(OFST-18,sp),a
1118                     ; 213     if ((status != MI_OK) || (!(ReadRawRC(Status2Reg) & 0x08)))
1120  0249 0d02          	tnz	(OFST-18,sp)
1121  024b 2609          	jrne	L363
1123  024d a608          	ld	a,#8
1124  024f cd04c0        	call	_ReadRawRC
1126  0252 a508          	bcp	a,#8
1127  0254 2604          	jrne	L163
1128  0256               L363:
1129                     ; 214     {   status = MI_ERR;   }
1131  0256 a602          	ld	a,#2
1132  0258 6b02          	ld	(OFST-18,sp),a
1134  025a               L163:
1135                     ; 216     return status;
1137  025a 7b02          	ld	a,(OFST-18,sp)
1140  025c 5b16          	addw	sp,#22
1141  025e 81            	ret
1224                     ; 225 char PcdRead(u8   addr,u8 *p )
1224                     ; 226 {
1225                     	switch	.text
1226  025f               _PcdRead:
1228  025f 88            	push	a
1229  0260 5215          	subw	sp,#21
1230       00000015      OFST:	set	21
1233                     ; 231     ucComMF522Buf[0] = PICC_READ;
1235  0262 a630          	ld	a,#48
1236  0264 6b03          	ld	(OFST-18,sp),a
1238                     ; 232     ucComMF522Buf[1] = addr;
1240  0266 7b16          	ld	a,(OFST+1,sp)
1241  0268 6b04          	ld	(OFST-17,sp),a
1243                     ; 233     CalulateCRC(ucComMF522Buf,2,&ucComMF522Buf[2]);
1245  026a 96            	ldw	x,sp
1246  026b 1c0005        	addw	x,#OFST-16
1247  026e 89            	pushw	x
1248  026f 4b02          	push	#2
1249  0271 96            	ldw	x,sp
1250  0272 1c0006        	addw	x,#OFST-15
1251  0275 cd03b2        	call	_CalulateCRC
1253  0278 5b03          	addw	sp,#3
1254                     ; 235     status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,4,ucComMF522Buf,&unLen);
1256  027a 96            	ldw	x,sp
1257  027b 1c0001        	addw	x,#OFST-20
1258  027e 89            	pushw	x
1259  027f 96            	ldw	x,sp
1260  0280 1c0005        	addw	x,#OFST-16
1261  0283 89            	pushw	x
1262  0284 4b04          	push	#4
1263  0286 96            	ldw	x,sp
1264  0287 1c0008        	addw	x,#OFST-13
1265  028a 89            	pushw	x
1266  028b a60c          	ld	a,#12
1267  028d cd0526        	call	_PcdComMF522
1269  0290 5b07          	addw	sp,#7
1270  0292 6b02          	ld	(OFST-19,sp),a
1272                     ; 236     if ((status == MI_OK) && (unLen == 0x90))
1274  0294 0d02          	tnz	(OFST-19,sp)
1275  0296 2629          	jrne	L724
1277  0298 7b01          	ld	a,(OFST-20,sp)
1278  029a a190          	cp	a,#144
1279  029c 2623          	jrne	L724
1280                     ; 239         for (i=0; i<16; i++)
1282  029e 0f15          	clr	(OFST+0,sp)
1284  02a0               L134:
1285                     ; 240         {    *(p +i) = ucComMF522Buf[i];   }
1287  02a0 7b15          	ld	a,(OFST+0,sp)
1288  02a2 5f            	clrw	x
1289  02a3 97            	ld	xl,a
1290  02a4 72fb19        	addw	x,(OFST+4,sp)
1291  02a7 89            	pushw	x
1292  02a8 96            	ldw	x,sp
1293  02a9 1c0005        	addw	x,#OFST-16
1294  02ac 9f            	ld	a,xl
1295  02ad 5e            	swapw	x
1296  02ae 1b17          	add	a,(OFST+2,sp)
1297  02b0 2401          	jrnc	L44
1298  02b2 5c            	incw	x
1299  02b3               L44:
1300  02b3 02            	rlwa	x,a
1301  02b4 f6            	ld	a,(x)
1302  02b5 85            	popw	x
1303  02b6 f7            	ld	(x),a
1304                     ; 239         for (i=0; i<16; i++)
1306  02b7 0c15          	inc	(OFST+0,sp)
1310  02b9 7b15          	ld	a,(OFST+0,sp)
1311  02bb a110          	cp	a,#16
1312  02bd 25e1          	jrult	L134
1314  02bf 2004          	jra	L734
1315  02c1               L724:
1316                     ; 243     {   status = MI_ERR;   }
1318  02c1 a602          	ld	a,#2
1319  02c3 6b02          	ld	(OFST-19,sp),a
1321  02c5               L734:
1322                     ; 245     return status;
1324  02c5 7b02          	ld	a,(OFST-19,sp)
1327  02c7 5b16          	addw	sp,#22
1328  02c9 81            	ret
1411                     ; 254 char PcdWrite(u8 addr,u8 *p )
1411                     ; 255 {
1412                     	switch	.text
1413  02ca               _PcdWrite:
1415  02ca 88            	push	a
1416  02cb 5214          	subw	sp,#20
1417       00000014      OFST:	set	20
1420                     ; 260     ucComMF522Buf[0] = PICC_WRITE;
1422  02cd a6a0          	ld	a,#160
1423  02cf 6b02          	ld	(OFST-18,sp),a
1425                     ; 261     ucComMF522Buf[1] = addr;
1427  02d1 7b15          	ld	a,(OFST+1,sp)
1428  02d3 6b03          	ld	(OFST-17,sp),a
1430                     ; 262     CalulateCRC(ucComMF522Buf,2,&ucComMF522Buf[2]);
1432  02d5 96            	ldw	x,sp
1433  02d6 1c0004        	addw	x,#OFST-16
1434  02d9 89            	pushw	x
1435  02da 4b02          	push	#2
1436  02dc 96            	ldw	x,sp
1437  02dd 1c0005        	addw	x,#OFST-15
1438  02e0 cd03b2        	call	_CalulateCRC
1440  02e3 5b03          	addw	sp,#3
1441                     ; 264     status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,4,ucComMF522Buf,&unLen);
1443  02e5 96            	ldw	x,sp
1444  02e6 1c0001        	addw	x,#OFST-19
1445  02e9 89            	pushw	x
1446  02ea 96            	ldw	x,sp
1447  02eb 1c0004        	addw	x,#OFST-16
1448  02ee 89            	pushw	x
1449  02ef 4b04          	push	#4
1450  02f1 96            	ldw	x,sp
1451  02f2 1c0007        	addw	x,#OFST-13
1452  02f5 89            	pushw	x
1453  02f6 a60c          	ld	a,#12
1454  02f8 cd0526        	call	_PcdComMF522
1456  02fb 5b07          	addw	sp,#7
1457  02fd 6b14          	ld	(OFST+0,sp),a
1459                     ; 266     if ((status != MI_OK) || (unLen != 4) || ((ucComMF522Buf[0] & 0x0F) != 0x0A))
1461  02ff 0d14          	tnz	(OFST+0,sp)
1462  0301 260e          	jrne	L505
1464  0303 7b01          	ld	a,(OFST-19,sp)
1465  0305 a104          	cp	a,#4
1466  0307 2608          	jrne	L505
1468  0309 7b02          	ld	a,(OFST-18,sp)
1469  030b a40f          	and	a,#15
1470  030d a10a          	cp	a,#10
1471  030f 2704          	jreq	L305
1472  0311               L505:
1473                     ; 267     {   status = MI_ERR;   }
1475  0311 a602          	ld	a,#2
1476  0313 6b14          	ld	(OFST+0,sp),a
1478  0315               L305:
1479                     ; 269     if (status == MI_OK)
1481  0315 0d14          	tnz	(OFST+0,sp)
1482  0317 2661          	jrne	L115
1483                     ; 272         for (i=0; i<16; i++)
1485  0319 0f14          	clr	(OFST+0,sp)
1487  031b               L315:
1488                     ; 274         	ucComMF522Buf[i] = *(p +i);   
1490  031b 96            	ldw	x,sp
1491  031c 1c0002        	addw	x,#OFST-18
1492  031f 9f            	ld	a,xl
1493  0320 5e            	swapw	x
1494  0321 1b14          	add	a,(OFST+0,sp)
1495  0323 2401          	jrnc	L05
1496  0325 5c            	incw	x
1497  0326               L05:
1498  0326 02            	rlwa	x,a
1499  0327 7b14          	ld	a,(OFST+0,sp)
1500  0329 905f          	clrw	y
1501  032b 9097          	ld	yl,a
1502  032d 72f918        	addw	y,(OFST+4,sp)
1503  0330 90f6          	ld	a,(y)
1504  0332 f7            	ld	(x),a
1505                     ; 272         for (i=0; i<16; i++)
1507  0333 0c14          	inc	(OFST+0,sp)
1511  0335 7b14          	ld	a,(OFST+0,sp)
1512  0337 a110          	cp	a,#16
1513  0339 25e0          	jrult	L315
1514                     ; 276         CalulateCRC(ucComMF522Buf,16,&ucComMF522Buf[16]);
1516  033b 96            	ldw	x,sp
1517  033c 1c0012        	addw	x,#OFST-2
1518  033f 89            	pushw	x
1519  0340 4b10          	push	#16
1520  0342 96            	ldw	x,sp
1521  0343 1c0005        	addw	x,#OFST-15
1522  0346 ad6a          	call	_CalulateCRC
1524  0348 5b03          	addw	sp,#3
1525                     ; 278         status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,18,ucComMF522Buf,&unLen);
1527  034a 96            	ldw	x,sp
1528  034b 1c0001        	addw	x,#OFST-19
1529  034e 89            	pushw	x
1530  034f 96            	ldw	x,sp
1531  0350 1c0004        	addw	x,#OFST-16
1532  0353 89            	pushw	x
1533  0354 4b12          	push	#18
1534  0356 96            	ldw	x,sp
1535  0357 1c0007        	addw	x,#OFST-13
1536  035a 89            	pushw	x
1537  035b a60c          	ld	a,#12
1538  035d cd0526        	call	_PcdComMF522
1540  0360 5b07          	addw	sp,#7
1541  0362 6b14          	ld	(OFST+0,sp),a
1543                     ; 279         if ((status != MI_OK) || (unLen != 4) || ((ucComMF522Buf[0] & 0x0F) != 0x0A))
1545  0364 0d14          	tnz	(OFST+0,sp)
1546  0366 260e          	jrne	L325
1548  0368 7b01          	ld	a,(OFST-19,sp)
1549  036a a104          	cp	a,#4
1550  036c 2608          	jrne	L325
1552  036e 7b02          	ld	a,(OFST-18,sp)
1553  0370 a40f          	and	a,#15
1554  0372 a10a          	cp	a,#10
1555  0374 2704          	jreq	L115
1556  0376               L325:
1557                     ; 280         {   status = MI_ERR;   }
1559  0376 a602          	ld	a,#2
1560  0378 6b14          	ld	(OFST+0,sp),a
1562  037a               L115:
1563                     ; 283     return status;
1565  037a 7b14          	ld	a,(OFST+0,sp)
1568  037c 5b15          	addw	sp,#21
1569  037e 81            	ret
1624                     ; 290 char PcdHalt(void)
1624                     ; 291 {
1625                     	switch	.text
1626  037f               _PcdHalt:
1628  037f 5214          	subw	sp,#20
1629       00000014      OFST:	set	20
1632                     ; 296     ucComMF522Buf[0] = PICC_HALT;
1634  0381 a650          	ld	a,#80
1635  0383 6b03          	ld	(OFST-17,sp),a
1637                     ; 297     ucComMF522Buf[1] = 0;
1639  0385 0f04          	clr	(OFST-16,sp)
1641                     ; 298     CalulateCRC(ucComMF522Buf,2,&ucComMF522Buf[2]);
1643  0387 96            	ldw	x,sp
1644  0388 1c0005        	addw	x,#OFST-15
1645  038b 89            	pushw	x
1646  038c 4b02          	push	#2
1647  038e 96            	ldw	x,sp
1648  038f 1c0006        	addw	x,#OFST-14
1649  0392 ad1e          	call	_CalulateCRC
1651  0394 5b03          	addw	sp,#3
1652                     ; 300     status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,4,ucComMF522Buf,&unLen);
1654  0396 96            	ldw	x,sp
1655  0397 1c0002        	addw	x,#OFST-18
1656  039a 89            	pushw	x
1657  039b 96            	ldw	x,sp
1658  039c 1c0005        	addw	x,#OFST-15
1659  039f 89            	pushw	x
1660  03a0 4b04          	push	#4
1661  03a2 96            	ldw	x,sp
1662  03a3 1c0008        	addw	x,#OFST-12
1663  03a6 89            	pushw	x
1664  03a7 a60c          	ld	a,#12
1665  03a9 cd0526        	call	_PcdComMF522
1667  03ac 5b07          	addw	sp,#7
1668                     ; 302     return MI_OK;
1670  03ae 4f            	clr	a
1673  03af 5b14          	addw	sp,#20
1674  03b1 81            	ret
1750                     ; 308 void CalulateCRC(u8 *pIn ,u8   len,u8 *pOut )
1750                     ; 309 {
1751                     	switch	.text
1752  03b2               _CalulateCRC:
1754  03b2 89            	pushw	x
1755  03b3 89            	pushw	x
1756       00000002      OFST:	set	2
1759                     ; 311     ClearBitMask(DivIrqReg,0x04);
1761  03b4 ae0504        	ldw	x,#1284
1762  03b7 cd0511        	call	_ClearBitMask
1764                     ; 312     WriteRawRC(CommandReg,PCD_IDLE);
1766  03ba ae0100        	ldw	x,#256
1767  03bd cd04e0        	call	_WriteRawRC
1769                     ; 313     SetBitMask(FIFOLevelReg,0x80);
1771  03c0 ae0a80        	ldw	x,#2688
1772  03c3 cd04fd        	call	_SetBitMask
1774                     ; 314     for (i=0; i<len; i++)
1776  03c6 0f02          	clr	(OFST+0,sp)
1779  03c8 2011          	jra	L716
1780  03ca               L316:
1781                     ; 315     {   WriteRawRC(FIFODataReg, *(pIn +i));   }
1783  03ca 7b02          	ld	a,(OFST+0,sp)
1784  03cc 5f            	clrw	x
1785  03cd 97            	ld	xl,a
1786  03ce 72fb03        	addw	x,(OFST+1,sp)
1787  03d1 f6            	ld	a,(x)
1788  03d2 ae0900        	ldw	x,#2304
1789  03d5 97            	ld	xl,a
1790  03d6 cd04e0        	call	_WriteRawRC
1792                     ; 314     for (i=0; i<len; i++)
1794  03d9 0c02          	inc	(OFST+0,sp)
1796  03db               L716:
1799  03db 7b02          	ld	a,(OFST+0,sp)
1800  03dd 1107          	cp	a,(OFST+5,sp)
1801  03df 25e9          	jrult	L316
1802                     ; 316     WriteRawRC(CommandReg, PCD_CALCCRC);
1804  03e1 ae0103        	ldw	x,#259
1805  03e4 cd04e0        	call	_WriteRawRC
1807                     ; 317     i = 0xFF;
1809  03e7 a6ff          	ld	a,#255
1810  03e9 6b02          	ld	(OFST+0,sp),a
1812  03eb               L326:
1813                     ; 320         n = ReadRawRC(DivIrqReg);
1815  03eb a605          	ld	a,#5
1816  03ed cd04c0        	call	_ReadRawRC
1818  03f0 6b01          	ld	(OFST-1,sp),a
1820                     ; 321         i--;
1822  03f2 0a02          	dec	(OFST+0,sp)
1824                     ; 323     while ((i!=0) && !(n&0x04));
1826  03f4 0d02          	tnz	(OFST+0,sp)
1827  03f6 2706          	jreq	L136
1829  03f8 7b01          	ld	a,(OFST-1,sp)
1830  03fa a504          	bcp	a,#4
1831  03fc 27ed          	jreq	L326
1832  03fe               L136:
1833                     ; 324     pOut [0] = ReadRawRC(CRCResultRegL);
1835  03fe a622          	ld	a,#34
1836  0400 cd04c0        	call	_ReadRawRC
1838  0403 1e08          	ldw	x,(OFST+6,sp)
1839  0405 f7            	ld	(x),a
1840                     ; 325     pOut [1] = ReadRawRC(CRCResultRegM);
1842  0406 a621          	ld	a,#33
1843  0408 cd04c0        	call	_ReadRawRC
1845  040b 1e08          	ldw	x,(OFST+6,sp)
1846  040d e701          	ld	(1,x),a
1847                     ; 326 }
1850  040f 5b04          	addw	sp,#4
1851  0411 81            	ret
1876                     ; 332 char PcdReset(void)
1876                     ; 333 {
1877                     	switch	.text
1878  0412               _PcdReset:
1882                     ; 336     GPIO_HIGH(RC522RST_GPIO_PORT,RC522RST_GPIO_PIN);
1884  0412 7216500a      	bset	20490,#3
1885                     ; 337     delay_ns(10);
1887  0416 ae000a        	ldw	x,#10
1888  0419 89            	pushw	x
1889  041a ae0000        	ldw	x,#0
1890  041d 89            	pushw	x
1891  041e cd0000        	call	_delay_ns
1893  0421 5b04          	addw	sp,#4
1894                     ; 340     GPIO_LOW(RC522RST_GPIO_PORT,RC522RST_GPIO_PIN);
1896  0423 7217500a      	bres	20490,#3
1897                     ; 341     delay_ns(10);
1899  0427 ae000a        	ldw	x,#10
1900  042a 89            	pushw	x
1901  042b ae0000        	ldw	x,#0
1902  042e 89            	pushw	x
1903  042f cd0000        	call	_delay_ns
1905  0432 5b04          	addw	sp,#4
1906                     ; 344     GPIO_HIGH(RC522RST_GPIO_PORT,RC522RST_GPIO_PIN);
1908  0434 7216500a      	bset	20490,#3
1909                     ; 345     delay_ns(10);
1911  0438 ae000a        	ldw	x,#10
1912  043b 89            	pushw	x
1913  043c ae0000        	ldw	x,#0
1914  043f 89            	pushw	x
1915  0440 cd0000        	call	_delay_ns
1917  0443 5b04          	addw	sp,#4
1918                     ; 346     WriteRawRC(CommandReg,PCD_RESETPHASE);
1920  0445 ae010f        	ldw	x,#271
1921  0448 cd04e0        	call	_WriteRawRC
1923                     ; 347     WriteRawRC(CommandReg,PCD_RESETPHASE);
1925  044b ae010f        	ldw	x,#271
1926  044e cd04e0        	call	_WriteRawRC
1928                     ; 348     delay_ns(10);
1930  0451 ae000a        	ldw	x,#10
1931  0454 89            	pushw	x
1932  0455 ae0000        	ldw	x,#0
1933  0458 89            	pushw	x
1934  0459 cd0000        	call	_delay_ns
1936  045c 5b04          	addw	sp,#4
1937                     ; 350     WriteRawRC(ModeReg,0x3D);            //和Mifare卡通讯，CRC初始值0x6363
1939  045e ae113d        	ldw	x,#4413
1940  0461 ad7d          	call	_WriteRawRC
1942                     ; 351     WriteRawRC(TReloadRegL,30);           
1944  0463 ae2d1e        	ldw	x,#11550
1945  0466 ad78          	call	_WriteRawRC
1947                     ; 352     WriteRawRC(TReloadRegH,0);
1949  0468 ae2c00        	ldw	x,#11264
1950  046b ad73          	call	_WriteRawRC
1952                     ; 353     WriteRawRC(TModeReg,0x8D);
1954  046d ae2a8d        	ldw	x,#10893
1955  0470 ad6e          	call	_WriteRawRC
1957                     ; 354     WriteRawRC(TPrescalerReg,0x3E);
1959  0472 ae2b3e        	ldw	x,#11070
1960  0475 ad69          	call	_WriteRawRC
1962                     ; 356     WriteRawRC(TxAutoReg,0x40);//必须要
1964  0477 ae1540        	ldw	x,#5440
1965  047a ad64          	call	_WriteRawRC
1967                     ; 358     return MI_OK;
1969  047c 4f            	clr	a
1972  047d 81            	ret
2011                     ; 363 char M500PcdConfigISOType(u8   type)
2011                     ; 364 {
2012                     	switch	.text
2013  047e               _M500PcdConfigISOType:
2017                     ; 365    if (type == 'A')                     //ISO14443_A
2019  047e a141          	cp	a,#65
2020  0480 263b          	jrne	L166
2021                     ; 367       ClearBitMask(Status2Reg,0x08);
2023  0482 ae0808        	ldw	x,#2056
2024  0485 cd0511        	call	_ClearBitMask
2026                     ; 368       WriteRawRC(ModeReg,0x3D);//3F
2028  0488 ae113d        	ldw	x,#4413
2029  048b ad53          	call	_WriteRawRC
2031                     ; 369       WriteRawRC(RxSelReg,0x86);//84
2033  048d ae1786        	ldw	x,#6022
2034  0490 ad4e          	call	_WriteRawRC
2036                     ; 370       WriteRawRC(RFCfgReg,0x7F);   //4F
2038  0492 ae267f        	ldw	x,#9855
2039  0495 ad49          	call	_WriteRawRC
2041                     ; 371       WriteRawRC(TReloadRegL,30);//tmoLength);// TReloadVal = 'h6a =tmoLength(dec) 
2043  0497 ae2d1e        	ldw	x,#11550
2044  049a ad44          	call	_WriteRawRC
2046                     ; 372       WriteRawRC(TReloadRegH,0);
2048  049c ae2c00        	ldw	x,#11264
2049  049f ad3f          	call	_WriteRawRC
2051                     ; 373       WriteRawRC(TModeReg,0x8D);
2053  04a1 ae2a8d        	ldw	x,#10893
2054  04a4 ad3a          	call	_WriteRawRC
2056                     ; 374       WriteRawRC(TPrescalerReg,0x3E);
2058  04a6 ae2b3e        	ldw	x,#11070
2059  04a9 ad35          	call	_WriteRawRC
2061                     ; 375       delay_ns(1000);
2063  04ab ae03e8        	ldw	x,#1000
2064  04ae 89            	pushw	x
2065  04af ae0000        	ldw	x,#0
2066  04b2 89            	pushw	x
2067  04b3 cd0000        	call	_delay_ns
2069  04b6 5b04          	addw	sp,#4
2070                     ; 376       PcdAntennaOn();
2072  04b8 cd0664        	call	_PcdAntennaOn
2075                     ; 383    return MI_OK;
2077  04bb 4f            	clr	a
2080  04bc 81            	ret
2081  04bd               L166:
2082                     ; 380      return 1; 
2084  04bd a601          	ld	a,#1
2087  04bf 81            	ret
2140                     ; 390 u8 ReadRawRC(u8   Address)
2140                     ; 391 {
2141                     	switch	.text
2142  04c0               _ReadRawRC:
2144  04c0 88            	push	a
2145       00000001      OFST:	set	1
2148                     ; 393     u8   ucResult=0;
2150                     ; 395     GPIO_LOW(RC522NSS_GPIO_PORT,RC522NSS_GPIO_PIN);
2152  04c1 7219500a      	bres	20490,#4
2153                     ; 396     ucAddr = ((Address<<1)&0x7E)|0x80;
2155  04c5 48            	sll	a
2156  04c6 a47e          	and	a,#126
2157  04c8 aa80          	or	a,#128
2158  04ca 6b01          	ld	(OFST+0,sp),a
2160                     ; 398     SPIWriteByte(ucAddr);
2162  04cc 7b01          	ld	a,(OFST+0,sp)
2163  04ce cd002d        	call	_SPIWriteByte
2165                     ; 399     ucResult=SPIReadByte();
2167  04d1 4f            	clr	a
2168  04d2 cd002d        	call	_SPIWriteByte
2170  04d5 6b01          	ld	(OFST+0,sp),a
2172                     ; 401     GPIO_HIGH(RC522NSS_GPIO_PORT,RC522NSS_GPIO_PIN);
2174  04d7 7218500a      	bset	20490,#4
2175                     ; 402     return ucResult;
2177  04db 7b01          	ld	a,(OFST+0,sp)
2180  04dd 5b01          	addw	sp,#1
2181  04df 81            	ret
2234                     ; 410 void WriteRawRC(u8   Address, u8   value)
2234                     ; 411 {  
2235                     	switch	.text
2236  04e0               _WriteRawRC:
2238  04e0 89            	pushw	x
2239  04e1 88            	push	a
2240       00000001      OFST:	set	1
2243                     ; 414     GPIO_LOW(RC522NSS_GPIO_PORT,RC522NSS_GPIO_PIN);
2245  04e2 7219500a      	bres	20490,#4
2246                     ; 415     ucAddr = ((Address<<1)&0x7E);
2248  04e6 9e            	ld	a,xh
2249  04e7 48            	sll	a
2250  04e8 a47e          	and	a,#126
2251  04ea 6b01          	ld	(OFST+0,sp),a
2253                     ; 417     SPIWriteByte(ucAddr);
2255  04ec 7b01          	ld	a,(OFST+0,sp)
2256  04ee cd002d        	call	_SPIWriteByte
2258                     ; 418     SPIWriteByte(value);
2260  04f1 7b03          	ld	a,(OFST+2,sp)
2261  04f3 cd002d        	call	_SPIWriteByte
2263                     ; 420     GPIO_HIGH(RC522NSS_GPIO_PORT,RC522NSS_GPIO_PIN);
2265  04f6 7218500a      	bset	20490,#4
2266                     ; 422 }
2269  04fa 5b03          	addw	sp,#3
2270  04fc 81            	ret
2324                     ; 428 void SetBitMask(u8   reg,u8   mask)  
2324                     ; 429 {
2325                     	switch	.text
2326  04fd               _SetBitMask:
2328  04fd 89            	pushw	x
2329  04fe 88            	push	a
2330       00000001      OFST:	set	1
2333                     ; 430     char   tmp = 0x0;
2335                     ; 431     tmp = ReadRawRC(reg);
2337  04ff 9e            	ld	a,xh
2338  0500 adbe          	call	_ReadRawRC
2340  0502 6b01          	ld	(OFST+0,sp),a
2342                     ; 432     WriteRawRC(reg,tmp | mask);  // set bit mask
2344  0504 7b01          	ld	a,(OFST+0,sp)
2345  0506 1a03          	or	a,(OFST+2,sp)
2346  0508 97            	ld	xl,a
2347  0509 7b02          	ld	a,(OFST+1,sp)
2348  050b 95            	ld	xh,a
2349  050c add2          	call	_WriteRawRC
2351                     ; 433 }
2354  050e 5b03          	addw	sp,#3
2355  0510 81            	ret
2409                     ; 440 void ClearBitMask(u8   reg,u8   mask)  
2409                     ; 441 {
2410                     	switch	.text
2411  0511               _ClearBitMask:
2413  0511 89            	pushw	x
2414  0512 88            	push	a
2415       00000001      OFST:	set	1
2418                     ; 442     char   tmp = 0x0;
2420                     ; 443     tmp = ReadRawRC(reg);
2422  0513 9e            	ld	a,xh
2423  0514 adaa          	call	_ReadRawRC
2425  0516 6b01          	ld	(OFST+0,sp),a
2427                     ; 444     WriteRawRC(reg, tmp & ~mask);  // clear bit mask
2429  0518 7b03          	ld	a,(OFST+2,sp)
2430  051a 43            	cpl	a
2431  051b 1401          	and	a,(OFST+0,sp)
2432  051d 97            	ld	xl,a
2433  051e 7b02          	ld	a,(OFST+1,sp)
2434  0520 95            	ld	xh,a
2435  0521 adbd          	call	_WriteRawRC
2437                     ; 445 } 
2440  0523 5b03          	addw	sp,#3
2441  0525 81            	ret
2572                     ; 455 char PcdComMF522(u8   Command, 
2572                     ; 456                  u8 *pIn , 
2572                     ; 457                  u8   InLenByte,
2572                     ; 458                  u8 *pOut , 
2572                     ; 459                  u8 *pOutLenBit)
2572                     ; 460 {
2573                     	switch	.text
2574  0526               _PcdComMF522:
2576  0526 88            	push	a
2577  0527 5206          	subw	sp,#6
2578       00000006      OFST:	set	6
2581                     ; 461     char   status = MI_ERR;
2583  0529 a602          	ld	a,#2
2584  052b 6b01          	ld	(OFST-5,sp),a
2586                     ; 462     u8   irqEn   = 0x00;
2588  052d 0f03          	clr	(OFST-3,sp)
2590                     ; 463     u8   waitFor = 0x00;
2592  052f 0f02          	clr	(OFST-4,sp)
2594                     ; 467     switch (Command)
2596  0531 7b07          	ld	a,(OFST+1,sp)
2598                     ; 477         default:
2598                     ; 478                 break;
2599  0533 a00c          	sub	a,#12
2600  0535 270e          	jreq	L7101
2601  0537 a002          	sub	a,#2
2602  0539 2612          	jrne	L3111
2603                     ; 469         case PCD_AUTHENT:
2603                     ; 470                 irqEn   = 0x12;
2605  053b a612          	ld	a,#18
2606  053d 6b03          	ld	(OFST-3,sp),a
2608                     ; 471                 waitFor = 0x10;
2610  053f a610          	ld	a,#16
2611  0541 6b02          	ld	(OFST-4,sp),a
2613                     ; 472                 break;
2615  0543 2008          	jra	L3111
2616  0545               L7101:
2617                     ; 473         case PCD_TRANSCEIVE:
2617                     ; 474                 irqEn   = 0x77;
2619  0545 a677          	ld	a,#119
2620  0547 6b03          	ld	(OFST-3,sp),a
2622                     ; 475                 waitFor = 0x30;
2624  0549 a630          	ld	a,#48
2625  054b 6b02          	ld	(OFST-4,sp),a
2627                     ; 476                 break;
2629  054d               L1201:
2630                     ; 477         default:
2630                     ; 478                 break;
2632  054d               L3111:
2633                     ; 481     WriteRawRC(ComIEnReg,irqEn|0x80);
2635  054d 7b03          	ld	a,(OFST-3,sp)
2636  054f aa80          	or	a,#128
2637  0551 ae0200        	ldw	x,#512
2638  0554 97            	ld	xl,a
2639  0555 ad89          	call	_WriteRawRC
2641                     ; 482     ClearBitMask(ComIrqReg,0x80);	//清所有中断位
2643  0557 ae0480        	ldw	x,#1152
2644  055a adb5          	call	_ClearBitMask
2646                     ; 483     WriteRawRC(CommandReg,PCD_IDLE);
2648  055c ae0100        	ldw	x,#256
2649  055f cd04e0        	call	_WriteRawRC
2651                     ; 484     SetBitMask(FIFOLevelReg,0x80);	 	//清FIFO
2653  0562 ae0a80        	ldw	x,#2688
2654  0565 ad96          	call	_SetBitMask
2656                     ; 486     for (i=0; i<InLenByte; i++)
2658  0567 5f            	clrw	x
2659  0568 1f05          	ldw	(OFST-1,sp),x
2662  056a 2014          	jra	L1211
2663  056c               L5111:
2664                     ; 488       WriteRawRC(FIFODataReg, pIn [i]);    
2666  056c 1e0a          	ldw	x,(OFST+4,sp)
2667  056e 72fb05        	addw	x,(OFST-1,sp)
2668  0571 f6            	ld	a,(x)
2669  0572 ae0900        	ldw	x,#2304
2670  0575 97            	ld	xl,a
2671  0576 cd04e0        	call	_WriteRawRC
2673                     ; 486     for (i=0; i<InLenByte; i++)
2675  0579 1e05          	ldw	x,(OFST-1,sp)
2676  057b 1c0001        	addw	x,#1
2677  057e 1f05          	ldw	(OFST-1,sp),x
2679  0580               L1211:
2682  0580 7b0c          	ld	a,(OFST+6,sp)
2683  0582 5f            	clrw	x
2684  0583 97            	ld	xl,a
2685  0584 bf00          	ldw	c_x,x
2686  0586 1e05          	ldw	x,(OFST-1,sp)
2687  0588 b300          	cpw	x,c_x
2688  058a 25e0          	jrult	L5111
2689                     ; 490     WriteRawRC(CommandReg, Command);	  
2691  058c 7b07          	ld	a,(OFST+1,sp)
2692  058e ae0100        	ldw	x,#256
2693  0591 97            	ld	xl,a
2694  0592 cd04e0        	call	_WriteRawRC
2696                     ; 493     if (Command == PCD_TRANSCEIVE)
2698  0595 7b07          	ld	a,(OFST+1,sp)
2699  0597 a10c          	cp	a,#12
2700  0599 2606          	jrne	L5211
2701                     ; 495       SetBitMask(BitFramingReg,0x80);           //開始傳送
2703  059b ae0d80        	ldw	x,#3456
2704  059e cd04fd        	call	_SetBitMask
2706  05a1               L5211:
2707                     ; 499     i = 10000;
2709  05a1 ae2710        	ldw	x,#10000
2710  05a4 1f05          	ldw	(OFST-1,sp),x
2712  05a6               L7211:
2713                     ; 502         n = ReadRawRC(ComIrqReg);
2715  05a6 a604          	ld	a,#4
2716  05a8 cd04c0        	call	_ReadRawRC
2718  05ab 6b04          	ld	(OFST-2,sp),a
2720                     ; 503         i--;
2722  05ad 1e05          	ldw	x,(OFST-1,sp)
2723  05af 1d0001        	subw	x,#1
2724  05b2 1f05          	ldw	(OFST-1,sp),x
2726                     ; 505     while ((i!=0) && !(n&0x01) && !(n&waitFor));
2728  05b4 1e05          	ldw	x,(OFST-1,sp)
2729  05b6 270c          	jreq	L5311
2731  05b8 7b04          	ld	a,(OFST-2,sp)
2732  05ba a501          	bcp	a,#1
2733  05bc 2606          	jrne	L5311
2735  05be 7b04          	ld	a,(OFST-2,sp)
2736  05c0 1502          	bcp	a,(OFST-4,sp)
2737  05c2 27e2          	jreq	L7211
2738  05c4               L5311:
2739                     ; 506     ClearBitMask(BitFramingReg,0x80);
2741  05c4 ae0d80        	ldw	x,#3456
2742  05c7 cd0511        	call	_ClearBitMask
2744                     ; 508     if (i!=0)
2746  05ca 1e05          	ldw	x,(OFST-1,sp)
2747  05cc 2603          	jrne	L47
2748  05ce cc0653        	jp	L1411
2749  05d1               L47:
2750                     ; 510         if(!(ReadRawRC(ErrorReg)&0x1B))
2752  05d1 a606          	ld	a,#6
2753  05d3 cd04c0        	call	_ReadRawRC
2755  05d6 a51b          	bcp	a,#27
2756  05d8 2675          	jrne	L3411
2757                     ; 512             status = MI_OK;
2759  05da 0f01          	clr	(OFST-5,sp)
2761                     ; 513             if (n & irqEn & 0x01)
2763  05dc 7b04          	ld	a,(OFST-2,sp)
2764  05de 1403          	and	a,(OFST-3,sp)
2765  05e0 a501          	bcp	a,#1
2766  05e2 2704          	jreq	L5411
2767                     ; 515               status = MI_NOTAGERR;   
2769  05e4 a601          	ld	a,#1
2770  05e6 6b01          	ld	(OFST-5,sp),a
2772  05e8               L5411:
2773                     ; 517             if (Command == PCD_TRANSCEIVE)
2775  05e8 7b07          	ld	a,(OFST+1,sp)
2776  05ea a10c          	cp	a,#12
2777  05ec 2665          	jrne	L1411
2778                     ; 519                	n = ReadRawRC(FIFOLevelReg);
2780  05ee a60a          	ld	a,#10
2781  05f0 cd04c0        	call	_ReadRawRC
2783  05f3 6b04          	ld	(OFST-2,sp),a
2785                     ; 520               	lastBits = ReadRawRC(ControlReg) & 0x07;
2787  05f5 a60c          	ld	a,#12
2788  05f7 cd04c0        	call	_ReadRawRC
2790  05fa a407          	and	a,#7
2791  05fc 6b03          	ld	(OFST-3,sp),a
2793                     ; 521                 if (lastBits)
2795  05fe 0d03          	tnz	(OFST-3,sp)
2796  0600 270e          	jreq	L1511
2797                     ; 523                   *pOutLenBit = (n-1)*8 + lastBits;   
2799  0602 7b04          	ld	a,(OFST-2,sp)
2800  0604 48            	sll	a
2801  0605 48            	sll	a
2802  0606 48            	sll	a
2803  0607 a008          	sub	a,#8
2804  0609 1b03          	add	a,(OFST-3,sp)
2805  060b 1e0f          	ldw	x,(OFST+9,sp)
2806  060d f7            	ld	(x),a
2808  060e 2008          	jra	L3511
2809  0610               L1511:
2810                     ; 527                   *pOutLenBit = n*8;   
2812  0610 7b04          	ld	a,(OFST-2,sp)
2813  0612 48            	sll	a
2814  0613 48            	sll	a
2815  0614 48            	sll	a
2816  0615 1e0f          	ldw	x,(OFST+9,sp)
2817  0617 f7            	ld	(x),a
2818  0618               L3511:
2819                     ; 529                 if (n == 0)
2821  0618 0d04          	tnz	(OFST-2,sp)
2822  061a 2604          	jrne	L5511
2823                     ; 531                   n = 1;    
2825  061c a601          	ld	a,#1
2826  061e 6b04          	ld	(OFST-2,sp),a
2828  0620               L5511:
2829                     ; 533                 if (n > MAXRLEN)
2831  0620 7b04          	ld	a,(OFST-2,sp)
2832  0622 a113          	cp	a,#19
2833  0624 2504          	jrult	L7511
2834                     ; 535                   n = MAXRLEN;   
2836  0626 a612          	ld	a,#18
2837  0628 6b04          	ld	(OFST-2,sp),a
2839  062a               L7511:
2840                     ; 537                 for (i=0; i<n; i++)
2842  062a 5f            	clrw	x
2843  062b 1f05          	ldw	(OFST-1,sp),x
2846  062d 2012          	jra	L5611
2847  062f               L1611:
2848                     ; 539                   pOut[i] = ReadRawRC(FIFODataReg);    
2850  062f a609          	ld	a,#9
2851  0631 cd04c0        	call	_ReadRawRC
2853  0634 1e0d          	ldw	x,(OFST+7,sp)
2854  0636 72fb05        	addw	x,(OFST-1,sp)
2855  0639 f7            	ld	(x),a
2856                     ; 537                 for (i=0; i<n; i++)
2858  063a 1e05          	ldw	x,(OFST-1,sp)
2859  063c 1c0001        	addw	x,#1
2860  063f 1f05          	ldw	(OFST-1,sp),x
2862  0641               L5611:
2865  0641 7b04          	ld	a,(OFST-2,sp)
2866  0643 5f            	clrw	x
2867  0644 97            	ld	xl,a
2868  0645 bf00          	ldw	c_x,x
2869  0647 1e05          	ldw	x,(OFST-1,sp)
2870  0649 b300          	cpw	x,c_x
2871  064b 25e2          	jrult	L1611
2872  064d 2004          	jra	L1411
2873  064f               L3411:
2874                     ; 545           status = MI_ERR;   
2876  064f a602          	ld	a,#2
2877  0651 6b01          	ld	(OFST-5,sp),a
2879  0653               L1411:
2880                     ; 551     SetBitMask(ControlReg,0x80);           // stop timer now
2882  0653 ae0c80        	ldw	x,#3200
2883  0656 cd04fd        	call	_SetBitMask
2885                     ; 552     WriteRawRC(CommandReg,PCD_IDLE); 
2887  0659 ae0100        	ldw	x,#256
2888  065c cd04e0        	call	_WriteRawRC
2890                     ; 553     return status;
2892  065f 7b01          	ld	a,(OFST-5,sp)
2895  0661 5b07          	addw	sp,#7
2896  0663 81            	ret
2932                     ; 560 void PcdAntennaOn(void)
2932                     ; 561 {
2933                     	switch	.text
2934  0664               _PcdAntennaOn:
2936  0664 88            	push	a
2937       00000001      OFST:	set	1
2940                     ; 563     i = ReadRawRC(TxControlReg);
2942  0665 a614          	ld	a,#20
2943  0667 cd04c0        	call	_ReadRawRC
2945  066a 6b01          	ld	(OFST+0,sp),a
2947                     ; 564     if (!(i & 0x03))
2949  066c 7b01          	ld	a,(OFST+0,sp)
2950  066e a503          	bcp	a,#3
2951  0670 2606          	jrne	L1121
2952                     ; 566         SetBitMask(TxControlReg, 0x03);
2954  0672 ae1403        	ldw	x,#5123
2955  0675 cd04fd        	call	_SetBitMask
2957  0678               L1121:
2958                     ; 568 }
2961  0678 84            	pop	a
2962  0679 81            	ret
2986                     ; 574 void PcdAntennaOff(void)
2986                     ; 575 {
2987                     	switch	.text
2988  067a               _PcdAntennaOff:
2992                     ; 576 	ClearBitMask(TxControlReg, 0x03);
2994  067a ae1403        	ldw	x,#5123
2995  067d cd0511        	call	_ClearBitMask
2997                     ; 577 }
3000  0680 81            	ret
3084                     ; 588 char PcdValue(u8 dd_mode,u8 addr,u8 *pValue)
3084                     ; 589 {
3085                     	switch	.text
3086  0681               _PcdValue:
3088  0681 89            	pushw	x
3089  0682 5214          	subw	sp,#20
3090       00000014      OFST:	set	20
3093                     ; 595     ucComMF522Buf[0] = dd_mode;
3095  0684 9e            	ld	a,xh
3096  0685 6b03          	ld	(OFST-17,sp),a
3098                     ; 596     ucComMF522Buf[1] = addr;
3100  0687 9f            	ld	a,xl
3101  0688 6b04          	ld	(OFST-16,sp),a
3103                     ; 597     CalulateCRC(ucComMF522Buf,2,&ucComMF522Buf[2]);
3105  068a 96            	ldw	x,sp
3106  068b 1c0005        	addw	x,#OFST-15
3107  068e 89            	pushw	x
3108  068f 4b02          	push	#2
3109  0691 96            	ldw	x,sp
3110  0692 1c0006        	addw	x,#OFST-14
3111  0695 cd03b2        	call	_CalulateCRC
3113  0698 5b03          	addw	sp,#3
3114                     ; 599     status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,4,ucComMF522Buf,&unLen);
3116  069a 96            	ldw	x,sp
3117  069b 1c0001        	addw	x,#OFST-19
3118  069e 89            	pushw	x
3119  069f 96            	ldw	x,sp
3120  06a0 1c0005        	addw	x,#OFST-15
3121  06a3 89            	pushw	x
3122  06a4 4b04          	push	#4
3123  06a6 96            	ldw	x,sp
3124  06a7 1c0008        	addw	x,#OFST-12
3125  06aa 89            	pushw	x
3126  06ab a60c          	ld	a,#12
3127  06ad cd0526        	call	_PcdComMF522
3129  06b0 5b07          	addw	sp,#7
3130  06b2 6b02          	ld	(OFST-18,sp),a
3132                     ; 601     if ((status != MI_OK) || (unLen != 4) || ((ucComMF522Buf[0] & 0x0F) != 0x0A))
3134  06b4 0d02          	tnz	(OFST-18,sp)
3135  06b6 260e          	jrne	L7621
3137  06b8 7b01          	ld	a,(OFST-19,sp)
3138  06ba a104          	cp	a,#4
3139  06bc 2608          	jrne	L7621
3141  06be 7b03          	ld	a,(OFST-17,sp)
3142  06c0 a40f          	and	a,#15
3143  06c2 a10a          	cp	a,#10
3144  06c4 2704          	jreq	L5621
3145  06c6               L7621:
3146                     ; 603       status = MI_ERR;   
3148  06c6 a602          	ld	a,#2
3149  06c8 6b02          	ld	(OFST-18,sp),a
3151  06ca               L5621:
3152                     ; 606     if (status == MI_OK)
3154  06ca 0d02          	tnz	(OFST-18,sp)
3155  06cc 264c          	jrne	L3721
3156                     ; 608         memcpy(ucComMF522Buf, pValue, 4);
3158  06ce 96            	ldw	x,sp
3159  06cf 1c0003        	addw	x,#OFST-17
3160  06d2 bf00          	ldw	c_x,x
3161  06d4 1619          	ldw	y,(OFST+5,sp)
3162  06d6 90bf00        	ldw	c_y,y
3163  06d9 ae0004        	ldw	x,#4
3164  06dc               L401:
3165  06dc 5a            	decw	x
3166  06dd 92d600        	ld	a,([c_y.w],x)
3167  06e0 92d700        	ld	([c_x.w],x),a
3168  06e3 5d            	tnzw	x
3169  06e4 26f6          	jrne	L401
3170                     ; 611         CalulateCRC(ucComMF522Buf,4,&ucComMF522Buf[4]);
3172  06e6 96            	ldw	x,sp
3173  06e7 1c0007        	addw	x,#OFST-13
3174  06ea 89            	pushw	x
3175  06eb 4b04          	push	#4
3176  06ed 96            	ldw	x,sp
3177  06ee 1c0006        	addw	x,#OFST-14
3178  06f1 cd03b2        	call	_CalulateCRC
3180  06f4 5b03          	addw	sp,#3
3181                     ; 612         unLen = 0;
3183  06f6 0f01          	clr	(OFST-19,sp)
3185                     ; 613         status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,6,ucComMF522Buf,&unLen);
3187  06f8 96            	ldw	x,sp
3188  06f9 1c0001        	addw	x,#OFST-19
3189  06fc 89            	pushw	x
3190  06fd 96            	ldw	x,sp
3191  06fe 1c0005        	addw	x,#OFST-15
3192  0701 89            	pushw	x
3193  0702 4b06          	push	#6
3194  0704 96            	ldw	x,sp
3195  0705 1c0008        	addw	x,#OFST-12
3196  0708 89            	pushw	x
3197  0709 a60c          	ld	a,#12
3198  070b cd0526        	call	_PcdComMF522
3200  070e 5b07          	addw	sp,#7
3201  0710 6b02          	ld	(OFST-18,sp),a
3203                     ; 614 		if (status != MI_ERR)
3205  0712 7b02          	ld	a,(OFST-18,sp)
3206  0714 a102          	cp	a,#2
3207  0716 2702          	jreq	L3721
3208                     ; 615         {    status = MI_OK;    }
3210  0718 0f02          	clr	(OFST-18,sp)
3212  071a               L3721:
3213                     ; 618     if (status == MI_OK)
3215  071a 0d02          	tnz	(OFST-18,sp)
3216  071c 2648          	jrne	L7721
3217                     ; 620         ucComMF522Buf[0] = PICC_TRANSFER;
3219  071e a6b0          	ld	a,#176
3220  0720 6b03          	ld	(OFST-17,sp),a
3222                     ; 621         ucComMF522Buf[1] = addr;
3224  0722 7b16          	ld	a,(OFST+2,sp)
3225  0724 6b04          	ld	(OFST-16,sp),a
3227                     ; 622         CalulateCRC(ucComMF522Buf,2,&ucComMF522Buf[2]); 
3229  0726 96            	ldw	x,sp
3230  0727 1c0005        	addw	x,#OFST-15
3231  072a 89            	pushw	x
3232  072b 4b02          	push	#2
3233  072d 96            	ldw	x,sp
3234  072e 1c0006        	addw	x,#OFST-14
3235  0731 cd03b2        	call	_CalulateCRC
3237  0734 5b03          	addw	sp,#3
3238                     ; 624         status = PcdComMF522(PCD_TRANSCEIVE,ucComMF522Buf,4,ucComMF522Buf,&unLen);
3240  0736 96            	ldw	x,sp
3241  0737 1c0001        	addw	x,#OFST-19
3242  073a 89            	pushw	x
3243  073b 96            	ldw	x,sp
3244  073c 1c0005        	addw	x,#OFST-15
3245  073f 89            	pushw	x
3246  0740 4b04          	push	#4
3247  0742 96            	ldw	x,sp
3248  0743 1c0008        	addw	x,#OFST-12
3249  0746 89            	pushw	x
3250  0747 a60c          	ld	a,#12
3251  0749 cd0526        	call	_PcdComMF522
3253  074c 5b07          	addw	sp,#7
3254  074e 6b02          	ld	(OFST-18,sp),a
3256                     ; 626         if ((status != MI_OK) || (unLen != 4) || ((ucComMF522Buf[0] & 0x0F) != 0x0A))
3258  0750 0d02          	tnz	(OFST-18,sp)
3259  0752 260e          	jrne	L3031
3261  0754 7b01          	ld	a,(OFST-19,sp)
3262  0756 a104          	cp	a,#4
3263  0758 2608          	jrne	L3031
3265  075a 7b03          	ld	a,(OFST-17,sp)
3266  075c a40f          	and	a,#15
3267  075e a10a          	cp	a,#10
3268  0760 2704          	jreq	L7721
3269  0762               L3031:
3270                     ; 627         {   status = MI_ERR;   }
3272  0762 a602          	ld	a,#2
3273  0764 6b02          	ld	(OFST-18,sp),a
3275  0766               L7721:
3276                     ; 629     return status;
3278  0766 7b02          	ld	a,(OFST-18,sp)
3281  0768 5b16          	addw	sp,#22
3282  076a 81            	ret
3326                     ; 633 void Hex2String(u8 hex,u8 *str)
3326                     ; 634 {
3327                     	switch	.text
3328  076b               _Hex2String:
3330  076b 88            	push	a
3331       00000000      OFST:	set	0
3334                     ; 635   str[0] = (hex / 100) + '0';
3336  076c 5f            	clrw	x
3337  076d 97            	ld	xl,a
3338  076e a664          	ld	a,#100
3339  0770 62            	div	x,a
3340  0771 9f            	ld	a,xl
3341  0772 ab30          	add	a,#48
3342  0774 1e04          	ldw	x,(OFST+4,sp)
3343  0776 f7            	ld	(x),a
3344                     ; 636   str[1] = (hex % 100 / 10) + '0';
3346  0777 7b01          	ld	a,(OFST+1,sp)
3347  0779 5f            	clrw	x
3348  077a 97            	ld	xl,a
3349  077b a664          	ld	a,#100
3350  077d cd0000        	call	c_smodx
3352  0780 a60a          	ld	a,#10
3353  0782 cd0000        	call	c_sdivx
3355  0785 1c0030        	addw	x,#48
3356  0788 1604          	ldw	y,(OFST+4,sp)
3357  078a 01            	rrwa	x,a
3358  078b 90e701        	ld	(1,y),a
3359  078e 02            	rlwa	x,a
3360                     ; 637   str[2] = (hex % 10) + '0';
3362  078f 7b01          	ld	a,(OFST+1,sp)
3363  0791 5f            	clrw	x
3364  0792 97            	ld	xl,a
3365  0793 a60a          	ld	a,#10
3366  0795 62            	div	x,a
3367  0796 5f            	clrw	x
3368  0797 97            	ld	xl,a
3369  0798 9f            	ld	a,xl
3370  0799 ab30          	add	a,#48
3371  079b 1e04          	ldw	x,(OFST+4,sp)
3372  079d e702          	ld	(2,x),a
3373                     ; 638 }
3376  079f 84            	pop	a
3377  07a0 81            	ret
3432                     ; 640 void cardNo2String(u8 *cardNo, u8 *str)
3432                     ; 641 {
3433                     	switch	.text
3434  07a1               _cardNo2String:
3436  07a1 89            	pushw	x
3437  07a2 88            	push	a
3438       00000001      OFST:	set	1
3441                     ; 642     u8 Count = 0;
3443                     ; 643     for(Count = 0; Count < 4; Count++)
3445  07a3 0f01          	clr	(OFST+0,sp)
3447  07a5               L7531:
3448                     ; 645         Hex2String(cardNo[Count], str + Count * 4);
3450  07a5 7b01          	ld	a,(OFST+0,sp)
3451  07a7 97            	ld	xl,a
3452  07a8 a604          	ld	a,#4
3453  07aa 42            	mul	x,a
3454  07ab 72fb06        	addw	x,(OFST+5,sp)
3455  07ae 89            	pushw	x
3456  07af 7b03          	ld	a,(OFST+2,sp)
3457  07b1 5f            	clrw	x
3458  07b2 97            	ld	xl,a
3459  07b3 72fb04        	addw	x,(OFST+3,sp)
3460  07b6 f6            	ld	a,(x)
3461  07b7 adb2          	call	_Hex2String
3463  07b9 85            	popw	x
3464                     ; 646         if(Count == 3)
3466  07ba 7b01          	ld	a,(OFST+0,sp)
3467  07bc a103          	cp	a,#3
3468  07be 2608          	jrne	L5631
3469                     ; 648           str[15] = '\n';
3471  07c0 1e06          	ldw	x,(OFST+5,sp)
3472  07c2 a60a          	ld	a,#10
3473  07c4 e70f          	ld	(15,x),a
3475  07c6 200d          	jra	L7631
3476  07c8               L5631:
3477                     ; 652           str[Count * 4 + 3] = ':';
3479  07c8 7b01          	ld	a,(OFST+0,sp)
3480  07ca 97            	ld	xl,a
3481  07cb a604          	ld	a,#4
3482  07cd 42            	mul	x,a
3483  07ce 72fb06        	addw	x,(OFST+5,sp)
3484  07d1 a63a          	ld	a,#58
3485  07d3 e703          	ld	(3,x),a
3486  07d5               L7631:
3487                     ; 643     for(Count = 0; Count < 4; Count++)
3489  07d5 0c01          	inc	(OFST+0,sp)
3493  07d7 7b01          	ld	a,(OFST+0,sp)
3494  07d9 a104          	cp	a,#4
3495  07db 25c8          	jrult	L7531
3496                     ; 655 }
3499  07dd 5b03          	addw	sp,#3
3500  07df 81            	ret
3563                     ; 657 void showcard(u8 Tx_Buffer[64],u8 *set)
3563                     ; 658 {
3564                     	switch	.text
3565  07e0               _showcard:
3567  07e0 89            	pushw	x
3568  07e1 88            	push	a
3569       00000001      OFST:	set	1
3572                     ; 660 	status = PcdRequest(PICC_REQIDL,CT); 
3574  07e2 ae0004        	ldw	x,#_CT
3575  07e5 89            	pushw	x
3576  07e6 a626          	ld	a,#38
3577  07e8 cd0092        	call	_PcdRequest
3579  07eb 85            	popw	x
3580  07ec 6b01          	ld	(OFST+0,sp),a
3582                     ; 661 	if (status==MI_OK)
3584  07ee 0d01          	tnz	(OFST+0,sp)
3585  07f0 2608          	jrne	L7141
3586                     ; 663 			status = PcdAnticoll(SN); 
3588  07f2 ae0000        	ldw	x,#_SN
3589  07f5 cd00e5        	call	_PcdAnticoll
3591  07f8 6b01          	ld	(OFST+0,sp),a
3593  07fa               L7141:
3594                     ; 665 	if (status==MI_OK)
3596  07fa 0d01          	tnz	(OFST+0,sp)
3597  07fc 2608          	jrne	L1241
3598                     ; 667 			status = PcdSelect(SN);
3600  07fe ae0000        	ldw	x,#_SN
3601  0801 cd0174        	call	_PcdSelect
3603  0804 6b01          	ld	(OFST+0,sp),a
3605  0806               L1241:
3606                     ; 669 	if (status==MI_OK)
3608  0806 0d01          	tnz	(OFST+0,sp)
3609  0808 2620          	jrne	L3241
3610                     ; 671 			cardNo2String(SN, Tx_Buffer);
3612  080a 1e02          	ldw	x,(OFST+1,sp)
3613  080c 89            	pushw	x
3614  080d ae0000        	ldw	x,#_SN
3615  0810 ad8f          	call	_cardNo2String
3617  0812 85            	popw	x
3618                     ; 672 			*set=1;
3620  0813 1e06          	ldw	x,(OFST+5,sp)
3621  0815 a601          	ld	a,#1
3622  0817 f7            	ld	(x),a
3623                     ; 673 			status=PcdAuthState(0x60,3,key,SN) ;  
3625  0818 ae0000        	ldw	x,#_SN
3626  081b 89            	pushw	x
3627  081c ae0000        	ldw	x,#_key
3628  081f 89            	pushw	x
3629  0820 ae6003        	ldw	x,#24579
3630  0823 cd01f6        	call	_PcdAuthState
3632  0826 5b04          	addw	sp,#4
3633  0828 6b01          	ld	(OFST+0,sp),a
3635  082a               L3241:
3636                     ; 675 	 if (status==MI_OK)
3638  082a 0d01          	tnz	(OFST+0,sp)
3639  082c 2603          	jrne	L5241
3640                     ; 677 			status = PcdHalt();
3642  082e cd037f        	call	_PcdHalt
3644  0831               L5241:
3645                     ; 679 }
3648  0831 5b03          	addw	sp,#3
3649  0833 81            	ret
3694                     	xdef	_delay_ns
3695                     	xdef	_key
3696                     	switch	.ubsct
3697  0000               _SN:
3698  0000 00000000      	ds.b	4
3699                     	xdef	_SN
3700  0004               _CT:
3701  0004 0000          	ds.b	2
3702                     	xdef	_CT
3703                     	xdef	_showcard
3704                     	xdef	_cardNo2String
3705                     	xdef	_Hex2String
3706                     	xdef	_PcdValue
3707                     	xdef	_Reset_RC522
3708                     	xdef	_PcdHalt
3709                     	xdef	_PcdRead
3710                     	xdef	_PcdWrite
3711                     	xdef	_PcdAuthState
3712                     	xdef	_PcdSelect
3713                     	xdef	_PcdAnticoll
3714                     	xdef	_M500PcdConfigISOType
3715                     	xdef	_PcdAntennaOff
3716                     	xdef	_PcdRequest
3717                     	xdef	_PcdReset
3718                     	xdef	_PcdAntennaOn
3719                     	xdef	_ReadRawRC
3720                     	xdef	_CalulateCRC
3721                     	xdef	_PcdComMF522
3722                     	xdef	_SetBitMask
3723                     	xdef	_WriteRawRC
3724                     	xdef	_ClearBitMask
3725                     	xdef	_InitRc522
3726                     	xdef	_SPI2_Init
3727                     	xdef	_SPIWriteByte
3728                     	xref	_SPI_GetFlagStatus
3729                     	xref	_SPI_ReceiveData
3730                     	xref	_SPI_SendData
3731                     	xref	_SPI_Cmd
3732                     	xref	_SPI_Init
3733                     	xref	_GPIO_Init
3734                     	xref.b	c_x
3735                     	xref.b	c_y
3755                     	xref	c_sdivx
3756                     	xref	c_smodx
3757                     	xref	c_lcmp
3758                     	xref	c_ltor
3759                     	xref	c_lgadc
3760                     	end
