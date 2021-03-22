**************************************************************************
*
* ImageQuant
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* iqgif.asm
*
* ImageQuant GIF loading routines
*
**************************************************************************

	mcopy	m/iqgif.mac

;-------------------------------------------------------------------------
; LoadGIF
;    Load a GIF
;-------------------------------------------------------------------------

LoadGIF	START IQgif

;               kind  $8000

	using	Globals

curbyte	equ	1
ptr	equ	curbyte+2
colormap	equ	ptr+4
giftype	equ	colormap+4
row	equ	giftype+2
image	equ	row+4
bitpixel	equ	image+4
rcmnum	equ	bitpixel+2
globcolortab	equ	rcmnum+2
c	equ	globcolortab+4
lbitpixel	equ	c+2
loccolortab	equ	lbitpixel+2
bitres	equ	loccolortab+4
height	equ	bitres+2
width	equ	height+2
sp	equ	width+2
cmap	equ	sp+2
incode	equ	cmap+4
code_size	equ	incode+2
set_code_size	equ	code_size+2
max_code	equ	set_code_size+2
max_code_size	equ	max_code+2
firstcode	equ	max_code_size+2
oldcode	equ	firstcode+2
clear_code	equ	oldcode+2
end_code	equ	clear_code+2
curbit	equ	end_code+2
doneflag	equ	curbit+2
last_byte	equ	doneflag+2
j	equ	last_byte+2
space	equ	j+2

	subroutine (4:raw),space
;
; Check for AOL GIF header by seeing if the GIF header is at +$20
;
	ldy	#$20
	lda	[<raw],y
	cmp	#'IG'
	bne	okhdr
	ldy	#$22
	lda	[<raw],y
	and	#$FF
	cmp	#'F'
	bne	okhdr
	clc
	lda	<raw
	adc	#$20
	sta	<raw
	lda	<raw+2
	adc	#0
	sta	<raw+2
;                         
; Check for the GIF header
;
okhdr	lda	[<raw]
	cmp	#'IG'
	bne	badgif
	ldy	#2
	lda	[<raw],y
	and	#$FF
	cmp	#'F'
	bne	badgif
	stz	<giftype
	ldy	#3
	lda	[<raw],y
	cmp	#'78'
	beq	chk87
	cmp	#'98'
	bne	goodgif
	ldy	#5
	lda	[<raw],y
	and	#$FF
	cmp	#'a'
	bne	goodgif
	lda	#2
	sta	<giftype	;it's an 89a
	bra	goodgif
chk87	ldy	#5
	lda	[<raw],y
	and	#$FF
	cmp	#'a'
	bne	goodgif
	lda	#1
	sta	<giftype	;it's an 87a
               bra	goodgif   

badgif	ph4	#errmsg
	jsl	IQError
	jmp	done

goodgif	jsl	DisposeImage

	clc
	lda	<raw
	adc	#6
	sta	<raw
	lda	<raw+2
	adc	#0
	sta	<raw+2
	
               ldy	#4
	lda	[<raw],y
	and	#%111
;	inc	a
	asl	a
	tax
	lda	!bittbl+2,x
	sta	<bitpixel
	stz	<globcolortab
	stz	<globcolortab+2
	lda	[<raw],y
	bit	#%10000000
	php
	lda	<raw
	adc	#7
	sta	<raw
	lda	<raw+2
	adc	#0
	sta	<raw+2
	plp
	beq	skipglobal
;
; read the global palette
;
	lda	<bitpixel
	jsr	readcolormap
	lda	<colormap
	sta	<globcolortab
	sta	<cmap
	lda	<colormap+2
	sta	<globcolortab+2
	sta	<cmap+2
skipglobal     anop

bigloop	lda	[<raw]
	and	#$FF
	sta	<c
	clc
	lda	<raw
	adc	#1
	sta	<raw
	lda	<raw+2
	adc	#0
	sta	<raw+2
	lda	<c
	cmp	#';'
	bne	gif1
	jmp	done

gif1	cmp	#'!'
	bne	gif2
	clc
	lda	<raw
	adc	#1
	sta	<raw
	lda	<raw+2
	adc	#0
	sta	<raw+2
	jsr	ignoreextension	
	bne	gif2
               jmp	done

