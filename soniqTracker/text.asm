*
* soniqtracker text routines
*

	mcopy	m/text.mac

	copy	text.equ

cleartext	START

	using	textdata

	lda	backcolor
	ldx	#7*160-2
loop	sta   textbuf,x
	dex
	dex
	bpl	loop
	stz	textx
	rts

	END

scrollview	START

	using	textdata

count	equ	0

	lda	#60
	sta	count

	ldy	#49
	short	a

	phb
	lda	#$E1
	pha
	plb

loop	anop
wvbl1          lda   $C019
               bmi   wvbl1
wvbl2          lda   $C019
               bpl   wvbl2
               
	ldx	#0
scroll	lda	$2000+140*160+50,x
	sta	$2000+140*160+49,x
	sta	$2000+181*160+49,x
	lda	$2000+141*160+50,x
	sta	$2000+141*160+49,x
	sta	$2000+180*160+49,x
	lda	$2000+142*160+50,x
	sta	$2000+142*160+49,x
	sta	$2000+179*160+49,x
	lda	$2000+143*160+50,x
	sta	$2000+143*160+49,x
	sta	$2000+178*160+49,x
	lda	$2000+144*160+50,x
	sta	$2000+144*160+49,x
	sta	$2000+177*160+49,x
	lda	$2000+145*160+50,x
	sta	$2000+145*160+49,x
	sta	$2000+176*160+49,x
	lda	$2000+146*160+50,x
	sta	$2000+146*160+49,x
	sta	$2000+175*160+49,x
	inx            
	cpx	#59
	bne	scroll

	tyx
	lda	>textbuf+0*160,x
	sta	$2000+140*160+49+59
	sta	$2000+181*160+49+59
	lda	>textbuf+1*160,x
	sta	$2000+141*160+49+59
	sta	$2000+180*160+49+59
	lda	>textbuf+2*160,x
	sta	$2000+142*160+49+59
	sta	$2000+179*160+49+59
	lda	>textbuf+3*160,x
	sta	$2000+143*160+49+59
	sta	$2000+178*160+49+59
	lda	>textbuf+4*160,x
	sta	$2000+144*160+49+59
	sta	$2000+177*160+49+59
	lda	>textbuf+5*160,x
	sta	$2000+145*160+49+59
	sta	$2000+176*160+49+59
	lda	>textbuf+6*160,x
	sta	$2000+146*160+49+59
	sta	$2000+175*160+49+59
                              
	iny

	dec	count
	jne	loop
          
	plb
	long	a
	rts

	END

gettextlen	START

	using	Tables

	stz	textwidth
	ldy	#0
loop	lda	[textptr],y
	and	#$7F
	beq	done
	tax
	lda	fontlen,x
	and	#$FF
	clc
	adc	textwidth
	inc	a
	sta	textwidth
	iny
	bra	loop
done	rts

	END

centertext	START

	jsr	gettextlen

	lda	textwidth
	cmp	#320
	bcc	cont
	stz	textx
	rts

cont	lsr	a
	eor	#$FFFF
;	inc	a
	clc
	adc	#160+1
	sta	textx
	rts

	END

drawtext	START

	using	Tables

	ldy	#0
loop	lda	[textptr],y
	and	#$7F
	beq	done
	phy
	jsr	drawchar
	ply
	lda	[textptr],y
	and	#$7F
               tax
	lda	fontlen,x
	and	#$FF
;	clc
	sec
	adc	textx
;	inc	a
	sta	textx
	
	iny
	bra	loop

done	rts

	END

drawchar	START

	using	textdata
	using	Tables

	asl	a	;2
	asl	a	;4
	asl	a	;8
	sta	chidx
	stz	xnib
	lda	textx
	bit	#1
	beq	foo2
	inc	xnib
foo2	lsr	a
	sta	xoff
	mv4	conadr,conptr

	ldy	#7
loop	phy
	ldx	chidx
	lda	fonttab,x
	and	#$FF
	ldx	xnib
	beq	foo3
	lsr	a
