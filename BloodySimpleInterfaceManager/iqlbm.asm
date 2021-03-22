**************************************************************************
*
* ImageQuant
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* iqlbm.asm
*
* ImageQuant IFF/ILBM loading routines
*
**************************************************************************

	mcopy	m/iqlbm.mac

;-------------------------------------------------------------------------
; LoadILBM
;    Load a IFF/ILBM file
;-------------------------------------------------------------------------

LoadILBM	START	IQILBM

;	kind	$8000

	using	Globals
	using	lbmdata

color	equ	1
bytes	equ	color+4
bits	equ	bytes+2
pwidth	equ	bits+2
row	equ	pwidth+2
rowsleft	equ	row+4
imageptr	equ	rowsleft+2
pal	equ	imageptr+4
compression	equ	pal+4
stencil	equ	compression+2
planar	equ	stencil+2
curptr	equ	planar+2
space	equ	curptr+4

	subroutine (4:ptr),space

	lda	<ptr
	sta	<curptr
	lda	<ptr+2
	sta	<curptr+2

; check for the FORM chunk

	ph4	curptr
	jsl	readheader

	sta	<curptr
	stx	<curptr+2

	lda	!hdrstring
	cmp	!chkFORM
	jne	notiff
	lda	!hdrstring+2
	cmp	!chkFORM+2
	jne	notiff

	stz	<planar

; check for the PBM or ILBM chunk

	ph4	curptr
	jsl	readheader
	sta	<curptr
	stx	<curptr+2

	lda	!hdrstring
	cmp	!chkPBM
	beq	pbm1
	cmp	!chkILBM
	jne	notilbm

	lda	!hdrstring+2
	cmp	!chkILBM+2
	jne	notilbm

	lda	#1
	sta	<planar
	bra	cont1

pbm1	lda	!hdrstring+2
	cmp	!chkPBM+2
	jne	notilbm

cont1	jsl	DisposeImage

	ldy	#4
	lda	[<curptr],y
	xba
	sta	>ImageWidth

	ldy	#6
	lda	[<curptr],y
	xba
	sta	>ImageHeight

	ldy	#13
	lda	[<curptr],y
	and	#$ff
	sta	<stencil

	iny
	lda	[<curptr],y	
	and	#$ff
	sta	<compression

	ph4	#LoadStr
	lda	>ImageHeight
	pha
	jsl	OpenThermo

	jsl	AllocateImage

; read the palette

	lda	<ptr
	sta	<curptr
	lda	<ptr+2
	sta	<curptr+2

	lda	#12
	sta	!hdrlen
	stz	!hdrlen+2

pallup1	ph4	curptr
	jsl	skipchunk
	phx
	pha
	jsl	readheader
	sta	<curptr
	stx	<curptr+2

	lda	!hdrstring
	cmp	!chkCMAP
	bne	pallup1
	lda	!hdrstring+2
	cmp	!chkCMAP+2
	bne	pallup1

	lda	<curptr
	sta	<pal
	lda	<curptr+2
	sta	<pal+2

; read the image

	lda	<ptr
	sta	<curptr
	lda	<ptr+2
	sta	<curptr+2

	lda	#12
	sta	!hdrlen
	stz	!hdrlen+2

imagelup	ph4	curptr
	jsl	skipchunk
	phx
	pha
	jsl	readheader
	sta	<curptr
	stx	<curptr+2

	lda	!hdrstring
	cmp	!chkBODY
	bne	imagelup
	lda	!hdrstring+2
	cmp	!chkBODY+2
	bne	imagelup

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

; convert a row

	lda	<planar
	beq	nonplanar

	lda	>ImageWidth
	lsr	a
	lsr	a
	lsr	a
	sta	<pwidth

	lda	>ImageWidth
	bit	#3
	beq	skip1
		
	inc	<pwidth

skip1	bit	#1
	beq	skip2

	inc	<pwidth

skip2	lda	#8
	sta	<bits

	lda	<stencil
	beq	skip3

	inc	<bits

skip3	anop

; AHHH do planar code here

	jmp	noplanar

nonplanar	lda	<compression
	jeq	npraw

	lda	>ImageWidth
	sta	<bytes

