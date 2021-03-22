  	mcopy	m/loader.mac

	datachk off
;
; song types that are used by 'songkind'
;
;   0 - unknown/NoiseTracker/SoundTracker
;   1 - ProTracker
;   2 - StarTrekker 4
;

*
* Load the mod file
*

loadmod	START	sequencer

	using	GSOSData
	using	SongData
	using	Tables

voicenum	equ	20
voiceidx	equ	22
songstart	equ	24
songskip	equ	26
pattern	equ	28
sample	equ	30
next	equ	32
namptr	equ	36

	ldx	#0	
	txa
	jsl	seek
	lda	#20
	jsl	readbuf

; see if it's an unsupported mod...

	lda	buffer
	cmp	>sig4
	bne	oky1
	lda	buffer+2
	cmp	>sig4+2
	bne	goody
	jmp	abort
oky1           cmp	>sig5
	bne	oky2
	lda	buffer+2
	cmp	>sig5+2
	bne	goody
	jmp	abort

oky2	cmp	>sig6	;see if it's an OKTALYZER mod
	bne	oky3
	lda	buffer+2
	cmp	>sig6+2
	bne	goody
	lda	buffer+4
	cmp	>sig6+4
	bne	goody
	lda	buffer+6
	cmp	>sig6+6
	bne	goody
               jmp	LoadOKTA

oky3	anop

goody	anop
;
; we've checked all other types, let's now assume it's a normal mod
;

	ldy	#18
copyname	lda	buffer,y
	sta	modname,y
	dey
	dey
	bpl	copyname
	short	a
	lda	#0
	sta	modname+20
	long	a

	stz	songkind	;default unknown song type
	ld2	15,nvoices	;default unless a sig is found
	ld2	470,songstart
	ld2	130,songskip
;                                 
; read the signature
;
	ldx	#0
	lda	#1080
	jsl	seek
	bcs	LoadExit
	lda	#4
	jsl	readbuf
	bcs	LoadExit

	lda	buffer
	ldx	buffer+2
	cmp	>sig1
	bne	trysig2
	txa
	cmp	>sig1+2
	jeq	set31
	jmp	not31

sig1	dc	c'M.K.'
sig2	dc	h'4D264B21'	;stupid Orca... 'M"and"K!'
sig3	dc	c'FLT4T8'
sig4	dc	c'MMD0'
sig5	dc	c'GMOD'
sig6	dc	c'OKTASONG'

abort	sec
	lda	#$BADD

LoadExit	ENTRY

	php
	pha
	lda	thermoflag
	bne	exit0
	jsl	CloseThermo
exit0	pla
	plp
	rtl

trysig2	cmp	>sig2
	bne	trysig3
	txa
	cmp	>sig2+2
	beq	set31
	bra	not31

trysig3	cmp	>sig3
	bne	not31
	txa
	cmp	>sig3+2
	beq	itis3
	cmp	>sig3+2
	bne	not31
	jmp	abort

itis3	ld2	2,songkind

set31	ld2	31,nvoices
	ld2	950,songstart
	ld2	134,songskip

not31	anop

;
; at this point, song kind is set 0 or 2 ONLY!!
;
	lda	songkind
	asl	a
	tax
	lda	>loadtbl+2,x
	tay
	lda	>loadtbl,x
	tyx
	jsl	StartThermo

	lda	#20
	ldx	#0
	jsl	showthermo
	lda	nvoices
	cmp	#31
	bne	skipshow4
	lda	#4
	ldx	#0
	jsl	showthermo
skipshow4	anop

;
; set up the sample tables
;
	ldx	#0
	lda	#20
	jsl	seek
	jcs	exit
	mv2	nvoices,voicenum

	ldy	#31
	ldx	#0
zapname	lda	#0
	sta	instnam1,x
	txa
	clc
	adc	#42
	tax
	dey
	bne	zapname
	ld4	instnam1,namptr

	ldx	#4

sampleloop     phx
	lda	#30
	jsl 	readbuf
	lda	#30
	ldx	#0
	jsl	showthermo
	
               ldy	#22-2
copyinstnam	lda	buffer,y
	sta	[namptr],y
	dey
	dey
	bpl	copyinstnam
	ldy	#22
	lda	#0
	sta	[namptr],y
	add4	namptr,#42,namptr

               plx
	lda	buffer+22
	xba
	sta	buffer+22
	lda	buffer+26
	xba
	sta	buffer+26
	lda	buffer+28
	xba
	sta	buffer+28
	clc		;if rp_len + rp_offset - 1 > len
	adc	buffer+26
	dec	a
	cmp	buffer+22
	beq 	sizeadj
	bcc	sizeadj
	lsr	buffer+26	; then rp_offset /= 2