foo3	asl	a
	asl	a
	tay
	lda	[conptr],y
	sta	byte
	ldx	xoff
	eor	#$FFFF
	and	textbuf,x
	sta	textbuf,x
	lda	byte
	and	forecolor
	ora	textbuf,x
	sta	textbuf,x
	inx                    
	inx
	iny
	iny	
	lda	[conptr],y
	sta	byte
	eor	#$FFFF
	and	textbuf,x
	sta	textbuf,x
	lda	byte
	and	forecolor
	ora	textbuf,x
	sta	textbuf,x
	add2	xoff,#160,xoff
               inc	chidx
	ply
	dey
	bne	loop

	rts

	END

textdata	DATA

conadr	ds	4
textbuf	ds	160*7

	END

;
; text buffer code for player....the buffer zone.....
;

InitZones	START

	using	textbuffers

	lda	#$0000
	sta	backcolor
	lda	#$4444
	sta	forecolor

	ld4	msg1,textptr
	ld4	track1onbuf,zonebuf
	jsr	makezone
	ld4	msg2,textptr
	ld4	track1offbuf,zonebuf
	jsr	makezone
	ld4	msg3,textptr
	ld4	track2onbuf,zonebuf
	jsr	makezone
	ld4	msg4,textptr
	ld4	track2offbuf,zonebuf
	jsr	makezone
	ld4	msg5,textptr
	ld4	track3onbuf,zonebuf
	jsr	makezone
	ld4	msg6,textptr
	ld4	track3offbuf,zonebuf
	jsr	makezone
	ld4	msg7,textptr
	ld4	track4onbuf,zonebuf
	jsr	makezone
	ld4	msg8,textptr
	ld4	track4offbuf,zonebuf
	jsr	makezone
	ld4	msg9,textptr
	ld4	playingbuf,zonebuf
	jsr	makezone
	ld4	msg10,textptr
	ld4	loadingbuf,zonebuf
	jsr	makezone
	ld4	msg11,textptr
	ld4	pausedbuf,zonebuf
	jsr	makezone
	ld4	msg12,textptr
	ld4	vol01buf,zonebuf
	jsr	makezone
	ld4	msg13,textptr
	ld4	vol02buf,zonebuf
	jsr	makezone
	ld4	msg14,textptr
	ld4	vol03buf,zonebuf
	jsr	makezone
	ld4	msg15,textptr
	ld4	vol04buf,zonebuf
	jsr	makezone
	ld4	msg16,textptr
	ld4	vol05buf,zonebuf
	jsr	makezone
	ld4	msg17,textptr
	ld4	vol06buf,zonebuf
	jsr	makezone
	ld4	msg18,textptr
	ld4	vol07buf,zonebuf
	jsr	makezone
	ld4	msg19,textptr
	ld4	vol08buf,zonebuf
	jsr	makezone
	ld4	msg20,textptr
	ld4	vol09buf,zonebuf
	jsr	makezone
	ld4	msg21,textptr
	ld4	vol10buf,zonebuf
	jsr	makezone
	ld4	msg22,textptr
	ld4	stereofullbuf,zonebuf
	jsr	makezone
	ld4	msg23,textptr
	ld4	stereo75buf,zonebuf
	jsr	makezone
	ld4	msg24,textptr
	ld4	stereo50buf,zonebuf
	jsr	makezone
	ld4	msg25,textptr
	ld4	stereo25buf,zonebuf
	jsr	makezone
	ld4	msg26,textptr
	ld4	stereomonobuf,zonebuf
	jsr	makezone
	ld4	msg27,textptr
	ld4	unknownbuf,zonebuf
	jsr	makezone
	ld4	msg28,textptr
	ld4	fiftybuf,zonebuf
	jsr	makezone
	ld4	msg29,textptr
	ld4	sixtybuf,zonebuf
	jmp	makezone
                                   
