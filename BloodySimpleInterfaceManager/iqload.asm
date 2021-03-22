**************************************************************************
*
* ImageQuant
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* iqload.asm
*
* ImageQuant picture loading routines
*
**************************************************************************

	mcopy	m/iqload.mac

;-------------------------------------------------------------------------
; LoadImage
;    Load a Image from the disk
;-------------------------------------------------------------------------

LoadImage	START

	using	Globals
	using	EventData

hand	equ	1
space	equ	hand+2

	subroutine (4:filename),space

	WaitCursor

	lda	<filename
	sta	!openpath
	lda	<filename+2
	sta	!openpath+2

	Open	openparm
	jcs	openerr

	lda	!openeof+2
	pha
	lda	!openeof	
	pha
	jsl	TVMM_alloc
	sta	<hand

	lda	!openref
	sta	!readref
	sta	!closeref

	lda	!openeof
	sta	!readreq
	lda	!openeof+2
	sta	!readreq+2

	pei	(<hand)
	jsl	TVMM_acquire

	sta	!readbuf
	stx	!readbuf+2

	phx
	pha

	Read	readparm
	bcs	readerr

	Close closeparm

	lda	!loadtype
	asl	a
	tax
	jmp	(loadtable,x)

fini	pei	(<hand)
	jsl	TVMM_free

done	InitCursor

	jsr	fixmenu

	jsl	updatestats

	return

