**************************************************************************
*
* Convert to a 3200 color picture...
*
**************************************************************************

	mcopy	c3200.mac
	copy	iq.h

Convert3200	START

	using	Globals

	GetCtlValue QuantHand,comp+1
	ldx	#0
loop	lda	dithtbl,x
	beq	baddith
comp	cmp	#0000
	beq	found
	inx
	inx
	bra	loop
baddith	AlertWindow (#0,#0,#dithmsg),@a
	rts

found	jmp	(jmptbl,x)	

dithtbl	dc	i2'OctreeID'
	dc	i2'VarQuantID'
	dc	i2'SierchioID'
	dc	i2'WuID'
	dc	i2'MedianCutID'
	dc	i2'0'
                                 
jmptbl	dc	i2'doOctree3200'
	dc	i2'doNothing'
	dc	i2'doNothing'
	dc	i2'doNothing'
	dc	i2'doNothing'

dithmsg	dc	c'23/Unknown Quantization type/OK',h'00'

	END

**************************************************************************
*
* Octree quantization
*
**************************************************************************

doOctree3200	START

	using	Globals

	GetCtlValue DitherHand,comp+1
	ldx	#0
loop	lda	dithtbl,x
	beq	baddith
comp	cmp	#0000
	beq	found
	inx
	inx
	bra	loop
baddith	AlertWindow (#0,#0,#dithmsg),@a
	rts

found	jmp	(jmptbl,x)	

dithtbl	dc	i2'NoDitherID'
	dc	i2'Order2ID'
	dc	i2'Order4ID'
	dc	i2'Floyd1ID'
	dc	i2'Floyd2ID'
	dc	i2'DotDiffID'
	dc	i2'HilbertID'
	dc	i2'PeanoID'
	dc	i2'0'
                                 
jmptbl	dc	i2'doPlainOctree3200'
	dc	i2'doNothing'
	dc	i2'doNothing'
	dc	i2'doFloyd1Octree3200'
	dc	i2'doNothing'
	dc	i2'doNothing'
	dc	i2'doNothing'
	dc	i2'doNothing'
                          
dithmsg	dc	c'23/Unknown dither type/OK',h'00'

	END

**************************************************************************
*
* 3200 mode with Octree quantization
*
**************************************************************************

doPlainOctree3200 START

	using	Globals
	using	OctData

image	equ	0
height	equ	4
offset	equ	6
lineptr	equ	8
width	equ	12
paloffset	equ	14
pic	equ	16

	WaitCursor

	ph4	#loadstr
	ph2	ImageHeight
	jsl	OpenThermo
	stz	thermo

	jsr	DisposePic
	jsr	AllocatePic
	jsr	clrPic

	lda	picpal
	sta	palptr
	lda	picpal+2
	sta	palptr+2
	stz	paloffset

	lda	picbuf
	sta	pic
	lda	picbuf+2
	sta	pic+2
	lda	ImagePtr
	sta	image
	lda	ImagePtr+2	
	sta	image+2
	lda	ImageHeight
	sta	height

yloop2	jsr	InitOct

	stz	tree

	lda	[image]
	sta	lineptr
	ldy	#2
	lda	[image],y
	sta	lineptr+2
	lda	ImageWidth
	sta	width
xloop	lda	tree
	pha
	ldy	#2
	lda	[lineptr],y
	and	#$FF
	pha
	lda	[lineptr]
	pha
	pea	0
	jsr	inserttree
	sta	tree
	lda	size
	cmp	#17
	bcc	nextone
	jsr	reducetree
nextone	clc
	lda	lineptr
	adc	#3
	sta	lineptr
	dec	width
	bne	xloop

initcolor	stz	index
	lda	tree
	pha
	ph4	#index
	ph4	palptr
	jsr	initcolortable
	ldx	paloffset
	jsr	ExpandPal

	lda	[image]
	sta	lineptr
	ldy	#2
	lda	[image],y
	sta	lineptr+2

	lda	ImageWidth
	sta	width
	stz	offset

xloop2	ldy	#2
	lda	[lineptr],y
	and	#$FF
	tax
	lda	[lineptr]
	jsr	FindColor
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$F0
	ldy	offset
	ora	[pic],y
	sta	[pic],y
	add2	lineptr,#3,lineptr
	dec	width
	beq	nexty2
	ldy	#2
	lda	[lineptr],y
	tax
	lda	[lineptr]
	jsr	FindColor
	and	#$0F
	ldy	offset
	ora	[pic],y
	sta	[pic],y
	add2	lineptr,#3,lineptr
	inc	offset
	dec	width
	bne	xloop2

nexty2	clc
	lda	image
	adc	#4
	sta	image
	lda	pic
	adc	picwidth
	sta	pic
	lda	pic+2
	adc	#0
	sta	pic+2
	clc
	lda	palptr
	adc	#32
	sta	palptr
	clc
	lda	paloffset
	adc	#32
	sta	paloffset
	inc	thermo
	lda	thermo
	jsl	UpdateThermo
	dec	height
	jne	yloop2	

	lda	#pic3200
	sta	picType

	jsl	CloseThermo
	InitCursor

	jmp	doView

tree	ds	2
index	ds	2
palptr	ds	4
thermo	ds	2

loadstr	dc	c'Octree Quantization w/o Dithering...',h'00'

	END

**************************************************************************
*
* 3200 mode with Octree quantization w/ Floyd Steinberg #1 dithering
*
**************************************************************************

doFloyd1Octree3200 START

	using	Globals
	using	OctData
	using	Tables

image	equ	0
height	equ	4
offset	equ	6
lineptr	equ	8
width	equ	12
currline	equ	14
curgline	equ	18
curbline       equ	22
nextrline	equ	26
nextgline	equ	30
nextbline	equ	34
currhand	equ	38
curghand	equ	42
curbhand       equ	46
nextrhand	equ	50
nextghand	equ	54
nextbhand	equ	58
rval	equ	62
gval	equ	64
bval	equ	66
offflag	equ	68
paloffset	equ	70
pic	equ	72
                  
	WaitCursor

	ph4	#loadstr
	ph2	ImageHeight
	jsl	OpenThermo
	stz	thermo

	jsr	DisposePic
	jsr	AllocatePic

	lda	ImageWidth
	inc	a
	asl	a
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),currhand
	ldy	#2
	lda	[currhand],y
	sta	currline+2
	lda	[currhand]
	sta	currline

	lda	ImageWidth
	inc	a
	asl	a
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),curghand
	ldy	#2
	lda	[curghand],y
	sta	curgline+2
	lda	[curghand]
	sta	curgline

	lda	ImageWidth
	inc	a
	asl	a
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),curbhand
	ldy	#2
	lda	[curbhand],y
	sta	curbline+2
	lda	[curbhand]
	sta	curbline

	lda	ImageWidth
	inc	a
	asl	a
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),nextrhand
	ldy	#2
	lda	[nextrhand],y
	sta	nextrline+2
	lda	[nextrhand]
	sta	nextrline

	lda	ImageWidth
	inc	a
	asl	a
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),nextghand
	ldy	#2
	lda	[nextghand],y
	sta	nextgline+2
	lda	[nextghand]
	sta	nextgline

	lda	ImageWidth
	inc	a
	asl	a
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),nextbhand
	ldy	#2
	lda	[nextbhand],y
	sta	nextbline+2
	lda	[nextbhand]
	sta	nextbline

	lda	picpal
	sta	palptr
	lda	picpal+2
	sta	palptr+2
	lda	picbuf
	sta	pic
	lda	picbuf+2
	sta	pic+2
	jsr	clrPic
	stz	paloffset

	lda	ImageWidth
	asl	a
	tay
	lda	#0
