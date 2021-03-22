**************************************************************************
*
* ImageQuant
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************

	mcopy	m/iq.mac

	copy	bsi.h

;-----------------------------------------
; ImageQuant Main
;-----------------------------------------

IQ	START

	using	EventData
	using	Globals

	using	BSI_data

	tsc
	sta	!IQStack
	tdc
	sta	!IQDP

; initialize the interface

	jsl	BSI_init
	ph4	#TVMM_err
	jsl	TVMM_init

; initialize variables

	stz	!ImageLoaded
	stz	!PicLoaded

; add the menu buttons

	ph4	#aboutbutton
	jsl	BSI_addevent
	ph4	#openbutton
	jsl	BSI_addevent
	ph4	#convertbutton
	jsl	BSI_addevent
	ph4	#savebutton
	jsl	BSI_addevent
	ph4	#viewbutton
	jsl	BSI_addevent
	ph4	#quitbutton
	jsl	BSI_addevent

; draw the identifiers for pop-up menus

	ph4	#loadidstr
	jsl	BSI_writetext
	ph4   #convertidstr
	jsl	BSI_writetext
	ph4	#quantidstr
	jsl	BSI_writetext
	ph4	#ditheridstr
	jsl	BSI_writetext
	ph4	#saveidstr
	jsl	BSI_writetext

; add the main pop-up menu events

	ph4	#loadpopup
	jsl	BSI_addevent
	ph4	#convertpopup
	jsl	BSI_addevent
	ph4	#quantpopup
	jsl	BSI_addevent
	ph4	#ditherpopup
	jsl	BSI_addevent
	ph4	#savepopup
	jsl	BSI_addevent

; draw current picture stats

	jsl	updatestats

; set menu status

	jsr	fixmenu

; the main event loop            

	jsl	BSI_event

; shutdown the interface

	jsl	TVMM_exit
	jsl	BSI_exit

	Quit	QuitParm

	rtl

QuitParm	dc	i2'0'
	dc	i4'0'
	
	END

;--------------------------------------------
; TVMM_err
;   TVMM error handler
;--------------------------------------------

TVMM_err	START

	using	Globals

	phk
	plb

	lda	!IQStack
	tcs
	lda	!IQDP
	tcd

	jsl	TVMM_exit
	jsl	BSI_exit

	jmp	IQ

	END

;--------------------------------------------
; doAbout
;   this is the callback for the About button
;--------------------------------------------

doAbout	START

	using	EventData

space	equ	1

	subroutine (2:action),space

	ph4	#aboutwindow
	jsl	BSI_addevent
	ph4	#aboutokbutton
	jsl	BSI_addevent
	ph4	#aboutstr1
	jsl	BSI_writetext
	ph4   #aboutstr2
	jsl	BSI_writetext
	ph4   #aboutstr3
	jsl	BSI_writetext
	ph4   #aboutstr4
	jsl	BSI_writetext
 
	return

	END

;--------------------------------------------
; AboutOkCallback
;   this is called when the OK button is
;   pressed in the About dialog box 
;--------------------------------------------

AboutOKCallback START                         

	using	EventData

space	equ	1

	subroutine (2:action),space

	ph4	#aboutwindow
	jsl	BSI_deleteevent

	return

	END

;--------------------------------------------
; doOpen
;   this is the callback for the Open button
;--------------------------------------------

doOpen	START

	using	EventData

space	equ	1

	subroutine (2:action),space

	ph4	#opendescstr
	ph4	#LoadImage
	jsl	BSI_getsf

	return

	END

;--------------------------------------------
; doConvert
;   this is the callback for the Convert button
;--------------------------------------------

doConvert	START

	using	EventData
	using	Globals

space	equ	1

	subroutine (2:action),space
	
	WaitCursor

	lda	!convtype
	sta	!PicType
	asl	a
	tax
	jmp	(convtbl,x)

convtbl	dc	i2'convbw'	;B/W
	dc	i2'conv16col'	;16 color
	dc	i2'conv3200f'	;3200 color fast
	dc	i2'conv3200s'	;3200 color slow
	dc	i2'convtrucol'	;true color

