**************************************************************************
*
* ImageQuant
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* iq16col.asm
*
* ImageQuant 16 color converters
*
**************************************************************************

	mcopy	m/iq16col.mac

;-------------------------------------------------------------------------
; doPlainOctree16
;    16 color octree quantization w/o dithering
;-------------------------------------------------------------------------

doPlainOctree16 START

	using	Globals
	using	OctData

tree	equ	1
image	equ	tree+2
height	equ	image+4
offset	equ	height+2
lineptr	equ	offset+2
width	equ	lineptr+4
pic	equ	width+2
space	equ	pic+4

	subroutine (0:dummy),space

	ph4	#loadstr
	lda	!ImageHeight
	asl	a
	pha
	jsl	OpenThermo

	jsl	DisposePic
	jsl	AllocatePic
	jsl	Mk16SCB
	jsr	InitOct

	stz	<tree

	lda	!ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

	lda	!ImageHeight
	sta	<height

yloop	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2
	
	lda	!ImageWidth
	sta	<width

xloop	pei	(<tree)
	ldy	#2
	lda	[<lineptr],y
	pha
	lda	[<lineptr]
	pha
	pea	0
	jsr	inserttree
	sta	<tree
	lda	!size
	cmp	#64
	bcc	nextone
	jsr	reducetree
	clc
nextone	lda	<lineptr
	adc	#3
	sta	<lineptr
	dec	<width
	bne	<xloop

nexty	inc	<image
	inc	<image
	jsl	AdvanceThermo
	jsl	TVMM_release
	dec	<height
	jne	yloop	

	jsl	TVMM_release

reduce	lda	!size
	cmp	#17
	bcc	donereduce
	jsr	reducetree
	bra	reduce
donereduce	anop

	stz	!index

	lda	!PicPalHandle
	pha
	pha
	jsl	TVMM_acquire

	pei	(<tree)
	ph4	#index	
	phx
	pha
	jsr	initcolortable

	jsl	TVMM_release

	ldx	#0
	jsl	ExpandPal

	lda	!PicHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<pic
	stx	<pic+2

	lda	!ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

	lda	!ImageHeight
	sta	<height

yloop2	stz	<offset

	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2

	lda	!ImageWidth
	sta	<width

xloop2	ldy	#2
	lda	[<lineptr],y
	and	#$FF
	tax
	lda	[<lineptr]
	jsr	FindColor
	asl	a
	asl	a
	asl	a
	asl	a
	ldy	<offset
	short	a
	sta	[<pic],y
	long	a
	lda	<lineptr
	adc	#3
	sta	<lineptr
	dec	<width
	beq	nexty2

	ldy	#2
	lda	[<lineptr],y
	tax
	lda	[<lineptr]
	jsr	FindColor
	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	clc
	lda	<lineptr
	adc	#3
	sta	<lineptr
	inc	<offset
	dec	<width
	bne	xloop2

nexty2	inc	<image
	inc	<image
	lda	<pic
	adc	!PicWidth
	sta	<pic
	lda	<pic+2
	adc	#0
	sta	<pic+2

	jsl	AdvanceThermo
	jsl	TVMM_release

	dec	<height
	jne	yloop2	

	jsl	TVMM_release
	jsl	TVMM_release

	jsl	CloseThermo

	return

index	ds	2
loadstr	dc	c'Octree Quantization...',h'00'

	END

;-------------------------------------------------------------------------
; doOrder2Octree16
;    16 color octree quantization w/ Order-2 dithering
;-------------------------------------------------------------------------

doOrder2Octree16 START

	using	Globals
	using	OctData

value	equ	1
dithoffset	equ	value+4
tree	equ	dithoffset+2
image	equ	tree+2
height	equ	image+4
offset	equ	height+2
lineptr	equ	offset+2
width	equ	lineptr+4
pic	equ	width+2
space	equ	pic+4

	subroutine (0:dummy),space

	ph4	#loadstr
	lda	!ImageHeight
	asl	a
	pha
	jsl	OpenThermo

	jsl	DisposePic
	jsl	AllocatePic
	jsl	Mk16SCB
	jsr	InitOct

	stz	<tree

	lda	!ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

	lda	!ImageHeight
	sta	<height

yloop	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2
	
	lda	!ImageWidth
	sta	<width

xloop	pei	(<tree)
	ldy	#2
	lda	[<lineptr],y
	pha
	lda	[<lineptr]
	pha
	pea	0
	jsr	inserttree
	sta	<tree
	lda	!size
	cmp	#64
	bcc	nextone
	jsr	reducetree
	clc
nextone	lda	<lineptr
	adc	#3
	sta	<lineptr
	dec	<width
	bne	<xloop

