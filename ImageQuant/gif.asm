**************************************************************************
*
* ImageQuant GIF image loading support routines
*
**************************************************************************

	mcopy	gif.mac

**************************************************************************
*
* decode a GIF file
*
**************************************************************************

LoadGIF	START

	using	Globals

raw	equ	0
giftype	equ	4
row	equ	6
image	equ	10
bitpixel	equ	14
rcmnum	equ	16
globcolortab	equ	18
c	equ	22
lbitpixel	equ	24
loccolortab	equ	26
bitres	equ	30
height	equ	32
width	equ	34
table1	equ	36
table2	equ	40
sp	equ	44
stack	equ	48
cmap	equ	52
fresh	equ	56
incode	equ	58
code_size	equ	60
set_code_size	equ	62
max_code	equ	64
max_code_size	equ	66
firstcode	equ	68
oldcode	equ	70
clear_code	equ	72
end_code	equ	74
curbit	equ	76
lastbit	equ	78
doneflag	equ	80
last_byte	equ	82
count	equ	84
ret	equ	86
i	equ	88
j	equ	90

	mv4	LoadPtr,raw
;
; Check for AOL GIF header by seeing if the GIF header is at +$20
;
	ldy	#$20
	lda	[raw],y
	cmp	#'IG'
	bne	okhdr
	ldy	#$22
	lda	[raw],y
	and	#$FF
	cmp	#'F'
	bne	okhdr
	add4	raw,#$20,raw
;                         
; Check for the GIF header
;
okhdr	lda	[raw]
	cmp	#'IG'
	bne	badgif
	ldy	#2
	lda	[raw],y
	and	#$FF
	cmp	#'F'
	bne	badgif
	stz	giftype
	ldy	#3
	lda	[raw],y
	cmp	#'78'
	beq	chk87
	cmp	#'89'
	bne	goodgif
	ldy	#5
	lda	[raw],y
	and	#$FF
	cmp	#'a'
	bne	goodgif
	lda	#2
	sta	giftype	;it's an 89a
	bra	goodgif
chk87	ldy	#5
	lda	[raw],y
	and	#$FF
	cmp	#'a'
	bne	goodgif
	lda	#1
	sta	giftype	;it's an 87a
               bra	goodgif   