; B/W Conversion

convbw	lda	!dithertype
	asl	a
	tax
	jmp	(convbwtbl,x)

convbwtbl	dc	i2'convbwnone'	;B/W - no dither
	dc	i2'convbworder2'	;B/W - Order-2 dithering
	dc	i2'convdone'	;B/W - Order-4 dithering
	dc	i2'convbwerr1'	;B/W - Error Diffusion 1
	dc	i2'convdone'	;B/W - Error Diffusion 2
	dc	i2'convdone'	;B/W - Dot Diffusion
	dc	i2'convdone'	;B/W - Hilbert Space
	dc	i2'convdone'	;B/W - Peano Space

convbwnone	jsl	doPlainBW
	jmp	convdone
convbworder2	jsl	doOrder2BW
	jmp	convdone
convbwerr1	jsl	doError1BW
	jmp	convdone

; 16 color conversions

conv16col	lda	!quanttype
	asl	a
	tax
	jmp	(conv16coltbl,x)

conv16coltbl	dc	i2'conv16oct'	;16 Color - Octree
	dc	i2'convdone'	;16 Color - Variance
	dc	i2'convdone'	;16 Color - Sierchio
	dc	i2'convdone'	;16 Color - Wu
	dc	i2'convdone'	;16 Color - Median Cut

; 16 color octree conversions

conv16oct	lda	!dithertype
	asl	a
	tax
	jmp	(conv16octtbl,x)

conv16octtbl	dc	i2'conv16octnone'	;16 Color Octree - no dither
	dc	i2'conv16octord2'	;16 Color Octree - Order-2 dithering
	dc	i2'convdone'	;16 Color Octree - Order-4 dithering
	dc	i2'conv16octerr1'	;16 Color Octree - Error Diffusion 1
	dc	i2'convdone'	;16 Color Octree - Error Diffusion 2
	dc	i2'convdone'	;16 Color Octree - Dot Diffusion
	dc	i2'convdone'	;16 Color Octree - Hilbert Space
	dc	i2'convdone'	;16 Color Octree - Peano Space

conv16octnone  jsl	doPlainOctree16
	jmp	convdone
conv16octord2	jsl	doOrder2Octree16
	jmp	convdone
conv16octerr1	jsl	doErr1Octree16
	jmp	convdone
                      
; 3200 color fast conversions

conv3200f	lda	!quanttype
	asl	a
	tax
	jmp	(conv3200ftbl,x)

conv3200ftbl	dc	i2'conv3200foct'	;3200 Color fast - Octree
	dc	i2'convdone'	;3200 Color fast - Variance
	dc	i2'convdone'	;3200 Color fast - Sierchio
	dc	i2'convdone'	;3200 Color fast - Wu
	dc	i2'convdone'	;3200 Color fast - Median Cut

; 3200 color fast octree conversions

conv3200foct	lda	!dithertype
	asl	a
	tax
	jmp	(conv3200focttbl,x)

conv3200focttbl dc	i2'conv3200foctnone' ;3200 Color fast Octree - no dither
	dc	i2'conv3200foctord2' ;3200 Color fast Octree - Order-2 dithering
	dc	i2'convdone'	;3200 Color fast Octree - Order-4 dithering
	dc	i2'conv3200focterr1' ;3200 Color fast Octree - Error Diffusion 1
	dc	i2'convdone'	;3200 Color fast Octree - Error Diffusion 2
	dc	i2'convdone'	;3200 Color fast Octree - Dot Diffusion
	dc	i2'convdone'	;3200 Color fast Octree - Hilbert Space
	dc	i2'convdone'	;3200 Color fast Octree - Peano Space

conv3200foctnone jsl	doPlainOctree3200f
	bra	convdone
conv3200foctord2 jsl	doOrder2Octree3200f
	bra	convdone
conv3200focterr1 jsl	doErr1Octree3200f
	bra	convdone