gif2	lda	<c
	cmp	#','
	bne	bigloop	;bogus character

	ldy	#4
	lda	[<raw],y
	sta	>ImageWidth	
	ldy	#6
	lda	[<raw],y
	sta	>ImageHeight

	ldy	#8        
	lda	[<raw],y
	and	#%111
	inc	a
	asl	a
	tax
	lda	!bittbl,x
	sta	<lbitpixel

	stz	<loccolortab
	stz	<loccolortab+2
	lda	[<raw],y
	pha
	and	#%10000000
	php
	lda	<raw	
	adc	#9
	sta	<raw
	lda	<raw+2
	adc	#0
	sta	<raw+2
	plp
	beq	gif3
;
; use local colormap
;
	lda	<lbitpixel
	jsr	readcolormap
	lda	<colormap
	sta	<loccolortab
	sta	<cmap
	lda	<colormap+2
	sta	<loccolortab+2
	sta	<cmap+2

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
readcolormap	pea	$C018
	pea	0
	sta	<rcmnum
	asl	a
	adc	<rcmnum
	sta	<rcmnum
	pha
	jsl	TVMM_allocreal
	sta	<colormap
	stx	<colormap+2
	sta	<ptr
	stx	<ptr+2	

	ldx	<rcmnum
loop	short	a
	lda	[<raw]
	sta	[<ptr]
	rep	#$21
	longa on
	inc	<ptr
	lda	<raw
	adc	#1
	sta	<raw
	lda	<raw+2
	adc	#0
	sta	<raw+2
	dex
	bne	loop
	rts
;
; allocate palette
;
allocpal	ldx	<bitpixel

	lda	<loccolortab
	ora	<loccolortab+2
	beq	ap1

	ldx	<lbitpixel

ap1	stx	!ImagePalSize

	jsl	AllocatePal

	lda	!ImagePal
	pha
	pha
	jsl	TVMM_acquire

	sta	<ptr
	stx	<ptr+2

	lda	!ImagePalSize
	tax
	ldy	#0
	clc
ap2	lda	[<cmap],y
	sta	[<ptr]
	inc	<ptr
	iny
	lda	[<cmap],y	
	sta	[<ptr]
	iny
	iny
	lda	<ptr
	adc	#3
	sta	<ptr
	dex
	bne	ap2

	jsl	TVMM_release

	rts	

;
; ignore an extension
;
ignoreextension lda	[<raw]
	and	#$FF
	beq	igack
	sec		;includes the inc a
	adc	<raw
	sta	<raw
	lda	#0
	adc	<raw+2
	sta	<raw+2
	lda	#1
igack	rts
;
; load a non interlaced image
;
dorawgif	ph4	#LoadStr
	lda	>ImageHeight
	pha
	jsl	OpenThermo

	jsl	AllocateImage

	jsr	allocpal

	lda	[<raw]
	and	#$FF
	sta	<c
	clc
	lda	<raw
	adc	#1
	sta	<raw
	lda	<raw+2
	adc	#0
	sta	<raw+2

	lda	>ImageHeight
	sta	<height                               

	lda	<c
	jsr	LZWReadByte1

	lda	>ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

yloop	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<row
	stx	<row+2

	lda	>ImageWidth
	sta	<width

xloop	jsr	LZWReadByte2	
	sta	<c
	sta	[<row]
	clc
	lda	<row
	adc	#2
	sta	<row
	dec	<width
	bne	xloop

	inc	<image
	inc	<image

	jsl	AdvanceThermo
	jsl	TVMM_release

	dec	<height
	bne	yloop

donegif	jsl	CloseThermo
	jsl	TVMM_release

	FindHandle globcolortab,@ax
	DisposeHandle @xa
	FindHandle loccolortab,@ax
	DisposeHandle @xa
	
done	return
;
; load an interlaced image
;
dointgif	ph4	#LoadStr
	lda	>ImageHeight
	pha
	jsl	OpenThermo

	jsl	AllocateImage

	jsr	allocpal

	lda	[<raw]  
	and	#$FF
	sta	<c
	clc
	lda	<raw
	adc	#1
	sta	<raw
	lda	<raw+2
	adc	#0
	sta	<raw+2

	lda	<c
	jsr	LZWReadByte1

	lda	>ImageHeight
	sta	<height

	lda	>ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2                            

yloop0	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<row
	stx	<row+2

	lda  	>ImageWidth
	sta	<width
