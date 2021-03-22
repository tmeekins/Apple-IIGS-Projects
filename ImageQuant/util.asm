**************************************************************************
*
* ImageQuant quantization support routines
*
**************************************************************************

	mcopy	util.mac

**************************************************************************
*
* Find closest matching color in palette
*
* RGB in x/acc on entry. color index in a on exit
*
**************************************************************************

FindColor	START

	using	Globals
	using	tables

               sta	rgb
	stx	rgb+2
	short	ai
	lda	cliptbl,x
	sta	b+1
	ldx	rgb+1
	lda	cliptbl,x
	sta	g+1
	ldx	rgb
	lda	cliptbl,x
	sta	r+1
	xba
	lda	g+1
	asl	a
	asl	a
	asl	a
	asl	a
	ora	b+1
	long	ai
	tay
	lda	colorcache,y
	and	#$FF
	cmp	#16
	bcc	done
	sty	index+1	

	lda	#$7FFF
	sta	min+1
	ldx	#15*2

loop	clc
	lda	palr2,x
	adc	#15+1
r	sbc	#0
	asl	a
	tay
	lda	squaretbl2,y
	sta	val1+1
	lda	palg2,x
	adc	#15+1
g	sbc	#0
	asl	a
	tay
	lda	squaretbl2,y
val1	adc   #0
	sta	val2+1
	lda	palb2,x
	adc	#15+1
b	sbc	#0
	asl	a
	tay
	lda	squaretbl2,y
val2	adc   #0
	beq	quickout	;exact match
min	cmp	#0
	bcs	next
	sta	min+1
	stx	idx+1
next	dex
	dex	
	bpl	loop

idx	lda	#0
	lsr	a
index	ldy	#0
	short	a
	sta	colorcache,y
	long	a

done	rts

quickout	txa	
	lsr	a
	bra	index

squaretbl2	dc	i2'15*15,14*14,13*13,12*12,11*11,10*10,9*9,8*8'
	dc	i2'7*7,6*6,5*5,4*4,3*3,2*2,1*1'
squaretbl	dc	i2'0*0,1*1,2*2,3*3,4*4,5*5,6*6,7*7'
	dc	i2'8*8,9*9,10*10,11*11,12*12,13*13,14*14,15*15'

rgb	ds	4

	END

**************************************************************************
*
* convert GS palette to expanded RGB triples
*
* X is offset in picpal
*
**************************************************************************


ExpandPal	START

	using	Globals

	lda	picpal
	sta	128
	lda	picpal+2
	sta	128+2

	txy
	ldx	#0

loop	phx
	phy
	iny
	lda	[128],y
	and	#$0F
	sta	palr2,x
	Multiply (@a,#255),@ax
	UDivide (@a,#15),(@a,@x)
	ply
	plx
	sta	palr,x
	phx
	phy
	lda   [128],y
	and	#$F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	palg2,x
	Multiply (@a,#255),@ax
	UDivide (@a,#15),(@a,@x)
	ply
	plx
	sta	palg,x
	phx
	phy
	lda	[128],y
	and	#$0F
	sta	palb2,x
	Multiply (@a,#255),@ax
	UDivide (@a,#15),(@a,@x)
	ply
	plx
	sta	palb,x
	iny
	iny
	inx
	inx
	cpx	#16*2
	jcc	loop

	ldx	#4096-2
	lda	#$FFFF
zap	sta	colorcache,x
	dex
	dex
	bpl	zap

	rts

temp	ds	4
colorcache	ENTRY
	ds	4096

	END

**************************************************************************
*
* convert a 24 bit RGB triple to an 8-bit gray scale
*
**************************************************************************

RGB2Gray	START

	using	tables

	sty	temp+1
	stx	rgb
	short	ai
	tay
	lda	redtbl,x
	ldx	rgb+1
	adc	greentbl,x
	adc	bluetbl,y
	long	ai
temp	ldy	#0
	rts

rgb	ds	2

	END

**************************************************************************
*
* Make grey palette
*
**************************************************************************

mkGrayPal	START

	using	Globals

	lda	picpal
	sta	0
	lda	picpal+2
	sta	0+2
	ldy	#16*2-2
loop	lda	graypal,y
	sta	[0],y
	dey
	dey
	bpl	loop
	rts

graypal	dc	i2'$000,$111,$222,$333,$444,$555,$666,$777'
	dc	i2'$888,$999,$AAA,$BBB,$CCC,$DDD,$EEE,$FFF'

	END
                         
