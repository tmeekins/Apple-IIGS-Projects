    	mcopy	m/soundtool.mac

MasterVolume	gequ	$E100CA
SoundStarted	gequ	$E11DB6
SOUNDCTL	gequ	$E0C03C
SOUNDDATA	gequ	$E0C03D
SOUNDADRL	gequ	$E0C03E
SOUNDADRH	gequ	$E0C03F

**************************************************************************
*
* Sound Start
*
**************************************************************************
                                                                          
SoundStart	START

	using	SoundDat

	php
	short	at

	lda	>MasterVolume
	sta	sndctl
	ora	#%01000000
	sta	sndctlram
	ora	#%00100000
	sta	sndctlraminc
	lda	sndctl
	ora	#%00100000
	sta	sndctlinc
	sta	>SOUNDCTL	;<- default, ALWAYS set!!!!

	lda	#$40	;0 volume
	sta	>SOUNDADRL

	lda	#0
	ldx	#$1E
zapvol	sta	>SOUNDDATA
	dex
	bne	zapvol

	lda	#$A0	;one-shot, no interrupts
	sta	>SOUNDADRL
	lda	#2
	ldx	#$1E
zapctl	sta	>SOUNDDATA
	dex
	bne	zapctl

	lda	#$E1
	sta	>SOUNDADRL
	lda	#$3E
	sta	>SOUNDDATA

	lda	#$9E	;clock wave ptr
	sta	>SOUNDADRL
	lda	ClockAdr+1
	sta	>SOUNDDATA

	lda	#$DE
	sta	>SOUNDADRL
	lda	#0
	sta	>SOUNDDATA

	lda	sndctlraminc
	sta	>SOUNDCTL
	lda	ClockAdr
	sta	>SOUNDADRL
	lda	ClockAdr+1
	sta	>SOUNDADRH
	ldy	#255
	lda	#$80
zap            sta	>SOUNDDATA
	dey
	bpl	zap

	lda	sndctlinc
	sta	>SOUNDCTL

	lda	#$BE
	sta	>SOUNDADRL
	lda	#%1000	;free-form w/ interrupts
	sta	>SOUNDDATA

	longa	on
	plp