nexty	inc	<image
	inc	<image
	jsl	AdvanceThermo
	jsl	TVMM_release
	dec	<height
	jne	yloop	

	jsl	TVMM_release

reduce	lda	!size
	cmp	#17
	bcc	donereduce
	jsr	reducetree
	bra	reduce
donereduce	anop

	stz	!index

	lda	!PicPalHandle
	pha
	pha
	jsl	TVMM_acquire

	pei	(<tree)
	ph4	#index	
	phx
	pha
	jsr	initcolortable

	jsl	TVMM_release

	ldx	#0
	jsl	ExpandPal

	lda	!PicHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<pic
	stx	<pic+2

	lda	!ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

	stz	<dithoffset

	lda	!ImageHeight
	sta	<height

yloop2	stz	<offset

	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2

	lda	!ImageWidth
	sta	<width

xloop2	lda	[<lineptr]
	sta	<value
	ldy	#2
	lda	[<lineptr],y
	and	#$ff
	sta	<value+2

	short	a
	lda	<value
	tax
	and	#$F0
	sta	<value
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl,x
	bcc	ord01
	lda	<value
	adc	#$10-1
	beq	ord01
	sta	<value
ord01          anop

	lda	<value+1
	tax
	and	#$F0
	sta	<value+1
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl,x
	bcc	ord02
	lda	<value+1
	adc	#$10-1
	beq	ord02
	sta	<value+1
ord02          anop

	lda	<value+2
	tax
	and	#$F0
	sta	<value+2
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl,x
	bcc	ord03
	lda	<value+2
	adc	#$10-1
	beq	ord03
	sta	<value+2
ord03          long	a

	lda	<value
	ldx	<value+2
	jsr	FindColor
	asl	a
	asl	a
	asl	a
	asl	a
	ldy	<offset
	short	a
	sta	[<pic],y
	long	a
	lda	<lineptr
	adc	#3
	sta	<lineptr
	dec	<width
	jeq	nexty2

	lda	[<lineptr]
	sta	<value
	ldy	#2
	lda	[<lineptr],y
	and	#$ff
	sta	<value+2

	short	a
	lda	<value
	tax
	and	#$F0
	sta	<value
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl+2,x
	bcc	ord04
	lda	<value
	adc	#$10-1
	beq	ord04
	sta	<value
ord04          anop

	lda	<value+1
	tax
	and	#$F0
	sta	<value+1
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl+2,x
	bcc	ord05
	lda	<value+1
	adc	#$10-1
	beq	ord05
	sta	<value+1
ord05          anop

	lda	<value+2
	tax
	and	#$F0
	sta	<value+2
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl+2,x
	bcc	ord06
	lda	<value+2
	adc	#$10-1
	beq	ord06
	sta	<value+2
ord06          anop
	long	a

	lda	<value
	ldx	<value+2

	jsr	FindColor
	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	clc
	lda	<lineptr
	adc	#3
	sta	<lineptr
	inc	<offset
	dec	<width
	jne	xloop2

nexty2	inc	<image
	inc	<image
	lda	<pic
	adc	!PicWidth
	sta	<pic
	lda	<pic+2
	adc	#0
	sta	<pic+2

	jsl	AdvanceThermo
	jsl	TVMM_release

	lda	<dithoffset
	adc	#4
	and	#8-1
	sta	<dithoffset

	dec	<height   
	jne	yloop2	

	jsl	TVMM_release
	jsl	TVMM_release

	jsl	CloseThermo

	return

index	ds	2
loadstr	dc	c'Octree Quantization...',h'00'

dithtbl	dc	i2'1,3,4,2'

	END             

;-------------------------------------------------------------------------
; doErr1Octree16
;    16 color octree quantization w/ error diffusion 1
;-------------------------------------------------------------------------

doErr1Octree16 START

	using	Globals
	using	OctData
	using	Tables                     

tree	equ	1
image	equ	tree+2
height	equ	image+4
offset	equ	height+2
lineptr	equ	offset+2
width	equ	lineptr+4
currline	equ	width+2
curgline	equ	currline+4
curbline       equ	curgline+4
nextrline	equ	curbline+4
nextgline	equ	nextrline+4
nextbline	equ	nextgline+4
currptr	equ	nextbline+4
curgptr	equ	currptr+4
curbptr       	equ	curgptr+4
nextrptr	equ	curbptr+4
nextgptr	equ	nextrptr+4
nextbptr	equ	nextgptr+4
rval	equ	nextbptr+4
gval	equ	rval+2  
bval	equ	gval+2
offflag	equ	bval+2
pic	equ	offflag+2
space	equ	pic+4

	subroutine (0:dummy),space

	ph4	#loadstr
	lda	!ImageHeight
	asl	a
	pha
	jsl	OpenThermo

	jsl	DisposePic
	jsl	AllocatePic
	jsl	ClrPic
	jsl	Mk16SCB
	jsr	InitOct

	stz	<tree

	lda	!ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

	lda	!ImageHeight
	sta	<height
