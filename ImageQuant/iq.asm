**************************************************************************
*
* ImageQuant GS
*
**************************************************************************

	mcopy	iq.mac
	copy	iq.h

**************************************************************************
*
* Main routine
*
**************************************************************************

iq	START    

	using	Globals
	using	RGLOBAL

	phk
	plb

	TLStartUp
	jsr	chkerror

	MMStartUp @x
	jsr	chkerror
	stx	ID

	MTStartUp
	jsr	chkerror
               StartUpTools (ID,#0,#ToolTable),@xy
               jsr	chkerror
	stx	StartStop
	sty	StartStop+2

	NewWindow2 (#0,#0,#ContentDraw,#0,#0,#IntroWindow,#$800E),WindowPort
               ShowWindow WindowPort
	InitCursor

IntroLoop	TaskMaster (#$FFFF,#EventRecord),@a
	cmp	#$21
	bne	IntroLoop
	CloseWindow WindowPort
                                        
	NewWindow2 (#0,#0,#ContentDraw,#0,#0,#IQWindow,#$800E),WindowPort
               ShowWindow WindowPort

	GetCtlHandleFromID (#0,#LoadID),LoadHand
	GetCtlHandleFromID (#0,#ConvertID),ConvertHand
	GetCtlHandleFromID (#0,#QuantID),QuantHand
	GetCtlHandleFromID (#0,#DitherID),DitherHand
	GetCtlHandleFromID (#0,#SaveID),SaveHand
	GetCtlHandleFromID (#0,#LoadButID),LoadButHand
	GetCtlHandleFromID (#0,#ConvertButID),ConvertButHand
	GetCtlHandleFromID (#0,#SaveButID),SaveButHand
	GetCtlHandleFromID (#0,#ViewButID),ViewButHand
	GetCtlHandleFromID (#0,#QuitButID),QuitButHand
	GetCtlHandleFromID (#0,#TitleID),TitleHand

	stz	QuitFlag
	stz	Loaded
	stz	PicType

               jsr	Activate
	
EventLoop	TaskMaster (#$FFFF,#EventRecord),@a
	cmp	#$21
	bne	Event2
	jsr	inControl

Event2	lda	QuitFlag
	beq	EventLoop

	ShutDownTools (#0,StartStop)
	MTShutDown
	MMShutDown ID
	TLShutDown

	Quit	QuitParm

QuitParm	dc	i2'1'
	dc	i4'0'

	END

**************************************************************************
*
* An event was in a control
*
**************************************************************************

inControl	START

	using	Globals

inControl	lda	TaskData4
	cmp	#MaxCtlID+1
	bcs	done
	asl	a
	tax
	jsr	(ControlTbl,x)
	jmp	Activate

done	rts

ControlTbl	dc	i2'doNothing'	;no control
	dc	i2'doNothing'	;load pop-up
	dc	i2'doNothing'	;convert pop-up
	dc	i2'doNothing'	;quant pop-up
	dc	i2'doNothing'	;dither pop-up
	dc	i2'doNothing'      ;save pop-up
	dc	i2'doLoadPic'      ;load button
	dc	i2'doConvert'      ;convert button
	dc	i2'doNothing'      ;save button
	dc	i2'doView'      	;view button
	dc	i2'doQuit'      	;quit button
	dc	i2'doNothing'      ;title

	END

**************************************************************************
*
* The quit button was pressed
*
**************************************************************************

doQuit	START

	using	Globals

	lda	#1
	sta	QuitFlag
	rts

	END

**************************************************************************
*
* Load a picture
*
**************************************************************************

doLoadPic	START

	using	Globals

	SFGetFile2 (#120,#43,#0,#prompt,#0,#0,#replyrec)
	bcc	load0
	AlertWindow (#0,#0,#sfmsg),@a
zap1	rts

load0	lda	replyrec
	beq	zap1
	WaitCursor

	mv4	nameref,0
	lda	[0]
	inc	a
	inc	a
	sta	OpenPath
	ldy	#2
	lda	[0],y
	sta	OpenPath+2

               Open	OpenParm
	bcc	load1
	pha
	InitCursor
	pla
	ErrorWindow (#0,#0,@a),@a
	jmp	doneload

load1	mv2	OpenRef,(ReadRef,CloseRef)

	NewHandle (OpenEOF,ID,#$C008,#0),LoadHandle
	bcc	load2
	InitCursor
	AlertWindow (#0,#0,#memmsg),@a
	Close	CloseParm
	jmp	doneload
           
load2	mv4	LoadHandle,0
	lda	[0]
	sta	LoadPtr
	sta	ReadBuf
	ldy	#2
	lda	[0],y
	sta	LoadPtr+2
	sta	ReadBuf+2
	mv4	OpenEOF,ReadSize

	Read	ReadParm
	bcc	load3
	pha
	InitCursor
	pla
	ErrorWindow (#0,#0,@a),@a
	Close	CloseParm
	DisposeHandle LoadHandle
	bra	doneload
	           
load3	Close	CloseParm
;
; Now, let's go call our file interpreter for load type the user selected
;
	GetCtlValue LoadHand,comp+1
	ldx	#0
loop	lda	ldtbl,x
	beq	badload
comp	cmp	#0000
	beq	found
	inx
	inx
	bra	loop
badload	InitCursor
	AlertWindow (#0,#0,#loadmsg),@a
	bra	doneload

found	jsr	(jmptbl,x)	

	DisposeHandle LoadHandle
	InitCursor
doneload	DisposeHandle nameref
	DisposeHandle pathref
	rts

ldtbl	dc	i2'Raw24wID'
	dc	i2'Raw24LID'
	dc	i2'PPMID'
	dc	i2'ASTID'
	dc	i2'0'

jmptbl	dc	i2'LoadRaw24w'
	dc	i2'LoadGIF'
	dc	i2'LoadPPM'
	dc	i2'LoadAST'

prompt	str	'Select image to load'
sfmsg	dc	c'23/Standard File boo-boo/OK',h'00'
memmsg	dc	c'23/Could not allocate memory for loading/OK',h'00'
loadmsg	dc	c'23/Unknown load type/OK',h'00'

replyrec	ds	2
filetype	ds	2
auxtype	ds	4
	dc	i2'3'
nameref	ds	4
	dc	i'3'
pathref	ds	4

OpenParm	dc	i2'12'
OpenRef	dc	i2'0'
OpenPath	dc	i4'0'
	dc	i2'1'
	dc	i2'0'
	dc	i2'0'
	dc	i2'0'
               dc	i4'0'
	dc	i2'0'
	ds	8
	ds	8
	dc	i4'0'
OpenEOF	dc	i4'0'

ReadParm	dc	i2'4'
ReadRef	dc	i2'0'
ReadBuf	dc	i4'0'
ReadSize	dc	i4'0'
	dc	i4'0'

CloseParm	dc	i2'1'
CloseRef	dc	i2'0'

	END

**************************************************************************
*
* Convert the picture
*
**************************************************************************

doConvert	START

	using	Globals

	GetCtlValue ConvertHand,comp+1
	ldx	#0
loop	lda	convtbl,x
	beq	badload
comp	cmp	#0000
	beq	found
	inx
	inx
	bra	loop
badload	AlertWindow (#0,#0,#convmsg),@a
	rts

found	jmp	(jmptbl,x)	

convtbl	dc	i2'Item3200ID'
	dc	i2'BW320ID'
	dc	i2'Color320ID'
	dc	i2'0'

jmptbl	dc	i2'Convert3200'
	dc	i2'ConvertBW'
	dc	i2'Convert320'

convmsg	dc	c'23/Unknown image type/OK',h'00'

	END   

**************************************************************************
*
* Draw the contents of our window
*
**************************************************************************

ContentDraw	START

	using	Globals

	DrawControls WindowPort
	rtl

	END

**************************************************************************
*
* See who should be active and who shouldn't be
*
**************************************************************************

Activate	START

	using	Globals

none	equ	0
inactive	equ	255
;
; First let's deactivate everyone doesn't have code written yetr and
; activate the rest
;
	HiliteControl (#none,QuantHand)
	HiliteControl (#none,ConvertButHand)
	HiliteControl (#none,ViewButHand)
	HiliteControl (#inactive,SaveButHand)

	SetMenuBar QuantHand
	EnableMItem #OctreeID
	DisableMItem #VarQuantID
	DisableMItem #SierchioID
	DisableMItem #WuID
	DisableMItem #MedianCutID
	SetMenuBar DitherHand
	EnableMItem #Order2ID
	DisableMItem #Order4ID
	EnableMItem #Floyd1ID
	DisableMItem #Floyd2ID
	DisableMItem #DotDiffID
	DisableMItem #HilbertID
	DisableMItem #PeanoID
	SetMenuBar DitherHand
	EnableMItem #c10000ID
	DisableMItem #c10002ID
	DisableMItem #c00002ID
	HiliteControl (#inactive,SaveHand)
;                 
; If we're Black and White...
;	
	GetCtlValue ConvertHand,@a
	cmp	#BW320ID
	bne	act2
	HiliteControl (#inactive,QuantHand)
;
; set appropriate buttons
;
act2	lda	Loaded
	bne	act3
	HiliteControl (#inactive,ConvertButHand)
act3	lda	PicType
	cmp	#picNone
	bne	act4
	HiliteControl (#inactive,SaveButHand)
	HiliteControl (#inactive,ViewButHand)
;
; If we're Color 320
;
act4	GetCtlValue ConvertHand,@a
	cmp	#Color320ID
	bne	act5
	DisableMItem #Order2ID
;
; If we're Color 320
;
act5	GetCtlValue ConvertHand,@a
	cmp	#Item3200ID
	bne	act6
	DisableMItem #Order2ID

act6	anop               
                                
	rts

	END

**************************************************************************
*
* Clear the current picture
*
**************************************************************************

clrPic	START

	using	Globals

	ldx	picheight
	lda	picbuf
	sta	0
	lda	picbuf+2
	sta	0+2
yloop	ldy	picwidth
	dey
	short	a
	lda	#0
xloop	sta	[0],y
	dey
	bpl	xloop
	long	a
	clc
	lda	0
	adc	picwidth
	sta	0
	lda	0+2
	adc	#0
	sta	0+2	
	dex
	bne	yloop

	rts

	END

**************************************************************************
*
* View the current picture
*
**************************************************************************

doView	START

	using	Globals

	lda	PicType
	asl	a
	tax
	jmp	(jmptbl,x)

jmptbl	dc	i2'doNothing'
	dc	i2'View320'
	dc	i2'View3200'

	END

**************************************************************************
*
* View a 320 picture
*
**************************************************************************

View320        START

	using	Globals

addr	equ	0
scrn	equ	4

               HideCursor

	short	a
	lda	>$E1C034
	sta	border
	lda	#0
	sta	>$E1C034
	long	a

	SetAllSCBs #0
	SetColorTable (#0,picpal)

	ldx	#160*200-2
	lda	#0
clear	sta	>$E12000,x
	dex
	dex
	bpl	clear

	stz	xpos
	stz	ypos
	lda	picwidth
	cmp	#160
	bcc	v1
	lda	#160
v1	dec	a
	sta	mvnlen
	lda	picheight
	cmp	#200
	bcc	v2
	lda	#200
v2	dec	a
	sta	scrnheight

	GetMouseClamp (oymax,oymin,oxmax,oxmin)
	sec
	lda	picwidth
	sbc	#160
	bcs	v3
	lda	#0
v3	tax
	sec
	lda	picheight
	sbc	#200
	bcs	v4
	lda	#0
v4	ClampMouse (#0,@x,#0,@a)

	stz	mouse
loop	jsr	show
loop2	ReadMouse (@a,@y,@x)
	stz	movef
	cpx	xpos
	bne	domove
	cpy	ypos
	beq	nomove
domove	inc	movef
nomove	stx	xpos
	sty	ypos
	xba
	bit	#%10000000
	beq	notdown
	ldx	#1
	stx	mouse
	bra	continue
notdown        ldx	mouse
	bne	done
continue	lda	movef
	bne	loop
	bra	loop2

done           ClampMouse (oxmin,oxmax,oymin,oymax)
	short	a
	lda	border
	sta	>$E1C034
	long	a
	InitColorTable #$E19E00
               GetMasterSCB @a
               SetAllSCBs @a
               RefreshDesktop #0
               MenuNewRes
               InitCursor

               rts

oxmin	ds	2
oxmax          ds	2
oymin          ds	2
oymax          ds	2
mouse	ds	2
movef	ds	2

show	Multiply (ypos,picwidth),@ax
	clc
	adc	xpos
	bcc	show1
	inx
	clc
show1	adc	picbuf
	sta	addr
	txa
	adc	picbuf+2
	sta	addr+2

	lda	#$2000
	sta	scrn
	lda	scrnheight
	sta	height

	lda	addr+2
	ora	#$E100
	xba
	sta	move+1

	clc

yloop	lda	addr
               adc	picwidth
	bcs	crossbank
	ldy	scrn
	ldx	addr
	lda	mvnlen
move	mvn	0,0
	bra	next
crossbank      ldy	mvnlen
	pea	$E1E1
	plb
	plb
	short	a
bkcpy	lda	[addr],y
	sta	(scrn),y
	dey
	bpl	bkcpy
	phk
	plb
	inc	addr+2
	inc	move+2
	rep	#$21
	longa	on
	bra	next2
next	phk
	plb
next2	lda	addr
	adc	picwidth
	sta	addr
	clc
	lda	scrn
	adc	#160
	sta	scrn
	dec	height
	bpl	yloop

	rts

border	ds	2

xpos	ds	2
ypos	ds	2
mvnlen	ds	2
scrnheight	ds	2
height	ds	2

               END

**************************************************************************
*
* View a 3200 picture
*
**************************************************************************

View3200	START

	using	Globals

VERTCNT	equ	$E1C02E

addr	equ	0
scrn	equ	4

               HideCursor

	short	a
	lda	>$E1C034
	sta	border
	lda	#0
	sta	>$E1C034
	long	a

	lda	#0
	ldx	#160*200-2
blaken	sta	>$E12000,x
	dex
	dex
	bpl	blaken

	stz	xpos
	stz	ypos
	lda	picwidth
	cmp	#160
	bcc	v1
	lda	#160
v1	dec	a
	sta	mvnlen
	lda	picheight
	cmp	#200
	bcc	v2
	lda	#200
v2	dec	a
	sta	scrnheight

	GetMouseClamp (oymax,oymin,oxmax,oxmin)
	sec
	lda	picwidth
	sbc	#160
	bcs	v3
	lda	#0
v3	tax
	sec
	lda	picheight
	sbc	#200
	bcs	v4
	lda	#0
v4	ClampMouse (#0,@x,#0,@a)

	stz	mouse

	lda	>$E1C035
	sta	OldShadow
	ora	#$08
	sta	>$E1C035

	GetIRQEnable IRQEnable

	ldx	#0
nextdis	lda	IRQEnable
	and	masks,x
	beq	skip
	lda	disables,x
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

	lda	picpal
	sta	128
	lda	picpal+2
	sta	128+2

loop	jsr	show
	
	lda	ypos
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#6400-2
	tay
	ldx	#6400-2
palloop	lda	[128],y
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
	sta	oldstack
	short	a
	lda	>$E1C035
	and	#$F7
	sta	>$E1C035
	lda	>$E1C068
	sta	oldauxreg
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
	lda	oldstack
	tcs
	pld
	plp

	short	a
	lda	oldauxreg
	sta	>$E1C068
	long	a

	ReadMouse (@a,@y,@x)
	stz	movef
	cpx	xpos
	bne	domove
	cpy	ypos
	beq	nomove
domove	inc	movef
nomove	stx	xpos
	sty	ypos
	xba
	bit	#%10000000
	beq	notdown
	ldx	#1
	stx	mouse
	bra	continue
notdown        ldx	mouse
	bne	done
continue	lda	movef
	jne	loop
	jmp	loop2

done           ClampMouse (oxmin,oxmax,oymin,oymax)
                   
	ldx	#0
nextenable	lda	IRQEnable
	and	masks,x
	beq	skip1
	lda	enables,x
	phx
	IntSource @a
	plx
skip1	inx
	inx
	cpx	#14
	bne	nextenable

	short	a

	lda	oldauxreg
	sta	>$E1C068
	lda	OldShadow
	sta	>$E1C035

	lda	border
	sta	>$E1C034
	long	a

           	InitColorTable #$E19E00
               GetMasterSCB @a
               SetAllSCBs @a
               RefreshDesktop #0
               MenuNewRes
               InitCursor

               rts

OldShadow	ds	2
oldstack	ds	2
oldauxreg	ds	2
IRQEnable	ds	2
xend	ds	2

masks	dc	i'1,2,4,16,32,64,128'
enables	dc	i'14,12,10,6,4,2,0'
disables	dc	i'15,13,11,7,5,3,1'

oxmin	ds	2
oxmax          ds	2
oymin          ds	2
oymax          ds	2
mouse	ds	2
movef	ds	2

show	Multiply (ypos,picwidth),@ax
	clc
	adc	xpos
	bcc	show1
	inx
show1	clc
	adc	picbuf
	sta	addr
	txa
	adc	picbuf+2
	sta	addr+2

	lda	#$2000
	sta	scrn
	lda	scrnheight
	sta	height

yloop	clc
	lda	addr
               adc	picwidth
	bcs	crossbank
	lda	addr+2
	ora	#$E100
	xba
	sta	move+1
	ldy	scrn
	ldx	addr
	lda	mvnlen
move	mvn	0,0
	bra	next
crossbank	ldy	mvnlen
	pea	$E1E1
	plb
	plb
	short	a
bkcpy	lda	[addr],y
	sta	(scrn),y
	dey
	bpl	bkcpy
	long	a
next	phk
	plb
	clc
	lda	addr
	adc	picwidth
	sta	addr
	lda	addr+2
	adc	#0
	sta	addr+2
	lda	scrn
	adc	#160
	sta	scrn
	dec	height
	bpl	yloop

	rts

border	ds	2

xpos	ds	2
ypos	ds	2
mvnlen	ds	2
scrnheight	ds	2
height	ds	2


               END

**************************************************************************
*
* fatal tool error checker
*
**************************************************************************

chkerror	START

	bcs	ohshit
	rts

ohshit	SysFailMgr (@a,#shitmsg)
shitmsg	str	'ImageQuant failure: '

	END

**************************************************************************
*
* This is a dummy routine for stuff we haven't written
*
**************************************************************************

doNothing	START      

	rts

	END

**************************************************************************
*
* ImageQuant global data
*
**************************************************************************

Globals	DATA                                   

ID	dc	i2'0'
StartStop	dc	i4'0'
WindowPort	dc	i4'0'
QuitFlag	dc	i2'0'

Loaded	dc	i2'0'	;raw file data
LoadPtr	dc	i4'0'
LoadHandle	dc	i4'0'

ImagePtr	dc	i4'0'	;raw image data
ImageWidth	dc	i2'0'
ImageHeight	dc	i2'0'

picbuf	dc	i4'0'	;quantized picture data
picpal	dc	i4'0'
picscb	dc	i4'0'
picwidth	dc	i2'0'
picheight	dc	i2'0'
PicType	dc	i2'picNone'

EventRecord	anop
EventWhat	ds	2
EventMessage	ds	4
EventWhen	ds	4
EventWhere	ds	4
EventModifiers	ds	2
TaskData	ds	4
TaskMask	dc	i4'%001111010100010111111'
TaskLastClick	ds	4
TaskClickCnr	ds	2
TaskData2	ds	4
TaskData3	ds	4
TaskData4	ds	4
TaskClickPt	ds	8

LoadHand	ds	4
ConvertHand	ds	4
QuantHand	ds	4
DitherHand	ds	4
SaveHand	ds	4
LoadButHand	ds	4
ConvertButHand	ds	4
SaveButHand	ds	4
ViewButHand	ds	4
QuitButHand	ds	4
TitleHand	ds	4

palr	ds	16*2
palg	ds	16*2
palb	ds	16*2
palr2	ds	16*2
palg2	ds	16*2
palb2	ds	16*2

	END
