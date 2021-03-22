***********************************************************************
*
* Tool Tracer 1.0
* Written by Tim Meekins
*
* Copyright 1991 by Tim Meekins
*
**************************************************************************

	mcopy	tooltrace.mac

nummenu	gequ	3
;
; Types of patches
;
noPatch	gequ	0
sysPatch	gequ	1
maxPatch	gequ	2
;
;
;
dispatch1	gequ	$e10000
dispatch2	gequ	$e10004
ToolPointerTable gequ $e103c0

badHeaderError	gequ	$8001
headerNotFoundError gequ $8002

CDAHeader	START

	str	'Tool Tracer'
	dc	a4'TraceEnter'
	dc	a4'TraceLeave'

	END

**************************************************************************
*
* Enter the tool tracer main display routines
*
**************************************************************************

TraceEnter	START

	using	Global

	phb
	phk
	plb

;
; lots of bullshit
;
	TextStartUp
	SetInGlobals (#$7F,#$00)
	SetOutGlobals (#$FF,#$80)
	SetErrGlobals (#$FF,#$80)
	SetInputDevice (#1,#3)
	SetOutputDevice (#1,#3)
	SetErrorDevice (#1,#3)
	InitTextDev #0
	InitTextDev #1
	InitTextDev #2

	WriteCString #title
;
; main loop
;
main	ENTRY
	jsr	showstat
               jsr	DrawMenu

menuloop	ENTRY
	WriteChar #6
	ReadChar #0,@a
	pha
	WriteChar #5
	pla

	and	#$7F

	cmp	#11	;up-arrow
	bne	chk2
	lda	menuitem
	beq	menuloop
	dec	menuitem
	jsr	drawmenuitem
	dec	a
	jsr	drawmenuitem
	bra	menuloop

chk2	cmp	#10	;down-arrow
	bne	chk3
	lda	menuitem
	cmp	#nummenu-1
	beq	menuloop
	inc	menuitem
	jsr	drawmenuitem
	inc	a
	jsr	drawmenuitem	
	bra	menuloop

chk3	cmp	#13	;return
	bne	chk4
	lda	menuitem
	asl	a
	tax
	jmp	(jmptbl,x)

chk4	cmp	#27	;escape
	bne	menuloop
	lda	menuitem
	cmp	#nummenu-1
	beq	menuloop
	ldx	#nummenu-1
	stx	menuitem
	jsr	drawmenuitem
	lda	menuitem
	jsr	drawmenuitem
	bra	menuloop

done	plb
	rtl

jmptbl	dc	i2'unpatch'
	dc	i2'patchsys'
	dc	i2'done'

title	dc	i1'18,12,27'

 dc c' ______________________________________________________________________________ '
 dc i1'15',c'Z',i1'14',c'                             Tool Tracer v1.0                                 ',i1'15',c'_'
 dc c'Z',i1'14',c'                          Written by Tim Meekins                              ',i1'15',c'_'
 dc c'Z',i1'14',c'                       Copyright 1991 by Tim Meekins                          ',i1'15',c'_'
 dc i1'14',c' ',i1'15',c'LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL',i'14',c' '
 dc i1'24'
 dc i1'0'

	END

TraceLeave	START

	rtl

	END

**************************************************************************
*
* Unpatch the tool tracer
*
**************************************************************************

unpatch	START

	using	Global

	lda	PatchType
	asl	a
	tax
	jmp	(untbl,x)

untbl	dc	i2'menuloop'
	dc	i2'sys'

sys	jsr	unpatchsys
	jmp	main

	END

**************************************************************************
*
* Unpatcher before patcher
*
**************************************************************************

unpatch2	START

	using	Global

	lda	PatchType
	asl	a
	tax
	jmp	(untbl,x)

untbl	dc	i2'none'
	dc	i2'unpatchsys'

none	rts

	END

**************************************************************************
*
* Patch the system tool vector
*
**************************************************************************

patchsys	START

	using	global

	jsr	unpatch2	;Unpatch any previous patch

loop	WriteCString #str1
           	ReadLine (#buffer,#4,#13,#1),@a
	Hex2Int (#buffer,@a),@a
	bcc	good
	WriteChar #7
	bra	loop

good	sta	toolnum
	lda	#sysPatch
	sta	PatchType

	ph4	#OurE10000
	jsl	InstallE10000
	ply
	ply
	bcc	good2

good2	jmp	main	

str1	dc	i1'30,32+0,32+5,11'
	dc	i1'30,32+20,32+7'
	dc	c'Please enter a system tool call to patch:'
	dc	i1'30,32+35,32+9'
	dc	c'$'
	dc	h'00'

buffer	dc	c'0000'

	END

**************************************************************************
*
* Unpatch the system tool vector
*
**************************************************************************

unpatchsys	START

	using	Global

	stz	PatchType
	ph4	#OurE10000
	jsl	RemoveE10000
	ply
	ply
               bcc	ok

ok	rts

	END

**************************************************************************
*
* Show tool trace status
*
**************************************************************************

showstat	START

	using	Global

	WriteCString #str1

	lda	PatchType
	cmp	#maxPatch
	bcc	ok
	lda	#maxPatch
ok	asl	a
	tax
	jmp	(showtbl,x)

showtbl	dc	i2'noshow'
	dc	i2'sysshow'
	dc	i2'unshow'

noshow	WriteCString #str2
	rts

unshow	WriteCString #str3
	rts

sysshow	Int2Hex (toolnum,#str4+21,#4)
	WriteCString #str4
	rts

str1	dc	i1'30,32+0,32+5,11'
	dc	c'Status: '
	dc	i1'0'

str2	dc	c'Disabled',h'00'
str3	dc	c'Unknown tool trace installed',h'00'
str4	dc	c'Tracing System Tool $0000',h'00'

	END

**************************************************************************
*
* Draw the menu
*
**************************************************************************

DrawMenu	START

	using	Global

	lda	#nummenu-1
loop	jsr	drawmenuitem
	dec	a
	bpl	loop
	rts

	END

**************************************************************************
*
* Draw a menu item
*
**************************************************************************

drawmenuitem	START

	using	Global

	pha
	short	a
	clc
	adc	#9+32
	sta	posstr+2
	long	a
	WriteCString #posstr
	lda	1,s
	cmp	menuitem
	bne	noinvert
	WriteChar #15
noinvert	lda	1,s
	asl	a
	asl	a
	tax
	lda	menutbl+2,x
	tay
	lda	menutbl,x
	WriteCString @ya
	WriteChar #14
	pla
	rts

posstr	dc	i1'30,32+30,0,24',h'00'

	END

**************************************************************************
*
* Global Data
*
**************************************************************************

Global	DATA

PatchType	dc	i'noPatch'
toolnum	dc	i2'0'
inTrace	dc	i2'0'
oldborder	dc	i2'0'
oldrtl	dc	i4'0'

menuitem	dc	i2'0'
menutbl	dc	i4'menu0,menu1,menu2'

menu0	dc	c'Disable Tracing    ',h'00'
menu1	dc	c'Trace a System Tool',h'00'
menu2	dc	c'Quit               ',h'00'

	END

**************************************************************************
*
* InstallE10000 - Sets the jump vector at $e10000 and $e10004 to point to
*                 the passed new toolbox dispatch vector patch. This routine
*                 also updates the linked lists so that more than one routine
*                 can be patched into the dispatch vectors.
*
* Input: Passed via the stack following APW C conventions.
*   newPatchAddr (long) - Address of the patch routine.
*
* Output:
*    If an error occurred -
*        Carry set, Accumulator contains one of the following error codes:
*	badHeaderError
*    If no error occurred and patch was installed successfully -
*        Carry clear, Accumulator contains zero.
*
**************************************************************************

InstallE10000	START

oldPatchAddr	equ	1	; Address of existing patch
zprtl	equ	oldPatchAddr+4	; The address for the rtl.
zpsize	equ	zprtl-oldPatchAddr	; Size of dp we'll have on the stack
newPatchAddr	equ	zprtl+3	; Addr of patch (paramter to this)

	tsc		; Move the stack pointer to point beyond
	sec		; the direct page variables that we'll
	sbc	#zpsize	; place on the stack.
	tcs
	phd		; Save the direct page register
	tcd		; Set the direct page
	php		; Disable interrupts
	sei

	pei	(newPatchAddr+2)	; Check if patch header is valid
	pei	(newPatchAddr)
	jsl	CheckPatch
	plx		; Remove the parameters from the stack
	plx
	bcc	foo1	; Report the badHeaderError if detected.
	ldy	#badHeaderError
	jmp	exit

foo1	lda	>dispatch1	; Set up the next1Vector in the new patch
	sta	[newPatchAddr]	; The JML instruction amd low byte
	lda	>dispatch1+2
	ldy	#2
	sta	[newPatchAddr],y	; The middle and upper bytes

	lda	>dispatch2	; Set up the next2Vector in the new patch
	ldy	#4
	sta	[newPatchAddr],y	; The JML instruction and low byte
	lda	>dispatch2+2
	ldy	#6
	sta	[newpatchAddr],y	; The middle and upper bytes
	
	lda	>dispatch1+3	; See if there's already a patch
	and	#$00FF
	sta	oldPatchAddr+2
	pha		; High byte of possible header address
	lda	>dispatch1+1
	sec
	sbc	#$11
	sta	oldPatchAddr
	pha		; Low byte of possible header address
	jsl	CheckPatch
	plx
	plx
	bcs	first	; Jump if this is first patch

	ldy	#8	; Set up dispatch1Vector
	lda	[oldPatchAddr],y
	sta	[newPatchAddr],y	; The JML instruction and low byte
	ldy	#$A
	lda	[oldPatchAddr],y
	sta	[newPatchAddr],y	; The middle and upper bytes

	ldy	#$C	; Set up dispatch2Vector
	lda	[oldPatchAddr],y
	sta	[newPatchAddr],y	; The JML instruction and low byte
	ldy	#$E
	lda	[oldPatchAddr],y
	sta	[newPatchAddr],y	; The middle and upper bytes

	bra	PatchIt

First	ldy	#8	; Set up dispatch1Vector
	lda	>dispatch1
	sta	[newPatchAddr],y	; The JML instruction and low byte
	ldy	#$A
	lda	>dispatch1+2
	sta	[newPatchAddr],y	; The middle and upper bytes

	ldy	#$C	; Set up dispatch1Vector
	lda	>dispatch2
	sta	[newPatchAddr],y	; The JML instruction and low byte
	ldy	#$E
	lda	>dispatch2+2
	sta	[newPatchAddr],y	; The middle and upper bytes

PatchIt	clc		; Calculate the address of the new
	lda	newPatchAddr	; dispatch2
	adc	#$15
	sta	newPatchAddr
	xba
	and	#$FF00	; Mask in the JML instructions
	ora	#$005C
	sta	>dispatch2	; The JML instruction and low byte
	lda	newPatchAddr+1
	sta	>dispatch2+2	; The middle and upper bytes

	sec		; Calculate the address of the new
	lda	newPatchAddr	; dispatch1
	sbc	#4
	sta	newPatchAddr
	xba
	and	#$FF00	; Mask in the JML instruction
	ora	#$005C
	sta	>dispatch1	; The JML instruction and low byte
	lda	newPatchAddr+1
	sta	>dispatch1+2	; the middle and upper bytes

	ldy	#0	; Report that all went well

Exit	plp		; Restore the interrupt state.
	pld		; Restore the direct page
	tsc		; REstore the stack pointer
	clc
	adc	#zpsize
	tcs
	tya		; Value to return
	cmp	#1
	rtl

	END

**************************************************************************
*
* RemoveE10000 - Remove the specified patch from the dispatch1 and dispatch2
*                vectors and updates the linked lists for he remaining
*	  toolbox patches.
*
* Input:
*     If an error occurred -
*         Carry Set, Accumulator contains one of the following error codes:
*	badHeaderError
*	headerNotFoundError
*     If no error occurred and patch was removed successfully -
*         Carry clear, Accumulator contains 0
*
**************************************************************************

RemoveE10000	START

patchDispAddr	equ	1	; Address of existing patch + extra byte
prevHeader	equ	patchDispAddr+5	; Used to searhc through linked list
zprtl	equ	prevHeader+4	; The address for the rtl
zpsize	equ	zprtl-patchDispAddr ; Size of direct page on stack
patchToRemove	equ	zprtl+3	; Address of patch

	tsc		; Move the stack pointer to point beyond
	sec		; the direct page variables that we'll
	sbc	#zpsize	; place on the stack
	tcs
	phd		; Save the direct page register
	tcd		; Set the direct page
	php		; Disable interrupts
	sei

	pei	(patchToRemove+2)	; Check if patch header we were asked to
	pei	(patchToRemove)	; remove is a valid header
	jsl	CheckPatch
	plx		; Remove the parameters from the stack
	plx
	bcc	foo1	; Report the badHeaderError if detected
	ldy	#badHeaderError
	jmp	Exit

foo1	clc		; Create the JML
	lda	patchToRemove
	adc	#$11
               sta	patchDispAddr+1
	lda	patchToRemove+2
	sta	patchDispAddr+3
	lda	patchDispAddr	; Mask the JML
	and	#$FF00
	ora	#$005C
	sta	patchDispAddr

	cmp	>dispatch1	; Check if the patch to remove is the
	bne	notFirstOne	; first patch installed.
	lda	>dispatch1+2
	cmp	patchDispAddr+2
	bne	NotFirstOne

	lda	[patchToRemove]	; Restore the Dispatch1 vector1
	sta	>dispatch1
	ldy	#2
	lda	[patchToRemove],y
	sta	>dispatch1+2

	ldy	#4	; Restore the Dispatch2 vector.
	lda	[patchToRemove],y
	sta	>dispatch2
	ldy	#6
	lda	[patchToRemove],y
	sta	>dispatch2+2

	bra	NoErr	; Everything went well

NotFirstOne	sec		; Assume that whatever is in dispatch1
	lda	>dispatch1+1	; is patch and get the address of its
	sbc	#$11	; header.
	sta	prevHeader	; Low and middle bytes
	lda	>dispatch1+3
	and	#$FF
	sta	prevHeader+2	; Upper byte of header address

loop	pei	(prevHeader+2)	; Check if it really is a valid header.
	pei	(prevHeader)
	jsl	CheckPatch
	plx
	plx
	bcc	foo2	; Report that th patch we asked to
	ldy	#headerNotFoundError ; remove wasn't found.
	bra	Exit

foo2	lda	[prevHeader]	; See if this patch points to patch we
	cmp	patchDispAddr	; want to remove
	bne	nope
	ldy	#2
	lda	[prevHeader],y
	cmp	patchDispAddr+2
	bne	nope

	lda	[patchToRemove]	; Restore the next1Vector
	sta	[prevHeader]
	ldy	#2
	lda	[patchToRemove],y
	sta	[prevHeader],y

	ldy	#4	; Restore the next2vector
	lda	[patchToRemove],y
	sta	[prevHeader],y
	ldy	#6
	lda	[patchToRemove],y
	sta	[prevHeader],y

	bra	noerr	; Everything went well

nope	ldy	#2	; get the address of the next patch
	lda	[prevHeader],y	; header.
	tax
	lda	[prevHeader],y
	sta	prevHeader
	stx	prevHeader+2

	sec
	lda	prevHeader+1
	sbc	#$11
	sta	prevHeader
	lda	prevHeader+3
	and	#$FF
	sta	prevHeader+2

	bra	loop	; Now check this header

NoErr	ldy	#0	; Report that all went well

Exit	plp		; Restore the interrupt state
	pld		; Restore the direct page
	tsc		; Restore the stack pointer
	clc
	adc	#zpsize
	tcs
	tya		; Value to return
	cmp	#1
	rtl

	END

**************************************************************************
*
* CheckPatch - Checks the passed toolbox dispatch vector to see if it
*	points to a valid patch.
*
* Input: Passed via the stack following APW C conventios.
*    newPatchAddr (long) - Address of the patch routine.
*
* Output:
*    If newPatchAddr is a valid patch -
*        Carry clear
*    If newPatchAddr is not a valid patch -
*        carry set
*
**************************************************************************

CheckPatch	START

zprtl	equ	1	; The address for the rtl
newPatchAddr	equ	zprtl+3	; Address of patch

	tsc		; Make the stack and DP after saving
	phd		; the current DP
	tcd

	lda	newPatchAddr+2	; Simple check to check for a valid ptr
	and	#$FF00
	bne	BadPatch	; Wasn't zero, can't be valid ptr

	lda	[newPatchAddr]	; Check for the first JML
	and	#$00FF
	cmp	#$005C
	bne	BadPatch

	ldy	#4	; Check for the second JML
	lda	[newPatchAddr],y
	and	#$00FF
	cmp	#$005C
	bne	BadPatch

	ldy	#8	; Check for the third JML
	lda	[newPatchAddr],y
	and	#$00FF
	cmp	#$005C
	bne	BadPatch

	ldy	#$C	; Check for the fourth JML
	lda	[newPatchAddr],y
	and	#$00FF
	cmp	#$005C
	bne	BadPatch

	ldy	#$10	; Check for the rtl and phk
	lda	[newPatchAddr],y
	cmp	#$4B6B
	bne	BadPatch

	iny		; Check for the phk and pea
	lda	[newPatchAddr],y
	cmp	#$F44B
	bne	BadPatch

	clc		; Calculate address of the rtl
	lda	newPatchAddr
	adc	#$000F
	ldy	#$13	; Check for the address of the rtl
	cmp	[newPatchAddr],y
	bne	BadPatch

GoodPatch	pld
	clc
	rtl

BadPatch	pld
	sec
	rtl

	END

**************************************************************************
*
* OurE10000
*
**************************************************************************

OurE10000	START

	using	Global

next1Vector	jmp	>next1Vector
next2Vector	jmp	>next2Vector
dispatch1Vector jmp	>dispatch1Vector
dispatch2Vector jmp	>dispatch2Vector

anRTL	rtl

NewDispatch1	phk
	pea	anRTL-1

aLong	equ	1
oldDP	equ	aLong+4
oldTM	equ	oldDP+2

NewDispatch2	phx
	phd
	lda	>ToolPointerTable+2
	pha
	lda	>ToolPointerTable
	pha
	tsc
	tcd
	txa
	and	#$00FF
	cmp	[aLong]
	bcs	nocall
	asl	a
	asl	a
	tay
	lda	[aLong],y
	tax
	iny
	iny
	lda	[aLong],y
	sta	aLong+2
	stx	aLong
	lda	oldTM
	and	#$FF00
	xba
	cmp	[aLong]

noCall	pla
	pla
	pld
	plx

	lda	>intrace
	bne	goold
	txa
	cmp	>toolnum
	beq	traceit

goold	jmp	next2Vector

traceit	anop
;	bra	traceit
	lda	#1
	sta	>intrace
	lda	1,s
	sta	>oldrtl
	lda	2,s
	sta	>oldrtl+1
	short	a
	lda	>$E1C034
	sta	>oldborder
	lda	#1
	sta	>$E1C034
	long	a
	lda	>retvect
	sta	1,s
	lda	>retvect+1
	sta	2,s	

	bra	goold
	
retvect	dc	i4'returntrace-1'

returntrace	anop
;	bra	returntrace
	tax
	lda	#0
	sta	>intrace
	short	a
	lda	>oldborder
	sta	>$E1C034
	lda	>oldrtl+2
	pha
	long	a
	lda	>oldrtl
	pha
	txa
	cmp	#1
	rtl

	END
