*
* soniqTRAKER
*

	mcopy	m/st.mac

MasterVolume	gequ	$E100CA
SOUNDCTL	gequ	$00C03C
SOUNDDATA	gequ	$00C03D
SOUNDADRL	gequ	$00C03E
SOUNDADRH	gequ	$00C03F

*
* Play the mod
*

playmod	START

	using	blipdata
	using	SongData
	using	Tables
	using	GSOSData
	using	SoundDat
	using	textbuffers
	using	gendata

pattptr	equ	0

tempo	equ	4
position	equ	6
note	equ	8
channel	equ	10
doneflag	equ	12
pitch	equ	14
parm	equ	16
end_pattern	equ	18
notenum	equ	20
pulse	equ	22
pattloop	equ	24
loopstart	equ	26
pattdelay	equ	28
mod3	equ	30
sampvol	equ	32

	jsr	SoundStart

	jsr	initdig

	php
	short	at
	lda	#$1E
	sta	>SOUNDADRL
	lda	PlayHertz
	asl	a
	sta	>SOUNDDATA
	lda	#$3E
	sta	>SOUNDADRL
	lda	PlayHertz+1
	rol	a
	sta	>SOUNDDATA
	plp
	longa	on

	ldx	#8*2-2
	ldy	#0
	tya
init	sta	chvolume,x
	sta	chonoff,x
	sta	chpitch,x
	sta	chsample,x
	sta	chtune,x
	sta	chnote,x
	sta	chpitchgoal,x
	sta	chportarate,x
	sta	chslide,x
	sta	chviboffset,x
	sta	chtremoffset,x
	sta	choffset,x
	sta	chdidvib,x
	sta	chdidtrem,x
	sta	blipidx,x
	sta	WaveOffset,y
	sta	WaveOffset+2,y
	sta	WaveDOCPtrL,y
	sta	WaveDOCPtrL+2,y
	sta	WaveDOCPtrH,y
	sta	WaveDOCPtrH+2,y
	sta	oldheight,x
	lda	#8
	sta	chvibrate,x
	sta	chtremrate,x
	lda	#8*64
	sta	chvibdepth,x
	sta	chtremdepth,x
	lda	#1
	sta	VUHeight,x
	dec	a
	iny                  
	iny
	iny
	iny
	dex
	dex
	bpl	init

	sta	>$E19E00+15*32+2
	sta	>$E19E00+15*32+4
	sta	>$E19E00+15*32+6
	sta	>$E19E00+15*32+8
                                    
	jsr	DrawVU

	ld2	6*2,tempo
	stz	position
	stz	pulse
	stz	note
	stz	doneflag
	stz	pattloop
	stz	loopstart
	stz	pattdelay
	stz	mod3
	stz	IRQFlag
	jsr	setpattern

	lda	#$3334
	sta	>$E12000+160*134+12
	sta	>$E12000+160*187+12
	sta	>$E12000+160*134+21
	sta	>$E12000+160*187+21
	sta	>$E12000+160*134+30
	sta	>$E12000+160*187+30
	sta	>$E12000+160*134+39
	sta	>$E12000+160*187+39
	lda	#$3033              
	sta	>$E12000+160*134+14
	sta	>$E12000+160*134+15
	sta	>$E12000+160*187+14
	sta	>$E12000+160*187+15
	sta	>$E12000+160*134+23
	sta	>$E12000+160*134+24
	sta	>$E12000+160*187+23
	sta	>$E12000+160*187+24
	sta	>$E12000+160*134+32
	sta	>$E12000+160*134+33
	sta	>$E12000+160*187+32
	sta	>$E12000+160*187+33
	sta	>$E12000+160*134+41
	sta	>$E12000+160*134+42
	sta	>$E12000+160*187+41
	sta	>$E12000+160*187+42

	jsr	playlight
	lda	#playingbuf
	ldx	#^playingbuf
	jsr	showzone
;
; The syncro loop
;
playerloop	ldx	#113*160+113+11+3+11+3
	lda	note
	jsr	drawnum
vsyncwait	lda	LightsFlag
	bne	vsync2
	jsr	ShowOscillo
vsync2	lda	IRQFlag
	beq	vsyncwait
	dec	IRQFlag
	lda	doneflag
	beq	chkdone0
	lda	#0
	jmp	done
chkdone0	lda	>$E1C062
	and	#%10000000
	beq	chkdone1
               lda	#$1B
	jmp	done