clear	sta	[nextrline],y	
	sta	[nextgline],y
	sta	[nextbline],y
	dey
	dey
	bpl	clear

	mv4	ImagePtr,image
	lda	ImageHeight
	sta	height

yloop2	jsr	InitOct

	stz	tree

	lda	[image]
	sta	lineptr
	ldy	#2
	lda	[image],y
	sta	lineptr+2
	lda	ImageWidth
	sta	width

	lda	ImageWidth
	asl	a
	tay
copy	lda	[nextrline],y
	sta	[currline],y
	lda	[nextgline],y
	sta	[curgline],y
	lda	[nextbline],y
	sta	[curbline],y
	lda	#0
	sta	[nextrline],y
	sta	[nextgline],y
	sta	[nextbline],y
	dey         
	dey
	bpl	copy

xloop	lda	tree
	pha
	short	i
	phx		;dummy
	ldy	#2
	lda	[lineptr],y
	and	#$FF
	clc
	adc	[curbline]
	bpl	clipa1a
	lda	#0
	bra	clipa1
clipa1a	cmp	#$100
	bcc	clipa1
	lda	#$FF
clipa1	sta	bval
	tax
	phx
	ldy	#1
	lda	[lineptr],y
	and	#$FF
	clc
	adc	[curgline]
	bpl	clipa2a
	lda	#0
	bra	clipa2
