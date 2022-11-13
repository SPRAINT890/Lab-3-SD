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

AN0_RES		EQU 0x20
AN1_RES		EQU	0x21






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
	
	btfsc	INTCON, T0IF	;pregunto si se levanto el flag del timer0
	call 	calc_analog_res
	movf	pclath_temp,w	  ; retrieve copy of PCLATH register
	movwf	PCLATH		  ; restore pre-isr PCLATH register contents
	movf    status_temp,w     ; retrieve copy of STATUS register
	movwf	STATUS            ; restore pre-isr STATUS register contents
	swapf   w_temp,f
	swapf   w_temp,w          ; restore pre-isr W register contents
	retfie                    ; return from interrupt

calc_analog_res
	call 	calc_val_0		;calculo el valor de an0
	movf 	ADRESH, w		;guardo el resultado en AN0_RES
	movwf 	AN0_RES
	call 	calc_val_1		;calcuki ek valor de an1
	movf 	ADRESH, w		;guardo el resultado en AN1_RES
	movwf 	AN1_RES
	movlw	d'60'			;vuelvo a cargar el timer0
	movwf	TMR0
	bcf		INTCON, T0IF	;limpio la flag de timer0
	return

calc_val_0
	bcf		STATUS, RP1		;cambio al banco 0
	bcf		STATUS, RP0

	bcf		ADCON0, CHS0	;selecciono el pin 0
	bcf		ADCON0, CHS1
	bcf		ADCON0, CHS2
	bsf 	ADCON0, d'2'	;activo el Analog to Digital
	call	check_flag_done	;compruebo la flag
	return

calc_val_1
	bcf		STATUS, RP1		;cambio al banco 0
	bcf		STATUS, RP0

	bsf		ADCON0, CHS0	;selecciono el pin 1
	bcf		ADCON0, CHS1
	bcf		ADCON0, CHS2
	bsf 	ADCON0, d'2'	;activo el Analog to Digital
	call	check_flag_done	;compruebo la flag
	return

check_flag_done
	btfsc	ADCON0, d'2'	;compruebo la flag done
	return					
	goto check_flag_done

main
	call porta_init			;configuro el puerto a
	call portb_init			;configuro el puerto b
	call portc_init			;configuro el puerto c
	call timer0_init		;configuro el timer0
	goto read_select		;selecciono cual valor mostrar

porta_init
	;Config PORTA - start
	bcf		STATUS, RP1		;cambio al banco 1
	bsf		STATUS, RP0
	movlw	b'00000011'		;seteo el pin 0 y 1 como input
	movwf	TRISA
	bcf		ADCON1, PCFG3	;seteo las entradas como analogica
	bcf		ADCON1, PCFG2	;
	bcf		ADCON1, PCFG1	;
	bcf		ADCON1, PCFG0	;
	bcf		ADCON1, ADFM	;Justifica izquierda
	
	bcf		STATUS, RP1		;cambio al banco 0
	bcf		STATUS, RP0
	bsf		ADCON0, ADON	;activo la funcion AD
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

portc_init
	;Config PORTc - start
	bcf		STATUS, RP1		;cambio al banco 1
	bsf		STATUS, RP0
	movlw	b'00000001'		;seteo el pin 0 como input	
	movwf	TRISC
	bcf		STATUS, RP1		;cambio al banco 0
	bcf		STATUS, RP0
	return
	;Config PORTc - end

timer0_init
	bcf 	STATUS, RP1			;cambio al banco 1
	bsf		STATUS,	RP0
	bcf		OPTION_REG, T0CS	;utilizo el clock del microprocesador
	bcf		OPTION_REG, PSA		;utilizo el Prescaler en Timer0
	bcf		OPTION_REG,	PS0		;cargo el prescaler en 256
	bsf		OPTION_REG,	PS1		;
	bsf		OPTION_REG,	PS2		;
	bsf		INTCON, GIE			;activo las interrupciones
	bsf		INTCON, T0IE		;activo la interrupcion por overflow del timer 0
	bcf		STATUS, RP0			;cambio al banco 0
	bcf		STATUS, RP1
	movlw	d'60'				;seteo el timer en 6
	movwf	TMR0
	bcf		INTCON, T0IF		;limpio la flag del timer overflow
	return

read_select
	bcf		STATUS, RP1			;cambio al banco 0
	bcf		STATUS, RP0
	btfss	PORTC, d'0'			;el select es 0
	goto	set_an0				;si
	goto	set_an1				;no

set_an0
	movf 	AN0_RES, w			;muestro en el puerto b el resultado de an0
	movwf	PORTB
	goto	read_select

set_an1							;muestro en el puerto b el resultado de an1	
	movf 	AN1_RES, w
	movwf	PORTB
	goto	read_select






	END                       ; directive 'end of program'