xloop0	jsr	LZWReadByte2	
	sta	<c
	sta	[<row]
	clc
	lda	<row
	adc	#2
	sta	<row
	dec	<width
	bne	xloop0
	lda	<image
	adc	#2*8
	sta	<image
	jsl	AdvanceThermo
	jsl	TVMM_release
	lda	<height
	sec
	sbc	#8
	sta	<height
	bmi	done0
	bne	yloop0
done0	anop

	jsl	TVMM_release

	lda	>ImageHeight
	sec
	sbc	#4
	sta	<height
	
	lda	>ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	clc
	adc	#4*2
	sta	<image
	stx	<image+2
	
yloop1	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<row
	stx	<row+2

	lda	>ImageWidth
	sta	<width
xloop1	jsr	LZWReadByte2	
	sta	<c
	sta	[<row]
	clc
	lda	<row
	adc	#2
	sta	<row
	dec	<width
	bne	xloop1
	lda	<image
	adc	#2*8
	sta	<image
	jsl	AdvanceThermo
	jsl	TVMM_release
	lda	<height
	sec
	sbc	#8
	sta	<height
	bmi	done1
	bne	yloop1
done1	anop

	jsl	TVMM_release

	lda	>ImageHeight
	dec	a
	dec	a
	sta	<height

	lda	>ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	clc
	adc	#2*2
	sta	<image
	stx	<image+2                           

yloop2	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<row
	stx	<row+2	

	lda	>ImageWidth
	sta	<width
xloop2	jsr	LZWReadByte2	
	sta	<c
	sta	[<row]
	clc
	lda	<row
	adc	#2
	sta	<row
	dec	<width
	bne	xloop2
	lda	<image
	adc	#4*2
	sta	<image
	jsl	AdvanceThermo
	jsl	TVMM_release
	lda	<height
	sec
	sbc	#4
	sta	<height
	bmi	done2
	bne	yloop2
done2	anop

	jsl	TVMM_release

	lda	>ImageHeight
	dec	a
	sta	<height

	lda	>ImageHandle
	pha
	pha
               jsl	TVMM_acquire
	inc	a
	inc	a
	sta	<image
	stx	<image+2

yloop3	lda	[<image]
	pha
	pha
               jsl	TVMM_acquire
	sta	<row
	stx	<row+2

	lda	>ImageWidth
	sta	<width

xloop3	jsr	LZWReadByte2	
	sta	<c
	sta	[<row]
	clc
	lda	<row
	adc	#2
	sta	<row
	dec	<width
	bne	xloop3
	lda	<image
	adc	#2*2
	sta	<image
	jsl	AdvanceThermo
	jsl	TVMM_release
	lda	<height
	dec	a
	dec	a
	sta	<height
	bmi	done3
	bne	yloop3
done3	anop

	jmp	donegif
;                         
; read an LZWbyte
;
LZWReadByte1	sta	<set_code_size
	inc	a
	sta	<code_size
;	dec	a
	asl	a
	tax
	lda	!bittbl-2,x	;-2 to skip dec
	sta	<clear_code
	inc	a
	tay
	sta	<end_code
	dec	a
	asl	a
	sta	<max_code_size
;	lda	<clear_code
;	inc	a
;	inc	a
;	sta	<max_code
	iny
	sty	<max_code

	jsr	GetCode1
		
freshloop	jsr	GetCode2
	sta	<firstcode
	sta	<oldcode
	cmp	<clear_code
	beq	freshloop
	
	sta	!stack
	lda	#1
	sta	<sp

	lda	<clear_code
	dec	a
	tax
	asl	a
	tay
	txa
clrtab	anop
;	lda	#0
;	sta	!table1,y
;	txa
	sta	!table2,y
;	dex
	dec	a
	dey
	dey
	bpl	clrtab

;	lda	<clear_code
;	asl	a
;	tay
;	lda	#0
;clrtab2	sta	!table1,y
;	iny
;	iny
;	cpy	#4096*2	
;	bne	clrtab2
	
	rts

LZWReadByte2	anop

	ldx	<sp
	beq	getwhile
	dex
	stx	<sp
	lda	!stack,x
	and	#$ff
	rts

getwhile       jsr	GetCode2
	bpl	chkclear
	rts

chkclear       cmp	<clear_code
	bne	noclear

	dec	a
	tay
	asl	a
	tax
	tya
clrtaba	anop
;	stz	!table1,x
;	tya
	sta	!table2,x
	dec	a
	dex
	dex
	sta	!table2,x
	dec	a
;	tay
;	stz	!table1,x
	dex
	dex
	bpl	clrtaba

