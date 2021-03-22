**************************************************************************
*
* ImageQuant
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* iqutil.asm
*
* ImageQuant extraneous support routines
*
**************************************************************************

	mcopy	m/iqutil.mac

;-------------------------------------------------------------------------
; AllocateImage
;    Allocate an Image
;-------------------------------------------------------------------------

AllocateImage	START

	using	Globals

lines	equ	1
size	equ	lines+2
ptr	equ	size+2
space	equ	ptr+4

	subroutine (0:dummy),space

	lda	!ImageLoaded
	beq	ok

	cop	$55	; height could be different

ok	lda	!ImageHeight
	asl	a
	pea	0
	pha
	jsl	TVMM_alloc
	sta	!ImageHandle
	pha	
	pha
	jsl	TVMM_acquire
	
	sta	<ptr
	stx	<ptr+2

	lda	!ImageHeight
	sta	<lines

	lda	!ImageWidth
	asl	a
	sta	<size	

loop	pea	0
	pei	(<size)
	jsl	TVMM_alloc
	sta	[<ptr]

	inc	<ptr
	inc	<ptr

	dec	<lines
	bne	loop

	lda	#1
	sta	!ImageLoaded

	jsl	TVMM_release

	return

	END

;-------------------------------------------------------------------------
; AllocatePal
;    Allocate an Image Palette
;-------------------------------------------------------------------------

AllocatePal	START

	using	Globals

space	equ	1

	subroutine (0:dummy),space

	lda	!ImageLoaded
	beq	done

	lda	!ImagePalSize	
	asl	a
	asl	a
	pea	0
	pha
	jsl	TVMM_alloc

	sta	!ImagePal	

done	return

	END

;-------------------------------------------------------------------------
; DisposeImage
;    Free an Image
;-------------------------------------------------------------------------
  
DisposeImage	START

	using	Globals

counter	equ	1
ptr	equ	counter+2
space	equ	ptr+4

	subroutine (0:dummy),space

	lda	!ImageLoaded
	bne	ok
	
	bra	done

ok	lda	!ImageHandle
	pha
	jsl	TVMM_acquire
	sta	<ptr
	stx	<ptr+2

               lda	!ImageHeight
	sta	<counter

loop	lda	[<ptr]
	pha
	jsl	TVMM_free
	
	clc
	lda	<ptr
	adc	#2
	sta	<ptr	

	dec	<counter
	bne	loop

	lda	!ImageHandle
	pha
	jsl	TVMM_free

	lda	!ImagePal
	pha
	jsl	TVMM_free

	stz	!ImageLoaded

done	return

	END

;-------------------------------------------------------------------------
; AllocatePic
;    Allocate a picture
;-------------------------------------------------------------------------

AllocatePic	START

	using	Globals

	lda	!PicLoaded
	beq	continue

	jsl	DisposePic

continue	lda	!ImageHeight
	sta	!PicHeight

	lda	!ImageWidth
	lsr	a
	adc	#0
	sta	!PicWidth

	Multiply (@a,PicHeight),@ax

	phx
	pha
	jsl	TVMM_alloc
	sta	!PicHandle

	lda	!PicHeight
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	pea	0
	pha
	jsl	TVMM_alloc
	sta	!PicPalHandle

	lda	!PicHeight
	pea	0
	pha
	jsl	TVMM_alloc
	sta	!PicSCBHandle

	lda	#1
	sta	!PicLoaded

               rtl

	END

;-------------------------------------------------------------------------
; AllocatePicTC
;    Allocate a picture for true color conversions.
;-------------------------------------------------------------------------

AllocatePicTC	START

	using	Globals

	lda	!PicLoaded
	beq	continue

	jsl	DisposePic

