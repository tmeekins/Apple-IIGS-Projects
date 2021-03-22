***********************************************************************
*
* MKDIRECT.ASM - Version 1.0
* Written by Tim Meekins
* Copyright (C) 1992 by Procyon, Inc.
* This program is hereby donated to the public domain.
*
* This program creates a direct page segment for linking into programs.
*
* HISTORY:
*   1.0  06/24/92 First version.
*
**************************************************************************

	keep	mkdirect
               mcopy mkdirect.mac

; ~GNO_COMMAND is contained in the 'libgno' library and will be linked
; automatically. mkdirect should work with Orca, but GNO is required to
; compile it.

mkdirect	START
	jml	~GNO_COMMAND
	END

; this is where the fun begins.

main	START

arg	equ	0
retval	equ	arg+4
space	equ	retval+2

	subroutine (2:argc,4:argv),space

	WriteCString #title

	stz	retval

	lda	argc
	cmp	#2	;command name plus one argument
	beq	ok

showusage	lda	#usage
	jmp	error

ok	ldy	#4	;deref the 2nd argument
	lda	[argv],y
	sta	arg
	ldy	#6
	lda	[argv],y
	sta	arg+2

	pei	(arg+2)	;put the argument length in x
	pei	(arg)
	jsr	cstrlen
	tax

	lda	[arg]
	and	#$FF
	cmp	#'-'
	beq	showusage	;just in case..
	cmp	#'$'
	beq	dohex
;
; parse the integer stack size
;
	Dec2Int (arg,@x,#0),@x
	bra	chkerr
;
; parse the hex stack size (skip over the '$')
;
dohex	inc	arg
	bne	dohex0
	inc	arg+2
dohex0	dex		;decrement the strlen
	Hex2Int (arg,@x),@x
;
; check for conversion errors
;
chkerr	cmp	#$0B02	;imIllegalChar
	beq	badchar
	cmp	#$0B03	;imOverflow
	beq	badrange
;
; the page size is in x, see if its range is valid  ($100-$8000)
;
               cpx	#$100
	bcc	badrange
	cpx	#$8001
	bcs	badrange
	stx	seg_resspc	;store the direct page size in
	stx	seg_length         ; the OMF header
;
; go create the file!
;	
	Create createparm
	bcc	ok2
	cmp	#$47	;dupPathname
	beq	duperr
	bra	gsoserr
;
; it's created, we can write the file
;
ok2	Open	openparm
	bcs	gsoserr
	mv2	openref,(writeref,closeref)
	Write	writeparm
	bcs	gsoserr
	Close	closeparm
	bcc	done	;by golly, we're done!
;
; some error routines...oh no!
;
gsoserr	lda	#gsosstr
	beq	error
duperr	lda	#dupstr
	bra	error
badrange	lda	#rangestr
	bra	error
badchar	lda	#badcharstr
error	ldx	#^mkdirect
	ErrWriteCString @xa
	dec	retval

done	return 2:retval

title	dc	c'mkdirect v1.0 - (c) 1992 Procyon, Inc.',h'0d0a0d0a00'
usage	dc	c'usage: mkdirect pagesize',h'0d0a00'
badcharstr	dc	c'pagesize must be a numeric value - hex or integer',h'0d0a00'
rangestr	dc	c'pagesize must be from $100 to $8000',h'0d0a00'
gsosstr	dc	c'GS/OS error! could not write direct.root',h'0d0a00'
dupstr	dc	c'direct.root already exists. Please remove and try again'
	dc	h'0d0a00'
;
; some GS/OS parameter blocks, <yawn>!
;
createparm	dc	i2'4'
	dc	a4'directname'
	dc	i2'%11100011'	;drb---wr
	dc	i2'$B1'	;OBJ
	dc	i4'0'

openparm	dc	i2'3'
openref	dc	i2'0'
	dc	i4'directname'
	dc	i2'%10'	;write. ALWAYS specify the access w/ GNO

writeparm	dc	i2'4'
writeref	dc	i2'0'
	dc	i4'seg'
	dc	i4'segend-seg'
	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

directname	gsstr	'direct.root'
;
; this is a template for the object file we're going to create
;
seg	dc	i4'segend-seg'	;BYTECNT
seg_resspc	dc	i4'0'	;RESSPC
seg_length	dc	i4'0'	;LENGTH
	dc	i1'0'	;undefined
	dc	i1'0'	;LABLEN
	dc	i1'4'	;NUMLEN
	dc	i1'2'	;VERSION
	dc	i4'0'	;BANKSIZE
	dc	i2'$12'	;KIND  (Direct-page/stack segment)
	dc	i2'0'	;undefined
	dc	i4'0'	;ORG
	dc	i4'0'	;ALIGN
	dc	i1'0'	;NUMSEX
	dc	i1'0'	;undefined
	dc	i2'1'	;SEGNUM
	dc	i4'0'	;ENTRY
	dc	i2'loadname-seg'	;DISPNAME
	dc	i2'body-seg'	;DISPDATA
	dc	i4'0'	;tempOrg'
loadname	dc	c'~Direct   '	;LOADNAME
	str	'GNOSTACK'	;SEGNAME

body	dc	i1'$00'	;END
segend	anop

	END

*
* Routines borrowed from 'gsh'
*

;=========================================================================
;
; Get the length of a c string.
;
;=========================================================================

cstrlen        START

space          equ   1
p              equ   space+2
end            equ   p+4

               tsc
               phd
               tcd

               short a

               ldy   #0
loop           lda   [p],y
               beq   done
               iny
               bra   loop

done           long  a
               lda   space
               sta   end-2
               pld
               tsc
               clc
               adc   #end-3
               tcs

               tya

               rts

               END