; 3200 color slow conversions                           

conv3200s	lda	!quanttype
	asl	a
	tax
	jmp	(conv3200stbl,x)

conv3200stbl	dc	i2'conv3200soct'	;3200 Color slow - Octree
	dc	i2'convdone'	;3200 Color slow - Variance
	dc	i2'convdone'	;3200 Color slow - Sierchio
	dc	i2'convdone'	;3200 Color slow - Wu
	dc	i2'convdone'	;3200 Color slow - Median Cut

; 3200 color slow octree conversions

conv3200soct	lda	!dithertype
	asl	a
	tax
	jmp	(conv3200socttbl,x)

conv3200socttbl dc	i2'conv3200soctnone' ;3200 Color slow Octree - no dither
	dc	i2'conv3200soctord2' ;3200 Color slow Octree - Order-2 dithering
	dc	i2'convdone'	;3200 Color slow Octree - Order-4 dithering
	dc	i2'conv3200socterr1' ;3200 Color slow Octree - Error Diffusion 1
	dc	i2'convdone'	;3200 Color slow Octree - Error Diffusion 2
	dc	i2'convdone'	;3200 Color slow Octree - Dot Diffusion
	dc	i2'convdone'	;3200 Color slow Octree - Hilbert Space
	dc	i2'convdone'	;3200 Color slow Octree - Peano Space

conv3200soctnone jsl	doPlainOctree3200s
	bra	convdone
conv3200soctord2 jsl	doOrder2Octree3200s
	bra	convdone
conv3200socterr1 jsl	doErr1Octree3200s    
	bra	convdone

; True Color Conversion

convtrucol	lda	!dithertype
	asl	a
	tax
	jmp	(convtctbl,x)

convtctbl	dc	i2'convtcnone'	;True Color - no dither
	dc	i2'convtcord2'	;True Color - Order-2 dithering
	dc	i2'convdone'	;True Color - Order-4 dithering
	dc	i2'convdone'	;True Color - Error Diffusion 1
	dc	i2'convdone'	;True Color - Error Diffusion 2
	dc	i2'convdone'	;True Color - Dot Diffusion
	dc	i2'convdone'	;True Color - Hilbert Space
	dc	i2'convdone'	;True Color - Peano Space

convtcnone	jsl	doPlainTrueColor
	jmp	convdone
convtcord2	jsl	doOrder2TrueColor
	jmp	convdone

convdone	InitCursor         

	jsr	fixmenu

	jsl	updatestats

	pea	0
	jsl	doView

	return

	END

;--------------------------------------------
; doView
;   this is the callback for the View button
;--------------------------------------------

doView	START

	using	EventData
	using	Globals

space	equ	1

	subroutine (2:action),space

	lda	!PicLoaded
	beq	done

	HideCursor

	lda	!PicType
	asl	a
	tax
	jmp	(pictbl,x)

pictbl	dc	i2'pic16'	; B/W
	dc	i2'pic16'	; 16 color
	dc	i2'pic3200'	; 3200 color fast
	dc	i2'pic3200'	; 3200 color slow
	dc	i2'pic16'	; truecolor

pic16	jsl	View320
	bra	cont
pic3200	jsl	View3200
	
cont	InitCursor

	jsl	updatestats

done	return

	END

;--------------------------------------------
; QuitCallback
;   this is called when the Quit button is
;   pressed
;--------------------------------------------

QuitCallback	START

	using	EventData

space	equ	1

	subroutine (2:action),space

	ph4	#quitverwindow
	jsl	BSI_addevent
	ph4	#quityesbutton
	jsl	BSI_addevent
	ph4	#quitnobutton
	jsl	BSI_addevent
	ph4	#quitmessage
	jsl	BSI_writetext

	return

	END

;--------------------------------------------
; QuitYesCallback
;   this is called when the yes button is
;   pressed in the Quit? dialog box
;--------------------------------------------

QuitYesCallback START

	using	EventData