continue	lda	!ImageHeight
	asl	a
	adc	!ImageHeight
	sta	!PicHeight

	lda	!ImageWidth
	asl	a
	adc	!ImageWidth
	lsr	a
	adc	#0
	sta	!PicWidth

	Multiply (@a,PicHeight),@ax

	phx
	pha
	jsl	TVMM_alloc
	sta	!PicHandle

	pea	0
	pea	16*2*3	;true col pics only have 3 pals
	jsl	TVMM_alloc
	sta	!PicPalHandle

	lda	!PicHeight
	pea	0
	pha
	jsl	TVMM_alloc
	sta	!PicSCBHandle

	lda	#1
	sta	!PicLoaded

               rtl

	END

;-------------------------------------------------------------------------
; DisposePic
;    Dispose a picture
;-------------------------------------------------------------------------

DisposePic	START

	using	Globals

	lda	!PicLoaded
	beq	done

	stz	!PicLoaded

	lda	!PicHandle
	pha
	jsl	TVMM_free

	lda	!PicPalHandle
	pha
	jsl	TVMM_free

	lda	!PicSCBHandle
	pha
	jsl	TVMM_free

done           rtl

	END
	
;-------------------------------------------------------------------------
; ClrPic
;    Clear the picture
;-------------------------------------------------------------------------

ClrPic	START

	using	Globals

ptr	equ	1
space	equ	ptr+4

	subroutine (0:dummy),space

	lda	!PicHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<ptr
	stx	<ptr+2

	ldx	!PicHeight	
yloop	ldy	!PicWidth
	dey

	short	a
	lda	#0
xloop	sta	[<ptr],y
	dey
	bpl	xloop
	long	a

	clc
	lda	<ptr
	adc	!PicWidth
	sta	<ptr
	lda	<ptr+2
	adc	#0
	sta	<ptr+2

	dex
	bne	yloop

	jsl	TVMM_release

	return

	END

;-------------------------------------------------------------------------
; MkGrayPal
;    Make a Gray scale palette
;-------------------------------------------------------------------------

MkGrayPal	START

	using	Globals

ptr	equ	1
space	equ	ptr+4

	subroutine (0:dummy),space

	lda	!PicPalHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<ptr
	stx	<ptr+2

	ldy	#16*2-2
loop	lda	!graypal,y
	sta	[<ptr],y
	dey
	dey
	bpl	loop

	jsl	TVMM_release

	lda	#16*2
	sta	!palsize

	return

graypal	dc	i2'$000,$111,$222,$333,$444,$555,$666,$777'
	dc	i2'$888,$999,$AAA,$BBB,$CCC,$DDD,$EEE,$FFF'

	END
                                 
;-------------------------------------------------------------------------
; MkTCPal
;    Make a True Color RGB palette
;-------------------------------------------------------------------------

MkTCPal	START

	using	Globals

ptr	equ	1
space	equ	ptr+4

	subroutine (0:dummy),space

	lda	!PicPalHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<ptr
	stx	<ptr+2

	ldy	#16*2*3-2
loop	lda	!redpal,y
	sta	[<ptr],y
	dey
	dey
	bpl	loop

	jsl	TVMM_release

	lda	#16*2*3
	sta	!palsize

	return

redpal	dc	i2'$000,$100,$200,$300,$400,$500,$600,$700'
	dc	i2'$800,$900,$A00,$B00,$C00,$D00,$E00,$F00'

greenpal	dc	i2'$000,$010,$020,$030,$040,$050,$060,$070'
	dc	i2'$080,$090,$0A0,$0B0,$0C0,$0D0,$0E0,$0F0'

bluepal	dc	i2'$000,$001,$002,$003,$004,$005,$006,$007'
	dc	i2'$008,$009,$00A,$00B,$00C,$00D,$00E,$00F'

	END
                                 
;-------------------------------------------------------------------------
; Mk16SCB
;    Make a SCB table for a 16 color/BW pic
;-------------------------------------------------------------------------

Mk16SCB	START

	using	Globals

ptr	equ	1
space	equ	ptr+4

	subroutine (0:dummy),space

	lda	!PicSCBHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<ptr
	stx	<ptr+2

	ldy	!PicHeight

	short	a
	lda	#0
loop	sta	[<ptr],y
	dey
	bpl	loop
	long	a

	jsl	TVMM_release

	return

	END

