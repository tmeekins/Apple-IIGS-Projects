; unlzss with Tim's optimizations

	keep	unlzssP2P
	mcopy	unlzss.mac

IndexBitCount	gequ	14
LengthBitCount	gequ	4
WindowSize	gequ	1|IndexBitCount
RawLASize	gequ	1|LengthBitCount
OrcaLame 	gequ	1+IndexBitCount+LengthBitCount
BreakEven	gequ	OrcaLame/9
LookAheadSize	gequ	RawLASize+BreakEven
TreeRoot	gequ	WindowSize
EndOfStream	gequ	0
Unused	gequ	0

InBufSize	gequ	32768
OutBufSize	gequ	32768

LZSSExpandPtoP	start

BitCount	equ	1
BitFileRack	equ	BitCount+2
InBitIndex	equ	BitFileRack+2
InBitsRetVal	equ	InBitIndex+2
MatchPos	equ	InBitsRetVal+2
MatchLen	equ	MatchPos+2
OutBufIndex	equ	MatchLen+2
Dpage	equ	OutBufIndex+2
RTL	equ	Dpage+2
MyID	equ	RTL+3
OutBufPtr	equ	MyID+2
InBitBufPtr	gequ	OutBufPtr+4

TS	equ	14	; reserve 22 bytes of space
In	equ	10	; 10 bytes input

	phd		; save dpage
	tsc
	sec
	sbc	#TS	; reserve space
	tcs
	tcd

	stz	BitFileRack	; set some flags for bit i/o
	stz	BitCount
	stz	InBitIndex

	stz	OutBufIndex	; zero output buffer index

* start of main code

	ldx	#1
GetBit	dec	BitCount
	bmi	GetChar
	asl	BitFileRack
	bcs	nocode
	bra	DoCode

GetChar	ldy	InBitIndex	; get one char
	lda	[InBitBufPtr],y
	xba
	iny                 
	iny                     
	sty	InBitIndex     
	bne	NoReloadBuf
	inc	InBitBufPtr+2

NoReloadBuf	ldy	#15
	sty	BitCount

	asl	a
	sta	BitFileRack
	bcc	DoCode

nocode	ldy	#8	;   else it's a plain byte
	phx
	jsr	InputBits
	plx
	short	m
	ldy	OutBufIndex
	sta	[OutBufPtr],y
	sta	Window,x
	long	m
	iny
	sty	OutBufIndex
	bne	NoFlushBuf
	inc	OutBufPtr+2
NoFlushBuf	txa
	inc	a
	and	#WindowSize-1
	tax
	bra	GetBit

DoCode	phx
	ldy	#IndexBitCount
	jsr	InputBits
	beq	Done	; if code is 0, we're done
	sta	MatchPos
	ldy	#LengthBitCount
	jsr	InputBits
	clc
	adc	#BreakEven
	sta	MatchLen
	plx
ForLoop	lda	MatchPos
	and	#WindowSize-1
	tay
	short	m
	lda	Window,y
	ldy	OutBufIndex
	sta	[OutBufPtr],y
	sta	Window,x
	long	m
	iny
	sty	OutBufIndex
	bne	BumpCurPos
	inc	OutBufPtr+2
	txy
BumpCurPos	tya
	inc	a
	and	#WindowSize-1
	tax
	inc	MatchPos
	dec	MatchLen
	bpl	ForLoop
	jmp	GetBit    

Done	plx

FixStack	lda	RTL+1	; get RTL addr
	sta	InBitBufPtr+2
	lda	RTL-1
	sta	InBitBufPtr
	lda	DPage	; restore dpage
	tcd
	tsc		; restore stack ptr
	clc
	adc	#TS+In+2
	tcs

	rtl		; return

Window	ds	WindowSize

               end

InputBits	start

BitCount	equ	1
BitFileRack	equ	BitCount+2
InBitIndex	equ	BitFileRack+2
InBitsRetVal	equ	InBitIndex+2

; assumes number of bits to be read is in y reg

	stz	InBitsRetVal	; zero return value

	ldx	BitCount
	beq	GetChar
	lda	BitFileRack
ShiftLoop	asl	a
	rol	InBitsRetVal
	dey
	beq	done
               dex
	bne	ShiftLoop
	bra	GetChar
done	dex
	sta	BitFileRack
	stx	BitCount
	lda	InBitsRetVal	; return result in a
	rts

GetChar	phy
	ldy	InBitIndex	; get two chars
	lda	[InBitBufPtr],y
	xba
	iny
	iny
	sty	InBitIndex	
	bne	NoReloadBuf
	inc	InBitBufPtr+2
NoReloadBuf	ply
	ldx	#16
	bra	ShiftLoop

	end