space	equ	1

	subroutine (2:action),space

	ph4	#quitverwindow
	jsl	BSI_deleteevent

	jsl	BSI_Break

	return

	END

;--------------------------------------------
; QuitNoCallback
;   this is called when the no button is
;   pressed in the Quit? dialog box
;--------------------------------------------

QuitNoCallback START                         

	using	EventData

space	equ	1

	subroutine (2:action),space

	ph4	#quitverwindow
	jsl	BSI_deleteevent

	return

	END

;--------------------------------------------
; IQError
;   Display error dialog box
;--------------------------------------------

IQError 	START                         

	using	EventData

space	equ	1

	subroutine (4:string),space

	jsl	BSI_Normal

	ph4	#errwindow
	jsl	BSI_addevent
	ph4	#errokbutton
	jsl	BSI_addevent

	ldx	#22
	ldy	#11
	jsl	BSI_gotoxy

	pei	(<string+2)
	pei	(<string)
	jsl	BSI_writestring
	
	return

	END

;--------------------------------------------
; IQErrCallback
;   Called when OK button in error window is
;   pressed.
;--------------------------------------------

IQErrCallback 	START                         

	using	EventData

space	equ	1

	subroutine (2:action),space

	ph4	#errwindow
	jsl	BSI_deleteevent

	jsl	CloseThermo

	return

	END

;--------------------------------------------
; PopupCallback
;   A pop-up menu item was selected
;--------------------------------------------

PopupCallback 	START                         

space	equ	1

	subroutine (2:action),space

	jsr	fixpopups

	return
	
	END

;--------------------------------------------
; fixmenu
;   determines whether menu items are
;   enabled or disabled
;--------------------------------------------

fixmenu 	START                         

	using	EventData
	using	Globals

; is the Image loaded?

	lda	!ImageLoaded
	beq	fm0

	ph4	#convertbutton
	jsl	BSI_enableevent
	bra	fm1

fm0	ph4	#convertbutton
	jsl	BSI_disableevent

; is the Picture converted?

fm1	lda	!PicLoaded
	beq	fm2

	ph4	#savebutton
	jsl	BSI_enableevent
	ph4	#viewbutton
	jsl	BSI_enableevent
               bra	fm3

fm2	ph4	#savebutton
	jsl	BSI_disableevent
	ph4	#viewbutton
	jsl	BSI_disableevent

fm3	rts

	END

;--------------------------------------------
; fixpopups
;   determines whether menu items are
;   enabled or disabled
;--------------------------------------------

fixpopups 	START                         

	using	EventData
	using	Globals

; determine whether err diffusion should be allowed

	lda	!convtype
	cmp	#4
	beq	err1no

	ph4	#ditherpopup
	pea	3
	jsl	BSI_enablepopup
	bra	done

err1no         ph4	#ditherpopup
	pea	3
	jsl	BSI_disablepopup

done	rts

	END

;--------------------------------------------
; updatestats
;   updates the picture stats
;--------------------------------------------

updatestats 	START                         

	using	EventData
	using	TVMM_data
	using	Globals

