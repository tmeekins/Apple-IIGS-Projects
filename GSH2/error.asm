***********************************************************************
* CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL CONFIDENTIAL *
***********************************************************************
                                                                       
**************************************************************************
*                            
* GNO/Shell 2.0
* Error routines for GNO/Shell
*
* Written by Tim Meekins
* Copyright (C) 1993 by Tim Meekins & Procyon Enterprises, Inc.
*
**************************************************************************

	keep	o/error

**************************************************************************
*
* Raise an error exception
*
* entry:
*     ph4 errenv	- error environment
*     ph2 errnum	- error number
*
**************************************************************************

raiseerr	START

space	equ	1
errnum	equ	space+2
errenv	equ	errnum+2
end	equ	errenv+4

	tsc
	phd
	tcd

	lda	<errnum
	sta	[<errenv]

               lda   space
               sta   end-2
               pld
               tsc
               clc
               adc   #end-3
               tcs

               rts

	END

**************************************************************************
*
* Display an error message to standard-error
*
* entry:
*    ph2 app		- application number
*    ph2 errnum      - error number
*
**************************************************************************

shellerror	START

	using	ErrorData

space	equ	1
errnum	equ	space+2
app	equ	errnum+2
end	equ	app+2

	tsc
	phd
	tcd

	ldx	<app
	lda	!AppErrTable,x
	ldx	#^app00
	jsr	errputs

	ldx	<errnum
	lda	!ErrorTable,x
	ldx	#^err00
	jsr	errputs

	lda	#13
	jsr	errputchar
                            
               lda   space
               sta   end-2
               pld
               tsc
               clc
               adc   #end-3
               tcs

               rts

	END

**************************************************************************
*
* Error strings
*
**************************************************************************

ErrorData	PRIVDATA

ErrorTable	dc	a2'err00'
	dc	a2'err01'
	dc	a2'err02'
	dc	a2'err03'
	dc	a2'err04'
	dc	a2'err05'
	dc	a2'err06'
	dc	a2'err07'
	dc	a2'err08'
	dc	a2'err09'
	dc	a2'err10'
	dc	a2'err11'
	dc	a2'err12'
	dc	a2'err13'
	dc	a2'err14'

err00	dc	c'Unknown error.',h'00'
err01	dc	c'Missing ending ".',h'00'
err02	dc	c"Missing ending '.",h'00'
err03	dc	c'Missing ending `.',h'00'
err04	dc	c'No files specified for ">" or ">>".',h'00'
err05	dc	c'Extra "<" encountered.',h'00'
err06	dc	c'No file specified for "<".',h'00'
err07	dc	c'Extra ">" or ">>" encountered.',h'00'
err08	dc	c'Extra ">&" or ">>&" encountered.',h'00'
err09	dc	c'"|" conflicts with ">" or ">>".',h'00'
err10	dc	c'"|" conflicts with "<".',h'00'
err11	dc	c'Bad use of ( ).',h'00'
err12	dc	c'No matching ( .',h'00'
err13	dc	c'"|&" conflicts with ">&".',h'00'
err14	dc	c'Invalid null command.',h'00'

AppErrTable	dc	a2'app00'

app00	dc	c'gsh: ',h'00'

	END
                    
