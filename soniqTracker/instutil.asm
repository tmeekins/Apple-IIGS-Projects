	mcopy	m/instutil.mac

MasterVolume	gequ	$E100CA
SOUNDCTL	gequ	$E1C03C
SOUNDDATA	gequ	$E1C03D
SOUNDADRL	gequ	$E1C03E
SOUNDADRH	gequ	$E1C03F

*
* Sort instruments and put into DOC Ram
*

DocIt	START	instutil

;	kind	$8000

	using	SongData
	using	Tables
	using	SoundDat

count	equ	0
numinst	equ	2
v	equ	4
v2	equ	6
docptr	equ	8
docsize	equ	10
doclen	equ	12
index	equ	14
ptr	equ	16
looped	equ	20
newsize	equ	22
roundlen	equ	24

	phb
	phk
	plb

	stz	docsize
	stz	numinst
	ld2	1,count
;
; build a table of instruments for sorting
;
;	lda	count
loop	asl	a
	asl	a
	tax
;	lda	#0     
;	sta	>VoiceDocTab,x
	lda	>VoicePtrTab,x
	ora	>VoicePtrTab+2,x
	beq	next
	lda	numinst
	asl	a
	tay
	lda	count
	sta	instnumtbl,y
	lda	>VoiceLenTab+2,x
	beq	a1
               lda	#$FFFF
	bra	a2
a1	lda	>VoiceLenTab,x
a2	sta	instsizetbl,y
	inc	numinst
;	lda	#0
;	sta	>VLoopDocTab,x
	lda	>VLoopPtrTab,x
	ora	>VLoopPtrTab+2,x
	beq	next
	lda	numinst
	asl	a
	tay
	lda	count
	ora	#$8000
	sta	instnumtbl,y
	lda	>VLoopLenTab+2,x
	beq	a3
               lda	#$FFFF
	bra	a4
a3	lda	>VLoopLenTab,x
a4	sta	instsizetbl,y
	inc	numinst
next	inc	count
	lda	count
	cmp	>nvoices
	bcc	loop
	beq	loop
;
; do a quick insertion sort
;
	lda	numinst
	dec	a
	beq	donesort
	bmi	donesort
	ldx	#2
sort1	lda	instsizetbl,x
	sta	v
	lda	instnumtbl,x
	sta	v2
	txy
sort2	lda	v
	cmp	instsizetbl-2,y
	bcs	sort3
	lda	instsizetbl-2,y
	sta	instsizetbl,y
	lda	instnumtbl-2,y
	sta	instnumtbl,y
               dey
	dey
	bne	sort2           
          	lda	v
sort3	sta   instsizetbl,y
	lda	v2
	sta	instnumtbl,y
	inx
	inx
	lda	numinst
	asl	a
	sta	v
	cpx	v
	bcc	sort1
;
; Scan through each instrument, smallest to largest, accumulating their sizes
; rounded upwards to the nearest block (256 byte boundaries). Stop when
; accumulated up to 64k or a 32k instrument has been reached.
;
donesort	ldy	#0
	ldx	#0
sumloop	lda	instsizetbl+1,x
	and	#$FF
	inc	a
	cmp	#128	;32k
	bcs	donesum
	adc	docsize
	cmp	#256	;64k
	bcs	donesum
	sta	docsize
	inx
	inx
	iny
	cpy	numinst
	bcc	sumloop
donesum	sty	newsize

docloop	anop
;
; initialize the doc ram table to be empty
;	
	ldy	#256-2
	lda	#0
zapmap         sta	DOCMap,y
	dey
	dey
	bpl	zapmap
;
; initialize all instruments to not be in DOC Ram
;
	lda	#1	
	sta	count
	ldx	#0
initdocptr	lda	#0
	sta	>VoiceDocTab,x
	sta	>VoiceDocTab+2,x
	sta	>VLoopDocTab,x
	sta	>VLoopDocTab+2,x
	inx
	inx
	inx
	inx
	inc	count
	lda	count
;	cmp	>nvoices
	cmp	#31
	bcc	initdocptr
	beq	initdocptr
;
; loop from longest instrument to shortest and attempt to place each in DOC Ram
;
	lda	newsize    
	jeq	done
	dec	a
	sta	index

tryinst	asl	a
	tay	
