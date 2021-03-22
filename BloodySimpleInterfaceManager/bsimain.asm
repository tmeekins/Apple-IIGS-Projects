**************************************************************************
*
* The Bloody Simple Interface Manager v0.5
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* bsimain.asm
*
* The main routines which make up the BSI Manager
*
**************************************************************************

	mcopy	m/bsimain.mac

	copy	bsi.h

;-------------------------------------------------------------------------
;
; BSI_init
;    Initialize the BSI mananger
;
;-------------------------------------------------------------------------

BSI_init	START	bsi

	using	BSI_data
	using	BSI_private

	phb              

	phk
	plb

	TLStartup
	MMStartUp MMID
               StartUpTools (MMID,#0,#StartStop),StartStopRef

	SetColorTable (#0,#BSI_palette)

	short	a
	lda	>$E1C034
	sta	!OldBorder
	lda	#$A
	sta	>$E1C034
	long	a
;
; initialize the character drawing mechanism
;
	lda	#^BSI_Init
	xba
	and	#$FF00
	ora	#$00E1
	sta	>BSI_drawpea+1
	sta	>BSI_drawpea2+1
;
; initialize the screen address calculator
;
	GetAddress #1,temp
	lda	!temp
	sta	!BSI_lookup+1
	lda	!temp+1
	sta	!BSI_lookup+2
;
; variable initialization
;
	stz	!CH
	stz	!CV
	stz	!SHRIndex
	stz	!INVFLAG
	stz	!DIMFLAG
;
; initialize the event manager
;
	lda	#^lastevent
	sta	!EventHead+2
	sta	!EventTail+2
	lda	#lastevent
	sta	!EventHead
	sta	!EventTail

	plb
	rtl

temp	ds	4

lastevent	dc	i2'E_last'
	dc	i4'0'	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flag
	dc	i4'0'              ;key
	dc	i4'0'	;callback
	dc	i4'0'	;rectangle

	END

;-------------------------------------------------------------------------
;
; BSI_exit
;    exits the BSI mananger
;
;-------------------------------------------------------------------------

BSI_exit	START	bsi

	using	BSI_data
	using	BSI_private

	phb

	phk
	plb

	short	a
	lda	!OldBorder
	sta	>$E1C034
	lda	#01
	sta	>$E1C029
	long	a

	DisposeAll MMID

               ShutDownTools (#0,StartStopRef)
               MMShutDown MMID
               TLShutDown

	plb
	rtl

	END

;-------------------------------------------------------------------------
;
; BSI_normal
;    sets normal text drawing
;
;-------------------------------------------------------------------------

BSI_normal	START bsi

	using	BSI_data

	lda	#0
	sta	>INVFLAG
	sta	>DIMFLAG

	rtl

	END

;-------------------------------------------------------------------------
;
; BSI_inverse
;    sets inverse text drawing
;
;-------------------------------------------------------------------------

BSI_inverse	START bsi

	using	BSI_data

	lda	#$80
	sta	>INVFLAG

	rtl

	END

;-------------------------------------------------------------------------
;
; BSI_dim
;    sets dim text drawing
;
;-------------------------------------------------------------------------

BSI_dim	START bsi

	using	BSI_data

	lda	#1
	sta	>DIMFLAG

	rtl

	END

;-------------------------------------------------------------------------
;
; BSI_gotoxy
;    sets the position to draw text to
;
; Entry:
;   X: horizontal position
;   Y: vertical position
;
;-------------------------------------------------------------------------

BSI_gotoxy	START bsi

	using	BSI_data

	txa
	sta	>CH
	tya
	sta	>CV

; fall through to BSI_vtab

	END

;-------------------------------------------------------------------------
;
; BSI_vtab
;    calculate the screen addres based on CH and CV
;
;-------------------------------------------------------------------------

BSI_vtab	START bsi

	using	BSI_data
	using	BSI_private

	lda	>CV

	asl	a	;this clears carry
	tax

	lda	>SHRTable,x
	adc	>CH
	adc	>CH
	sta	>SHRindex

               rtl

	END

;-------------------------------------------------------------------------
;
; BSI_fillrect
;    fill a rectangle with a color
;    does not deal with "skinny" rectangles...they must be at least 1x5
;
; Entry:
;    stack: pointer to rectangle to fill and color
;
;-------------------------------------------------------------------------

BSI_fillrect	START	bsi

	using	BSI_tables

width	equ	1
temp	equ	width+2
colorval	equ	temp+2
height	equ	colorval+2
c1	equ	height+2
c2	equ	c1+2
x1	equ	c2+2
x2	equ	x1+2
y1	equ	x2+2
space	equ	y1+2

	subroutine (4:rect,2:color),space

	lda	<color
	asl	a
	tax
	lda	!colortbl,x
	sta	<colorval

	lda	[<rect]
	sta	<x1
	lsr	a
	lsr	a
	sta	<c1
	ldy	#2
	lda	[<rect],y
	sta	<y1
	ldy	#4
	lda	[<rect],y
	sta	<x2
	lsr	a
	lsr	a
	sta	<c2
	ldy	#6
	lda	[<rect],y
	sec
	sbc	<y1
	sta	<height
	sec
	lda	<c2
	sbc	<c1
	sta	<width
               
	HideCursor
	
	lda	<y1
	ldy	<x1
	jsr	BSI_calcaddr
	tax
	phx	
	lda	<x1
	and	#%11
	asl	a
	tay
	lda	!lefttbl,y
	and	#$FF
	and	<colorval
	sta	!c1a+1
	lda	lefttbl,y
	and	#$FF
	eor	#$FFFF
	sta	!c1b+1
	ldy	<height
leftloop	lda	>$E10000,x
c1b	and	#$FFFF
c1a	ora	#$0000
	sta	>$E10000,x
	txa
	adc	#160
	tax
	dey
               bpl	leftloop

               lda	1,s
	tax

	lda	<height
	sta	<temp

yloop	short	a
	ldy	<width
	lda	<colorval
xloop	inx
	dey
	beq	nexty
	sta	>$E10000,x	
	bra	xloop
nexty	long	a
	dec	<temp
	bmi	end
	txa
	clc
	adc	#161
               sbc	<width
	tax
               bra	yloop
end	pla
	clc
	adc	<width
	tax

	lda	<x2
	and	#%11
	asl	a
	tay
	lda	!righttbl,y
	and	#$FF
	and	<colorval
	sta	c2a+1
	lda	!righttbl,y
	and	#$FF
	eor	#$FFFF
	sta	!c2b+1
	ldy	<height
rightloop	lda	>$E10000,x
c2b	and	#$FFFF
c2a	ora	#$0000
	sta	>$E10000,x
	txa
	adc	#160
	tax
	dey
               bpl	rightloop
                         
	ShowCursor

	return

	END

;-------------------------------------------------------------------------
;
; BSI_drawframedrect
;    draw a framed rectangle
;
; Entry:
;    stack: pointer to rectangle to draw
;
;-------------------------------------------------------------------------

BSI_drawframedrect START bsi

space	equ	1

	subroutine (4:rect,2:color),space

	lda	[<rect]	;x1
	pha
	ldy	#2
	lda	[<rect],y	;y1
	pha
	ldy	#6
	lda	[<rect],y	;y2
	pha
	ph2	#2	;width
	pei	(<color)
	jsl	BSI_drawvline

	ldy	#4	
	lda	[<rect],y	;x2
	pha
	ldy	#2
	lda	[<rect],y	;y1
	pha
	ldy	#6
	lda	[<rect],y	;y2
	pha
	ph2	#2	;width
	pei	(<color)
	jsl	BSI_drawvline

	ldy	#2
	lda	[<rect],y	;y1
	pha
	lda	[<rect]	;x1
	inc	a	
	pha
	ldy	#4
	lda	[<rect],y	;x2
	dec	a
	pha
	pei	(<color)
	jsl	BSI_drawhline

	ldy	#6
	lda	[<rect],y	;y2
	pha
	lda	[<rect]	;x1
	inc	a	
	pha
	ldy	#4
	lda	[<rect],y	;x2
	dec	a
	pha
	pei	(<color)
	jsl	BSI_drawhline

	return

	END

;-------------------------------------------------------------------------
;
; BSI_saverect
;    save a rectangle of the screen in a buffer
;
; Entry:
;    stack: pointer to rectangle to save
;
; Exit:
;    xa: handle to saved rectangle
;
;-------------------------------------------------------------------------

BSI_saverect	START	bsi

	using	BSI_data

width	equ	1
height	equ	width+2
ptr	equ	height+2
c1	equ	ptr+4
c2	equ	c1+2
handle	equ	c2+2
space	equ	handle+4

	subroutine (4:rect),space

               HideCursor

	lda	[<rect]	;x1
	lsr	a
	lsr	a
	sta	<c1
	ldy	#4
	lda	[<rect],y	;x2
	lsr	a
	lsr	a
	sta	<c2

	sec
	sbc	<c1
	sta	<width
	inc	a
	tax
	sec
	ldy	#6
	lda	[<rect],y	;y2
	ldy	#2
	sbc	[<rect],y	;y1
	sta	<height
	inc	a
	Multiply (@a,@x),@ax
	clc
	adc	#8
	ldx	#0
;	NewHandle (@xa,MMID,#$C018,#0),handle
;	lda	[<handle]
;	sta	<ptr
;	ldy	#2
;	lda   [<handle],y
;	sta	<ptr+2

	pea	$C018
	phx
	pha
	jsl	TVMM_allocreal
	sta	<ptr
	stx	<ptr+2
	FindHandle @xa,@ax
	sta	<handle
	stx	<handle+2
	
	lda	<c1
	sta	[<ptr]
	ldy	#2
	lda	[<rect],y
	sta	[<ptr],y
	ldy	#4
	lda	<c2
	sta	[<ptr],y
	ldy	#6
	lda	[<rect],y
	sta	[<ptr],y

	lda	<ptr
	clc
	adc	#8
	sta	<ptr

	lda	<c1
	asl	a
	asl	a
	tax
	ldy	#2
	lda	[<rect],y	;y1
	txy
	jsr	BSI_calcaddr
	tax

yloop	ldy	<width
xloop	short	a
	lda	>$E10000,x
	sta	[<ptr]
	long	a
	inc	ptr
	inx
	dey
	bpl	xloop
	txa
	sec
	sbc	<width
	clc
	adc	#159
	tax
	dec	<height
	bpl	yloop

	ShowCursor

	return 4:handle

	END

;-------------------------------------------------------------------------
;
; BSI_restrect
;    restore a saved a rectangle
;
; Entry:
;    stack: handle of saved rectangle
;
;-------------------------------------------------------------------------

BSI_restrect	START	bsi

width	equ	1
height	equ	width+2
x1	equ	height+2
x2	equ	x1+2
y1	equ	x2+2
y2	equ	y1+2
ptr	equ	y2+2
space	equ	ptr+4

	subroutine (4:handle),space

	HideCursor

	lda	[<handle]
	sta	<ptr
	ldy	#2
	lda	[<handle],y
	sta	<ptr+2

	lda	[<ptr]
	sta	<x1
;	ldy	#2
	lda	[<ptr],y
	sta	<y1
	ldy	#4
	lda	[<ptr],y
	sta	<x2
	ldy	#6
	lda	[<ptr],y
	sta	<y2

	clc
	lda	<ptr
	adc	#8
	sta	<ptr

	sec
	lda	<x2
	sbc	<x1
	sta	<width
	sec	
	lda	<y2
	sbc	<y1
	sta	<height

	lda	<x1
	asl	a
	asl	a
	tay
	lda	<y1
	jsr	BSI_calcaddr
	tay

	lda	<ptr+2
	ora	#$E100
	xba
	sta	!move+1
	ldx	<ptr

yloop	lda	<width
move	mvn	0,0
	tya
	sec
	sbc	<width
	adc	#159-1
	tay
	dec	<height
	bpl	yloop

	DisposeHandle handle

	ShowCursor

	return   

	END

;-------------------------------------------------------------------------
;
; BSI_drawraisedrect
;    draw a raised rectangle
;
; Entry:
;    stack: pointer to rectangle to draw
;
;-------------------------------------------------------------------------

BSI_drawraisedrect START bsi

space	equ	1

	subroutine (4:rect),space

	lda	[<rect]	;x1
	pha
	ldy	#2
	lda	[<rect],y	;y1
	pha
	ldy	#6
	lda	[<rect],y	;y2
	pha
	ph2	#2	;width
	ph2	#2	;white
	jsl	BSI_drawvline

	ldy	#4	
	lda	[<rect],y	;x2
	pha
	ldy	#2
	lda	[<rect],y	;y1
	pha
	ldy	#6
	lda	[<rect],y	;y2
	pha
	ph2	#2	;width
	ph2	#3	;black
	jsl	BSI_drawvline

	ldy	#2
	lda	[<rect],y	;y1
	pha
	lda	[<rect]	;x1
	inc	a	
	pha
	ldy	#4
	lda	[<rect],y	;x2
	dec	a
	pha
	ph2	#2	;white
	jsl	BSI_drawhline

	ldy	#6
	lda	[<rect],y	;y2
	pha
	lda	[<rect]	;x1
	inc	a	
	pha
	ldy	#4
	lda	[<rect],y	;x2
	dec	a
	pha
	ph2	#3	;black
	jsl	BSI_drawhline

	return

	END

;-------------------------------------------------------------------------
;
; BSI_drawdroppedrect
;    draw a dropped rectangle
;
; Entry:
;    stack: pointer to rectangle to draw
;
;-------------------------------------------------------------------------

BSI_drawdroppedrect START bsi

space	equ	1

	subroutine (4:rect),space

	lda	[<rect]	;x1
	pha
	ldy	#2
	lda	[<rect],y	;y1
	pha
	ldy	#6
	lda	[<rect],y	;y2
	pha
	ph2	#2	;width
	ph2	#3	;black
	jsl	BSI_drawvline

	ldy	#4	
	lda	[<rect],y	;x2
	pha
	ldy	#2
	lda	[<rect],y	;y1
	pha
	ldy	#6
	lda	[<rect],y	;y2
	pha
	ph2	#2	;width
	ph2	#2	;white
	jsl	BSI_drawvline

	ldy	#2
	lda	[<rect],y	;y1
	pha
	lda	[<rect]	;x1
	inc	a	
	pha
	ldy	#4
	lda	[<rect],y	;x2
	dec	a
	pha
	ph2	#3	;black
	jsl	BSI_drawhline

	ldy	#6
	lda	[<rect],y	;y2
	pha
	lda	[<rect]	;x1
	inc	a	
	pha
	ldy	#4
	lda	[<rect],y	;x2
	dec	a
	pha
	ph2	#2	;white
	jsl	BSI_drawhline

	return

	END

;-------------------------------------------------------------------------
;
; BSI_writestring
;    draw a c string
;
; Entry:
;    stack: pointer to string to draw
;
;-------------------------------------------------------------------------

BSI_writestring START bsi

	using	BSI_data
	using	BSI_private

space	equ	1

	subroutine (4:str),space

	HideCursor

	ldy	!SHRIndex

loop	lda	[<str]
	and	#$FF
	beq	done
	jsr	BSI_drawchar
	jsr	BSI_dimchar
	inc	!CH
	inc	<str
	iny
	iny
	bra	loop

done	sty	!SHRIndex

	ShowCursor

	return

	END

;-------------------------------------------------------------------------
;
; BSI_writenstring
;    draw a c string of maximum length. Pad w/ space if less than length
;
; Entry:
;    stack: pointer to string to draw, length of max string
;
;-------------------------------------------------------------------------

BSI_writenstring START bsi

	using	BSI_data
	using	BSI_private

space	equ	1

	subroutine (4:str,2:n),space

	HideCursor

	ldy	!SHRIndex

loop	lda	[<str]
	and	#$FF
	beq	pad
	jsr	BSI_drawchar
	jsr	BSI_dimchar
	inc	!CH
	inc	<str
	iny
	iny
	dec	<n
	bne	loop
	bra	done

pad	lda	#' '
	jsr	BSI_drawchar
	jsr	BSI_dimchar
	inc	!CH
	iny
	iny
	dec	<n
	bne	pad

done	sty	!SHRIndex

	ShowCursor

	return

	END

;-------------------------------------------------------------------------
;
; BSI_writetext
;    draw a c string preceded by an x,y position
;
; Entry:
;    stack: pointer to string to draw
;
;-------------------------------------------------------------------------

BSI_writetext	START bsi

	using	BSI_data
	using	BSI_private

space	equ	1

	subroutine (4:str),space

	lda	[<str]
	and	#$FF
	inc	<str
	tax
	lda	[<str]
	and	#$FF
	inc	<str
	tay
	jsl	BSI_gotoxy

	HideCursor

	ldy	!SHRIndex

loop	lda	[<str]
	and	#$FF
	beq	done
	jsr	BSI_drawchar
	jsr	BSI_dimchar
	inc	!CH
	inc	<str
	iny
	iny
	bra	loop

done	sty	!SHRIndex

	ShowCursor

	return

	END

;-------------------------------------------------------------------------
;
; BSI_writechar
;    draw a character
;
; Entry:
;    A: character to draw
;
;-------------------------------------------------------------------------

BSI_writechar	START bsi

	using	BSI_data
	using	BSI_private

	phb

	phk
	plb

	pha
               HideCursor
	pla	

	ldy	!SHRIndex

	jsr	BSI_drawchar
	jsr	BSI_dimchar

	iny
	iny
	sty	!SHRIndex

	inc	!CH

	ShowCursor

	plb
	rtl

	END

;-------------------------------------------------------------------------
;
; BSI_drawvline
;    draw a vertical line
;
; Entry:
;    stack
;
;-------------------------------------------------------------------------

BSI_drawvline	START bsi

	using	BSI_tables

space	equ	1

	subroutine (2:x,2:y1,2:y2,2:width,2:color),space

	HideCursor

	asl	<color

	lda	<y1
	cmp	<y2
	bcc	oky
	ldx	<y1
	ldy	<y2
	sty	<y1
	stx	<y2

oky	lda	<y1
	ldy	<x
	jsr	BSI_calcaddr
	tay

	lda	<width
	dec	a
	asl	a
	tax
	jmp	(widthtbl,x)

widthtbl	dc	i2'vline1'
	dc	i2'vline2'

vline1	lda	<x
	and	#%11
	tax
	lda	!masktbl1,x
	and	#$FF
	eor	#$FFFF
	sta	!mask1+1
	lda	!masktbl1,x
	and	#$FF
	ldx	<color
	and	!colortbl,x
	sta	!color1+1

	tyx
	sec
	lda	<y2
	sbc	<y1
	tay	
	clc
loop1          lda	>$E10000,x
mask1	and	#$FFFF
color1	ora	#$0000
	sta	>$E10000,x
	txa
	adc	#160
	tax
	dey
	bpl	loop1

	bra	done

vline2	lda	<x
	and	#%11
	asl	a
	tax
	lda	!masktbl2,x
	eor	#$FFFF
	sta	!mask2+1
	lda	!masktbl2,x
	ldx	<color
	and	!colortbl,x
	sta	!color2+1

	tyx
	sec
	lda	<y2
	sbc	<y1
	tay	
	clc
loop2          lda	>$E10000,x
mask2	and	#$FFFF
color2	ora	#$0000
	sta	>$E10000,x
	txa
	adc	#160
	tax
	dey
	bpl	loop2

done	ShowCursor
	return

masktbl1	dc	i1'%11000000,%00110000,%00001100,%00000011'
masktbl2	dc	i2'%11110000,%00111100,%00001111,%1100000000000011'

	END

;-------------------------------------------------------------------------
;
; BSI_drawhline
;    draw a horizontal line
;
; Entry:
;    stack
;
;-------------------------------------------------------------------------

BSI_drawhline	START bsi

	using	BSI_Tables

m1	equ	1
m2	equ	m1+2
c1	equ	m2+2
c2	equ	c1+2
colorval	equ	c2+2
space	equ	colorval+2

	subroutine (2:y,2:x1,2:x2,2:color),space

	HideCursor

	lda	<color
	asl	a
	tax
	lda	!colortbl,x
	sta	<colorval

	lda	<x1
	cmp	<x2
	bcc	okx
	ldx	<x1
	ldy	<x2
	sty	<x1
	stx	<x2

okx	lda	<y
	ldy	<x1
	jsr	BSI_calcaddr
	tax

	lda	<x1
	and	#3
	asl	a
	tay
	lda	!lefttbl,y
	and	#$FF
	sta	<m1
	lda	<x2
	and	#3
	asl	a
	tay
	lda	!righttbl,y
	and	#$FF
	sta	<m2

	lda	<x1
	lsr	a
	lsr	a
	sta	<c1
	lda	<x2
	lsr	a
	lsr	a
	sta	<c2
	cmp	<c1
	bne	case1
;
; case 0: start and end line on the same byte
;
	lda	<m1
	and	<m2
	and	<colorval
	sta	!c0a+1
	lda	<m1
	and	<m2
	eor	#$FFFF
	and	>$E10000,x
c0a	ora	#$0000
	sta	>$E10000,x
	bra	done
;
; case 1: standard line
;
case1	sec
	lda	<c2
	sbc	<c1
	tay
	lda	<m1
	and	<colorval
	sta	!c1a+1
	lda	<m1
	eor	#$FFFF
	and	>$E10000,x
c1a	ora	#$0000
	sta	>$E10000,x
	short	a
	lda	<colorval
loop	inx
	dey
	beq	end
	sta	>$E10000,x	
	bra	loop
end	long	a
	lda	<m2
	and	<colorval
	sta	!c1b+1
	lda	<m2
	eor	#$FFFF
	and	>$E10000,x
c1b	ora	#$0000
	sta	>$E10000,x
                      
done	ShowCursor
	return

	END

;-------------------------------------------------------------------------
;
; BSI_drawchar
;    draw a character [low-level]
;
; Entry:
;    A: character to draw
;    Y: screen address
;
;-------------------------------------------------------------------------

BSI_drawchar	PRIVATE bsi

	using	BSI_data

	eor	!INVFLAG

BSI_drawpea	ENTRY
	pea	0	;this is a high-speed bank setter
	plb
	and	#$FF
	asl	a
	tax
	jmp 	(DEF_FONT,X)

	END

;-------------------------------------------------------------------------
;
; BSI_dimchar
;    dim/disable a character [low-level]
;
; Entry:
;    Y: screen address
;-------------------------------------------------------------------------

BSI_dimchar	PRIVATE bsi

	using	BSI_data

	lda	!DIMFLAG
	beq	done

BSI_drawpea2	ENTRY
	pea	0	;this is a high-speed bank setter
	plb

	lda   !$2000+0,y
	and	#%1100110011001100
	sta 	!$2000+0,y
	lda   !$2000+320,y
	and	#%1100110011001100
	sta 	!$2000+320,y
	lda   !$2000+640,y
	and	#%1100110011001100
	sta 	!$2000+640,y
	lda   !$2000+960,y
	and	#%1100110011001100
	sta 	!$2000+960,y

	lda   !$2000+160,y
	and	#%0011001100110011
	sta 	!$2000+160,y
	lda   !$2000+480,y
	and	#%0011001100110011
	sta 	!$2000+480,y
	lda   !$2000+800,y
	and	#%0011001100110011
	sta 	!$2000+800,y
	lda   !$2000+1120,y
	and	#%0011001100110011
	sta 	!$2000+1120,y

	plb

done	rts

	END

;-------------------------------------------------------------------------
;
; BSI_calcaddr
;    calculates the screen address given x & y coordinates
;
; Entry:
;    A: Y coordinate
;    Y: X coordinate
;
; Exit:
;    A: screen address offset
;
;-------------------------------------------------------------------------

BSI_calcaddr	PRIVATE bsi

	asl	a
	tax
	tya
	lsr	a
	lsr	a
	clc
BSI_lookup	ENTRY
	adc	>$FFFFFF,x
	rts

	END

;-------------------------------------------------------------------------
;
; SHRTable
;    table of screen addresses for each character line
;
;-------------------------------------------------------------------------

SHRTable	PRIVATE bsi

	dc a2'$0000'
	dc a2'$0500'
	dc a2'$0A00'
	dc a2'$0F00'
	dc a2'$1400'
	dc a2'$1900'
	dc a2'$1E00'
	dc a2'$2300'
	dc a2'$2800'
	dc a2'$2D00'
	dc a2'$3200'
	dc a2'$3700'
	dc a2'$3C00'
	dc a2'$4100'
	dc a2'$4600'
	dc a2'$4B00'
	dc a2'$5000'
	dc a2'$5500'
	dc a2'$5A00'
	dc a2'$5F00'
	dc a2'$6400'
	dc a2'$6900'
	dc a2'$6E00'
	dc a2'$7300'
	dc a2'$7800'

               END

;-------------------------------------------------------------------------
;
; BSI_private
;    private data used by BSI
;
;-------------------------------------------------------------------------

BSI_private	PRIVDATA bsi

SHRIndex	ds	2	;index into the SHR screen
OldBorder	ds	2	;old border color

StartStopRef   ds    4	;startup reference

StartStop      dc    i2'0'	;startup record
               dc    i2'$0080'
               ds    2
               ds    4
               dc    i2'2'
               dc    i2'$4,$0300'	;QuickDraw II
	dc	i2'$6,$0300'	;Event Manager

	END

;-------------------------------------------------------------------------
;
; BSI_tables
;     tables used by BSI
;
;-------------------------------------------------------------------------

BSI_tables	PRIVDATA bsi

colortbl	dc	i2'%0000000000000000,%0101010101010101'
	dc	i2'%1010101010101010,%1111111111111111'

lefttbl	dc	i2'%11111111'
	dc	i2'%00111111'
	dc	i2'%00001111'
	dc	i2'%00000011'
righttbl	dc	i2'%11000000'
	dc	i2'%11110000'
	dc	i2'%11111100'
	dc	i2'%11111111'

	END

;-------------------------------------------------------------------------
;
; BSI_data
;    data used by BSI
;
;-------------------------------------------------------------------------

BSI_data	DATA	bsi

MMID	ds	2	;Memory Manager ID
CH	ds	2	;character horizontal position
CV	ds	2	;character vertical position
INVFLAG	ds	2	;inverse flag, $80 = inverse
DIMFLAG	ds	2	;dim flag, != 0 = dim
EventHead	ds	4	;The event list
EventTail	ds	4	;The tail of the event list
EventFlag	ds	4	;Event Flag

TaskRecord     anop
What           ds    2
Message        ds    4
When           ds    4
Where          ds    4
Modifiers      ds    2

BSI_palette	dc	4i2'$AAA,$6AF,$FFF,$000'	;gray,blue,white,black

	END
