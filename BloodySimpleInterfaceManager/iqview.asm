**************************************************************************
*
* ImageQuant
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* iqview.asm
*
* ImageQuant viewing routines
*
**************************************************************************

	mcopy	m/iqview.mac

;-------------------------------------------------------------------------
; View320
;    View a 16/256 color pic
;-------------------------------------------------------------------------

View320        START

	using	Globals
	using BSI_data

scboff	equ	1
scbptr	equ	scboff+2
scb	equ	scbptr+4
pal	equ	scb+4
picbuf	equ	pal+4
movef	equ	picbuf+4
mouse	equ	movef+2
height	equ	mouse+2
scrnheight	equ	height+2
mvnlen	equ	scrnheight+2
ypos	equ	mvnlen+2
xpos	equ	ypos+2
border	equ	xpos+2
addr	equ	border+2
scrn	equ	addr+4
space	equ	scrn+4

	subroutine (0:dummy),space

	lda	!PicHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<picbuf
	stx	<picbuf+2

	lda	!PicSCBHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<scb
	stx	<scb+2

	ph4	#saverect
	jsl	BSI_saverect
	sta	!savehand
	stx	!savehand+2

	short	a
	lda	>$E1C034
	sta	<border
	lda	#0
	sta	>$E1C034
	long	a

	ldx	#320*200/2-2
	lda	#0
clear	sta	>$E12000,x
	dex
	dex
	bpl	clear

	lda	!PicPalHandle
	pha
	pha
	jsl	TVMM_acquire

	sta	<pal
	stx	<pal+2

	ldy	#16*16*2-2
	tyx
copypal	lda	[<pal],y
	sta	>$E19E00,x
	dex
	dex
	dey
	dey
	bpl	copypal

	jsl	TVMM_release

	stz	<xpos
	stz	<ypos

	lda	!PicWidth
	cmp	#160
	bcc	v1
	lda	#160
v1	dec	a
	sta	<mvnlen

	lda	!PicHeight
	cmp	#200
	bcc	v2
	lda	#200
v2	dec	a
	sta	<scrnheight

	GetMouseClamp (oymax,oymin,oxmax,oxmin)
	
	sec
	lda	!PicWidth
	sbc	#160
	bcs	v3
	lda	#0
v3	tax
	sec
	lda	!PicHeight
	sbc	#200
	bcs	v4
	lda	#0
