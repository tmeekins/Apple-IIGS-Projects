**************************************************************************
*
* ImageQuant image loading support routines
*
**************************************************************************

	mcopy	load.mac
	copy	iq.h

**************************************************************************
*
* decode a Raw 24 bit image with picture size stored as words.
*
**************************************************************************

LoadRaw24w	START

	using	Globals

	mv4	LoadPtr,0
;
; let's check for some reasonable values for the image size to
; see if this is a properly formatted file.
;
	lda	[0]
	beq	badsize
	cmp	#1281
	bcs	badsize
	ldy	#2
	lda	[0],y
	beq	badsize
	cmp	#1025
	bcc	goodsize
badsize	InitCursor
	AlertWindow (#0,#0,#loadmsg),@a
	rts

goodsize	jsr	DisposeImage
	mv4	LoadPtr,0

	lda	[0]
	sta	ImageWidth
	ldy	#2
	lda	[0],y
	sta	ImageHeight
	jsr	AllocateImage

	add4	LoadPtr,#4,0
	mv4	ImagePtr,4
	mv2	ImageHeight,8

yloop	ldy	#2
	lda	[4]
	sta	10
	lda	[4],y
	sta	10+2
	ldx	ImageWidth
xloop	lda	[0]
	sta	[10]
	ldy	#1
	lda	[0],y
	sta	[10],y
	add4	0,#3,0
	add4	10,#3,10
	dex
	bne	xloop
	add4	4,#4,4
	dec	8
	bne	yloop

	rts

loadmsg	dc	c'23/The picture dimensions are not legal/OK',h'00'

	END

**************************************************************************
*
* decode a Raw 24 bit image with picture size stored as longs.
*
**************************************************************************

LoadRaw24L	START

	using	Globals

	mv4	LoadPtr,0
;
; let's check for some reasonable values for the image size to
; see if this is a properly formatted file.
;
	ldy	#2
	lda	[0],y
	beq	badsize
	xba
	cmp	#1281
	bcs	badsize
	ldy	#0
	lda	[0],y
	bne	badsize
	ldy	#6
	lda	[0],y
	beq	badsize
	xba
	cmp	#1025
	bcs	badsize
               ldy	#4
	lda	[0],y
	beq	goodsize
badsize	InitCursor
	AlertWindow (#0,#0,#loadmsg),@a
	rts

goodsize	jsr	DisposeImage
	mv4	LoadPtr,0

	ldy	#2
	lda	[0],y
	xba
	sta	ImageWidth
	ldy	#6
	lda	[0],y
	xba
	dec	a	;I don't trust it :)
	sta	ImageHeight
	jsr	AllocateImage

	add4	LoadPtr,#8,0
	mv4	ImagePtr,4
	mv2	ImageHeight,8

yloop	ldy	#2
	lda	[4]
	sta	10
	lda	[4],y
	sta	10+2
	ldx	ImageWidth
xloop	lda	[0]
	sta	[10]
	ldy	#1
	lda	[0],y
	sta	[10],y
	add4	0,#3,0
	add4	10,#3,10
	dex
	bne	xloop
	add4	4,#4,4
	dec	8
	bne	yloop

	rts

loadmsg	dc	c'23/The picture dimensions are not legal/OK',h'00'

	END

**************************************************************************
*
* decode a PPM file.
*
**************************************************************************

LoadPPM	START

	using	Globals

	jsr	DisposeImage

	mv4	LoadPtr,0
;
; Let's see if it's a ppm first...
;
	lda	[0]
	and	#$FF
	cmp	#'P'
	bne	ack
	ldy	#1
	lda	[0],y
	and	#$FF
	cmp	#'3'
	beq	good
	cmp	#'6'
	beq	good

ack	InitCursor
	AlertWindow (#0,#0,#loadmsg),@a
	rts

good	anop

	sta	ppmtype
	add4	0,#2,0

	jsr	eatspace
	jsr	getnum
	sta	ImageWidth
	jsr	eatspace
	jsr	getnum
	sta	ImageHeight
	jsr	eatspace
	jsr	getnum
	sta	maxval
	add4	0,#1,0

	ph4	#LoadStr
	ph2	ImageHeight
	jsl	OpenThermo

	jsr	AllocateImage

	mv4	ImagePtr,4
	mv2	ImageHeight,8
	stz	therm

yloop	ldy	#2
	lda	[4]
	sta	10
	lda	[4],y
	sta	10+2
	ldx	ImageWidth
	ldy	#0
xloop	lda	[0],y
	sta	[10],y
	iny
	lda	[0],y
	sta	[10],y
	iny
	iny
	dex
	bne	xloop
	clc
	tya
	adc	0
	sta	0
	lda	2
	adc	#0
	sta	2
	inc	therm
	lda	therm
	jsl	UpdateThermo
	add4	4,#4,4
	dec	8
	bne	yloop

	jsl	CloseThermo

	rts

eatspace	lda	[0]
	and	#$FF
	cmp	#' '+1
	bcs	spaced
               add4	0,#1,0
	bra	eatspace
spaced	rts

getnum	ldy	#0
numlup	lda	[0],y
	and	#$FF
	cmp	#'0'
	bcc	endnum
	cmp	#'9'+1
	bcs	endnum
	iny
	bra	numlup
endnum	phy
	Dec2Int (0,@y,#0),val
	pla
	clc
	adc	0
	sta	0
	lda	#0
	adc	0+2
	sta	0+2
	lda	val
	rts

maxval	ds	2
val	ds	2
ppmtype	ds	2
loadmsg	dc	c'23/The picture is not a PPM/OK',h'00'
LoadStr	dc	c'Loading PPM Image...',h'00'
therm	ds	2

	END

**************************************************************************
*
* decode an AST picture
*
**************************************************************************

LoadAST	START

	using	Globals

	jsr	DisposeImage
	lda	#320
	sta	ImageWidth
	lda	#200
	sta	ImageHeight
	jsr	AllocateImage

	mv4	LoadPtr,0

	mv4	ImagePtr,4
	mv2	ImageHeight,8

yloop	ldy	#2
	lda	[4]
	sta	10
	lda	[4],y
	sta	10+2
	ldx	ImageWidth
xloop	short	a
	lda	[0]
	and	#$F0
	sta	[10]
	long	a
	add4	10,#3,10
	short	a
	lda	[0]
	and	#$0F	
	asl	a
	asl	a
	asl	a
	asl	a
	sta	[10]
	long	a
	add4	10,#3,10
	add4	0,#1,0
	dex
	dex
	bne	xloop
	add4	4,#4,4
	dec	8
	bne	yloop

	mv4	ImagePtr,4
	mv2	ImageHeight,8

yloop2	ldy	#2
	lda	[4]
	inc	a
	sta	10
	lda	[4],y
	sta	10+2
	ldx	ImageWidth
xloop2	short	a
	lda	[0]
	and	#$F0
	sta	[10]
	long	a
	add4	10,#3,10
	short	a
	lda	[0]
	and	#$0F	
	asl	a
	asl	a
	asl	a
	asl	a
	sta	[10]
	long	a
	add4	10,#3,10
	add4	0,#1,0
	dex
	dex
	bne	xloop2
	add4	4,#4,4
	dec	8
	bne	yloop2

	mv4	ImagePtr,4
	mv2	ImageHeight,8

yloop3	ldy	#2
	lda	[4]
	inc	a
	inc	a
	sta	10
	lda	[4],y
	sta	10+2
	ldx	ImageWidth
xloop3	short	a
	lda	[0]
	and	#$F0
	sta	[10]
	long	a
	add4	10,#3,10
	short	a
	lda	[0]
	and	#$0F	
	asl	a
	asl	a
	asl	a
	asl	a
	sta	[10]
	long	a
	add4	10,#3,10
	add4	0,#1,0
	dex
	dex
	bne	xloop3
	add4	4,#4,4
	dec	8
	bne	yloop3

	rts

	END

**************************************************************************
*
* Dispose the current 24 bit image data
*
**************************************************************************

DisposeImage	START

	using	Globals

	lda	Loaded
	bne	disp1
	rts

disp1	pei	(4)
	mv4	ImagePtr,8
	mv2	ImageHeight,4
disp2	ldy	#2
	lda	[8],y
	tax
	lda	[8]
	FindHandle @xa,@ax
	DisposeHandle @xa
	add4	8,#4,8
	dec	4
	bne	disp2
	FindHandle ImagePtr,@ax
	DisposeHandle @xa
                  
	stz	Loaded

	pla
	sta	4
	rts

	END

**************************************************************************
*
* Allocate data for a 24 bit image
*
**************************************************************************

AllocateImage	START

	using	Globals

	lda	ImageHeight
	asl	a
	asl	a
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),@ax
               bcs	allocerr
	sta	10
	stx	10+2
	ldy	#2
	lda	[10],y
	tax
	lda	[10]
	sta	10
	stx	10+2
	sta	ImagePtr
	stx	ImagePtr+2

	mv2	ImageHeight,4
alloc1	clc
	lda	ImageWidth
	adc	ImageWidth
	adc	ImageWidth
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),@ax
               bcc	alloc2
allocerr	InitCursor
	AlertWindow (#0,#0,#memmsg),@a
	jmp	DisposeImage
alloc2	sta	6
	stx	6+2
	ldy	#2
	lda	[6],y
	sta	[10],y
	lda	[6]
	sta	[10]
	add2	10,#4,10
	dec	4
	bne	alloc1

	lda	#1
	sta	Loaded

	rts

memmsg	dc	c'23/Not enough memory to allocate 24 bit image/OK',h'00'

	END

**************************************************************************
*
* Dispose the current quantized picture
*
**************************************************************************

DisposePic	START

	using	Globals

	lda	PicType
	cmp	#picNone
	bne	disp1
	rts

disp1          lda	picbuf
	ldx	picbuf+2
	jsr	DisposePointer
	lda	picpal
	ldx	picpal+2
	jsr	DisposePointer
	lda	picscb
	ldx	picscb+2
	jmp	DisposePointer

	END

**************************************************************************
*
* Allocate data for a quantized picture
*
**************************************************************************

AllocatePic	START

	using	Globals

	lda	ImageHeight
	sta	picheight
	lda	ImageWidth
	lsr	a
	adc	#0
	sta	picwidth
	Multiply (@a,picheight),@ax
	NewHandle (@xa,ID,#$C008,#0),@ax
	sta	0
	stx	0+2
	ldy	#2
	lda	[0],y
	sta	picbuf+2
	lda	[0]
	sta	picbuf
	lda	picheight
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),@ax
	sta	0
	stx	0+2
	ldy	#2
	lda	[0],y
	sta	picpal+2
	lda	[0]
	sta	picpal
	lda	picheight
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),@ax
	sta	0
	stx	0+2
	ldy	#2
	lda	[0],y
	sta	picscb+2
	lda	[0]
	sta	picscb
	rts
                           
	END

**************************************************************************
*
* Dipsose Pointer
*
**************************************************************************

DisposePointer	START

	sta	foo
	stx	foo+2
	ora	foo+2
	beq	done
	FindHandle foo,@ax
	DisposeHandle @xa
done	rts

foo	ds	4

	END