;
; Set the Master IRQ Vector
;
	GetVector #$B,OldIRQ
	SetVector (#$B,#SoundIRQ)

	rts

	END

**************************************************************************
*
* Sound Stop
*
**************************************************************************

SoundStop	START

	using	SoundDat

	php
	short	at

	lda	#$40	;0 volume
	sta	>SOUNDADRL
	lda	#0
	ldx	#$1E
zapvol	sta	>SOUNDDATA
	dex
	bne	zapvol

	lda	#$A0
	sta	>SOUNDADRL
	lda	#%11
	ldx	#$20
zapctl	sta	>SOUNDDATA
	dex
	bne	zapctl

	longa	on
	plp
           
	SetVector (#$B,OldIRQ)

	rts

	END                                                              
                                                                          
**************************************************************************
*
* Play Sound
* on entry:
*  A = track number
*  X = Voice number (volume in upper byte)
*  Y = Frequency
*
**************************************************************************

PlaySound	START

	using	SoundDat
	using	SongData
	using	Tables
	using	GSOSData

	php
	sei
;
; calculate some indices
;
	sty	freq
	asl	a
	asl	a
	sta	trackidx
	tay
	lda	WaveChannel,y
	sta	channel	
	txa
	xba
	sta	vol
	xba
	and	#$1F
	asl	a
	asl	a
	sta	voiceidx
	tax

	phd
	lda	#$C000
	tcd

	lda	VoiceDocTab+2,x
	jeq	normal
	lda	WaveOffset,y
	jne	normal
	lda	VLoopPtrTab,x
	ora	VLoopPtrTab+2,x
	beq	indoc
	lda	VLoopDocTab+2,x
	jeq	normal

;
; this instrument is in permanant DOC Ram
;
indoc	short	ai
docwait	lda	>SOUNDCTL
	bmi	docwait

	tya		;stop the oscillators
	ora	#$A0
	sta	>SOUNDADRL
	lda	channel
	ora	#%0011
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
;	lda	channel
;	ora	#%0011
	eor	ChannelMode
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
                         
	tya		;Set the wave size
	ora	#$C0
	sta	>SOUNDADRL
	lda	VoiceResTab,x
	sta	>SOUNDDATA
	tya
	ora	#$C2
	sta	>SOUNDADRL
	lda	VoiceResTab,x
	sta	>SOUNDDATA

	tya		;Set frequency
	sta	>SOUNDADRL
	lda	freq
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
	tya
	ora	#$20     
	sta	>SOUNDADRL
	lda	freq+1
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
                              
	tya		;Set Volume
	ora	#$40
	sta	>SOUNDADRL
	ldx	vol
	lda	voltab,x
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
	lda	voltab2,x
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
	ldx	voiceidx

	tya		;Set wave pointer
	ora	#$80
	sta	>SOUNDADRL
	lda	VoiceDocTab+1,x
	sta	>SOUNDDATA
	tya
	ora	#$82
	sta	>SOUNDADRL
	lda	VoiceDocTab+1,x
	sta	>SOUNDDATA

	lda	VLoopDocTab+2,x
	bne	inDocLoop

	tya		;start the oscillator
	ora	#$A0
	sta	>SOUNDADRL
	lda	channel
	ora	#%0010
	sta	>SOUNDDATA
	tya
	ora	#$A2
	sta	>SOUNDADRL
	lda	channel
	eor	ChannelMode
	ora	#%0010
	sta	>SOUNDDATA

	jmp	done

inDocLoop	tya		;Set the wave size
	ora	#$C1
	sta	>SOUNDADRL
	lda	VLoopResTab,x
	sta	<SOUNDDATA
	tya
	ora	#$C3
	sta	>SOUNDADRL
	lda	VLoopResTab,x
	sta	>SOUNDDATA

	tya		;Set wave pointer
	ora	#$81
	sta	>SOUNDADRL
	lda	VLoopDocTab+1,x
	sta	>SOUNDDATA
	tya
	ora	#$83
	sta	>SOUNDADRL
	lda	VLoopDocTab+1,x
	sta	>SOUNDDATA

	tya		;start the oscillator
	ora	#$A0
	sta	>SOUNDADRL
	lda	channel
	ora	#%1110
	sta	>SOUNDDATA
	lda	channel
	ora	#%0111
	sta	>SOUNDDATA
	lda	channel
	eor	ChannelMode
	ora	#%0110
	sta	>SOUNDDATA
	lda	channel
	eor	ChannelMode
	ora	#%0111
	sta	>SOUNDDATA

	lda	VLoopDocTab+1,x
	sta	WaveDoc,y
	lda	VLoopDocTab+2,x
	sta	WaveDoc+2,y
	lda	VLoopResTab,x
	sta	WaveRes,y

	long	a
	lda	VLoopPtrTab,x
	sta	WavePtr,y
	sta	NextWavePtr,y
	lda	VLoopPtrTab+2,x
	sta	WavePtr+2,y
	sta	NextWavePtr+2,y
                      
godone	jmp	done
;
; copy data for this track
;
normal	longi	on

	lda	VLoopDocTab+1,x
	and	#$FF
	sta	WaveDoc,y
	lda	VLoopDocTab+2,x
	sta	WaveDoc+2,y
	lda	VLoopResTab,x
	sta	WaveRes,y

	lda	VoicePtrTab,x
	sta	WavePtr,y
	lda	VoicePtrTab+2,x
	sta	WavePtr+2,y
               ora	WavePtr,y
	beq	godone
	
	lda	VLoopPtrTab,x
	sta	NextWavePtr,y
	lda	VLoopPtrTab+2,x
	sta	NextWavePtr+2,y
	               
	lda	VoiceLenTab,x
	sta	WaveLen,y
	lda	VoiceLenTab+2,x
	sta	WaveLen+2,y
                         
	lda	VLoopLenTab,x
	sta	NextWaveLen,y
	lda	VLoopLenTab+2,x
	sta	NextWaveLen+2,y

	lda	WaveOffset,y
	beq	nooff
	cmp	WaveLen+1,y
	bcc	ofok

	lda	WaveOffset,y
	sbc	WaveLen+1,y
	cmp	NextWaveLen+1,y
	bcc	ofrecalc

	lda	#0
	sta	WaveOffset,y
	bra	nooff

ofrecalc	lda	NextWavePtr,y
	sta	WavePtr,y
	lda	NextWavePtr+2,y
	sta	WavePtr+2,y

	lda	NextWaveLen,y
	sta	WaveLen,y
	lda	NextWaveLen+2,y
	sta	WaveLen+2,y
	bra	ofok2
                         
ofok	anop
;	clc
	lda	WavePtr+1,y
	adc	WaveOffset,y
	sta	WavePtr+1,y

	sec
	lda	WaveLen+1,y
	sbc	WaveOffset,y
	sta	WaveLen+1,y

ofok2	lda	#0
	sta	WaveOffset,y

nooff	short	ai

docwait2	lda	>SOUNDCTL
	bmi	docwait2

	tya		;Set the wave size
	ora	#$C0
	sta	>SOUNDADRL
	lda	#%000000
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
                              
	tya		;Set frequency
	sta	>SOUNDADRL
	lda	freq
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
	tya
	ora	#$20     
	sta	>SOUNDADRL
	lda	freq+1
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
                              
	tya		;Set Volume
	ora	#$40
	sta	>SOUNDADRL
	ldx	vol
	lda	voltab,x
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
	lda	voltab2,x
	sta	>SOUNDDATA    
;	nop
	sta	>SOUNDDATA
                              
	tya		;Set wave pointer
	ora	#$80
	sta	>SOUNDADRL
	lda	DOCAdr+1,y
	sta	>SOUNDDATA
	lda	DOCAdr+3,y
	sta	>SOUNDDATA
	lda	DOCAdr+1,y
	sta	>SOUNDDATA
	lda	DOCAdr+3,y
	sta	>SOUNDDATA
                              
	tya		;stop the oscillator
	ora	#$A0
	sta	>SOUNDADRL
	lda	channel
	ora	#%1111
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
	lda	channel
	eor	ChannelMode
	ora	#%0111
	sta	>SOUNDDATA
;	nop
	sta	>SOUNDDATA
                              
	long	ai

	lda	#1
	jsr	NextDOCPage

	short	ai

docwait3	lda	>SOUNDCTL
	bmi	docwait3

	lda	#$A1	;start the oscillator
	ora	trackidx
	sta	>SOUNDADRL
	lda	channel
	ora	#%1110
	sta	>SOUNDDATA
	lda	#$A3	;start the oscillator
	ora	trackidx
	sta	>SOUNDADRL
	lda	channel
	eor	ChannelMode
	ora	#%0110
	sta	>SOUNDDATA

	long	ai

	lda	#0
	jsr	NextDOCPage

done	pld
	plp
	longa	on
	longi	on
	rts

freq	ds	2
vol	ds	2	;<= ALWAYS ACCESS AS BYTE!!!!!

	END

**************************************************************************
*
* Halt Sound
* on entry:
*  A = track number
*
**************************************************************************

HaltSound	START

	using	SoundDat
	using	GSOSData

	asl	a
	asl	a
	tay
	lda	#0
	sta	WavePtr,y
	sta	WavePtr+2,y

	short	ai

	tya
	ora	#$A0	;set the control register
	sta	>SOUNDADRL
	lda	WaveChannel,y
	ora	#%00000111
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	eor	ChannelMode
	sta	>SOUNDDATA
	sta	>SOUNDDATA

	tya
	ora	#$40
	sta	>SOUNDADRL
	lda	#0
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA
	sta	>SOUNDDATA

	long	ai

	rts

	END

**************************************************************************
*
* Handle a sound IRQ
*
**************************************************************************

SoundIRQ	START

	using	SoundDat
	using	GSOSData

	longa	off
	longi	off

	phb
	phk
	plb

	long	ai
	phd
	lda	#$C000
	tcd
	short	ai

	lda	>$E100CC

irqloop	ldx	sndctlinc
	stx	<SOUNDCTL
	lsr	a
	and	#$1F
	sta	osc
	lsr	a
	cmp	#15
	beq	special
	lsr	a
	sta	tracknum
	asl	a
	asl	a
	sta	trackidx

	long	ai

	ldx	trackidx
	lda	WaveChannel,x
	sta	channel
	lda	WavePtr,x
	ora	WavePtr+2,x
	beq	halt	

	lda	osc
	and	#1
	jsr	NextDOCPage

done	short	ai
docwait	lda	>SOUNDCTL
	bmi	docwait
	lda	sndctl
	sta	>SOUNDCTL
	lda	#$E0
	sta	>SOUNDADRL
;	nop
	lda	>SOUNDDATA
	lda	#0
	sta	>SOUNDADRL
;	nop
	lda	>SOUNDDATA
	bpl	irqloop

	lda	sndctlinc
	sta	>SOUNDCTL

	pld
	plb
	clc
	rtl

special	inc	IRQFlag
	jmp	done

halt	short	ai
docwait2	lda	>SOUNDCTL
	bmi	docwait2
	lda	#$A0
	ora	osc
	eor	#1
	sta	>SOUNDADRL
	lda	channel
	ora	#1
	sta	>SOUNDDATA
	lda	#$A2
	ora	osc
	eor	#1
	sta	>SOUNDADRL
	lda	channel
	eor	ChannelMode
	ora	#1
	sta	>SOUNDDATA
	lda	tracknum
	asl	a
	tax
	lda	#1
	sta	VUHeight,x
	bra	done

osc	ds	2

	END

**************************************************************************
*
* Blast next DOC Page
* On Entry:
*   A = osc pair to blast to.
*
**************************************************************************

NextDOCPage	START

	using	SoundDat
	using	GSOSData

	longa	on
	longi	on

	sta	osc

	ldx	trackidx
	txy
	cmp	#0
	beq	even
	iny
	iny
even	anop

	lda	WavePtr,x
	cmp	NextWavePtr,x
	jne	normal2
	lda	WavePtr+2,x
	cmp	NextWavePtr+2,x
	bne	normal
	lda	WaveDoc+2,x
	beq	normal

	short	a

	txa	                   ;Set the wave size
	ora	osc
	ora	#$C0
	sta	>SOUNDADRL
	lda	WaveRes,x
	sta	>SOUNDDATA
	txa
	ora	osc
	ora	#$C2
	sta	>SOUNDADRL
	lda	WaveRes,x
	sta	>SOUNDDATA

	txa	                   ;Set wave pointer
	ora	osc
	ora	#$80
	sta	>SOUNDADRL
	lda	WaveDoc,x
	sta	>SOUNDDATA
	txa
	ora	osc
	ora	#$82
	sta	>SOUNDADRL
	lda	WaveDoc,x
	sta	>SOUNDDATA

	txa	                   ;start the oscillator
	ora	osc
	ora	#$A0
	sta	>SOUNDADRL
	lda	channel
	ora	#%0111
	sta	>SOUNDDATA
	txa
	ora	osc
	ora	#$A2
	sta	>SOUNDADRL
	lda	channel
	eor	ChannelMode
	ora	#%0111
	sta	>SOUNDDATA

	long	a
	rts

normal	lda	WavePtr,x	;if it's already there, don't blast.
normal2	cmp	WaveDOCPtrL,y
	bne	setptr2
	lda	WavePtr+2,x
	cmp	WaveDOCPtrH,y
	bne	setptr

	lda	WaveLen+1,x
	bne	coolbeans
	lda	NextWavePtr,x
	sta	WavePtr,x
	lda	NextWaveptr+2,x
	sta	WavePtr+2,x
	lda	NextWaveLen,x
	sta	WaveLen,x
	lda	NextWaveLen+2,x
	sta	WaveLen+2,x
	rts
coolbeans	dec	a
	sta	WaveLen+1,x
	inc	WavePtr+1,x
	rts

setptr	lda	WavePtr,x	;save this doc pointer
setptr2	sta	WaveDOCPtrL,y
	lda	WavePtr+2,x
	sta	WaveDOCPtrH,y	

	short	a
docwait	lda	>SOUNDCTL
	bmi	docwait
	lda	sndctlraminc
	sta	>SOUNDCTL
	long	a

	lda	DOCAdr,y	;point to DOC ram
putadr	sta	>SOUNDADRL

	lda	WaveLen+1,x	;see if less than a page is left
	beq	PartialWave
;
; Copy 256 bytes
;
	phb
	lda	WavePtr,x
               cmp	#$FF01
	bcs	normalslam
	tay
	lda	#0	;make sure upper byte is 0
	short	a
	lda	WavePtr+2,x
	ldx	osc
	bne	slam2
	pha
	plb
	jmp	DOCslameven
slam2	pha
	plb
	jmp	DOCslamodd

normalslam	sta	copy256+1
	short	ai
	lda	WavePtr+2,x
	pha
	plb
	ldy	#0
copy256	lda	$FFFF,y
copy256a	sta	<SOUNDDATA
	iny
	bne	copy256
endslam	ENTRY
	long	ai
	plb
	ldx	trackidx
	dec	WaveLen+1,x
	bne	ok256
	lda	WaveLen,x
	beq	exact256
ok256	inc	WavePtr+1,x
	short	a
	lda	sndctlinc
	sta	>SOUNDCTL
	long	a
	rts

exact256	lda	NextWavePtr,x
	sta	WavePtr,x
	lda	NextWaveptr+2,x
	sta	WavePtr+2,x
	lda	NextWaveLen,x
	sta	WaveLen,x
	lda	NextWaveLen+2,x
	sta	WaveLen+2,x
	short	a
	lda	sndctlinc
	sta	>SOUNDCTL
	long	a
	rts    
;       
; Copy only part of a wave
;
PartialWave	lda	WaveLen,x
	tay
	phb
	lda	WavePtr,x
	sta	copypart+1
	short	ai
	lda	WavePtr+2,x
	pha
	plb
	ldx	#0
copypart	lda	$FFFF,x
copypart2	sta	<SOUNDDATA
	inx
	dey
	bne	copypart
	plb
	phx
	long	ai
;
; let's see if there is a next wave pointer
;
	ldx	trackidx
	lda	NextWavePtr,x
	ora	NextWavePtr+2,x
	bne	blastnext
	lda	#0
	short	ai
	plx
copyzero	sta	<SOUNDDATA
	inx
	bne	copyzero
	long	ai
	ldx	trackidx
	sta	WavePtr,x
	sta	WavePtr+2,x

	short	ai
docwait2	lda	>SOUNDCTL
	bmi	docwait2
	lda	sndctlinc
	sta	>SOUNDCTL
	txa
	ora	osc
	ora	#$A0	;make one-shot
	sta	>SOUNDADRL
	lda	channel
	ora	#%0011
	sta	>SOUNDDATA
	txa
	ora	osc
	ora	#$A2	;make one-shot
	sta	>SOUNDADRL
	lda	channel
	eor	ChannelMode
	ora	#%0011
	sta	>SOUNDDATA

	long	ai
	rts
;
; Set up the next next wave and fill up the buffer
;
blastnext	short	ai
	plx
copyzero2	stz	<SOUNDDATA
	inx
	bne	copyzero2
	long	ai
	ldx	trackidx
	lda	NextWavePtr,x
	sta	WavePtr,x
	lda	NextWaveptr+2,x
	sta	WavePtr+2,x
	lda	NextWaveLen,x
	sta	WaveLen,x
	lda	NextWaveLen+2,x
	sta	WaveLen+2,x
                              
	short	a
	lda	sndctlinc
	sta	>SOUNDCTL
	long	a
	rts

osc	ds	2

	END
                  
**************************************************************************
*
* DOC slammer
*
**************************************************************************

DOCslameven	START

	using	Tables

	longa	off
	longi	on

	lda	|0,y
	tax
	lda	>wavtab02,x
	sta	<SOUNDDATA
	lda	|1,y
	tax
	lda	>wavtab04,x
	sta	<SOUNDDATA
	lda	|2,y
	tax  
	lda	>wavtab06,x
	sta	<SOUNDDATA
	lda	|3,y
	tax    
	lda	>wavtab08,x
	sta	<SOUNDDATA
	lda	|4,y
	tax   
	lda	>wavtab0a,x
	sta	<SOUNDDATA
	lda	|5,y
	tax    
	lda	>wavtab0c,x
	sta	<SOUNDDATA
	lda	|6,y
	tax   
	lda	>wavtab0e,x
	sta	<SOUNDDATA
	lda	|7,y      
	sta	<SOUNDDATA
	lda	|8,y      
	sta	<SOUNDDATA
	lda	|9,y      
	sta	<SOUNDDATA
	lda	|10,y      
	sta	<SOUNDDATA
	lda	|11,y      
	sta	<SOUNDDATA
	lda	|12,y      
	sta	<SOUNDDATA
	lda	|13,y      
	sta	<SOUNDDATA
	lda	|14,y      
	sta	<SOUNDDATA
	lda	|15,y      
	sta	<SOUNDDATA
	lda	|16,y      
	sta	<SOUNDDATA
	lda	|17,y      
	sta	<SOUNDDATA
	lda	|18,y      
	sta	<SOUNDDATA
	lda	|19,y      
	sta	<SOUNDDATA
	lda	|20,y      
	sta	<SOUNDDATA
	lda	|21,y      
	sta	<SOUNDDATA
	lda	|22,y      
	sta	<SOUNDDATA
	lda	|23,y      
	sta	<SOUNDDATA
	lda	|24,y      
	sta	<SOUNDDATA
	lda	|25,y      
	sta	<SOUNDDATA
	lda	|26,y      
	sta	<SOUNDDATA
	lda	|27,y      
	sta	<SOUNDDATA
	lda	|28,y      
	sta	<SOUNDDATA
	lda	|29,y      
	sta	<SOUNDDATA
	lda	|30,y      
	sta	<SOUNDDATA
	lda	|31,y      
	sta	<SOUNDDATA
	lda	|32,y      
	sta	<SOUNDDATA
	lda	|33,y      
	sta	<SOUNDDATA
	lda	|34,y      
	sta	<SOUNDDATA
	lda	|35,y      
	sta	<SOUNDDATA
	lda	|36,y      
	sta	<SOUNDDATA
	lda	|37,y      
	sta	<SOUNDDATA
	lda	|38,y      
	sta	<SOUNDDATA
	lda	|39,y      
	sta	<SOUNDDATA
	lda	|40,y      
	sta	<SOUNDDATA
	lda	|41,y      
	sta	<SOUNDDATA
	lda	|42,y      
	sta	<SOUNDDATA
	lda	|43,y      
	sta	<SOUNDDATA
	lda	|44,y      
	sta	<SOUNDDATA
	lda	|45,y      
	sta	<SOUNDDATA
	lda	|46,y      
	sta	<SOUNDDATA
	lda	|47,y      
	sta	<SOUNDDATA
	lda	|48,y      
	sta	<SOUNDDATA
	lda	|49,y      
	sta	<SOUNDDATA
	lda	|50,y      
	sta	<SOUNDDATA
	lda	|51,y
	sta	<SOUNDDATA
	lda	|52,y      
	sta	<SOUNDDATA
	lda	|53,y      
	sta	<SOUNDDATA
	lda	|54,y      
	sta	<SOUNDDATA
	lda	|55,y      
	sta	<SOUNDDATA
	lda	|56,y      
	sta	<SOUNDDATA
	lda	|57,y      
	sta	<SOUNDDATA
	lda	|58,y      
	sta	<SOUNDDATA
	lda	|59,y      
	sta	<SOUNDDATA
	lda	|60,y      
	sta	<SOUNDDATA
	lda	|61,y      
	sta	<SOUNDDATA
	lda	|62,y      
	sta	<SOUNDDATA
	lda	|63,y      
	sta	<SOUNDDATA
	lda	|64,y      
	sta	<SOUNDDATA
	lda	|65,y      
	sta	<SOUNDDATA
	lda	|66,y      
	sta	<SOUNDDATA
	lda	|67,y      
	sta	<SOUNDDATA
	lda	|68,y      
	sta	<SOUNDDATA
	lda	|69,y      
	sta	<SOUNDDATA
	lda	|70,y      
	sta	<SOUNDDATA
	lda	|71,y      
	sta	<SOUNDDATA
	lda	|72,y      
	sta	<SOUNDDATA
	lda	|73,y      
	sta	<SOUNDDATA
	lda	|74,y      
	sta	<SOUNDDATA
	lda	|75,y      
	sta	<SOUNDDATA
	lda	|76,y      
	sta	<SOUNDDATA
	lda	|77,y      
	sta	<SOUNDDATA
	lda	|78,y      
	sta	<SOUNDDATA
	lda	|79,y      
	sta	<SOUNDDATA
	lda	|80,y      
	sta	<SOUNDDATA
	lda	|81,y      
	sta	<SOUNDDATA
	lda	|82,y      
	sta	<SOUNDDATA
	lda	|83,y      
	sta	<SOUNDDATA
	lda	|84,y      
	sta	<SOUNDDATA
	lda	|85,y      
	sta	<SOUNDDATA
	lda	|86,y      
	sta	<SOUNDDATA
	lda	|87,y      
	sta	<SOUNDDATA
	lda	|88,y      
	sta	<SOUNDDATA
	lda	|89,y      
	sta	<SOUNDDATA
	lda	|90,y      
	sta	<SOUNDDATA
	lda	|91,y      
	sta	<SOUNDDATA
	lda	|92,y      
	sta	<SOUNDDATA
	lda	|93,y      
	sta	<SOUNDDATA
	lda	|94,y      
	sta	<SOUNDDATA
	lda	|95,y      
	sta	<SOUNDDATA
	lda	|96,y      
	sta	<SOUNDDATA
	lda	|97,y      
	sta	<SOUNDDATA
	lda	|98,y      
	sta	<SOUNDDATA
	lda	|99,y      
	sta	<SOUNDDATA
	lda	|100,y
	sta	<SOUNDDATA
	lda	|101,y
	sta	<SOUNDDATA
	lda	|102,y      
	sta	<SOUNDDATA
	lda	|103,y      
	sta	<SOUNDDATA
	lda	|104,y      
	sta	<SOUNDDATA
	lda	|105,y      
	sta	<SOUNDDATA
	lda	|106,y      
	sta	<SOUNDDATA
	lda	|107,y      
	sta	<SOUNDDATA
	lda	|108,y      
	sta	<SOUNDDATA
	lda	|109,y      
	sta	<SOUNDDATA
	lda	|110,y      
	sta	<SOUNDDATA
	lda	|111,y      
	sta	<SOUNDDATA
	lda	|112,y      
	sta	<SOUNDDATA
	lda	|113,y      
	sta	<SOUNDDATA
	lda	|114,y      
	sta	<SOUNDDATA
	lda	|115,y      
	sta	<SOUNDDATA
	lda	|116,y      
	sta	<SOUNDDATA
	lda	|117,y      
	sta	<SOUNDDATA
	lda	|118,y      
	sta	<SOUNDDATA
	lda	|119,y      
	sta	<SOUNDDATA
	lda	|120,y      
	sta	<SOUNDDATA
	lda	|121,y      
	sta	<SOUNDDATA
	lda	|122,y      
	sta	<SOUNDDATA
	lda	|123,y      
	sta	<SOUNDDATA
	lda	|124,y      
	sta	<SOUNDDATA
	lda	|125,y      
	sta	<SOUNDDATA
	lda	|126,y      
	sta	<SOUNDDATA
	lda	|127,y      
	sta	<SOUNDDATA
	lda	|128,y      
	sta	<SOUNDDATA
	lda	|129,y      
	sta	<SOUNDDATA
	lda	|130,y      
	sta	<SOUNDDATA
	lda	|131,y      
	sta	<SOUNDDATA
	lda	|132,y      
	sta	<SOUNDDATA
	lda	|133,y      
	sta	<SOUNDDATA
	lda	|134,y      
	sta	<SOUNDDATA
	lda	|135,y      
	sta	<SOUNDDATA
	lda	|136,y      
	sta	<SOUNDDATA
	lda	|137,y      
	sta	<SOUNDDATA
	lda	|138,y      
	sta	<SOUNDDATA
	lda	|139,y      
	sta	<SOUNDDATA
	lda	|140,y      
	sta	<SOUNDDATA
	lda	|141,y      
	sta	<SOUNDDATA
	lda	|142,y      
	sta	<SOUNDDATA
	lda	|143,y      
	sta	<SOUNDDATA
	lda	|144,y      
	sta	<SOUNDDATA
	lda	|145,y      
	sta	<SOUNDDATA
	lda	|146,y      
	sta	<SOUNDDATA
	lda	|147,y      
	sta	<SOUNDDATA
	lda	|148,y      
	sta	<SOUNDDATA
	lda	|149,y      
	sta	<SOUNDDATA
	lda	|150,y      
	sta	<SOUNDDATA
	lda	|151,y
	sta	<SOUNDDATA
	lda	|152,y      
	sta	<SOUNDDATA
	lda	|153,y      
	sta	<SOUNDDATA
	lda	|154,y      
	sta	<SOUNDDATA
	lda	|155,y      
	sta	<SOUNDDATA
	lda	|156,y      
	sta	<SOUNDDATA
	lda	|157,y      
	sta	<SOUNDDATA
	lda	|158,y      
	sta	<SOUNDDATA
	lda	|159,y      
	sta	<SOUNDDATA
	lda	|160,y      
	sta	<SOUNDDATA
	lda	|161,y      
	sta	<SOUNDDATA
	lda	|162,y      
	sta	<SOUNDDATA
	lda	|163,y      
	sta	<SOUNDDATA
	lda	|164,y      
	sta	<SOUNDDATA
	lda	|165,y      
	sta	<SOUNDDATA
	lda	|166,y      
	sta	<SOUNDDATA
	lda	|167,y      
	sta	<SOUNDDATA
	lda	|168,y      
	sta	<SOUNDDATA
	lda	|169,y      
	sta	<SOUNDDATA
	lda	|170,y      
	sta	<SOUNDDATA
	lda	|171,y      
	sta	<SOUNDDATA
	lda	|172,y      
	sta	<SOUNDDATA
	lda	|173,y      
	sta	<SOUNDDATA
	lda	|174,y      
	sta	<SOUNDDATA
	lda	|175,y      
	sta	<SOUNDDATA
	lda	|176,y      
	sta	<SOUNDDATA
	lda	|177,y      
	sta	<SOUNDDATA
	lda	|178,y      
	sta	<SOUNDDATA
	lda	|179,y      
	sta	<SOUNDDATA
	lda	|180,y      
	sta	<SOUNDDATA
	lda	|181,y      
	sta	<SOUNDDATA
	lda	|182,y      
	sta	<SOUNDDATA
	lda	|183,y      
	sta	<SOUNDDATA
	lda	|184,y      
	sta	<SOUNDDATA
	lda	|185,y      
	sta	<SOUNDDATA
	lda	|186,y      
	sta	<SOUNDDATA
	lda	|187,y      
	sta	<SOUNDDATA
	lda	|188,y      
	sta	<SOUNDDATA
	lda	|189,y      
	sta	<SOUNDDATA
	lda	|190,y      
	sta	<SOUNDDATA
	lda	|191,y      
	sta	<SOUNDDATA
	lda	|192,y      
	sta	<SOUNDDATA
	lda	|193,y      
	sta	<SOUNDDATA
	lda	|194,y      
	sta	<SOUNDDATA
	lda	|195,y      
	sta	<SOUNDDATA
	lda	|196,y      
	sta	<SOUNDDATA
	lda	|197,y      
	sta	<SOUNDDATA
	lda	|198,y      
	sta	<SOUNDDATA
	lda	|199,y      
	sta	<SOUNDDATA
	lda	|200,y
	sta	<SOUNDDATA
	lda	|201,y
	sta	<SOUNDDATA
	lda	|202,y      
	sta	<SOUNDDATA
	lda	|203,y      
	sta	<SOUNDDATA
	lda	|204,y      
	sta	<SOUNDDATA
	lda	|205,y      
	sta	<SOUNDDATA
	lda	|206,y      
	sta	<SOUNDDATA
	lda	|207,y      
	sta	<SOUNDDATA
	lda	|208,y      
	sta	<SOUNDDATA
	lda	|209,y      
	sta	<SOUNDDATA
	lda	|210,y      
	sta	<SOUNDDATA
	lda	|211,y      
	sta	<SOUNDDATA
	lda	|212,y      
	sta	<SOUNDDATA
	lda	|213,y      
	sta	<SOUNDDATA
	lda	|214,y      
	sta	<SOUNDDATA
	lda	|215,y      
	sta	<SOUNDDATA
	lda	|216,y      
	sta	<SOUNDDATA
	lda	|217,y      
	sta	<SOUNDDATA
	lda	|218,y      
	sta	<SOUNDDATA
	lda	|219,y      
	sta	<SOUNDDATA
	lda	|220,y      
	sta	<SOUNDDATA
	lda	|221,y      
	sta	<SOUNDDATA
	lda	|222,y      
	sta	<SOUNDDATA
	lda	|223,y      
	sta	<SOUNDDATA
	lda	|224,y      
	sta	<SOUNDDATA
	lda	|225,y      
	sta	<SOUNDDATA
	lda	|226,y      
	sta	<SOUNDDATA
	lda	|227,y      
	sta	<SOUNDDATA
	lda	|228,y      
	sta	<SOUNDDATA
	lda	|229,y      
	sta	<SOUNDDATA
	lda	|230,y      
	sta	<SOUNDDATA
	lda	|231,y      
	sta	<SOUNDDATA
	lda	|232,y      
	sta	<SOUNDDATA
	lda	|233,y      
	sta	<SOUNDDATA
	lda	|234,y      
	sta	<SOUNDDATA
	lda	|235,y      
	sta	<SOUNDDATA
	lda	|236,y      
	sta	<SOUNDDATA
	lda	|237,y      
	sta	<SOUNDDATA
	lda	|238,y      
	sta	<SOUNDDATA
	lda	|239,y      
	sta	<SOUNDDATA
	lda	|240,y      
	sta	<SOUNDDATA
	lda	|241,y      
	sta	<SOUNDDATA
	lda	|242,y      
	sta	<SOUNDDATA
	lda	|243,y      
	sta	<SOUNDDATA
	lda	|244,y      
	sta	<SOUNDDATA
	lda	|245,y      
	sta	<SOUNDDATA
	lda	|246,y      
	sta	<SOUNDDATA
	lda	|247,y      
	sta	<SOUNDDATA
	lda	|248,y      
	sta	<SOUNDDATA
	lda	|249,y      
	sta	<SOUNDDATA
	lda	|250,y      
	sta	<SOUNDDATA
	lda	|251,y
	sta	<SOUNDDATA
	lda	|252,y      
	sta	<SOUNDDATA
	lda	|253,y      
	sta	<SOUNDDATA
	lda	|254,y      
	sta	<SOUNDDATA
	lda	|255,y      
	sta	<SOUNDDATA

	jmp	endslam
        
	END

DOCslamodd	START

	using	Tables

	longa	off
	longi	on

	lda	|0,y
	sta	<SOUNDDATA
	lda	|1,y
	sta	<SOUNDDATA
	lda	|2,y      
	sta	<SOUNDDATA
	lda	|3,y      
	sta	<SOUNDDATA
	lda	|4,y      
	sta	<SOUNDDATA
	lda	|5,y      
	sta	<SOUNDDATA
	lda	|6,y      
	sta	<SOUNDDATA
	lda	|7,y      
	sta	<SOUNDDATA
	lda	|8,y      
	sta	<SOUNDDATA
	lda	|9,y      
	sta	<SOUNDDATA
	lda	|10,y      
	sta	<SOUNDDATA
	lda	|11,y      
	sta	<SOUNDDATA
	lda	|12,y      
	sta	<SOUNDDATA
	lda	|13,y      
	sta	<SOUNDDATA
	lda	|14,y      
	sta	<SOUNDDATA
	lda	|15,y      
	sta	<SOUNDDATA
	lda	|16,y      
	sta	<SOUNDDATA
	lda	|17,y      
	sta	<SOUNDDATA
	lda	|18,y      
	sta	<SOUNDDATA
	lda	|19,y      
	sta	<SOUNDDATA
	lda	|20,y      
	sta	<SOUNDDATA
	lda	|21,y      
	sta	<SOUNDDATA
	lda	|22,y      
	sta	<SOUNDDATA
	lda	|23,y      
	sta	<SOUNDDATA
	lda	|24,y      
	sta	<SOUNDDATA
	lda	|25,y      
	sta	<SOUNDDATA
	lda	|26,y      
	sta	<SOUNDDATA
	lda	|27,y      
	sta	<SOUNDDATA
	lda	|28,y      
	sta	<SOUNDDATA
	lda	|29,y      
	sta	<SOUNDDATA
	lda	|30,y      
	sta	<SOUNDDATA
	lda	|31,y      
	sta	<SOUNDDATA
	lda	|32,y      
	sta	<SOUNDDATA
	lda	|33,y      
	sta	<SOUNDDATA
	lda	|34,y      
	sta	<SOUNDDATA
	lda	|35,y      
	sta	<SOUNDDATA
	lda	|36,y      
	sta	<SOUNDDATA
	lda	|37,y      
	sta	<SOUNDDATA
	lda	|38,y      
	sta	<SOUNDDATA
	lda	|39,y      
	sta	<SOUNDDATA
	lda	|40,y      
	sta	<SOUNDDATA
	lda	|41,y      
	sta	<SOUNDDATA
	lda	|42,y      
	sta	<SOUNDDATA
	lda	|43,y      
	sta	<SOUNDDATA
	lda	|44,y      
	sta	<SOUNDDATA
	lda	|45,y      
	sta	<SOUNDDATA
	lda	|46,y      
	sta	<SOUNDDATA
	lda	|47,y      
	sta	<SOUNDDATA
	lda	|48,y      
	sta	<SOUNDDATA
	lda	|49,y      
	sta	<SOUNDDATA
	lda	|50,y      
	sta	<SOUNDDATA
	lda	|51,y
	sta	<SOUNDDATA
	lda	|52,y      
	sta	<SOUNDDATA
	lda	|53,y      
	sta	<SOUNDDATA
	lda	|54,y      
	sta	<SOUNDDATA
	lda	|55,y      
	sta	<SOUNDDATA
	lda	|56,y      
	sta	<SOUNDDATA
	lda	|57,y      
	sta	<SOUNDDATA
	lda	|58,y      
	sta	<SOUNDDATA
	lda	|59,y      
	sta	<SOUNDDATA
	lda	|60,y      
	sta	<SOUNDDATA
	lda	|61,y      
	sta	<SOUNDDATA
	lda	|62,y      
	sta	<SOUNDDATA
	lda	|63,y      
	sta	<SOUNDDATA
	lda	|64,y      
	sta	<SOUNDDATA
	lda	|65,y      
	sta	<SOUNDDATA
	lda	|66,y      
	sta	<SOUNDDATA
	lda	|67,y      
	sta	<SOUNDDATA
	lda	|68,y      
	sta	<SOUNDDATA
	lda	|69,y      
	sta	<SOUNDDATA
	lda	|70,y      
	sta	<SOUNDDATA
	lda	|71,y      
	sta	<SOUNDDATA
	lda	|72,y      
	sta	<SOUNDDATA
	lda	|73,y      
	sta	<SOUNDDATA
	lda	|74,y      
	sta	<SOUNDDATA
	lda	|75,y      
	sta	<SOUNDDATA
	lda	|76,y      
	sta	<SOUNDDATA
	lda	|77,y      
	sta	<SOUNDDATA
	lda	|78,y      
	sta	<SOUNDDATA
	lda	|79,y      
	sta	<SOUNDDATA
	lda	|80,y      
	sta	<SOUNDDATA
	lda	|81,y      
	sta	<SOUNDDATA
	lda	|82,y      
	sta	<SOUNDDATA
	lda	|83,y      
	sta	<SOUNDDATA
	lda	|84,y      
	sta	<SOUNDDATA
	lda	|85,y      
	sta	<SOUNDDATA
	lda	|86,y      
	sta	<SOUNDDATA
	lda	|87,y      
	sta	<SOUNDDATA
	lda	|88,y      
	sta	<SOUNDDATA
	lda	|89,y      
	sta	<SOUNDDATA
	lda	|90,y      
	sta	<SOUNDDATA
	lda	|91,y      
	sta	<SOUNDDATA
	lda	|92,y      
	sta	<SOUNDDATA
	lda	|93,y      
	sta	<SOUNDDATA
	lda	|94,y      
	sta	<SOUNDDATA
	lda	|95,y      
	sta	<SOUNDDATA
	lda	|96,y      
	sta	<SOUNDDATA
	lda	|97,y      
	sta	<SOUNDDATA
	lda	|98,y      
	sta	<SOUNDDATA
	lda	|99,y      
	sta	<SOUNDDATA
	lda	|100,y
	sta	<SOUNDDATA
	lda	|101,y
	sta	<SOUNDDATA
	lda	|102,y      
	sta	<SOUNDDATA
	lda	|103,y      
	sta	<SOUNDDATA
	lda	|104,y      
	sta	<SOUNDDATA
	lda	|105,y      
	sta	<SOUNDDATA
	lda	|106,y      
	sta	<SOUNDDATA
	lda	|107,y      
	sta	<SOUNDDATA
	lda	|108,y      
	sta	<SOUNDDATA
	lda	|109,y      
	sta	<SOUNDDATA
	lda	|110,y      
	sta	<SOUNDDATA
	lda	|111,y      
	sta	<SOUNDDATA
	lda	|112,y      
	sta	<SOUNDDATA
	lda	|113,y      
	sta	<SOUNDDATA
	lda	|114,y      
	sta	<SOUNDDATA
	lda	|115,y      
	sta	<SOUNDDATA
	lda	|116,y      
	sta	<SOUNDDATA
	lda	|117,y      
	sta	<SOUNDDATA
	lda	|118,y      
	sta	<SOUNDDATA
	lda	|119,y      
	sta	<SOUNDDATA
	lda	|120,y      
	sta	<SOUNDDATA
	lda	|121,y      
	sta	<SOUNDDATA
	lda	|122,y      
	sta	<SOUNDDATA
	lda	|123,y      
	sta	<SOUNDDATA
	lda	|124,y      
	sta	<SOUNDDATA
	lda	|125,y      
	sta	<SOUNDDATA
	lda	|126,y      
	sta	<SOUNDDATA
	lda	|127,y      
	sta	<SOUNDDATA
	lda	|128,y      
	sta	<SOUNDDATA
	lda	|129,y      
	sta	<SOUNDDATA
	lda	|130,y      
	sta	<SOUNDDATA
	lda	|131,y      
	sta	<SOUNDDATA
	lda	|132,y      
	sta	<SOUNDDATA
	lda	|133,y      
	sta	<SOUNDDATA
	lda	|134,y      
	sta	<SOUNDDATA
	lda	|135,y      
	sta	<SOUNDDATA
	lda	|136,y      
	sta	<SOUNDDATA
	lda	|137,y      
	sta	<SOUNDDATA
	lda	|138,y      
	sta	<SOUNDDATA
	lda	|139,y      
	sta	<SOUNDDATA
	lda	|140,y      
	sta	<SOUNDDATA
	lda	|141,y      
	sta	<SOUNDDATA
	lda	|142,y      
	sta	<SOUNDDATA
	lda	|143,y      
	sta	<SOUNDDATA
	lda	|144,y      
	sta	<SOUNDDATA
	lda	|145,y      
	sta	<SOUNDDATA
	lda	|146,y      
	sta	<SOUNDDATA
	lda	|147,y      
	sta	<SOUNDDATA
	lda	|148,y      
	sta	<SOUNDDATA
	lda	|149,y      
	sta	<SOUNDDATA
	lda	|150,y      
	sta	<SOUNDDATA
	lda	|151,y
	sta	<SOUNDDATA
	lda	|152,y      
	sta	<SOUNDDATA
	lda	|153,y      
	sta	<SOUNDDATA
	lda	|154,y      
	sta	<SOUNDDATA
	lda	|155,y      
	sta	<SOUNDDATA
	lda	|156,y      
	sta	<SOUNDDATA
	lda	|157,y      
	sta	<SOUNDDATA
	lda	|158,y      
	sta	<SOUNDDATA
	lda	|159,y      
	sta	<SOUNDDATA
	lda	|160,y      
	sta	<SOUNDDATA
	lda	|161,y      
	sta	<SOUNDDATA
	lda	|162,y      
	sta	<SOUNDDATA
	lda	|163,y      
	sta	<SOUNDDATA
	lda	|164,y      
	sta	<SOUNDDATA
	lda	|165,y      
	sta	<SOUNDDATA
	lda	|166,y      
	sta	<SOUNDDATA
	lda	|167,y      
	sta	<SOUNDDATA
	lda	|168,y      
	sta	<SOUNDDATA
	lda	|169,y      
	sta	<SOUNDDATA
	lda	|170,y      
	sta	<SOUNDDATA
	lda	|171,y      
	sta	<SOUNDDATA
	lda	|172,y      
	sta	<SOUNDDATA
	lda	|173,y      
	sta	<SOUNDDATA
	lda	|174,y      
	sta	<SOUNDDATA
	lda	|175,y      
	sta	<SOUNDDATA
	lda	|176,y      
	sta	<SOUNDDATA
	lda	|177,y      
	sta	<SOUNDDATA
	lda	|178,y      
	sta	<SOUNDDATA
	lda	|179,y      
	sta	<SOUNDDATA
	lda	|180,y      
	sta	<SOUNDDATA
	lda	|181,y      
	sta	<SOUNDDATA
	lda	|182,y      
	sta	<SOUNDDATA
	lda	|183,y      
	sta	<SOUNDDATA
	lda	|184,y      
	sta	<SOUNDDATA
	lda	|185,y      
	sta	<SOUNDDATA
	lda	|186,y      
	sta	<SOUNDDATA
	lda	|187,y      
	sta	<SOUNDDATA
	lda	|188,y      
	sta	<SOUNDDATA
	lda	|189,y      
	sta	<SOUNDDATA
	lda	|190,y      
	sta	<SOUNDDATA
	lda	|191,y      
	sta	<SOUNDDATA
	lda	|192,y      
	sta	<SOUNDDATA
	lda	|193,y      
	sta	<SOUNDDATA
	lda	|194,y      
	sta	<SOUNDDATA
	lda	|195,y      
	sta	<SOUNDDATA
	lda	|196,y      
	sta	<SOUNDDATA
	lda	|197,y      
	sta	<SOUNDDATA
	lda	|198,y      
	sta	<SOUNDDATA
	lda	|199,y      
	sta	<SOUNDDATA
	lda	|200,y
	sta	<SOUNDDATA
	lda	|201,y
	sta	<SOUNDDATA
	lda	|202,y      
	sta	<SOUNDDATA
	lda	|203,y      
	sta	<SOUNDDATA
	lda	|204,y      
	sta	<SOUNDDATA
	lda	|205,y      
	sta	<SOUNDDATA
	lda	|206,y      
	sta	<SOUNDDATA
	lda	|207,y      
	sta	<SOUNDDATA
	lda	|208,y      
	sta	<SOUNDDATA
	lda	|209,y      
	sta	<SOUNDDATA
	lda	|210,y      
	sta	<SOUNDDATA
	lda	|211,y      
	sta	<SOUNDDATA
	lda	|212,y      
	sta	<SOUNDDATA
	lda	|213,y      
	sta	<SOUNDDATA
	lda	|214,y      
	sta	<SOUNDDATA
	lda	|215,y      
	sta	<SOUNDDATA
	lda	|216,y      
	sta	<SOUNDDATA
	lda	|217,y      
	sta	<SOUNDDATA
	lda	|218,y      
	sta	<SOUNDDATA
	lda	|219,y      
	sta	<SOUNDDATA
	lda	|220,y      
	sta	<SOUNDDATA
	lda	|221,y      
	sta	<SOUNDDATA
	lda	|222,y      
	sta	<SOUNDDATA
	lda	|223,y      
	sta	<SOUNDDATA
	lda	|224,y      
	sta	<SOUNDDATA
	lda	|225,y      
	sta	<SOUNDDATA
	lda	|226,y      
	sta	<SOUNDDATA
	lda	|227,y      
	sta	<SOUNDDATA
	lda	|228,y      
	sta	<SOUNDDATA
	lda	|229,y      
	sta	<SOUNDDATA
	lda	|230,y      
	sta	<SOUNDDATA
	lda	|231,y      
	sta	<SOUNDDATA
	lda	|232,y      
	sta	<SOUNDDATA
	lda	|233,y      
	sta	<SOUNDDATA
	lda	|234,y      
	sta	<SOUNDDATA
	lda	|235,y      
	sta	<SOUNDDATA
	lda	|236,y      
	sta	<SOUNDDATA
	lda	|237,y      
	sta	<SOUNDDATA
	lda	|238,y      
	sta	<SOUNDDATA
	lda	|239,y      
	sta	<SOUNDDATA
	lda	|240,y      
	sta	<SOUNDDATA
	lda	|241,y      
	sta	<SOUNDDATA
	lda	|242,y      
	sta	<SOUNDDATA
	lda	|243,y      
	sta	<SOUNDDATA
	lda	|244,y      
	sta	<SOUNDDATA
	lda	|245,y      
	sta	<SOUNDDATA
	lda	|246,y      
	sta	<SOUNDDATA
	lda	|247,y      
	sta	<SOUNDDATA
	lda	|248,y      
	sta	<SOUNDDATA
	lda	|249,y
	tax   
	lda	>wavtab0e,x
	sta	<SOUNDDATA
	lda	|250,y
	tax    
	lda	>wavtab0c,x
	sta	<SOUNDDATA
	lda	|251,y
	tax
	lda	>wavtab0a,x
	sta	<SOUNDDATA
	lda	|252,y
	tax  
	lda	>wavtab08,x
	sta	<SOUNDDATA
	lda	|253,y
	tax   
	lda	>wavtab06,x
	sta	<SOUNDDATA
	lda	|254,y
	tax   
	lda	>wavtab04,x
	sta	<SOUNDDATA
	lda	|255,y
	tax    
	lda	>wavtab02,x
	sta	<SOUNDDATA

	jmp	endslam
        
	END

**************************************************************************
*
* Sound Data
*
**************************************************************************

SoundDat	DATA

sndctl	ds	2
sndctlinc	ds	2
sndctlram	ds	2
sndctlraminc	ds	2

WaveDoc	ds	8*4
WaveRes	ds	8*4
WavePtr	ds	8*4
WaveLen	ds	8*4
NextWavePtr	ds	8*4
NextWaveLen	ds	8*4
WaveOffset	ds	8*4
WaveDOCPtrL	ds	8*4
WaveDOCPtrH	ds	8*4
WaveChannel	dc	i4'%10000,%00000,%00000,%10000'
	dc	i4'%10000,%00000,%00000,%10000'
DOCAdr	dc	i2'$0100,$0200'
	dc	i2'$0300,$0400'
	dc	i2'$0500,$0600'
	dc	i2'$0700,$0800'
ClockAdr	dc	i2'0'

tracknum	ds	2      
trackidx	ds	2
voiceidx	ds	2
channel	ds	2

OldIRQ	ds	4

	END