;
; before we get wrapped up..see if it's a looped identical to the previous
;
	beq	fla01
               lda	instnumtbl,y
	bmi	fla01
	asl	a
	asl	a
	tax
	lda	>VoicePtrTab,x
	cmp	>VLoopPtrTab,x
	bne	fla01
	lda	>VoicePtrTab+2,x
	cmp	>VLoopPtrTab+2,x
	bne	fla01
	lda	>VLoopDocTab,x
	sta	>VoiceDocTab,x
	lda	>VLoopDocTab+2,x
	sta	>VoiceDocTab+2,x
	lda	>VLoopResTab,x
	sta	>VoiceResTab,x
	jmp	DocInPlace
;
; let's calculate the doclength required
;
fla01	lda	#256
	sta	doclen
	stz	docsize	
fla01a         lda	instsizetbl,y
	cmp	doclen
	bcc	fla02
	asl	doclen
	jcs	done
	inc	docsize
	bra	fla01a
fla02	adc	#$0100
	and	#$FF00
	sta	roundlen
	sec
	sbc	instsizetbl,y
	cmp	#8
	bcs	fla03
	lda	roundlen
	adc	#$0100
	sta	roundlen
fla03	anop
;
; now lets find an empty entry in the doc map
;
	stz	docptr
findadr	lda	docptr+1
	and	#$FF
	tay
	lda	roundlen+1
	and	#$FF
	tax
chkem	lda	DocMap,y
	and	#$FF
	bne	nextadr
	iny
	dex
	bne	chkem
	cpy	#256
	bcs   dead
	lda	docptr+1
	and	#$FF
	tay
	lda	roundlen+1
	and	#$FF
	tax
setem	lda	DocMap,y
	ora	#1
	sta	DocMap,y
	iny
	dex
	bne	setem
	bra	foundit

nextadr	clc
	lda	docptr
	adc	DocLen
	bcc	oknext
dead	dec	newsize	
	jmp   docloop
oknext	sta	docptr
	bra	findadr

foundit	lda	index	
	asl	a
	tay

	lda	instnumtbl,y
	jmi	getloopadr
	asl	a
	asl	a
	tax
	lda	>VoicePtrTab,x
	sta	ptr
	lda	>VoicePtrTab+2,x
	sta	ptr+2
	lda	docptr
	sta	>VoiceDocTab,x
	lda	#1
	sta	>VoiceDocTab+2,x
	lda	docsize
	asl	a
	asl	a
	asl	a
	ora	docsize
	sta	>VoiceResTab,x

	short	a
docwait0	lda	>SOUNDCTL
	bmi	docwait0
	lda	#$60	;auto-inc, sound ram
	ora	>MasterVolume
	sta	>SOUNDCTL
	long	a

	lda	docptr	;point to DOC ram
	sta	>SOUNDADRL

	lda	>VLoopPtrTab,x
	jne	stddoc
	lda	>VLoopPtrTab+2,x
	jne	stddoc

	lda	instsizetbl,y
	sec
	sbc	#7+4
	pha

	ldy	#0
	short	ai
	lda	[ptr],y
	tax
	lda	>wavtab02,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab04,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab08,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab0c,x
	sta	>SOUNDDATA
	iny		

	long	i
	plx
	dex
DOCloop2	lda	[ptr],y
	sta	>SOUNDDATA
	iny
	dex
	bpl	DOCloop2
	long	a
	clc
	phy
	tya
	adc	ptr
	sta	ptr
	lda	ptr+2
	adc	#0
	sta	ptr+2

	short	ai
	ldy	#0
	lda	[ptr],y
	tax
	lda	>wavtab0e,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab0c,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab0a,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab08,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab06,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab04,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab02,x
	sta	>SOUNDDATA

	long	ai
	pla
	clc
	adc	#7
	tay
	short	a

	jmp	DocZap

	longa	on

getloopadr	and	#$7FFF
	asl	a
	asl	a
	tax
	lda	>VLoopPtrTab,x
	sta	ptr
	lda	>VLoopPtrTab+2,x
	sta	ptr+2
	lda	docptr
	sta	>VLoopDocTab,x
	lda	#1
	sta	>VLoopDocTab+2,x
	lda	docsize	
	asl	a
	asl	a
	asl	a
	ora	docsize
	sta	>VLoopResTab,x

	short	a
docwait1	lda	>SOUNDCTL
	bmi	docwait1
	lda	#$60	;auto-inc, sound ram
	ora	>MasterVolume
	sta	>SOUNDCTL
	long	a

	lda	docptr	;point to DOC ram
	sta	>SOUNDADRL