npclup1	lda	<bytes
	beq	npcdun

	lda	[<curptr]
	and	#$ff

	inc	<curptr
	bne	inc1
	inc	<curptr+2
inc1	anop

	bit	#$80
	beq	npcskp1

	eor	#$ff
	inc	a
	inc	a

	tax

	lda	[<curptr]
	and	#$ff
	pha
	asl	a
	adc	1,s
	ply
	tay
	lda	[<pal],y
	sta	<color
	iny
	lda	[<pal],y
	sta	<color+1

	inc	<curptr
	bne	inc2
	inc	<curptr+2
inc2	anop

npclup2	lda	<color
	sta	[<row]
	ldy	#1
	lda	<color+1
	sta	[<row],y

	dec	<bytes

	clc
	lda	<row
	adc	#3
	sta	<row

	dex
	bne	npclup2

	bra	npcskp2

npcskp1	inc	a
	tax

npclup3	lda	[<curptr]
	and	#$ff
	pha
	asl	a
	adc	1,s
	ply
	tay
	lda	[<pal],y
	sta	[<row]
	iny
	lda	[<pal],y
	ldy	#1
	sta	[<row],y

	dec	<bytes

	inc	<curptr
	bne	inc3
	inc	<curptr+2
inc3	anop

	clc
	lda	<row
	adc	#3
	sta	<row

	dex
	bne	npclup3

npcskp2	bra	npclup1	                      

npcdun	bra	dun

npraw	bra	noraw

dun	jsl	AdvanceThermo

	jsl	TVMM_release	; release the row memory

	clc
	lda	<imageptr
	adc	#2
	sta	<imageptr

	dec	<rowsleft
	jne	yloop

done2	jsl	TVMM_release	; release the image handle

	jsl	CloseThermo

done	return            

notiff	ph4	#errstr1
err	jsl	IQError
	bra	done

notilbm	ph4	#errstr2
	bra	err

noplanar	jsl	TVMM_release
	ph4	#errstr3
	jsl	IQError
	bra	done2

noraw	ph4	#errstr4
	bra	err

errstr1	dc	c'This file is not in IFF form.',h'00'
errstr2	dc	c'This file is not an ILBM or PBM formatted IFF.',h'00'
errstr3	dc	c'Planarized form not currently supported.',h'00'
errstr4	dc	c'Uncompressed files not supported.',h'00'

LoadStr	dc	c'Loading IFF/ILBM Image...',h'00'

	END               

;-------------------------------------------------------------------------
; readheader
;    read an lbm block header
;-------------------------------------------------------------------------

readheader	PRIVATE IQILBM

	using	lbmdata

space	equ	1

	subroutine (4:ptr),space

	lda	[<ptr]
	sta	!hdrstring
	ldy	#2
	lda	[<ptr],y
	sta	!hdrstring+2

	ldy	#4
	lda	[<ptr],y
	xba
	sta	!hdrlen+2
	ldy	#6
	lda	[<ptr],y
	xba
	sta	!hdrlen

	lda	#1
	bit	!hdrlen
	beq	ok
	inc	!hdrlen
	bne	ok
	inc	!hdrlen+2
ok	anop

	clc
	lda	<ptr
	adc	#8
	sta	<ptr
	lda	<ptr+2
	adc	#0
	sta	<ptr+2

	return 4:ptr

	END

;-------------------------------------------------------------------------
; skip chunk
;    skip to the next chunk
;-------------------------------------------------------------------------
                           
skipchunk	PRIVATE IQILBM

	using	lbmdata

space	equ	1

	subroutine (4:ptr),space

	clc
	lda	<ptr
	adc	!hdrlen
	sta	<ptr
	lda	<ptr+2
	adc	!hdrlen+2
	sta	<ptr+2

	return 4:ptr

	END

;-------------------------------------------------------------------------
; LBM data
;-------------------------------------------------------------------------

lbmdata	PRIVDATA IQILBM

hdrstring	ds	4
hdrlen	ds	4
chkFORM	dc	c'FORM'
chkPBM	dc	c'PBM '
chkILBM	dc	c'ILBM'
chkCMAP	dc	c'CMAP'
chkBODY	dc	c'BODY'

	END
                                       
