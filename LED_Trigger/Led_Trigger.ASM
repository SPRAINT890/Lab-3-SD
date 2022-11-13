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

cont_timer	EQU 0x20		;contador Auxiliar		






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

; isr code can go here or be located as a call subroutine elsewhere

	movf	pclath_temp,w	  ; retrieve copy of PCLATH register
	movwf	PCLATH		  ; restore pre-isr PCLATH register contents
	movf    status_temp,w     ; retrieve copy of STATUS register
	movwf	STATUS            ; restore pre-isr STATUS register contents
	swapf   w_temp,f
	swapf   w_temp,w          ; restore pre-isr W register contents
	retfie                    ; return from interrupt



main
	call porta_init			;configuracion de porta
	call timer0_init		;configuracion de timer0
	goto read_porta			;leer valor de entrada porta
	
; remaining code goes here

porta_init
	;Config PORTA - start
	bcf		STATUS, RP1			;cambio al banco 1
	bsf		STATUS, RP0
	movlw	b'00000001'			; set el pin 0 como input
	movwf	TRISA
	movlw	0x06				; seteo todos los pines como digitales
	movwf	ADCON1
	bcf		STATUS, RP1			;cambio al banco 0
	bcf		STATUS, RP0
	return
	;Config PORTA - end

timer0_init
	bcf 	STATUS, RP1			;cambio al banco 1
	bsf		STATUS,	RP0
	bcf		OPTION_REG, T0CS	;utilizo el reloj del procesador
	bcf		OPTION_REG, PSA		;asigno el prescaler al timer0
	bsf		OPTION_REG,	PS0		;configuro el prescaler a 256
	bsf		OPTION_REG,	PS1		;
	bsf		OPTION_REG,	PS2		;
	return

read_porta
	bcf		STATUS, RP0			;cambio al banco 0
	bcf		STATUS, RP1
	bcf		PORTA,d'1'			; Cuando trigger esta en low el led esta apagado
	btfsc	PORTA, d'0'			;tengo entrada en el pin 0 en el puerto a
	goto	led_on				;si
	goto	read_porta			;no


led_on
	bsf		PORTA,d'1'	; Led on
	movlw	d'200'		; Inicio el contador en 200
	movwf	cont_timer
	goto 	loopa_timer
	
loopa_timer
	movlw	d'12'		; Timer inicia en 12 y se limpia la flag
	movwf	TMR0	
	bcf		INTCON, T0IF
	goto	loopb_timer

loopb_timer
	btfss	INTCON, T0IF	; Wait for flag
	goto	loopb_timer		

	decfsz	cont_timer		; decrease counter
	goto 	loopa_timer
	goto	read_porta



	END                       ; directive 'end of program'