;	lda	<clear_code
;	asl	a
;	tay
;	lda	#0
;clrtab2a	sta	!table1,y
;	sta	!table2,y
;	iny
;	iny
;	sta	!table1,y
;	sta	!table2,y
;	iny
;	iny
;	cpy	#4096*2	
;	bne	clrtab2a
	
	lda	<set_code_size
	inc	a
	sta	<code_size
	lda	<clear_code
	asl	a
	sta	<max_code_size
	lda	<clear_code
	adc	#2
	sta	<max_code
	stz	<sp
	jsr	GetCode2
	sta	<oldcode
	sta	<firstcode
	rts
       
noclear	cmp	<end_code
	bne	noend
               jsr	ignoreextension
	lda	#-2
	rts

noend	sta	<incode

	ldx	<sp

	cmp	<max_code
	bcc	nopush

	lda	<firstcode
	sta	!stack,x
	inx
	lda	<oldcode

nopush	cmp	<clear_code
	bcc	nopush2
	asl	a
	tay
	lda	!table2,y
	sta	!stack,x
	inx
	lda	!table1,y
	bra	nopush

nopush2	asl	a
	tay
	lda	!table2,y
	sta	<firstcode
	sta	!stack,x
	inx

	lda	<max_code
	cmp	#4096
	bcs	noincsize
	asl	a
	tay
	lda	<oldcode
	sta	!table1,y
	lda	<firstcode
	sta	!table2,y
	inc	<max_code
	lda	<max_code
	cmp	<max_code_size
	bcc	noincsize
	lda	<max_code_size
	cmp	#4096
	bcs	noincsize
	asl	a
	sta	<max_code_size
	inc	<code_size
noincsize	anop

	lda	<incode
	sta	<oldcode

	stx	<sp
		
	jmp	LZWReadByte2
;
; read an LZW code byte
;
GetCode1	lda	#8
	sta	<curbit
	stz	<curbyte
	stz	<last_byte
	stz	<doneflag
	rts

GetCode2	anop	
	
	sec
	lda	<code_size
	sbc	<curbit
	clc
	adc	#8
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	<curbyte
	cmp	<last_byte
	bcc	GetCodeok

	ldx	<last_byte
	lda	!buf-2,x
	sta	!buf
	lda	[<raw]
	inc	<raw
	bne	get0	
	inc	<raw+2
get0	and	#$FF
	bne	get1
               inc	<doneflag
	tay
	bra	get3

get1	ldy	#0
	lsr	a
	tax
	bcc	get2
	lda	[<raw]
	sta	!buf+2
	iny
get2	lda	[<raw],y
	sta	!buf+2,y
	iny
	iny
	dex
	bne	get2

	clc
	tya
	adc	<raw
	sta	<raw
	bcc	get3a
	inc	<raw+2
	
get3	clc
get3a	lda	#2+1
	adc	<curbyte
	sbc	<last_byte
	sta	<curbyte

	iny
	iny
	sty	<last_byte

GetCodeok	lda	<code_size
	asl	a
	tax
	jmp	(getctbl,x)

getctbl	dc	a2'slow'	;0 - ack!
	dc	a2'slow'	;1 - never used?
	dc	a2'slow'	;2 - never used?
	dc	a2'getc3'	;3
	dc	a2'getc4'	;4
	dc	a2'getc5'	;5
	dc	a2'getc6'	;6
	dc	a2'getc7'	;7
	dc	a2'getc8'	;8
	dc	a2'getc9'	;9
	dc	a2'getc10'	;10
	dc	a2'getc11'	;11
	dc	a2'getc12'	;12
	dc	a2'slow'	;13 - never used?
	dc	a2'slow'	;14 - never used?

getc3	lda	<curbit
	asl	a
	tax
	jmp	(getc3tbl-2,x)

getc3tbl	dc	a2'getc3_1'	;1
	dc	a2'getc3_2'	;2
	dc	a2'getc3_3'	;3
	dc	a2'getc3_4'	;4
	dc	a2'getc3_5'	;5
	dc	a2'getc3_6'	;6
	dc	a2'getc3_7'	;7
	dc	a2'getc3_8'	;8

getc3_1	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%11
	asl	a
	ora	!buf,x
	lsr	!buf+1,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	ldx	#6
	stx	<curbit
	rts

getc3_2	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%1
	asl	a
	asl	a
	ora	!buf,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	ldx	#7
	stx	<curbit
	rts