yloop	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2

	lda	!ImageWidth
	sta	<width
xloop	pei	(<tree)
	ldy	#2
	lda	[<lineptr],y
	pha
	lda	[<lineptr]
	pha
	pea	0
	jsr	inserttree
	sta	<tree
	lda	!size
	cmp	#64
	bcc	nextone
	jsr	reducetree
	clc
nextone	lda	<lineptr
	adc	#3
	sta	<lineptr
	dec	<width
	bne	xloop

nexty	inc	<image
	inc	<image
	jsl	TVMM_release
	jsl	AdvanceThermo
	dec	<height
	jne	yloop	

	jsl	TVMM_release

reduce	lda	!size
	cmp	#17
	bcc	donereduce
	jsr	reducetree
	bra	reduce
donereduce	anop

	stz	!index

	lda	!PicPalHandle
	pha
	pha
	jsl	TVMM_acquire

	pei	(<tree)
	ph4	#index
	phx
	pha
	jsr	initcolortable

	jsl	TVMM_release

	ldx	#0
	jsl	ExpandPal	;Expand the palette for easy access

	pea	$C018
	pea	0
	lda	!ImageWidth
	inc	a
	asl	a
	pha
	jsl	TVMM_allocreal
	sta	<currline
	stx	<currline+2
	sta	<currptr
	stx	<currptr+2

	pea	$C018
	pea	0
	lda	!ImageWidth
	inc	a
	asl	a
	pha
	jsl	TVMM_allocreal
	sta	<curgline
	stx	<curgline+2
	sta	<curgptr
	stx	<curgptr+2

	pea	$C018
	pea	0
	lda	!ImageWidth
	inc	a
	asl	a
	pha
	jsl	TVMM_allocreal
	sta	<curbline
	stx	<curbline+2
	sta	<curbptr
	stx	<curbptr+2

	pea	$C018
	pea	0
	lda	!ImageWidth
	inc	a
	asl	a
	pha
	jsl	TVMM_allocreal
	sta	<nextrline
	stx	<nextrline+2
	sta	<nextrptr
	stx	<nextrptr+2

	pea	$C018
	pea	0
	lda	!ImageWidth
	inc	a
	asl	a
	pha
	jsl	TVMM_allocreal
	sta	<nextgline
	stx	<nextgline+2
	sta	<nextgptr
	stx	<nextgptr+2

	pea	$C018
	pea	0
	lda	!ImageWidth
	inc	a
	asl	a
	pha
	jsl	TVMM_allocreal
	sta	<nextbline
	stx	<nextbline+2
	sta	<nextbptr
	stx	<nextbptr+2

	lda	!ImageWidth
	asl	a
	tay
	lda	#0
clear	sta	[<nextrline],y	
	sta	[<nextgline],y
	sta	[<nextbline],y
	dey
	dey
	bpl	clear

	lda	!PicHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<pic
	stx	<pic+2

	lda	!ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image	
	stx	<image+2

	lda	!ImageHeight
	sta	<height
yloop2	stz	<offset
	stz	<offflag

	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2

	lda	!ImageWidth
	sta	<width

	asl	a
	tay
copy	lda	[<nextrline],y
	sta	[<currline],y
	lda	[<nextgline],y
	sta	[<curgline],y
	lda	[<nextbline],y
	sta	[<curbline],y
	lda	#0
	sta	[<nextrline],y
	sta	[<nextgline],y
	sta	[<nextbline],y
	dey         
	dey
	bpl	copy

xloop2	short	i
	phx		;dummy
	ldy	#2
	lda	[<lineptr],y
	and	#$FF
	clc
	adc	[<curbline]
	bpl	clip1a
	lda	#0
	bra	clip1
clip1a	cmp	#$100
	bcc	clip1
	lda	#$FF
clip1	sta	<bval
	tax
	phx
	ldy	#1
	lda	[<lineptr],y
	and	#$FF
	clc
	adc	[<curgline]
	bpl	clip2a
	lda	#0
	bra	clip2
clip2a	cmp	#$100
	bcc	clip2
	lda	#$FF
clip2	sta	<gval
	tax
	phx
	lda	[<lineptr]
	and	#$FF
	clc
	adc	[<currline]
	bpl	clip3a
	lda	#0
	bra	clip3
clip3a	cmp	#$100
	bcc	clip3
	lda	#$FF
