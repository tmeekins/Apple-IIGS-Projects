***********************************************************************
*
* MKMAC.ASM - Version 1.0
* Written by Tim Meekins
* Copyright (C) 1992 by Procyon, Inc.
* This program is hereby donated to the public domain.
*
* This program creates macro files for Orca/M assembly programs.
*
* HISTORY:
*   1.0  06/25/92 First version.
*
**************************************************************************

	keep	mkmac
               mcopy mkmac.mac

; ~GNO_COMMAND is contained in the 'libgno' library and will be linked
; automatically. mkdirect should work with Orca, but GNO is required to
; compile it.

mkmac	START
	jml	~GNO_COMMAND
	END

; this is where the fun begins.

main	START

arg	equ	0
retval	equ	arg+4
space	equ	retval+2

	subroutine (2:argc,4:argv),space

	WriteCString #title

optloop	add4	argv,#4,argv
               dec	argc
	bne	opt

showusage	ErrWriteCString #usage
	ld2	1,retval
	jmp	done

opt	lda	[argv]
	sta	arg
	ldy	#2
	lda	[argv],y
	sta	arg+2
	lda	[arg]
	and	#$FF
	cmp	#'-'
	bne	parsein

	jmp	optloop

parsein	lda	[argv]
	sta	infile
	ldy	#2
	lda	[argv],y
	sta	infile+2
                            

	jsl	buildophash
	ph4	infile
	jsl	readsource


done	return 2:retval

infile	ds	4

title	dc	c'mkmac v1.0d01 - (c) 1992 Procyon, Inc.',h'0d0a0d0a00'
usage	dc	c'usage: mkmac [-flags] infile outfile [macfile ...]',h'0d0a00'

	END