;-------------------------------------------------------------------------
; MkTCSCB
;    Make a SCB table for a True Color pic
;-------------------------------------------------------------------------

MkTCSCB	START

	using	Globals

ptr	equ	1
space	equ	ptr+4

	subroutine (0:dummy),space

	lda	!PicSCBHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<ptr
	stx	<ptr+2

	ldy	!PicHeight

	short	a
loop	lda	#2
	sta	[<ptr],y
	dey
	dec	a
	sta	[<ptr],y
	dey	
	dec	a
	sta	[<ptr],y
	dey
	bpl	loop
	long	a

	jsl	TVMM_release

	return

	END

;-------------------------------------------------------------------------
; RGB2Gray
;    Convert a 24 bit RGB triple to an 8-bit gray scale
;-------------------------------------------------------------------------

RGB2Gray	START

	using	Tables

	sty	!temp+1
	stx	!rgb
	short	ai
	tay
	lda	!redtbl,x
	ldx	!rgb+1
	adc	!greentbl,x
	adc	!bluetbl,y
	long	ai
temp	ldy	#0
	rts

rgb	ds	2

	END

;-------------------------------------------------------------------------
; ExpandPal
;    Convert a GS palette to expanded RGB triples
;    X is offset in PicPal
;-------------------------------------------------------------------------

ExpandPal	START

	using	Globals

pal	equ	1
space	equ	pal+4

	subroutine (0:dummy),space

	lda	!PicPalHandle
	pha
	phx

	pha
	jsl	TVMM_acquire
	sta	<pal
	stx	<pal+2

	ply
	ldx	#0

loop	phx
	phy
	iny
	lda	[<pal],y
	and	#$0F
