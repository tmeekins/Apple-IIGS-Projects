*
* SoniqTracker main
*

	mcopy	m/main.mac

	copy	text.equ

KBD      	gequ  $E0C000                  keyboard latch
KBDSTROBE 	gequ 	$E0C010                  turn off keypressed flag
MOUSEDATA 	gequ 	$E0C024                  X or Y mouse data register
KEYMODREG 	gequ 	$E0C025                  key modifier register
KMSTATUS 	gequ  $E0C027                  kbd/mouse status register
BUTN0    	gequ  $E0C061                  Read switch 0 (open-Apple)
BUTN1    	gequ  $E0C062                  Read switch 1 (option)

main	START

	using	GSOSData
	using	textdata
	using	gendata
	using	songdata

	phk
	plb

	TLStartUp
	jsr	chkerror

	MMStartUp @x
               jsr	chkerror
	stx	sysid
	txa
	clc
	adc	#$100
	sta	MMID
	adc	#$100
	sta	SongID

	MTStartUp
	jsr	chkerror

	jsr	clearscreen
	short	a
	lda	>$E1C034
	sta	oldborder
	lda	#0
	sta	>$E1C034
	lda	#$C1
	sta	>$E1C029
	long	a
	jsr	splasher
	jsr	loadplayer
	jsr	loadabout
	jsr	loadblanker
	jsr	waitevent
	jsr	clearscreen
	short	a
	lda	oldborder
	sta	>$E1C034
	long	a

               StartUpTools (MMID,#0,#startstoprec),@xy
	jsr	chkerror
	stx	startstopref
	sty	startstopref+2

	GetAddress #2,conadr
	jsr	InitZones

	ld2	31,>InstListCtl+$1A
	ld2	9,>InstListCtl+$1C
	ld2	%11,>InstListCtl+$1E
	ld4	instlisttbl,>InstListCtl+$2A
	ld4	DrawInstMember,>InstListCtl+$22
	jsr	LoadConfig
	jsr	setvolume

	NewMenuBar2 (#0,#menubar,#0),@xy
               jsr	chkerror
	stx	menubarhand
	sty	menubarhand+2
	SetSysBar @yx
	SetMenuBar #0
	FixAppleMenu #1
	FixMenuBar @y
	DrawMenuBar

	NewWindow2 (#0,#0,#InstContDraw,#0,#0,#InstWindow,#$800E),InstPort
	GetCtlHandleFromID (InstPort,#12),0
	HLock	0
	lda	[0]
	sta	4
	ldy	#2
	lda	[0],y
	sta	6
	ldy	#$1C	;ctlData
	lda	[4],y
	sta	InstLEHand
	ldy	#$1C+2
	lda	[4],y
	sta	InstLEHand+2
	HUnlock 0

	NewWindow2 (#0,#0,#AlarmContDraw,#0,#0,#AlarmWindow,#$800E),AlarmPort
	GetCtlHandleFromID (AlarmPort,#17),@ax
	SetCtlAction (#AlarmHourAction,@xa)
	GetCtlHandleFromID (AlarmPort,#18),@ax
	SetCtlAction (#AlarmMinuteAction,@xa)
	GetCtlHandleFromID (AlarmPort,#19),@ax
	SetCtlAction (#AlarmAMPMAction,@xa)
	GetCtlHandleFromID (InstPort,#13),@ax
	HiliteControl (#255,@xa)
	GetCtlHandleFromID (InstPort,#14),@ax
	HiliteControl (#255,@xa)
	GetCtlHandleFromID (InstPort,#15),@ax
	HiliteControl (#255,@xa)
	GetCtlHandleFromID (InstPort,#16),@ax
	HiliteControl (#255,@xa)
                                                
	InitCursor

	stz	QuitFlag
	jsr	InstallOneSec

EventLoop	anop
	TaskMaster (#$FFFF,#EventRecord),@y
	jsr	chkerror
	phy
	jsr	CheckOneSec
	jsr	CheckMouse
	ply
	cpy	#$22+1
	bcs	EventLoop
	tya
	asl	a
	tax
	
	jsr	(eventtbl,x)

Event2	lda	QuitFlag
	beq	EventLoop

blah	jsr	SaveConfig
	CloseWindow InstPort
	CloseWindow AlarmPort

	CloseAllNDAs

	DisposeAll SongID
	DisposeAll MMID

               IntSource #7             ;Disable one second interrupt
	ShutDownTools (#0,startstopref)
	MTShutDown
	MMShutDown sysid
	TLShutDown

	Quit	QuitParm
QuitParm	dc	i'0'
	dc	i4'0'

eventtbl	dc	i'donothing'	;$00 - null
	dc	i'ResetSB'       	;$01 - mouse-down
	dc	i'donothing'       ;$02 - mouse-up
	dc	i'doKeyEvent'      ;$03 - key-down
	dc	i'donothing'
	dc	i'doKeyEvent'      ;$05 - auto-key
	dc	i'donothing'	;$06 - update event
	dc	i'donothing'
	dc	i'donothing'       ;$08 - Activate
	dc	i'ResetSB'       	;$09 - Switch
	dc	i'ResetSB'       	;$0A - Desk Acc
	dc	i'donothing'       ;$0B - Device driver
	dc	i'donothing'       
	dc	i'donothing'
	dc	i'donothing'
	dc	i'donothing'
	dc	i'ResetSB'	;$10 - in desktop
	dc	i'doMenu'       	;$11 - in sys menu bar
	dc	i'donothing'       ;$12 - system click
	dc	i'donothing'       ;$13 - in content
	dc	i'donothing'       ;$14 - in drag
	dc	i'donothing'       ;$15 - in grow
	dc	i'doClose'       	;$16 - in go-away
	dc	i'donothing'       ;$17 - in zoom
	dc	i'donothing'       ;$18 - in info
	dc	i'donothing'       ;$19 - ID 250-255
	dc	i'donothing'       ;$1A - ID 1-249
	dc	i'donothing'       ;$1B - in frame
	dc	i'donothing'       ;$1C - inactive menu selected
	dc	i'donothing'       ;$1D - Desk acc closed
	dc	i'donothing'       ;$1E - called sys edit
	dc	i'donothing'       ;$1F - track zoom
	dc	i'donothing'       ;$20 - hit frame
	dc	i'doControl'       ;$21 - in control
	dc	i'donothing'       ;$22 - in control menu
                                                         
donothing	rts

oldborder	ds	2
sysid	ds	2

startstopref	ds	4
startstoprec	DC 	I2'$0000' 	; flags
           	DC 	I2'$C080' 	; videoMode
           	DS 	6
           	DC 	I2'18' 	; numTools
           	DC 	I2'2,$0300' 	; Memory Manager
           	DC 	I2'3,$0300' 	; Miscellaneous Tools
           	DC 	I2'4,$0301' 	; QuickDraw II
           	DC 	I2'5,$0302' 	; Desk Manager
           	DC 	I2'6,$0300' 	; Event Manager
	dc	i2'8,$0200'	; Sound Tools
           	DC 	I2'11,$0200' 	; Integer Math
           	DC 	I2'14,$0301' 	; Window Manager
           	DC 	I2'15,$0301' 	; Menu Manager
           	DC 	I2'16,$0301' 	; Control Manager
           	DC 	I2'18,$0301' 	; QuickDraw II Aux.
           	DC 	I2'20,$0301' 	; LineEdit Tools
           	DC 	I2'21,$0301' 	; Dialog Manager
           	DC 	I2'22,$0300' 	; Scrap Manager
           	DC 	I2'23,$0301' 	; Standard File Tools
           	DC 	I2'27,$0301' 	; Font Manager
           	DC 	I2'28,$0301' 	; List Manager
           	DC 	I2'30,$0100' 	; Resource Manager

menubarhand	ds	4

menubar	dc	i2'0'
	dc	i2'0'
	dc	i4'applemenu'
	dc	i4'filemenu'
	dc	i4'editmenu'
	dc	i4'soundmenu'
	dc	i4'windowmenu'
	dc	i4'0'

applemenu	dc	i2'0'
	dc	i2'1'
	dc	i2'%0000000000001000'
	dc	i4'appletitle'
	dc	i4'aboutitem'
	dc	i4'0'

filemenu	dc	i2'0'
	dc	i2'2'
	dc	i2'%0000000000101000'
	dc	i4'filetitle'
	dc	i4'openitem'
	dc	i4'quititem'
	dc	i4'0'
       
editmenu	dc	i2'0'
	dc	i2'3'
	dc	i2'%0000000010101000'
	dc	i4'edittitle'
	dc	i4'undoitem'
	dc	i4'cutitem'
	dc	i4'copyitem'
	dc	i4'pasteitem'
	dc	i4'clearitem'
	dc	i4'0'
     
soundmenu	dc	i2'0'
	dc	i2'4'
	dc	i2'%0000000000101000'
	dc	i4'soundtitle'
	dc	i4'playitem'
	dc	i4'jukeitem'
	dc	i4'prefitem'
	dc	i4'0'
    
windowmenu	dc	i2'0'
	dc	i2'5'
	dc	i2'%0000000000101000'
	dc	i4'windowstitle'
	dc	i4'institem'
	dc	i4'alarmwinitem'
	dc	i4'0'

aboutitem	dc	i2'0'       
	dc	i2'256'
	dc	c'?/'
	dc	i2'0'
	dc	i2'%0000000001000000'
	dc	i4'aboutname'

openitem	dc	i2'0'
	dc	i2'257'
	dc	c'Oo'
	dc	i2'0'
	dc	i2'%0000000001000000'
	dc	i4'openname'
                                
quititem	dc	i2'0'
	dc	i2'258'
	dc	c'Qq'
	dc	i2'0'
	dc	i2'%0000000000000000'
	dc	i4'quitname'
                          
undoitem	dc	i2'0'
	dc	i2'250'
	dc	c'Zz'
	dc	i2'0'
	dc	i2'%0000000011000000'
	dc	i4'undoname'
                          
cutitem        dc	i2'0'
	dc	i2'251'
	dc	c'Xx'
	dc	i2'0'
	dc	i2'%0000000010000000'
	dc	i4'cutname'
                         
copyitem       dc	i2'0'
	dc	i2'252'
	dc	c'Cc'
	dc	i2'0'
	dc	i2'%0000000010000000'
	dc	i4'copyname'
                          
pasteitem      dc	i2'0'
	dc	i2'253'	
	dc	c'Vv'
	dc	i2'0'
	dc	i2'%0000000010000000'
	dc	i4'pastename'
                         
clearitem      dc	i2'0'
	dc	i2'254'
	dc	i1'0,0'
	dc	i2'0'
	dc	i2'%0000000010000000'
	dc	i4'clearname'
                        
playitem       dc	i2'0'
	dc	i2'259'
	dc	c'Pp'
	dc	i2'0'
	dc	i2'%0000000010000000'
	dc	i4'playname'
                 
prefitem       dc	i2'0'       
	dc	i2'260'
	dc	h'0000'
	dc	i2'0'
	dc	i2'%0000000000000000'
	dc	i4'prefname'
                 
jukeitem       dc	i2'0'
	dc	i2'261'
	dc	c'Jj'
	dc	i2'0'
	dc	i2'%0000000001000000'
	dc	i4'jukename'
                 
institem       dc	i2'0'       
	dc	i2'262'
	dc	h'0000'
	dc	i2'0'
	dc	i2'%0000000010000000'
	dc	i4'instname'
                 
alarmwinitem   dc	i2'0'       
	dc	i2'263'
	dc	h'0000'
	dc	i2'0'
	dc	i2'%0000000000000000'
	dc	i4'alarmwinname'
                 
appletitle	str	'@'           
filetitle	str	'  File  '
edittitle	str	'  Edit  '
soundtitle	str	'  Sound  '
windowstitle	str	'  Windows  '

aboutname	str	'About soniqTracker...'
openname	str	'Open...'
quitname       str	'Quit'
undoname       str	'Undo'
cutname        str	'Cut'
copyname       str	'Copy'
pastename      str	'Paste'
clearname      str	'Clear'
playname       str	'Play Music'
jukename	str	'JukeBox Player...'
prefname	str	'Preferences...'
instname	str	'Instruments'
alarmwinname	str	'soniqAlarm'

	END

*
* Handle a menu
*

doMenu	START

	using	GSOSData

	lda	TaskData
	cmp	#250
	bcc	donothing	
               sec
	sbc	#250
	asl	a
	tax
	jsr	(menutbl,x)

	jsr	ResetSB
	lda	TaskData+2
	HiliteMenu (#$FFFF,@a)

donothing	rts

menutbl	dc	i2'donothing'	;250 - Undo
	dc	i2'donothing'      ;251 - Cut
	dc	i2'donothing'      ;252 - Copy
	dc	i2'donothing'      ;253 - Paste
	dc	i2'donothing'      ;254 - Clear
	dc	i2'donothing'      ;255
	dc	i2'doabout'      	;256 - About
	dc	i2'doopen'      	;257 - Open
	dc	i2'doquit'      	;258 - Quit
	dc	i2'doPlay'      	;259 - Play
	dc	i2'doPref'      	;260 - Preferences
	dc	i2'doJuke'      	;261 - JukeBox
	dc	i2'ShowInstWind'	;262 - Instruments
	dc	i2'ShowAlarmWind'	;263 - Alarm
	dc	i2'donothing'	;264
      
	END

*
* The About box
*

doAbout	START

	using	GSOSData
	using textdata

	HideCursor
	HideMenuBar

	stz	thermoflag
	stz	jukeflag

	jsr	clearscreen

	short	a
	lda	>$E1C034
	sta	oldborder
	lda	#0
	sta	>$E1C034
	long	a

	ph4	AboutPic
	ph2	AboutSize
	jsl	UNLZSSPic

	lda	#$0000
	sta	backcolor
	lda	#$3333
	sta	forecolor

               stz	index

bigloop	EventAvail (#$2A,#eventrec),@a
	beq	okcmd
	GetNextEvent (#$2A,#eventrec),@a
	lda	eventrec
	beq	okcmd
	jmp	done

okcmd	ldx	index
	inc	index
	lda   script,x
	and	#$FF
	asl	a
	tax
	jmp	(cmdtbl,x)

cmdtbl	dc	i2'endscript'
	dc	i2'puttext'
	dc	i2'pause'

endscript	stz	index
	bra	bigloop

pause	ldx	#60	;1 second
	short	a
wvbl1	lda   $E1C019
               bmi   wvbl1
wvbl2	lda   $E1C019
               bpl   wvbl2
	long	a
	phx
	EventAvail (#$2A,#eventrec),@a
	beq	pauseack
pause2	plx
	short	a
	dex
	bne	wvbl1
	long	a
	bra	bigloop

pauseack	GetNextEvent (#$2A,#eventrec),@a
	lda	eventrec
	beq	pause2
	plx
	jmp	done

puttext	ldx	index
	inc	index
	inc	index
	lda	script,x
	sta	textptr
	lda	#^str0
	sta	textptr+2
	jsr	cleartext
	jsr	centertext
	jsr	drawtext
	ldx	index
	inc	index
	lda	script,x
	and	#$FF
	asl	a
	tax
	jmp	(blasttbl,x)

blasttbl	dc	i2'blast1'
	dc	i2'blast2'
	dc	i2'blast3'

blast1	ldx	#160*7-2
blast1a	lda	textbuf,x
	sta	$E12000+160*65,x
	dex
	dex
	bpl	blast1a
	jmp	bigloop

blast2	ldx	#160*7-2
blast2a	lda	textbuf,x
	sta	$E12000+160*75,x
	dex
	dex
	bpl	blast2a
	jmp	bigloop

blast3	ldx	#160*7-2
blast3a	lda	textbuf,x
	sta	$E12000+160*85,x
	dex
	dex
	bpl	blast3a
	jmp	bigloop

done	short	a
	lda	oldborder
	sta	>$E1C034
	long	a

           	InitColorTable #$E19E00
               GetMasterSCB @a
               SetAllSCBs @a
               RefreshDesktop #0
	ShowMenuBar
               InitCursor

	pla		;skip the menu rts
	rts

eventrec	ds	$10
oldborder	ds	2
index	ds	2

script	dc	h'01',i2'str1',h'00'
	dc	h'01',i2'str2',h'01'
	dc	h'01',i2'str3',h'02'
	dc	h'0202020202'
	dc	h'01',i2'str0',h'01'
	dc	h'01',i2'str19',h'02'
	dc	h'0202020202'
	dc	h'01',i2'str4',h'00'
	dc	h'01',i2'str0',h'01'
	dc	h'01',i2'str5',h'02'
	dc	h'02020202'
	dc	h'01',i2'str6',h'02'
	dc	h'02020202'
	dc	h'01',i2'str8',h'00'
	dc	h'01',i2'str9',h'02'
	dc	h'020202'
	dc	h'01',i2'str11',h'02'
	dc	h'020202'
	dc	h'01',i2'str18',h'02'
	dc	h'020202'
	dc	h'01',i2'str10',h'02'
	dc	h'020202'
	dc	h'01',i2'str16',h'02'
	dc	h'020202'
	dc	h'01',i2'str17',h'02'
	dc	h'020202'
	dc	h'01',i2'str20',h'02'
	dc	h'020202'
	dc	h'01',i2'str21',h'02'
	dc	h'020202'
	dc	h'01',i2'str12',h'02'
	dc	h'0202020202'         
	dc	h'01',i2'str13',h'00'
	dc	h'01',i2'str14',h'02'
;	dc	h'02020202'
;	dc	h'01',i2'str15',h'02'
	dc	h'0202020202'
                          
	dc	h'00'

str0	dc	c' ',h'00'
str1	dc	c'soniqTracker 0.6.3',h'00'
str2	dc	c'April 22, 1993',h'00'
str3	dc	c'Copyright (c) 1992,1993 by Tim Meekins',h'00'
str4	dc	c'CREDITS:',h'00'
str5	dc	c'Coding: Tim Meekins',h'00'
str6	dc	c'Artwork: Dave Seah',h'00'
str8	dc	c'Special Thanx!',h'00'
str9	dc	c'James Brookes',h'00'
str10	dc	c'Chris McKinsey',h'00'
str11	dc	c'Ian Schmidt',h'00'
str12	dc	c'and to everyone who sent me bug reports and suggestions!',h'00'
str13	dc	c'NOTES:',h'00'
str14	dc	c'This version of soniqTracker is FreeWare!',h'00'
;str15	dc	c"Continuing to support the II in '92",h'00'
str16	dc	c'Bill Heineman',h'00'
str17	dc	c'Jim Maricondo',h'00'
str18	dc	c'Max the Dog',h'00'
str19	dc	c'Apple Expo West Special Edition',h'00'
str20	dc	c'Jason Andersen',h'00'
str21	dc	c'Jawaid Bazyar',h'00'

	END

*
* Quit? You gotta be kidding!
*

doQuit	START

	using	GSOSData

	lda	#1
	sta	QuitFlag
	rts

	END

*
* do preferences
*

doPref	START

	using	GSOSData
	using	gendata
	using	Tables


	NewWindow2 (#0,#0,#ContentDraw,#0,#0,#PrefWindow,#$800E),WindowPort
               ShowWindow WindowPort
	SelectWindow WindowPort
	InitCursor

doNothing	anop
PrefLoop	TaskMaster (#%1111111111110111,#EventRecord),@a
	cmp	#$21
	bne	PrefLoop

inControl	lda	TaskData4
	cmp	#10+1
	bcs	done
	asl	a
	tax
	jmp	(ControlTbl,x)

done	jsr	setvolume
	CloseWindow WindowPort
	rts

ControlTbl	dc	i2'doNothing'	;0  - no control
	dc	i2'doNothing'	;1  - pre-title-control
	dc	i2'dofifty'	;2  - 50 hz button
	dc	i2'dosixty'	;3  - 60 hz button
	dc	i2'doNothing'	;4  - hertz title
	dc	i2'doNothing'	;5  - play arp
	dc	i2'doNothing'	;6  - use protracker
	dc	i2'dostereo'      	;7  - stereo menu
	dc	i2'done'      	;8  - ok button
	dc	i2'dolights'	;9  - dancing lights
	dc	i2'dovolume'	;10 - volume setting

ContentDraw	DrawControls WindowPort
	rtl

dofifty	ld2	250,PlayHertz
	ld2	1,>FiftyHzButton+$1E
	ld2	0,>SixtyHzButton+$1E
	jmp	prefloop

dosixty	ld2	300,PlayHertz
	ld2	1,>SixtyHzButton+$1E
	ld2	0,>FiftyHzButton+$1E
	jmp	prefloop

dolights	lda	>CTLTMP_00000009+$1E
	eor	#1
	sta	>CTLTMP_00000009+$1E         
	sta	lightsFlag
	jmp	prefloop

dostereo	GetCtlHandleFromID (#0,#7),@ax
	GetCtlValue @xa,@a
	sta	>StereoMenuControl+$20
	jmp	prefloop

dovolume	GetCtlHandleFromID (#0,#10),@ax
	GetCtlValue @xa,@a
	sta	>VolMenuControl+$20
	jmp	prefloop

item	ds	2
WindowPort	ds	4         

EventRecord	anop
EventWhat	ds	2
EventMessage	ds	4
EventWhen	ds	4
EventWhere	ds	4
EventModifiers	ds	2
TaskData	ds	4
TaskMask	dc	i4'%001111010100010110111'
TaskLastClick	ds	4
TaskClickCnr	ds	2
TaskData2	ds	4
TaskData3	ds	4
TaskData4	ds	4
TaskClickPt	ds	8
                      
	END

*
* play the mod
*

doPlay	START

	using	GSOSData
	using textdata

	HideCursor
	HideMenuBar

	stz	jukeflag

	jsr	clearscreen

	short	a
	lda	>$E1C034
	sta	oldborder
	lda	#0
	sta	>$E1C034
	long	a

	ph4	PlayerPic
	ph2	PlayerSize
	jsl	UNLZSSPic

	jsr	pauselight

	lda	#$6666
	sta	backcolor
	lda	#$9999
	sta	forecolor
	lda	#modname
	sta	textptr
	lda	#^modname
	sta	textptr+2	

	jsr	cleartext
	jsr	centertext
	jsr	drawtext
	jsr	scrollview
	jsr	playmod

	short	a
	lda	oldborder
	sta	>$E1C034
	long	a

           	InitColorTable #$E19E00
               GetMasterSCB @a
               SetAllSCBs @a
               RefreshDesktop #0
	ShowMenuBar
               InitCursor

	pla		;skip the menu rts
	rts

oldborder	ds	2

	END

*
* open a mod
*

doOpen	START

	using	GSOSData
	using	gendata

	SFGetFile2 (#120,#43,#0,#prompt,#0,#0,#replyrec)
	bcc	load0
	AlertWindow (#0,#0,#sfmsg),@a
zap1	rts

load0	lda	replyrec
	beq	zap1

	stz	thermoflag

	WaitCursor

	jsl	killsong

	mv4	nameref,0
	lda	[0]
	inc	a
	inc	a
	sta	OpenPath
	ldy	#2
	lda	[0],y
	sta	OpenPath+2

	jsl	openfile
	bcs	damn
               jsl	loadmod
	bcs	damn

	jsr	ShowInstWind
	GetCtlHandleFromID (InstPort,#11),@ax
	DrawOneCtl @xa
	jsr	doInstList

	EnableMItem #259
	EnableMItem #262
	DrawMenuBar
	HiliteMenu (#$FFFF,#2)	;Since draw menu bar lost our hiliting

	Close CloseParm
	InitCursor
	bra	done              

damn	pha
	Close	CloseParm
	InitCursor
	pla
	ErrorWindow (#0,#0,@a),@a
               HideWindow InstPort
	DrawMenuBar
	HiliteMenu (#$FFFF,#2)	;Since draw menu bar lost our hiliting

done	DisposeHandle nameref
	DisposeHandle pathref
	rts

replyrec	ds	2
filetype	ds	2
auxtype	ds	4
	dc	i2'3'
nameref	ds	4
	dc	i'3'
pathref	ds	4

prompt	str	'Select music to load'
sfmsg	dc	c'23/Standard File boo-boo/OK',h'00'

	END

*
* The JukeBox Player
*

doJuke	START

stbl	equ	0

	using	GSOSData
	using	textbuffers

	SFPMultiGet2 (#120,#34,#0,#0,#prompt,#0,#0,#GetDialog640,#dlghook,#replyrec)
	bcc	load0
	AlertWindow (#0,#0,#sfmsg),@a
zap1	rts

load0	lda	replyrec
	beq	zap1

	HideCursor

	jsl	killsong

	HideMenuBar

	lda	#1
	sta	thermoflag
	sta	jukeflag

	jsr	clearscreen

	short	a
	lda	>$E1C034
	sta	oldborder
	lda	#0
	sta	>$E1C034
	long	a

	ph4	PlayerPic
	ph2	PlayerSize
	jsl	UNLZSSPic

	jsr	pauselight

               mv4	replyhand,stbl
	lda	[stbl]
	tax
	ldy	#2
	lda	[stbl],y
	sta	stbl+2
	stx	stbl
	
	stz	numsongs

	add4	stbl,#2,stbl	;skip buffer length

fixlistloop	add4	stbl,#5,stbl	;skip filetype and 3 bytes of aux
	lda	[stbl]
	xba
	and	#$FF
	sta	[stbl]
	lda	numsongs
	asl	a
	asl	a
	tax
	lda	stbl
	sta	songlist,x
	lda	stbl+2
	sta	songlist+2,x
	lda	[stbl]
	inc	a
	inc	a
	clc
	adc	stbl	;len byte + 1 byte from the aux + len
	sta	stbl
	bcc	fl2
	inc	stbl+2
fl2	inc	numsongs
	lda	numsongs
	cmp	#300
	beq	startshuffle
	dec	replyrec
	lda	replyrec
	bne	fixlistloop
	bra	startshuffle

song	equ	4

startshuffle	lda	shuffleflag
	beq	startjuke			
	stz	song
	lda	>$E0C02E
	tax
	SetRandSeed @xa
shuffleloop    Random @a
	UDivide (@a,numsongs),(@x,@a)
	asl	a
	asl	a
	tay
	lda	song
	asl	a
	asl	a
	tax
	lda	songlist,x
	pha
	lda	songlist,y
	sta	songlist,x
	pla
	sta	songlist,y
	lda	songlist+2,x
	pha
	lda	songlist+2,y
	sta	songlist+2,x
	pla
	sta	songlist+2,y
	inc	song	
	lda	song
	cmp	numsongs
	bne	shuffleloop

startjuke	stz	songnum
	stz	goodcount

getsong	lda	#loadingbuf
	ldx	#^loadingbuf
	jsr	showzone
	lda	#$6666
	sta	backcolor
	lda	#$9999
	sta	forecolor
	lda	#loadstr
	sta	textptr
	lda	#^loadstr
	sta	textptr+2	
	jsr	cleartext
	jsr	centertext
	jsr	drawtext
	jsr	scrollview

	lda	songnum
	asl	a
	asl	a
	tax
	lda	songlist,x
	sta	OpenPath
	lda	songlist+2,x
	sta	OpenPath+2

	DisposeAll SongID

	jsl	openfile
	bcs	nextsong
               jsl	loadmod
	bcs	nextsong

	inc	goodcount

	lda	#$6666
	sta	backcolor
	lda	#$9999
	sta	forecolor
	lda	#modname
	sta	textptr
	lda	#^modname
	sta	textptr+2	

	jsr	cleartext
	jsr	centertext
	jsr	drawtext
	jsr	scrollview

playsong	jsr	playmod
	cmp	#$1B	;ESC (OPTION)
	beq	done
	cmp	#'q'
	beq	done
	cmp	#'Q'
	beq	done

nextsong	Close CloseParm
	inc	songnum
	lda	songnum
	cmp	numsongs
	jcc	getsong
	stz	songnum
	lda	goodcount
	beq	done
	stz	goodcount
	jmp	getsong	
               
done	Close	CloseParm

	DisposeHandle replyhand
	DisposeAll SongID

               HideWindow InstPort
               
	short	a
	lda	oldborder
	sta	>$E1C034
	long	a

           	InitColorTable #$E19E00
               GetMasterSCB @a
               SetAllSCBs @a
               RefreshDesktop #0
	ShowMenuBar
               InitCursor

	pla		;skip the menu rts
	rts

goodcount	ds	2

oldborder	ds	2
                                
replyrec	ds	2
replyhand	ds	4

songnum	ds	2
numsongs	ds	2
songlist	ds	4*300	;maximum of 300 songs

prompt	str	'Choose Jukebox Music'
sfmsg	dc	c'23/Standard File boo-boo/OK',h'00'
loadstr	dc	c'Loading Music',h'00'
OpenStr	str	'Open'
CloseStr	str	'Close'
DriveStr	str	'Volumes'
CancelStr	str	'Cancel'
AcceptStr	str	'Accept'
ShuffleStr	str	'Shuffle Songs'

buttonItem	gequ	$000A	;Standard button control
checkItem	gequ	$000B	;Standard check box control
statText	gequ	$000F	;Static text; text that cannot be edited
userItem	gequ	$0014	;Application-defined item
itemDisable	gequ	$8000	;Added to any item, this disables item

GetDialog640	dc	i2'0,0,132,400'	;recommended drect of dialog

	dc	i2'-1'
	dc	i2'0,0'            ;reserved
	dc	a4'OpenBut640'	;item 1
	dc	a4'CloseBut640'	;item 2
	dc	a4'NextBut640'	;item 3
	dc	a4'CancelBut640'	;item 4
	dc	a4'Scroll640'	;dummy item or ACCEPT button
	dc	a4'Path640'	;item 6
	dc	a4'Files640'	;item 7
	dc	a4'Prompt640'	;item 8
	dc	a4'Shuffle640'	;item 9
	dc	i4'0'

OpenBut640	dc	i2'1'	;item #
	dc	i2'61,265,73,375'	;drect
	dc	i2'buttonItem'	;type of item
	dc	a4'OpenStr'	;item descriptor
	dc	i2'0,0'	;item value & bit flags
	dc	i4'0'	;color table ptr

CloseBut640	dc	i2'2'	;item #
	dc	i2'79,265,91,375'	;drect
	dc	i2'buttonItem'	;type of item
	dc	a4'CloseStr'	;item descriptor
	dc	i2'0,0'	;item value & bit flags
	dc	i4'0'	;color table ptr

NextBut640	dc	i2'3'	;item #
	dc	i2'25,265,37,375'	;drect
	dc	i2'buttonItem'	;type of item
	dc	a4'DriveStr'	;item descriptor
	dc	i2'0,0'	;item value & bit flags
	dc	i4'0'	;color table ptr

CancelBut640	dc	i2'4'	;item #
	dc	i2'97,265,109,375'	;drect
	dc	i2'buttonItem'	;type of item
	dc	a4'CancelStr'	;item descriptor
	dc	i2'0,0'	;item value & bit flags
	dc	i4'0'	;color table ptr

Scroll640	dc	i2'5'	;item #
	dc	i2'43,265,55,375'	;drect
	dc	i2'buttonItem'	;type of item
	dc	a4'AcceptStr'	;item descriptor
	dc	i2'0,0'	;item value & bit flags
	dc	i4'0'	;color table ptr

Path640	dc	i2'6'	;item #
	dc	i2'12,15,24,395'	;drect
	dc	i2'userItem'	;type of item
	dc	i4'0'	;item descriptor
	dc	i2'0,0'	;item value & bit flags
	dc	i4'0'	;color table ptr

Files640	dc	i2'7'	;item #
	dc	i2'25,18,107,215'	;drect
	dc	i2'userItem+itemDisable' ;type of item
	dc	i4'0'	;item descriptor
	dc	i2'0,0'	;item value & bit flags
	dc	i4'0'	;color table ptr

Prompt640	dc	i2'8'	;item #
	dc	i2'03,15,12,395'	;drect
	dc	i2'statText+ItemDisable' ;type of item
	dc	i4'0'	;item descriptor
	dc	i2'0,0'	;item value & bit flags
	dc	i4'0'	;color table ptr

Shuffle640	dc	i2'9'	;item #
	dc	i2'115,18,127,395'	;drect
	dc	i2'checkItem' ;type of item
	dc	a4'ShuffleStr'	;item descriptor
ShuffleVal	ENTRY
	dc	i2'0,0'	;item value & bit flags
	dc	i4'0'	;color table ptr

dlghook	tsc                             
	phd
	tcd

	lda	[4]	;item hit
	cmp	#9	;was it shuffle?
	bne	donehook
	lda	#0
               sta	[4]
	GetDItemValue (8,#9),@a
	eor	#1
	sta	>shuffleflag
	sta	>ShuffleVal
	SetDItemValue (@a,8,#9)

donehook	pld
	pla
	short	i
	plx
	long	i
	ply
	ply
	ply
	ply
	short	i
	phx
	long	i
	pha
	rtl	

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
shitmsg	str	'soniqTracker massive failure: '

	END

*
* do the splash screen!
*

splasher	START

	using	GSOSData

hand	equ	0

	Open	openparm
	jsr	chkerror
	mv2	openref,(readref,closeref)
               NewHandle (openeof,MMID,#$C018,#0),hand
	lda	[hand]
	sta	readbuf
	ldy	#2
	lda	[hand],y
	sta	readbuf+2
	mv4	openeof,readreq
	Read	readparm
	jsr	chkerror
	Close	closeparm

	ph4	readbuf
	ph2	readtrans
	jsl	UNLZSSPic
	DisposeHandle hand

	rts

openparm	dc	i2'12'
openref	dc	i2'0'
	dc	i4'name'
	dc	i2'1'
	dc	i2'0'
	dc	i2'0'
	dc	i2'0'
	dc	i4'0'
	dc	i2'0'
	ds	8
	ds	8
	dc	i4'0'
openeof	dc	i4'0'

readparm	dc	i2'4'
readref	dc	i2'0'
readbuf	dc	i4'0'
readreq	dc	i4'0'
readtrans	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

name	gsstr	'9:soniqDATA:DATA01'

	END

*
* clear the screen
*

clearscreen	START

	ldx	#$1000-2
	lda	#0
loop	sta	>$E12000,x
	sta	>$E13000,x
	sta	>$E14000,x
	sta	>$E15000,x
	sta	>$E16000,x
	sta	>$E17000,x
	sta	>$E18000,x
	sta	>$E19000,x
	dex        
	dex
	bpl	loop
	rts

	END

*
* wait event
*

waitevent	START

        	short	ai
         	lda   #$00
         	lda   >MOUSEDATA               X or Y mouse data register
         	sta   >KBDSTROBE               turn off keypressed flag
L01560A  	long	ai
         	lda   #$0096
       	short	ai
         	lda   >KBD                     keyboard latch
         	bmi   L015647
         	lda   >BUTN0                   Read switch 0 (open-Apple)
         	bmi   L015645
         	lda   >BUTN1                   Read switch 1 (option)
         	bmi   L015645
         	lda   >KMSTATUS                kbd/mouse status register
         	bpl   L01560A
         	and   #$02
         	bne   L01563F
         	lda   >MOUSEDATA               X or Y mouse data register
         	lda   >MOUSEDATA               X or Y mouse data register
         	bmi   L01560A
         	bra   L015645
L01563F  	lda   >MOUSEDATA               X or Y mouse data register
         	bra   L01560A
L015645  	lda   #$00
L015647  	long	ai
         	and   #$007F

	rts

	END

*
* load player pic
*

loadplayer	START

	using	GSOSData

hand	equ	0

	Open	openparm
	mv2	openref,(readref,closeref)
               NewHandle (openeof,MMID,#$C018,#0),hand
	lda	[hand]
	sta	readbuf
	ldy	#2
	lda	[hand],y
	sta	readbuf+2
	mv4	openeof,readreq
	Read	readparm
	Close	closeparm

	rts

openparm	dc	i2'12'
openref	dc	i2'0'
	dc	i4'name'
	dc	i2'1'
	dc	i2'0'
	dc	i2'0'
	dc	i2'0'
	dc	i4'0'
	dc	i2'0'
	ds	8
	ds	8
	dc	i4'0'
PlayerSize	ENTRY
openeof	dc	i4'0'

readparm	dc	i2'4'
readref	dc	i2'0'
PlayerPic	ENTRY
readbuf	dc	i4'0'
readreq	dc	i4'0'
	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

name	gsstr	'9:soniqDATA:DATA02'

	END

*
* load about pic
*

loadabout	START

	using	GSOSData

hand	equ	0

	Open	openparm
	mv2	openref,(readref,closeref)
               NewHandle (openeof,MMID,#$C018,#0),hand
	lda	[hand]
	sta	readbuf
	ldy	#2
	lda	[hand],y
	sta	readbuf+2
	mv4	openeof,readreq
	Read	readparm
	Close	closeparm

	rts

openparm	dc	i2'12'
openref	dc	i2'0'
	dc	i4'name'
	dc	i2'1'
	dc	i2'0'
	dc	i2'0'
	dc	i2'0'
	dc	i4'0'
	dc	i2'0'
	ds	8
	ds	8
	dc	i4'0'
AboutSize	ENTRY
openeof	dc	i4'0'

readparm	dc	i2'4'
readref	dc	i2'0'
AboutPic	ENTRY
readbuf	dc	i4'0'
readreq	dc	i4'0'
	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

name	gsstr	'9:soniqDATA:DATA03'

	END

*
* load blanker pic
*

loadblanker	START

	using	GSOSData

hand	equ	0

	Open	openparm
	mv2	openref,(readref,closeref)
               NewHandle (openeof,MMID,#$C018,#0),hand
	lda	[hand]
	sta	readbuf
	ldy	#2
	lda	[hand],y
	sta	readbuf+2
	mv4	openeof,readreq
	Read	readparm
	Close	closeparm

	rts

openparm	dc	i2'12'
openref	dc	i2'0'
	dc	i4'name'
	dc	i2'1'
	dc	i2'0'
	dc	i2'0'
	dc	i2'0'
	dc	i4'0'
	dc	i2'0'
	ds	8
	ds	8
	dc	i4'0'
BlankerSize	ENTRY
openeof	dc	i4'0'

readparm	dc	i2'4'
readref	dc	i2'0'
BlankerPic	ENTRY
readbuf	dc	i4'0'
readreq	dc	i4'0'
	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

name	gsstr	'9:soniqDATA:DATA04'

	END

; sets up the volume tables

setvolume	START

	using	gendata
	using	tables
	using	GSOSData

	lda	>VolMenuControl+$20
	sec
	sbc	#267	
	asl	a
	tax
	lda	menu2vol,x
	asl	a
	tax
	
	lda	>StereoMenuControl+$20
	dec	a
	bne	stereo2
	stz	ChannelMode
	bra	stereomono

stereo2	ldy	#%10000
	sty	ChannelMode
	cmp	#266-1
	beq	stereomono
	cmp	#263-1
	beq	stereo75
	cmp	#264-1
	beq	stereo50

stereo25	ldy	vol25idx,x
               bra	stereo3
stereo50	ldy	vol50idx,x
               bra	stereo3
stereo75	ldy	vol75idx,x	
               bra	stereo3

stereomono	ldy	vol100idx,x
stereo3	lda	vol100idx,x
	
	sta	copy1+1
	sty	copy2+1

	ldx	#$40-2
copy1	lda	voltab,x
	sta	voltab,x
copy2	lda	voltab2,x
	sta	voltab2,x
	dex
	dex
	bpl	copy1
	rts	

	END

*
* kill song
*

killsong	START

	using	GSOSData

	DisableMItem #259
	DisableMItem #262
	DisposeAll SongID

	rtl

	END

*
* Draw Instrument Window
*

InstContDraw	START

	using	GSOSData

	phb
	phk
               plb

	DrawControls InstPort

	plb
	rtl

	END

*
* Draw Alarm Window
*

AlarmContDraw	START

	using	GSOSData
	using	gendata

	phb
	phk
               plb

	DrawControls AlarmPort
	DrawIcon (#AlarmBoxIcon,#%1111000000000000,#85,#11)
	lda	AlarmHour
	inc	a
	Int2Dec (@a,#buf,#2,#0)
	SetFontFlags #%010
	MoveTo (#93,#20)
	DrawCString #buf
	DrawIcon (#AlarmBoxIcon,#%1111000000000000,#85,#30)
	lda	AlarmMinute
	Int2Dec (@a,#buf,#2,#0)
	MoveTo (#93,#39)
	DrawCString #buf
	DrawIcon (#AlarmBoxIcon,#%1111000000000000,#85,#49)
	MoveTo (#93,#58)
	lda	AlarmAMPM
	beq	doam
	DrawCString #pmstr
	bra	done
doam	DrawCString #amstr
                          
done	SetFontFlags #0

	plb
	rtl

buf	dc	c'00',h'00'
amstr	dc	c'AM',h'00'
pmstr	dc	c'PM',h'00'

	END

*
* close a window
*

doClose	START

	FrontWindow @ax
	HideWindow @xa
	jmp	ResetSB

	END

*
* event in control
*

doControl	START

	using	GSOSData

	lda	TaskData4
	asl	a
	tax
	jmp	(ControlTbl,x)

doNothing	rts

ControlTbl	dc	i2'doNothing'	;0  - no control
	dc	i2'doNothing'	;1  - pre-title-control
	dc	i2'doNothing'	;2  - 50 hz button
	dc	i2'doNothing'	;3  - 60 hz button
	dc	i2'doNothing'	;4  - hertz title
	dc	i2'doNothing'	;5  - play arp
	dc	i2'doNothing'	;6  - use protracker
	dc	i2'doNothing'      ;7  - stereo menu
	dc	i2'doNothing'      ;8  - ok button
	dc	i2'doNothing'	;9  - dancing lights
	dc	i2'doNothing'	;10 - volume setting
	dc	i2'doInstList'	;11 - inst list
	dc	i2'doNothing'	;12 - inst line edit
	dc	i2'doNothing'	;13 - inst load button
	dc	i2'doNothing'	;14 - inst save button
	dc	i2'doNothing'	;15 - inst compact button
	dc	i2'doNothing'	;16 - inst edit button
	dc	i2'doNothing'	;17 - alarm hour scroll bar
	dc	i2'doNothing'	;18 - alarm minute scroll bar
	dc	i2'doNothing'	;19 - alarm AM/PM scroll bar
	dc	i2'doNothing'	;20 - alarm hour title
	dc	i2'doNothing'	;21 - alarm minute title
	dc	i2'doNothing'	;22 - alarm AM/PM title
	dc	i2'doAlarmOnOff'	;23 - alarm activate check box
	dc	i2'doAlarmSelect'	;24 - alarm select music button
                                                                      
	END

doAlarmOnOff	START

	using	gendata
	using	GSOSData

	lda	>AlarmActBox+$1E
	eor	#1
	sta	>AlarmActBox+$1E         
	sta	AlarmFlag

	rts

	END

doAlarmSelect	START

	using	GSOSData
	using	gendata

	SFGetFile2 (#120,#43,#0,#prompt,#0,#0,#replyrec)
	bcc	load0
	AlertWindow (#0,#0,#sfmsg),@a
zap1	rts

load0	lda	replyrec
	beq	zap1

	mv4	pathref,0
	lda	[0]
	inc	a
	inc	a
	tax
	ldy	#2
	lda	[0],y
	stx	0
	sta	0+2

	lda	[0]
	cmp	#65
	bcc	ok
	lda	#0
	sta	AlarmSong
	GetCtlHandleFromID (AlarmPort,#23),@ax
	phx
	pha
	SetCtlValue (#0,@xa)
	pla
	plx
	HiliteControl (#0,@xa)
	stz	AlarmFlag
	lda	#0
	sta	>AlarmActBox+$1E         
	AlertWindow (#0,#0,#alarmmsg),@a
	bra	done
ok             tax
	ldy	#0
	inx
copy	lda	[0],y
	sta	AlarmSong,y
	iny
	dex
	bpl	copy	
	GetCtlHandleFromID (AlarmPort,#23),@ax
	HiliteControl (#0,@xa)
                  
done	DisposeHandle nameref
	DisposeHandle pathref
	rts              

replyrec	ds	2
filetype	ds	2
auxtype	ds	4
	dc	i2'3'
nameref	ds	4
	dc	i2'3'
pathref	ds	4

prompt	str	'Select music for soniqAlarm'
sfmsg	dc	c'23/Standard File boo-boo/OK',h'00'
alarmmsg	dc	c'43/Filename exceeded internal buffer! Please '
	dc	c'contact the author about this/OK',h'00'

	END

AlarmHourAction START

	using	gendata
	using	GSOSData

	lda	8,s

	cmp	#5	;left-arrow
	bne   a1
	lda   >AlarmHour
	beq	a5
	dec	a
	bra	a1a

a1	cmp	#6                 ;right-arrow
	bne	a2
	lda	>AlarmHour
	cmp	#11
	beq	a5
	inc	a
a1a	sta	>AlarmHour
	tay
	lda	6,s
	tax
	lda	4,s        
	SetCtlValue (@y,@xa)
	bra	update

a2	cmp	#7	;page-left
	bne	a3
	lda	>AlarmHour
	beq	a5
	sec
	sbc	#3
	bpl	a1a
	lda	#0
	bra	a1a

a3	cmp	#8	;page-right
	bne	a4
	lda	>AlarmHour
	cmp	#11
	beq   a5
	clc
	adc	#3
	cmp	#12
	bcc	a1a
	lda	#11
	bra	a1a

a5	bra	exit

a4	cmp	#129	;thumb
	bne	a5
	lda	6,s
	tax
	lda	4,s        
	GetCtlValue @xa,@a
	sta	>AlarmHour

update	SetPort >AlarmPort
	lda	>AlarmHour
	inc	a
	Int2Dec (@a,#buf,#2,#0)
	SetFontFlags #%010
	MoveTo (#93,#20)
	DrawCString #buf
	SetFontFlags #0
                                 
exit	lda	2,s
	sta	8,s
	lda	1,s
	sta	7,s
	pla
	pla
	pla
	rtl

buf	dc	c'00',h'00'

	END

AlarmMinuteAction START

	using	gendata
	using	GSOSData

	lda	8,s

	cmp	#5	;left-arrow
	bne   a1
	lda   >AlarmMinute
	beq	a5
	dec	a
	bra	a1a

a1	cmp	#6                 ;right-arrow
	bne	a2
	lda	>AlarmMinute
	cmp	#59
	beq	a5
	inc	a
a1a	sta	>AlarmMinute
	tay
	lda	6,s
	tax
	lda	4,s        
	SetCtlValue (@y,@xa)
	bra	update

a2	cmp	#7	;page-left
	bne	a3
	lda	>AlarmMinute
	beq	a5
	sec
	sbc	#10
	bpl	a1a
	lda	#0
	bra	a1a

a3	cmp	#8	;page-right
	bne	a4
	lda	>AlarmMinute
	cmp	#59
	beq   a5
	clc
	adc	#10
	cmp	#60
	bcc	a1a
	lda	#59
	bra	a1a

a5	bra	exit

a4	cmp	#129	;thumb
	bne	a5
	lda	6,s
	tax
	lda	4,s        
	GetCtlValue @xa,@a
	sta	>AlarmMinute

update	SetPort >AlarmPort
	lda	>AlarmMinute
	Int2Dec (@a,#buf,#2,#0)
	SetFontFlags #%010
	MoveTo (#93,#39)
	DrawCString #buf
	SetFontFlags #0
                                 
exit	lda	2,s
	sta	8,s
	lda	1,s
	sta	7,s
	pla
	pla
	pla
	rtl

buf	dc	c'00',h'00'

	END

AlarmAMPMAction START

	using	gendata
	using	GSOSData

	lda	8,s

	cmp	#5	;left-arrow
	bne   a1
a1z	lda   >AlarmAMPM
	jeq	exit
	dec	a
	bra	a1a

a1	cmp	#6                 ;right-arrow
	bne	a2
a1y	lda	>AlarmAMPM
	jne	exit
	inc	a
a1a	sta	>AlarmAMPM
	tay
	lda	6,s
	tax
	lda	4,s        
	SetCtlValue (@y,@xa)
	bra	update

a2	cmp	#7	;page-left
	beq	a1z

a3	cmp	#8	;page-right
	beq	a1y

a4	cmp	#129	;thumb
	bne	exit
	lda	6,s
	tax
	lda	4,s        
	GetCtlValue @xa,@a
	sta	>AlarmAMPM

update	SetPort >AlarmPort
	MoveTo (#93,#58)
	lda	>AlarmAMPM
	beq	doam
	DrawCString #pmstr
	bra	done
doam	DrawCString #amstr
done	SetFontFlags #0
                                 
exit	lda	2,s
	sta	8,s
	lda	1,s
	sta	7,s
	pla
	pla
	pla
	rtl

buf	dc	c'00',h'00'
amstr	dc	c'AM',h'00'
pmstr	dc	c'PM',h'00'

	END

doInstList	START                                

	using	GSOSData
	using	SongData

	jsr	findselinst
	bmi	done

gotit	anop
;	Multiply (@y,#42),@ax
	phy
	tya
	asl	a
	asl	a
	adc	1,s
	asl	a
	asl	a
	adc	1,s
	ply
	asl	a
	bcs	done

	ldx	#^instnam1
;	clc
	adc	#instnam1
	bcc	ok1
	inx
ok1	sta	4
	stx	6

	ldy	#0
getlen	lda	[4],y
	and	#$FF
	beq	gotlen
	iny
	bra	getlen
gotlen	anop

	LESetText (4,@y,InstLEHand)
	LESetSelect (#0,#32,InstLEHand)
	GetCtlHandleFromID (InstPort,#12),@ax
	DrawOneCtl @xa

done	rts

	END

***************
*
* handle keyboard events
*
***************

doKeyEvent	START

	using	GSOSData
	using	SongData

	jsr	ResetSB

	FrontWindow 0
	lda	0
	ora	2
	beq	done
;
; branch to the appropriate routines depending on which window is in front
;
	lda	0
	eor	2
	eor	InstPort
	eor	InstPort+2
	beq	doInstKey

done	rts
;
; we're in the instrument window
;
doInstKey	lda	EventModifiers
	and	#%0000100100000000
	jne	instmod
	lda	EventMessage
	and	#$7F
	cmp	#13	;RETURN
	jne	instkey2
;
; return was pressed, copy LE text to instrument name record
;
	jsr	findselinst
	bmi	done

gotit	phy
;	Multiply (@y,#42),@ax
	tya
	asl	a
	asl	a
	adc	1,s
	asl	a
	asl	a
	adc	1,s
	asl	a	
	ldx	#^instnam1
	clc
	adc	#instnam1
	bcc	ok1
	inx
ok1	sta	0
	stx	2

	LEGetTextHand InstLEHand,4
	Hlock	4
	lda	[4]
	sta	8
	ldy	#2
	lda	[4],y
	sta	10
	LEGetTextLen InstLEHand,@x
	phx
	ldy	#0
copyname	lda	[8],y
	sta	[0],y
	iny
	dex
	bmi	donecopy
	bne	copyname
donecopy	ply
	lda	#0
	sta	[0],y
	HUnlock 4
drawdone	GetPort 0
	SetPort InstPort
	GetCtlHandleFromID (InstPort,#11),@ax
	ply
	iny
	DrawMember2 (@y,@xa)
	SetPort 0

done2	rts                 

instkey2	cmp	#11	;UP-ARROW
	bne	instkey3

	jsr	findselinst
	dey
	bmi	done2	;on 0 or < 0
	iny

	phy
	GetPort 0
	SetPort InstPort
	GetCtlHandleFromID (InstPort,#11),@ax
	ply
	SelectMember2 (@y,@xa)
	SetPort 0
               jmp	doInstList

instkey3	cmp	#10	;DOWN-ARROW
	bne	instmod

	jsr	findselinst
	cpy	#-1
	beq	done2	;on 0 or < 0
	cpy	#30
	beq	done2

	phy
	GetPort 0
	SetPort InstPort
	GetCtlHandleFromID (InstPort,#11),@ax
	ply
	iny	
	iny
	SelectMember2 (@y,@xa)
	SetPort 0
               jmp	doInstList

instmod	LEKey	(EventMessage,EventModifiers,InstLEHand)

	rts

	END

findselinst	START

	using	SongData

	ldx	#0
	ldy	#0
findsel	lda	instlisttbl+4,x
	and	#$80
	bne	gotit
	inx
	inx
	inx
	inx
	inx
	iny
	cpy	#31
	bcc	findsel
	ldy	#-1
gotit	rts

	END

*
* show the instrument window
*

ShowInstWind	START

	using	GSOSData

	ShowWindow InstPort
	SelectWindow InstPort
	rts

	END

*
* show the alarm window
*

ShowAlarmWind	START

	using	GSOSData

	ShowWindow AlarmPort
	SelectWindow AlarmPort
	rts

	END

*
* draw a member of the instrument list
*

DrawInstMember	START

top	equ	0
left	equ	top+2
bottom	equ	left+2
right	equ	bottom+2
rgnBounds	equ	2

oldDPage	equ	1
theRTL	equ	oldDPage+2
listHand	equ	theRTL+3
memPtr	equ	listHand+4
theRect	equ	memPtr+4

	phd
	tsc
	tcd

	pha
	pha
	_GetClipHandle
	pl4	listHand

	ldy	#2
	lda	[listhand],y
	tax
	lda	[listhand]
	sta	listhand
	stx	listhand+2

	lda	[therect]	; now test the top
	dec	a	; adjust amd give a little slack
	ldy	#rgnbounds+bottom
	cmp	[listhand],y	; rgnRectBottom >= top ?
	bcc	skip2
	jmp	nodraw	; if not don't draw
skip2	ldy	#bottom	; now see if the bottom is higher than the top
	inc	a	; give a little slack
	lda	[therect],y
	ldy	#rgnBounds+top
	cmp	[listhand],y
	bcc	NoDraw
NoTest	anop

	SetFontFlags #%010

	pei	(theRect+2)
	pei	(theRect)
	_EraseRect	; erase the old rectangle

	ldy	#left
	lda	[theRect],y
	tax
	ldy	#bottom
	lda	[theRect],y
	dec	a
	dec	a
	inx
	inx
	phx
	pha
	_MoveTo
	ldy	#2
	lda	[memptr],y
	pha
	lda	[memptr]
	pha
	_DrawCString

	ldy	#4
	lda	[memPtr],y
	and	#$00C0	; strip to the 6 and 7 bits
	beq	memDrawn	; if they are both 0 and the member is drawn
	ph4	theRect
	_InvertRect
memDrawn	anop

noDraw	pld
	short	a
	pla
	ply

	plx
	plx
	plx
	plx
	plx
	plx
	phy
	pha
	long	a
	rtl

	END

**************************************************************************
*
* Install a one second interrupt handler
*
**************************************************************************

InstallOneSec  START

	using	GSOSData

	lda	$E1C034
	and	#$F
	sta	SBBorder

               SetVector (#$15,#OneSec)
               IntSource #6
               jmp   ResetSB

OneSec         longa off
               longi off

               phb
               phk
               plb

               pha
               inc   OneSecFlag
               lda   $E0C032
               and   #%10111111
               sta   $E0C032
               pla

               plb
               clc
               rtl

               longa on
               longi on

               END

**************************************************************************
*
* Reset Screen Blank
*
**************************************************************************

ResetSB        START

	using	GSOSData

               lda   SBTimer
               bne   reset

               short a
               lda   $E1C034
               and   #$F0
               ora   SBBorder
               sta   $E1C034
               long  a

           	InitColorTable #$E19E00
               GetMasterSCB @a
               SetAllSCBs @a
               RefreshDesktop #0
	ShowMenuBar
               InitCursor

reset          lda   #120	;2 minutes
               sta   SBTimer

               rts

               END

**************************************************************************
*
* See if one second interrupt has been flagged
*
**************************************************************************

CheckOneSec    START

	using	GSOSData
	using	textbuffers
	using textdata
                  
               lda   OneSecFlag
               bne   ok
nope           rts

ok             stz   OneSecFlag
;
; check for alarm
;
	lda	AlarmFlag
	jeq	sb2
	lda	AlarmHour
	inc	a
	cmp	#12
	bne	al0
	lda	#0
al0	ldy	AlarmAMPM
	beq	al1
	clc
	adc	#12
al1	sta	newhour
	pha
	pha
	pha
	pha
	_ReadTimeHex
	pla
	xba
	and	#$FF
	cmp	AlarmMinute
	jne	ss0
	pla
	and	#$FF
;	dec	a
;	bpl	al2
;	lda	#23
al2	cmp	newhour
	jne	ss1
	pla
	pla

triggeralarm	lda	#1
	sta	thermoflag
	jsl	killsong

	HideCursor
	HideMenuBar
	stz	jukeflag
	jsr	clearscreen
	short	a
	lda	>$E1C034
	sta	oldborder
	lda	#0
	sta	>$E1C034
	long	a

	ph4	PlayerPic
	ph2	PlayerSize
	jsl	UNLZSSPic

	jsr	pauselight

	lda	#loadingbuf
	ldx	#^loadingbuf
	jsr	showzone

	lda	#$6666
	sta	backcolor
	lda	#$9999
	sta	forecolor
	lda	#wakeup
	sta	textptr
	lda	#^wakeup
	sta	textptr+2	

	jsr	cleartext
	jsr	centertext
	jsr	drawtext
	jsr	scrollview

	ld4	AlarmSong,OpenPath
	jsl	openfile
	jcs	damn
               jsl	loadmod
	jcs	damn0
	Close CloseParm

	jsr	playmod

damn0	Close	CloseParm
damn	short	a
	lda	oldborder
	sta	>$E1C034
	long	a

           	InitColorTable #$E19E00
               GetMasterSCB @a
               SetAllSCBs @a
               RefreshDesktop #0
	ShowMenuBar
               InitCursor

	rts

oldborder	ds	2

damn2	rts	

ss0	pla
ss1	pla
	pla
;
; Screen blanker
;
sb2	lda	SBTimer
	beq	damn2
	dec	SBTimer
	bne	damn2
               short a
               lda   $E1C034
               tay
               and   #$F0
               sta   $E1C034
               tya
               and   #$F
               sta   SBBorder
               long  a

	HideMenuBar
	jsr	clearscreen
	ph4	BlankerPic
	ph2	BlankerSize
	jsl	UNLZSSPic

	lda	AlarmFlag
	jeq	sblup

	lda	AlarmHour
	inc	a
	Int2Dec (@a,#alarmhstr,#2,#0)
	Int2Dec (AlarmMinute,#alarmmstr,#2,#0)
	short	a
	lda	alarmmstr
	cmp	#' '
	bne	zz1
	lda	#'0'
	sta	alarmmstr
zz1	long	a
	lda	AlarmAMPM
	beq	zz2
	lda	PMstr
	bra	zz3
zz2	lda	AMstr
zz3	sta	alarmpstr
	lda	#$0000
	sta	backcolor
	lda	#$4444
	sta	forecolor
	ld4	alarmstr,textptr
	jsr	cleartext
	jsr	centertext
	jsr	drawtext
	ldx	#38
putalarm	lda	textbuf+0*160+60,x	
	sta	>$E12000+193*160+60,x
	lda	textbuf+1*160+60,x	
	sta	>$E12000+194*160+60,x
	lda	textbuf+2*160+60,x	
	sta	>$E12000+195*160+60,x
	lda	textbuf+3*160+60,x	
	sta	>$E12000+196*160+60,x
	lda	textbuf+4*160+60,x	
	sta	>$E12000+197*160+60,x
	lda	textbuf+5*160+60,x	
	sta	>$E12000+198*160+60,x
	lda	textbuf+6*160+60,x	
	sta	>$E12000+199*160+60,x
	dex
	dex
	bpl	putalarm
                               
sblup	GetMouse #mouse2
wait	GetNextEvent (#$2A,#eventrec),@a
	pha
               GetMouse #mouse1
	lda	mouse1
	cmp	mouse2
	jne	mouser
	lda	mouse1+2
	cmp	mouse2+2
	jne	mouser
	lda	OneSecFlag
	jeq	wait2
	ReadAsciiTime #TimeBuf
	lda	#$0000
	sta	backcolor
	lda	#$5555
	sta	forecolor
	ld4	TimeBuf,textptr
	jsr	cleartext
	jsr	drawtext
	ldx	#50
puttime	lda	textbuf+0*160,x	
	sta	>$E12000+193*160+3,x
	lda	textbuf+1*160,x	
	sta	>$E12000+194*160+3,x
	lda	textbuf+2*160,x	
	sta	>$E12000+195*160+3,x
	lda	textbuf+3*160,x	
	sta	>$E12000+196*160+3,x
	lda	textbuf+4*160,x	
	sta	>$E12000+197*160+3,x
	lda	textbuf+5*160,x	
	sta	>$E12000+198*160+3,x
	lda	textbuf+6*160,x	
	sta	>$E12000+199*160+3,x
	dex
	dex
	bpl	puttime
	stz	OneSecFlag
;
; check for alarm
;
	lda	AlarmFlag
	jeq	wait2
	lda	AlarmHour
	inc	a
	cmp	#12
	bne	bal0
	lda	#0
bal0	ldy	AlarmAMPM
	beq	bal1
	clc
	adc	#12
bal1	sta	newhour
	pha
	pha
	pha
	pha
	_ReadTimeHex
	pla
	xba
	and	#$FF
	cmp	AlarmMinute
	jne	bss0
	pla
	and	#$FF
;	dec	a
;	bpl	bal2
;	lda	#23
bal2	cmp	newhour
	jne	bss1
	pla
	pla
	pla
               short a
               lda   $E1C034
               and   #$F0
               ora   SBBorder
               sta   $E1C034
               long  a
          	lda   #120	;2 minutes
               sta   SBTimer
               jmp	triggeralarm

bss0	pla
bss1	pla
	pla
wait2        	pla
	jeq	wait

	pha
mouser         pla
	mv4   mouse1,mouse2
               jmp   ResetSB

mouse1         ds    4
mouse2         ds    4

eventrec	ds	$10
TimeBuf	ds	20
	dc	i1'0'

newhour	ds	2
wakeup	dc	c'WAKE UP!!!!!!',h'00'
alarmstr	dc	c'ALARM '
alarmhstr	dc	c'00:'
alarmmstr	dc	c'00 '
alarmpstr	dc	c'PM',h'00'

amstr	dc	c'AM'
pmstr	dc	c'PM'

               END

**************************************************************************
*
* Check for mouse movement
*
**************************************************************************

CheckMouse     START

               GetMouse #mouse1

               if2   mouse1,ne,mouse2,mouser
               if2   mouse1+2,eq,mouse2+2,nomouse
mouser         mv4   mouse1,mouse2
               jsr   ResetSB
nomouse        rts

mouse1         ds    4
mouse2         ds    4

               END

*
* Load configuration from disk
*

LoadConfig	START

	using	GSOSData
	using	gendata

	Open	_OpenParm
	bcs	usedefaults
	mv2	_OpenRef,(_ReadRef,_CloseRef)
	Read	_ReadParm
	bcs	closedefault
	Close _CloseParm
	lda	ConfigSig
	cmp	soniqT
	bne	usedefaults
	lda	ConfigSig+2
	cmp	soniqT+2
	bne	usedefaults
	lda	ConfigSig+4
	cmp	soniqT+4
	bne	usedefaults

	bra	setup

closedefault	Close	_CloseParm

usedefaults	lda	soniqT
	sta	ConfigSig
	lda	soniqT+2
	sta	ConfigSig+2
	lda	soniqT+4
	sta	ConfigSig+4
	lda	#1         
	sta	LightsFlag
	stz	AlarmFlag
	stz	AlarmHour
	stz	AlarmMinute
	stz	AlarmAMPM
	ld2	271,confVolume	;level 8
	ld2	264,confStereo	;50%
	ld2	50*5,PlayHertz
	stz	shuffleflag
                  
setup          lda	LightsFlag
	sta	>CTLTMP_00000009+$1E         
	lda	AlarmFlag
	sta	>AlarmActBox+$1E         
	lda	AlarmHour
	sta	>AlarmHourScroll+$1E
	lda	AlarmMinute
	sta	>AlarmMinuteScroll+$1E
	lda	AlarmAMPM           
	sta	>AlarmAMPMScroll+$1E
	lda	confVolume
	sta	>VolMenuControl+$20
	lda	confStereo
	sta	>StereoMenuControl+$20
	lda	#1
	ldx	PlayHertz
	cpx	#5*60
	beq	set1
	eor	#1
set1	sta	>SixtyHzButton+$1E
	eor	#1
	sta	>FiftyHzButton+$1E
	lda	shuffleflag
	sta	>ShuffleVal
	lda	AlarmSong
	bne	set2
               lda	#$FF00
	sta	>AlarmActBox+$12
set2	anop
              
	rts      

_OpenParm	dc	i2'2'
_OpenRef	dc	i2'0'
	dc	i4'filename'

_ReadParm	dc	i2'4'
_ReadRef	dc	i2'0'
	dc	i4'ConfigTable'
	dc	i4'ConfigEnd-ConfigTable'
_ReadCount	dc	i4'0'

_CloseParm	dc	i2'1'
_CloseRef	dc	i2'0'

filename	GSStr '9:soniqDATA:DATA00'

	END

*
* Save configuration to disk
*

SaveConfig	START

	using	GSOSData
	using	gendata

	Create _CreateParm
               bcc	doopen
	cmp	#$47
	beq	doopen
err	rts
doopen         Open	_OpenParm
	bcs	err
	mv2	_OpenRef,(_WriteRef,_CloseRef)
	lda	>VolMenuControl+$20
	sta	confVolume
	lda	>StereoMenuControl+$20
	sta	confStereo
	Write	_WriteParm                     
	Close _CloseParm
	rts

_CreateParm	dc	i2'3'
	dc	i4'filename'
	dc	i2'%0000000010000011'
	dc	i2'4'

_OpenParm	dc	i2'2'
_OpenRef	dc	i2'0'
	dc	i4'filename'

_WriteParm	dc	i2'4'
_WriteRef	dc	i2'0'
	dc	i4'ConfigTable'
	dc	i4'ConfigEnd-ConfigTable'
	dc	i4'0'

_CloseParm	dc	i2'1'
_CloseRef	dc	i2'0'
                              
filename	GSStr	'9:soniqDATA:DATA00'

	END

*                         
* Data for reading the mod file
*

GSOSData	DATA

MMID	ds	2
SongID	ds	2

thermoflag	ds	2
jukeflag	ds	2
OneSecFlag	dc	i2'0'
SBTimer	dc	i2'1'
SBBorder	dc	i2'0'

AlarmPort	ds	4
InstPort	ds	4
InstLEHand	ds	4

Filename	ds	256

buffer	ds	1025

modname	ds	21

OpenParm	dc	i2'2'
OpenRef	dc	i2'0'
OpenPath	dc	i4'Filename'

ReadParm	dc	i2'4'
ReadRef	dc	i2'0'
ReadBuffer	dc	i4'0'
ReadCount	dc	i4'0'
	dc	i4'0'

SetMarkParm	dc	i2'3'
SetMarkRef	dc	i2'0'
	dc	i2'0'
SetMarkPos	dc	i4'0'

CloseParm	dc	i2'1'
CloseRef	dc	i2'0'

GetEOFParm	dc	i2'2'
GetEOFRef      dc	i2'0'
GetEOFeof	dc	i4'0'

QuitFlag	ds	2
tread	ds	4
                  
EventRecord	anop
EventWhat	ds	2
EventMessage	ds	4
EventWhen	ds	4
EventWhere	ds	4
EventModifiers	ds	2
TaskData	ds	4
TaskMask	dc	i4'%101011010100111111111'
TaskLastClick	ds	4
TaskClickCnr	ds	2
TaskData2	ds	4
TaskData3	ds	4
TaskData4	ds	4
TaskClickPt	ds	8

ChannelMode	dc	i2'0'

soniqT	dc	c'soniqT'

;
; configuration data
;
ConfigTable	anop
ConfigSig	ds	6
LightsFlag	dc	i2'1'
AlarmFlag	dc	i2'0'
AlarmHour	dc	i2'0'
AlarmMinute	dc	i2'0'
AlarmAMPM	dc	i2'0'
confVolume	dc	i2'271'	;level 8
confStereo	dc	i2'264'            ;50%
PlayHertz	dc	i2'5*50'
shuffleflag	dc	i2'0'
AlarmSong	dc	66i1'0'

ConfigEnd	anop

	END