getc3_3	ldx	<curbyte
	lda	!buf,x
	and	#$ff
	inc	<curbyte
	ldx	#8
	stx	<curbit
	rts

getc3_4	anop
getc3_5	anop
getc3_6	anop
getc3_7	anop
getc3_8	ldx	<curbyte
	short	a
	lda	!buf,x
	and	#%111
	tay
	lda	!buf,x
	lsr	a
	lsr	a
	lsr	a
	sta	!buf,x
	rep	#$21
	longa	on
	lda	<curbit
	sbc	#3-1
	sta	<curbit
	tya
	rts	
	
getc4	lda	<curbit
	asl	a
	tax
	jmp	(getc4tbl-2,x)

getc4tbl	dc	a2'getc4_1'	;1
	dc	a2'getc4_2'	;2
	dc	a2'getc4_3'	;3
	dc	a2'getc4_4'	;4
	dc	a2'getc4_5'	;5
	dc	a2'getc4_6'	;6
	dc	a2'getc4_7'	;7
	dc	a2'getc4_8'	;8

getc4_1	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%111
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	ldx	#5
	stx	<curbit
	rts

getc4_2	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%11
	asl	a
	asl	a
	ora	!buf,x
	lsr	!buf+1,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	ldx	#6
	stx	<curbit
	rts

getc4_3	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%1
	asl	a
	asl	a
	asl	a
	ora	!buf,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	ldx	#7
	stx	<curbit
	rts

getc4_4	ldx	<curbyte
	lda	!buf,x
	and	#$ff
	inc	<curbyte
	ldx	#8
	stx	<curbit
	rts

getc4_5	anop
getc4_6	anop
getc4_7	anop
getc4_8	ldx	<curbyte
	short	a
	lda	!buf,x
	and	#%1111
	tay
	lda	!buf,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf,x
	rep	#$21
	longa	on
	lda	<curbit
	sbc	#4-1
	sta	<curbit
	tya
	rts	
                             
getc5	lda	<curbit
	asl	a
	tax
	jmp	(getc5tbl-2,x)

getc5tbl	dc	a2'getc5_1'	;1
	dc	a2'getc5_2'	;2
	dc	a2'getc5_3'	;3
	dc	a2'getc5_4'	;4
	dc	a2'getc5_5'	;5
	dc	a2'getc5_6'	;6
	dc	a2'getc5_7'	;7
	dc	a2'getc5_8'	;8

getc5_1	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%1111
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	ldx	#4
	stx	<curbit
	rts

getc5_2	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%111
	asl	a
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	ldx	#5
	stx	<curbit
	rts

getc5_3	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%11
	asl	a
	asl	a
	asl	a
	ora	!buf,x
	lsr	!buf+1,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	ldx	#6
	stx	<curbit
	rts

getc5_4	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%1
	asl	a
	asl	a
	asl	a
	asl	a
	ora	!buf,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	ldx	#7
	stx	<curbit
	rts

getc5_5	ldx	<curbyte
	lda	!buf,x
	and	#$ff
	inc	<curbyte
	ldx	#8
	stx	<curbit
	rts

getc5_6	anop
getc5_7	anop
getc5_8	ldx	<curbyte
	short	a
	lda	!buf,x
	and	#%11111
	tay
	lda	!buf,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf,x
	rep	#$21
	longa	on
	lda	<curbit
	sbc	#5-1
	sta	<curbit
	tya
	rts	
                             
getc6	lda	<curbit
	asl	a
	tax
	jmp	(getc6tbl-2,x)

getc6tbl	dc	a2'getc6_1'	;1
	dc	a2'getc6_2'	;2
	dc	a2'getc6_3'	;3
	dc	a2'getc6_4'	;4
	dc	a2'getc6_5'	;5
	dc	a2'getc6_6'	;6
	dc	a2'getc6_7'	;7
	dc	a2'getc6_8'	;8

getc6_1	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%11111
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	ldx	#3
	stx	<curbit
	rts

getc6_2	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%1111
	asl	a
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	ldx	#4
	stx	<curbit
	rts

getc6_3	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%111
	asl	a
	asl	a
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	ldx	#5
	stx	<curbit
	rts

getc6_4	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%11
	asl	a
	asl	a
	asl	a
	asl	a
	ora	!buf,x
	lsr	!buf+1,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	ldx	#6
	stx	<curbit
	rts

