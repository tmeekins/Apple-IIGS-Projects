*
* The IRC Experience
*
	mcopy	ircexp.mac

KBD      	gequ  $E0C000                  keyboard latch
KBDSTROBE 	gequ 	$E0C010                  turn off keypressed flag
MOUSEDATA 	gequ 	$E0C024                  X or Y mouse data register
KEYMODREG 	gequ 	$E0C025                  key modifier register
KMSTATUS 	gequ  $E0C027                  kbd/mouse status register
BUTN0    	gequ  $E0C061                  Read switch 0 (open-Apple)
BUTN1    	gequ  $E0C062                  Read switch 1 (option)
;
; text control
;
txtEND	gequ	0
txtPHRASE	gequ	1
txtENDPHRASE	gequ	2
txtPAUSE	gequ	3
txtLINE1	gequ	4
txtLINE2	gequ	5
txtCLEAR	gequ	6
txtMAX	gequ	7
;
; variables from mt player
;
MyMID          gequ $10
MyID           gequ MyMID+2
Temp1          gequ MyID+2
Digits         gequ Temp1+2
WaveTemp       gequ Digits+4
WaveTemp2      gequ WaveTemp+4

TempM          gequ WaveTemp2+4
SongPtr        gequ TempM+4
InstPtr        gequ SongPtr+4
MusListPtr     gequ InstPtr+4
MainBlockPtr   gequ MusListPtr+4
InstHandle     gequ MainBlockPtr+4
TempDP         gequ InstHandle+4
SongHandle     gequ TempDP+4
FX1Ptr         gequ SongHandle+4
FX2Ptr         gequ FX1Ptr+4
SongPath       gequ FX2Ptr+4
InstPath       gequ SongPath+4
DPTemp         gequ InstPath+4
Temp0          gequ DPTemp+4
MySID          gequ Temp0+4
;
; some variables of my own
;
ptr	gequ	MySID+2 

intro          START

	using	MainData
	using	BackData
	using	Globals

TempHandle	equ	0
temp	equ	0
count	equ	4
lesize	equ	8
lebuf	equ	10
lehand	equ	14

               longa on
               longi on

               bra   start

               dc    c'Copyright (c) 1992 by Tim Meekins '
               dc    c'All Rights Reserved '

start          phk
               plb
