**************************************************************************
*
* The Bloody Simple Interface Manager
* by Tim Meekins
*
* Copyright (c) 1993 by Procyon Enterprises
*
**************************************************************************
*
* bsi.h
*
* Data structures and constants used by BSI
*
**************************************************************************

;
; Event types
;
E_last	gequ	0	; the last event on the event list
E_button	gequ	2	; standard pushbutton
E_window	gequ	4	; a window
E_popup	gequ	6	; pop-up menu
E_list	gequ	8	; list event
;
; Event Actions
;
A_none	gequ	0	; no action occurred
A_key	gequ	2	; keypress action
A_mousedn	gequ	4	; mouse-down action
;
; Event flags
;
F_blockevent	gequ	%01	; block all events past this event
F_disabled	gequ	%10	; disabled event
;
; base event data structure
;
o_type	gequ	0	; the event type
o_next	gequ	o_type+2	; the next event
o_prev	gequ	o_next+4	; the previous event
o_flag	gequ	o_prev+4	; event flags
o_key	gequ	o_flag+2	; ptr to key list
o_code	gequ	o_key+4	; ptr to callback procedure
o_rect	gequ	o_code+4	; pointer to rectangle
;
; button specific entries
;
obut_text	gequ	o_rect+4	; button string with position
;
; window specific entries
;
owin_save	gequ	o_rect+4	; handle to rectangle save
;
; pop-menu specific entries
;
opop_width	gequ	o_rect+4	; width of text
opop_items	gequ	opop_width+2	; number of menu items
opop_select	gequ	opop_items+2	; selected item
opop_pos	gequ	opop_select+2	; x,y position for text
opop_list	gequ	opop_pos+2	; menu list ptr
;
; list specific entries
;
olst_pos	gequ	o_rect+4	; x,y position for first line
olst_items	gequ	olst_pos+2	; number of entries visible in list
olst_first	gequ	olst_items+2	; first visible entry in list
olst_select	gequ	olst_first+2	; selected item
olst_list	gequ	olst_select+2	; pointer to list
olst_width	gequ	olst_list+4	; width of list entries
olst_length	gequ	olst_width+2	; # entries in list
