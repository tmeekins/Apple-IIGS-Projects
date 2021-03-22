**************************************************************************
*
* Gray Scale conversions
*
**************************************************************************

	mcopy	bw.mac
	copy	iq.h

ConvertBW	START

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
                                 
jmptbl	dc	i2'doPlainBW'
	dc	i2'doOrder2BW'
	dc	i2'doNothing'
	dc	i2'doFloyd1BW'
	dc	i2'doNothing'
	dc	i2'doNothing'
	dc	i2'doNothing'
	dc	i2'doNothing'
                          
dithmsg	dc	c'23/Unknown dither type/OK',h'00'

	END

**************************************************************************
*
* Gray Scale with no dithering
*
**************************************************************************

doPlainBW	START

image	equ	0
height	equ	4
offset	equ	6
lineptr	equ	8
width	equ	12
paloffset	equ	14
pic	equ	16

	using	Globals
	using	tables

	ph4	#loadstr
	ph2	ImageHeight
	jsl	OpenThermo
	stz	thermo

	WaitCursor

	jsr	DisposePic
	jsr	AllocatePic
	jsr	clrPic
	jsr	mkGrayPal

	mv4	ImagePtr,image
	mv4	picbuf,pic
	lda	ImageHeight
	sta	height
yloop	stz	offset
	lda	[image]
	sta	lineptr
	ldy	#2
	lda	[image],y
	sta	lineptr+2

	lda	ImageWidth
	sta	width
	
	ldy	#0
	clc
xloop	lda	[lineptr],y
	tax
	iny
	iny
	lda	[lineptr],y
	iny
	sty	temp1+1
	stx	paloffset
	short	ai
	tay
	lda	redtbl,x
	ldx	paloffset+1
	adc	greentbl,x
	adc	bluetbl,y
	long	ai
	and	#$F0
	ldy	offset
	ora	[pic],y
	sta	[pic],y
temp1	ldy	#0
	dec	width
	beq	nexty
	lda	[lineptr],y
	tax
	iny
	iny
	lda	[lineptr],y	
	iny
	sty	temp2+1
	stx	paloffset
	short	ai
	tay
	lda	redtbl,x
	ldx	paloffset+1
	adc	greentbl,x
	adc	bluetbl,y
	long	ai
	and	#$F0 
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	ldy	offset
	ora	[pic],y
	sta	[pic],y
temp2	ldy	#0
	inc	offset
	dec	width
	bne	xloop

nexty	clc
	lda	image
	adc	#4
	sta	image

	clc
	lda	pic
	adc	picwidth
	sta	pic
	lda	pic+2
	adc	#0
	sta	pic+2

	inc	thermo
	lda	thermo
	jsl	UpdateThermo

	dec	height
	jne	yloop	

	lda	#pic16
	sta	picType

	jsl	CloseThermo
	InitCursor

	jmp	doView

thermo	ds	2

loadstr	dc	c'Gray Scale Conversion w/o Dithering...',h'00'

	END

**************************************************************************
*
* Gray Scale with Order 2 dithering
*
**************************************************************************

doOrder2BW	START

	using	Globals

image	equ	0
height	equ	4
offset	equ	6
lineptr	equ	8
width	equ	12
value	equ	14
dithoffset	equ	16
pic	equ	28

	WaitCursor

	ph4	#loadstr
	ph2	ImageHeight
	jsl	OpenThermo
	stz	thermo

	jsr	DisposePic
	jsr	AllocatePic
	jsr	clrPic                
	jsr	mkGrayPal

	lda	picbuf
	sta	pic
	lda	picbuf+2
	sta	pic+2
	stz	dithoffset
	mv4	ImagePtr,image
	lda	ImageHeight
	sta	height
yloop	stz	offset
	lda	[image]
	sta	lineptr
	ldy	#2
	lda	[image],y
	sta	lineptr+2

	lda	ImageWidth
	sta	width

	clc

	ldy	#0
xloop	lda	[lineptr],y
	tax
	iny
	iny
	lda	[lineptr],y
	iny
	jsr	RGB2Gray
	tax
	and	#$F0
	sta	value
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	dithoffset
	cmp	dithtbl,x
	bcc	bw03
	lda	value
	clc
	adc	#$10
	bra	bw03a
bw03	lda	value
bw03a	tyx
	ldy	offset
	ora	[pic],y
	sta	[pic],y
	txy
	dec	width
	beq	nexty
	lda	[lineptr],y
	tax
	iny
	iny
	lda	[lineptr],y
	iny
	jsr	RGB2Gray
	tax
	and	#$F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	value
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	dithoffset
	cmp	dithtbl+2,x
	bcc	bw04
               inc	value
	clc
bw04	lda	value
	tyx
	ldy	offset
	ora	[pic],y
	sta	[pic],y
	txy
	inc	offset
	dec	width
	jne	xloop

nexty	clc
	lda	image
	adc	#4
	sta	image

	lda	pic
	adc	picwidth
	sta	pic
	lda	pic+2
	adc	#0
	sta	pic+2

	lda	dithoffset
	adc	#4
	and	#8-1
	sta	dithoffset

	inc	thermo
	lda	thermo
	jsl	UpdateThermo

	dec	height                     
	jne	yloop	

	lda	#pic16
	sta	picType

	jsl	CloseThermo
	InitCursor

	jmp	doView

dithtbl	dc	i2'1,3,4,2'

thermo	ds	2

loadstr	dc	c'Gray Scale Conversion w/ Ordered-2 Dithering...',h'00'

	END

**************************************************************************
*
* Gray Scale with no floyd-steinberg dithering
*
**************************************************************************