getc6_5	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%1
	lsr	a
	ror	a
	ror	a
	ror	a
	ora	!buf,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	ldx	#7
	stx	<curbit
	rts

getc6_6	ldx	<curbyte
	lda	!buf,x
	and	#$ff
	inc	<curbyte
	ldx	#8
	stx	<curbit
	rts

getc6_7	anop
getc6_8	ldx	<curbyte
	short	a
	lda	!buf,x
	and	#%111111
	tay
	lda	!buf,x
	asl	a
	rol	a
	rol	a
	and	#%11
	sta	!buf,x
	rep	#$21
	longa	on
	lda	<curbit
	sbc	#6-1
	sta	<curbit
	tya
	rts	
                             
getc7	lda	<curbit
	asl	a
	tax
	jmp	(getc7tbl-2,x)

getc7tbl	dc	a2'getc7_1'	;1
	dc	a2'getc7_2'	;2
	dc	a2'getc7_3'	;3
	dc	a2'getc7_4'	;4
	dc	a2'getc7_5'	;5
	dc	a2'getc7_6'	;6
	dc	a2'getc7_7'	;7
	dc	a2'getc7_8'	;8

getc7_1	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%111111
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	asl	a
	rol	a
	rol	a
	and	#%11
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	inc	<curbit
	rts

getc7_2	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%11111
	asl	a
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	ldx	#3
	stx	<curbit
	rts

getc7_3	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%1111
	asl	a
	asl	a
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	inc	<curbit
	rts

getc7_4	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%111
	asl	a
	asl	a
	asl	a
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	inc	<curbit
	rts

getc7_5	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%11
	lsr	a
	ror	a
	ror	a
	ror	a
	ora	!buf,x
	lsr	!buf+1,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	inc	<curbit
	rts

getc7_6	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%1
	lsr	a
	ror	a
	ror	a
	ora	!buf,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	inc	<curbit
	rts

getc7_7	ldx	<curbyte
	lda	!buf,x
	and	#$ff
	inc	<curbyte
	inc	<curbit
	rts

getc7_8	ldx	<curbyte
	short	a
	lda	!buf,x
	and	#%1111111
	tay
	lda	!buf,x
	asl	a
	rol	a
	and	#%1
	sta	!buf,x
	tya
	long	a
	ldx	#1
	stx	<curbit
	rts	
                             
getc8	lda	<curbit
	asl	a
	tax
	jmp	(getc8tbl-2,x)

getc8tbl	dc	a2'getc8_1'	;1
	dc	a2'getc8_2'	;2
	dc	a2'getc8_3'	;3
	dc	a2'getc8_4'	;4
	dc	a2'getc8_5'	;5
	dc	a2'getc8_6'	;6
	dc	a2'getc8_7'	;7
	dc	a2'getc8_8'	;8

getc8_1	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%1111111
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	asl	a
	rol	a
	and	#%1
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	rts

getc8_2	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%111111
	asl	a
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	asl	a
	rol	a
	rol	a
	and	#%11
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	rts

getc8_3	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%11111
	asl	a
	asl	a
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	rts

getc8_4	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%1111
	asl	a
	asl	a
	asl	a
	asl	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	rts

getc8_5	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%111
	lsr	a
	ror	a
	ror	a
	ror	a
	ora	!buf,x
	tay
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	rts

getc8_6	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%11
	lsr	a
	ror	a
	ror	a
	ora	!buf,x
	lsr	!buf+1,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	rts

getc8_7	ldx	<curbyte
	short	a
	lda	!buf+1,x
	and	#%1
	lsr	a
	ror	a
	ora	!buf,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	rts

getc8_8	ldx	<curbyte
	lda	!buf,x
	and	#$ff
	inc	<curbyte
	rts

getc9	lda	<curbit
	asl	a
	tax
	jmp	(getc9tbl-2,x)

getc9tbl	dc	a2'getc9_1'	;1
	dc	a2'getc9_2'	;2
	dc	a2'getc9_3'	;3
	dc	a2'getc9_4'	;4
	dc	a2'getc9_5'	;5
	dc	a2'getc9_6'	;6
	dc	a2'getc9_7'	;7
	dc	a2'getc9_8'	;8

getc9_1	ldx	<curbyte
	lda	!buf,x
	lsr	a
	lda	!buf+1,x
	and	#$ff
	rol	a
	inx
	inx
	stx	<curbyte
	ldx	#8
	stx	<curbit	
	rts