msg1	dc	c'Track 1 On',h'00'
msg2	dc	c'Track 1 Off',h'00'
msg3	dc	c'Track 2 On',h'00'
msg4	dc	c'Track 2 Off',h'00'
msg5	dc	c'Track 3 On',h'00'
msg6	dc	c'Track 3 Off',h'00'
msg7	dc	c'Track 4 On',h'00'
msg8	dc	c'Track 4 Off',h'00'
msg9	dc	c'Playing',h'00'
msg10	dc	c'Loading',h'00'
msg11	dc	c'PAUSED',h'00'
msg12	dc	c'Volume 1',h'00'
msg13	dc	c'Volume 2',h'00'
msg14	dc	c'Volume 3',h'00'
msg15	dc	c'Volume 4',h'00'
msg16	dc	c'Volume 5',h'00'
msg17	dc	c'Volume 6',h'00'
msg18	dc	c'Volume 7',h'00'
msg19	dc	c'Volume 8',h'00'
msg20	dc	c'Volume 9',h'00'
msg21	dc	c'Volume 10',h'00'
msg22	dc	c'Full Stereo',h'00'
msg23	dc	c'75% Stereo',h'00'
msg24	dc	c'50% Stereo',h'00'
msg25	dc	c'25% Stereo',h'00'
msg26	dc	c'Mono',h'00'
msg27	dc	c'Unknown Effect!',h'00'
msg28	dc	c'50 Hz',h'00'
msg29	dc	c'60 Hz',h'00'

	END

makezone	START

	using	textdata

	jsr	cleartext
	jsr	centertext
	jsr	drawtext

	add4	zonebuf,#42*1,80
	add4	zonebuf,#42*2,84
	add4	zonebuf,#42*3,88
	add4	zonebuf,#42*4,92
	add4	zonebuf,#42*5,96
	add4	zonebuf,#42*6,100
                                   
	ldy	#42-2
copy	lda	textbuf+0*160+80-21,y	
	sta	[zonebuf],y
	lda	textbuf+1*160+80-21,y	
	sta	[80],y
	lda	textbuf+2*160+80-21,y	
	sta	[84],y
	lda	textbuf+3*160+80-21,y	
	sta	[88],y
	lda	textbuf+4*160+80-21,y	
	sta	[92],y
	lda	textbuf+5*160+80-21,y	
	sta	[96],y
	lda	textbuf+6*160+80-21,y	
	sta	[100],y
               dey
	dey
	bpl	copy
	
	rts
	                  
	END

showzone	START

	using	textbuffers

	sta	80
	stx	82

	add4	80,#42*1,84
	add4	80,#42*2,88
	add4	80,#42*3,92
	add4	80,#42*4,96
	add4	80,#42*5,100
	add4	80,#42*6,104
                                   
	ldy	#42-2
copy	tyx
	lda	[80],y
	sta	>$E12000+116*160+4,x
	lda	[84],y
	sta	>$E12000+117*160+4,x
	lda	[88],y
	sta	>$E12000+118*160+4,x
	lda	[92],y
	sta	>$E12000+119*160+4,x
	lda	[96],y
	sta	>$E12000+120*160+4,x
	lda	[100],y
	sta	>$E12000+121*160+4,x
	lda	[104],y
	sta	>$E12000+122*160+4,x
               dey                     
	dey
	bpl	copy

	lda	#3*50
	sta	>zonecount
	
	rts
	                  
	END

clearzone	START

	ldx	#42-2
	lda	#0
loop	sta	>$E12000+116*160+4,x
	sta	>$E12000+117*160+4,x
	sta	>$E12000+118*160+4,x
	sta	>$E12000+119*160+4,x
	sta	>$E12000+120*160+4,x
	sta	>$E12000+121*160+4,x
	sta	>$E12000+122*160+4,x
               dex                     
	dex
	bpl	loop
	
	rts
	                  
	END

zonedaemon	START

	using	textbuffers

	lda	>zonecount
	beq	done
	dec	a
	sta	>zonecount
	bne	done
	jmp	clearzone

done	rts

	END

textbuffers	DATA	TamponZone

zonecount	dc	i2'0'
track1onbuf	ds	294
track1offbuf	ds	294
track2onbuf	ds	294
track2offbuf	ds	294
track3onbuf	ds	294
track3offbuf	ds	294
track4onbuf	ds	294
track4offbuf	ds	294
playingbuf	ds	294
loadingbuf	ds	294
pausedbuf	ds	294
vol01buf	ds	294
vol02buf	ds	294
vol03buf	ds	294
vol04buf	ds	294
vol05buf	ds	294
vol06buf	ds	294
vol07buf	ds	294
vol08buf	ds	294
vol09buf	ds	294
vol10buf	ds	294
stereofullbuf	ds	294
stereo75buf	ds	294
stereo50buf	ds	294
stereo25buf	ds	294
stereomonobuf	ds	294
unknownbuf	ds	294
fiftybuf	ds	294
sixtybuf	ds	294

	END
