***********************************************************************
* CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL CONFIDENTIAL *
***********************************************************************
                                                                       
**************************************************************************
*                            
* GNO/Shell 2.0
* Main entry into GNO/Shell
*
* Written by Tim Meekins
* Copyright (C) 1993 by Tim Meekins & Procyon Enterprises, Inc.
*
**************************************************************************

               keep  o/main
               mcopy m/main.mac

init	START
	jml	~GNO_COMMAND
	END

MAIN	START

	using	global

arg	equ	0
space	equ	arg+4

	subroutine (2:argc,4:argv),space

	kernStatus @a
	bcc	ok

	ErrWriteCString #str
	jmp	done

ok	stz	FastFlag

argloop	dec	argc
	jeq	start
	add2	argv,#4,argv
	beq	start
	ldy	#2
	lda	[argv]
	sta	arg
	lda	[argv],y
	sta	arg+2
	lda	[arg]
	and	#$FF
	cmp	#'-'
	beq	intoption

showusage	ErrWriteCString #usage
	bra	done

intoption	ldy	#1
optloop	lda	[arg],y
	and	#$FF
	beq	nextarg
	cmp	#'f'
	beq	optf
	cmp	#'c'
	bne	showusage
	bra	parsec

optf	lda	#1
	sta	FastFlag

nextopt	iny
	bra	optloop

nextarg	cpy	#1
	beq	showusage
	jmp	argloop

parsec	add4	argv,#4,argv
	dec	argc
	beq	showusage
	lda	#1
	sta	CmdFlag
	sta	FastFlag
	mv4	argv,CmdArgV
	mv2	argc,CmdArgC

start	case	on
	jsl	shell
	case	off

done	return

str	dc	h'0d0a0a'
 dc c'Before gsh may be run, the GNO/ME system, or kernel, must be running.'
	dc	h'0d0a0a00'

usage	dc	c'Usage: gsh [-cf] [argument...]',h'0d0a00'

	END