getc9_2	ldx	<curbyte
	lda	!buf+1,x
	and	#%1111111
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	asl	a
	rol	a
	and	#%1
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	dec	<curbit
	rts

getc9_3	ldx	<curbyte
	lda	!buf+1,x
	and	#%111111
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	asl	a
	rol	a
	rol	a
	and	#%11
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	dec	<curbit
	rts

getc9_4	ldx	<curbyte
	lda	!buf+1,x
	and	#%11111
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	dec	<curbit
	rts

getc9_5	ldx	<curbyte
	lda	!buf+1,x
	and	#%1111
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	dec	<curbit
	rts

getc9_6	ldx	<curbyte
	lda	!buf+1,x
	and	#%111
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	dec	<curbit
	rts

getc9_7	ldx	<curbyte
	lda	!buf+1,x
	and	#%11
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	short	a
	lsr	!buf+1,x
	lsr	!buf+1,x
	ora	!buf,x
	long	a
	inc	<curbyte
	dec	<curbit
	rts

getc9_8	ldx	<curbyte
	lda	!buf,x
	and	#%111111111
	short	a
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	dec	<curbit
	rts

getc10	lda	<curbit
	asl	a
	tax
	jmp	(getc10tbl-2,x)

getc10tbl	dc	a2'getc10_1'	;1
	dc	a2'getc10_2'	;2
	dc	a2'getc10_3'	;3
	dc	a2'getc10_4'	;4
	dc	a2'getc10_5'	;5
	dc	a2'getc10_6'	;6
	dc	a2'getc10_7'	;7
	dc	a2'getc10_8'	;8

getc10_1	ldx	<curbyte
	lda	!buf+1,x
	and	#%111111111
	asl	a
	short	a
	lsr	!buf+2,x
	ora	!buf,x
	long	a
	inx
	inx
	stx	<curbyte
	ldx	#7
	stx	<curbit
	rts

getc10_2	ldx	<curbyte
	lda	!buf+1,x
	and	#%11111111
	asl	a
	asl	a
	short	a
	ora	!buf,x
	long	a
	inx
	inx
	stx	<curbyte
	ldx	#8
	stx	<curbit
	rts

getc10_3	ldx	<curbyte
	lda	!buf+1,x
	and	#%1111111
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	asl	a
	rol	a
	and	#%1
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#1
	stx	<curbit
	rts

getc10_4	ldx	<curbyte
	lda	!buf+1,x
	and	#%111111
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	asl	a
	rol	a
	rol	a
	and	#%11
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#2
	stx	<curbit
	rts

getc10_5	ldx	<curbyte
	lda	!buf+1,x
	and	#%11111
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#3
	stx	<curbit
	rts

getc10_6	ldx	<curbyte
	lda	!buf+1,x
	and	#%1111
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#4
	stx	<curbit
	rts

getc10_7	ldx	<curbyte
	lda	!buf+1,x
	and	#%111
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#5
	stx	<curbit
	rts

getc10_8	ldx	<curbyte
	lda	!buf,x
	and	#%1111111111
	short	a
	lsr	!buf+1,x
	lsr	!buf+1,x
	long	a
	inc	<curbyte
	ldx	#6
	stx	<curbit
	rts

getc11	lda	<curbit
	asl	a
	tax
	jmp	(getc11tbl-2,x)

getc11tbl	dc	a2'getc11_1'	;1
	dc	a2'getc11_2'	;2
	dc	a2'getc11_3'	;3
	dc	a2'getc11_4'	;4
	dc	a2'getc11_5'	;5
	dc	a2'getc11_6'	;6
	dc	a2'getc11_7'	;7
	dc	a2'getc11_8'	;8

getc11_1	ldx	<curbyte
	lda	!buf+1,x
	and	#%1111111111
	asl	a
	short	a
	lsr	!buf+2,x
	lsr	!buf+2,x
	ora	!buf,x
	long	a
	inx
	inx
	stx	<curbyte
	ldx	#6
	stx	<curbit
	rts

getc11_2	ldx	<curbyte
	lda	!buf+1,x
	and	#%111111111
	asl	a
	asl	a
	short	a
	lsr	!buf+2,x
	ora	!buf,x
	long	a
	inx
	inx
	stx	<curbyte
	ldx	#7
	stx	<curbit
	rts

getc11_3	ldx	<curbyte
	lda	!buf+1,x
	and	#%11111111
	asl	a
	asl	a
	asl	a
	short	a
	ora	!buf,x
	long	a
	inx
	inx
	stx	<curbyte
	ldx	#8
	stx	<curbit
	rts