space	equ	1

	subroutine (0:dummy),space

	FreeMem mem
	jsr	memtok
	Long2Dec (mem,#statstr1+11,#5,#1)

	lda	>TVMM_RamSize
	sta	mem
	lda	>TVMM_RamSize+2
	sta	mem+2
	jsr	memtok
	Long2Dec (mem,#statstr2+11,#5,#1)
	
	lda	>TVMM_SwapSize
	sta	mem
	lda	>TVMM_SwapSize+2
	sta	mem+2
	jsr	memtok
	Long2Dec (mem,#statstr3+11,#5,#1)
	
	jsl	BSI_normal

	ldx	#45
	ldy	#5
	jsl	BSI_gotoxy
	ph4	#statstr1
	jsl	BSI_writestring         

	ldx	#45
	ldy	#6
	jsl	BSI_gotoxy
	ph4	#statstr2
	jsl	BSI_writestring         

	ldx	#45            
	ldy	#7
	jsl	BSI_gotoxy
	ph4	#statstr3
	jsl	BSI_writestring         

	ldx	#45            
	ldy	#9
	jsl	BSI_gotoxy
	ph4	#statstr4
	jsl	BSI_writestring         

	lda	!ImageLoaded
	beq	skip1

	Int2Dec (ImageWidth,#statstr6+0,#4,#1)
	Int2Dec (ImageHeight,#statstr6+7,#4,#1)

	ldx	#45+2            
	ldy	#10
	jsl	BSI_gotoxy
	ph4	#statstr6
	jsl	BSI_writestring         

skip1	ldx	#45            
	ldy	#12
	jsl	BSI_gotoxy
	ph4	#statstr5
	jsl	BSI_writestring         

	lda	!PicLoaded
	beq	skip2

	lda	!PicWidth
	asl	a
	Int2Dec (@a,#statstr6+0,#4,#1)
	Int2Dec (PicHeight,#statstr6+7,#4,#1)
                  
	ldx	#45+2            
	ldy	#13
	jsl	BSI_gotoxy
	ph4	#statstr6
	jsl	BSI_writestring         

skip2	anop

	return               

memtok	lda	!mem+1
	sta	!mem
	lda	!mem+3
	and	#$ff
	sta	!mem+2
               lsr	!mem+2
	ror	!mem
	lsr	!mem+2
	ror	!mem
               rts

mem	ds	4

	END                             

;---------------------------------------------------
; Data for the events/controls for BSI
;---------------------------------------------------

EventData	DATA
;
; the About button
;
aboutbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'aboutkey'	;key list
	dc	i4'doAbout'	;button callback
	dc	i4'aboutrect'      ;button rectangle
	dc	i4'abouttext'      ;button text
aboutrect	dc    i2'0,1*8-3,104,2*8+1'
abouttext	dc	i1'4,1',c'About',h'00'
aboutkey	dc	i1'$41+$80,$61+$80,$3F+$80,$2F+$80,0' ;OA-A,OA-a,OA-?,OA-/
;
; the Open button
;
openbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'openkey'	;key list
	dc	i4'doOpen'	;button callback
	dc	i4'openrect'       ;button rectangle
	dc	i4'opentext'       ;button text
openrect	dc    i2'106,1*8-3,211,2*8+1'
opentext	dc	i1'18,1',c'Open',h'00'
openkey	dc	i1'$4F+$80,$6F+$80,0'	;OA-O,OA-o
;
; the Convert button
;
convertbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'convertkey'	;key list
	dc	i4'doConvert' 	;button callback
	dc	i4'convertrect'    ;button rectangle
	dc	i4'converttext'    ;button text
convertrect	dc    i2'213,1*8-3,317,2*8+1'
converttext	dc	i1'30,1',c'Convert',h'00'
convertkey	dc	i1'$43+$80,$63+$80,0'	;OA-C,OA-c
;
; the Save button
;
savebutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'savekey'	;key list
	dc	i4'0'	;button callback
	dc	i4'saverect'       ;button rectangle
	dc	i4'savetext'       ;button text
saverect	dc    i2'319,1*8-3,424,2*8+1'
savetext	dc	i1'44,1',c'Save',h'00'
savekey	dc	i1'$53+$80,$73+$80,0'	;OA-S,OA-s
;                 
; the View button
;
viewbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'viewkey'	;key list
	dc	i4'doView'	;button callback
	dc	i4'viewrect'       ;button rectangle
	dc	i4'viewtext'       ;button text
viewrect	dc    i2'426,1*8-3,530,2*8+1'
viewtext	dc	i1'58,1',c'View',h'00'
viewkey	dc	i1'$56+$80,$76+$80,0'	;OA-V,OA-v
;                                    
; the Quit button
;
quitbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'quitkey'	;key list
	dc	i4'QuitCallback'	;button callback
	dc	i4'quitrect'       ;button rectangle
	dc	i4'quittext'       ;button text
quitrect	dc    i2'532,1*8-3,638,2*8+1'
quittext	dc	i1'71,1',c'Quit',h'00'
quitkey	dc	i1'$51+$80,$71+$80,0'	;OA-Q,OA-q
;
; Quit verify window
;
quitverwindow	dc	i2'E_window'	;window type
	dc	i4'0'	;next
	dc	i4'0'	;prev
	dc	i2'F_blockevent'	;flags
	dc	i4'0'	;key list
	dc	i4'0'	;quit ver callback
               dc	i4'quitverrect'	;quit ver rectangle
	dc	i4'0'	;quit ver save handle
quitverrect 	dc	i2'197,80,433,118'
;
; Quit "Yes" button
;
quityesbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'quityeskey'	;key list
	dc	i4'QuitYesCallback' ;button callback
	dc	i4'quityesrect'    ;button rectangle
	dc	i4'quityestext'    ;button text
quityesrect	dc    i2'394,101,429,113'
quityestext	dc	i1'50,13',c'Yes',h'00'
quityeskey	dc	i1'$0D,$59,$79,$59+$80,$79+$80,0'	;CR,Y,y,OA-Y,OA-y
;
; Quit "No" button
;
quitnobutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'quitnokey'	;key list
	dc	i4'QuitNoCallback' ;button callback
	dc	i4'quitnorect'     ;button rectangle
	dc	i4'quitnotext'     ;button text
quitnorect	dc    i2'202,101,232,113'
quitnotext	dc	i1'26,13',c'No',h'00'
quitnokey	dc	i1'$1B,$4E,$6E,$2E+$80,$4E+$80,$6E+$80,0'	;ESC,N,n,OA-.,OA-N,OA-n
;
; Quit message
;
quitmessage	dc	i1'33,11',c'Are you sure?',h'00'
;
; pop-up menu name strings
;
loadidstr	dc	i1'7,6',c'Load Type:',h'00'
convertidstr	dc	i1'6,9',c'Convert To:',h'00'
quantidstr	dc	i1'4,12',c'Quantization:',h'00'
ditheridstr	dc	i1'7,15',c'Dithering:',h'00'
saveidstr	dc	i1'7,18',c'Save Type:',h'00'
;
; load type pop-up menu
;
loadpopup	dc	i2'E_popup'	;pop-up menu type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'loadpopkey'	;key list
	dc	i4'0'	;button callback
	dc	i4'loadpoprect'	;button rectangle
	dc	i2'17'	;text width
	dc	i2'7'	;5 items
loadtype	dc	i2'1'	;selected item
	dc	i1'18,6'	;text position
	dc	i4'loadpoplist'	;menulist
loadpoprect	dc	i2'18*8-4,6*8-3,36*8+1,7*8+1'
loadpopkey	dc	i1'$4C+$80,$6C+$80,0'	;OA-L,OA-l
loadpoplist	dc	i4'loadpop1'
	dc	i4'loadpop2'
	dc	i4'loadpop3'
	dc	i4'loadpop4'
	dc	i4'loadpop5'
	dc	i4'loadpop6'
	dc	i4'loadpop7'
loadpop1	dc	i1'0',c'Raw 24 (word)',h'00'
loadpop2	dc	i1'0',c'GIF',h'00'
loadpop3	dc	i1'0',c'PPM/PGM Format',h'00'
loadpop4	dc	i1'0',c'AST/Visionary',h'00'
loadpop5	dc	i1'F_disabled',c'JPEG',h'00'
loadpop6	dc	i1'0',c'IFF/ILBM',h'00'
loadpop7	dc	i1'0',c'Windows(tm) BMP',h'00'
;                 
; convert to pop-up menu
;
convertpopup	dc	i2'E_popup'	;pop-up menu type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'convpopkey'	;key list
	dc	i4'PopupCallback'	;button callback
	dc	i4'convpoprect'	;button rectangle
	dc	i2'17'	;text width
	dc	i2'5'	;5 items
convtype	dc	i2'0'	;selected item
	dc	i1'18,9'	;text position
	dc	i4'convpoplist'	;menulist
convpoprect	dc	i2'18*8-4,9*8-3,36*8+1,10*8+1'
convpopkey	dc	i1'$54+$80,$74+$80,0'	;OA-T,OA-t
convpoplist	dc	i4'convpop1'
	dc	i4'convpop2'
	dc	i4'convpop3'
	dc	i4'convpop4'
	dc	i4'convpop5'
convpop1	dc	i1'00',c'B/W',h'00'
convpop2	dc	i1'00',c'16 Color',h'00'
convpop3	dc	i1'00',c'3200 Color (fast)',h'00'
convpop4	dc	i1'00',c'3200 Color (slow)',h'00'
convpop5	dc	i1'00',c'True Color',h'00'
;                 
; quantization pop-up menu
;
quantpopup	dc	i2'E_popup'	;pop-up menu type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'quantpopkey'	;key list
	dc	i4'0'	;button callback
	dc	i4'quantpoprect'	;button rectangle
	dc	i2'17'	;text width
	dc	i2'5'	;5 items
quanttype	dc	i2'0'	;selected item
	dc	i1'18,12'	;text position
	dc	i4'quantpoplist'	;menulist
quantpoprect	dc	i2'18*8-4,12*8-3,36*8+1,13*8+1'
quantpopkey	dc	i1'$5A+$80,$7A+$80,0'	;OA-Z,OA-z
quantpoplist	dc	i4'quantpop1'
	dc	i4'quantpop2'
	dc	i4'quantpop3'
	dc	i4'quantpop4'
	dc	i4'quantpop5'
quantpop1	dc	i1'00',c'Octree',h'00'
quantpop2	dc	i1'F_disabled',c'Variance Based',h'00'
quantpop3	dc	i1'F_disabled',c'Sierchio Method',h'00'
quantpop4	dc	i1'F_disabled',c'Wu Method',h'00'
quantpop5	dc	i1'F_disabled',c'Median Cut',h'00'
;                 
; dithering pop-up menu
;
ditherpopup	dc	i2'E_popup'	;pop-up menu type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'ditherpopkey'	;key list
	dc	i4'0'	;button callback
	dc	i4'ditherpoprect'	;button rectangle
	dc	i2'17'	;text width
	dc	i2'8'	;8 items
dithertype	dc	i2'0'	;selected item
	dc	i1'18,15'	;text position
	dc	i4'ditherpoplist'	;menulist
ditherpoprect	dc	i2'18*8-4,15*8-3,36*8+1,16*8+1'
ditherpopkey	dc	i1'$4D+$80,$6D+$80,0'	;OA-D,OA-d
ditherpoplist	dc	i4'ditherpop1'
	dc	i4'ditherpop2'
	dc	i4'ditherpop3'
	dc	i4'ditherpop4'
	dc	i4'ditherpop5'
	dc	i4'ditherpop6'
	dc	i4'ditherpop7'
	dc	i4'ditherpop8'
ditherpop1	dc	i1'00',c'None',h'00'
ditherpop2	dc	i1'00',c'Ordered-2',h'00'
ditherpop3	dc	i1'F_disabled',c'Ordered-4',h'00'
ditherpop4	dc	i1'00',c'Error Diffusion 1',h'00'
ditherpop5	dc	i1'F_disabled',c'Error Diffusion 2',h'00'
ditherpop6	dc	i1'F_disabled',c'Dot Diffusion',h'00'
ditherpop7	dc	i1'F_disabled',c'Hilbert Space',h'00'
ditherpop8	dc	i1'F_disabled',c'Peano Space',h'00'
;                 
; save type pop-up menu
;
savepopup	dc	i2'E_popup'	;pop-up menu type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'0'	;key list
	dc	i4'0'	;button callback
	dc	i4'savepoprect'	;button rectangle
	dc	i2'17'	;text width
	dc	i2'1'	;1 item
	dc	i2'0'	;selected item
	dc	i1'18,18'	;text position
	dc	i4'savepoplist'	;menulist
savepoprect	dc	i2'18*8-4,18*8-3,36*8+1,19*8+1'
savepoplist	dc	i4'savepop1'
savepop1	dc	i1'F_disabled',c'$C1/0000 Raw',h'00'
;
; About window
;
aboutwindow	dc	i2'E_window'	;window type
	dc	i4'0'	;next
	dc	i4'0'	;prev
	dc	i2'F_blockevent'	;flags
	dc	i4'0'	;key list
	dc	i4'0'	;about callback
               dc	i4'aboutwrect'	;rectangle
	dc	i4'0'	;save handle
aboutwrect 	dc	i2'20*8,6*8,60*8,17*8'

aboutstr1	dc	i1'22,7',c'ImageQuant v0.3 - &SYSDATE &SYSTIME',h'00'
aboutstr2	dc	i1'22,9',c'Copyright (c) 1994 by Tim Meekins',h'00'
aboutstr3	dc	i1'24,11',c'BSI v0.5',h'00'
aboutstr4	dc	i1'24,12',c'TVMM v1.1',h'00'
;
; About "OK" button
;
aboutokbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'aboutokkey'	;key list
	dc	i4'AboutOkCallback' ;button callback
	dc	i4'aboutokrect'   	;button rectangle
	dc	i4'aboutoktext'    ;button text
aboutokrect	dc    i2'53*8-3,15*8-3,58*8+1,16*8+1'
aboutoktext	dc	i1'55,15',c'OK',h'00'
aboutokkey	dc	i1'$0D,$4F,$6F,$4F+$80,$6F+$80,00'	;CR,O,o,OA-O,OA-o

opendescstr	dc	c'Open which picture:',h'00'
;
; Error window
;
errwindow	dc	i2'E_window'	;window type
	dc	i4'0'	;next
	dc	i4'0'	;prev
	dc	i2'F_blockevent'	;flags
	dc	i4'0'	;key list
	dc	i4'0'	;about callback
               dc	i4'errwrect'	;rectangle
	dc	i4'0'	;save handle
errwrect 	dc	i2'20*8,6*8,60*8,17*8'
;
; Error "OK" button
;
errokbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'errokkey'	;key list
	dc	i4'IQErrCallback' 	;button callback
	dc	i4'errokrect'   	;button rectangle
	dc	i4'erroktext'    	;button text
errokrect	dc    i2'53*8-3,15*8-3,58*8+1,16*8+1'
erroktext	dc	i1'55,15',c'OK',h'00'
errokkey	dc	i1'$0D,$4F,$6F,$4F+$80,$6F+$80,00'	;CR,O,o,OA-O,OA-o
;
; Stat strings
;
statstr1	dc	c'Ram Free:  00000k',h'00'
statstr2	dc	c'Ram Used:  00000k',h'00'
statstr3	dc	c'VM Used:   00000k',h'00'
statstr4	dc	c'Loaded Image:',h'00'
statstr5	dc	c'Converted Image:',h'00'
statstr6	dc	c'0000 x 0000',h'00'

	END

;-----------------------------------------
; ImageQuant Globals
;-----------------------------------------

Globals	DATA

IQStack	ds	2
IQDP	ds	2

ImageHeight	ds	2	;height of raw image
ImageWidth	ds	2	;width of raw image
ImageHandle	ds	2	;handle to image
ImagePal	ds	2	;handle to image palette
ImagePalSize	ds	2	;number of entries in palette
ImageLoaded	ds	2	;=1 if image is allocated

PicHeight	ds	2	;height of GS image
PicWidth	ds	2	;width of GS image
PicHandle	ds	2	;handle to GS image
PicPalHandle	ds	2	;handle to GS palette
PicSCBHandle	ds	2	;handle to GS SCB table
PicLoaded	ds	2	;=1 if picture is allocated
PicType	ds	2	;type of picture, like convert type

palr	ds	16*2
palg	ds	16*2
palb	ds	16*2
;palr2	ds	16*2
;palg2	ds	16*2
;palb2	ds	16*2
palsize	ds	2

	END
