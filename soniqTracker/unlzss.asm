; UNLZSS - Written by Tim Meekins
;

	mcopy	m/unlzss.mac


N	gequ	4096	;size of ring buffer
F	gequ	18	;upper limit for match_length
THRESHOLD	gequ	2	;encode string into position and length


UNLZSSPic	START	exploder

	using	LZSSData

j	equ	0
i	equ	j+2
r	equ	i+2
in	equ	r+2
flags	equ	in+2
space	equ	flags+2

	subroutine (4:inbuf,2:length),space

; initialize the ring buffer to all zeros

	ldx	#N-F-2
	lda	#0
init	sta	text_buf,x
	dex
	dex
	bpl	init

	lda	#N-F
	sta	r
	stz	flags
	stz	in
	ldx	#0

loop	lda	flags
	bit	#$100
	bne	switch

	dec	length
	jmi	done
               ldy	in
	lda	[inbuf],y
	iny
	sty	in
	and	#$00ff
	ora	#$ff00

switch	lsr	a
	sta	flags
	bcc	string

	dec	length
	bmi	done
               ldy	in
	lda	[inbuf],y
	iny
	sty	in

	short	a
	sta	>$e12000,x
	inx
	ldy	r
	sta	text_buf,y
	long	a
	tya
	inc	a
	and	#N-1
	sta	r
	bra	loop

string	dec	length
	dec	length
	bmi	done
	ldy	in
	lda	[inbuf],y
	iny
	iny
	sty	in
	tay
	xba
	and	#$000f
	inc	a	;adc #THRESHOLD (2)
	inc	a
	sta	j
	tya
	and	#$00ff
	sta	i
	tya
	xba
	and	#$00f0
	asl	a
	asl	a
	asl	a
	asl	a
	ora	i
	tay

strloop	short	a
	lda	text_buf,y
	phy
	sta	>$e12000,x
	inx
	ldy	r
	sta	text_buf,y
	long	a
	tya
	inc	a	
	and	#N-1
	sta	r
	pla	
	inc	a
	and	#N-1
	tay
	dec	j
	bpl	strloop
	jmp	loop

done	return

	END

;
; LZSS data
;

LZSSData	DATA	exploder

text_buf	ds	N+F-1	;ring buffer of size N

	END