;
; Start up some tools
;
               short a
               mv2   $E0C034,oldborder
               ld2   0,$E0C034
               long  a

               mv2   $E10048,CDAVal
               ld2   $6B18,$E10048      ;CLC, RTL

               TLStartUp
               MMStartUp ID
               NewHandle (#$300,ID,#%1100000000000101,#0),TempHandle
               QDStartUp ([TempHandle],#%1000000000000000,#320,ID)
               NewHandle (#$100,ID,#%1100000000000101,#0),TempHandle
               SoundStartUp [TempHandle]
               HideCursor
	CompactMem
;
; Black out the palette so that we don't see the picture load
;
               lda   #0
               ldx   #16*2*16-2
blacken        sta   >$019E00,x
               dex2
               bpl   blacken
;
; get the title screen
;
	jsr	gettitle
	jsr	nextbar
	jsr	compactoff
	jsr	getcloud1
	jsr	getcloud2
	jsr	getback
;                                   
; Load the data
;
	NewHandle (#89000,ID,#$C008,#0),lehand
	lda	[lehand]
	sta	lebuf
	ldy	#2
	lda	[lehand],y
	sta	lebuf+2

	Open	openparm
	mv2	openref,(readref,closeref)
               NewHandle (openeof,ID,#$C008,#0),@yx
	jcs	newerr
	sty	TempHandle
	stx	TempHandle+2
	lda	[TempHandle]
	sta	readbuf
	ldy	#2
	lda	[TempHandle],y
	sta	readbuf+2
	mv4	openeof,readreq
	Read	readparm
	Close	closeparm
	jsr	nextbar
	jsr	nextbar

	jsr	compacton
	ph4	readbuf
	ph4	lebuf
	lda	ID
	ora	#$400
               pha
	jsl	LZSSExpandPtoP
	jsr	compactoff
	DisposeHandle TempHandle
	jsr	nextbar
	jsr	nextbar

	stz	count
readloop	lda	[lebuf]
	sta	lesize
	add4	lebuf,#2,lebuf
	ldx	#0
	lda	lesize
               NewHandle (@xa,ID,#$C018,#0),@yx
	jcs	newerr
	sty	TempHandle
	stx	TempHandle+2
	lda	count
	asl	a
	asl	a
	tax
	ldy	#2
	lda	[TempHandle]
	sta	animtbl,x
	lda	[Temphandle],y
	sta	animtbl+2,x
	ldx	#0
	ldy	lesize
	PtrToHand (lebuf,TempHandle,@xy)
	clc
	lda	lebuf
	adc	lesize
	sta	lebuf
	lda	lebuf+2
	adc	#0
	sta	lebuf+2

	inc	count	
	lda	count
	cmp	#$40
	bne	readloop

	DisposeHandle lehand
	jsr	nextbar

	jmp	startdemo

newerr	SysFailMgr (@a,#errstr)
errstr	str	"'Lamer!' (c) FTA. GS<>IRC Erreur k0dez ->"


startdemo	anop
;                                     
; Load music and start playing it
;
	tdc
	sta	>MyDP
	jsr	InitSeq
	clc
	lda	ID
	adc	#$100
	sta	MyMID
	adc	#$100
	sta	MyID 
	adc	#$100
	sta	MySID
	ld4	seq03,SongPath
	jsr	LoadASong
;
; swap "please wait" with "click mouse"
;
	ldx	#16*2-2
swappal	lda	>$E19E00+1*32,x
	tay
	lda	>$E19E00+4*32,x
	sta	>$E19E00+1*32,x
	tya
	sta	>$E19E00+4*32,x
	dex
	dex
	bpl	swappal
;
; wait for an event...from pnp..
;
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
;
; fade to black
;
         	lda   #0
         	jsr   FadePict
;
; show the background
;
	ldx	#200*160-2
putbak	lda	>backpic,x
	sta	>$012000,x
	dex2
	bpl	putbak
	ldx	#198
pscb0	lda	>backpic+$7D00,x
	sta	>$019D00,x
	dex2
	bpl	pscb0
;
; create scb tables
;
c1	equ	$f0
c2	equ	$f2

	lda	#6
	sta	c1
	inc	a
	sta	c2

	short	a
	ldx	#0
	ldy	#0
mkscb	lda	scb0,x
	cmp	#1
	bne	mk2
	lda	c1
	sta	scb0,x
	lda	c2
	sta	scb0+88*32,x
	bra	mk3
mk2	lda	c2
	sta	scb0,x
	lda	c1
	sta	scb0+88*32,x
mk3	inx
	iny
	cpy	#30
	bne	mk4
	lda	#8
	bra	mk4a
mk4	cpy	#88
	bne	mk5
	ldy	#0
	lda	#6
mk4a	sta	c1
	inc	a
	sta	c2
mk5	cpx	#88*32
	bcc	mkscb
	long	a	
;                                   
; initialize ground scbs
;
	ldx	#87
scbloop	lda	scb1,x
	sta	>$019D00+112,x
	dex	
	bpl	scbloop
;
; start playing the song
;
	jsr	Play
;
; initialize sky colors
;
	ldx	#16*2-2
sky	lda	>backpic+$7E00+1*32,x
	sta	>$019E00+1*32,x
	lda	>backpic+$7E00+2*32,x
	sta	>$019E00+2*32,x
	lda	>backpic+$7E00+3*32,x
	sta	>$019E00+3*32,x
	lda	>backpic+$7E00+4*32,x
	sta	>$019E00+4*32,x
	lda	>backpic+$7E00+5*32,x
	sta	>$019E00+5*32,x
	dex2
	bpl	sky
;                                   
; initialize ground colors
;
	ldx	#6*2-2
palloop0	lda	pal0,x
	sta	$019E00+1*32,x
	sta	$019E00+2*32,x
	sta	$019E00+3*32,x
	sta	$019E00+4*32,x
	sta	$019E00+5*32,x
	sta	$019E00+6*32,x
	sta	$019E00+7*32,x
	dex
	dex
	bpl	palloop0

	lda	#$FFF
	sta	>$019E00+32*1+15*2
	sta	>$019E00+32*6+15*2
	sta	>$019E00+32*7+15*2
	sta	>$019E00+32*8+15*2
	sta	>$019E00+32*9+15*2
                                  
	ldx	#8*2-2
palloop1	lda	pal1,x
	sta	$019E00+6*32+14,x
	lda	pal2,x
	sta	$019E00+7*32+14,x
	lda	pal1,x
	sta	$019E00+8*32+14,x
	lda	pal2,x
	sta	$019E00+9*32+14,x
	dex               
	dex	
               bpl	palloop1
;
; vu colors
;
;	lda	#$FC0
	lda	#$2F0
	sta	$019E00+8*32+4*2
	sta	$019E00+9*32+4*2
	lda	#$F40
	sta	$019E00+8*32+5*2
	sta	$019E00+9*32+5*2
;
; The main demo loop
;
main           long	a
	VBLWait
	jsr	DoVUMeters
	jsr	groundseq
	jsr	nextframe
	jsr	textseq
;
; check for hyper mode
;
	short	a
	lda	$E1C025	;keymodreg
	and	#%11000000	;OA and OPTION
	cmp	#%11000000
	bne	OAup
OAdown	lda	hypermode
	bne	OAdone
	ld2	1,hypermode
	bra	OAdone
OAup	lda	hypermode
	beq	OAdone
	stz	hypermode
	stz	FFflag
OAdone	anop
;              
; Check for a keypress
;
wait           lda   $E1C000
               bmi   done
               long  a
               bra   main

	longa	off
done           sta   $E1C010
	and	#$7F
	cmp	#'q'
	bne	main
               long  a
;
; Shutdown the tools
;
byebye	short a
               mv2   oldborder,$E0C034
               long  a

	jsr	Stop
               GrafOff
	SoundShutDown
               QDShutDown
               MMShutDown ID
               TLShutDown
               mv2   CDAVal,$E10048

               Quit  QuitParm

	dc	c'  Yoshi! Get the hell out of my code!  '
;
; the text sequencer
;
textseq	lda	texttimer
	beq	textseq01
	dec	texttimer
	rts
textseq01	lda	textclrcount
	beq	textseq02
	ldx	textline
	lda	>backpic,x
	ldy	#80
textseq01a	sta	>$012000,x
	inx2
	dey
	bne	textseq01a
	dec	textclrcount
	lda	textline
	clc
	adc	#160
	sta	textline
	rts         

textseq02	ldx	txtoffset
	lda	text,x	
	and	#$FF
	cmp	#txtMAX
	bcs	txtchar
	asl	a
	tax
	jmp	(texttbl,x)

width	equ	0
owidth	equ	2
ycount	equ	4
add	equ	6

txtchar	cmp	#' '
	beq	txtright
	tay
	lda	fontwidths,y
	and	#$FF
	sta	owidth
	sec
	lda	#160
	sbc	owidth
	sta	add
	tya
	sec
	sbc	#'!'
	asl	a
	asl	a
	tax
	lda	fonttbl,x
	sta	ptr
	lda	fonttbl+2,x
	sta	ptr+2
	ld2	33,ycount
	ldx	textpos
char1	lda	owidth
	sta	width
	short	a
	lda	>$012000,x
	sta	scrbak+1
char2	lda	[ptr]
	tay
	lda	mask,y
scrbak	and	#$FF
	ora	[ptr]
	sta	>$012000,x
	inx
	inc	ptr
	bne	char2a
	inc	ptr+1
char2a	dec	width
	bne	char2
               long	a

	clc
	txa
	adc	add
	tax
	lda	ptr
	adc	add
	sta	ptr
	dec	ycount
	bne	char1		

	ldx	txtoffset
	lda	text,x
	and	#$FF
txtright	tax
	lda	fontwidths,x
	and	#$FF
	clc
	adc	textpos
	inc	a
	sta	textpos
	inc	txtoffset
	rts	

texttbl	dc	i2'textend'
	dc	i2'textphrase'
	dc	i2'textendphrase'
	dc	i2'textpause'
	dc	i2'textline1'
	dc	i2'textline2'
	dc	i2'textclear'

textend	stz	txtoffset
	rts

textline1	lda	#5*160
	bra   textline2a
textline2	lda	#40*160
textline2a	sta	textline
	inc	txtoffset
	rts

textpause	ld2	200,texttimer
textendphrase	inc	txtoffset
	rts

textclear	ld2	33,textclrcount
	inc	txtoffset
	rts

textphrase	stz	textpos
	ldx	txtoffset
textphrase1	inx
	lda	text,x
	and	#$FF
	cmp	#txtENDPHRASE
	beq	textphrase2
	tay
	lda	fontwidths,y
	and	#$FF
	clc
	adc	textpos
	inc	a	
	sta	textpos
	bra	textphrase1
textphrase2	lsr	textpos
	lda	#80
	sec
	sbc	textpos
	clc
	adc	textline
	sta	textpos
	inc	txtoffset	
	rts

textclrcount	dc	i'0'
texttimer	dc	i'0'
textline	dc	i'0'
textpos	dc	i'0'
;
; the ground sequencer
;
groundseq	anop
	lda	groundstate
	asl	a
	tax
	lda	hypermode
	beq	groundseq2h
	phx
	jsr	(groundtbl1,x)
	plx
	phx
	jsr	(groundtbl1,x)
	plx
groundseq2h	jsr	(groundtbl1,x)
	lda	hypermode
	bne	groundseq2a
	dec	gsspeed2
	bmi	groundseq2a
	rts
groundseq2a	lda	groundstate
	asl	a
	tax
	jsr	(groundtbl2,x)
	ld2	1,gsspeed2 
	dec	gscount2
	beq	groundseq2b
	rts
groundseq2b	ld2	5*30,gscount2
	inc	groundstate
	lda	groundstate
	cmp	#8
	bne	groundseq2c
	stz	groundstate
groundseq2c	rts
gscount2	dc	i2'5*30'
gsspeed2	dc	i2'1'
groundstate	dc	i2'0'
groundtbl1	dc	a2'moveforward'
	dc	a2'moveforward'
	dc	a2'moverts'
	dc	a2'movebackward'
	dc	a2'movebackward'
	dc	a2'movebackward'
	dc	a2'moverts'
	dc	a2'moveforward'
groundtbl2	dc	a2'moverts'
	dc	a2'moveright'
	dc	a2'moveright'
	dc	a2'moveright'
	dc	a2'moverts'
	dc	a2'moveleft'
	dc	a2'moveleft'
	dc	a2'moveleft'
moverts	rts
;                  
; draw the next animation frame if we're ready
;
nextframe	lda	hypermode
	bne	nextframe0
	lda	animcount
	beq	nextframe0
	dec	animcount
	rts
nextframe0	lda	animspeed
	sta	animcount
	lda	animframe
	asl	a
	asl	a
	tax
	lda	animtbl,x
	sta	animdraw+1
	lda	animtbl+1,x
	sta	animdraw+2

	phb
	pea	$0101
	plb
	plb
	short	a
animdraw	jsl	$FFFFFF
	long	a
	plb

	inc	animframe
	lda	animframe
	cmp	#$40
	bne	animdone
	stz	animframe
animdone	rts

animspeed	dc	i2'3'
animcount	dc	i2'0'
animframe	dc	i2'0'
;
; move to the right by scrolling the ground to the left
;
moveright	inc	groundoff1
	lda	groundoff1
	cmp	#8
	bcc	gsok
	lda	#0
	sta	groundoff1
gsok	asl	a
	tay
	ldx	#0
gsloop	lda	pal1,y
	sta	$019E00+6*32+14,x
	lda	pal2,y
	sta	$019E00+7*32+14,x
	lda	pal1,y
	sta	$019E00+8*32+14,x
	lda	pal2,y
	sta	$019E00+9*32+14,x
	iny
	iny
	inx
	inx
	cpx	#8*2
	bne	gsloop
	rts
;
; move to the left by scrolling the ground to the right
;
moveleft	dec	groundoff1
	lda	groundoff1
	bpl	gsok2
	lda	#7
	sta	groundoff1
gsok2	asl	a
	tay
	ldx	#0
gsloop2	lda	pal1,y
	sta	$019E00+6*32+14,x
	lda	pal2,y
	sta	$019E00+7*32+14,x
	lda	pal1,y
	sta	$019E00+8*32+14,x
	lda	pal2,y
	sta	$019E00+9*32+14,x
	iny            
	iny
	inx
	inx
	cpx	#8*2
	bne	gsloop2
	rts
;
; move forward by scrolling ground downward
;
moveforward	inc	groundoff2
	lda	groundoff2
	cmp	#64
	bcc	gsok3
	lda	#0
	sta	groundoff2
gsok3	asl	a
	tay
	lda	scbtbl,y
	tay
	ldx	#112
gsloop3	lda	scb0,y
	sta	>$019D00,x
	inx
	inx
	iny
	iny
	cpx	#200
	bne	gsloop3
	rts	
;
; move backword by scrolling ground upward
;
movebackward	dec	groundoff2
	lda	groundoff2
	cmp	#-1
	bne	gsok4
	lda	#63
	sta	groundoff2
gsok4	asl	a
	tay
	lda	scbtbl,y
	tay
	ldx	#112
gsloop4	lda	scb0,y
	sta	>$019D00,x
	inx
	inx
	iny
	iny
	cpx	#200
	bne	gsloop4
	rts	
                    
ID             ENTRY
	ds    2
seq03	gsstr	'9:edat:edat5.pak'
QuitParm       dc    i'0'
oldborder      ds    2
hypermode	dc	i'0'
CDAVal	ds	2

groundoff1	dc	i2'0'
groundoff2	dc	i2'0'

animtbl	ds	$40*4

openparm	dc	i2'12'
openref	dc	i2'0'
	dc	i4'filename'
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
	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

filename      	GSStr '9:edat:edat4.pak'

txtoffset	dc	i'0'
text	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'The GS<>IRC',i1'txtENDPHRASE'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'Experience',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR,txtLINE2,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'Production:',i1'txtENDPHRASE'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'Tim Meekins',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'Coding:',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'Graphics:',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE2,txtCLEAR'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'James Brookes',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'Music:',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR,txtLINE2,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'MegaTracker:',i1'txtENDPHRASE'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'by Ian Schmidt',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR,txtLINE2,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'Compaction:',i1'txtENDPHRASE'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'Dave Huang',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR,txtLINE2,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'Can you find',i1'txtENDPHRASE'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'Hyper mode?',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR,txtLINE2,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'This entire',i1'txtENDPHRASE'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'demo was',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR,txtLINE2,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'developed on',i1'txtENDPHRASE'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'an Apple IIgs',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR,txtLINE2,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'Apple II',i1'txtENDPHRASE'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'Forever!',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR,txtLINE2,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'Support the',i1'txtENDPHRASE'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'Alliance!',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR,txtLINE2,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'The Date:',i1'txtENDPHRASE'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'April 24, 1992',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtLINE1,txtCLEAR,txtLINE2,txtCLEAR'
	dc	i1'txtLINE1'
	dc	i1'txtPHRASE',c'$004C - EOF',i1'txtENDPHRASE'
	dc	i1'txtLINE2'
	dc	i1'txtPHRASE',c'Encountered',i1'txtENDPHRASE'
	dc	i1'txtPAUSE'
	dc	i1'txtPAUSE'
	dc	i1'txtPAUSE'      
	dc	i1'txtPAUSE'      
	dc	i1'txtLINE1,txtCLEAR,txtLINE2,txtCLEAR'
	dc	i1'txtEND'                   
                                 
pal0	dc	i2'$000,$666,$888,$AAA,$CCC,$C9F'

pal1	dc	i'$B91,$B91,$B91,$B91,$783,$783,$783,$783'
	dc	i'$B91,$B91,$B91,$B91,$783,$783,$783,$783'
pal2	dc	i'$A62,$A62,$A62,$A62,$762,$762,$762,$762'
	dc	i'$A62,$A62,$A62,$A62,$762,$762,$762,$762'

               dc    c'What are you looking for?'    

scbtbl	dc	i2'00*88,01*88,02*88,03*88,04*88,05*88'
	dc	i2'06*88,07*88,08*88,09*88,10*88,11*88'
	dc	i2'12*88,13*88,14*88,15*88,16*88,17*88'
	dc	i2'18*88,19*88,20*88,21*88,22*88,23*88'
	dc	i2'24*88,25*88,26*88,27*88,28*88,29*88'
	dc	i2'30*88,31*88,32*88,33*88,34*88,35*88'
	dc	i2'36*88,37*88,38*88,39*88,40*88,41*88'
	dc	i2'42*88,43*88,44*88,45*88,46*88,47*88'
	dc	i2'48*88,49*88,50*88,51*88,52*88,53*88'
	dc	i2'54*88,55*88,56*88,57*88,58*88,59*88'
	dc	i2'60*88,61*88,62*88,63*88'
                                                            
scb0  dc i1'1,2,1,1,2,2,2,2,1,1'
 dc i1'1,1,1,1,1,1,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb1  dc i1'1,2,1,1,2,2,2,2,1,1'
 dc i1'1,1,1,1,1,1,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb2  dc i1'1,2,1,1,2,2,2,2,1,1'
 dc i1'1,1,1,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb3  dc i1'1,2,1,1,2,2,2,2,1,1'
 dc i1'1,1,1,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb4  dc i1'1,2,1,1,2,2,2,2,2,1'
 dc i1'1,1,1,1,1,1,1,1,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb5  dc i1'1,2,1,1,2,2,2,2,2,1'
 dc i1'1,1,1,1,1,1,1,1,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb6  dc i1'1,2,1,1,2,2,2,2,2,1'
 dc i1'1,1,1,1,1,1,1,1,1,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb7  dc i1'1,2,1,1,2,2,2,2,2,1'
 dc i1'1,1,1,1,1,1,1,1,1,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb8  dc i1'1,2,1,1,1,2,2,2,2,2'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb9  dc i1'1,2,1,1,1,2,2,2,2,2'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb10  dc i1'1,2,1,1,1,2,2,2,2,2'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb11  dc i1'1,2,1,1,1,2,2,2,2,2'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb12  dc i1'1,2,1,1,1,2,2,2,2,2'
 dc i1'2,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb13  dc i1'1,2,1,1,1,2,2,2,2,2'
 dc i1'2,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb14  dc i1'1,2,1,1,1,2,2,2,2,2'
 dc i1'2,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb15  dc i1'1,2,1,1,1,2,2,2,2,2'
 dc i1'2,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb16  dc i1'1,2,2,1,1,1,2,2,2,2'
 dc i1'2,2,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb17  dc i1'1,2,2,1,1,1,2,2,2,2'
 dc i1'2,2,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb18  dc i1'1,2,2,1,1,1,2,2,2,2'
 dc i1'2,2,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb19  dc i1'1,2,2,1,1,1,2,2,2,2'
 dc i1'2,2,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb20  dc i1'1,2,2,1,1,1,2,2,2,2'
 dc i1'2,2,2,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb21  dc i1'1,2,2,1,1,1,2,2,2,2'
 dc i1'2,2,2,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb22  dc i1'1,2,2,1,1,1,2,2,2,2'
 dc i1'2,2,2,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,2,2'
 dc i1'2,2,2,2,2,2,2,2'
scb23  dc i1'1,2,2,1,1,1,2,2,2,2'
 dc i1'2,2,2,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,2'
 dc i1'2,2,2,2,2,2,2,2'
scb24  dc i1'1,2,2,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'2,2,2,2,2,2,2,2'
scb25  dc i1'1,2,2,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,2,2,2,2,2,2,2'
scb26  dc i1'1,2,2,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,2,2,2,2,2,2'
scb27  dc i1'1,2,2,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,2,2,2,2,2'
scb28  dc i1'1,2,2,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,2,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,2,2,2,2'
scb29  dc i1'1,2,2,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,2,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,2,2,2'
scb30  dc i1'1,2,2,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,2,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,2,2'
scb31  dc i1'1,2,2,1,1,1,1,2,2,2'
 dc i1'2,2,2,2,2,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,2,2,2,2,2'
 dc i1'2,2,2,2,2,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,1,1,1'
 dc i1'1,1,1,1,1,1,1,2'

 ds 88*32

	dc	c'Have you found it yet?'

mask	dc	h'fff0f0f0f0f0f0f0f0f0f0f0f0f0f0f0'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
	dc	h'0f000000000000000000000000000000'
                  
fonttbl	dc	a4'font1+1*160+2'	   ;!
	dc	a4'font1+1*160+8'	   ;"
	dc	a4'font1+1*160+17'	   ;#
	dc	a4'font1+1*160+27'	   ;$
	dc	a4'font1+1*160+37'	   ;%
	dc	a4'font1+1*160+52'	   ;&
	dc	a4'font1+1*160+67'	   ;'
	dc	a4'font1+1*160+72'	   ;(
	dc	a4'font1+1*160+79'	   ;)
	dc	a4'font1+1*160+86'	   ;*
	dc	a4'font1+1*160+94'	   ;+
	dc	a4'font1+1*160+104'   ;,
	dc	a4'font1+1*160+109'   ;-
	dc	a4'font1+1*160+120'   ;.
	dc	a4'font1+1*160+125'   ;/
	dc	a4'font1+39*160+2'	   ;0
	dc	a4'font1+39*160+18'   ;1
	dc	a4'font1+39*160+30'   ;2
	dc	a4'font1+39*160+44'   ;3
	dc	a4'font1+39*160+56'   ;4
	dc	a4'font1+39*160+71'   ;5
	dc	a4'font1+39*160+84'   ;6
	dc	a4'font1+39*160+97'   ;7
	dc	a4'font1+39*160+110'  ;8
	dc	a4'font1+39*160+124'  ;9
	dc	a4'font1+39*160+137'  ;:
	dc	a4'font1+39*160+142'  ;;
	dc	a4'font1+75*160+2'    ;<
	dc	a4'font1+75*160+10'   ;=
	dc	a4'font1+75*160+19'   ;>
	dc	a4'font1+75*160+26'   ;?
	dc	a4'font1+75*160+39'   ;@
	dc	a4'font1+75*160+55'   ;A
	dc	a4'font1+75*160+69'   ;B
	dc	a4'font1+75*160+82'   ;C
	dc	a4'font1+75*160+94'   ;D
	dc	a4'font1+75*160+108'  ;E
	dc	a4'font1+75*160+120'  ;F
	dc	a4'font1+75*160+131'  ;G
	dc	a4'font1+75*160+145'  ;H
	dc	a4'font1+113*160+2'   ;I
	dc	a4'font1+113*160+13'  ;J
	dc	a4'font1+113*160+27'  ;K
	dc	a4'font1+113*160+40'  ;L
	dc	a4'font1+113*160+54'  ;M
	dc	a4'font1+113*160+70'  ;N
	dc	a4'font1+113*160+85'  ;O
	dc	a4'font1+113*160+99'  ;P
	dc	a4'font1+113*160+112' ;Q
	dc	a4'font1+113*160+128' ;R
	dc	a4'font1+113*160+141' ;S
	dc	a4'font1+150*160+2'   ;T
	dc	a4'font1+150*160+17'  ;U
	dc	a4'font1+150*160+31'  ;V
	dc	a4'font1+150*160+44'  ;W
	dc	a4'font1+150*160+60'  ;X
	dc	a4'font1+150*160+74'  ;Y
	dc	a4'font1+150*160+87'  ;Z
	dc	a4'font1+150*160+101' ;[
	dc	a4'font1+150*160+108' ;\
	dc	a4'font1+150*160+121' ;]
	dc	a4'font1+150*160+128' ;^
	dc	a4'font1+150*160+137' ;_
	dc	a4'font1+150*160+149' ;`
	dc	a4'font2+0*160+1'     ;a
	dc	a4'font2+0*160+12'    ;b
	dc	a4'font2+0*160+23'    ;c
	dc	a4'font2+0*160+32'    ;d
	dc	a4'font2+0*160+43'    ;e
	dc	a4'font2+0*160+53'    ;f
	dc	a4'font2+0*160+64'    ;g
	dc	a4'font2+0*160+75'    ;h
	dc	a4'font2+0*160+86'    ;i
	dc	a4'font2+0*160+92'    ;j
	dc	a4'font2+0*160+101'   ;k
	dc	a4'font2+0*160+112'   ;l
	dc	a4'font2+0*160+118'   ;m
	dc	a4'font2+0*160+133'   ;n
	dc	a4'font2+0*160+145'   ;o
	dc	a4'font2+36*160+0'    ;p
	dc	a4'font2+36*160+11'   ;q
	dc	a4'font2+36*160+22'   ;r
	dc	a4'font2+36*160+31'   ;s
	dc	a4'font2+36*160+41'   ;t
	dc	a4'font2+36*160+53'   ;u
	dc	a4'font2+36*160+64'   ;v
	dc	a4'font2+36*160+76'   ;w
	dc	a4'font2+36*160+91'   ;x
	dc	a4'font2+36*160+100'  ;y
	dc	a4'font2+36*160+111'  ;z
	dc	a4'font2+36*160+122'  ;{
	dc	a4'font2+36*160+129'  ;|
	dc	a4'font2+36*160+133'  ;}
	dc	a4'font2+36*160+140'  ;~

fontwidths	dc	i1'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'		;$00-$0F
	dc	i1'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'		;$10-$1F
	dc	i1'6,6,9,10,10,15,15,5,7,7,8,10,5,11,5,13'		;$20-$2F
	dc	i1'14,9,12,12,14,12,12,12,14,13,5,5,8,9,7,13'	;$30-$3F
	dc	i1'16,14,13,12,14,12,11,14,14,11,14,13,14,16,15,14' $40-$4F
	dc	i1'13,16,13,12,15,14,13,16,14,13,14,7,13,7,9,12'	;$50-$5F
	dc	i1'8,11,11,9,11,10,11,11,11,6,9,11,6,15,12,10'	;$60-$6F
	dc	i1'11,11,9,10,12,11,12,15,9,11,11,7,4,7,8,0'	;$70-$7F
                                                                        
	dc	c'Well, whaddya know? Another demo...be sure to '
	dc	c'tell me what you think of it...  '
	dc	c'You see...Americans can write cool demos too :) '
	dc	c'To all budding programmers...keep up the work! '
	dc	c'To Europeans: Don''t fret! We''re working on '
	dc	c'network for distributing between Europe and '
	dc	c'North America... Dig out those warez and get ready '
	dc	c'sell them over here! '
	dc	c'Dadopado: I hear you left me a message..hehe..'
	dc	c'any chance of an English translation? hehe...'
	dc	c'I sure hope to see TSOMI running on my GS!!!   '
	dc	c'Let''s get the Europeans on the Internet!!'

               END

backdata	DATA	seg01

backpic	ds	$8000

	END

fontdata	START	seg02

font1	ENTRY
	ds	$8000
font2	ENTRY
	ds	$7FFF
	
	END

z3dfubar	DATA	z3dlib

	dc	c'Hey! Whare *are* you looking for?'

	END

******************************
*
* Le VU
*
******************************


DoVUMeters     START                    ; VU meters, its a heartbeat task
               using MainDATA
               using Globals
	using	backdata

VOffset        equ 	180*160        	; byte offset of scanline from $e12000
Track          equ 	$f0
XOffset        equ 	$f2
CTHeight       equ 	$f4

               stz 	Track

MainLoop       lda Track
               asl a
               tax
               stx XOffset
               lda TrackInst,x
               beq NoChange
               inc a
               inc a
               sta VUHeight,x
               lda #$0000
               sta TrackInst,x       
               bra Update

NoChange       lda VUHeight,x
               beq Nope
               dec a
               sta VUHeight,x
               bra Update

Nope           jmp SkipUD

Update         ldx 	XOffset
               lda 	VUHeight,x
               sta 	CTHeight

               ldx 	XOffset
               lda 	HorzOffsets,x
               clc
               adc 	#VOffset    	; make start address of meter on screen
               tax
	ldy	#17
ULoop        	cpy 	CTHeight
               beq 	Draw          	; if less than or equal to, draw
               bcs 	Erase
Draw           cpy	#12
	bcs	DrawR
	lda	>backpic,x
	and	#$00F0
	ora	#$4404
               bra 	PutIt
DrawR	lda	>backpic,x
	and	#$00F0
	ora	#$5505
	bra	PutIt
Erase          lda	>backpic,x
Putit          sta 	>$e12000,x     
Continue       txa
               clc
               adc 	#160       	; next scanline
               tax
               dey
               bne 	ULoop        	; continue

               ldx 	XOffset
               lda 	Horz2Offsets,x
               clc
               adc 	#VOffset       	; make start address of meter on screen
               tax
	ldy	#17
ULoop2        	cpy 	CTHeight
               beq 	Draw2          	; if less than or equal to, draw
               bcs 	Erase2
Draw2          cpy	#12
	bcs	DrawR2
          	lda	>backpic,x
	and	#$00F0
	ora	#$4404
               bra 	PutIt2
DrawR2         lda	>backpic,x
	and	#$00F0
	ora	#$5505
               bra 	PutIt2
Erase2         lda	>backpic,x
Putit2         sta 	>$e12000,x     
Continue2      txa
               clc
               adc 	#160       	; next scanline
               tax
               dey
               bne 	ULoop2        	; continue

SkipUD         inc 	Track
               lda 	Track
               cmp 	#14
               beq 	ExitVUM
               jmp 	MainLoop

ExitVUM        rts

HorzOffsets	dc	i2'5,7,9,11,13,15,17,19,21,23,25,27,29,31,33'
Horz2Offsets   dc	i2'154,152,150,148,146,144,142,140,138,136,134,132,130,128'
VUHeight       dc 	32i2'0'

               END

*************************
*
* Show the title
*
*************************

gettitle	START

hand	equ	0

	Open	openparm
	mv2	openref,(readref,closeref)
               NewHandle (openeof,ID,#$C018,#0),hand
	lda	[hand]
	sta	readbuf
	ldy	#2
	lda	[hand],y
	sta	readbuf+2
	mv4	openeof,readreq
	Read	readparm
	Close	closeparm

	ph4	readbuf
	ph4	#$E12000
	lda	ID
	ora	#$400
               pha
	jsl	LZSSExpandPtoP
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
	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

name	gsstr	'9:edat:edat0.pak'

	END
                  
*************************
*
* Load cloud 1
*
*************************

getcloud1	START

hand	equ	0

	Open	openparm
	mv2	openref,(readref,closeref)
               NewHandle (openeof,ID,#$C018,#0),hand
	lda	[hand]
	sta	readbuf
	ldy	#2
	lda	[hand],y
	sta	readbuf+2
	mv4	openeof,readreq
	Read	readparm
	Close	closeparm
	jsr	nextbar

	jsr	compacton
	ph4	readbuf
	ph4	#font1
	lda	ID
	ora	#$400
               pha
	jsl	LZSSExpandPtoP
	jsr	compactoff
	DisposeHandle hand
	jsr	nextbar

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
	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

name	gsstr	'9:edat:edat1.pak'

	END
                  
*************************
*
* Load cloud 2
*
*************************

getcloud2	START

hand	equ	0

	Open	openparm
	mv2	openref,(readref,closeref)
               NewHandle (openeof,ID,#$C018,#0),hand
	lda	[hand]
	sta	readbuf
	ldy	#2
	lda	[hand],y
	sta	readbuf+2
	mv4	openeof,readreq
	Read	readparm
	Close	closeparm
	jsr	nextbar

	jsr	compacton
	ph4	readbuf
	ph4	#font2
	lda	ID
	ora	#$400
               pha
	jsl	LZSSExpandPtoP
	jsr	compactoff
	DisposeHandle hand
	jsr	nextbar

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
	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

name	gsstr	'9:edat:edat2.pak'

	END
                  
*************************
*
* Load background
*
*************************

getback	START

	using	backdata

hand	equ	0

	Open	openparm
	mv2	openref,(readref,closeref)
               NewHandle (openeof,ID,#$C018,#0),hand
	lda	[hand]
	sta	readbuf
	ldy	#2
	lda	[hand],y
	sta	readbuf+2
	mv4	openeof,readreq
	Read	readparm
	Close	closeparm
	jsr	nextbar

	jsr	compacton
	ph4	readbuf
	ph4	#backpic
	lda	ID
	ora	#$400
               pha
	jsl	LZSSExpandPtoP
	jsr	compactoff
	DisposeHandle hand
	jsr	nextbar

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
	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

name	gsstr	'9:edat:edat3.pak'

	END

*******
* compact util
*******

compactoff	START

	ldx	#32-2
loop1	lda	>$E19E00+32*14,x
	sta	>buffoo,x
	lda	#0
	sta	>$E19E00+32*14,x
	dex2
	bpl	loop1
	rts

compacton	ENTRY

	ldx	#32-2
loop2	lda	>buffoo,x
	sta	>$E19E00+32*14,x
	dex2
	bpl	loop2
	rts

buffoo	ds	32

	END

****
* thermometer
****

nextbar	START

	short	a
	ldx	idx
	lda	#$EE
	sta	>$012000+140*160,x
	sta	>$012000+141*160,x
	sta	>$012000+142*160,x
	sta	>$012000+143*160,x
	sta	>$012000+144*160,x
	sta	>$012000+145*160,x
	sta	>$012000+146*160,x
	sta	>$012000+147*160,x
	sta	>$012000+148*160,x
	sta	>$012000+149*160,x
	inx
	stx	idx
	long	a
	rts

idx	dc	i'69'

	END

FadePict	START

red	equ	0
green	equ	2
blue	equ	4
destcolor	equ	6
startcolor	equ	8

         	cmp   #0	0=fade-out
         	bne   FadeIn
         	brl   FadeOut

FadeIn  	ldx   #0
CopyIn  	lda   >$012000,x
         	sta   >$E12000,x
         	inx2
         	cpx   #$7E00
         	bne   CopyIn

         	ldy   #16
         	ldx   #0
FadeInLoop  	lda   >$019E00,x
         	sta   destcolor
         	lda   >$E19E00,x
         	sta   startcolor
         	cmp   destcolor
         	beq   FadeInNext
	and2	startcolor,#$F00,red
	and2	startcolor,#$0F0,green
	and2	startcolor,#$00F,blue
	and2	destcolor,#$F00,@a
	if2	@a,eq,red,noredadd
	add2	red,#$100,red
noredadd  	and2	destcolor,#$0F0,@a
	if2	@a,eq,green,nogreenadd
	add2	green,#$010,green
nogreenadd  	and2	destcolor,#$00F,@a
	if2	@a,eq,blue,noblueadd
	add2	blue,#$001,blue
noblueadd 	lda   red
         	ora   green
         	ora   blue
         	sta   >$E19E00,x

FadeInNext	inx2
	cpx	#32*16
	jcc	FadeInloop
	jsr	FadeWait
	ldx	#0
	dey
	jne	FadeInLoop
	rts

FadeWait  	phx
	VBLWait
         	VBLWait
	VBLWait
         	plx
         	rts

FadeOut  	ldy   #16
         	ldx   #0
FadeOutLoop  	lda   >$E19E00,x
         	cmp   #$0000
         	beq   FadeOutNext
         	lda  	>$E19E00,x
	and2	@a,#$F00,red
         	lda   >$E19E00,x
	and2	@a,#$0F0,green
         	lda   >$E19E00,x
	and2	@a,#$00F,blue
         	lda   red
         	beq   L01574C
	sub2	red,#$100,red
L01574C  	lda   green
         	beq   L01575B
	sub2	green,#$010,green
L01575B  	lda   blue
         	beq   L01576A
	sub2	blue,#$001,blue
L01576A  	lda   red
         	ora   green
         	ora   blue
         	sta   >$E19E00,x
FadeOutNext	inx2
	cpx	#32*16
	bcc	FadeOutLoop
	jsr	FadeWait
	ldx	#0
	dey
	bne	FadeOutLoop  	
         	rts

       	END