getc11_4	ldx	<curbyte
	lda	!buf+1,x
	and	#%1111111
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	asl	a
	rol	a
	and	#%1
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#1
	stx	<curbit
	rts

getc11_5	ldx	<curbyte
	lda	!buf+1,x
	and	#%111111
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	asl	a
	rol	a
	rol	a
	and	#%11
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#2
	stx	<curbit
	rts

getc11_6	ldx	<curbyte
	lda	!buf+1,x
	and	#%11111
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#3
	stx	<curbit
	rts

getc11_7	ldx	<curbyte
	lda	!buf+1,x
	and	#%1111
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#4
	stx	<curbit
	rts

getc11_8	ldx	<curbyte
	lda	!buf,x
	and	#%11111111111
	tay
	short	a
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	long	a
	inc	<curbyte
	ldx	#5
	stx	<curbit
	rts

getc12	lda	<curbit
	asl	a
	tax
	jmp	(getc12tbl-2,x)

getc12tbl	dc	a2'getc12_1'	;1
	dc	a2'getc12_2'	;2
	dc	a2'getc12_3'	;3
	dc	a2'getc12_4'	;4
	dc	a2'getc12_5'	;5
	dc	a2'getc12_6'	;6
	dc	a2'getc12_7'	;7
	dc	a2'getc12_8'	;8

getc12_1	ldx	<curbyte
	lda	!buf+1,x
	and	#%11111111111
	asl	a
	tay
	short	a
	lda	!buf+2,x
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+2,x
	tya
	ora	!buf,x
	long	a
	inx
	inx
	stx	<curbyte
	ldx	#5
	stx	<curbit
	rts

getc12_2	ldx	<curbyte
	lda	!buf+1,x
	and	#%1111111111
	asl	a
	asl	a
	short	a
	lsr	!buf+2,x
	lsr	!buf+2,x
	ora	!buf,x
	long	a
	inx
	inx
	stx	<curbyte
	ldx	#6
	stx	<curbit
	rts

getc12_3	ldx	<curbyte
	lda	!buf+1,x
	and	#%111111111
	asl	a
	asl	a
	asl	a
	short	a
	lsr	!buf+2,x
	ora	!buf,x
	long	a
	inx
	inx
	stx	<curbyte
	ldx	#7
	stx	<curbit
	rts

getc12_4	ldx	<curbyte
	lda	!buf+1,x
	and	#%11111111
	asl	a
	asl	a
	asl	a
	asl	a
	short	a
	ora	!buf,x
	long	a
	inx
	inx
	stx	<curbyte
	ldx	#8
	stx	<curbit
	rts

getc12_5	ldx	<curbyte
	lda	!buf+1,x
	and	#%1111111
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	asl	a
	rol	a
	and	#%1
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#1
	stx	<curbit
	rts

getc12_6	ldx	<curbyte
	lda	!buf+1,x
	and	#%111111
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	asl	a
	rol	a
	rol	a
	and	#%11
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#2
	stx	<curbit
	rts

getc12_7	ldx	<curbyte
	lda	!buf+1,x
	and	#%11111
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	short	a
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#3
	stx	<curbit
	rts

getc12_8	ldx	<curbyte
	lda	!buf,x
	and	#%111111111111
	tay
	short	a
	lda	!buf+1,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!buf+1,x
	tya
	ora	!buf,x
	long	a
	inc	<curbyte
	ldx	#4
	stx	<curbit
	rts

slow	lda	#0       

	ldy	<code_size
	ldx	<curbyte
gcloop         short	a
	lsr	!buf,x
	long	a
	ror	a
gcnext         dec	<curbit
	bne	gcnext2
	ldx	#8
	stx	<curbit
	inc	<curbyte
	ldx	<curbyte
gcnext2	dey
	bne	gcloop

	stx	<curbyte

	ldy	<code_size
	cpy	#16
	bcs	gcexit

gcdone	lsr	a
	iny
	cpy	#16
	bcc	gcdone
	
gcexit	rts

buf	ds	280
table1	ds	4096*2
table2	ds	4096*2
stack	ds	4096*2

errmsg	dc	c'The picture is not a GIF.',h'00'

bittbl	dc	i2'1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192'
	dc	i2'16384,32768'

LoadStr	dc	c'Loading GIF Image...',h'00'
                      
	END