stddoc	lda	instsizetbl,y
	sec
	sbc	#4*2
	pha

	ldy	#0
	short	ai
	lda	[ptr],y
	tax
	lda	>wavtab02,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab04,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab08,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab0c,x
	sta	>SOUNDDATA
	iny		

	long	i
	plx
	dex
DOCloop1	lda	[ptr],y
	sta	>SOUNDDATA
	iny
	dex
	bpl	DOCloop1
	long	a
	clc
	phy
	tya
	adc	ptr
	sta	ptr
	lda	ptr+2
	adc	#0
	sta	ptr+2

	short	ai
	ldy	#0
	lda	[ptr],y
	tax
	lda	>wavtab0c,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab08,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab04,x
	sta	>SOUNDDATA
	iny		
	lda	[ptr],y
	tax
	lda	>wavtab02,x
	sta	>SOUNDDATA

	long	ai
	pla
	clc
	adc	#4
	tay
	short	a

DOCZap	lda	#0
DOCzap2	cpy	roundlen
	bcs	Docinplace
	sta	>SOUNDDATA	
	iny
	bra	DOCzap2

Docinplace     long	a
	dec   index
	lda	index
	bmi	docdone
	jmp   tryinst
;
; All done putting instruments in Doc Ram, now try to make a 256 byte block for
; the clock and see if we need to allocate DOC ram for copy ahead buffers.
;
docdone	anop
	ldy	#0
hole1	lda	DocMap,y
	bit	#1
	beq	hole1a
	iny
	cpy	#256
	bcc	hole1
	dec	newsize	
	jmp   docloop
hole1a	ora	#1
	sta	DocMap,y
	tya
	xba	
	sta	>ClockAdr
;
; do we need copy ahead buffers??
;
	lda	numinst
	cmp	newsize
	beq	done
;
; we need buffers, go allocate them all.
;
	ldx	#0
allocbufs	lda	DocMap,y
	bit	#1
	beq	hole2a
	iny
	cpy	#256
	bcc	allocbufs
	dec	newsize	
	jmp   docloop
hole2a	ora	#1
	sta	DocMap,y
	tya
	xba	
	sta	>DocAdr,x
	inx
	inx
	cpx	#8*2
	bcc	allocbufs
;
; we're done!! whew!
;
done	plb
	rtl

instnumtbl	ds	32*2*2
instsizetbl	ds	32*2*2
DOCMap	ds	256

	END

*
* adjust the wave for zero-crossings at the end.
*
* assumes MAIN data bank
*

	datachk off

WaveIt	START	instutil

;	kind	$8000

	using	SongData
	using GSOSData

count	equ	0
loopptr	equ	2
crosspoint	equ	6
hand	equ	8
index	equ	12
ptr	equ	14
hi	equ	18
lo	equ	20

	ld2	1,count

loop	asl	a
	asl	a
	sta	index
	tax
	lda	VLoopPtrTab,x
	ora	VLoopPtrTab+2,x
	jeq	next

               lda	VLoopPtrTab,x
	sta	loopptr
               lda	VLoopPtrTab+2,x
	sta	loopptr+2

	lda	#$81
	sta	hi
	lda	#$80
	sta	lo
crossloop	ldy	#0
downloop	lda	[loopptr],y
	and	#$FF
	cmp	hi
	bcs	nextcross
	cmp	lo
	bcs	foundcross
nextcross	iny
	bne	downloop
	bra	crossretry

foundcross	tya
	cmp	VloopLenTab,x
	bcc	foundok

crossretry	inc	hi
	dec	lo
	bra	crossloop

foundok	cmp	#0
	jeq	next
	sta	crosspoint

	lda	VloopPtrTab,x
	cmp	VoicePtrtab,x
	bne	fixvoice
	lda	VloopPtrTab+2,x
	cmp	VoicePtrtab+2,x
	jeq	fixloop

fixvoice	lda	VoicePtrTab,x
	ora	VoicePtrTab+2,x
	jeq	next
	lda	VoicePtrTab,x
	tay
	lda	VoicePtrTab+2,x
	FindHandle @ay,hand
	ldy	#4
	lda	[hand],y
	and	#$7FFF
	sta	[hand],y
	ldx	index
	lda	VoiceLenTab,x
	clc
	adc	crosspoint
	ldx	#0
	SetHandleSize (@xa,hand)
	ldy	#4
	lda	[hand],y
	ora	#$8000
	sta	[hand],y
	ldy	#2
	ldx	index
	lda	[hand]
	sta	VoicePtrTab,x
	clc
	adc	VoiceLenTab,x
	sta	ptr
	lda	[hand],y
	sta	VoicePtrTab+2,x
	adc	VoiceLenTab+2,x
	sta	ptr+2
	lda	VoiceLenTab,x
	clc
	adc	crosspoint
	sta	VoiceLenTab,x
	short	a
	ldy	crosspoint
	dey
	beq	cv00