clipa2a	cmp	#$100
	bcc	clipa2
	lda	#$FF
clipa2	sta	gval
	tax
	phx
	lda	[lineptr]
	and	#$FF
	clc
	adc	[currline]
	bpl	clipa3a
	lda	#0
	bra	clipa3
clipa3a	cmp	#$100
	bcc	clipa3
	lda	#$FF
clipa3	sta	rval
	tax
	phx
	long	i
	pea	0
	jsr	inserttree
	sta	tree
	lda	size
	cmp	#17
	bcc	nextone
	jsr	reducetree
nextone	add2	lineptr,#3,lineptr
	inc	nextrline
	inc	nextrline                           
	inc	nextgline
	inc	nextgline                           
	inc	nextbline
	inc	nextbline                           
	inc	currline
	inc	currline                           
	inc	curgline
	inc	curgline                           
	inc	curbline
	inc	curbline                           
	dec	width    
	jne	xloop

initcolor	stz	index
	lda	tree
	pha
	ph4	#index
	ph4	palptr
	jsr	initcolortable
	ldx	paloffset
	jsr	ExpandPal

	ldy	#2
	lda	[currhand]
	sta	currline
	lda	[currhand],y
	sta	currline+2
	lda	[curghand]
	sta	curgline
	lda	[curghand],y
	sta	curgline+2
	lda	[curbhand]
	sta	curbline
	lda	[curbhand],y
	sta	curbline+2
	lda	[nextrhand]
	sta	nextrline
	lda	[nextrhand],y
	sta	nextrline+2
	lda	[nextghand]
	sta	nextgline
	lda	[nextghand],y
	sta	nextgline+2
	lda	[nextbhand]
	sta	nextbline
	lda	[nextbhand],y
	sta	nextbline+2

	stz	offset
	stz	offflag
	lda	[image]
	sta	lineptr
	ldy	#2
	lda	[image],y
	sta	lineptr+2

	lda	ImageWidth
	sta	width

xloop2	short	i
	phx		;dummy
	ldy	#2
	lda	[lineptr],y
	and	#$FF
	clc
	adc	[curbline]
	bpl	clip1a
	lda	#0
	bra	clip1
clip1a	cmp	#$100
	bcc	clip1
	lda	#$FF
clip1	sta	bval
	tax
	phx
	ldy	#1
	lda	[lineptr],y
	and	#$FF
	clc
	adc	[curgline]
	bpl	clip2a
	lda	#0
	bra	clip2
clip2a	cmp	#$100
	bcc	clip2
	lda	#$FF
clip2	sta	gval
	tax
	phx
	lda	[lineptr]
	and	#$FF
	clc
	adc	[currline]
	bpl	clip3a
	lda	#0
	bra	clip3
clip3a	cmp	#$100
	bcc	clip3
	lda	#$FF
clip3	sta	rval
	tax
	phx
	long	i
	pla
	plx
	jsr	FindColor
	tax
	ldy	offflag
	bne	odd

	asl	a	;even
	asl	a
	asl	a
	asl	a
	inc	offflag
	ldy	offset
	ora	[pic],y
	sta	[pic],y
	bra	doneplot

odd	ldy	offset
	ora	[pic],y
	sta	[pic],y
	inc	offset
	stz	offflag

