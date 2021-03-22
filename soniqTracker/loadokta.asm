	datachk off

*
* Load an OKTALYZER formatted mod
*

;	mcopy	m/loadokta.mac

LoadOKTA	START	sequencer

	using	GSOSData

	ldx	#^loadstr
	lda	#loadstr
	jsl	StartThermo
	lda	#8
	lda	#0
	jsl	ShowThermo

; read the channel modes

	lda	#CMODstr
	ldx	#^CMODstr
	jsl	findblock
	bcs	error
	cmp	#8
	bne	abort
	jsl	readbuf
	lda	ReadCount
	ldx	ReadCount+2
	jsl	showthermo

; read the sample data

	lda	#SAMPstr
	ldx	#^SAMPstr
	jsl	findblock
	bcs	error
	cmp	#36*32
	bne	abort
	jsl	readbuf
	lda	ReadCount
	ldx	ReadCount+2
	jsl	showthermo

	clc
error	jmp	LoadExit
abort	lda	#$BADD
	sec
	jmp	LoadExit

loadstr	dc	c'Importing Oktalyzer Module...',h'00'

CMODstr	dc	c'CMOD'
SAMPstr	dc	c'SAMP'
SBODstr	dc	c'SBOD'

	END

*
* Search for a block in the file
*

findblock	PRIVATE sequencer

	using	GSOSData
	using	SongData
	using	OKTAData

	sta	0
	stx	2

	lda	#8
	sta	>pos
	lda	#0
	sta	>pos+2

loop	lda	>pos+2
	tax
	lda	>pos
	jsl	seek
	bcs	err

	lda	#8
	jsl	readbuf
	bcs	err

	ldy	#2
	lda	buffer
	cmp	[0]
	bne	next
	lda	buffer+2
	cmp	[0],y
	bne	next
	
	lda	#8
	ldx	#0
	jsl	showthermo

	lda	buffer+4
	xba
	tax
	lda	buffer+6
	xba
	clc
err	rtl

next	lda	>pos
	clc
	adc	#8
	sta	>pos
	lda	>pos+2
	adc	#0
	sta	>pos+2

	lda	buffer+6
	xba
	clc
	adc	>pos
	sta	>pos
	lda	buffer+4
	xba
	adc	>pos+2
	sta	>pos+2

	bra	loop

	END

OKTAData	DATA

pos	ds	4	

	END