v4	ClampMouse (#0,@x,#0,@a)

	stz	<mouse
loop	jsr	show
loop2	ReadMouse (@a,@y,@x)
	stz	<movef
	cpx	<xpos
	bne	domove
	cpy	<ypos
	beq	nomove
domove	inc	<movef
nomove	stx	<xpos
	sty	<ypos
	xba
	bit	#%10000000
	beq	notdown
	ldx	#1
	stx	<mouse
	bra	continue
notdown        ldx	<mouse
	bne	done
continue	lda	<movef
	bne	loop
	bra	loop2

done           ClampMouse (oxmin,oxmax,oymin,oymax)

	jsl	TVMM_release
	jsl	TVMM_release	

	short	a
	lda	<border
	sta	>$E1C034
	long	a
	SetColorTable (#0,#black)
               GetMasterSCB @a
               SetAllSCBs @a
	ph4	savehand
	jsl	BSI_restrect
	SetColorTable (#0,#BSI_palette)

               return

show	anop

	lda	<ypos
	clc
	adc	<scb
	sta	<scbptr
	lda	<scb+2
	sta	<scbptr+2

	stz	<scboff

	Multiply (ypos,PicWidth),@ax
	clc
	adc	<xpos
	bcc	show1
	inx
	clc
show1	adc	<picbuf
	sta	<addr
	txa
	adc	<picbuf+2
	sta	<addr+2

	lda	#$2000
	sta	<scrn
	lda	<scrnheight
	sta	<height

	lda	<addr+2
	ora	#$E100
	xba
	sta	!move+1

	clc

yloop	lda	<addr
               adc	!PicWidth
	bcs	crossbank
	ldy	<scrn
	ldx	<addr
	lda	mvnlen
move	mvn	0,0
	bra	next
crossbank      ldy	mvnlen
	pea	$E1E1
	plb
	plb
	short	a
bkcpy	lda	[<addr],y
	sta	(<scrn),y
	dey
	bpl	bkcpy
	phk
	plb
	inc	<addr+2
	inc	!move+2
	rep	#$21
	longa	on
	bra	next2
next	phk
	plb
next2	lda	<addr
	adc	!PicWidth
	sta	<addr
	clc
	lda	<scrn
	adc	#160
	sta	<scrn
	short	a
	lda	[<scbptr]
	ldx	<scboff
	sta	>$E19D00,x
	long	a
	inc	<scbptr
	inc	<scboff
	dec	<height
	bpl	yloop

	rts

oxmin	ds	2
oxmax          ds	2
oymin          ds	2
oymax          ds	2
saverect	dc	i2'0,0,639,199'
savehand	ds	4
black	dc	16i2'0'

               END

;-------------------------------------------------------------------------
; View3200
;    View a 3200 picture
;-------------------------------------------------------------------------

View3200       START

	using	Globals
	using BSI_data

VERTCNT	equ	$E1C02E

height	equ	1
picbuf	equ	height+2
palptr	equ	picbuf+4
movef	equ	palptr+4
mouse	equ	movef+2
scrnheight	equ	mouse+2
mvnlen	equ	scrnheight+2
ypos	equ	mvnlen+2
xpos	equ	ypos+2
border	equ	xpos+2
addr	equ	border+2
scrn	equ	addr+4
space	equ	scrn+4

	subroutine (0:dummy),space

	ph4	#saverect
	jsl	BSI_saverect
	sta	!savehand
	stx	!savehand+2

	lda	!Pichandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<picbuf
	stx	<picbuf+2

	short	a       
	lda	>$E1C034
	sta	<border
	lda	#0
	sta	>$E1C034
	long	a

	lda	#0
	ldx	#160*200-2
blaken	sta	>$E12000,x
	dex
	dex
	bpl	blaken

	stz	<xpos
	stz	<ypos

	lda	!PicWidth
	cmp	#160
	bcc	v1
	lda	#160
v1	dec	a
	sta	<mvnlen

	lda	!PicHeight
	cmp	#200
	bcc	v2
	lda	#200
v2	dec	a
	sta	<scrnheight

	GetMouseClamp (oymax,oymin,oxmax,oxmin)
	
	sec
	lda	!PicWidth
	sbc	#160
	bcs	v3
	lda	#0
v3	tax
	sec
	lda	!PicHeight
	sbc	#200
	bcs	v4
	lda	#0
v4	ClampMouse (#0,@x,#0,@a)

	stz	<mouse

	lda	>$E1C035
	sta	!OldShadow
	ora	#$08
	sta	>$E1C035

	GetIRQEnable IRQEnable

	ldx	#0
nextdis	lda	!IRQEnable
	and	!masks,x
	beq	skip
	lda	!disables,x
	phx
	IntSource @a
	plx
skip	inx
	inx
	cpx	#14
	bne	nextdis

	short	a

	lda	#$F
	ldx	#0
nextSCB	sta	>$E19D00,x
	dec	a
	and	#$F
	inx
	cpx	#200
	bne	nextSCB

	long	a

	lda	!PicPalHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<palptr
	stx	<palptr+2

loop	jsr	show
	
	lda	<ypos
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#6400-2
	tay
	ldx	#6400-2
palloop	lda	[<palptr],y
	sta	>$012000,x
	dey
	dey
	dex
	dex
	bpl	palloop

loop2	php
	sei
	phd
	long	a
	tsc
	sta	!oldstack
	short	a
	lda	>$E1C035
	and	#$F7
	sta	>$E1C035
	lda	>$E1C068
	sta	!oldauxreg
               ora	#$30
	sta	>$E1C068

	copy	G3200.A.asm

	lda	>$E1C035
	ora	#$08
	sta	>$E1C035
	lda	>$E1C068
	and	#$CF
	sta	>$E1C068
	long	a
	lda	!oldstack
	tcs
	pld
	plp

	short	a
	lda	!oldauxreg
	sta	>$E1C068
	long	a

	ReadMouse (@a,@y,@x)
	stz	<movef
	cpx	<xpos
	bne	domove
	cpy	<ypos
	beq	nomove
domove	inc	<movef
nomove	stx	<xpos
	sty	<ypos
	xba
	bit	#%10000000
	beq	notdown
	ldx	#1
	stx	<mouse
	bra	continue
notdown        ldx	<mouse
	bne	done
continue	lda	<movef
	jne	loop
	jmp	loop2

done           ClampMouse (oxmin,oxmax,oymin,oymax)
                   
	ldx	#0
nextenable	lda	!IRQEnable
	and	!masks,x
	beq	skip1
	lda	!enables,x
	phx
	IntSource @a
	plx
skip1	inx
	inx
	cpx	#14
	bne	nextenable

	short	a

	lda	!oldauxreg
	sta	>$E1C068
	lda	!OldShadow
	sta	>$E1C035

	lda	<border
	sta	>$E1C034

	long	a

	jsl	TVMM_release
	jsl	TVMM_release

	SetColorTable (#0,#black)
               GetMasterSCB @a
               SetAllSCBs @a
	ph4	savehand
	jsl	BSI_restrect
	SetColorTable (#0,#BSI_palette)

               return

show	Multiply (ypos,PicWidth),@ax
	clc
	adc	<xpos
	bcc	show1
	inx
	clc
show1	adc	<picbuf
	sta	<addr
	txa
	adc	<picbuf+2
	sta	<addr+2

	lda	#$2000
	sta	<scrn
	lda	<scrnheight
	sta	<height

yloop	clc
	lda	<addr
               adc	!PicWidth
	bcs	crossbank
	lda	<addr+2
	ora	#$E100
	xba
	sta	!move+1
	ldy	<scrn
	ldx	<addr
	lda	<mvnlen
move	mvn	0,0
	bra	next
crossbank	ldy	mvnlen
	pea	$E1E1
	plb
	plb
	short	a
bkcpy	lda	[<addr],y
	sta	(<scrn),y
	dey
	bpl	bkcpy
	long	a
next	phk
	plb
	clc
	lda	<addr
	adc	!PicWidth
	sta	<addr
	lda	<addr+2
	adc	#0
	sta	<addr+2
	lda	<scrn
	adc	#160
	sta	<scrn
	dec	<height
	bpl	yloop

	rts

masks	dc	i'1,2,4,16,32,64,128'
enables	dc	i'14,12,10,6,4,2,0'
disables	dc	i'15,13,11,7,5,3,1'

oxmin	ds	2
oxmax          ds	2
oymin          ds	2
oymax          ds	2
OldShadow	ds	2
IRQEnable	ds	2
oldstack	ds	2
oldauxreg	ds	2
saverect	dc	i2'0,0,639,199'
savehand	ds	4
black	dc	16i2'0'
                  
               END
