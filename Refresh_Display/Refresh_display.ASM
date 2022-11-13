;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F877A. This file contains the basic code              *
;   building blocks to build upon.                                    *  
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    xxx.asm                                           *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files Required: P16F877A.INC                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************


	list		p=16f877A	; list directive to define processor
	#include	<p16f877A.inc>	; processor specific variable definitions
	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.






;***** VARIABLE DEFINITIONS
w_temp		EQU	0x7D		; variable used for context saving 
status_temp	EQU	0x7E		; variable used for context saving
pclath_temp	EQU	0x7F		; variable used for context saving			

DIG0 			EQU 0x23
DIG1 			EQU 0x22
DIG2 			EQU 0x21
DIG3 			EQU 0x20 
add_reg_dig		EQU 0x24
select_output	EQU	0x25

;caracteres Validos
char_A EQU 0x26
char_B EQU 0x27
char_C EQU 0x28
char_D EQU 0x29
char_E EQU 0x2A
char_F EQU 0x2B
char_G EQU 0x2C
char_H EQU 0x2D
char_I EQU 0x2E
char_J EQU 0x2F
char_L EQU 0x30
char_N EQU 0x31
char_Ñ EQU 0x32
char_O EQU 0x33
char_P EQU 0x34
char_R EQU 0x35
char_S EQU 0x36
char_T EQU 0x37
char_U EQU 0x38
char_Y EQU 0x39
char_1 EQU 0x3A
char_2 EQU 0x3B
char_3 EQU 0x3C
char_4 EQU 0x3D
char_5 EQU 0x3E
char_6 EQU 0x3F
char_7 EQU 0x40
char_8 EQU 0x41
char_9 EQU 0x42
char_0 EQU 0x43
;caracteres invalidos
char_K EQU 0x44
char_M EQU 0x45
char_Q EQU 0x46
char_V EQU 0x47
char_W EQU 0x48
char_X EQU 0x49
char_Z EQU 0x4A




;**********************************************************************
	ORG     0x000             ; processor reset vector

	nop			  ; nop required for icd
  	goto    main              ; go to beginning of program


	ORG     0x004             ; interrupt vector location

	movwf   w_temp            ; save off current W register contents
	movf	STATUS,w          ; move status register into W register
	movwf	status_temp       ; save off contents of STATUS register
	movf	PCLATH,w	  ; move pclath register into w register
	movwf	pclath_temp	  ; save off contents of PCLATH register

	bcf		STATUS, RP1			;cambio al banco 0
	bcf		STATUS, RP0
	btfsc	INTCON, T0IF		;pregunto si se interrumpio por el overflow del timer
	call 	show_in_display
	movf	pclath_temp,w	  ; retrieve copy of PCLATH register
	movwf	PCLATH		  	; restore pre-isr PCLATH register contents
	movf    status_temp,w     ; retrieve copy of STATUS register
	movwf	STATUS            ; restore pre-isr STATUS register contents
	swapf   w_temp,f
	swapf   w_temp,w          ; restore pre-isr W register contents
	retfie                    ; return from interrupt

show_in_display
	btfsc	select_output, d'3'	;el select esta en el pin 3 del puerto a
	call	load_digit3			;si
	btfsc	select_output, d'2'	;el select esta en el pin 2 del puerto a
	call	load_digit2			;si
	btfsc	select_output, d'1' ;el select esta en el pin 1 del puerto a
	call	load_digit1			;si
	btfsc	select_output, d'0' ;el select esta en el pin 0 del puerto a
	call	load_digit0			;si
	bcf		STATUS, C			
	rrf		select_output		;cambio el select al siguiente puerto
	btfsc	STATUS, C			;si el select esta vacio, le cargo el valor al puerto 4
	call	reset_count
	movlw	d'60'
	movwf	TMR0				;vuelvo a configurar el timer0
	bcf		INTCON, T0IF		;limpio la flag del timer0
	return

load_digit3
	bcf		STATUS, IRP			;limpio el irp
	movf	add_reg_dig, w		;cargo la primera direccion del char en el fsr
	movwf	FSR
	movf	select_output, w	;paso el pin de salida del puerto a
	movwf	PORTA
	movf	INDF, w				;paso el digito por el puerto b
	movwf	PORTB
	return

load_digit2
	incf 	FSR, f				;aumento el fsr
	movf	select_output, w	;paso el pin de salida del puerto a
	movwf	PORTA
	movf	INDF, w				;paso el digito por el puerto b
	movwf	PORTB
	return

load_digit1
	incf 	FSR, f				;aumento el fsr
	movf	select_output, w	;paso el pin de salida del puerto a
	movwf	PORTA
	movf	INDF, w				;paso el digito por el puerto b
	movwf	PORTB
	return

