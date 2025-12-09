   1                     ; C Compiler for STM8 (COSMIC Software)
   2                     ; Parser V4.13.2 - 04 Jun 2024
   3                     ; Generator (Limited) V4.6.4 - 15 Jan 2025
  14                     	bsct
  15  0000               _fac_us:
  16  0000 00            	dc.b	0
  57                     ; 11 void Delay_InIt(unsigned char clk)
  57                     ; 12 {
  59                     	switch	.text
  60  0000               _Delay_InIt:
  62  0000 88            	push	a
  63       00000000      OFST:	set	0
  66                     ; 13     if(clk > 16) fac_us = (16 - 4)/4;
  68  0001 a111          	cp	a,#17
  69  0003 2506          	jrult	L72
  72  0005 35030000      	mov	_fac_us,#3
  74  0009 201c          	jra	L13
  75  000b               L72:
  76                     ; 14     else if(clk > 4) fac_us = (clk - 4)/4; 
  78  000b 7b01          	ld	a,(OFST+1,sp)
  79  000d a105          	cp	a,#5
  80  000f 2512          	jrult	L33
  83  0011 7b01          	ld	a,(OFST+1,sp)
  84  0013 5f            	clrw	x
  85  0014 97            	ld	xl,a
  86  0015 1d0004        	subw	x,#4
  87  0018 a604          	ld	a,#4
  88  001a cd0000        	call	c_sdivx
  90  001d 01            	rrwa	x,a
  91  001e b700          	ld	_fac_us,a
  92  0020 02            	rlwa	x,a
  94  0021 2004          	jra	L13
  95  0023               L33:
  96                     ; 15     else fac_us = 1;
  98  0023 35010000      	mov	_fac_us,#1
  99  0027               L13:
 100                     ; 16 }
 103  0027 84            	pop	a
 104  0028 81            	ret
 149                     ; 18 void Delay_us(unsigned int nus)
 149                     ; 19 {
 150                     	switch	.text
 151  0029               _Delay_us:
 153  0029 89            	pushw	x
 154  002a 89            	pushw	x
 155       00000002      OFST:	set	2
 158                     ; 21     for (j = 0; j < nus; j++)
 160  002b 5f            	clrw	x
 161  002c 1f01          	ldw	(OFST-1,sp),x
 164  002e 2008          	jra	L56
 165  0030               L16:
 166                     ; 22         __asm("nop");
 169  0030 9d            nop
 171                     ; 21     for (j = 0; j < nus; j++)
 173  0031 1e01          	ldw	x,(OFST-1,sp)
 174  0033 1c0001        	addw	x,#1
 175  0036 1f01          	ldw	(OFST-1,sp),x
 177  0038               L56:
 180  0038 1e01          	ldw	x,(OFST-1,sp)
 181  003a 1303          	cpw	x,(OFST+1,sp)
 182  003c 25f2          	jrult	L16
 183                     ; 23 }
 186  003e 5b04          	addw	sp,#4
 187  0040 81            	ret
 230                     ; 26 void LF_ClockOccurs(unsigned char LF_Pll)
 230                     ; 27 {      
 231                     	switch	.text
 232  0041               _LF_ClockOccurs:
 234  0041 89            	pushw	x
 235       00000002      OFST:	set	2
 238                     ; 30     Pll_num = (16000 / LF_Pll) - 1;  
 240  0042 ae3e80        	ldw	x,#16000
 241  0045 905f          	clrw	y
 242  0047 9097          	ld	yl,a
 243  0049 cd0000        	call	c_idiv
 245  004c 5a            	decw	x
 246  004d 1f01          	ldw	(OFST-1,sp),x
 248                     ; 32     TIM1 -> CNTRH = 0;        
 250  004f 725f525e      	clr	21086
 251                     ; 33     TIM1 -> CNTRL = 0;   
 253  0053 725f525f      	clr	21087
 254                     ; 34     TIM1 -> PSCRH = 0;
 256  0057 725f5260      	clr	21088
 257                     ; 35     TIM1 -> PSCRL = 0;            
 259  005b 725f5261      	clr	21089
 260                     ; 36     TIM1 -> ARRH = (unsigned char)(Pll_num >> 8);  
 262  005f 7b01          	ld	a,(OFST-1,sp)
 263  0061 c75262        	ld	21090,a
 264                     ; 37     TIM1 -> ARRL = (unsigned char)(Pll_num);  
 266  0064 7b02          	ld	a,(OFST+0,sp)
 267  0066 c75263        	ld	21091,a
 268                     ; 38     TIM1 -> CR1 &= 0x8F;       
 270  0069 c65250        	ld	a,21072
 271  006c a48f          	and	a,#143
 272  006e c75250        	ld	21072,a
 273                     ; 40     TIM1 -> CCR1H = (unsigned char)((Pll_num / 2) >> 8);
 275  0071 1e01          	ldw	x,(OFST-1,sp)
 276  0073 4f            	clr	a
 277  0074 01            	rrwa	x,a
 278  0075 54            	srlw	x
 279  0076 9f            	ld	a,xl
 280  0077 c75265        	ld	21093,a
 281                     ; 41     TIM1 -> CCR1L = (unsigned char)(Pll_num / 2);    
 283  007a 1e01          	ldw	x,(OFST-1,sp)
 284  007c 54            	srlw	x
 285  007d 9f            	ld	a,xl
 286  007e c75266        	ld	21094,a
 287                     ; 43     TIM1 -> CCMR1 = 0x60;      
 289  0081 35605258      	mov	21080,#96
 290                     ; 46     TIM1 -> CCER1 &= (uint8_t)~0x0F;  /* 關閉 CH1/CH1N，清除極性設定 */
 292  0085 c6525c        	ld	a,21084
 293  0088 a4f0          	and	a,#240
 294  008a c7525c        	ld	21084,a
 295                     ; 47     TIM1 -> CCER1 |= 0x04;           /* CC1NE = 1，啟用 CH1N（PB0）   */
 297  008d 7214525c      	bset	21084,#2
 298                     ; 48     TIM1 -> OISR  |= 0x02;           /* OIS1N = 1，閒置狀態輸出為 1    */
 300  0091 7212526f      	bset	21103,#1
 301                     ; 50     TIM1 -> BKR |= 0x80;
 303  0095 721e526d      	bset	21101,#7
 304                     ; 51     TIM1 -> CR1 |= 0x01;
 306  0099 72105250      	bset	21072,#0
 307                     ; 52 }
 310  009d 85            	popw	x
 311  009e 81            	ret
 354                     ; 54 void LF_PLL_SET(unsigned char LF_Pll)
 354                     ; 55 {
 355                     	switch	.text
 356  009f               _LF_PLL_SET:
 358  009f 89            	pushw	x
 359       00000002      OFST:	set	2
 362                     ; 58     Pll_num = (16000 / LF_Pll) - 1;  //us
 364  00a0 ae3e80        	ldw	x,#16000
 365  00a3 905f          	clrw	y
 366  00a5 9097          	ld	yl,a
 367  00a7 cd0000        	call	c_idiv
 369  00aa 5a            	decw	x
 370  00ab 1f01          	ldw	(OFST-1,sp),x
 372                     ; 60     TIM1 -> CR1 &= 0xFE;
 374  00ad 72115250      	bres	21072,#0
 375                     ; 62     TIM1 -> ARRH = (unsigned char)(Pll_num >> 8);  
 377  00b1 7b01          	ld	a,(OFST-1,sp)
 378  00b3 c75262        	ld	21090,a
 379                     ; 63     TIM1 -> ARRL = (unsigned char)(Pll_num);  
 381  00b6 7b02          	ld	a,(OFST+0,sp)
 382  00b8 c75263        	ld	21091,a
 383                     ; 64     TIM1 -> CCR1H = (unsigned char)((Pll_num / 2) >> 8);
 385  00bb 1e01          	ldw	x,(OFST-1,sp)
 386  00bd 4f            	clr	a
 387  00be 01            	rrwa	x,a
 388  00bf 54            	srlw	x
 389  00c0 9f            	ld	a,xl
 390  00c1 c75265        	ld	21093,a
 391                     ; 65     TIM1 -> CCR1L = (unsigned char)(Pll_num / 2);    
 393  00c4 1e01          	ldw	x,(OFST-1,sp)
 394  00c6 54            	srlw	x
 395  00c7 9f            	ld	a,xl
 396  00c8 c75266        	ld	21094,a
 397                     ; 67     TIM1 -> CR1 |= 0x01;
 399  00cb 72105250      	bset	21072,#0
 400                     ; 68 }
 403  00cf 85            	popw	x
 404  00d0 81            	ret
 448                     ; 70 void Out_125K(unsigned int tim, unsigned char LF_Send_CHx)
 448                     ; 71 {      
 449                     	switch	.text
 450  00d1               _Out_125K:
 452  00d1 89            	pushw	x
 453       00000000      OFST:	set	0
 456                     ; 72     switch(LF_Send_CHx)
 458  00d2 7b05          	ld	a,(OFST+5,sp)
 460                     ; 86         default:
 460                     ; 87             break;
 461  00d4 4a            	dec	a
 462  00d5 2708          	jreq	L531
 463  00d7 4a            	dec	a
 464  00d8 2710          	jreq	L731
 465  00da 4a            	dec	a
 466  00db 2718          	jreq	L141
 467  00dd 201f          	jra	L171
 468  00df               L531:
 469                     ; 74         case LF_SEND_CH1:
 469                     ; 75             CH1_GPIO_OPEN;
 471  00df 721a5014      	bset	20500,#5
 472                     ; 76             Delay_us(tim);
 474  00e3 1e01          	ldw	x,(OFST+1,sp)
 475  00e5 cd0029        	call	_Delay_us
 477                     ; 77             break;
 479  00e8 2014          	jra	L171
 480  00ea               L731:
 481                     ; 78         case LF_SEND_CH2:
 481                     ; 79             CH2_GPIO_OPEN;
 483  00ea 7216500a      	bset	20490,#3
 484                     ; 80             Delay_us(tim);
 486  00ee 1e01          	ldw	x,(OFST+1,sp)
 487  00f0 cd0029        	call	_Delay_us
 489                     ; 81             break;	
 491  00f3 2009          	jra	L171
 492  00f5               L141:
 493                     ; 82         case LF_SEND_CH3:
 493                     ; 83             CH3_GPIO_OPEN;
 495  00f5 7218500a      	bset	20490,#4
 496                     ; 84             Delay_us(tim);
 498  00f9 1e01          	ldw	x,(OFST+1,sp)
 499  00fb cd0029        	call	_Delay_us
 501                     ; 85             break;
 503  00fe               L341:
 504                     ; 86         default:
 504                     ; 87             break;
 506  00fe               L171:
 507                     ; 89 }
 510  00fe 85            	popw	x
 511  00ff 81            	ret
 555                     ; 91 void Clock_125K(unsigned int tim, unsigned char LF_Send_CHx)
 555                     ; 92 {      
 556                     	switch	.text
 557  0100               _Clock_125K:
 559  0100 89            	pushw	x
 560       00000000      OFST:	set	0
 563                     ; 93     switch(LF_Send_CHx)
 565  0101 7b05          	ld	a,(OFST+5,sp)
 567                     ; 107         default:
 567                     ; 108             break;
 568  0103 4a            	dec	a
 569  0104 2708          	jreq	L371
 570  0106 4a            	dec	a
 571  0107 2710          	jreq	L571
 572  0109 4a            	dec	a
 573  010a 2718          	jreq	L771
 574  010c 201f          	jra	L722
 575  010e               L371:
 576                     ; 95         case LF_SEND_CH1:
 576                     ; 96             CH1_GPIO_CLOCK;
 578  010e 721b5014      	bres	20500,#5
 579                     ; 97             Delay_us(tim);
 581  0112 1e01          	ldw	x,(OFST+1,sp)
 582  0114 cd0029        	call	_Delay_us
 584                     ; 98             break;
 586  0117 2014          	jra	L722
 587  0119               L571:
 588                     ; 99         case LF_SEND_CH2:
 588                     ; 100             CH2_GPIO_CLOCK;
 590  0119 7217500a      	bres	20490,#3
 591                     ; 101             Delay_us(tim);
 593  011d 1e01          	ldw	x,(OFST+1,sp)
 594  011f cd0029        	call	_Delay_us
 596                     ; 102             break;	
 598  0122 2009          	jra	L722
 599  0124               L771:
 600                     ; 103         case LF_SEND_CH3:
 600                     ; 104             CH3_GPIO_CLOCK;
 602  0124 7219500a      	bres	20490,#4
 603                     ; 105             Delay_us(tim);
 605  0128 1e01          	ldw	x,(OFST+1,sp)
 606  012a cd0029        	call	_Delay_us
 608                     ; 106             break;
 610  012d               L102:
 611                     ; 107         default:
 611                     ; 108             break;
 613  012d               L722:
 614                     ; 110 }
 617  012d 85            	popw	x
 618  012e 81            	ret
 664                     ; 112 void Timecalculate(void)
 664                     ; 113 {
 665                     	switch	.text
 666  012f               _Timecalculate:
 668  012f 5206          	subw	sp,#6
 669       00000006      OFST:	set	6
 672                     ; 117     Tcarr = 1000 / LF_PLL;    
 674  0131 ae03e8        	ldw	x,#1000
 675  0134 b609          	ld	a,_Set_Buff+3
 676  0136 905f          	clrw	y
 677  0138 9097          	ld	yl,a
 678  013a cd0000        	call	c_idiv
 680  013d 01            	rrwa	x,a
 681  013e 6b05          	ld	(OFST-1,sp),a
 682  0140 02            	rlwa	x,a
 684                     ; 118     Tclk  = 1000000 / (RC_PLL1 * 256 + RC_PLL2); 
 686  0141 b60a          	ld	a,_Set_Buff+4
 687  0143 5f            	clrw	x
 688  0144 97            	ld	xl,a
 689  0145 4f            	clr	a
 690  0146 02            	rlwa	x,a
 691  0147 01            	rrwa	x,a
 692  0148 bb0b          	add	a,_Set_Buff+5
 693  014a 2401          	jrnc	L22
 694  014c 5c            	incw	x
 695  014d               L22:
 696  014d cd0000        	call	c_itol
 698  0150 96            	ldw	x,sp
 699  0151 1c0001        	addw	x,#OFST-5
 700  0154 cd0000        	call	c_rtol
 703  0157 ae4240        	ldw	x,#16960
 704  015a bf02          	ldw	c_lreg+2,x
 705  015c ae000f        	ldw	x,#15
 706  015f bf00          	ldw	c_lreg,x
 707  0161 96            	ldw	x,sp
 708  0162 1c0001        	addw	x,#OFST-5
 709  0165 cd0000        	call	c_ldiv
 711  0168 b603          	ld	a,c_lreg+3
 712  016a 6b06          	ld	(OFST+0,sp),a
 714                     ; 119     Tclk  = 256 - Tclk;       
 716  016c a600          	ld	a,#0
 717  016e 1006          	sub	a,(OFST+0,sp)
 718  0170 6b06          	ld	(OFST+0,sp),a
 720                     ; 120     Tclk  = Tclk;             
 722                     ; 122     Bit_element = LFBIT_NxRC + Tclk * LFBIT_NxRC;   
 724  0172 7b06          	ld	a,(OFST+0,sp)
 725  0174 97            	ld	xl,a
 726  0175 b610          	ld	a,_Set_Buff+10
 727  0177 42            	mul	x,a
 728  0178 01            	rrwa	x,a
 729  0179 bb10          	add	a,_Set_Buff+10
 730  017b 2401          	jrnc	L42
 731  017d 5c            	incw	x
 732  017e               L42:
 733  017e b705          	ld	_Bit_element+1,a
 734  0180 9f            	ld	a,xl
 735  0181 b704          	ld	_Bit_element,a
 736                     ; 124     if(ONOFF_SCAN)      // 超碼模式
 738  0183 3d0c          	tnz	_Set_Buff+6
 739  0185 2603          	jrne	L62
 740  0187 cc0265        	jp	L352
 741  018a               L62:
 742                     ; 126         if((LF_PLL >= 15) && (LF_PLL <= 23))
 744  018a b609          	ld	a,_Set_Buff+3
 745  018c a10f          	cp	a,#15
 746  018e 2524          	jrult	L552
 748  0190 b609          	ld	a,_Set_Buff+3
 749  0192 a118          	cp	a,#24
 750  0194 241e          	jruge	L552
 751                     ; 128             Carrier_Time = 220 * Tclk + 8 * Tcarr;
 753  0196 7b05          	ld	a,(OFST-1,sp)
 754  0198 97            	ld	xl,a
 755  0199 a608          	ld	a,#8
 756  019b 42            	mul	x,a
 757  019c 1f03          	ldw	(OFST-3,sp),x
 759  019e 7b06          	ld	a,(OFST+0,sp)
 760  01a0 97            	ld	xl,a
 761  01a1 a6dc          	ld	a,#220
 762  01a3 42            	mul	x,a
 763  01a4 72fb03        	addw	x,(OFST-3,sp)
 764  01a7 bf02          	ldw	_Carrier_Time,x
 765                     ; 129             Carrier_Time =  Carrier_Time + 500;    //us
 767  01a9 be02          	ldw	x,_Carrier_Time
 768  01ab 1c01f4        	addw	x,#500
 769  01ae bf02          	ldw	_Carrier_Time,x
 771  01b0 ac340334      	jpf	L103
 772  01b4               L552:
 773                     ; 131         else if((LF_PLL > 23) && (LF_PLL <= 40))
 775  01b4 b609          	ld	a,_Set_Buff+3
 776  01b6 a118          	cp	a,#24
 777  01b8 2524          	jrult	L162
 779  01ba b609          	ld	a,_Set_Buff+3
 780  01bc a129          	cp	a,#41
 781  01be 241e          	jruge	L162
 782                     ; 133             Carrier_Time = 224 * Tclk + 16 * Tcarr;
 784  01c0 7b05          	ld	a,(OFST-1,sp)
 785  01c2 97            	ld	xl,a
 786  01c3 a610          	ld	a,#16
 787  01c5 42            	mul	x,a
 788  01c6 1f03          	ldw	(OFST-3,sp),x
 790  01c8 7b06          	ld	a,(OFST+0,sp)
 791  01ca 97            	ld	xl,a
 792  01cb a6e0          	ld	a,#224
 793  01cd 42            	mul	x,a
 794  01ce 72fb03        	addw	x,(OFST-3,sp)
 795  01d1 bf02          	ldw	_Carrier_Time,x
 796                     ; 134             Carrier_Time =  Carrier_Time + 500;    //us
 798  01d3 be02          	ldw	x,_Carrier_Time
 799  01d5 1c01f4        	addw	x,#500
 800  01d8 bf02          	ldw	_Carrier_Time,x
 802  01da ac340334      	jpf	L103
 803  01de               L162:
 804                     ; 136         else if((LF_PLL > 40) && (LF_PLL <= 65))
 806  01de b609          	ld	a,_Set_Buff+3
 807  01e0 a129          	cp	a,#41
 808  01e2 2524          	jrult	L562
 810  01e4 b609          	ld	a,_Set_Buff+3
 811  01e6 a142          	cp	a,#66
 812  01e8 241e          	jruge	L562
 813                     ; 138             Carrier_Time = 180 * Tclk + 16 * Tcarr;
 815  01ea 7b05          	ld	a,(OFST-1,sp)
 816  01ec 97            	ld	xl,a
 817  01ed a610          	ld	a,#16
 818  01ef 42            	mul	x,a
 819  01f0 1f03          	ldw	(OFST-3,sp),x
 821  01f2 7b06          	ld	a,(OFST+0,sp)
 822  01f4 97            	ld	xl,a
 823  01f5 a6b4          	ld	a,#180
 824  01f7 42            	mul	x,a
 825  01f8 72fb03        	addw	x,(OFST-3,sp)
 826  01fb bf02          	ldw	_Carrier_Time,x
 827                     ; 139             Carrier_Time =  Carrier_Time + 500;    //us
 829  01fd be02          	ldw	x,_Carrier_Time
 830  01ff 1c01f4        	addw	x,#500
 831  0202 bf02          	ldw	_Carrier_Time,x
 833  0204 ac340334      	jpf	L103
 834  0208               L562:
 835                     ; 141         else if((LF_PLL > 65) && (LF_PLL <= 95))
 837  0208 b609          	ld	a,_Set_Buff+3
 838  020a a142          	cp	a,#66
 839  020c 2524          	jrult	L172
 841  020e b609          	ld	a,_Set_Buff+3
 842  0210 a160          	cp	a,#96
 843  0212 241e          	jruge	L172
 844                     ; 143             Carrier_Time = 92 * Tclk + 16 * Tcarr;
 846  0214 7b05          	ld	a,(OFST-1,sp)
 847  0216 97            	ld	xl,a
 848  0217 a610          	ld	a,#16
 849  0219 42            	mul	x,a
 850  021a 1f03          	ldw	(OFST-3,sp),x
 852  021c 7b06          	ld	a,(OFST+0,sp)
 853  021e 97            	ld	xl,a
 854  021f a65c          	ld	a,#92
 855  0221 42            	mul	x,a
 856  0222 72fb03        	addw	x,(OFST-3,sp)
 857  0225 bf02          	ldw	_Carrier_Time,x
 858                     ; 144             Carrier_Time =  Carrier_Time + 500;    //us
 860  0227 be02          	ldw	x,_Carrier_Time
 861  0229 1c01f4        	addw	x,#500
 862  022c bf02          	ldw	_Carrier_Time,x
 864  022e ac340334      	jpf	L103
 865  0232               L172:
 866                     ; 146         else if((LF_PLL > 95) && (LF_PLL <= 150))
 868  0232 b609          	ld	a,_Set_Buff+3
 869  0234 a160          	cp	a,#96
 870  0236 2524          	jrult	L572
 872  0238 b609          	ld	a,_Set_Buff+3
 873  023a a197          	cp	a,#151
 874  023c 241e          	jruge	L572
 875                     ; 148             Carrier_Time = 80 * Tclk + 16 * Tcarr;
 877  023e 7b05          	ld	a,(OFST-1,sp)
 878  0240 97            	ld	xl,a
 879  0241 a610          	ld	a,#16
 880  0243 42            	mul	x,a
 881  0244 1f03          	ldw	(OFST-3,sp),x
 883  0246 7b06          	ld	a,(OFST+0,sp)
 884  0248 97            	ld	xl,a
 885  0249 a650          	ld	a,#80
 886  024b 42            	mul	x,a
 887  024c 72fb03        	addw	x,(OFST-3,sp)
 888  024f bf02          	ldw	_Carrier_Time,x
 889                     ; 149             Carrier_Time =  Carrier_Time + 500;    //us
 891  0251 be02          	ldw	x,_Carrier_Time
 892  0253 1c01f4        	addw	x,#500
 893  0256 bf02          	ldw	_Carrier_Time,x
 895  0258 ac340334      	jpf	L103
 896  025c               L572:
 897                     ; 152             Carrier_Time =  3000;    //us	       
 899  025c ae0bb8        	ldw	x,#3000
 900  025f bf02          	ldw	_Carrier_Time,x
 901  0261 ac340334      	jpf	L103
 902  0265               L352:
 903                     ; 156         if((LF_PLL >= 15) && (LF_PLL <= 23))
 905  0265 b609          	ld	a,_Set_Buff+3
 906  0267 a10f          	cp	a,#15
 907  0269 2524          	jrult	L303
 909  026b b609          	ld	a,_Set_Buff+3
 910  026d a118          	cp	a,#24
 911  026f 241e          	jruge	L303
 912                     ; 158             Carrier_Time = 92 * Tclk + 8 * Tcarr;
 914  0271 7b05          	ld	a,(OFST-1,sp)
 915  0273 97            	ld	xl,a
 916  0274 a608          	ld	a,#8
 917  0276 42            	mul	x,a
 918  0277 1f03          	ldw	(OFST-3,sp),x
 920  0279 7b06          	ld	a,(OFST+0,sp)
 921  027b 97            	ld	xl,a
 922  027c a65c          	ld	a,#92
 923  027e 42            	mul	x,a
 924  027f 72fb03        	addw	x,(OFST-3,sp)
 925  0282 bf02          	ldw	_Carrier_Time,x
 926                     ; 159             Carrier_Time =  Carrier_Time + 500;    //us
 928  0284 be02          	ldw	x,_Carrier_Time
 929  0286 1c01f4        	addw	x,#500
 930  0289 bf02          	ldw	_Carrier_Time,x
 932  028b ac340334      	jpf	L103
 933  028f               L303:
 934                     ; 161         else if((LF_PLL > 23) && (LF_PLL <= 40))
 936  028f b609          	ld	a,_Set_Buff+3
 937  0291 a118          	cp	a,#24
 938  0293 2522          	jrult	L703
 940  0295 b609          	ld	a,_Set_Buff+3
 941  0297 a129          	cp	a,#41
 942  0299 241c          	jruge	L703
 943                     ; 163             Carrier_Time = 96 * Tclk + 16 * Tcarr;
 945  029b 7b05          	ld	a,(OFST-1,sp)
 946  029d 97            	ld	xl,a
 947  029e a610          	ld	a,#16
 948  02a0 42            	mul	x,a
 949  02a1 1f03          	ldw	(OFST-3,sp),x
 951  02a3 7b06          	ld	a,(OFST+0,sp)
 952  02a5 97            	ld	xl,a
 953  02a6 a660          	ld	a,#96
 954  02a8 42            	mul	x,a
 955  02a9 72fb03        	addw	x,(OFST-3,sp)
 956  02ac bf02          	ldw	_Carrier_Time,x
 957                     ; 164             Carrier_Time =  Carrier_Time + 500;    //us
 959  02ae be02          	ldw	x,_Carrier_Time
 960  02b0 1c01f4        	addw	x,#500
 961  02b3 bf02          	ldw	_Carrier_Time,x
 963  02b5 207d          	jra	L103
 964  02b7               L703:
 965                     ; 166         else if((LF_PLL > 40) && (LF_PLL <= 65))
 967  02b7 b609          	ld	a,_Set_Buff+3
 968  02b9 a129          	cp	a,#41
 969  02bb 2522          	jrult	L313
 971  02bd b609          	ld	a,_Set_Buff+3
 972  02bf a142          	cp	a,#66
 973  02c1 241c          	jruge	L313
 974                     ; 168             Carrier_Time = 52 * Tclk + 16 * Tcarr;
 976  02c3 7b05          	ld	a,(OFST-1,sp)
 977  02c5 97            	ld	xl,a
 978  02c6 a610          	ld	a,#16
 979  02c8 42            	mul	x,a
 980  02c9 1f03          	ldw	(OFST-3,sp),x
 982  02cb 7b06          	ld	a,(OFST+0,sp)
 983  02cd 97            	ld	xl,a
 984  02ce a634          	ld	a,#52
 985  02d0 42            	mul	x,a
 986  02d1 72fb03        	addw	x,(OFST-3,sp)
 987  02d4 bf02          	ldw	_Carrier_Time,x
 988                     ; 169             Carrier_Time =  Carrier_Time + 500;    //us
 990  02d6 be02          	ldw	x,_Carrier_Time
 991  02d8 1c01f4        	addw	x,#500
 992  02db bf02          	ldw	_Carrier_Time,x
 994  02dd 2055          	jra	L103
 995  02df               L313:
 996                     ; 171         else if((LF_PLL > 65) && (LF_PLL <= 95))
 998  02df b609          	ld	a,_Set_Buff+3
 999  02e1 a142          	cp	a,#66
1000  02e3 2522          	jrult	L713
1002  02e5 b609          	ld	a,_Set_Buff+3
1003  02e7 a160          	cp	a,#96
1004  02e9 241c          	jruge	L713
1005                     ; 173             Carrier_Time = 28 * Tclk + 16 * Tcarr;
1007  02eb 7b05          	ld	a,(OFST-1,sp)
1008  02ed 97            	ld	xl,a
1009  02ee a610          	ld	a,#16
1010  02f0 42            	mul	x,a
1011  02f1 1f03          	ldw	(OFST-3,sp),x
1013  02f3 7b06          	ld	a,(OFST+0,sp)
1014  02f5 97            	ld	xl,a
1015  02f6 a61c          	ld	a,#28
1016  02f8 42            	mul	x,a
1017  02f9 72fb03        	addw	x,(OFST-3,sp)
1018  02fc bf02          	ldw	_Carrier_Time,x
1019                     ; 174             Carrier_Time =  Carrier_Time + 500;    //us
1021  02fe be02          	ldw	x,_Carrier_Time
1022  0300 1c01f4        	addw	x,#500
1023  0303 bf02          	ldw	_Carrier_Time,x
1025  0305 202d          	jra	L103
1026  0307               L713:
1027                     ; 176         else if((LF_PLL > 95) && (LF_PLL <= 150))
1029  0307 b609          	ld	a,_Set_Buff+3
1030  0309 a160          	cp	a,#96
1031  030b 2522          	jrult	L323
1033  030d b609          	ld	a,_Set_Buff+3
1034  030f a197          	cp	a,#151
1035  0311 241c          	jruge	L323
1036                     ; 178             Carrier_Time = 16 * Tclk + 16 * Tcarr;
1038  0313 7b05          	ld	a,(OFST-1,sp)
1039  0315 97            	ld	xl,a
1040  0316 a610          	ld	a,#16
1041  0318 42            	mul	x,a
1042  0319 1f03          	ldw	(OFST-3,sp),x
1044  031b 7b06          	ld	a,(OFST+0,sp)
1045  031d 97            	ld	xl,a
1046  031e a610          	ld	a,#16
1047  0320 42            	mul	x,a
1048  0321 72fb03        	addw	x,(OFST-3,sp)
1049  0324 bf02          	ldw	_Carrier_Time,x
1050                     ; 179             Carrier_Time =  Carrier_Time + 1000;   //us
1052  0326 be02          	ldw	x,_Carrier_Time
1053  0328 1c03e8        	addw	x,#1000
1054  032b bf02          	ldw	_Carrier_Time,x
1056  032d 2005          	jra	L103
1057  032f               L323:
1058                     ; 182             Carrier_Time =  2000;    //us	
1060  032f ae07d0        	ldw	x,#2000
1061  0332 bf02          	ldw	_Carrier_Time,x
1062  0334               L103:
1063                     ; 184 }
1066  0334 5b06          	addw	sp,#6
1067  0336 81            	ret
1116                     ; 186 void CarrierBurst(unsigned char LF_Send_CHx)     
1116                     ; 187 {      
1117                     	switch	.text
1118  0337               _CarrierBurst:
1120  0337 88            	push	a
1121  0338 88            	push	a
1122       00000001      OFST:	set	1
1125                     ; 189     CH1_GPIO_CLOCK;
1127  0339 721b5014      	bres	20500,#5
1128                     ; 190     CH2_GPIO_CLOCK;
1130  033d 7217500a      	bres	20490,#3
1131                     ; 191     CH3_GPIO_CLOCK;
1133  0341 7219500a      	bres	20490,#4
1134                     ; 193     Timecalculate(); 
1136  0345 cd012f        	call	_Timecalculate
1138                     ; 194     Out_125K(Carrier_Time,LF_Send_CHx);
1140  0348 7b02          	ld	a,(OFST+1,sp)
1141  034a 88            	push	a
1142  034b be02          	ldw	x,_Carrier_Time
1143  034d cd00d1        	call	_Out_125K
1145  0350 84            	pop	a
1146                     ; 195     Clock_125K(Bit_element,LF_Send_CHx);
1148  0351 7b02          	ld	a,(OFST+1,sp)
1149  0353 88            	push	a
1150  0354 be04          	ldw	x,_Bit_element
1151  0356 cd0100        	call	_Clock_125K
1153  0359 84            	pop	a
1154                     ; 197     if(LFSENDMODE)    
1156  035a 3d11          	tnz	_Set_Buff+11
1157  035c 271c          	jreq	L153
1158                     ; 199         for(i = 0; i < 8; i++)    
1160  035e 0f01          	clr	(OFST+0,sp)
1162  0360               L353:
1163                     ; 201             Out_125K(Bit_element,LF_Send_CHx);
1165  0360 7b02          	ld	a,(OFST+1,sp)
1166  0362 88            	push	a
1167  0363 be04          	ldw	x,_Bit_element
1168  0365 cd00d1        	call	_Out_125K
1170  0368 84            	pop	a
1171                     ; 202             Clock_125K(Bit_element,LF_Send_CHx);
1173  0369 7b02          	ld	a,(OFST+1,sp)
1174  036b 88            	push	a
1175  036c be04          	ldw	x,_Bit_element
1176  036e cd0100        	call	_Clock_125K
1178  0371 84            	pop	a
1179                     ; 199         for(i = 0; i < 8; i++)    
1181  0372 0c01          	inc	(OFST+0,sp)
1185  0374 7b01          	ld	a,(OFST+0,sp)
1186  0376 a108          	cp	a,#8
1187  0378 25e6          	jrult	L353
1188  037a               L153:
1189                     ; 205 }
1192  037a 85            	popw	x
1193  037b 81            	ret
1284                     ; 207 void Pattern(unsigned char R6_Dat,
1284                     ; 208              unsigned char R5_Dat,
1284                     ; 209              unsigned char Patt16_32,
1284                     ; 210              unsigned char LF_Send_CHx)    
1284                     ; 211 {
1285                     	switch	.text
1286  037c               _Pattern:
1288  037c 89            	pushw	x
1289  037d 5205          	subw	sp,#5
1290       00000005      OFST:	set	5
1293                     ; 213     unsigned int Patt_Data = 0;
1295                     ; 214     unsigned int Temp_x    = 0;
1297                     ; 216     Patt_Data = (unsigned int)R6_Dat * 256 + R5_Dat;
1299  037f 9e            	ld	a,xh
1300  0380 5f            	clrw	x
1301  0381 97            	ld	xl,a
1302  0382 4f            	clr	a
1303  0383 02            	rlwa	x,a
1304  0384 01            	rrwa	x,a
1305  0385 1b07          	add	a,(OFST+2,sp)
1306  0387 2401          	jrnc	L43
1307  0389 5c            	incw	x
1308  038a               L43:
1309  038a 02            	rlwa	x,a
1310  038b 1f04          	ldw	(OFST-1,sp),x
1311  038d 01            	rrwa	x,a
1313                     ; 217     Temp_x = 0x8000;
1315  038e ae8000        	ldw	x,#32768
1316  0391 1f01          	ldw	(OFST-4,sp),x
1318                     ; 219     if(Patt16_32 == Patt_32bit)
1320  0393 7b0a          	ld	a,(OFST+5,sp)
1321  0395 a101          	cp	a,#1
1322  0397 2644          	jrne	L724
1323                     ; 221         for(i = 0; i < 16; i++)
1325  0399 0f03          	clr	(OFST-2,sp)
1327  039b               L134:
1328                     ; 223             if(Patt_Data & Temp_x) 		 
1330  039b 1e04          	ldw	x,(OFST-1,sp)
1331  039d 01            	rrwa	x,a
1332  039e 1402          	and	a,(OFST-3,sp)
1333  03a0 01            	rrwa	x,a
1334  03a1 1401          	and	a,(OFST-4,sp)
1335  03a3 01            	rrwa	x,a
1336  03a4 a30000        	cpw	x,#0
1337  03a7 2714          	jreq	L734
1338                     ; 225                 Out_125K(Bit_element,LF_Send_CHx);
1340  03a9 7b0b          	ld	a,(OFST+6,sp)
1341  03ab 88            	push	a
1342  03ac be04          	ldw	x,_Bit_element
1343  03ae cd00d1        	call	_Out_125K
1345  03b1 84            	pop	a
1346                     ; 226                 Clock_125K(Bit_element,LF_Send_CHx); 	
1348  03b2 7b0b          	ld	a,(OFST+6,sp)
1349  03b4 88            	push	a
1350  03b5 be04          	ldw	x,_Bit_element
1351  03b7 cd0100        	call	_Clock_125K
1353  03ba 84            	pop	a
1355  03bb 2012          	jra	L144
1356  03bd               L734:
1357                     ; 230                 Clock_125K(Bit_element,LF_Send_CHx);
1359  03bd 7b0b          	ld	a,(OFST+6,sp)
1360  03bf 88            	push	a
1361  03c0 be04          	ldw	x,_Bit_element
1362  03c2 cd0100        	call	_Clock_125K
1364  03c5 84            	pop	a
1365                     ; 231                 Out_125K(Bit_element,LF_Send_CHx);
1367  03c6 7b0b          	ld	a,(OFST+6,sp)
1368  03c8 88            	push	a
1369  03c9 be04          	ldw	x,_Bit_element
1370  03cb cd00d1        	call	_Out_125K
1372  03ce 84            	pop	a
1373  03cf               L144:
1374                     ; 233             Patt_Data = (unsigned int)(Patt_Data << 1);		
1376  03cf 0805          	sll	(OFST+0,sp)
1377  03d1 0904          	rlc	(OFST-1,sp)
1379                     ; 221         for(i = 0; i < 16; i++)
1381  03d3 0c03          	inc	(OFST-2,sp)
1385  03d5 7b03          	ld	a,(OFST-2,sp)
1386  03d7 a110          	cp	a,#16
1387  03d9 25c0          	jrult	L134
1389  03db 2030          	jra	L344
1390  03dd               L724:
1391                     ; 238         for(i = 0; i < 16; i++)    
1393  03dd 0f03          	clr	(OFST-2,sp)
1395  03df               L544:
1396                     ; 240             if(Patt_Data & Temp_x)
1398  03df 1e04          	ldw	x,(OFST-1,sp)
1399  03e1 01            	rrwa	x,a
1400  03e2 1402          	and	a,(OFST-3,sp)
1401  03e4 01            	rrwa	x,a
1402  03e5 1401          	and	a,(OFST-4,sp)
1403  03e7 01            	rrwa	x,a
1404  03e8 a30000        	cpw	x,#0
1405  03eb 270b          	jreq	L354
1406                     ; 242                 Out_125K(Bit_element,LF_Send_CHx);
1408  03ed 7b0b          	ld	a,(OFST+6,sp)
1409  03ef 88            	push	a
1410  03f0 be04          	ldw	x,_Bit_element
1411  03f2 cd00d1        	call	_Out_125K
1413  03f5 84            	pop	a
1415  03f6 2009          	jra	L554
1416  03f8               L354:
1417                     ; 246                 Clock_125K(Bit_element,LF_Send_CHx);
1419  03f8 7b0b          	ld	a,(OFST+6,sp)
1420  03fa 88            	push	a
1421  03fb be04          	ldw	x,_Bit_element
1422  03fd cd0100        	call	_Clock_125K
1424  0400 84            	pop	a
1425  0401               L554:
1426                     ; 248             Patt_Data = (unsigned int)(Patt_Data << 1);			
1428  0401 0805          	sll	(OFST+0,sp)
1429  0403 0904          	rlc	(OFST-1,sp)
1431                     ; 238         for(i = 0; i < 16; i++)    
1433  0405 0c03          	inc	(OFST-2,sp)
1437  0407 7b03          	ld	a,(OFST-2,sp)
1438  0409 a110          	cp	a,#16
1439  040b 25d2          	jrult	L544
1440  040d               L344:
1441                     ; 251 }
1444  040d 5b07          	addw	sp,#7
1445  040f 81            	ret
1542                     ; 253 void LF_SendData(unsigned char R6_Dat,
1542                     ; 254                  unsigned char R5_Dat,
1542                     ; 255                  unsigned char Patt16_32,
1542                     ; 256                  unsigned char LF_Send_CHx)
1542                     ; 257 {
1543                     	switch	.text
1544  0410               _LF_SendData:
1546  0410 89            	pushw	x
1547  0411 5216          	subw	sp,#22
1548       00000016      OFST:	set	22
1551                     ; 261     if((LFBIT_NxRC < 4) || (LFBIT_NxRC > 32))
1553  0413 b610          	ld	a,_Set_Buff+10
1554  0415 a104          	cp	a,#4
1555  0417 2506          	jrult	L725
1557  0419 b610          	ld	a,_Set_Buff+10
1558  041b a121          	cp	a,#33
1559  041d 2504          	jrult	L525
1560  041f               L725:
1561                     ; 262         return;
1563  041f acff04ff      	jpf	L25
1564  0423               L525:
1565                     ; 264     Data_Buff[0] = ACTIVE_NUM + 2;
1567  0423 b615          	ld	a,_Set_Buff+15
1568  0425 ab02          	add	a,#2
1569  0427 6b02          	ld	(OFST-20,sp),a
1571                     ; 265     Data_Buff[1] = DEVICE_ID;
1573  0429 b608          	ld	a,_Set_Buff+2
1574  042b 6b03          	ld	(OFST-19,sp),a
1576                     ; 266     Data_Buff[ACTIVE_NUM + 2] = 0;
1578  042d 96            	ldw	x,sp
1579  042e 1c0004        	addw	x,#OFST-18
1580  0431 9f            	ld	a,xl
1581  0432 5e            	swapw	x
1582  0433 bb15          	add	a,_Set_Buff+15
1583  0435 2401          	jrnc	L04
1584  0437 5c            	incw	x
1585  0438               L04:
1586  0438 02            	rlwa	x,a
1587  0439 7f            	clr	(x)
1588                     ; 268     for(i = 0; i < ACTIVE_NUM; i++)
1590  043a 0f16          	clr	(OFST+0,sp)
1593  043c 2018          	jra	L535
1594  043e               L135:
1595                     ; 269         Data_Buff[i+2] = Set_Buff[i+16];
1597  043e 96            	ldw	x,sp
1598  043f 1c0004        	addw	x,#OFST-18
1599  0442 9f            	ld	a,xl
1600  0443 5e            	swapw	x
1601  0444 1b16          	add	a,(OFST+0,sp)
1602  0446 2401          	jrnc	L24
1603  0448 5c            	incw	x
1604  0449               L24:
1605  0449 02            	rlwa	x,a
1606  044a 7b16          	ld	a,(OFST+0,sp)
1607  044c 905f          	clrw	y
1608  044e 9097          	ld	yl,a
1609  0450 90e616        	ld	a,(_Set_Buff+16,y)
1610  0453 f7            	ld	(x),a
1611                     ; 268     for(i = 0; i < ACTIVE_NUM; i++)
1613  0454 0c16          	inc	(OFST+0,sp)
1615  0456               L535:
1618  0456 7b16          	ld	a,(OFST+0,sp)
1619  0458 b115          	cp	a,_Set_Buff+15
1620  045a 25e2          	jrult	L135
1621                     ; 271     for(i = 0; i < ACTIVE_NUM; i++)
1623  045c 0f16          	clr	(OFST+0,sp)
1626  045e 2019          	jra	L545
1627  0460               L145:
1628                     ; 272         Data_Buff[ACTIVE_NUM + 2] += Set_Buff[i+16];
1630  0460 96            	ldw	x,sp
1631  0461 1c0004        	addw	x,#OFST-18
1632  0464 9f            	ld	a,xl
1633  0465 5e            	swapw	x
1634  0466 bb15          	add	a,_Set_Buff+15
1635  0468 2401          	jrnc	L44
1636  046a 5c            	incw	x
1637  046b               L44:
1638  046b 02            	rlwa	x,a
1639  046c 7b16          	ld	a,(OFST+0,sp)
1640  046e 905f          	clrw	y
1641  0470 9097          	ld	yl,a
1642  0472 f6            	ld	a,(x)
1643  0473 90eb16        	add	a,(_Set_Buff+16,y)
1644  0476 f7            	ld	(x),a
1645                     ; 271     for(i = 0; i < ACTIVE_NUM; i++)
1647  0477 0c16          	inc	(OFST+0,sp)
1649  0479               L545:
1652  0479 7b16          	ld	a,(OFST+0,sp)
1653  047b b115          	cp	a,_Set_Buff+15
1654  047d 25e1          	jrult	L145
1655                     ; 274     disableInterrupts();
1658  047f 9b            sim
1660                     ; 276     CarrierBurst(LF_Send_CHx);	
1663  0480 7b1c          	ld	a,(OFST+6,sp)
1664  0482 cd0337        	call	_CarrierBurst
1666                     ; 277     Pattern(R6_Dat,R5_Dat,Patt16_32,LF_Send_CHx);
1668  0485 7b1c          	ld	a,(OFST+6,sp)
1669  0487 88            	push	a
1670  0488 7b1c          	ld	a,(OFST+6,sp)
1671  048a 88            	push	a
1672  048b 7b1a          	ld	a,(OFST+4,sp)
1673  048d 97            	ld	xl,a
1674  048e 7b19          	ld	a,(OFST+3,sp)
1675  0490 95            	ld	xh,a
1676  0491 cd037c        	call	_Pattern
1678  0494 85            	popw	x
1679                     ; 279     for(i = 0; i < ACTIVE_NUM+3; i++)
1681  0495 0f16          	clr	(OFST+0,sp)
1684  0497 2050          	jra	L555
1685  0499               L155:
1686                     ; 281         for(j = 0; j < 8; j++)
1688  0499 0f01          	clr	(OFST-21,sp)
1690  049b               L165:
1691                     ; 283             if(Data_Buff[i] & 0x80)
1693  049b 96            	ldw	x,sp
1694  049c 1c0002        	addw	x,#OFST-20
1695  049f 9f            	ld	a,xl
1696  04a0 5e            	swapw	x
1697  04a1 1b16          	add	a,(OFST+0,sp)
1698  04a3 2401          	jrnc	L64
1699  04a5 5c            	incw	x
1700  04a6               L64:
1701  04a6 02            	rlwa	x,a
1702  04a7 f6            	ld	a,(x)
1703  04a8 a580          	bcp	a,#128
1704  04aa 2714          	jreq	L765
1705                     ; 285                 Out_125K(Bit_element,LF_Send_CHx);
1707  04ac 7b1c          	ld	a,(OFST+6,sp)
1708  04ae 88            	push	a
1709  04af be04          	ldw	x,_Bit_element
1710  04b1 cd00d1        	call	_Out_125K
1712  04b4 84            	pop	a
1713                     ; 286                 Clock_125K(Bit_element,LF_Send_CHx);
1715  04b5 7b1c          	ld	a,(OFST+6,sp)
1716  04b7 88            	push	a
1717  04b8 be04          	ldw	x,_Bit_element
1718  04ba cd0100        	call	_Clock_125K
1720  04bd 84            	pop	a
1722  04be 2012          	jra	L175
1723  04c0               L765:
1724                     ; 290                 Clock_125K(Bit_element,LF_Send_CHx);	
1726  04c0 7b1c          	ld	a,(OFST+6,sp)
1727  04c2 88            	push	a
1728  04c3 be04          	ldw	x,_Bit_element
1729  04c5 cd0100        	call	_Clock_125K
1731  04c8 84            	pop	a
1732                     ; 291                 Out_125K(Bit_element,LF_Send_CHx);						
1734  04c9 7b1c          	ld	a,(OFST+6,sp)
1735  04cb 88            	push	a
1736  04cc be04          	ldw	x,_Bit_element
1737  04ce cd00d1        	call	_Out_125K
1739  04d1 84            	pop	a
1740  04d2               L175:
1741                     ; 293             Data_Buff[i]= Data_Buff[i] << 1;
1743  04d2 96            	ldw	x,sp
1744  04d3 1c0002        	addw	x,#OFST-20
1745  04d6 9f            	ld	a,xl
1746  04d7 5e            	swapw	x
1747  04d8 1b16          	add	a,(OFST+0,sp)
1748  04da 2401          	jrnc	L05
1749  04dc 5c            	incw	x
1750  04dd               L05:
1751  04dd 02            	rlwa	x,a
1752  04de 78            	sll	(x)
1753                     ; 281         for(j = 0; j < 8; j++)
1755  04df 0c01          	inc	(OFST-21,sp)
1759  04e1 7b01          	ld	a,(OFST-21,sp)
1760  04e3 a108          	cp	a,#8
1761  04e5 25b4          	jrult	L165
1762                     ; 279     for(i = 0; i < ACTIVE_NUM+3; i++)
1764  04e7 0c16          	inc	(OFST+0,sp)
1766  04e9               L555:
1769  04e9 9c            	rvf
1770  04ea b615          	ld	a,_Set_Buff+15
1771  04ec 5f            	clrw	x
1772  04ed 97            	ld	xl,a
1773  04ee 1c0003        	addw	x,#3
1774  04f1 7b16          	ld	a,(OFST+0,sp)
1775  04f3 905f          	clrw	y
1776  04f5 9097          	ld	yl,a
1777  04f7 90bf00        	ldw	c_y,y
1778  04fa b300          	cpw	x,c_y
1779  04fc 2c9b          	jrsgt	L155
1780                     ; 296     enableInterrupts();        		
1783  04fe 9a            rim
1785                     ; 297 }
1786  04ff               L25:
1790  04ff 5b18          	addw	sp,#24
1791  0501 81            	ret
1852                     	xdef	_Pattern
1853                     	xdef	_CarrierBurst
1854                     	xdef	_Clock_125K
1855                     	xdef	_Out_125K
1856                     	xdef	_fac_us
1857                     	xdef	_LF_SendData
1858                     	xdef	_Timecalculate
1859                     	xdef	_LF_PLL_SET
1860                     	xdef	_LF_ClockOccurs
1861                     	xdef	_Delay_us
1862                     	xdef	_Delay_InIt
1863                     	switch	.ubsct
1864  0000               _LF_Send_Tim:
1865  0000 0000          	ds.b	2
1866                     	xdef	_LF_Send_Tim
1867  0002               _Carrier_Time:
1868  0002 0000          	ds.b	2
1869                     	xdef	_Carrier_Time
1870  0004               _Bit_element:
1871  0004 0000          	ds.b	2
1872                     	xdef	_Bit_element
1873  0006               _Set_Buff:
1874  0006 000000000000  	ds.b	26
1875                     	xdef	_Set_Buff
1876                     	xref.b	c_lreg
1877                     	xref.b	c_x
1878                     	xref.b	c_y
1898                     	xref	c_ldiv
1899                     	xref	c_rtol
1900                     	xref	c_itol
1901                     	xref	c_idiv
1902                     	xref	c_sdivx
1903                     	end