chkdone1	lda	pulse
	bit	#%11111
	bne	donekey2
	EventAvail (#$28,#eventrec),@a
	jne	dokeyevent

donekey	lda	pulse
donekey2	and	#%11
	cmp	#%10
	bne	sync2
	ldx	#8*2-2
vusync	lda	VUHeight,x
	dec	a
	beq	nextvusync
	sta	VUHeight,x
nextvusync	dex
	dex
	bpl	vusync

sync2	lda	pulse
	bne	goeffects
	jsr	donotes

goeffects	ldx	#0
	jsr	(cheffect,x)
	ldx	#2
	jsr	(cheffect,x)
	ldx	#4
	jsr	(cheffect,x)
	ldx	#6          
	jsr	(cheffect,x)
	ldx	#8          
	jsr	(cheffect,x)
	ldx	#10          
	jsr	(cheffect,x)
	ldx	#12          
	jsr	(cheffect,x)
	ldx	#14          
	jsr	(cheffect,x)
                     
nextsync	jsr	DrawVU
	lda	pulse
	lsr	a
	bcc	noblip
	lda	LightsFlag
	beq	noblip
	jsr	blipslide
noblip	jsr	zonedaemon
	inc	mod3
	lda	mod3
	cmp	#3
	bne	skip3
	stz	mod3
skip3	inc	pulse
	lda	pulse
	cmp	tempo
	bcc	goplayerloop
	stz	pulse
goplayerloop	jmp	playerloop

eventrec	ds	$10
;
; do a keypres
;
dokeyevent	GetNextEvent (#$28,#eventrec),@a
	lda	eventrec+$2
	and	#$7F
	cmp	#'1'
	jeq	track1
	cmp	#'2'
	jeq	track2
	cmp	#'3'
	jeq	track3
	cmp	#'4'
	jeq	track4
	cmp	#'q'
	beq	done
	cmp	#'Q'
	beq	done
	cmp	#$1B
	beq	done
	cmp	#' '
	jeq	pause
	cmp	#'<'
	jeq	voldown
	cmp	#','
	jeq	voldown
	cmp	#'>'
	jeq	volup
	cmp	#'.'
	jeq	volup
	cmp	#'s'
	jeq	stereo
	cmp	#'S'
	jeq	stereo
	cmp	#'h'
	jeq	speed
	cmp	#'H'
	jeq	speed
	ldx	JukeFlag
	jeq	donekey
	cmp	#'n'
	beq	done
	cmp	#'N'
	beq	done
	jmp	donekey  
;
; done playing
;          
done	and	#$7F
	pha
	jsr	pauselight
	lda	#0
	jsr	HaltSound
	lda	#1
	jsr	HaltSound
	lda	#2
	jsr	HaltSound
	lda	#3
	jsr	HaltSound
	jsr	SoundStop
	lda	#1
	sta	VUHeight+0
	sta	VUheight+2
	sta	VUheight+4
	sta	VUHeight+6
	jsr	DrawVU
	ldx	#0
	lda	#0
	jsr	putblip
	ldx	#2
	lda	#0
	jsr	putblip
	ldx	#4
	lda	#0
	jsr	putblip
	ldx	#6
	lda	#0
	jsr	putblip
	lda	#0
	sta	>$E19E00+15*32+2
	sta	>$E19E00+15*32+4
	sta	>$E19E00+15*32+6
	sta	>$E19E00+15*32+8
	jsr	initdig

	pla
	rts
;
; track 1 on/off
;
track1	lda	chonoff+0
	eor	#1
	sta	chonoff+0
	beq	track1on

	lda	#track1offbuf
	ldx	#^track1offbuf
	jsr	showzone
	lda	#$2222    
	sta	>$E12000+160*134+12
	sta	>$E12000+160*187+12
	lda	#$2022              
	sta	>$E12000+160*134+14
	sta	>$E12000+160*134+15
	sta	>$E12000+160*187+14
	sta	>$E12000+160*187+15
	php
	short	at
	lda	#$40
	sta	>SOUNDADRL
	lda	#0
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
	jmp	donekey

track1on	lda	#track1onbuf
	ldx	#^track1onbuf
	jsr	showzone
	lda	#$3334
	sta	>$E12000+160*134+12
	sta	>$E12000+160*187+12
	lda	#$3033              
	sta	>$E12000+160*134+14
	sta	>$E12000+160*134+15
	sta	>$E12000+160*187+14
	sta	>$E12000+160*187+15
	jmp	donekey
;
; track 2 on/off
;
track2	lda	chonoff+2
	eor	#1
	sta	chonoff+2
	beq	track2on

	lda	#track2offbuf
	ldx	#^track2offbuf
	jsr	showzone
	lda	#$2222    
	sta	>$E12000+160*134+21
	sta	>$E12000+160*187+21
	lda	#$2022              
	sta	>$E12000+160*134+23
	sta	>$E12000+160*134+24
	sta	>$E12000+160*187+23
	sta	>$E12000+160*187+24
	php
	short	at
	lda	#$44
	sta	>SOUNDADRL
	lda	#0
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
	jmp	donekey

track2on	lda	#track2onbuf
	ldx	#^track2onbuf
	jsr	showzone
	lda	#$3334
	sta	>$E12000+160*134+21
	sta	>$E12000+160*187+21
	lda	#$3033              
	sta	>$E12000+160*134+23
	sta	>$E12000+160*134+24
	sta	>$E12000+160*187+23
	sta	>$E12000+160*187+24
	jmp	donekey
;
; track 3 on/off
;
track3	lda	chonoff+4
	eor	#1
	sta	chonoff+4
	beq	track3on

	lda	#track3offbuf
	ldx	#^track3offbuf
	jsr	showzone
	lda	#$2222    
	sta	>$E12000+160*134+30
	sta	>$E12000+160*187+30
	lda	#$2022             
	sta	>$E12000+160*134+32
	sta	>$E12000+160*134+33
	sta	>$E12000+160*187+32
	sta	>$E12000+160*187+33
	php
	short	at
	lda	#$48
	sta	>SOUNDADRL
	lda	#0
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
	jmp	donekey

track3on	lda	#track3onbuf
	ldx	#^track3onbuf
	jsr	showzone
	lda	#$3334
	sta	>$E12000+160*134+30
	sta	>$E12000+160*187+30
	lda	#$3033              
	sta	>$E12000+160*134+32
	sta	>$E12000+160*134+33
	sta	>$E12000+160*187+32
	sta	>$E12000+160*187+33
	jmp	donekey
;
; track 4 on/off
;
track4	lda	chonoff+6
	eor	#1
	sta	chonoff+6
	beq	track4on

	lda	#track4offbuf
	ldx	#^track4offbuf
	jsr	showzone
	lda	#$2222    
	sta	>$E12000+160*134+39
	sta	>$E12000+160*187+39
	lda	#$2022             
	sta	>$E12000+160*134+41
	sta	>$E12000+160*134+42
	sta	>$E12000+160*187+41
	sta	>$E12000+160*187+42
	php
	short	at
	lda	#$4C
	sta	>SOUNDADRL
	lda	#0
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
	jmp	donekey

track4on	lda	#track4onbuf
	ldx	#^track4onbuf
	jsr	showzone
	lda	#$3334
	sta	>$E12000+160*134+39
	sta	>$E12000+160*187+39
	lda	#$3033              
	sta	>$E12000+160*134+41
	sta	>$E12000+160*134+42
	sta	>$E12000+160*187+41
	sta	>$E12000+160*187+42
	jmp	donekey
;
; pause
;
pause	php
	short	at
	lda	#$40	;0 volume
	sta	>SOUNDADRL
	lda	#0
	ldx	#$1E
zapvol	sta	>SOUNDDATA
	dex
	bne	zapvol
	longa	on
	plp

	jsr	pauselight
	lda	#pausedbuf
	ldx	#^pausedbuf
	jsr	showzone
pausewait	EventAvail (#$28,#eventrec),@a
	beq	pausewait

	php
	sei
	ldx	#0
restorelup	lda	chvolume,x
	ldy	chpitch,x
	beq	restorenext
	tay
	short	ai
	txa
	asl	a
	ora	#$40
	sta	>SOUNDADRL
	lda	voltab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	lda	voltab2,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
restorenext	long	ai
	inx	
	inx
	cpx	#8*2
	bcc	restorelup
	plp

	jsr	playlight
	lda	#playingbuf
	ldx	#^playingbuf
	jsr	showzone
	stz	IRQFlag
	jmp	donekey
;
; volume up/down
;
volup	lda	>VolMenuControl+$20
	sec
	sbc	#267
	asl	a
	tax
	lda	menu2vol,x
	cmp	#9
	beq	volchange
	inc	a
	bra	volchange

voldown	lda	>VolMenuControl+$20
	sec
	sbc	#267
	asl	a
	tax
	lda	menu2vol,x
	cmp	#0
	beq	volchange
	dec	a

volchange	asl	a
	tax
	asl	a
	tay
	lda	vol2menu,x
	sta	>VolMenuControl+$20
	lda	volbuftbl,y
	ldx	volbuftbl+2,y
setthevol	jsr	showzone
               jsr	setvolume
	jmp	donekey

volbuftbl	dc	i4'vol01buf,vol02buf,vol03buf,vol04buf,vol05buf'
	dc	i4'vol06buf,vol07buf,vol08buf,vol09buf,vol10buf'
;
; change the stereo mode
;
stereo	lda	>StereoMenuControl+$20
	dec	a
	beq	isfull
	cmp	#263-1
	beq	is75
	cmp	#264-1
	beq	is50
	cmp	#265-1
	beq	is25
ismono	ldy	#1
	ldx	#^stereofullbuf
	lda	#stereofullbuf
	bra	stereo2
isfull	ldy	#263
	ldx	#^stereo75buf
	lda	#stereo75buf
	bra	stereo2       
is75           ldy	#264   
	ldx	#^stereo50buf
	lda	#stereo50buf
	bra	stereo2    
is50           ldy	#265   
	ldx	#^stereo25buf
	lda	#stereo25buf
	bra	stereo2  
is25           ldy	#266   
	ldx	#^stereomonobuf
	lda	#stereomonobuf
stereo2	pha
	tya
	sta	>StereoMenuControl+$20
	pla
	jmp	setthevol
;
; change Hz speed setting
;
speed	lda	>FiftyHzButton+$1E
	beq	speed50
	ld2	1,>SixtyHzButton+$1E
	ld2	0,>FiftyHzButton+$1E
	ld2	300,PlayHertz
	lda	#sixtybuf
	ldx	#^sixtybuf
	jsr	showzone
	bra	speed2 

speed50	ld2	1,>FiftyHzButton+$1E
	ld2	0,>SixtyHzButton+$1E
	ld2	250,PlayHertz
	lda	#fiftybuf
	ldx	#^fiftybuf
	jsr	showzone
                            
speed2	php
	short	at
	lda	#$1E
	sta	>SOUNDADRL
	lda	PlayHertz
	asl	a
	sta	>SOUNDDATA
	lda	#$3E
	sta	>SOUNDADRL
	lda	PlayHertz+1
	rol	a
	sta	>SOUNDDATA
	longa	on
	plp
               jmp	donekey
;                           
; get next pattern
;
setpattern	ldx	position
	lda   postbl,x
	and	#$FF
	tay
	asl	a
	asl	a
	tax
	lda	PattTable,x
	sta	pattptr
	lda	PattTable+2,x
	sta	pattptr+2
	lda	note
	asl	a
	pha
	asl	a
	adc	1,s	;*6
	asl	a	;*12
	asl	a                  ;*24
	asl	a	;*48
	adc	pattptr	;(cf=0)
	sta	pattptr
	lda	#0
	adc	pattptr+2
	sta	pattptr+2
	pla
	tya
	ldx	#113*160+113+11+3
	jsr	drawnum
	lda	position
	cmp	#100
	bcc	zero1
	sbc	#100	;(cf=1)
zero1	ldx	#113*160+113
	jmp	drawnum
;
; do the next line in the song
;
donotes	lda	pattdelay
	beq	donotes0
	dec	a
	sta	pattdelay
	rts

donotes0	stz	channel
	stz	end_pattern

	lda	#0
channloop	asl	a
	tax
	stz	chvolslide,x
	lda	#noeffect
	sta	cheffect,x
	
	lda	chonoff,x
	jne	nextchann

	lda	[pattptr]
	beq	getpitch
	sta	chsample,x
	asl	a
	asl	a
	tay
	lda	VoiceTunTab,y
	asl	a
	sta	chtune,x
	lda	VoiceVolTab,y
putvol	sta	chvolume,x

getpitch	sta	sampvol
	ldy	#2
	lda	[pattptr],y
	beq	putpitch
	sta	notenum
	sta	chnote,x

	ldy	chtune,x
	lda	notenum
	asl	a
	adc	noteofftbl,y
	tay
	lda	notepitch,y
putpitch	sta	pitch

geteffect	ldy	#4
	lda	[pattptr],y
	sta	parm
	lda	chdidvib,x
	beq	geteffect2
	lda	parm
	and	#$FF00
	cmp	#$0F00
	beq	geteffect2
	cmp	#$1200
	beq	geteffect2
	cmp	#$1300
	beq	geteffect2
	cmp	#$0000
	bne	geteffect0
	lda	parm
	bne	geteffect2
geteffect0	lda	chpitch,x
	jsr	putblip
	lda	chpitch,x	;restore the pitch :)
	asl	a
	tay
	php
	short	at
	txa
	asl	a
	sta	>SOUNDADRL
	lda	pitchtab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	txa
	asl	a
	ora	#$20
	sta	>SOUNDADRL
	lda	pitchtab+1,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
	stz	chdidvib,x	
geteffect2	lda	chdidtrem,x
	beq	geteffect3
	lda	parm
	and	#$FF00
	cmp	#$1D00
	beq	geteffect3
	ldy	chvolume,x	;restore the volume
	php
	short	at
	txa
	asl	a
	ora	#$40
	sta	>SOUNDADRL
	lda	voltab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	lda	voltab2,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
	stz	chdidtrem,x	

geteffect3	lda	parm
	beq	playnote
	phx
	xba
	and	#$FF
	asl	a
	tax
	jmp	(effecttab,x)

effectplaynote	plx
      
playnote	lda	pitch	;begin playing a new note
playnote2	beq	resetvol
	sta	chpitch,x
	jsr	putblip
	lda	chpitch,x
	asl	a      
	tay
	lda	pitchtab,y
	tay
	lda	chvolume,x
	lsr	a
	lsr	a
	bne	playnote2a
	inc	a
playnote2a	sta	VUHeight,x
	lda	chvolume,x
	xba
	ora	chsample,x
	tax
	lda	channel
	jsr	PlaySound
               bra	nextchann

resetvol	lda	chpitch,x
	beq	nextchann
	lda	sampvol
	beq	nextchann
	sta	chvolume,x
	tay
	lsr	a
	lsr	a
	bne	resetvol2
	inc	a
resetvol2	sta	VUHeight,x
	php
	short	ait
	txa
	asl	a
	ora	#$40
	sta	>SOUNDADRL
	lda	voltab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	lda	voltab2,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	longi	on
	plp
                              
nextchann	clc
	lda	pattptr
	adc	#6
	sta	pattptr
	bcc	nextchann2	
               inc	pattptr+2

nextchann2	inc	channel
	lda	channel
	cmp	#8
	jcc	channloop

	lda	end_pattern
	bne	skip

	inc	note
	lda	note
	cmp	#64
	bcc	endnotes

	stz	note
skip	inc	position
	jsr	setpattern
	lda	position
	cmp	songlength
	bcc	endnotes

	inc	doneflag
                        
endnotes	rts
;
; Code for interpreting effects
;
effecttab	dc	i2'unknowneffect'	;$00 - No effect
	dc	i2'unknowneffect'	;$01 - Unknown effect
	dc	i2'effect02'	;$02 - Arpeggio
	dc	i2'effect03'	;$03 - Set Volume
	dc	i2'effect04'	;$04 - Volume Slide Up
	dc	i2'effect05'	;$05 - Volume Slide Down
	dc	i2'effect06'	;$06 - Fine Volume Slide Up
	dc	i2'effect07'	;$07 - Fine Volume Slide Down
	dc	i2'effect08'	;$08 - Pitchbend Up
	dc	i2'effect09'	;$09 - Pitchbend Down
	dc	i2'effect0A'	;$0A - Fine Pitchbend Up
	dc	i2'effect0B'	;$0B - Fine Pitchbend Down
	dc	i2'effect0C'	;$0C - Note Portamento
	dc	i2'effect0D'	;$0D - Set Tempo
	dc	i2'effect0E'	;$0E - Set Clock Rate
	dc	i2'effect0F'	;$0F - Vibrato
	dc	i2'effect10'	;$10 - Note Portamento + Volume Slide Up
	dc	i2'effect11'	;$11 - Note Portamento + Volume Slide Down
	dc	i2'effect12'	;$12 - Vibrato + Volume Slide Up
	dc	i2'effect13'	;$13 - Vibrato + Volume Slide Down
	dc	i2'effect14'	;$14 - Set Sample Offset
	dc	i2'effect15'	;$15 - Position Jump
	dc	i2'effect16'	;$16 - Pattern Break
	dc	i2'effect17'	;$17 - Pattern Loop
	dc	i2'effect18'	;$18 - Pattern Delay
	dc	i2'effect19'	;$19 - Set FineTune
	dc	i2'effect1A'	;$1A - Retrig Note
	dc	i2'effect1B'	;$1B - Note Cut
	dc	i2'effect1C'	;$1C - Note Delay
	dc	i2'effect1D'	;$1D - Volume Tremelo
;
; unknown effect
;
unknowneffect	ldx	#^unknownbuf
	lda	#unknownbuf
	jsr	showzone
	jmp	effectplaynote
;              
; parse the arpeggio effect
;
effect02	plx
	lda	mod3
	asl	a
	tay
	lda	whicharp,y
	sta	cheffect,x
	lda	pitch
	bne	effect02a
	lda	chnote,x
	sta	notenum
	lda	chpitch,x
effect02a	sta	charp0,x
	lda	parm
	and	#$F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	eor	#$FFFF
	sec
	adc	notenum
	asl	a
	tay
	lda	notepitch,y
	sta	charp1,x
	lda	parm
	and	#$F
	eor	#$FFFF
	sec
	adc	notenum
	asl	a
	tay
	lda	notepitch,y
	sta	charp2,x
	lda	#1
	sta	chdidvib,x	;restore pitch when done
	jmp	playnote
whicharp	dc	i'applyarpeggio0'
	dc	i'applyarpeggio1'
	dc	i'applyarpeggio2'
;
; parse set volume effect
;
effect03	lda	parm
	and	#$FF
	plx
	sta	chvolume,x
	ldy	pitch
	jne	playnote
	ldy	chpitch,x
	beq	effect03b
	tay
	lsr	a
	lsr	a
	bne	effect03a
	inc	a
effect03a	sta	VUHeight,x
	php
	short	ait
	txa
	asl	a
	ora	#$40
	sta	>SOUNDADRL
	lda	voltab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	lda	voltab2,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	longi	on
	plp
	jmp	nextchann
effect03b	jmp	playnote
;
; parse volume slide up
;
effect04	plx
	lda	parm
	and	#$F
	beq	effect04a
	sta	chvolslide,x
	lda	#applyvolslide
	sta	cheffect,x
effect04a	jmp	playnote
;
; parse volume slide down
;
effect05	plx
	lda	parm
	and	#$F
	beq	effect05a
	eor	#$FFFF
	inc	a
	sta	chvolslide,x
	lda	#applyvolslide
	sta	cheffect,x
effect05a	jmp	playnote
;                               
; parse fine volume slide up
;
effect06	plx
	lda	parm
	and	#$F
	beq	effect06a
	sta	chvolslide,x
	lda	#applyfvolslide
	sta	cheffect,x
effect06a	jmp	playnote
;
; parse fine volume slide down
;
effect07	plx
	lda	parm
	and	#$F
	beq	effect07a
	eor	#$FFFF
	inc	a
	sta	chvolslide,x
	lda	#applyfvolslide
	sta	cheffect,x
effect07a	jmp	playnote
;       
; parse the pitchbend up
;
effect08	plx
	lda	#applypitchbend
	sta	cheffect,x
	lda	parm
	and	#$FF
	beq	effect08a
	eor	#$FFFF
	inc	a
	sta	chslide,x
effect08a	jmp	playnote
;
; parse the pitchbend down
;
effect09	plx
	lda	#applypitchbend
	sta	cheffect,x
               lda	parm
	and	#$FF
	beq	effect09a
	sta	chslide,x
effect09a	jmp	playnote
;
; parse fine pitchbend up
;
effect0A	plx
	lda	#applyfpitchbend
	sta	cheffect,x
	lda	parm
	and	#$0F
	beq	effect0Aa
	eor	#$FFFF
	inc	a
	sta	chslide,x
effect0Aa	jmp	playnote
;
; parse fine pitchbend down
;
effect0B	plx
	lda	#applyfpitchbend
	sta	cheffect,x
	lda	parm
	and	#$0F
	beq	effect0Ba
	sta	chslide,x
effect0Ba	jmp	playnote
;
; parse the note portemento effect
;
effect0C	plx
	lda	#applyporta
	sta	cheffect,x
	lda	parm
	and	#$FF
	beq	effect0Ca
	sta	chportarate,x
effect0Ca	lda	pitch
	beq	effect0Cb
	cmp	chpitchgoal,x
	beq	effect0Cc
	sta	chpitchgoal,x	
	lda	chpitch,x
effect0Cb	jmp	playnote2
effect0Cc	jmp	nextchann
;
; parse tempo effect
;
effect0D	lda	parm
	and	#$FF
	asl	a
	sta	tempo
	jmp	effectplaynote
;
; parse set rate
;
effect0E	lda	parm
	and	#$FF
	inc	a
	inc	a
               asl	a
	asl	a
	tay
	php
	short	at
	lda	#$3E
	sta	>SOUNDADRL
	xba
	sta	>SOUNDDATA
	lda	#$1E
	sta	>SOUNDADRL
	tya
	sta	>SOUNDDATA
	longa	on
	plp
	jmp	effectplaynote
;
; parse vibrato effect
;
effect0F	plx
	lda	#applyvibrato
	sta	cheffect,x
	inc	chdidvib,x
	lda	parm
	beq	effect0Fa
	and	#$F
	beq	effect0Fb
	xba		;*64
	lsr	a
	lsr	a
	sta	chvibdepth,x
effect0Fb	lda	parm
	and	#$F0
	beq	effect0Fa
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	chvibrate,x	
effect0Fa	jmp	playnote
;
; parse tone portamento + volume slide up
;
effect10	plx
	lda	#applyportavol
	sta	cheffect,x
	lda	pitch
	beq	effect10a
	cmp	chpitchgoal,x
	beq	effect10a
	sta	chpitchgoal,x	
	stz	pitch
effect10a	lda	parm
	and	#$F
	beq	effect10b
	sta	chvolslide,x
effect10b	jmp	playnote
;
; parse tone portamento + volume slide down
;
effect11	plx
	lda	#applyportavol
	sta	cheffect,x
	lda	pitch
	beq	effect11a
	cmp	chpitchgoal,x
	beq	effect11a
	sta	chpitchgoal,x	
	stz	pitch
effect11a	lda	parm
	and	#$F
	beq	effect11b
	eor	#$FFFF
	inc	a
	sta	chvolslide,x
effect11b	jmp	playnote
;
; parse vibrato + volume slide up
;
effect12	plx
	lda	#applyvibvol
	sta	cheffect,x
	inc	chdidvib,x
	lda	parm
	and	#$F
	beq	effect12a
	sta	chvolslide,x
effect12a	jmp	playnote
;
; parse vibrato + volume slide down
;
effect13	plx
	lda	#applyvibvol
	sta	cheffect,x
	inc	chdidvib,x
	lda	parm
	and	#$F
	beq	effect13a
	eor	#$FFFF
	inc	a
	sta	chvolslide,x
effect13a	jmp	playnote
;        
; parse wave offset
;
effect14	pla
	tax
	asl	a
	tay
	lda	parm
	and	#$FF
	bne	effect14a
               lda	choffset,x
effect14a	sta	WaveOffset,y
	sta	choffset,x
	lda	pitch
	bne	effect14b
	lda	chpitch,x
	sta	pitch
effect14b	jmp	playnote
;
; parse position jump
;
effect15	lda	jukeflag
	bne	effect15a
	inc	end_pattern
	lda	parm
	and	#$FF
	dec	a
	sta	position
	stz	note
effect15a	jmp	effectplaynote
;
; parse pattern break effect
;
effect16	inc	end_pattern
	lda	parm
	and	#$FF
	sta	note
	jmp	effectplaynote
;
; PatternLoop
;
effect17	lda	parm
	and	#$0F
	bne	effect17a
	lda	note	;set the loop start
	sta	loopstart
	bra	effect17b
effect17a	lda	pattloop
	beq	effect17c
	dec	a	;next
	sta	pattloop
	beq	effect17b
	bra	effect17d
effect17c	lda	parm	;the first time
	and	#$0F
	sta	pattloop
effect17d	lda	end_pattern
	bne	effect17e
	dec	position
	inc	end_pattern
effect17e	lda	loopstart
	sta	note
effect17b	jmp	effectplaynote
;
; parse pattern delay
;
effect18	lda	parm
	and	#$F
	sta	pattdelay
	jmp	effectplaynote
;
; parse set finetune
;
effect19	ply
	lda	parm
	and	#$F
	asl	a
	sta	chtune,y
	tax
	lda	notenum
	bne	effect19a
	lda	chnote,y
      	beq	effect19b
effect19a	asl	a
effect19c	adc	noteofftbl,x
	tax
	lda	notepitch,x
	ldx	pitch
	beq	effect19d
	sta	pitch
	bra	effect19b
effect19d	sta	chpitch,y
	tyx
	pha
	jsr	putblip
	pla
	asl	a
	tay
	php
	short	at
	txa
	asl	a
	sta	>SOUNDADRL
	lda	pitchtab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	txa
	asl	a
	ora	#$20
	sta	>SOUNDADRL
	lda	pitchtab+1,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
	bra	effect19e               
effect19b	tyx
effect19e	jmp	playnote	
;
; parse note retrig effect
;
effect1A	plx
	lda	parm
	and	#$F
	beq	effect1Ab
	asl	a
	sta	chretrigrate,x
	sta	chnextretrig,x
	lda	#applyretrig
	sta	cheffect,x
	lda	pitch
	beq	effect1Ab
	sta	chpitch,x
effect1Ab	jmp	playnote
;
; parse note cut effect
;
effect1B	plx
	lda	parm
	and	#$F
	inc	a
	asl	a
	sta	chnextretrig,x
	lda	#applynotecut
	sta	cheffect,x
	jmp	playnote
;                               
; parse note delay effect
;
effect1C	plx
	lda	parm
	and	#$F
	inc	a
	asl	a
	sta	chnextretrig,x
	lda	#applynotedelay
	sta	cheffect,x
	lda	pitch
	beq	effect1Cb
	sta	chpitch,x
	stz	pitch
effect1Cb	jmp	nextchann
;
; parse tremelo effect
;
effect1D	plx
	lda	#applytremelo
	sta	cheffect,x
	inc	chdidtrem,x
	lda	parm
	beq	effect1Da
	and	#$F
	beq	effect1Db
	xba		;*64
	lsr	a
	lsr	a
	sta	chtremdepth,x
effect1Db	lda	parm
	and	#$F0
	beq	effect1Da
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	chtremrate,x	
effect1Da	jmp	playnote
;
; effects processor
;
noeffect	rts
;
; apply fine pitchbend to the current channel
;
applyfpitchbend lda	#noeffect
	sta	cheffect,x
	bra	pbe
;
; apply the pitchbend to the current channel
;
applypitchbend	lda	pulse
	cmp	#2
	bcs	pbe
	rts
pbe	lda	chslide,x
	bmi	pbf
	lsr	a
	bcc	pbg
	tay
	lda	pulse
	lsr	a
	bcc	pbh
	iny
	clc
pbh	tya
pbg	bra	pbi

pbf	eor	#$FFFF
	inc	a
	lsr	a
	bcc	pbj
	tay
	lda	pulse
	lsr	a
	bcc	pbk
	iny
pbk	tya
pbj	eor	#$FFFF
	sec
	
pbi	adc	chpitch,x
	bmi	pbc
	cmp	#1024
	bcc	pba
	lda	#1023
	bra	pbb
pba	cmp	#113
	bcs	pbb
pbc            lda	#113
pbb	sta	chpitch,x
	jsr	putblip
	lda	chpitch,x
	asl	a
	tay
	php
	short	at
	txa
	asl	a
	sta	>SOUNDADRL
	lda	pitchtab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	txa
	asl	a
	ora	#$20
	sta	>SOUNDADRL
	lda	pitchtab+1,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
pbd            rts
;                      
; apply portamento AND volume slide
;
applyportavol	jsr	applyporta
	bra	applyvolslide
;
; apply fine volume slide
;
applyfvolslide	lda	#noeffect
	sta	cheffect,x
	clc
	bra	doeffect0d
;
; apply vebrato AND volume slide
;
applyvibvol	jsr	applyvibrato
;
; apply volume slide to the current channel
;
applyvolslide	lda	pulse
	beq	doeffect0c
	lsr	a
	bcs	doeffect0c
doeffect0d	lda	chvolslide,x
	adc	chvolume,x
	bpl	doeffect0a
	lda	#0
	bra	doeffect0b
doeffect0a	cmp	#$40
	bcc	doeffect0b
	lda	#$3F
doeffect0b	sta	chvolume,x
	tay
	lsr	a
	lsr	a
	bne	doeffect0e
	inc	a
doeffect0e	sta	VUHeight,x
	php
	short	at
	txa
	asl	a
	ora	#$40
	sta	>SOUNDADRL
	lda	voltab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	lda	voltab2,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
doeffect0c	rts
;                     
; apply portamento to the current channel
;
applyporta	lda	pulse
	cmp	#2
	jcc   doeffect1b
	lda	chpitch,x
	cmp	chpitchgoal,x
	jeq	doeffect1e
	bcc	doeffect1a
	lda	chportarate,x
	lsr	a
	bcc	doeffect1f
	tay
	lda	pulse
	lsr	a
	bcc	doeffect1g
	iny
doeffect1g	tya
doeffect1f     eor	#$FFFF
	sec
	adc	chpitch,x
	bmi	doeffect1c	
	cmp	chpitchgoal,x
	bcs	doeffect1d	
	bra	doeffect1c
doeffect1a	lda	chportarate,x
	lsr	a
	bcc	doeffect1h
	tay
	lda	pulse
	lsr	a
	bcc	doeffect1i
               iny
	clc
doeffect1i	tya
doeffect1h	adc	chpitch,x
	cmp	chpitchgoal,x
	bcc	doeffect1d
doeffect1c	lda	chpitchgoal,x
doeffect1d	sta	chpitch,x
	jsr	putblip
	lda	chpitch,x
	asl	a
	tay
	php
	short	at
	txa
	asl	a
	sta	>SOUNDADRL
	lda	pitchtab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	txa
	asl	a
	ora	#$20
	sta	>SOUNDADRL
	lda	pitchtab+1,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
doeffect1b	rts
doeffect1e	lda	#noeffect
	sta	cheffect,x
	rts
;
; apply vibrato to the current channel
;        
applyvibrato	clc
	lda	chviboffset,x
	adc	chvibrate,x
	and	#%1111111	;extra 1 for double rate
	sta	chviboffset,x
	lsr	a	;for double rate
	clc
	adc	chvibdepth,x
	and	#%1111111111111110
	tay
	lda	vibtbl0,y
	adc	chpitch,x
	pha
	jsr	putblip
	pla
	asl	a        
	tay
	php
	short	at
	txa
	asl	a
	sta	>SOUNDADRL
	lda	pitchtab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	txa
	asl	a
	ora	#$20
	sta	>SOUNDADRL
	lda	pitchtab+1,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
	rts
;
; apply arpeggio to the current channel
;          
applyarpeggio2	lda	#applyarpeggio0
	sta	cheffect,x
	lda	charp2,x
	bra	doeffect3d
applyarpeggio0	lda	#applyarpeggio1
	sta	cheffect,x
	lda	charp0,x
	bra	doeffect3d
applyarpeggio1	lda	#applyarpeggio2
	sta	cheffect,x
	lda	charp1,x
doeffect3d	pha
	jsr	putblip
	pla
	asl	a
	tay
	php
	short	at
	txa
	asl	a
	sta	>SOUNDADRL
	lda	pitchtab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	txa
	asl	a
	ora	#$20
	sta	>SOUNDADRL
	lda	pitchtab+1,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
	rts
;
; apply retrig
;
applyretrig	lda	pulse
	cmp	chnextretrig,x
	beq	doeffect4a
	rts
doeffect4a     clc
	adc	chretrigrate,x
	sta	chnextretrig,x
	txa
	lsr	a
	sta	channel
	lda	chpitch,x
	jsr	putblip
	lda	chpitch,x
	asl	a
	tay
	lda	pitchtab,y
	tay
	lda	chvolume,x
	xba
	ora	chsample,x
	tax
	lda	channel
	jmp	PlaySound
;
; apply note delay
;
applynotedelay	lda	pulse
	cmp	chnextretrig,x
	beq	doeffect5a
	rts
doeffect5a     lda	#noeffect
	sta	cheffect,x
	txa
	lsr	a
	sta	channel
	lda	chpitch,x
	jsr	putblip
	lda	chpitch,x
	asl	a
	tay
	lda	pitchtab,y
	tay
	lda	chvolume,x
	xba
	ora	chsample,x
	tax
	lda	channel
	jmp	PlaySound
;
; apply note cut
;
applynotecut	lda	pulse
	cmp	chnextretrig,x
	beq	cut
	rts
cut     	lda	#noeffect
	sta	cheffect,x
	stz	chvolume,x
	lda	#1
	sta	VUHeight,x
	php
	short	at
	txa
	asl	a
	ora	#$40
	sta	>SOUNDADRL
	lda	#0
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
	rts
;
; apply tremelo to the current channel
;        
applytremelo	clc
	lda	chtremoffset,x
	adc	chtremrate,x
	and	#%1111111	;extra 1 for double rate
	sta	chtremoffset,x
	lsr	a	;for double rate
	clc
	adc	chtremdepth,x
	and	#%1111111111111110
	tay
	lda	vibtbl0,y
	clc
	adc	chvolume,x
	bmi	doeffect6a
	cmp	#$40
	bcc	doeffect6b
               lda	#$3F
	bra	doeffect6b
doeffect6a	lda	#0
doeffect6b	tay
	lsr	a
	lsr	a
	bne	doeffect6c
	inc	a
doeffect6c	sta	VUHeight,x
	php
	short	at
	txa
	asl	a
	ora	#$40
	sta	>SOUNDADRL
	lda	voltab,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	lda	voltab2,y
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	longa	on
	plp
	rts
                        
redtbl	dc	i'121*160+6,121*160+16,121*160+26,121*160+36'

chonoff	ds	2*8
chsample	ds	2*8
chnote	ds	2*8
chpitch	ds	2*8
chvolume	ds	2*8
chtune	ds	2*8
chslide	ds	2*8
chvolslide	ds	2*8
chportarate	ds	2*8
chpitchgoal	ds	2*8
chvibrate	ds	2*8
chvibdepth	ds	2*8
chviboffset	ds	2*8
chtremrate	ds	2*8
chtremdepth	ds	2*8
chtremoffset	ds	2*8
charp0	ds	2*8
charp1	ds	2*8
charp2	ds	2*8
cheffect	ds	2*8
choffset	ds	2*8
chretrigrate	ds	2*8
chnextretrig	ds	2*8
chdidvib	ds	2*8
chdidtrem	ds	2*8

IRQFlag	ENTRY
	dc	i2'0'

	END

*
* Song specific data
*

SongData	DATA

nvoices	dc	i2'15'
npatterns	dc	i2'0'
songkind	dc	i2'0'

VoicePtrTab	ds	32*4	;voice pointer
VoiceLenTab	ds	32*4	;voice length
VoiceVolTab	ds	32*4	;voice volume
VoiceTunTab	ds	32*4	;voice tuning
VoiceDocTab	ds	32*4	;voice DOC address
VoiceResTab	ds	32*4	;voice DOC resolution
VLoopPtrTab	ds	32*4	;loop pointer
VLoopLenTab	ds	32*4	;loop length  
VLoopDocTab	ds	32*4	;loop DOC address
VLoopResTab	ds	32*4	;loop DOC resolution
RealLen	ds	32*4                                    

PattTable	ds	64*4	;pointer to each pattern

songlength	ds	2
postbl	ds	128

instlisttbl	dc	i4'instmem1',i1'0'
	dc	i4'instmem2',i1'0'
	dc	i4'instmem3',i1'0'
	dc	i4'instmem4',i1'0'
	dc	i4'instmem5',i1'0'
	dc	i4'instmem6',i1'0'
	dc	i4'instmem7',i1'0'
	dc	i4'instmem8',i1'0'
	dc	i4'instmem9',i1'0'
	dc	i4'instmem10',i1'0'
	dc	i4'instmem11',i1'0'
	dc	i4'instmem12',i1'0'
	dc	i4'instmem13',i1'0'
	dc	i4'instmem14',i1'0'
	dc	i4'instmem15',i1'0'
	dc	i4'instmem16',i1'0'
	dc	i4'instmem17',i1'0'
	dc	i4'instmem18',i1'0'
	dc	i4'instmem19',i1'0'
	dc	i4'instmem20',i1'0'
	dc	i4'instmem21',i1'0'
	dc	i4'instmem22',i1'0'
	dc	i4'instmem23',i1'0'
	dc	i4'instmem24',i1'0'
	dc	i4'instmem25',i1'0'
	dc	i4'instmem26',i1'0'
	dc	i4'instmem27',i1'0'
	dc	i4'instmem28',i1'0'
	dc	i4'instmem29',i1'0'
	dc	i4'instmem30',i1'0'
	dc	i4'instmem31',i1'0'

instmem1	dc	c'01- 0k   '
instnam1	ds	33
instmem2	dc	c'02- 0k   '
instnam2	ds	33
instmem3	dc	c'03- 0k   '
instnam3	ds	33
instmem4	dc	c'04- 0k   '
instnam4	ds	33
instmem5	dc	c'05- 0k   '
instnam5	ds	33
instmem6	dc	c'06- 0k   '
instnam6	ds	33
instmem7	dc	c'07- 0k   '
instnam7	ds	33
instmem8	dc	c'08- 0k   '
instnam8	ds	33
instmem9	dc	c'09- 0k   '
instnam9	ds	33
instmem10	dc	c'10- 0k   '
instnam10	ds	33
instmem11	dc	c'11- 0k   '
instnam11	ds	33
instmem12	dc	c'12- 0k   '
instnam12	ds	33
instmem13	dc	c'13- 0k   '
instnam13	ds	33
instmem14	dc	c'14- 0k   '
instnam14	ds	33
instmem15	dc	c'15- 0k   '
instnam15	ds	33
instmem16	dc	c'16- 0k   '
instnam16	ds	33
instmem17	dc	c'17- 0k   '
instnam17	ds	33
instmem18	dc	c'18- 0k   '
instnam18	ds	33
instmem19	dc	c'19- 0k   '
instnam19	ds	33
instmem20	dc	c'20- 0k   '
instnam20	ds	33
instmem21	dc	c'21- 0k   '
instnam21	ds	33
instmem22	dc	c'22- 0k   '
instnam22	ds	33
instmem23	dc	c'23- 0k   '
instnam23	ds	33
instmem24	dc	c'24- 0k   '
instnam24	ds	33
instmem25	dc	c'25- 0k   '
instnam25	ds	33
instmem26	dc	c'26- 0k   '
instnam26	ds	33
instmem27	dc	c'27- 0k   '
instnam27	ds	33
instmem28	dc	c'28- 0k   '
instnam28	ds	33
instmem29	dc	c'29- 0k   '
instnam29	ds	33
instmem30	dc	c'30- 0k   '
instnam30	ds	33
instmem31	dc	c'31- 0k   '
instnam31	ds	33
                       

	END

*
* Update vu meters
*

DrawVU     	START

VOffset        equ 	108*160        	; byte offset of scanline from $e12000

               stz 	Track

       	lda	#0
MainLoop       asl	a
               tax
	
         	lda 	VUHeight,x
            	sta 	CTHeight
	cmp	oldheight,x
	beq	nexttrack
	sta	oldheight,x

               lda 	HorzOffsets,x
               clc
               adc 	#VOffset    	; make start address of meter on screen
               tax
	ldy	#15
ULoop        	cpy 	CTHeight
               bcs 	Erase
	lda	#$6006
	bra	PutIt
Erase          lda	#0
	clc
Putit          sta 	>$E12000,x     
Continue       txa
               adc 	#160       	; next scanline
               tax
               dey
               bpl 	ULoop        	; continue

nexttrack      inc 	Track
               lda 	Track
               cmp 	#8
               bne 	MainLoop

        	rts

Track          ds	2
CTHeight	ds	2
HorzOffsets	dc	i2'62,66,70,74,82,86,90,94'
VUHeight       ENTRY
	dc 	8i2'0'
oldheight	ENTRY
	dc	8i2'0'

               END

initdig	START

	ldx	#113*160+111
	jsr	digzit
	ldx	#113*160+113
	jsr	dig0
	ldx	#113*160+113+5
	jsr	digbl
	ldx	#113*160+113+6
	jsr	dig0
	ldx	#113*160+113+11
	jsr	digbl
	ldx	#113*160+113+11+3
	jsr	dig0
	ldx	#113*160+113+11+3+5
	jsr	digbl
	ldx	#113*160+113+11+3+6
	jsr	dig0
	ldx	#113*160+113+11+3+11
	jsr	digbl
	ldx	#113*160+113+11+3+11+3
	jsr	dig0
	ldx	#113*160+113+11+3+11+3+5
	jsr	digbl
	ldx	#113*160+113+11+3+11+3+6
	jsr	dig0
	ldx	#113*160+113+11+3+11+3+6+5
	jmp	digzit

	END

drawnum	START

	ldy	#0
	cmp	#10
	bcc	ok
	iny
	sbc	#10
	cmp	#10
	bcc	ok
	iny
	sbc	#10
	cmp	#10
	bcc	ok
	iny
	sbc	#10
	cmp	#10
	bcc	ok
	iny
	sbc	#10
	cmp	#10
	bcc	ok
	iny
	sbc	#10
	cmp	#10
	bcc	ok
	iny
	sbc	#10
	cmp	#10
	bcc	ok
	iny
	sbc	#10
	cmp	#10
	bcc	ok
	iny
	sbc	#10
	cmp	#10
	bcc	ok
	iny
	sbc	#10
	cmp	#10
	bcc	ok
	iny
	sbc	#10
ok	pha
	tya
	jsr	drawdig
	txa
	clc
	adc	#6
	tax
	pla		;fall through
                        
	END

drawdig	START

	asl	a
	tay
	lda	digtbl,y
	sta	godig+1
godig	jmp	$FFFF

digtbl	dc	i'dig0'
	dc	i'dig1'
	dc	i'dig2'
	dc	i'dig3'
	dc	i'dig4'
	dc	i'dig5'
	dc	i'dig6'
	dc	i'dig7'
	dc	i'dig8'
	dc	i'dig9'
                            
	END

digbl	START

	lda	#$7050
	sta	$E12000+04*160+0,x
	sta	$E12000+06*160+0,x
	sta	$E12000+08*160+0,x
	lda	#$5050
	sta	$E12000+00*160+0,x
	sta	$E12000+02*160+0,x
	sta	$E12000+10*160+0,x
	sta	$E12000+12*160+0,x
	short	a
	sta	$E12000+00*160+2,x
	sta	$E12000+02*160+2,x
	sta	$E12000+04*160+2,x
	sta	$E12000+06*160+2,x
	sta	$E12000+08*160+2,x
	sta	$E12000+10*160+2,x
	sta	$E12000+12*160+2,x
	long	a
	rts

	END

digzit	START

	lda	#$5050
	sta	$E12000+00*160+0,x
	sta	$E12000+02*160+0,x
	sta	$E12000+04*160+0,x
	sta	$E12000+06*160+0,x
	sta	$E12000+08*160+0,x
	sta	$E12000+10*160+0,x
	sta	$E12000+12*160+0,x
	rts

	END

dig0	START

	lda	#$7070
	sta	$E12000+00*160+2,x
	sta	$E12000+12*160+2,x
	lda	#$5050
	sta	$E12000+02*160+2,x
	sta	$E12000+04*160+2,x
	sta	$E12000+06*160+2,x
	sta	$E12000+08*160+2,x
	sta	$E12000+10*160+2,x
	lda	#$5070
	sta	$E12000+02*160+0,x
	sta	$E12000+04*160+0,x
	sta	$E12000+06*160+0,x
	sta	$E12000+08*160+0,x
	sta	$E12000+10*160+0,x
	xba
	sta	$E12000+00*160+0,x
	sta	$E12000+12*160+0,x
	short	a
	sta	$E12000+00*160+4,x
	sta	$E12000+12*160+4,x
	xba
	sta	$E12000+02*160+4,x
	sta	$E12000+04*160+4,x
	sta	$E12000+06*160+4,x
	sta	$E12000+08*160+4,x
	sta	$E12000+10*160+4,x
	long	a
	rts

	END

dig1	START

	lda	#$5050
	sta	$E12000+00*160+0,x
	sta	$E12000+04*160+0,x
	sta	$E12000+06*160+0,x
	sta	$E12000+08*160+0,x
	sta	$E12000+10*160+0,x
	lda	#$7070
	sta	$E12000+12*160+2,x
	lda	#$5070
	sta	$E12000+00*160+2,x
	sta	$E12000+02*160+2,x
	sta	$E12000+04*160+2,x
	sta	$E12000+06*160+2,x
	sta	$E12000+08*160+2,x
	sta	$E12000+10*160+2,x
	xba
	sta	$E12000+02*160+0,x
	sta	$E12000+12*160+0,x
	short	a
	sta	$E12000+00*160+4,x
	sta	$E12000+02*160+4,x
	sta	$E12000+04*160+4,x
	sta	$E12000+06*160+4,x
	sta	$E12000+08*160+4,x
	sta	$E12000+10*160+4,x
	sta	$E12000+12*160+4,x
	long	a
	rts
                      
	END
                           
dig2	START

               lda	#$7070                
	sta	$E12000+12*160+0,x
	sta	$E12000+00*160+2,x
	sta	$E12000+06*160+2,x
	sta	$E12000+12*160+2,x
	lda	#$5050    
	sta	$E12000+04*160+0,x
	sta	$E12000+06*160+0,x
	sta	$E12000+02*160+2,x
	sta	$E12000+04*160+2,x
	sta	$E12000+08*160+2,x
	sta	$E12000+10*160+2,x
	lda	#$5070    
	sta	$E12000+02*160+0,x
	sta	$E12000+10*160+0,x
	xba
	sta	$E12000+00*160+0,x
	sta	$E12000+08*160+0,x
	short	a                               
	sta	$E12000+00*160+4,x
	sta	$E12000+06*160+4,x
	sta	$E12000+08*160+4,x
	sta	$E12000+10*160+4,x
	xba
	sta	$E12000+02*160+4,x
	sta	$E12000+04*160+4,x
	sta	$E12000+12*160+4,x
	long	a
	rts

	END

dig3	START

	lda	#$5050    
	sta	$E12000+04*160+0,x
	sta	$E12000+06*160+0,x
	sta	$E12000+08*160+0,x
	sta	$E12000+02*160+2,x
	sta	$E12000+04*160+2,x
	sta	$E12000+08*160+2,x
	sta	$E12000+10*160+2,x
	lda	#$7070          
	sta	$E12000+00*160+2,x
	sta	$E12000+06*160+2,x
	sta	$E12000+12*160+2,x
	lda	#$5070   
	sta	$E12000+02*160+0,x
	sta	$E12000+10*160+0,x
	xba
	sta	$E12000+00*160+0,x
	sta	$E12000+12*160+0,x
	short	a
	sta	$E12000+00*160+4,x
	sta	$E12000+06*160+4,x
	sta	$E12000+12*160+4,x
	xba
	sta	$E12000+02*160+4,x
	sta	$E12000+04*160+4,x
	sta	$E12000+08*160+4,x
	sta	$E12000+10*160+4,x
	long	a
	rts
       
	END

dig4	START

	lda	#$5050
	sta	$E12000+00*160+0,x
	sta	$E12000+08*160+0,x
	sta	$E12000+10*160+0,x
	sta	$E12000+12*160+0,x
	lda	#$7070
	sta	$E12000+06*160+0,x
	sta	$E12000+00*160+2,x
	sta	$E12000+06*160+2,x
	lda	#$5070          
	sta	$E12000+04*160+0,x
	xba    
	sta	$E12000+02*160+0,x
	sta	$E12000+02*160+2,x
	sta	$E12000+04*160+2,x
	sta	$E12000+08*160+2,x
	sta	$E12000+10*160+2,x
	sta	$E12000+12*160+2,x
	short	a
	sta	$E12000+00*160+4,x
	sta	$E12000+02*160+4,x
	sta	$E12000+04*160+4,x
	sta	$E12000+08*160+4,x
	sta	$E12000+10*160+4,x
	sta	$E12000+12*160+4,x
	xba
	sta	$E12000+06*160+4,x
	long	a
	rts
      
	END

dig5	START
	
	lda	#$7070
	sta	$E12000+00*160+0,x
	sta	$E12000+04*160+0,x
	sta	$E12000+00*160+2,x
	sta	$E12000+04*160+2,x
	sta	$E12000+12*160+2,x
	lda	#$5050    
	sta	$E12000+06*160+0,x
	sta	$E12000+08*160+0,x
	sta	$E12000+02*160+2,x
	sta	$E12000+06*160+2,x
	sta	$E12000+08*160+2,x
	sta	$E12000+10*160+2,x
	lda	#$5070    
	sta	$E12000+02*160+0,x
	sta	$E12000+10*160+0,x
               xba                
	sta	$E12000+12*160+0,x
	short	a
	sta	$E12000+02*160+4,x
	sta	$E12000+04*160+4,x
	sta	$E12000+12*160+4,x
	xba
	sta	$E12000+00*160+4,x
	sta	$E12000+06*160+4,x
	sta	$E12000+08*160+4,x
	sta	$E12000+10*160+4,x
	long	a
	rts         

	END

dig6	START

	lda	#$7070    
	sta	$E12000+04*160+0,x
	sta	$E12000+00*160+2,x
	sta	$E12000+04*160+2,x
	sta	$E12000+12*160+2,x
	lda	#$5050    
	sta	$E12000+02*160+2,x
	sta	$E12000+06*160+2,x
	sta	$E12000+08*160+2,x
	sta	$E12000+10*160+2,x
	lda	#$5070	
	sta	$E12000+02*160+0,x
	sta	$E12000+06*160+0,x
	sta	$E12000+08*160+0,x
	sta	$E12000+10*160+0,x
	xba
	sta	$E12000+00*160+0,x
	sta	$E12000+12*160+0,x
	short	a	
	sta	$E12000+00*160+4,x
	sta	$E12000+02*160+4,x
	sta	$E12000+04*160+4,x
	sta	$E12000+12*160+4,x
	xba
	sta	$E12000+06*160+4,x
	sta	$E12000+08*160+4,x
	sta	$E12000+10*160+4,x
	long	a
	rts

	END

dig7	START
	
	lda	#$7070
	sta	$E12000+00*160+0,x
	sta	$E12000+00*160+2,x
	lda	#$5050    
	sta	$E12000+02*160+0,x
	sta	$E12000+04*160+0,x
	sta	$E12000+06*160+0,x
	sta	$E12000+08*160+0,x
	sta	$E12000+10*160+0,x
	sta	$E12000+12*160+0,x
	sta	$E12000+02*160+2,x
	lda	#$5070
	sta	$E12000+06*160+2,x
	sta	$E12000+08*160+2,x
	sta	$E12000+10*160+2,x
	sta	$E12000+12*160+2,x
	xba	
	sta	$E12000+04*160+2,x
	short	a
	sta	$E12000+04*160+4,x
	sta	$E12000+06*160+4,x
	sta	$E12000+08*160+4,x
	sta	$E12000+10*160+4,x
	sta	$E12000+12*160+4,x
	xba
	sta	$E12000+00*160+4,x
	sta	$E12000+02*160+4,x
	long	a
	rts

	END

dig8	START
	
	lda	#$7070
	sta	$E12000+00*160+2,x
	sta	$E12000+06*160+2,x
	sta	$E12000+12*160+2,x
	lda	#$5050    
	sta	$E12000+02*160+2,x
	sta	$E12000+04*160+2,x
	sta	$E12000+08*160+2,x
	sta	$E12000+10*160+2,x
	lda	#$5070    
	sta	$E12000+02*160+0,x
	sta	$E12000+04*160+0,x
	sta	$E12000+08*160+0,x
	sta	$E12000+10*160+0,x
	xba
	sta	$E12000+00*160+0,x
	sta	$E12000+06*160+0,x
	sta	$E12000+12*160+0,x
	short	a
	sta	$E12000+00*160+4,x
	sta	$E12000+06*160+4,x
	sta	$E12000+12*160+4,x
	xba
	sta	$E12000+02*160+4,x
	sta	$E12000+04*160+4,x
	sta	$E12000+08*160+4,x
	sta	$E12000+10*160+4,x
	long	a
	rts

	END

dig9	START

	lda	#$5050
	sta	$E12000+10*160+0,x
	sta	$E12000+02*160+2,x
	sta	$E12000+04*160+2,x
	sta	$E12000+06*160+2,x
	sta	$E12000+10*160+2,x
	lda	#$7070          
	sta	$E12000+00*160+2,x
	sta	$E12000+08*160+2,x
	sta	$E12000+12*160+2,x
	lda	#$5070	
	sta	$E12000+02*160+0,x
	sta	$E12000+04*160+0,x
	sta	$E12000+06*160+0,x
	xba
	sta	$E12000+00*160+0,x
	sta	$E12000+08*160+0,x
	sta	$E12000+12*160+0,x
	short	a
	sta	$E12000+00*160+4,x
	sta	$E12000+12*160+4,x
	xba
	sta	$E12000+02*160+4,x
	sta	$E12000+04*160+4,x
	sta	$E12000+06*160+4,x
	sta	$E12000+08*160+4,x
	sta	$E12000+10*160+4,x
               long	a                      
	rts

	END

PutBlip	START

	using	blipdata
	using	GSOSData
	using	gendata

	txy
	
	ldx	LightsFlag
	beq   powie

	sta	newpos

	lda	blips,y
	tax
	short	a
	lda	#0
	sta	>$E12000,x
	sta	>$E120A0,x
	long	a

	ldx	#0
	lda	#1024
	sec
	sbc	newpos
	lsr	a
	lsr	a
	lsr	a
	php
	clc
	adc	postbl,y
	sta	blips,y
	tax
	plp
	bcs	odd
	short	a
	lda	icon1,y
	sta	>$E12000,x
	sta	>$E120A0,x
	long	a
	bra	done
odd	short	a
	lda	icon2,y
	sta	>$E12000,x
	sta	>$E120A0,x
	long	a
   
done	lda	#32
	sta	blipidx,y

powie	tyx
	rts

newpos	ds	2
blips	ds	8*2	

postbl	dc	i'83*160+16,85*160+16,87*160+16,89*160+16'
	dc	i'91*160+16,93*160+16,95*160+16,97*160+16'

icon1	dc	i'$10,$20,$30,$40,$10,$20,$30,$40'
icon2	dc	i'$01,$02,$03,$04,$01,$02,$03,$04'

	END

blipslide	START

	using	blipdata

	lda	blipidx
	beq	blip2
	dec	a
	sta	blipidx
	lsr	a
	asl	a
	tay
	lda	blippal1,y
	sta	$E19E00+15*32+1*2

blip2	anop
	lda	blipidx+2
	beq	blip3
	dec	a
	sta	blipidx+2
	lsr	a
	asl	a
	tay
	lda	blippal2,y
	sta	$E19E00+15*32+2*2

blip3	anop
	lda	blipidx+4
	beq	blip4
	dec	a
	sta	blipidx+4
	lsr	a
	asl	a
	tay
	lda	blippal3,y
	sta	$E19E00+15*32+3*2

blip4	anop
	lda	blipidx+6
	beq	blip5
	dec	a
	sta	blipidx+6
	lsr	a
	asl	a
	tay
	lda	blippal4,y
	sta	$E19E00+15*32+4*2

blip5	anop
	rts
                   
	END

blipdata	DATA

blipidx	ds	8*2
blippal1	dc	i'$000,$100,$211,$311,$422,$522,$633,$733'
	dc	i'$844,$944,$A55,$B55,$C66,$D66,$E77,$F77'
blippal2	dc	i'$000,$010,$121,$131,$242,$252,$363,$373'
	dc	i'$484,$494,$5A5,$5B5,$6C6,$6D6,$7E7,$7F7'
blippal3	dc	i'$000,$001,$112,$113,$224,$225,$336,$337'
	dc	i'$448,$449,$55A,$55B,$66C,$66D,$77E,$77F'
blippal4	dc	i'$000,$110,$220,$330,$440,$550,$660,$770'
	dc	i'$880,$990,$AA0,$BB0,$CC0,$DD0,$EE0,$FF0'
                                                               
	END

pauselight	START

	lda	#$4303
	sta	>$E12000+160*134+141
	sta	>$E12000+160*187+141
	lda	#$3333              
	sta	>$E12000+160*134+143
	sta	>$E12000+160*134+144
	sta	>$E12000+160*187+143
	sta	>$E12000+160*187+144

	lda	#$2202    
	sta	>$E12000+160*134+123
	sta	>$E12000+160*187+123
	lda	#$2222              
	sta	>$E12000+160*134+125
	sta	>$E12000+160*134+126
	sta	>$E12000+160*187+125
	sta	>$E12000+160*187+126

	rts

	END
                                         
playlight	START

	lda	#$4303
	sta	>$E12000+160*134+123
	sta	>$E12000+160*187+123
	lda	#$3333              
	sta	>$E12000+160*134+125
	sta	>$E12000+160*134+126
	sta	>$E12000+160*187+125
	sta	>$E12000+160*187+126

	lda	#$2202    
	sta	>$E12000+160*134+141
	sta	>$E12000+160*187+141
	lda	#$2222              
	sta	>$E12000+160*134+143
	sta	>$E12000+160*134+144
	sta	>$E12000+160*187+143
	sta	>$E12000+160*187+144

	rts

	END

ShowOscillo	START

	using	SoundDat

; this is the new oscilloscope, it uses a loopback from your
; stereo into the digitizing port of your stereo card.

	php
	short	ait

sync	lda	>SOUNDCTL
	bmi	sync

	lda	sndctl
	sta	>SOUNDCTL

	lda	#$E2
	sta	>SOUNDADRL
	lda	>SOUNDDATA
	lda	>SOUNDDATA
	
	tay
	
	lda	sndctlinc
	sta	>SOUNDCTL

	longa	on
	longi	on
	plp

	tya
	lsr	a
	lsr	a
;	lsr	a
;	asl	a

	bra	drawitbaby

; this is old oscilloscope, it averages what is playing played

old	phd
	lda	#$c000
	tcd

	php
	short	ait

	lda	#$60
	sta	<SOUNDADRL
	lda	<SOUNDDATA
	lda	<SOUNDDATA
	sta	add1+1
	lda	<SOUNDDATA
	sta	add2+1
	lda	<SOUNDDATA
	lda	<SOUNDDATA
	lda	<SOUNDDATA
	sta	add5+1
	lda	<SOUNDDATA
	sta	add6+1
	lda	<SOUNDDATA
	lda	<SOUNDDATA
	lda	<SOUNDDATA
	sta	add9+1
	lda	<SOUNDDATA
	sta	add10+1
	lda	<SOUNDDATA
	lda	<SOUNDDATA
	lda	<SOUNDDATA
	sta	add13+1
	lda	<SOUNDDATA
	sta	add14+1

               plp
	longa	on
	longi	on
	pld	

	clc
add1	lda	#0
add2	adc	#0
add5	adc	#0
add6	adc	#0
add9	adc	#0
add10	adc	#0
add13	adc	#0
add14	adc	#0
	sbc	#$80*4-1

;	lsr	a	;2048 -> 32
	lsr	a
	lsr	a
	lsr   a
	lsr   a
;	lsr	a
;	asl	a
drawitbaby	and	#%111110
               tay
	lda	lines,y
	sta	$FE

index	lda	#0
	asl	a
	tay
	lsr	a
	lsr	a
	bcs	odd

	adc	$FE
	cmp	values,y
	beq	done
	ldx	values,y
	sta	values,y
	short	a
	lda	>$E12000+160*60+16,x
	and	#$0F
	sta	>$E12000+160*60+16,x
	ldx	values,y
	lda	>$E12000+160*60+16,x
	ora	#$F0
	sta	>$E12000+160*60+16,x
	inc	index+1
	long	a
	rts              

done	short	a
	inc	index+1
	long	a
	rts

odd	clc
	adc	$FE
	cmp	values,y
	beq	done
	ldx	values,y
	sta	values,y
	short	a
	lda	>$E12000+160*60+16,x
	and	#$F0
	sta	>$E12000+160*60+16,x
	ldx	values,y
	lda	>$E12000+160*60+16,x
	ora	#$0F
	sta	>$E12000+160*60+16,x
	inc	index+1
	long	a
	rts              
                  
values	dc	128i2'0'
	dc	128i2'0'
	dc	i2'0'	;one extra
lines	dc	i2'0*160'
	dc	i2'1*160'
	dc	i2'2*160'
	dc	i2'3*160'
	dc	i2'4*160'
	dc	i2'5*160'
	dc	i2'6*160'
	dc	i2'7*160'
	dc	i2'8*160'
	dc	i2'9*160'
	dc	i2'10*160'
	dc	i2'11*160'
	dc	i2'12*160'
	dc	i2'13*160'
	dc	i2'14*160'
	dc	i2'15*160'
	dc	i2'16*160'
	dc	i2'17*160'
	dc	i2'18*160'
	dc	i2'19*160'
	dc	i2'20*160'
	dc	i2'21*160'
	dc	i2'22*160'
	dc	i2'23*160'
	dc	i2'24*160'
	dc	i2'25*160'
	dc	i2'26*160'
	dc	i2'27*160'
	dc	i2'28*160'
	dc	i2'29*160'
	dc	i2'30*160'
	dc	i2'31*160'

	END