load_digit0
	incf 	FSR, f				;aumento el fsr
	movf	select_output, w	;paso el pin de salida del puerto a
	movwf	PORTA
	movf	INDF, w				;paso el digito por el puerto b
	movwf	PORTB
	return

reset_count
	movlw	b'00001000'			;reseteo el select
	movwf	select_output
	return

	


main
	call porta_init		;configuro el puerto a
	call portb_init		;configuro el puerto b
	call table_set		;configuro las variables de los chars
	call digit_set		;configuro los digitos que se van a usar
	call timer0_init	;configuro el timer0
	goto loop
; remaining code goes here

porta_init
	;Config PORTA - start
	bcf		STATUS, RP1			;cambio al banco 1
	bsf		STATUS, RP0
	movlw	b'00000000'			;seteo el puerto a como salida	
	movwf	TRISA
	movlw	0x06				;seteo las entradas/salidas como digitales
	movwf	ADCON1
	bcf		STATUS, RP1			;cambio al banco 0
	bcf		STATUS, RP0
	return
	;Config PORTA - end

portb_init
	;Config PORTB - start
	bcf		STATUS, RP1		;cambio al banco 1
	bsf		STATUS, RP0		
	movlw	b'00000000'		;seteo el puerto b como salida		
	movwf	TRISB
	bcf		STATUS, RP1		;cambio al banco 0
	bcf		STATUS, RP0
	return
	;Config PORTB - end

digit_set
	movf	char_H,w	;cargo los chars que quiero mostrar
	movwf	DIG3
	movf	char_O,w
	movwf	DIG2
	movf	char_L,w
	movwf	DIG1
	movf	char_A,w
	movwf	DIG0
	movlw	0x20
	movwf	add_reg_dig		;primera direccion de Dig
	movlw	b'00001000'		;seteo el select para que empieze en el pin 3
	movwf	select_output
	return

timer0_init
	bcf 	STATUS, RP1			;cambio al banco 0
	bsf		STATUS,	RP0
	bcf		OPTION_REG, T0CS	;utilizo el clock del microprocesador
	bcf		OPTION_REG, PSA		;utilizo el Prescaler en Timer0
	bcf		OPTION_REG,	PS0		;cargo el prescaler en 128
	bsf		OPTION_REG,	PS1		;
	bsf		OPTION_REG,	PS2		;
	bsf		INTCON, GIE			;activo las interrupciones generales
	bsf		INTCON, T0IE		;activo la interrupcion por overflow del timer 0
	bcf		STATUS, RP0			;cambio al banco 0
	bcf		STATUS, RP1
	movlw	d'60'				;seteo el timer en 60
	movwf	TMR0
	bcf		INTCON, T0IF		;limpio la flag del timer overflow
	return

table_set
	;caracteres validos
	movlw b'01110111'
	movwf char_A	
	movlw b'01111100'
	movwf char_B	
	movlw b'01011000'
	movwf char_C	
	movlw b'01011110'
	movwf char_D
	movlw b'01111001'
	movwf char_E
	movlw b'01110001'
	movwf char_F
	movlw b'01111101'
	movwf char_G	
	movlw b'01110110'
	movwf char_H	
	movlw b'00000110'
	movwf char_I
	movlw b'00011110'
	movwf char_J
	movlw b'00111000'
	movwf char_L
	movlw b'01010100'
	movwf char_N
	movlw b'01010101'
	movwf char_Ñ
	movlw b'01011100'
	movwf char_O
	movlw b'01110011'
	movwf char_P
	movlw b'01010000'
	movwf char_R
	movlw b'01101101'
	movwf char_S
	movlw b'01111000'
	movwf char_T
	movlw b'00011100'
	movwf char_U
	movlw b'01101110'
	movwf char_Y
	movlw b'00000110'
	movwf char_1
	movlw b'01011011'
	movwf char_2
	movlw b'01001111'
	movwf char_3
	movlw b'01100110'
	movwf char_4
	movlw b'01101101'
	movwf char_5
	movlw b'01111101'
	movwf char_6
	movlw b'00000111'
	movwf char_7
	movlw b'01111111'
	movwf char_8
	movlw b'01100111'
	movwf char_9
	movlw b'00111111'
	movwf char_0
	;caracteres invalidos
	movlw b'01001111'
	movwf char_K
	movlw b'01001111'
	movwf char_M
	movlw b'01001111'
	movwf char_Q
	movlw b'01001111'
	movwf char_V
	movlw b'01001111'
	movwf char_W
	movlw b'01001111'
	movwf char_X
	movlw b'01001111'
	movwf char_Z
	return

loop
	goto loop







	END                       ; directive 'end of program'

