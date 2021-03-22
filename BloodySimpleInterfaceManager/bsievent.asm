**************************************************************************
*
* The Bloody Simple Interface Manager
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* bsievent.asm
*
* Event and related code
*
**************************************************************************

	mcopy	m/bsievent.mac

	copy	bsi.h

;-------------------------------------------------------------------------
;
; BSI_event
;     The entire BSI event loop
;
;-------------------------------------------------------------------------

BSI_event	START	bsi

	using	BSI_data

k	equ	1
p	equ	k+4
key	equ	p+4
space	equ	key+2

	subroutine (0:dummy),space

	stz	!EventFlag 	; don't break out of event

mainloop	lda	!EventFlag
	bne	break

               GetNextEvent (#$FFFF,#TaskRecord),@x

               lda   !what
	cmp	#3	; keydown
	beq	doKey
	cmp	#5	; autokey
	beq	doKey
	cmp	#1	; mousedown
	jeq	doMouse
	cmp	#$A	; desk accessory
	beq	deskacc

        	bra	mainloop

; break out of event loop

break	return

; desk accessory

deskacc	short	a
	lda	#$A
	sta	>$E1C034
	long	a

	bra	mainloop
       
; handle keypresses

doKey	lda   !Modifiers
               and   #%0000000100000000
	lsr	a
               ora   !Message
	and	#$ff
	sta	<key

               lda	!EventHead
	sta	<p
	lda	!EventHead+2
	sta	<p+2

keyloop	ldy	#o_flag
	lda	[<p],y
	bit	#F_disabled
	bne	keynext

	ldy	#o_key
               lda   [<p],y
	sta	<k
	ldy	#o_key+2
	lda	[<p],y
	sta	<k+2
	ora	<k
	beq	keynext

	ldy	#-1
keyloop2	iny
	lda	[<k],y
	and	#$ff
	beq	keynext
	cmp	<key
               bne	keyloop2

	pei	(<p+2)
	pei	(<p)
	pea	A_key
	jsl	BSI_docallback

	jmp	mainloop

keynext        ldy	#o_type
	lda	[<p],y
	tax
	jsr	(keytbl,x)
	jne	mainloop
	ldy	#o_flag
	lda	[<p],y
	bit	#F_blockevent
	beq	keycont
       	jmp	mainloop
keycont	ldy	#o_next
               lda   [<p],y
	tax
	ldy	#o_next+2
	lda	[<p],y
	sta	<p+2
	stx	<p
	ora	<p
	bne	keyloop
	jmp	mainloop

; handle MouseDown

doMouse        lda	!EventHead
	sta	<p
	lda	!EventHead+2
	sta	<p+2

mouseloop	ldy	#o_flag
	lda	[<p],y
	bit	#F_disabled
	bne	mousenext

	pei	(<p+2)
	pei	(<p)
	jsl	BSI_mouseinrect
	beq	mousenext

	pei	(<p+2)
	pei	(<p)
	jsl	BSI_trackmousedn

	jmp	mainloop

mousenext	ldy	#o_flag
	lda	[<p],y
	bit	#F_blockevent
	beq	mousecont
       	jmp	mainloop
mousecont	ldy	#o_next
               lda   [<p],y
	tax
	ldy	#o_next+2
	lda	[<p],y
	sta	<p+2
	stx	<p
	ora	<p
	bne	mouseloop
	jmp	mainloop

; events with special keyboard control

keytbl	dc	i2'nokey'	;E_last
	dc	i2'nokey'	;E_button
	dc	i2'nokey'	;E_window
	dc	i2'nokey'	;E_popup
	dc	i2'keylist'	;E_list

keylist	lda	<key
	cmp	#$0B	;up-arrow
	beq	kl0
	cmp	#$0A	;down-arrow
	beq	kl0
nokey	lda	#0
	rts

kl0	pei	(<p+2)
	pei	(<p)
	pei	(<key)
	jsl	BSI_listkey
	lda	#1
	rts

	END

;-------------------------------------------------------------------------
;
; BSI_break
;     Break out of the event loop
;
;-------------------------------------------------------------------------

BSI_break	START	bsi

	using	BSI_data

	lda	#1
	sta	>EventFlag

	rtl

	END

;-------------------------------------------------------------------------
;
; BSI_addevent
;     add a new event to the event structure
;
;-------------------------------------------------------------------------

BSI_addevent	START	bsi

	using	BSI_data

p	equ	1
space	equ	p+4

	subroutine (4:event),space

               lda	!EventHead
	sta	<p
	lda	!EventHead+2
	sta	<p+2

	ldy	#o_prev
	lda	<event
	sta	[<p],y
	lda	#0
	sta	[<event],y
	ldy	#o_prev+2
	lda	<event+2
	sta	[<p],y
	lda	#0
	sta	[<event],y

	ldy	#o_next
	lda	<p
	sta	[<event],y
	ldy	#o_next+2
	lda	<p+2
	sta	[<event],y
	
	lda	<event
	sta	!EventHead
	lda	<event+2
	sta	!EventHead+2

	ldy	#o_type
	lda	[<event],y
	tax
	jmp	(addtbl,x)

addtbl	dc	i2'done'	;E_last
	dc	i2'done'	;E_button
	dc	i2'initwindow'	;E_window
	dc	i2'done'	;E_popup
	dc	i2'done'	;E_list
;
; initialize a window
;
initwindow	ldy	#o_rect+2
	lda	[<event],y
	pha
	ldy	#o_rect
	lda	[<event],y
	pha
	jsl	BSI_saverect

	ldy	#owin_save
	sta	[<event],y
	ldy	#owin_save+2
	txa
	sta	[<event],y

	bra	done

done	pei	(<event+2)
	pei	(<event)
	jsl	BSI_drawevent

	return

	END

;-------------------------------------------------------------------------
;
; BSI_deleteevent
;     delete an event (deletes every event until the designated event is found)
;
;-------------------------------------------------------------------------

BSI_deleteevent START bsi

	using	BSI_data

p	equ	1
space	equ	p+4

	subroutine (4:event),space

loop	lda	<event
	cmp	!EventHead
	bne	next
	lda	<event+2
	cmp	!EventHead+2
	beq	last

next	jsr	popevent
	bra	loop

last	jsr	popevent

	lda	!EventHead
	sta	<p
	lda	!EventHead+2
	sta	<p+2

	ldy	#o_prev
	lda	#0
	sta	[<p],y
	ldy	#o_prev+2
	sta	[<p],y

	return
;
; delete the top event from the event list
;
popevent	lda	!EventHead
	sta	<p
	lda	!EventHead+2
	sta	<p+2

	ldy	#o_next
	lda	[<p],y
	sta	!EventHead
	ldy	#o_next+2
	lda	[<p],y
	sta	!EventHead+2

	ldy	#o_type
	lda	[<p],y
	tax
	jmp	(poptbl,x)

poptbl	dc	i2'popdone'	;E_last
	dc	i2'popdone'	;E_button
	dc	i2'popwindow'	;E_window
	dc	i2'popdone'	;E_popup
	dc	i2'popdone'	;E_list

popdone	rts
;
; pop a window
;
popwindow	ldy	#owin_save+2
	lda	[<p],y
	pha
	ldy	#owin_save
	lda	[<p],y
	pha
	jsl   BSI_restrect
	rts

	END

;-------------------------------------------------------------------------
;
; BSI_disableevent
;     disable an event
;
;-------------------------------------------------------------------------

BSI_disableevent START bsi

	using	BSI_data

space	equ	1

	subroutine (4:event),space

	ldy	#o_flag
	lda	[<event],y
	ora	#F_disabled
	sta	[<event],y

	pei	(<event+2)
	pei	(<event)
	jsl	BSI_drawevent

	return	

	END

;-------------------------------------------------------------------------
;
; BSI_enableevent
;     enable an event
;
;-------------------------------------------------------------------------

BSI_enableevent START bsi

	using	BSI_data

space	equ	1

	subroutine (4:event),space

	ldy	#o_flag
	lda	[<event],y
	and	#(0-F_disabled)-1	; should mimic an inversion: ~F_disable
	sta	[<event],y

	pei	(<event+2)
	pei	(<event)
	jsl	BSI_drawevent

	return	

	END

;-------------------------------------------------------------------------
;
; BSI_enablepopup
;     enable a pop-up menu item
;
;-------------------------------------------------------------------------

BSI_enablepopup START bsi

	using	BSI_data

p	equ	1
list	equ	p+4
space	equ	list+4

	subroutine (4:event,2:item),space

	ldy	#opop_list
	lda	[<event],y
	sta	<list
	ldy	#opop_list+2
	lda	[<event],y
	sta	<list+2

	lda	<item
	asl	a
	asl	a
	tay
	lda	[<list],y
	sta	<p
	iny
	iny
	lda	[<list],y
	sta	<p+2

	lda	[<p]
	and	#(0-F_disabled)-1	; should mimic an inversion: ~F_disable
	sta	[<p]	

	pei	(<event+2)
	pei	(<event)
	jsl	BSI_drawevent

	return    

	END

;-------------------------------------------------------------------------
;
; BSI_disablepopup
;     disable a pop-up menu item
;
;-------------------------------------------------------------------------

BSI_disablepopup START bsi

	using	BSI_data

p	equ	1
list	equ	p+4
space	equ	list+4

	subroutine (4:event,2:item),space

	ldy	#opop_list
	lda	[<event],y
	sta	<list
	ldy	#opop_list+2
	lda	[<event],y
	sta	<list+2

	lda	<item
	asl	a
	asl	a
	tay
	lda	[<list],y
	sta	<p
	iny
	iny
	lda	[<list],y
	sta	<p+2

	lda	[<p]
	ora	#F_disabled
	sta	[<p]	

	ldy	#opop_select
	lda	[<event],y
	cmp	<item
	bne	ok

; eek, we just disabled the current item, let's change the selected
; item to something different.

	stz	<item
loop	lda	[<list]
	sta	<p
	ldy	#2
	lda	[<list],y
	sta	<p+2
	
	lda	[<p]
	bit	#F_disabled
	beq	found

	inc	<item
	ldy	#opop_items
	lda	[<event],y
	cmp	<item
	beq	ok	; no enabled items, give up

	clc
	lda	<list
	adc	#4
	sta	<list
	
	bra	loop

found          lda	<item
	ldy	#opop_select
	sta	[<event],y

ok	pei	(<event+2)
	pei	(<event)
	jsl	BSI_drawevent

	return    

	END

;-------------------------------------------------------------------------
;
; BSI_drawevent
;     draw an event
;
;-------------------------------------------------------------------------

BSI_drawevent	START	bsi

r	equ	1
p	equ	r+4
space	equ	p+4

	subroutine (4:event),space

	ldy	#o_type
	lda	[<event],y
	tax
	jmp	(drawtbl,x)

drawtbl	dc	i2'done'	;E_last
	dc	i2'drawbutton'	;E_button
	dc	i2'drawwindow'	;E_window
	dc	i2'drawpopup'	;E_popup
	dc	i2'drawlist'	;E_list
;
; draw a simple button
;
drawbutton	ldy	#o_rect+2
	lda	[<event],y
	pha
	ldy	#o_rect
	lda	[<event],y
	pha
	jsl	BSI_drawraisedrect

	ldy	#o_flag
	lda	[<event],y
	bit	#F_disabled
	beq	db1

	jsl	BSI_dim

db1	ldy	#obut_text+2
	lda	[<event],y
	pha
	ldy	#obut_text
	lda	[<event],y
	pha
	jsl	BSI_writetext

               jsl	BSI_normal
	
	jmp	done
;
; draw a window
;
drawwindow	ldy	#o_rect+2
	lda	[<event],y
	pha
	ldy	#o_rect
	lda	[<event],y
	pha
	ph2	#0
	jsl	BSI_fillrect

	ldy	#o_rect+2
	lda	[<event],y
	pha
	ldy	#o_rect
	lda	[<event],y
	pha
	jsl	BSI_drawraisedrect

	jmp	done
;
; draw a pop-up menu
;
drawpopup	ldy	#o_rect+2
	lda	[<event],y
	pha
	ldy	#o_rect
	lda	[<event],y
	pha
	jsl	BSI_drawdroppedrect

	ldy	#opop_pos
	lda	[<event],y
	and	#$FF
	tax
	iny
	lda	[<event],y
	and	#$FF
	tay
	jsl	BSI_gotoxy

	ldy	#opop_select
	lda	[<event],y
	asl	a
	asl	a
	ldy	#opop_list
	adc	[<event],y
	sta	<p
	lda	#0
	ldy	#opop_list+2
               adc	[<event],y
	sta	<p+2	

	ldy	#2
	lda	[<p],y
	sta	<r+2
	pha
	lda	[<p]
	sta	<r
	inc	a
	pha
	lda	[<r]
	bit	#F_disabled
	beq	nodis
	jsl	BSI_dim
nodis	ldy	#opop_width
	lda	[<event],y
	inc	a
	pha
	jsl	BSI_writenstring

	jsl	BSI_normal

	bra	done
;
; draw a list
;
drawlist	ldy	#o_rect
	lda	[<event],y
	sta	<r
	ldy	#o_rect+2
	lda	[<event],y
	sta	<r+2

; create the rectangle

	ldy	#olst_pos+1
	lda	[<event],y
	and	#$ff
	pha
	asl	a
	asl	a
	asl	a
	sbc	#3-1
	ldy	#2
	sta	[<r],y
	pla
	ldy	#olst_items
	clc
	adc	[<event],y
	asl	a
	asl	a
	asl	a
	inc	a
	ldy	#6
	sta	[<r],y

	pei	(<r+2)
	pei	(<r)
	jsl	BSI_drawdroppedrect

	pei	(<event+2)
	pei	(<event)
	jsl	BSI_drawlist

	bra	done
                                                
done	return

	END

;-------------------------------------------------------------------------
;
; BSI_docallback
;     call a callback procedure
;
;-------------------------------------------------------------------------

BSI_docallback	PRIVATE bsi

space	equ	1

	subroutine (4:event,2:action),space

	ldy	#o_code
	lda	[<event],y
	sta	!call+1
	iny
	lda	[<event],y
	sta	!call+2
               ora	!call+1
	beq	bye

	pei	(<event)

call	jsl	$ffffff

bye	return

	END

;-------------------------------------------------------------------------
;
; BSI_mouseinrect
;     is the mouse in the rectangle
;
; returns != 0 if in rectangle
;
;-------------------------------------------------------------------------

BSI_mouseinrect PRIVATE bsi

	using	BSI_data

k	equ	1
retval	equ	k+4
space	equ	retval+2

	subroutine (4:p),space

	stz	<retval

	ldy	#o_rect
               lda   [<p],y
	sta	<k
	ldy	#o_rect+2
	lda	[<p],y
	sta	<k+2
	ora	<k
	beq	done

	lda	[<k]
	cmp	!Where+2
	bcs	done

               ldy	#2
	lda	[<k],y
	cmp	!Where
	bcs	done

	ldy	#4
	lda	[<k],y
	cmp	!Where+2
	bcc	done

	ldy	#6
	lda	[<k],y
	cmp	!Where
	bcc	done

	inc	<retval

done	return 2:retval

	END

;-------------------------------------------------------------------------
;
; BSI_trackmousedn
;     track mouse down
;
;-------------------------------------------------------------------------

BSI_trackmousedn PRIVATE bsi

	using	BSI_data

last	equ	1
q	equ	last+2
count	equ	q+4
r	equ	count+2
save	equ	r+4
rect	equ	save+4
top	equ	rect+8
space	equ	top+2

	subroutine (4:p),space

	ldy	#o_type
	lda	[<p],y
	tax

	jmp	(tbl,x)

tbl	dc	i2'done'	;last
	dc	i2'button'	;button
	dc	i2'done'	;window
	dc	i2'popup'	;pop-up menu
	dc	i2'list'	;list

; mouse down in button

button	ldy	#o_rect+2
	lda	[<p],y
	pha
	ldy	#o_rect
	lda	[<p],y
	pha
	jsl	BSI_drawdroppedrect

inbutton	StillDown #0,@a
	bne	inbcont

	ldy	#o_rect+2
	lda	[<p],y
	pha
	ldy	#o_rect
	lda	[<p],y
	pha
	jsl	BSI_drawraisedrect

	pei	(<p+2)
	pei	(<p)
	pea	A_mousedn
	jsl	BSI_docallback
	jmp	done

inbcont        GetMouse #Where
               pei	(<p+2)
	pei	(<p)
	jsl	BSI_mouseinrect
	bne	inbutton

	ldy	#o_rect+2
	lda	[<p],y
	pha
	ldy	#o_rect
	lda	[<p],y
	pha
	jsl	BSI_drawraisedrect

outbutton	StillDown #0,@a
	jeq	done

	GetMouse #Where
               pei	(<p+2)
	pei	(<p)
	jsl	BSI_mouseinrect
	beq	outbutton
	jmp	button

; in pop-up menu
; first calculate the pop-up window

popup	ldy	#o_rect	;get pointer to rectangle
	lda	[<p],y
	sta	<r
	ldy	#o_rect+2
	lda	[<p],y
	sta	<r+2

; top row = boxrow - selection

	ldy	#opop_pos+1
	lda	[<p],y
	and	#$ff
	ldy	#opop_select
	sec
	sbc	[<p],y

	bmi	poptopfix
	bne	poptopok

poptopfix	lda	#1

poptopok	sta	<top

	lda	[<p],y
	sta	<last

; create the rectangle

	lda	[<r]
	sta	<rect
	ldy	#4
	lda	[<r],y
	sta	<rect+4
	lda	<top
	asl	a
	asl	a
	asl	a
	sbc	#3-1
	sta	<rect+2
	ldy	#opop_items
	lda	[<p],y
	clc
	adc	<top
	asl	a
	asl	a
	asl	a
	inc	a
	sta	<rect+6

	pea	0
	tdc	
	adc	#rect
	pha
	jsl	BSI_saverect
	sta	<save
	stx	<save+2

	pea	0
	tdc
	clc
	adc	#rect
	pha
	pea	0
	jsl	BSI_fillrect

	pea	0
	tdc
	clc
	adc	#rect
	pha
	jsl	BSI_drawdroppedrect

	jsr	drawpop

poploop	StillDown #0,@a
	beq	endpop

	GetMouse #Where

	lda	!Where
	lsr	a
	lsr	a
	lsr	a
	sec
	sbc	<top
	bmi	poploop
	ldy	#opop_items
	cmp	[<p],y
	bcs	poploop
	ldy	#opop_select
	cmp	[<p],y
	beq	poploop

	sta	[<p],y
	jsr	drawpop

	bra	poploop

endpop	ldy	#opop_list+2
	lda	[<p],y
	sta	<r+2
	ldy	#opop_list
	lda	[<p],y
	sta	<r
	ldy	#opop_select
	lda	[<p],y
	asl	a
	asl	a
	adc	<r
	sta	<r
	lda	[<r]
	sta	<q
	ldy	#2
	lda	[<r],y
	sta	<q+2
	lda	[<q]
	bit	#F_disabled
	beq	valpop
               ldy	#opop_select
	lda	<last
	sta	[<p],y

valpop	pei	(<save+2)
	pei	(<save)
	jsl	BSI_restrect

	pei	(<p+2)
	pei	(<p)
	jsl	BSI_drawevent

	pei	(<p+2)
	pei	(<p)
	pea	A_mousedn
	jsl	BSI_docallback

	jmp	done

; mouse down in list

list	ldy	#olst_pos+1
	lda	[<p],y
	and	#$ff
	sta	<top
       
listloop	StillDown #0,@a
	jeq	endlist

	GetMouse #Where

	lda	!Where
	lsr	a
	lsr	a
	lsr	a
	sec
	sbc	<top
	bmi	listtop
	ldy	#olst_items
	cmp	[<p],y
	bcs	listbot
	ldy	#olst_first
	adc	[<p],y
	ldy	#olst_select
	cmp	[<p],y
	beq	listloop

setlist	ldy	#olst_length
	cmp	[<p],y
	bcs	listloop
	ldy	#olst_select
	sta	[<p],y

	pei	(<p+2)
	pei	(<p)
	jsl	BSI_drawlist

	bra	listloop

listtop	ldy	#olst_first
	lda	[<p],y
	ldy	#olst_select
	cmp	[<p],y
	beq	top2
	sta	[<p],y
               bra	setlist
top2	ldy	#olst_first
	lda	[<p],y
	beq	listloop
	dec	a
	sta	[<p],y
	ldy	#olst_select
	lda	[<p],y
	dec	a
	bra	setlist

listbot	ldy	#olst_select
	sec
	lda	[<p],y
	ldy	#olst_first
	sbc	[<p],y
	bmi	bot1
	inc	a
	ldy	#olst_items
	cmp	[<p],y
	bcs	bot2
bot1	ldy	#olst_first
	lda	[<p],y
	clc
	ldy	#olst_items
	adc	[<p],y
	dec	a
	bra	setlist

bot2	ldy	#olst_select
	lda	[<p],y
	inc	a
	ldy	#olst_length
	cmp	[<p],y
	jcs	listloop
	ldy	#olst_first
	lda	[<p],y
	inc	a
	sta	[<p],y
	ldy	#olst_select
	lda	[<p],y	
	inc	a
	bra	setlist	

endlist	TickCount @ax
	phx
	pha

	sec
	sbc	!lastclick
	tay
	txa
	sbc	!lastclick+2
	bne	nodbl
	sty	!delay

	GetDblTime @ax
	cmp	!delay
	bcc	nodbl	

	PostEvent (#3,#$80),@a

nodbl	pla
	sta	!lastclick
	pla
	sta	!lastclick+2
	bra	done

done	return    

; draw a pop-list

drawpop	ldy	#opop_items
	lda	[<p],y
	dec	a
	sta	<count
dploop	ldy	#opop_pos
	lda	[<p],y
	and	#$ff
	tax
	lda	<top
	clc
	adc	<count
	tay	
	jsl	BSI_gotoxy

	ldy	#opop_select
	lda	[<p],y
	cmp	<count
	bne	nosel

	jsl	BSI_inverse

nosel	ldy	#opop_list+2
	lda	[<p],y
	sta	<r+2
	lda	<count
	asl	a
	asl	a
	ldy	#opop_list
	adc	[<p],y
	sta	<r
	ldy	#2
	lda	[<r],y
	sta	<q+2
	pha
	lda	[<r]
	sta	<q
	inc	a
	pha
	lda	[<q]
	bit	#F_disabled
	beq	nodis
	jsl	BSI_normal
	jsl	BSI_dim
nodis	ldy	#opop_width
	lda	[<p],y
	inc	a
	pha
	jsl	BSI_writenstring

	jsl	BSI_normal

	dec	<count
	bpl	dploop
		
	rts

lastclick	dc	i4'0'
delay	dc	i2'0'

	END

;------------------------------------------------------------------
; BSI_drawlist
;   draw the contents of a list
;------------------------------------------------------------------

BSI_drawlist	PRIVATE bsi

item	equ	1
width	equ	item+2
xpos	equ	width+2
ypos	equ	xpos+2
index	equ	ypos+2
list	equ	index+2
numleft	equ	list+4
space	equ	numleft+2

	subroutine (4:p),space

	stz	<index
	ldy	#olst_items
	lda	[<p],y
	sta	<numleft
	jeq	end

	ldy	#olst_list
	lda	[<p],y
	ldy	#olst_list+2
	ora	[<p],y
	beq	end

	lda	[<p],y
	sta	<list+2
	ldy	#olst_first
	lda	[<p],y
	asl	a
	asl	a
	ldy	#olst_list
	clc
	adc	[<p],y
	sta	<list

	ldy	#olst_pos
	lda	[<p],y
	and	#$ff
	sta	<xpos
	iny
	lda	[<p],y
	and	#$ff
	sta	<ypos
	ldy	#olst_width
	lda	[<p],y
	sta	<width
	ldy	#olst_first
	lda	[<p],y
	sta	<item

loop	lda	[<list]
	ldy	#2
	ora	[<list],y
	beq	end

	ldx	<xpos
	ldy	<ypos	
	jsl	BSI_gotoxy

	lda	<item
	ldy	#olst_select
	cmp	[<p],y
	bne	write

	jsl	BSI_inverse

write	ldy	#2
	lda	[<list],y
	pha
	lda	[<list]
	pha
	pei	(<width)
	jsl	BSI_writenstring

	jsl	BSI_normal

	lda	<list
	clc
	adc	#4
	sta	<list

	inc	<ypos
	inc	<index
	inc	<item
	dec	<numleft
	bne	loop
	bra	done

end	ldy	#olst_pos
	lda	[<p],y
	and	#$ff
	tax
	iny
	lda	[<p],y
	and	#$ff
	clc
	adc	<index
	tay	
	jsl	BSI_gotoxy

	ph4	#null
	ldy	#olst_width
	lda	[<p],y
	pha
	jsl	BSI_writenstring

	inc	<index
	dec	<numleft
	bne	end

done	return

null	dc	h'00'

	END

;------------------------------------------------------------------
; BSI_listkey
;   handle a keyboard event for a list
;------------------------------------------------------------------

BSI_listkey	PRIVATE bsi

space	equ	1

	subroutine (4:p,2:key),space

	lda	<key
	cmp	#$0B
	beq	up

; down-arrow

	ldy	#olst_select
	lda	[<p],y
	inc	a
	ldy	#olst_length
	cmp	[<p],y
	bcs	done
	ldy	#olst_select
	bra	update

; up-arrow

up	ldy	#olst_select
	lda	[<p],y
	beq	done
	dec	a

update	sta	[<p],y
	sec
	ldy	#olst_first
	sbc	[<p],y
	bmi	offtop

	inc	a
	ldy	#olst_items
	cmp	[<p],y
	bcc	draw
	ldy	#olst_select
	lda	[<p],y
	ldy	#olst_items
	sbc	[<p],y
	inc	a
	bra	setdraw

offtop	ldy	#olst_select
	lda	[<p],y
setdraw	ldy	#olst_first
	sta	[<p],y

draw	pei	(<p+2)
	pei	(<p)
	jsl	BSI_drawlist

done	return

	END
                  