openerr	Int2Hex (@a,#errstr1a,#4,#0)
	ph4	#errstr1
	jsl	IQError
	bra	done

readerr	Int2Hex (@a,#errstr2a,#4,#0)
	pla
	pla
	ph4	#errstr2
	jsl	IQError
	pei	(<hand)
	jsl	TVMM_free
	bra	done

_LoadRaw24w	jsl	LoadRaw24w
	UnloadSeg _LoadRaw24w+1,(@a,@a,@a)
	jmp	fini

_LoadGIF	jsl	LoadGIF
	UnloadSeg _LoadGIF+1,(@a,@a,@a)
	jmp	fini

_LoadPPM	jsl	LoadPPM
	UnloadSeg _LoadPPM+1,(@a,@a,@a)
	jmp	fini

_LoadAST	jsl	LoadAST
	UnloadSeg _LoadAST+1,(@a,@a,@a)
	jmp	fini

_LoadJPEG	jsl	LoadJPEG
	UnloadSeg _LoadJPEG+1,(@a,@a,@a)
	jmp	fini

_LoadILBM	jsl	LoadILBM
	UnloadSeg _LoadILBM+1,(@a,@a,@a)
	jmp	fini

_LoadBMP	jsl	LoadBMP
	UnloadSeg _LoadBMP+1,(@a,@a,@a)
	jmp	fini

loadtable	dc	i2'_LoadRaw24w'	;Raw 24 (word)
	dc	i2'_LoadGIF'	;GIF
	dc	i2'_LoadPPM'	;PPM
	dc	i2'_LoadAST'	;AST/Visionary
	dc	i2'_LoadJPEG'	;JPEG
	dc	i2'_LoadILBM'	;IFF/ILBM
	dc	i2'_LoadBMP'	;Windows BMP
                        
openparm	dc	i2'12'
openref	dc	i2'0'
openpath	dc	i4'0'
	dc	i2'1'
	dc	i2'0'
	dc	i2'0'
	dc	i2'0'
	dc	i4'0'
	dc	i2'0'
	ds	8
	ds	8
	dc	i4'0'
LoadSize	ENTRY
openeof	dc	i4'0'

readparm	dc	i2'4'
readref	dc	i2'0'
readbuf	dc	i4'0'
readreq	dc	i4'0'
	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

errstr1	dc	c'GS/OS Error #'
errstr1a	dc	c'0000 opening file',h'00'
errstr2	dc	c'GS/OS Error #'
errstr2a	dc	c'0000 reading file',h'00'
                              
	END

;-------------------------------------------------------------------------
; LoadPPM
;    Load a PPM file
;-------------------------------------------------------------------------

LoadPPM	START	IQPPM

;	kind	$8000

	using	Globals

row	equ	1
rowsleft	equ	row+4
imageptr	equ	rowsleft+2
maxval	equ	imageptr+4
val	equ	maxval+2
ppmtype	equ	val+2
space	equ	ppmtype+2
	
	subroutine (4:ptr),space
;
; Let's see if it's a ppm first...
;
	lda	[<ptr]
	and	#$FF
	cmp	#'P'
	bne	ack
	ldy	#1
	lda	[<ptr],y
	and	#$FF
	cmp	#'2'
	jeq	type2
	cmp	#'3'
	jeq	type3
	cmp	#'5'
	jeq	type5
	cmp	#'6'
	beq	good

ack	ph4	#errstr
	jsl	IQError
	jmp	done

good	sta	<ppmtype

	jsl	DisposeImage

	clc
	lda	<ptr
	adc	#2
	sta	<ptr
	lda	<ptr+2
	adc	#0
	sta	<ptr+2

	jsr	eatspace
	jsr	getnum
	sta	>ImageWidth

	jsr	eatspace
	jsr	getnum
	sta	>ImageHeight

	jsr	eatspace
	jsr	getnum
	sta	<maxval
	cmp	#255
	jne	scaled

	inc	<ptr
	bne	inc2
	inc	<ptr+2
inc2	anop

	ph4	#LoadStr
	lda	>ImageHeight
	pha
	jsl	OpenThermo

	jsl	AllocateImage

	lda	>ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<imageptr
	stx	<imageptr+2

	lda	>ImageHeight
	sta	<rowsleft

yloop	lda	[<imageptr]
	pha
	pha
	jsl	TVMM_acquire
	sta	<row
	stx	<row+2

	lda	>ImageWidth
	tax
	ldy	#0
xloop	lda	[<ptr],y
	sta	[<row],y
	iny
	lda	[<ptr],y
	sta	[<row],y
	iny
	iny
	dex
	bne	xloop

	clc
	tya
	adc	<ptr
	sta	<ptr
	lda	<ptr+2
	adc	#0
	sta	<ptr+2

	jsl	AdvanceThermo

	jsl	TVMM_release	; release the row memory

	clc
	lda	<imageptr
	adc	#2
	sta	<imageptr

	dec	<rowsleft
	bne	yloop

	jsl	CloseThermo

	jsl	TVMM_release	; release the image handle

done	return

eatspace	lda	[<ptr]
	and	#$FF
	cmp	#' '+1
	bcs	spaced
	inc	<ptr
	bne	eatspace
	inc	<ptr+2
	bra	eatspace
spaced	rts

getnum	ldy	#0
numlup	lda	[<ptr],y
	and	#$FF
	cmp	#'0'
	bcc	endnum
	cmp	#'9'+1
	bcs	endnum
	iny
	bra	numlup
endnum	phy
	Dec2Int (ptr,@y,#0),val
	pla
	clc
	adc	<ptr
	sta	<ptr
	lda	#0
	adc	<ptr+2
	sta	<ptr+2
	lda	<val
	rts

type2	ph4	#err2str
	jsl	IQError
	jmp	done

type3	ph4	#err3str
	jsl	IQError
	jmp	done

type5	ph4	#err5str
	jsl	IQError
	jmp	done

scaled	ph4	#scalestr
	jsl	IQError
	jmp	done

LoadStr	dc	c'Loading PPM/PGM Image...',h'00'

errstr	dc	c'The picture is not a PPM or PGM file',h'00'
err2str	dc	c'Text formatted PGM - send file to author',h'00'
err3str	dc	c'Text formatted PPM - send file to author',h'00'
err5str	dc	c'Raw formatted PGM - send file to author',h'00'
scalestr	dc	c'Scaled Data Error - send file to author',h'00'

	END

;-------------------------------------------------------------------------
; LoadAST
;    Load an AST/Visionary file
;-------------------------------------------------------------------------

LoadAST	START	IQAST

;	kind	$8000

	using	Globals

lineptr	equ	1
height	equ	lineptr+4
image	equ	height+2
space	equ	image+4

	subroutine (4:ptr),space

	jsl	DisposeImage

	lda	#320
	sta	>ImageWidth
	lda	#200
	sta	>ImageHeight
	
	ph4	#LoadStr
	pea	200*3
	jsl	OpenThermo

	jsl	AllocateImage

	lda	>ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

	lda	>ImageHeight
	sta	<height

yloop	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2

	lda	>ImageWidth
	tax
xloop	short	a
	lda	[<ptr]
	and	#$F0
	sta	[<lineptr]
	rep	#$21
	longa	on
	lda	<lineptr
	adc	#3
	sta	<lineptr
	short	a
	lda	[<ptr]
	and	#$0F	
	asl	a
	asl	a
	asl	a
	asl	a
	sta	[<lineptr]
	rep	#$21
	longa	on
	lda	<lineptr
	adc	#3
	sta	<lineptr
	lda	<ptr
	adc	#1
	sta	<ptr
	lda	<ptr+2
	adc	#0
	sta	<ptr+2
	dex
	dex
	bne	xloop
	jsl	TVMM_release
	jsl	AdvanceThermo
	inc	<image
	inc	<image
	dec	<height
	bne	yloop

	jsl	TVMM_release
	
	lda	>ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

	lda	>ImageHeight
	sta	<height

yloop2	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	inc	a
	sta	<lineptr
	stx	<lineptr+2
	
	lda	>ImageWidth
	tax
xloop2	short	a
	lda	[<ptr]
	and	#$F0
	sta	[<lineptr]
	rep	#$21
	longa on
	lda	<lineptr
	adc	#3
	sta	<lineptr
	short	a
	lda	[<ptr]
	and	#$0F	
	asl	a
	asl	a
	asl	a
	asl	a
	sta	[<lineptr]
	rep	#$21
	longa	on
	lda	<lineptr
	adc	#3
	sta	<lineptr
	lda	<ptr
	adc	#1
	sta	<ptr
	lda	<ptr+2
	adc	#0
	sta	<ptr+2
	dex
	dex
	bne	xloop2
	jsl	TVMM_release
	jsl	AdvanceThermo
	inc	<image       
	inc	<image
	dec	<height
	bne	yloop2

	jsl	TVMM_release

	lda	>ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2
	
	lda	>ImageHeight
	sta	<height

yloop3	lda	[<image]	
	pha
	pha
	jsl	TVMM_acquire
	inc	a
	inc	a
	sta	<lineptr
	stx	<lineptr+2

	lda	>ImageWidth
	tax
xloop3	short	a
	lda	[<ptr]
	and	#$F0
	sta	[<lineptr]
	rep	#$21
	longa	on
	lda	<lineptr
	adc	#3
	sta	<lineptr
	short	a
	lda	[<ptr]
	and	#$0F	
	asl	a
	asl	a
	asl	a
	asl	a
	sta	[<lineptr]
	rep	#$21
	longa	on
	lda	<lineptr
	adc	#3
	sta	<lineptr
	lda	<ptr
	adc	#1
	sta	<ptr
	lda	<ptr+2
	adc	#0	
	sta	<ptr+2
	dex
	dex
	bne	xloop3
	jsl	TVMM_release
	jsl	AdvanceThermo
	inc	<image       
	inc	<image
	dec	<height
	bne	yloop3

	jsl	TVMM_release
	jsl	CloseThermo

	return

LoadStr	dc	c'Loading AST Image...',h'00'
	
	END

;-------------------------------------------------------------------------
; LoadRaw24w
;    Load a Raw 24 bit image with picture size stored as words
;-------------------------------------------------------------------------

LoadRaw24w	START	IQRaw24w

;	kind	$8000

	using	Globals

lineptr	equ	1
height	equ	lineptr+4
image	equ	height+2
space	equ	image+4

	subroutine (4:ptr),space

;
; let's check for some reasonable values for the image size to
; see if this is a properly formatted file.
;
	lda	[<ptr]
	beq	badsize
	cmp	#1281
	bcs	badsize
	ldy	#2
	lda	[<ptr],y
	beq	badsize
	cmp	#1025
	bcc	goodsize

badsize	ph4	#errmsg
	jsl	IQError
	jmp	done

goodsize	jsl	DisposeImage

	lda	[<ptr]
	sta	>ImageWidth
	ldy	#2
	lda	[<ptr],y
	sta	>ImageHeight
	
	ph4	#LoadStr
	pha
	jsl	OpenThermo

	jsl	AllocateImage

	clc
	lda	<ptr
	adc	#4
	sta	<ptr
	lda	<ptr+2
	adc	#0
	sta	<ptr+2

	lda	>ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

	lda	>ImageHeight
	sta	<height

yloop	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2

	clc
	lda	>ImageWidth
	tax
xloop	lda	[<ptr]
	sta	[<lineptr]
	ldy	#1
	lda	[<ptr],y
	sta	[<lineptr],y
	lda	<ptr
	adc	#3
	sta	<ptr
	lda	<ptr+2
	adc	#0
	sta	<ptr+2
	lda	<lineptr
	adc	#3
	sta	<lineptr
	dex
	bne	xloop
	inc	<image
	inc	<image
	jsl	TVMM_release
	jsl	AdvanceThermo
	dec	<height
	bne	yloop

	jsl	TVMM_release
	jsl	CloseThermo

done	return

errmsg	dc	c'The picture dimensions are not legal',h'00'
LoadStr	dc	c'Loading Raw (word) image...',h'00'

	END