sizeadj	inc	a	;if rp_len + rp_offset > len
	cmp	buffer+22
	beq	sizeadj2
	bcc	sizeadj2
	sec
	lda	buffer+22	; then rp_len = len - rp_offset
	sbc	buffer+26
	sta	buffer+28
sizeadj2	lda	buffer+22	;if len >= 1
	cmp	#2
	bcs	sizeadj3
	stz	buffer+22
               lda	#0
	sta	VoiceLenTab,x
	sta	VoiceLenTab+2,x
	sta	VLoopLenTab,x
	sta	VLoopLenTab+2,x
	sta	RealLen,x
	sta	RealLen+2,x
	jmp	nextsamp
sizeadj3	lda	buffer+22
	asl	a
	sta	RealLen,x
	lda	#0
	rol	a
	sta	RealLen+2,x
	lda	buffer+28	;if rep_len > 1
	cmp	#2
	bcs	sizeadj4
	lda	#0	
	sta	VLoopLenTab,x
	sta	VLoopLenTab+2,x
               bra	sizeadj5
sizeadj4       lda	buffer+26
	cmp	#2
	bcs	sizeadj4a
	clc
	lda	buffer+28
	adc	buffer+26
	sta	buffer+28
	lda	#0
sizeadj4a	sta	buffer+22
	lda	buffer+28
	asl	a
	sta	VLoopLenTab,x
	lda	#0
	rol	a
	sta	VLoopLenTab+2,x

sizeadj5	lda	buffer+22
	asl	a
	sta	VoiceLenTab,x
	lda	#0
	rol	a
	sta	VoiceLenTab+2,x

	lda	buffer+25
	and	#$FF
	cmp	#$40
	bcc	putvol
	lda	#$3F	
putvol	sta	VoiceVolTab,x

	lda	buffer+24
	and	#$FF
	sta	VoiceTunTab,x

nextsamp       inx
	inx
	inx
	inx
	dec	voicenum
	jne	sampleloop
;
; zap the rest
;
	lda	#0
zapvoice	cpx	#32*4
	beq	zapdone
	sta	VoicePtrTab,x
	sta	VoicePtrTab+2,x
	sta	VoiceLenTab,x
	sta	VoiceLenTab+2,x
	sta	VLoopPtrTab,x
	sta	VLoopPtrTab+2,x
	inx
	inx
	inx
	inx
	bra	zapvoice	

zapdone	anop
;
; read song size and positions
;
	ldx	#0
	lda	songstart
	jsl	seek
	jcs	exit
	ld2	130,ReadCount
	ld4	songlength,ReadBuffer
	Read	ReadParm
	jcs	exit
	lda	#130
	ldx	#0
	jsl	showthermo
;
; check for 127 signalling protracker
;
	lda	nvoices
	cmp	#31	;protracker must be 31 voices
	bne	skippt
	lda	songkind	
	bne	skippt	;don't know what type yet
	lda	songlength+1
	and	#$FF
	cmp	#127	;is the sync byte 127??
	bne	skippt
	ld2	1,songkind	;more than likely, this is a ProTracker
;
; calculate the number of patterns
;
skippt	lda	songlength
	and	#$FF
	jeq	abort
	sta	songlength
	cmp	#129
	jcs	exit
	stz	npatterns
	ldx	#127
calcpatt	lda	postbl,x
	and	#$FF
	cmp	#64
	jcs	abort
	cmp	npatterns
	bcc	nextpatt
               sta	npatterns
nextpatt	dex
	bpl	calcpatt	
	inc	npatterns
;
; Read the samples
;	
	ldx	#0
	lda	npatterns-1
	and	#$FF00
	asl	a
	asl	a	;*1024
	bne	foo1                   
               inx
foo1           clc
	adc	songstart
	bcc	foo2
	inx
	clc
foo2	adc	songskip
	bcc	foo3
	inx
foo3	sta	next
	stx	next+2
	jsl	seek
	jcs	exit

	lda	#1
	sta	voicenum
readsamploop	lda	voicenum
	asl	a
	asl	a
	sta	voiceidx
	tax
	lda	#0
	sta	VoicePtrTab,x
	sta	VoicePtrTab+2,x
	sta	VLoopPtrTab,x
	sta	VLoopPtrTab+2,x
	lda	VoiceLenTab,x
	ora	VoiceLenTab+2,x
	jeq	loadloop
	lda	VoiceLenTab+2,x
	sta	ReadCount+2
	lda	VoiceLenTab,x
	sta	ReadCount
	ldy	#$8018+%100
	lda	VoiceLenTab+2,x
	beq	okcross
	ldy	#$8008+%100