doneplot	txa
	asl	a
	tay
	sec
	lda	gval
	sbc	palg,y
	sta	gval
	sec
	lda	bval
	sbc	palb,y
	sta	bval
	sec
	lda	rval
	sbc	palr,y
	bmi	minus1
	tax
	lda	three8tbl1,x
	and	#$FF
	clc
	adc	[nextrline]
	sta	[nextrline]
	ldy	#2
	lda	three8tbl2,x
	and	#$FF
	clc
	adc	[currline],y
	sta	[currline],y
	lda	one4tbl,x
	and	#$FF
	clc
	adc	[nextrline],y
	sta	[nextrline],y
	bra	fini1        
minus1	eor	#$FFFF
	inc	a
	tax
	lda	three8tbl1,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[nextrline]
	sta	[nextrline]
	ldy	#2
	lda	three8tbl2,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[currline],y
	sta	[currline],y
	lda	one4tbl,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[nextrline],y
	sta	[nextrline],y
fini1	lda	gval
	bmi	minus2	            
	tax
	lda	three8tbl1,x
	and	#$FF
	clc
	adc	[nextgline]
	sta	[nextgline]
	ldy	#2
	lda	three8tbl2,x
	and	#$FF
	clc
	adc	[curgline],y
	sta	[curgline],y
	lda	one4tbl,x
	and	#$FF
	clc
	adc	[nextgline],y
	sta	[nextgline],y
	bra	fini2        
minus2	eor	#$FFFF
	inc	a
	tax
	lda	three8tbl1,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[nextgline]
	sta	[nextgline]
	ldy	#2
	lda	three8tbl2,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[curgline],y
	sta	[curgline],y
	lda	one4tbl,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[nextgline],y
	sta	[nextgline],y
fini2	lda	bval
	bmi	minus3	            
	tax
	lda	three8tbl1,x
	and	#$FF
	clc
	adc	[nextbline]
	sta	[nextbline]
	ldy	#2
	lda	three8tbl2,x
	and	#$FF
	clc
	adc	[curbline],y
	sta	[curbline],y
	lda	one4tbl,x
	and	#$FF
	clc
	adc	[nextbline],y
	sta	[nextbline],y
	bra	fini3        
minus3	eor	#$FFFF
	inc	a
	tax
	lda	three8tbl1,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[nextbline]
	sta	[nextbline]
	ldy	#2
	lda	three8tbl2,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[curbline],y
	sta	[curbline],y
	lda	one4tbl,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[nextbline],y
	sta	[nextbline],y
fini3	inc	nextrline
	inc	nextrline                           
	inc	nextgline
	inc	nextgline                           
	inc	nextbline
	inc	nextbline                           
	inc	currline
	inc	currline                           
	inc	curgline
	inc	curgline                           
	inc	curbline
	inc	curbline                           
	add2	lineptr,#3,lineptr
	dec	width
	jne	xloop2

	clc
	lda	image
	adc	#4
	sta	image
	lda	pic
	adc	picwidth
	sta	pic
	lda	pic+2
	adc	#0
	sta	pic+2	
	lda	palptr
	adc	#32
	sta	palptr
	lda	paloffset
	adc	#32
	sta	paloffset
	ldy	#2
	lda	[currhand]
	sta	currline
	lda	[currhand],y
	sta	currline+2
	lda	[curghand]
	sta	curgline
	lda	[curghand],y
	sta	curgline+2
	lda	[curbhand]
	sta	curbline
	lda	[curbhand],y
	sta	curbline+2
	lda	[nextrhand]
	sta	nextrline
	lda	[nextrhand],y
	sta	nextrline+2
	lda	[nextghand]
	sta	nextgline
	lda	[nextghand],y
	sta	nextgline+2
	lda	[nextbhand]
	sta	nextbline
	lda	[nextbhand],y
	sta	nextbline+2
	inc	thermo
	lda	thermo
	jsl	UpdateThermo
	dec	height
	jne	yloop2	

	lda	#pic3200
	sta	picType

	DisposeHandle nextrhand
	DisposeHandle nextghand
	DisposeHandle nextbhand
	DisposeHandle currhand
	DisposeHandle curghand
	DisposeHandle curbhand

	jsl	CloseThermo
	InitCursor

	jmp	doView

tree	ds	2
index	ds	2
palptr	ds	4
thermo	ds	2

loadstr	dc	c'Octree Quantization w/ Error Diffusion 1 Dithering...',h'00'
                                             
	END
                  