doFloyd1BW	START

	using	Globals
	using	Tables

image	equ	0
height	equ	4
offset	equ	6
lineptr	equ	8
width	equ	12
curhand	equ	14
curline	equ	18
nexthand	equ	22
nextline	equ	26
value	equ	30
actual	equ	32
pic	equ	34

	WaitCursor

	ph4	#loadstr
	ph2	ImageHeight
	jsl	OpenThermo
	stz	thermo

	jsr	DisposePic
	jsr	AllocatePic
	jsr	clrPic            
	jsr	mkGrayPal

	lda	ImageWidth
	inc	a
	asl	a
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),curhand
	lda	[curhand]
	sta	curline
	ldy	#2
	lda	[curhand],y
	sta	curline+2
	
	lda	ImageWidth
	inc	a
	asl	a
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),nexthand
	lda	[nexthand]
	sta	nextline
	ldy	#2
	lda	[nexthand],y
	sta	nextline+2

	lda	ImageWidth
	asl	a
	tay
	lda	#0
clear	sta	[nextline],y
	dey
	dey
	bpl	clear

	lda	picbuf
	sta	pic
	lda	picbuf+2
	sta	pic+2
	mv4	ImagePtr,image
	lda	ImageHeight
	sta	height
yloop	stz	offset
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
copy	lda	[nextline],y
	sta	[curline],y
	lda	#0
	sta	[nextline],y
	dey
	dey
	bpl	copy

xloop	ldy	#2
	lda	[lineptr]
	tax
	lda	[lineptr],y
	jsr	RGB2Gray
	and	#$FF
	clc
	adc	[curline]
	bpl	clip0
	lda	#0
	bra	clip1
clip0	cmp	#$100
	bcc	clip1
	lda	#$FF
clip1	sta	actual
	clc
	adc	#8	;round up if >.5
	cmp	#$100
	bcc	clip2
	lda	#$FF
clip2	and	#$F0
	sta	value
               sec
	lda	actual
	sbc	value
	bmi	minus1
	tax
	lda	three8tbl1,x
	and	#$FF
	clc
	adc	[nextline]
	sta	[nextline]
	ldy	#2
	lda	three8tbl2,x
	and	#$FF
	clc
	adc	[curline],y
	sta	[curline],y
	lda	one4tbl,x
	and	#$FF
	clc
	adc	[nextline],y
	sta	[nextline],y
	bra	fini1        
minus1	eor	#$FFFF
	inc	a
	tax
	lda	three8tbl1,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[nextline]
	sta	[nextline]
	ldy	#2
	lda	three8tbl2,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[curline],y
	sta	[curline],y
	lda	one4tbl,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[nextline],y
	sta	[nextline],y

fini1	inc	nextline
	inc	nextline
	inc	curline	
	inc	curline

	lda	value
	ldy	offset
	ora	[pic],y
	sta	[pic],y
	add2	lineptr,#3,lineptr
	dec	width
	jeq	nexty
	ldy	#2
	lda	[lineptr]
	tax
	lda	[lineptr],y
	jsr	RGB2Gray
	and	#$FF
	clc
	adc	[curline]
	bpl	clip5
	lda	#0
	bra	clip3
clip5	cmp	#$100
	bcc	clip3
	lda	#$FF
clip3	sta	actual
	clc
	adc	#8	;round up if >.5
	cmp	#$100
	bcc	clip4
	lda	#$FF
clip4	and	#$F0
	sta	value
               sec
	lda	actual
	sbc	value
	bmi	minus2
	tax
	clc
	lda	three8tbl1,x
	and	#$FF
	adc	[nextline]
	sta	[nextline]
	ldy	#2
	lda	three8tbl2,x
	and	#$FF
	adc	[curline],y
	sta	[curline],y
	lda	one4tbl,x
	and	#$FF
	adc	[nextline],y
	sta	[nextline],y
	bra	fini2        
minus2	eor	#$FFFF
	inc	a
	tax
	clc
	lda	three8tbl1,x
	and	#$FF
	eor	#$FFFF
	inc	a
	adc	[nextline]
	sta	[nextline]
	ldy	#2
	lda	three8tbl2,x
	and	#$FF
	eor	#$FFFF
	inc	a
	adc	[curline],y
	sta	[curline],y
	lda	one4tbl,x
	and	#$FF
	eor	#$FFFF
	inc	a
	adc	[nextline],y
	sta	[nextline],y

fini2	inc	nextline
	inc	nextline
	inc	curline	
	inc	curline

	lda	value
	and	#$F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	ldy	offset
	ora	[pic],y
	sta	[pic],y
	clc
	lda	lineptr
	adc	#3
	sta	lineptr
	inc	offset
	dec	width
	jne	xloop

nexty	clc
	lda	image
	adc	#4
	sta	image
	lda	pic
	adc	picwidth
	sta	pic
	lda	pic+2
	adc	#0
	sta	pic+2
	lda	[curhand]
	sta	curline
	ldy	#2
	lda	[curhand],y
	sta	curline+2
	lda	[nexthand]
	sta	nextline
	lda	[nexthand],y
	sta	nextline+2
	inc	thermo
	lda	thermo
	jsl	UpdateThermo
	dec	height            
	jne	yloop	

	lda	#pic16
	sta	picType

	DisposeHandle CurHand
	DisposeHandle NextHand

	jsl	CloseThermo
	InitCursor              

	jmp	doView

thermo	ds	2

loadstr	dc	c'Gray Scale Conversion w/ Error Diffusion 1 Dithering...',h'00'

	END                     