badgif	InitCursor
	AlertWindow (#0,#0,#loadmsg),@a
	rts

goodgif	jsr	DisposeImage
               add4	raw,#6,raw
	
               ldy	#4
	lda	[raw],y
	and	#%111
	inc	a
	asl	a
	tax
	lda	bittbl,x
	sta	bitpixel
	stz	globcolortab
	stz	globcolortab+2
	lda	[raw],y
	bit	#%10000000
	php
	add4	raw,#7,raw
	plp
	beq	skipglobal
;
; read the global palette
;
	lda	bitpixel
	jsr	readcolormap
	lda	128
	sta	globcolortab
	sta	cmap
	lda	128+2
	sta	globcolortab+2
	sta	cmap+2

skipglobal     anop

bigloop	anop

	lda	[raw]
	and	#$FF
	sta	c
               add4	raw,#1,raw
	lda	c
	cmp	#';'
	bne	gif1
	InitCursor
	rts

gif1	cmp	#'!'
	bne	gif2
	add4	raw,#1,raw
	jsr	ignoreextension	
	bne	gif2
	InitCursor
	rts

gif2	lda	c
	cmp	#','
	bne	bigloop	;bogus character

	ldy	#4
	lda	[raw],y
	sta	ImageWidth	
	ldy	#6
	lda	[raw],y
	sta	ImageHeight

	ldy	#8        
	lda	[raw],y
	and	#%111
	inc	a
	asl	a
	tax
	lda	bittbl,x
	sta	lbitpixel

	stz	loccolortab
	stz	loccolortab+2
	lda	[raw],y
	pha
	and	#%10000000
	php
	add4	raw,#9,raw
	plp
	beq	gif3
;
; use local colormap
;
	lda	lbitpixel
	jsr	readcolormap
	lda	128
	sta	loccolortab
	sta	cmap
	lda	128+2
	sta	loccolortab+2
	sta	cmap+2

gif3	pla		
	
	and	#%01000000
	bne	gif4
;
; do noninterlace
;
	jmp	dorawgif
;
; do interlace
;
gif4	jmp	dointgif
;
; Read a colormap
;
readcolormap	sta	rcmnum
	asl	a
	adc	rcmnum
	sta	rcmnum
	ldx	#0
	NewHandle (@xa,ID,#$C018,#0),@ax
	sta	128
	stx	128+2
	ldy	#2
	lda	[128],y
	tax
	lda	[128]
	sta	128
	stx	128+2
	sta	132
	stx	132+2

	ldx	rcmnum
loop	short	a
	lda	[raw]
	sta	[132]
	long	a
	inc	132
	add4	raw,#1,raw
	dex
	bne	loop
	rts
;
; ignore an extension
;
ignoreextension anop

	lda	[raw]
	and	#$FF
	beq	igack
	sec		;includes the inc a
	adc	raw
	sta	raw
	lda	#0
	adc	raw+2
	sta	raw+2
	lda	#1
igack	rts
;
; load a non interlaced image
;
dorawgif	ph4	#LoadStr
	ph2	ImageHeight
	jsl	OpenThermo
	stz	therm

	jsr	AllocateImage

	lda	[raw]
	and	#$FF
	sta	c
	add4	raw,#1,raw

	lda	ImageHeight
	sta	height                               

	lda	c
	jsr	LZWReadByte1

	mv4	ImagePtr,image               
yloop	ldy	#2
	lda	[image]
	sta	row
	lda	[image],y
	sta	row+2
	lda	ImageWidth
	sta	width

xloop	jsr	LZWReadByte2	
	sta	c
	asl	a
	adc	c
	tay
	lda	[cmap],y
	sta	[row]
	iny
	lda	[cmap],y
	ldy	#1
	sta	[row],y
	add4	row,#3,row
	dec	width
	bne	xloop
	add2	image,#4,image
	inc	therm
	lda	therm
	jsl	UpdateThermo
	dec	height
	bne	yloop

donegif	jsl	CloseThermo

	ldx	globcolortab+2
	lda	globcolortab
	jsr	DisposePointer
	ldx	loccolortab+2
	lda	loccolortab
	jsr	DisposePointer
	ldx	table1+2
	lda	table1
	jsr	DisposePointer
	ldx	table2+2
	lda	table2
	jsr	DisposePointer
	ldx	stack+2
	lda	stack
	jsr	DisposePointer
                           
	rts
;
; load an interlaced image
;
dointgif	ph4	#LoadStr
	ph2	ImageHeight
	jsl	OpenThermo
	stz	therm

	jsr	AllocateImage

	lda	[raw]
	and	#$FF
	sta	c
	add4	raw,#1,raw

	lda	c
	jsr	LZWReadByte1

	lda	ImageHeight
	sta	height                               
	mv4	ImagePtr,image               
yloop0	ldy	#2
	lda	[image]
	sta	row
	lda	[image],y
	sta	row+2
	lda	ImageWidth
	sta	width
xloop0	jsr	LZWReadByte2	
	sta	c
	asl	a
	adc	c
	tay
	lda	[cmap],y
	sta	[row]
	iny
	lda	[cmap],y
	ldy	#1
	sta	[row],y
	add4	row,#3,row
	dec	width
	bne	xloop0
	add2	image,#4*8,image
	inc	therm
	lda	therm
	jsl	UpdateThermo
	lda	height
	sec
	sbc	#8
	sta	height
	bmi	done0
	bne	yloop0
done0	anop

	lda	ImageHeight
	sec
	sbc	#4
	sta	height                               
	add4	ImagePtr,#4*4,image               
yloop1	ldy	#2
	lda	[image]
	sta	row
	lda	[image],y
	sta	row+2
	lda	ImageWidth
	sta	width
xloop1	jsr	LZWReadByte2	
	sta	c
	asl	a
	adc	c
	tay
	lda	[cmap],y
	sta	[row]
	iny
	lda	[cmap],y
	ldy	#1
	sta	[row],y
	add4	row,#3,row
	dec	width
	bne	xloop1
	add2	image,#4*8,image
	inc	therm
	lda	therm
	jsl	UpdateThermo
	lda	height
	sec
	sbc	#8
	sta	height
	bmi	done1
	bne	yloop1
done1	anop

	lda	ImageHeight
	dec	a
	dec	a
	sta	height                               
	add4	ImagePtr,#2*4,image               
yloop2	ldy	#2
	lda	[image]
	sta	row
	lda	[image],y
	sta	row+2
	lda	ImageWidth
	sta	width
xloop2	jsr	LZWReadByte2	
	sta	c
	asl	a
	adc	c
	tay
	lda	[cmap],y
	sta	[row]
	iny
	lda	[cmap],y
	ldy	#1
	sta	[row],y
	add4	row,#3,row
	dec	width
	bne	xloop2
	add2	image,#4*4,image
	inc	therm
	lda	therm
	jsl	UpdateThermo
	lda	height
	sec
	sbc	#4
	sta	height
	bmi	done2
	bne	yloop2
done2	anop

	lda	ImageHeight
	dec	a
	sta	height                               
	add4	ImagePtr,#4,image               
yloop3	ldy	#2
	lda	[image]
	sta	row
	lda	[image],y
	sta	row+2
	lda	ImageWidth
	sta	width
xloop3	jsr	LZWReadByte2	
	sta	c
	asl	a
	adc	c
	tay
	lda	[cmap],y
	sta	[row]
	iny
	lda	[cmap],y
	ldy	#1
	sta	[row],y
	add4	row,#3,row
	dec	width
	bne	xloop3
	add2	image,#4*2,image
	inc	therm
	lda	therm
	jsl	UpdateThermo
	lda	height
	dec	a
	dec	a
	sta	height
	bmi	done3
	bne	yloop3
done3	anop

	jmp	donegif
;                         
; read an LZWbyte
;
LZWReadByte1	sta	set_code_size
	inc	a
	sta	code_size
	dec	a
	asl	a
	tax
	lda	bittbl,x
	sta	clear_code
	inc	a
	sta	end_code
	dec	a
	asl	a
	sta	max_code_size
	lda	clear_code
	inc	a
	inc	a
	sta	max_code

	jsr	GetCode1
		
	lda	#1
	sta	fresh

	NewHandle (#4096*2,ID,#$C018,#0),@ax
	sta	table1
	stx	table1+2
	NewHandle (#4096*2,ID,#$C018,#0),@ax
	sta	table2
	stx	table2+2
	NewHandle (#4096*2*2,ID,#$C018,#0),@ax
	sta	stack
	stx	stack+2
	ldy	#2
	lda	[table1],y
	tax
	lda	[table1]	
	sta	table1
	stx	table1+2
	lda	[table2],y
	tax
	lda	[table2]	
	sta	table2
	stx	table2+2
	lda	[stack],y
	tax
	lda	[stack]	
	sta	stack
	stx	stack+2
                                   
	lda	clear_code
	dec	a
	tax
	asl	a
	tay
clrtab	lda	#0
	sta	[table1],y
	txa
	sta	[table2],y
	dex
	dey
	dey
	bpl	clrtab

	lda	clear_code
	asl	a
	tay
	lda	#0
clrtab2	sta	[table1],y
;	sta	[table2]
	iny
	iny
	cpy	#4096*2	
	bne	clrtab2
	
	lda	stack
	sta	sp
	lda	stack+2
	sta	sp+2

	rts

LZWReadByte2	lda	fresh
	beq	notfresh

	stz	fresh

freshloop	jsr	GetCode2
	sta	firstcode
	sta	oldcode
	cmp	clear_code
	beq	freshloop
	rts

notfresh	lda	sp
	cmp	stack
	beq	getwhile
	dec	a
	dec	a
	sta	sp
	lda	[sp]
	rts

getwhile       jsr	GetCode2
	bpl	chkclear
	rts

chkclear       cmp	clear_code
	bne	noclear

;	lda	clear_code
	dec	a
	tax
	asl	a
	tay
clrtaba	lda	#0
	sta	[table1],y
	txa
	sta	[table2],y
	dex
	dey
	dey
	bpl	clrtaba

	lda	clear_code
	asl	a
	tay
	lda	#0
clrtab2a	sta	[table1],y
	sta	[table2],y
	iny
	iny
	cpy	#4096*2	
	bne	clrtab2a
	
	lda	set_code_size
	inc	a
	sta	code_size
	lda	clear_code
	asl	a
	sta	max_code_size
	lda	clear_code
	inc	a
	inc	a
	sta	max_code
	lda	stack
	sta	sp
	lda	stack+2
	sta	sp+2
	jsr	GetCode2
	sta	oldcode
	sta	firstcode
	rts
       
noclear	cmp	end_code
	bne	noend
               jsr	ignoreextension
	lda	#-2
	rts

noend	sta	incode

	cmp	max_code
	bcc	nopush
	lda	firstcode
	sta	[sp]
	lda	sp
	inc	a
	inc	a
	sta	sp
	lda	oldcode

nopush	cmp	clear_code
	bcc	nopush2
	asl	a
	tay
	lda	[table2],y
	sta	[sp]
	lda	sp
	inc	a
	inc	a
	sta	sp
	lda	[table1],y
	bra	nopush

nopush2	asl	a
	tay
	lda	[table2],y
	sta	firstcode
	sta	[sp]
	lda	sp
	inc	a
	inc	a
	sta	sp

	lda	max_code
	cmp	#4096
	bcs	noincsize
	asl	a
	tay
	lda	oldcode
	sta	[table1],y
	lda	firstcode
	sta	[table2],y
	inc	max_code
	lda	max_code
	cmp	max_code_size
	bcc	noincsize
	lda	max_code_size
	cmp	#4096
	bcs	noincsize
	asl	a
	sta	max_code_size
	inc	code_size
noincsize	anop

	lda	incode
	sta	oldcode
		
	jmp	notfresh
;
; read an LZW code byte
;
GetCode1	anop

	stz	curbit
	stz	lastbit
	stz	doneflag
	rts

GetCode2	anop

	clc
	lda	curbit
	adc	code_size
	cmp	lastbit
	bcc	GetCodeok

	ldx	last_byte
	lda	buf-2,x
	sta	buf
	lda	[raw]
	and	#$FF
	sta	count
	add4	raw,#1,raw
	lda	count
	bne	get1
               inc	doneflag
	bra	get3
get1	tax
	ldy	#0
	short	a
get2	lda	[raw],y
	sta	buf+2,y
	iny
	dex
	bne	get2
	rep	#$21
	longa	on
	lda	raw
	adc	count
	sta	raw
	bcc	get3
	inc	raw+2
	
get3	lda	count
	inc	a
	inc	a
	sta	last_byte
	sec
	lda	curbit
	sbc	lastbit
	clc
	adc	#16
	sta	curbit
	lda	count
	inc	a
	inc	a
	asl	a
	asl	a
	asl	a
	sta	lastbit

GetCodeok	stz	ret

	lda	curbit
	sta	i
	ldy	#0
gcloop         anop
	lda	i
	lsr	a
	lsr	a
	lsr	a
	tax
	short	a
	lsr	buf,x
	ror	ret+1
	ror	ret
	long	a
gcnext         anop
	inc	i
	iny
	cpy	code_size
	bcc	gcloop


gcdone	cpy	#16
	bcs	gcexit
	lsr	ret
	iny
	bra	gcdone
	
gcexit	clc
	lda	curbit
	adc	code_size
	sta	curbit

	lda	ret

	rts	

byte	ds	2
bit	ds	2

buf	ds	280

loadmsg	dc	c'23/The picture is not a GIF/OK',h'00'

bittbl	dc	i2'1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192'
	dc	i2'16384,32768'

therm	ds	2
LoadStr	dc	c'Loading GIF Image...',h'00'
                      
	END
