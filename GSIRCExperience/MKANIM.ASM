	mcopy	mkanim.mac

main	start

temphandle	equ	0

          	phk
               plb
;
; Start up some tools
;
               TLStartUp
               MMStartUp ID
               NewHandle (#$300,ID,#%1100000000000101,#0),TempHandle
               QDStartUp ([TempHandle],#0,#320,ID)
               HideCursor
               LoadOneTool (#230,#0)
               ZPStartUp ID

	jsr	opendata

	jsr	loadbak
;	jsr	showbak

	lda	#$3F
	sta	frame
;	jsr	loadlogo
;	jsr	writeframe1
	stz	frame
	dec	frame

loop	jsr	savepic
	inc	frame
	lda	frame
	cmp	#$40
	beq	font
	jsr	loadlogo
	jsr	compilepic
               bra	loop

font	anop

done           jsr	closedata
	ZPShutDown
               UnloadOneTool #230
               GrafOff
               QDShutDown
               MMShutDown ID
               TLShutDown

               Quit  QuitParm

frame	ds	2
ID             ds    2
QuitParm       dc    i'0'
               
	end

*********************
*
* Load and merge the logo
*
*********************

loadlogo	start

ptr1	equ	0
ptr2	equ	4
maskbyte	equ	8
rowcount	equ	10
colcount	equ	12
srcidx	equ	14
destidx	equ	16

	using	pic1data
	using	pic3data
	using	apfdata

	asl	a
	tax
	lda	files,x
	sta	filename+10

	open	openparm
	mv2	openref,(readref,closeref)
	read	readparm
	close	closeparm

               APFUnPackMain (#logopic,#apfbuf,readgot)

;	jsr	showbak
	jmp	part2
;
; creates a drop shadow of "irc", but looks like shit....
;
	lda	#160*18
	sta	srcidx
	lda	#160*175
	sta	destidx
	lda	#45-1
	sta	rowcount
loop2	lda	#160-1
	sta	colcount
loop3	short	a
	ldx	srcidx
	lda	>logopic,x
	ldx	destidx
	tay
	lda	mask,y
	eor	#$FF
	pha
	eor	#$FF
	and	>bakpic,x
	tay
	lda	shad,y
	sta	bar+1
	pla
	and   >bakpic,x
bar	ora	#00
	sta	>$E12000,x
	long	a
	inc	srcidx
	inc	destidx
	dec	colcount
	bpl	loop3
	lda	destidx
	sec
	sbc	#160*2
	sta	destidx
	dec	rowcount
	bpl	loop2
	
part2	short	a
	ldx	#45*160
loop1	lda	>logopic+160*18,x
	sta	foo+1
	tay
	lda	mask,y
	eor	#$FF
	and	>bakpic+160*80,x
foo	ora	#00
	sta   >$E12000+160*80,x
	dex
	bne	loop1
	long	a

	rts


openparm	dc	i2'2'
openref	dc	i2'0'
	dc	a4'filename'

readparm	dc	i2'4'
readref	dc	i2'0'
	dc	a4'apfbuf'
	dc	i4'$8000'
readgot	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

filename	gsstr	'pics:irc00'

files	dc	c'400102030405060708090a0b0c0d0e0f'
	dc	c'101112131415161718191a1b1c1d1e1f'
	dc	c'202122232425262728292a2b2c2d2e2f'
	dc	c'303132333435363738393a3b3c3d3e3f'
               dc	h'00'

mask	dc	h'000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
	dc	h'f0ffffffffffffffffffffffffffffff'
                                                        
shad	dc	h'00000000000000000102030405060F00'
	dc	h'00000000000000000102030405060F00'
	dc	h'00000000000000000102030405060F00'
	dc	h'00000000000000000102030405060F00'
	dc	h'00000000000000000102030405060F00'
	dc	h'00000000000000000102030405060F00'
	dc	h'00000000000000000102030405060F00'
	dc	h'00000000000000000102030405060F00'
	dc	h'10101010101010101112131415161F10'
	dc	h'20202020202020202122232425262F20'
	dc	h'30303030303030303132333435363F30'
	dc	h'40404040404040404142434445464F40'
	dc	h'50505050505050505152535455565F50'
	dc	h'60606060606060606162636465666F60'
	dc	h'F0F0F0F0F0F0F0F0F1F2F3F4F5F6FFF0'
	dc	h'00000000000000000102030405060F00'
                                                        
	end           

*********************
*
* load background picture
*
*********************

loadbak	start

	using	pic1data

	open	openparm
	mv2	openref,(readref,closeref)
	read	readparm
	close	closeparm

	ldx	#32-2
loop	lda	bakpal,x
	sta	>bakpic+$7E00,x
	dex2
	bpl	loop

	jsr	showbak

	jsr	zapbak
	lda	#$3F
	jsr	loadlogo

	create createparm
	open	open2parm
	mv2	open2ref,(readref,closeref)
	write	readparm
	close	closeparm

	rts

bakpal	dc	i2'$000,$666,$888,$AAA,$CCC,$0F0,$000'
	dc	i2'$B91,$B91,$B91,$B91,$783,$783,$783,$783'
	dc	i2'$FFF'

openparm	dc	i2'2'
openref	dc	i2'0'
	dc	a4'filename'

open2parm	dc	i2'2'
open2ref	dc	i2'0'
	dc	a4'filename2'

createparm	dc	i2'3'
	dc	a4'filename2'
	dc	i2'$c3'
	dc	i2'6'

readparm	dc	i2'4'
readref	dc	i2'0'
	dc	a4'bakpic'
	dc	i4'$8000'
	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

filename	gsstr	'ground.pic'
filename2	gsstr	'backpic'

	end

*********************
*
* zap the background
*
*********************

zapbak	start

	using	pic1data

	short	a
	ldx	#0
loop1	lda	>bakpic,x
	ldy	#160
loop2	sta	>bakpic,x
	inx
	dey
	bne	loop2
	cpx	#80*160
	bcc	loop1

	long	a
	rts

	end

******************
*
* display background pic
*
******************

showbak	start

	using	pic1data

	ldx	#$8000-2
loop	lda	>bakpic,x
	sta	>$e12000,x
	dex2
	bpl	loop

	rts	

	end

******************
*
* save as prevpic
*
******************

savepic	start

	using	pic2data

	ldx	#$8000-2
loop	lda	>$e12000,x
	sta	>prevpic,x
	dex2
	bpl	loop

	rts	

	end

************************************
*
* open data file
*
************************************

opendata	start

	using	filedata

	create createparm
	open	openparm
	mv2	openref,outrefnum
	rts

createparm	dc	i2'3'
	dc	a4'filename'
	dc	i2'$c3'
	dc	i2'6'

openparm	dc	i2'2'
openref	dc	i2'0'
	dc	a4'filename'	

filename	gsstr	'gnotim.data'

	end

************************************
*
* close data file
*
************************************

closedata	start

	using	filedata

	mv2	outrefnum,closeref
	close	closeparm
	rts

closeparm	dc	i2'1'
closeref	dc	i2'0'

	end

************************************
*
* write the main screen
*
************************************

writeframe1	start

	using	filedata

	mv2	outrefnum,writeref
	write	writeparm
	rts

writeparm	dc	i2'4'
writeref	dc	i2'0'
	dc	a4'$E12000'
	dc	i4'$8000'
	dc	i4'0'

	end

*********************************
*
* Compile an animation frame
*
*********************************

compilepic	start

	using	pic2data
	using	bufdata
	using	filedata

prevbyte	equ	0
keybyte	equ	2

	lda	#$FF
	sta	prevbyte
	stz	keybyte
	lda	#0
	sta	bufptr

keyloop	ldx	#160*80

byteloop	phx
	short	a
	lda	$E12000,x
	cmp	keybyte
	bne	nextbyte
	cmp	>prevpic,x
	beq	nextbyte

dobyte	cmp	#0
	beq	dozero
	cmp	prevbyte
	beq	putbyte
	dec	a
	cmp	prevbyte
	beq	incbyte
	inc	a

	sta	prevbyte
	pha
	lda	#$A9	;LDA #const
	jsr	storebyte
	pla
	jsr	storebyte

putbyte	lda	#$8D	;STA addr
	jsr	storebyte

putaddr	long	a
	pla
	pha
	clc
	adc	#$2000
	jsr	storebyte
	inc	bufptr
	short	a
	bra	nextbyte

dozero	lda	#$9C	;STZ addr
	jsr	storebyte
	bra	putaddr

incbyte	inc	prevbyte
	lda	#$1A	;INC A
	jsr	storebyte
	bra	putbyte

nextbyte	long	a
	plx
	inx
	cpx	#160*(80+46)
	bcc	byteloop

nextkey	inc	keybyte
	lda	keybyte
	cmp	#$100
	bne	keyloop

	lda	#$6B	;RTL
	jsr	storebyte

	mv2	outrefnum,writeref
	lda	bufptr
	inc	a
	inc	a
	sta	writesize
	write	writeparm
                             
	rts

storebyte	ldx	bufptr
	sta	buffer,x
	inx
	stx	bufptr
	rts

writeparm	dc	i2'4'
writeref	dc	i2'0'
	dc	a4'bufptr'
writesize	dc	i4'0'
	dc	i4'0'

	end           

filedata	data

outrefnum	ds	2

	end

bufdata	data

bufptr	ds	2
buffer	ds	$6000

	end

pic1data	data	seg2

bakpic	ds	$8000

	end

pic2data	data	seg3

prevpic	ds	$8000	

	end

pic3data	data	seg4

logopic	ds	$8000

	end

apfdata	data	seg5

apfbuf	ds	$8000

	end