copyvoice	lda	[loopptr],y
	sta	[ptr],y
	dey
	bne	copyvoice
cv00	lda	[loopptr]
	sta	[ptr]
	long	a
                       
fixloop	lda	VLoopLenTab,x
	tay
	lda	VLoopLenTab+2,x
	NewHandle (@ay,SongID,#$C018,#0),hand
	lda	[hand]
	sta	ptr
	ldy	#2
	lda	[hand],y
	sta	ptr+2
	ldx	index
	ldy	VloopLenTab,x
	short	a
	dey
	beq	copy1a
copy1          lda	[loopptr],y
	sta	[ptr],y
               dey
	bne	copy1
copy1a	lda	[loopptr]
	sta	[ptr]
	long	a	
	lda	VloopLenTab,x
	sec
	sbc	crosspoint
	tay
	phy
	clc
	lda	ptr
	adc	crosspoint
               sta	ptr
	lda	ptr+2
	adc	#0
	sta	ptr+2
	short	a
	dey
	beq	copy2a
copy2	lda	[ptr],y
	sta	[loopptr],y
	dey
	bne	copy2
copy2a	lda	[ptr]
	sta	[loopptr]
	long	a
	clc
	pla
	adc	loopptr
	sta	loopptr
	lda	loopptr+2
	adc	#0
	sta	loopptr+2
	lda	[hand]
	sta	ptr
	ldy	#2
	lda	[hand],y
	sta	ptr+2
	ldy	crosspoint
	short	a
	dey
	beq	copy3a
copy3	lda	[ptr],y
	sta	[loopptr],y
	dey	
	bne	copy3
copy3a	lda	[ptr]
	sta	[loopptr]
	long	a
	DisposeHandle hand

next	inc	count
	lda	count
	cmp	nvoices
	jcc	loop
	jeq	loop

	rtl

	END

*
* Set up the sizes of the instruments for display and DOC flags
*

SetSizes	START	instutil

;	kind	$8000

	using	SongData

ptr	equ	0
count	equ	4
size	equ	6

	ld4	instmem1+3,ptr
               ld2	31,count
	ldx	#4
loop	stz	size
	stz	size+2
	ldy	#1
	lda	#'  '
	sta	[ptr]
	sta	[ptr],y
	ldy	#4
	sta	[ptr],y
	lda	VoicePtrTab,x
	ora	VoicePtrTab+2,x
	jeq	next
	lda	VoicePtrTab,x
	cmp	VloopPtrTab,x
	bne	ok2
	lda	VloopPtrTab+2,x
	cmp	VoicePtrTab+2,x
	beq	doloop
ok2	lda	VoiceLenTab,x
	sta	size
	lda	VoiceLenTab+2,x
	sta	size+2
doloop	clc
	lda	VloopLenTab,x
	adc	size
	sta	size
	lda	VloopLenTab+2,x
	adc	size+2
	sta	size+2

	phx
	lda	size+1
	lsr	a
	lsr	a
	Int2Dec (@a,ptr,#2,#0)
	short	a
	lda	[ptr]
	cmp	#' '
	bne	ok3
	lda	#'0'
	sta	[ptr]
ok3	ldy	#2
	lda	#'k'
	sta	[ptr],y
	long	a
	plx

	lda	VoiceDOCTab+2,x
	bne	ok4
	short	a
	lda	#$D7
	bra	ok5
ok4	short	a
	lda	#$13
ok5	ldy	#4
	sta	[ptr],y
	long	a

	lda	VLoopPtrTab,x
	ora	VLoopPtrTab+2,x
	beq	next

	lda	VLoopDOCTab+2,x
	bne	ok6
	short	a
	lda	#$D7
	bra	ok7
ok6	short	a
	lda	#$13
ok7	ldy	#5
	sta	[ptr],y
	long	a

next	inx       
	inx
	inx
	inx
	add4	ptr,#42,ptr
	dec	count
	jne	loop
	rtl

	END

	datachk on
