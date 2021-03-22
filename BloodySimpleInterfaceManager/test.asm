**************************************************************************
*
* The Bloody Simple Interface Manager
* by Tim Meekins
* Font compiler by Jawaid Bazyar & Tim Meekins
*
* Copyright (c) 1993 by Procyon Enterprises
*
**************************************************************************
*
* test.asm
*
* used for testing the BSI Manager
*
**************************************************************************

	mcopy	m/test.mac

	copy	bsi.h

test	START

	using	EventData

	jsl	BSI_init

	ph4	#aboutwindow
	jsl	BSI_addevent
	ph4	#quitbutton
	jsl	BSI_addevent
	ph4	#listbutton
	jsl	BSI_addevent

	jsl	BSI_event

	jsl	BSI_exit

	rtl

	Quit	QuitParm

QuitParm	dc	i2'0'
	dc	i4'0'	
	END

QuitCallback	START

	using	EventData

space	equ	0

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

QuitYesCallback START

	using	EventData

space	equ	0

	subroutine (2:action),space

	ph4	#quitverwindow
	jsl	BSI_deleteevent

	jsl	BSI_Break

	return

	END

QuitNoCallback START

	using	EventData

space	equ	0

	subroutine (2:action),space

	ph4	#quitverwindow
	jsl	BSI_deleteevent

	return

	END

EventData	DATA
;
; About Window
;
aboutwindow	dc	i2'E_window'	;window type
	dc	i4'0'	;next
	dc	i4'0'	;prev
	dc	i2'0'	;flags
	dc	i4'0'	;key list
	dc	i4'0'	;about callback
	dc	i4'aboutrect'      ;about rectangle
	dc	i4'0'	;about handle
aboutrect	dc	i2'80,50,320,150'
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
quitrect	dc    i2'593,181,638,194'
quittext	dc	i1'75,23',c'Quit',h'00'
quitkey	dc	i1'$51+$80,$71+$80,0'	;OA-Q,OA-q
;
; the List button
;
listbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'listkey'	;key list
	dc	i4'0'	;button callback
	dc	i4'listrect'       ;button rectangle
	dc	i4'listtext'       ;button text
listrect	dc    i2'593,165,638,178'
listtext	dc	i1'75,21',c'List',h'00'
listkey	dc	i1'$4C+$80,$6C+$80,0'	;OA-L,OA-l
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
quityeskey	dc	i1'$0D,$59,$79,0'	;CR,Y,y
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
quitnokey	dc	i1'$1B,$4E,$6E,$2E+$80,0'	;ESC,N,n,OA-.
;
; Quit message
;
quitmessage	dc	i1'33,11',c'Are you sure?',h'00'

	END
