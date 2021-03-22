**************************************************************************
*
* ImageQuant
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* iqbmp.asm
*
* ImageQuant Windows BMP loading routines
*
**************************************************************************

	mcopy	m/iqbmp.mac

;-------------------------------------------------------------------------
; LoadBMP
;    Load a Windows BMP file
;-------------------------------------------------------------------------

LoadBMP	START	IQBMP

;	kind	$8000

	using	Globals

rowsleft	equ	1
bytes	equ	rowsleft+2
row	equ	bytes+2
imageptr	equ	row+4
pal	equ	imageptr+4
bitmap	equ	pal+4
space	equ	bitmap+4

	subroutine (4:ptr),space

	lda	[<ptr]
	cmp	!id
	jne	notbmp

	clc
	lda	<ptr
	ldy	#10
	adc	[<ptr],y
	sta	<bitmap
	lda	<ptr+2
	ldy	#12
	adc	[<ptr],y
	sta	<bitmap+2

	clc
	lda	<ptr
	ldy	#14
	adc	[<ptr],y
	sta	<pal
	lda	<ptr+2
	ldy	#16
	adc	[<ptr],y
	sta	<pal+2

	clc
	lda	<pal
	adc	#14
	sta	<pal
	lda	<pal+2
	adc	#0
	sta	<pal+2

	ldy	#30
	lda	[<ptr],y
	jne	nocomp

	jsl	DisposeImage

	ldy	#18
	lda	[<ptr],y
	sta	>ImageWidth
	ldy	#22
	lda	[<ptr],y
	sta	>ImageHeight

	ph4	#LoadStr
	lda	>ImageHeight
	pha
	jsl	OpenThermo

	jsl	AllocateImage

	ldy	#28
	lda	[<ptr],y
	cmp	#4
	beq	bits4
	cmp	#8
	jeq	bits8
	cmp	#24
	jeq	bits24

	jmp	badbit

bits4	lda	>ImageHandle      
	pha
	pha
	jsl	TVMM_acquire
	sta	<imageptr
	stx	<imageptr+2

	lda	>ImageHeight
	sta	<rowsleft

	dec	a
	asl	a
	adc	<imageptr
	sta	<imageptr

yloop4	lda	[<imageptr]
	pha
	pha
	jsl	TVMM_acquire
	sta	<row
	stx	<row+2

	lda	>ImageWidth
	sta	<bytes

xloop4	lda	[<bitmap]
	and	#$F0
	lsr	a
	lsr	a
	tay
	iny
	lda	[<pal],y
	xba
	sta	[<row]
	dey
	lda	[<pal],y
	xba
	ldy	#1
	sta	[<row],y

	clc
	lda	<row
	adc	#3
	sta	<row

	dec	<bytes
	jeq	nexty4

ok4	lda	[<bitmap]
	and	#$0F
	asl	a
	asl	a
	tay
	iny
	lda	[<pal],y
	xba
	sta	[<row]
	dey
	lda	[<pal],y
	xba
	ldy	#1
	sta	[<row],y

	clc
	lda	<row
	adc	#3
	sta	<row

	inc	<bitmap
	bne	inc4b
	inc	<bitmap+1
inc4b	anop

	dec	<bytes
	bne	xloop4

nexty4	jsl	AdvanceThermo

	jsl	TVMM_release	; release the row memory

	lda	>ImageWidth
	lsr	a
	and	#%11
	beq	skip4a
	eor	#$ffff
	sec
	adc	#4
	clc
	adc	<bitmap
	sta	<bitmap
	lda	<bitmap+2
	adc	#0
	sta	<bitmap+2
skip4a	anop

	sec
	lda	<imageptr
	sbc	#2
	sta	<imageptr

	dec	<rowsleft
	jne	yloop4

	jmp	finished

bits8	lda	>ImageHandle      
	pha
	pha
	jsl	TVMM_acquire
	sta	<imageptr
	stx	<imageptr+2

	lda	>ImageHeight
	sta	<rowsleft

	dec	a
	asl	a
	adc	<imageptr
	sta	<imageptr

yloop8	lda	[<imageptr]
	pha
	pha
	jsl	TVMM_acquire
	sta	<row
	stx	<row+2

	lda	>ImageWidth
	sta	<bytes

xloop8	lda	[<bitmap]
	and	#$FF
	asl	a
	asl	a
	tay
	iny
	lda	[<pal],y
	xba
	sta	[<row]
	dey
	lda	[<pal],y
	xba
	ldy	#1
	sta	[<row],y

	clc
	lda	<row
	adc	#3
	sta	<row

	inc	<bitmap
	bne	inc8a
	inc	<bitmap+1
inc8a	anop

	dec	<bytes
	bne	xloop8

nexty8	jsl	AdvanceThermo

	jsl	TVMM_release	; release the row memory

	lda	>ImageWidth
	and	#%11
	beq	skip8a
	eor	#$ffff
	sec
	adc	#4
	clc
	adc	<bitmap
	sta	<bitmap
	lda	<bitmap+2
	adc	#0
	sta	<bitmap+2
skip8a	anop

	sec
	lda	<imageptr
	sbc	#2
	sta	<imageptr

	dec	<rowsleft
	jne	yloop8

	jmp	finished
                     
bits24	lda	>ImageHandle      
	pha
	pha
	jsl	TVMM_acquire
	sta	<imageptr
	stx	<imageptr+2

	lda	>ImageHeight
	sta	<rowsleft

	dec	a
	asl	a
	adc	<imageptr
	sta	<imageptr

yloop24	lda	[<imageptr]
	pha
	pha
	jsl	TVMM_acquire
	sta	<row
	stx	<row+2

	lda	>ImageWidth
	sta	<bytes

xloop24	ldy	#1
	lda	[<bitmap],y
	xba
	sta	[<row]
	lda	[<bitmap]
	xba
	sta	[<row],y

	clc
	lda	<row
	adc	#3
	sta	<row

	lda	<bitmap
	adc	#3
	sta	<bitmap
	lda	<bitmap+2
	adc	#0
	sta	<bitmap+2

	dec	<bytes
	bne	xloop24

nexty24	jsl	AdvanceThermo

	jsl	TVMM_release	; release the row memory

	lda	>ImageWidth
	asl	a
	adc	>ImageWidth
	and	#%11
	beq	skip24a
	eor	#$ffff
	sec
	adc	#4
	clc
	adc	<bitmap
	sta	<bitmap
	lda	<bitmap+2
	adc	#0
	sta	<bitmap+2
skip24a	anop

	sec
	lda	<imageptr
	sbc	#2
	sta	<imageptr

	dec	<rowsleft
	jne	yloop24

	jmp	finished

finished	jsl	TVMM_release	; release the image handle

	jsl	CloseThermo

done	return            

notbmp	ph4	#errstr1
err	jsl	IQError
	bra	done

nocomp	ph4	#errstr2
	bra	err

badbit	ph4	#errstr3
	bra	err

id	dc	c'BM'

errstr1	dc	c'Unknown .BMP type.',h'00'
errstr2	dc	c'Unsupported compression type.',h'00'
errstr3	dc	c'Unsupported color resolution.',h'00'

LoadStr	dc	c'Loading Windows(tm) .BMP Image...',h'00'

	END               