;	sta	!palr2,x
	Multiply (@a,#255),@ax
	UDivide (@a,#15),(@a,@x)
	ply
	plx
	sta	!palr,x
	phx
	phy
	lda   [<pal],y
	and	#$F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
;	sta	!palg2,x
	Multiply (@a,#255),@ax
	UDivide (@a,#15),(@a,@x)
	ply
	plx
	sta	!palg,x
	phx
	phy
	lda	[<pal],y
	and	#$0F
;	sta	!palb2,x
	Multiply (@a,#255),@ax
	UDivide (@a,#15),(@a,@x)
	ply
	plx
	sta	!palb,x
;	clc
;	lda	!palr2,x
;	adc	#15+1
;	sta	!palr2,x
;	lda	!palg2,x
;	adc	#15+1
;	sta	!palg2,x
;	lda	!palb2,x
;	adc	#15+1
;	sta	!palb2,x
	iny
	iny
	inx
	inx
	cpx	!palsize
	jcc	loop

	ldx	#4096-2
	lda	#$FFFF
zap	sta	!colorcache,x
	dex
	dex
	bpl	zap

	jsl	TVMM_release

	return

temp	ds	4
colorcache	ENTRY
	ds	4096

	END

;-------------------------------------------------------------------------
; FindColor
;    Find closest matching color in palette
;    RGB in x/acc on entry. color index in a on exit
;-------------------------------------------------------------------------

FindColor	START

	using	Globals
	using	tables

               sta	!rgb
	stx	!rgb+2
	short	ai
	lda	!cliptbl,x
	sta	!b+1
	ldx	!rgb+1
	lda	!cliptbl,x
	sta	!g+1
	ldx	!rgb
	lda	!cliptbl,x
;	sta	!r+1
	xba
	lda	!g+1
	asl	a
	asl	a
	asl	a
	asl	a
	ora	!b+1
	long	ai
	tay
	lda	!colorcache,y
	and	#$FF
	cmp	#16
	jcc	done
	sty	!index+1	

	lda	!rgb
	and	#$ff
	sta	!r+1
	lda	!rgb+1
	and	#$ff
	sta	!g+1
	lda	!rgb+2
	and	#$ff
	sta	!b+1

	lda	#$7FFF
	sta	!mina+1
	lda	#$FFFF
	sta	!min+1

	ldx	!palsize
	dex
	dex

loop	clc
	lda	!palr,x
	adc	#255+1
r	sbc	#0
	asl	a
	tay
	lda	!squaretbl,y
	sta	!val1+1

	lda	!palg,x
	adc	#255+1
g	sbc	#0
	asl	a
	tay
	lda	!squaretbl,y
val1	adc   #0
	sta	!val2+1
	lda	#0
	adc	#0
	sta	!val2a+1

	lda	!palb,x
	adc	#255+1
b	sbc	#0
	asl	a
	tay
	lda	!squaretbl,y
val2	adc   #0
	sta	!val2+1
	lda	#0
val2a	adc	#0

mina	cmp	#0
	beq	chk2
	bcs	next
	sta	!mina+1
	lda	!val2+1
	bra	set
chk2	lda	!val2+1
min	cmp	#0
	bcs	next
set	sta	!min+1
	stx	!idx+1
next	dex
	dex	
	bpl	loop

idx	lda	#0
	lsr	a
index	ldy	#0
	short	a
	sta	!colorcache,y
	long	a

done	rts

quickout	txa	
	lsr	a
	bra	index

;squaretbl2	dc	i2'15*15,14*14,13*13,12*12,11*11,10*10,9*9,8*8'
;	dc	i2'7*7,6*6,5*5,4*4,3*3,2*2,1*1'
;	dc	i2'0*0,1*1,2*2,3*3,4*4,5*5,6*6,7*7'
;	dc	i2'8*8,9*9,10*10,11*11,12*12,13*13,14*14,15*15'

rgb	ds	4

	END

;-------------------------------------------------------------------------
; OpenThermo
;    Open Thermometer
;-------------------------------------------------------------------------

OpenThermo	START

	using	ThermoData

space	equ	1

	subroutine (4:string,2:max),space

	ph4	#winrect
	jsl	BSI_saverect
	sta	!savehand
	stx	!savehand+2

	ph4	#winrect
	ph2	#0
	jsl	BSI_fillrect

	ph4	#winrect
	jsl	BSI_drawraisedrect

	ldx	#16
	ldy	#10
	jsl	BSI_gotoxy

	pei	(<string+2)
	pei	(<string)
	jsl	BSI_writestring

	ph4	#thermrect
	ph2	#3	;black
	jsl	BSI_drawframedrect

	ldx	#16
	ldy	#12
	jsl	BSI_gotoxy

	jsl	BSI_inverse

	lda	<max
	sta	!thermmax

	FixRatio (#47,@a),thermratio

	stz	!lasttherm

	stz	!therm
	stz	!therm+2

	return

winrect	dc	i2'16*8-6,10*8-6,64*8+4,13*8+4'
thermrect	dc	i2'16*8-2,12*8-1,64*8,13*8'

	END

;-------------------------------------------------------------------------
; CloseThermo
;    Close Thermometer
;-------------------------------------------------------------------------

CloseThermo	START

	using	ThermoData

	phb	
	phk
	plb

	lda	savehand
	ora	savehand+2
	beq	done

	ph4	savehand
	jsl	BSI_restrect

	jsl	BSI_normal

	stz	savehand
	sta	savehand+2

done	plb
	rtl

	END

;-------------------------------------------------------------------------
; AdvanceThermo
;    Advance Thermometer by "one"
;-------------------------------------------------------------------------

AdvanceThermo	START

	using	ThermoData

	phb
	phk
	plb

	clc
	lda	therm
	adc	thermratio
	sta	therm
	lda	therm+2
	adc	thermratio+2
	sta	therm+2

loop	lda	therm+2
	cmp	lasttherm
	beq	done
	lda	#' '
	jsl	BSI_writechar
	inc	lasttherm
	bra	loop

done	plb
	rtl

	END

;-------------------------------------------------------------------------
; ThermoData
;    Thermometer Data
;-------------------------------------------------------------------------

ThermoData	DATA

savehand	dc	i4'0'
lasttherm	ds	2
thermmax	ds	2
thermratio	ds	4
therm	ds	4

	END