clip3	sta	<rval
	tax
	phx

	long	i
	pla
	plx
	jsr	FindColor
	tax
	ldy	<offflag
	bne	odd

	asl	a	;even
	asl	a
	asl	a
	asl	a
	inc	<offflag
	ldy	<offset
	short	a
	sta	[<pic],y
	long	a
	bra	doneplot

odd	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	inc	<offset
	stz	<offflag

doneplot	txa
	asl	a
	tay

	sec
	lda	<gval
	sbc	!palg,y
	sta	<gval

	sec
	lda	<bval
	sbc	!palb,y
	sta	<bval

	sec
	lda	<rval
	sbc	!palr,y
	bmi	minus1

	tax
	lda	!three8tbl1,x
	and	#$FF
	clc
	adc	[<nextrline]
	sta	[<nextrline]
	lda	!three8tbl2,x
	and	#$FF
	clc
	ldy	#2
	adc	[<currline],y
	sta	[<currline],y
	lda	!one4tbl,x
	and	#$FF
	clc
	adc	[<nextrline],y
	sta	[<nextrline],y
	bra	fini1        
minus1	eor	#$FFFF
	inc	a
	tax
	lda	!three8tbl1,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[<nextrline]
	sta	[<nextrline]
	lda	!three8tbl2,x
	and	#$FF
	eor	#$FFFF
	sec
	ldy	#2
	adc	[<currline],y
	sta	[<currline],y
	lda	!one4tbl,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[<nextrline],y
	sta	[<nextrline],y

fini1	lda	<gval
	bmi	minus2	            
	tax
	lda	!three8tbl1,x
	and	#$FF
	clc
	adc	[<nextgline]
	sta	[<nextgline]
	lda	!three8tbl2,x
	and	#$FF
	clc
	adc	[<curgline],y
	sta	[<curgline],y
	lda	!one4tbl,x
	and	#$FF
	clc
	adc	[<nextgline],y
	sta	[<nextgline],y
	bra	fini2        
minus2	eor	#$FFFF
	inc	a
	tax
	lda	!three8tbl1,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[<nextgline]
	sta	[<nextgline]
	lda	!three8tbl2,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[<curgline],y
	sta	[<curgline],y
	lda	!one4tbl,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[<nextgline],y
	sta	[<nextgline],y

fini2	lda	<bval
	bmi	minus3	            
	tax
	lda	!three8tbl1,x
	and	#$FF
	clc
	adc	[<nextbline]
	sta	[<nextbline]
	lda	!three8tbl2,x
	and	#$FF
	clc
	adc	[<curbline],y
	sta	[<curbline],y
	lda	!one4tbl,x
	and	#$FF
	clc
	adc	[<nextbline],y
	sta	[<nextbline],y
	bra	fini3        
minus3	eor	#$FFFF
	inc	a
	tax
	lda	!three8tbl1,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[<nextbline]
	sta	[<nextbline]
	lda	!three8tbl2,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[<curbline],y
	sta	[<curbline],y
	lda	!one4tbl,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[<nextbline],y
	sta	[<nextbline],y
fini3	inc	<nextrline
	inc	<nextrline                           
	inc	<nextgline
	inc	<nextgline                           
	inc	<nextbline
	inc	<nextbline                           
	inc	<currline
	inc	<currline                           
	inc	<curgline
	inc	<curgline                           
	inc	<curbline
	inc	<curbline
	clc
	lda	<lineptr
	adc	#3
	sta	<lineptr                        
	dec	<width
	jne	xloop2

	inc	<image
	inc	<image
	lda	<pic
	adc	!PicWidth
	sta	<pic
	lda	<pic+2
	adc	#0
	sta	<pic+2
	lda	<currptr
	sta	<currline
	lda	<curgptr
	sta	<curgline
	lda	<curbptr
	sta	<curbline
	lda	<nextrptr
	sta	<nextrline
	lda	<nextgptr
	sta	<nextgline
	lda	<nextbptr
	sta	<nextbline
               jsl	TVMM_release
	jsl	AdvanceThermo
	dec	<height
	jne	yloop2	

	jsl	TVMM_release
	jsl	TVMM_release

	FindHandle nextrptr,@ax
	DisposeHandle @xa
	FindHandle nextgptr,@ax
	DisposeHandle @xa
	FindHandle nextbptr,@ax
	DisposeHandle @xa
	FindHandle currptr,@ax
	DisposeHandle @xa
	FindHandle curgptr,@ax
	DisposeHandle @xa
	FindHandle curbptr,@ax
	DisposeHandle @xa
                                
	jsl	CloseThermo

	return

index	ds	2

loadstr	dc	c'Octree Quantization...',h'00'

	END

                     