okcross	NewHandle (ReadCount,SongID,@y,#0),0
	ldx	voiceidx
	lda	[0]
	sta	VoicePtrTab,x
	sta	ReadBuffer
	sta	4
	ldy	#2
	lda	[0],y
	sta	VoicePtrTab+2,x
	sta	ReadBuffer+2
	sta	6
	Read	ReadParm
	jcs	exit

	lda	#0
	ldy	#2
	sta	[4]	;Noisetracker and Protracker do this
	sta	[4],y

	jsl	fixup

loadloop	lda	VLoopLenTab,x
	ora	VLoopLenTab+2,x
	jeq	nextrs

	lda	VLoopLenTab+2,x
	sta	ReadCount+2
	tay
	lda	VLoopLenTab,x
	sta	ReadCount
	cpy	#0
	bne	loadloop2
	cmp	#256
	bcs	loadloop2
               lda	#512
loadloop2	NewHandle (@ya,SongID,#$C018+%100,#0),0
	ldx	voiceidx
	lda	[0]
	sta	VLoopPtrTab,x
	sta	ReadBuffer
	sta	4
	ldy	#2
	lda	[0],y
	sta	VLoopPtrTab+2,x
	sta	ReadBuffer+2
	sta	6
	Read	ReadParm
	jcs	exit

	lda	ReadCount+2
	bne	loadloop3
	lda	ReadCount
	cmp	#256
	bcs	loadloop3	;<256, so re-copy as many times as needed
	ldx	voiceidx
loadloop5	lda	VLoopLenTab,x
	clc
	adc	4
	sta	8	
	lda	6
	adc	#0
	sta	10
	ldy	ReadCount
	dey
	short	a
loadloop4	lda	[4],y
	sta	[8],y
	dey
	bpl	loadloop4
	long	a
	clc
	lda	VLoopLenTab,x
               adc	ReadCount
	sta	VLoopLenTab,x
	eor	#$FFFF
	inc	a
	clc
	adc	#511	;amount left
	cmp	ReadCount
	bcs   loadloop5
	lda	VloopLenTab,x
	sta	ReadCount

loadloop3	jsl	fixup
	ldx	voiceidx
	lda	VoiceLenTab,x
	ora	VoiceLenTab+2,x
	bne	nextrs

	lda	VloopPtrTab,x
	sta	VoicePtrTab,x
	lda	VloopPtrTab+2,x
	sta	VoicePtrTab+2,x
	lda	VloopLenTab,x
	sta	VoiceLenTab,x
	lda	VloopLenTab+2,x
	sta	VoiceLenTab+2,x
                              
nextrs	inc	voicenum
	lda	voicenum
	cmp	nvoices
	beq	nextrs2
	bcs	startpatts
nextrs2	ldx	voiceidx
	clc
	lda	next
	adc	RealLen,x
	sta	next
	tay
	lda	next+2
	adc	RealLen+2,x
	sta	next+2
	tax
	tya
	jsl	seek
	ldy	voiceidx
	ldx	RealLen+2,y
	lda	RealLen,y
	jsl	showthermo
	jmp	readsamploop
;
; read in the patterns
;
startpatts	clc
	lda	songstart
	adc	songskip
	ldx	#0
	jsl	seek
	jcs	exit

	stz	ReadCount+2

	stz	pattern
pattloop	lda	#1024
	jsl	readbuf
	jcs	exit
	lda	#1024
	ldx	#0
	jsl	showthermo
	NewHandle (#6*8*64,SongID,#$C018,#0),0
	lda	pattern
	asl	a
	asl	a
	tax
	lda	[0]
	sta	4
	sta	PattTable,x
	ldy	#2
	lda	[0],y
	sta	6
	sta	PattTable+2,x                         

	lda	#4
	sta	8
	ldx	#0
	txy
noteloop	lda	buffer,x
	and	#%00010000
	sta	sample
	lda	buffer+2,x
	and	#%11110000
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	ora	sample
	sta	[4],y
	iny
	iny
	lda	buffer,x
	xba
	and	#%0000111111111111
	beq	skiptune
	asl	a
	phx
	tax	
	lda	notetab,x
	plx
skiptune	sta	[4],y
	iny
	iny
	lda	buffer+2,x
	xba
	and	#%0000111111111111
	beq	putconv
	jsl	convert
putconv	sta	[4],y
	iny
	iny
	inx
	inx
	inx
	inx
	dec	8
	bne	noteloop
	lda	#4
	sta	8
	lda	#0
zap8	sta	[4],y
	iny
	iny	
	sta	[4],y
	iny
	iny	
	sta	[4],y
	iny
	iny	
	dec	8
	bne	zap8
	lda	#4
	sta	8
	cpx	#64*4*4
	bcc	noteloop	

	inc	pattern
	lda	pattern
	cmp	npatterns
	jcc	pattloop

	jsl	WaveIt
	jsl	DocIt
	jsl	SetSizes

	clc

exit	jmp	LoadExit

loadtbl        dc	a4'loadstr1'
	dc	a4'loadstr2'

loadstr1	dc	c'Importing NoiseTracker/ProTracker Module...',h'00'
loadstr2	dc    c'Importing StarTrekker 4 Module...',h'00'

;
; fix up a sound
;
fixup	mv4	4,8

	lda	ReadCount+2
	beq	fixup2

	short	a
	ldy	#0
fixuploop1	lda	[4],y
	eor	#$80
	bne	fixup1
	inc	a
fixup1	sta	[4],y
	iny
	bne	fixuploop1

	long	a
	inc	6

fixup2	ldy	#0
	short	a
fixuploop2	lda	[4],y
	eor	#$80
	bne	fixup3
	inc	a
fixup3	sta	[4],y
	iny
	cpy	ReadCount
	bne	fixuploop2

	long	a

	rtl

; convert mod effect to soniq effect

convert	phy
	phx
	sta	>temp
	xba
	and	#$F
	asl	a
	tax
	jmp	(convtbl1,x)

convtbl1	dc	i2'conv00'	;$00 - Arpeggio
	dc	i2'conv01'    	;$01 - Slide Up
	dc	i2'conv02'    	;$02 - Slide Down
	dc	i2'conv03'    	;$03 - Tone Portamento
	dc	i2'conv04'    	;$04 - Vibrato
	dc	i2'conv05'    	;$05 - Tone Porta + Vol Slide
	dc	i2'conv06'    	;$06 - Vibrato + Vol Slide
	dc	i2'conv07'    	;$07 - Tremelo
	dc	i2'convunknown'    ;$08 - NOT USED
	dc	i2'conv09'    	;$09 - Set SampleOffset
	dc	i2'conv0a'    	;$0A - VolSlide
	dc	i2'conv0b'    	;$0B - Pos Jump
	dc	i2'conv0c'    	;$0C - Set Volume
	dc	i2'conv0d'    	;$0D - Pattern Break
	dc	i2'conv0e'    	;$0E - E-Commands
	dc	i2'conv0f'    	;$0F - Set Speed

convtbl2	dc	i2'conve0'	;$0 - Set Filter
	dc	i2'conve1'    	;$1 - FineSlide Up
	dc	i2'conve2'    	;$2 - FineSlide Down
	dc	i2'conve3'    	;$3 - Glissando Control
	dc	i2'conve4'    	;$4 - Set Vibrato Waveform
	dc	i2'conve5'    	;$5 - Set FineTune
	dc	i2'conve6'    	;$6 - Pattern Loop
	dc	i2'conve7'   	;$7 - Set Tremelo WaveForm
	dc	i2'convunknown'    ;$8 - NOT USED
	dc	i2'conve9'    	;$9 - Retrig Note
	dc	i2'convea'    	;$A - Fine VolumeSlide Up
	dc	i2'conveb'    	;$B - Fine VolumeSlide Down
	dc	i2'convec'    	;$C - Note Cut
	dc	i2'conved'    	;$D - Note Delay
	dc	i2'convee'    	;$E - Pattern Delay
	dc	i2'convef'	;$F - Invert Loop
                                    
conv00	lda	>temp    
	and	#$FF
	ora	#$0200
	jmp	convdone

conv01	lda	>temp    
	and	#$FF
	ora	#$0800
	jmp	convdone

conv02	lda	>temp              
	and	#$FF
	ora	#$0900
	jmp	convdone

conv03	lda	>temp              
	and	#$FF
	ora	#$0C00
	jmp	convdone

conv04	lda	>temp              
	and	#$FF
	ora	#$0F00
	jmp	convdone

conv05	lda	>temp
	bit	#$F0
	bne	conv05a
	and	#$0F
	ora	#$1100
	jmp	convdone
conv05a	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$0F
	ora	#$1000
	jmp	convdone

conv06	lda	>temp
	bit	#$F0
	bne	conv06a
	and	#$0F
	ora	#$1300
	jmp	convdone
conv06a	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$0F
	ora	#$1200
	jmp	convdone

conv07	lda	>temp              
	and	#$FF
	ora	#$1D00
	jmp	convdone

conv09	lda	>temp              
	and	#$FF
	ora	#$1400
	jmp	convdone

conv0a	lda	>temp
	bit	#$F0
	bne	conv0aa
	and	#$0F
	ora	#$0500
	jmp	convdone

conv0aa	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$0F
	ora	#$0400
	jmp	convdone

conv0b	lda	>temp              
	and	#$FF
	ora	#$1500
	jmp	convdone

conv0c	lda	>temp              
	and	#$FF
	cmp	#$40
	bcc	conv0ca
	lda	#$3F
conv0ca	ora	#$0300
	jmp	convdone

conv0d	lda	>temp
	and	#$FF
	beq	conv0da
	and	#$F0	;convert BCD to hex
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	pha
	asl	a
	asl	a
	adc	1,s
	asl	a
	sta	1,s
	lda	>temp
	and	#$F
	adc	1,s
	plx
conv0da	ora	#$1600
	jmp	convdone
      
conv0e	lda	songkind
	cmp	#2	;is StarTrekker?
	jeq	conv0estar
	lda	>temp
	and	#$F0
	lsr	a
	lsr	a
	lsr	a
	tax
	jmp	(convtbl2,x)

conv0estar	lda	#$0000
	jmp	convdone

conv0f	lda	>temp
	and	#$FF
	cmp	#$20
	bcc	conv0fa
	ldy	songkind	;if not protracker....
	dey		
	bne	conv0fa
	ora	#$0E00
	jmp	convdone
conv0fa	ora	#$0D00
	jmp	convdone

conve0	lda	#$0000
	jmp	convdone

conve1	lda	>temp    
	and	#$0F
	ora	#$0A00
	jmp	convdone

conve2	lda	>temp    
	and	#$0F
	ora	#$0B00
	bra	convdone

conve7	anop
conve4	anop
conve3	lda	>temp
	and	#$F
	beq	conve0
	bra	convunknown

conve5	lda	>temp    
	and	#$0F
	ora	#$1900
	bra	convdone

conve6	lda	>temp    
	and	#$0F
	ora	#$1700
	bra	convdone

conve9	lda	>temp              
	and	#$0F
	ora	#$1A00
	bra	convdone

convea	lda	>temp              
	and	#$0F
	ora	#$0600
	bra	convdone

conveb	lda	>temp    
	and	#$0F
	ora	#$0700
	bra	convdone

convec	lda	>temp    
	and	#$0F
	ora	#$1B00
	bra	convdone

conved	lda	>temp              
	and	#$0F
	ora	#$1C00
	bra	convdone

convee	lda	>temp              
	and	#$0F
	ora	#$1800
	bra	convdone

convef	lda	#$0000
	jmp	convdone

convunknown	lda	#$0100             
convdone	plx
	ply
	rtl

temp	ds	2

	END

*
* Open the mod file
*

openfile	START	sequencer

	using	GSOSData

	Open	OpenParm
	bcs	done
	mv2	OpenRef,(ReadRef,SetMarkRef,GetEOFRef,CloseRef)

	clc
done	rtl

	END

*                      
* seek a file position
*

seek	START	sequencer

	using	GSOSData

	sta	SetMarkPos
	stx	SetMarkPos+2
	SetMark SetMarkParm
	rtl

	END

*
* read acc bytes into the common buffer
*

readbuf	START sequencer

	using	GSOSData

	sta	ReadCount
	stz	ReadCount+2
	ld4	buffer,ReadBuffer
	Read	ReadParm
	rtl

	END

*
* update the thermometer position
*

showthermo	START	sequencer

	using	GSOSData

	ldy	thermoflag	
	bne	st0
	clc
	adc	tread
	sta	tread
	txa
	adc	tread+2
	sta	tread+2
	lda	tread+1
	jsl	UpdateThermo
st0	rtl

 	END


*
* Start the thermometer for a new file
*

StartThermo	START	sequencer

	using	GSOSData

	ldy	thermoflag
	bne	done

	phx
	pha

	GetEOF GetEOFParm
	ph2	GetEOFeof+1
	jsl	OpenThermo
	lda	#0
	sta	tread
	sta	tread+2

done	rtl

	END
