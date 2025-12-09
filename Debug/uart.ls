   1                     ; C Compiler for STM8 (COSMIC Software)
   2                     ; Parser V4.13.2 - 04 Jun 2024
   3                     ; Generator (Limited) V4.6.4 - 15 Jan 2025
  46                     ; 22 void Uart_Init(void)
  46                     ; 23 {
  48                     	switch	.text
  49  0000               _Uart_Init:
  53                     ; 24     UART2_DeInit();
  55  0000 cd0000        	call	_UART2_DeInit
  57                     ; 25     UART2_Init((u32)9600, UART2_WORDLENGTH_8D, UART2_STOPBITS_1, \
  57                     ; 26     UART2_PARITY_NO , UART2_SYNCMODE_CLOCK_DISABLE , UART2_MODE_TXRX_ENABLE);
  59  0003 4b0c          	push	#12
  60  0005 4b80          	push	#128
  61  0007 4b00          	push	#0
  62  0009 4b00          	push	#0
  63  000b 4b00          	push	#0
  64  000d ae2580        	ldw	x,#9600
  65  0010 89            	pushw	x
  66  0011 ae0000        	ldw	x,#0
  67  0014 89            	pushw	x
  68  0015 cd0000        	call	_UART2_Init
  70  0018 5b09          	addw	sp,#9
  71                     ; 27     UART2_ITConfig(UART2_IT_RXNE_OR,ENABLE  );
  73  001a 4b01          	push	#1
  74  001c ae0205        	ldw	x,#517
  75  001f cd0000        	call	_UART2_ITConfig
  77  0022 84            	pop	a
  78                     ; 28     UART2_Cmd(ENABLE );
  80  0023 a601          	ld	a,#1
  81  0025 cd0000        	call	_UART2_Cmd
  83                     ; 30 }
  86  0028 81            	ret
 122                     ; 32 void UART2_SendByte(u8 data)
 122                     ; 33 {
 123                     	switch	.text
 124  0029               _UART2_SendByte:
 128                     ; 34     UART2_SendData8((unsigned char)data);
 130  0029 cd0000        	call	_UART2_SendData8
 133  002c               L14:
 134                     ; 36   while (UART2_GetFlagStatus(UART2_FLAG_TXE) == RESET);
 136  002c ae0080        	ldw	x,#128
 137  002f cd0000        	call	_UART2_GetFlagStatus
 139  0032 4d            	tnz	a
 140  0033 27f7          	jreq	L14
 141                     ; 37 }
 144  0035 81            	ret
 198                     ; 39 void UART2_SendString(u8* Data,u16 len)
 198                     ; 40 {
 199                     	switch	.text
 200  0036               _UART2_SendString:
 202  0036 89            	pushw	x
 203  0037 89            	pushw	x
 204       00000002      OFST:	set	2
 207                     ; 41   u16 i=0;
 209  0038 5f            	clrw	x
 210  0039 1f01          	ldw	(OFST-1,sp),x
 213  003b 200f          	jra	L77
 214  003d               L37:
 215                     ; 43     UART2_SendByte(Data[i]);
 217  003d 1e03          	ldw	x,(OFST+1,sp)
 218  003f 72fb01        	addw	x,(OFST-1,sp)
 219  0042 f6            	ld	a,(x)
 220  0043 ade4          	call	_UART2_SendByte
 222                     ; 42   for(;i<len;i++)
 224  0045 1e01          	ldw	x,(OFST-1,sp)
 225  0047 1c0001        	addw	x,#1
 226  004a 1f01          	ldw	(OFST-1,sp),x
 228  004c               L77:
 231  004c 1e01          	ldw	x,(OFST-1,sp)
 232  004e 1307          	cpw	x,(OFST+5,sp)
 233  0050 25eb          	jrult	L37
 234                     ; 45 }
 237  0052 5b04          	addw	sp,#4
 238  0054 81            	ret
 274                     ; 47 u8 UART2_ReceiveByte(void)
 274                     ; 48 {
 275                     	switch	.text
 276  0055               _UART2_ReceiveByte:
 278  0055 88            	push	a
 279       00000001      OFST:	set	1
 282  0056               L321:
 283                     ; 50      while (UART2_GetFlagStatus(UART2_FLAG_RXNE) == RESET);
 285  0056 ae0020        	ldw	x,#32
 286  0059 cd0000        	call	_UART2_GetFlagStatus
 288  005c 4d            	tnz	a
 289  005d 27f7          	jreq	L321
 290                     ; 51      USART2_RX_BUF=UART2_ReceiveData8();
 292  005f cd0000        	call	_UART2_ReceiveData8
 294  0062 6b01          	ld	(OFST+0,sp),a
 296                     ; 52      return  USART2_RX_BUF;
 298  0064 7b01          	ld	a,(OFST+0,sp)
 301  0066 5b01          	addw	sp,#1
 302  0068 81            	ret
 315                     	xdef	_UART2_ReceiveByte
 316                     	xdef	_UART2_SendString
 317                     	xdef	_UART2_SendByte
 318                     	xdef	_Uart_Init
 319                     	xref	_UART2_GetFlagStatus
 320                     	xref	_UART2_SendData8
 321                     	xref	_UART2_ReceiveData8
 322                     	xref	_UART2_ITConfig
 323                     	xref	_UART2_Cmd
 324                     	xref	_UART2_Init
 325                     	xref	_UART2_DeInit
 344                     	end
