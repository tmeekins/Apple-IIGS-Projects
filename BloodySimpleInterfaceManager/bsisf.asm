**************************************************************************
*
* The Bloody Simple Interface Manager
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* bsisf.asm
*
* Standard File dialog
*
**************************************************************************

	mcopy	m/bsisf.mac

	copy	bsi.h

;--------------------------------------------------------------------
; BSI_getsf
;   standard file dialog box for loading files
;
;--------------------------------------------------------------------

BSI_getsf	START	bsi

	using	SFdata

space	equ	1     

	subroutine (4:str,4:callback),space

	lda	<callback
	sta	!filecb
	lda	<callback+2
	sta	!filecb+2

	stz	!filelistptr
	stz	!filelistptr+2
	stz	!filelength
	stz	!filemode

	ph4	#sfwindow
	jsl	BSI_addevent

	ldx	#17
	ldy	#5
	jsl	BSI_gotoxy
	pei	(<str+2)
	pei	(<str)
	jsl	BSI_writestring

	jsl	BSI_updsf

	ph4	#cancelbutton
	jsl	BSI_addevent
	ph4	#closebutton
	jsl	BSI_addevent
	ph4	#openbutton
	jsl	BSI_addevent
	ph4	#volumebutton
	jsl	BSI_addevent
	ph4	#filelist
	jsl	BSI_addevent
                                              
	return

	END

;----------------------------------------------------------
; BSI_updsf
;   update the standard file
;-------------------------------------------------------

BSI_updsf	PRIVATE bsi

	using	BSI_data
	using	SFdata

idx1	equ	1
idx2	equ	idx1+2
p	equ	idx2+2
str	equ	p+4
listsize	equ	str+4
numleft	equ	listsize+2
list	equ	numleft+2
bufptr	equ	list+4
bufhand	equ	bufptr+4
space	equ	bufhand+4

	subroutine (0:dummy),space

	jsl	freefilelist

	lda	!filemode
	jeq	files

	ldx	#17
	ldy	#7
	jsl	BSI_gotoxy

	ph4	#volstr
	pea	48
	jsl	BSI_writenstring

; read the volume names

	NewHandle (#128*4,MMID,#$C018,#0),list
	ldy	#2
	lda	[<list],y
	tax
	lda	[<list]
	sta	<list
	stx	<list+2

	stz	<listsize

	lda	#1
	sta	!devnum	
devloop	DInfo	diparm
	jcs	lastdev

	Volume volparm
	jcs	nextdev

	lda	!volname1
	clc
	adc	#3+1
	ldx	#0
	NewHandle (@xa,MMID,#$C018,#0),str
	ldy	#2
	lda	[<str],y
	tax
	lda	[<str]
	clc	
	adc	#3
	sta	<str
	stx	<str+2

	ldy	!volname1
	short	a
	lda	#0
	sta	[<str],y
	dey
devcopy	lda	!volname2,y
	sta	[<str],y
	dey
	bpl	devcopy
	long	a

	lda	<str
	sec
	sbc	#3
	sta	<str

	short	a
	lda	#' '
	sta	[<str]
	ldy	#1
	sta	[<str],y
	iny
	sta	[<str],y
	long	a

	lda	<listsize
	asl	a
	asl	a
	tay
	lda	<str
	sta	[<list],y
	iny
	iny
	lda	<str+2
	sta	[<list],y
	inc	<listsize

nextdev	inc	!devnum
	jmp	devloop

lastdev	anop

	jmp	sort
     
; show files, not files

files	NewHandle (#516,MMID,#$C018,#0),bufhand

	lda	[<bufhand]
	sta	<bufptr
	sta	!gpbuf
	sta	!gdname
	ldy	#2
	lda   [<bufhand],y
	sta	<bufptr+2
	sta	!gpbuf+2
	sta	!gdname+2

	lda	#512
	sta	[<bufptr]

	GetPrefix gpparm

	ldy	#2
	lda	[<bufptr],y
	clc
	adc	#4
	tay
	lda	#0
	sta	[<bufptr],y

; display the path

	ldx	#17
	ldy	#7
	jsl	BSI_gotoxy

	lda	<bufptr+2
	sta	<p+2
	pha
	lda	<bufptr
	adc	#4
	sta	<p
	pha
	pea	48
	jsl	BSI_writenstring

; open this prefix for reading

	lda	<bufptr+2
	sta	!openname+2
	lda	<bufptr
	inc	a
	inc	a
	sta	!openname

	Open	openparm

; see how many entries there are

	stz	<listsize
	stz	<list
	stz	<list+2

	lda	!openref
	sta	!gdref
	sta	!closeref
	stz	!gdbase
	stz	!gddisp

	GetDirEntry gdparm

	lda	#1
	sta	!gdbase
	sta	!gddisp

	lda	!gdentry
	jeq	neardone
	sta	<numleft	;maximum entries
	inc	a
	asl	a
	asl	a
	ldx	#0

	NewHandle (@xa,MMID,#$C018,#0),list
	ldy	#2
	lda	[<list],y
	tax
	lda	[<list]
	sta	<list
	stx	<list+2

; read in each entry one at a time

dirloop	GetDirEntry gdparm
	
	lda	!gdaccess
	bit	#%0000000000000100	; invisible bit
	jne	nextentry
	bit	#%0000000000000001	; read bit
	jeq	nextentry

	ldy	#2
	lda	[<bufptr],y
	clc
	adc	#4
	ldx	#0
	NewHandle (@xa,MMID,#$C018,#0),str
	ldy	#2
	lda	[<str],y
	tax
	lda	[<str]
	clc	
	adc	#3
	sta	<str
	stx	<str+2

               ldy	#2
	lda	[<bufptr],y
	tay
	short	a
	lda	#0
	sta	[<str],y
	dey
copy	lda	[<p],y
	sta	[<str],y
	dey
	bpl	copy
	long	a

	lda	<str
	sec
	sbc	#3
	sta	<str

	short	a
	lda	#' '
	sta	[<str]
	ldy	#1
	sta	[<str],y
	iny
	sta	[<str],y
	long	a

	lda	!gdfiletype
	cmp	#$0f
	bne	skipdir

	short	a
	lda	#1
	sta	[<str]
	inc	a
	dey
	sta	[<str],y
	long	a

skipdir	anop

	lda	<listsize
	asl	a
	asl	a
	tay
	lda	<str
	sta	[<list],y
	iny
	iny
	lda	<str+2
	sta	[<list],y
	inc	<listsize

nextentry	dec	<numleft
	jne	dirloop

	Close closeparm

neardone	DisposeHandle bufhand

; sort the files

sort	lda	<listsize
	beq	done	

	stz	<idx1

outer	stz	<idx2

inner	lda	<idx1
	asl	a
	asl	a
	tay
	lda	[<list],y
	tax
	iny
	iny
	lda	[<list],y
	pha
	phx
	lda	<idx2
	asl	a
	asl	a
	tay
	lda	[<list],y
	tax
	iny
	iny
	lda	[<list],y
	pha
	phx
	jsr	cmpcstr
	beq	noswap
	bpl	noswap

	lda	<idx1
	asl	a
	asl	a
	tay
	phy
	lda	[<list],y
	sta	<str
	iny
	iny
	lda	[<list],y
	sta	<str+2
	lda	<idx2
	asl	a
	asl	a
	tay
	lda	[<list],y
	sta	<p
	lda	<str
	sta	[<list],y
	iny
	iny
	lda	[<list],y
	sta	<p+2
	lda	<str+2
	sta	[<list],y
	ply
	lda	<p
	sta	[<list],y
	iny
	iny
	lda	<p+2
	sta	[<list],y

noswap	inc	<idx2
	lda	<idx2
	cmp	<listsize
	bcc	inner

	inc	<idx1
	lda	<idx1
	cmp	<listsize
	bcc	outer	

done	lda	<listsize
	asl	a
	asl	a
	tay
	lda	#0
	sta	[<list],y	
	iny
	iny
	sta	[<list],y

	lda	<listsize
	sta	!filelength
	lda	<list
	sta   !filelistptr
	lda	<list+2
	sta	!filelistptr+2

	return         

gpparm	dc	i2'2'	;pCount
	dc	i2'8'	;prefix 8
gpbuf	dc	i4'0'	;prefix

openparm	dc	i2'2'	;pCount
openref	dc	i2'0'              ;refNum
openname	dc	i4'0'	;pathname

gdparm	dc	i2'12'	;pCount
gdref	dc	i2'0'	;refnum
	dc	i2'0'	;flags
gdbase	dc	i2'0'	;base
gddisp	dc	i2'0'	;displacement
gdname	dc	i4'0'	;name ptr
gdentry	dc	i2'0'	;entryNum
gdfiletype	dc	i2'0'	;fileType
	dc	i4'0'	;eof
	dc	i4'0'	;block count
	dc	2i4'0'	;create date time
	dc	2i4'0'	;mod date time
gdaccess	dc	i2'0'	;access

closeparm	dc	i2'1'	;pCount
closeref	dc	i2'0'	;refNum

diparm	dc	i2'2'	;pCount
devnum	dc	i2'0'	;devNum
	dc	i4'devname'	;devName

volparm	dc	i2'2'	;pCount
	dc	i4'devname1'	;devName
	dc	i4'volname'	;volName

devname	dc	i2'33'
devname1	ds	2
devname2	ds	31

volname	dc	i2'33'
volname1	ds	2
volname2	ds	31

volstr	dc	c'Volumes On-Line:',i1'0'

	END

;----------------------------------------------------------
; cancelCallback
;   cancel button was pressed in getsf
;----------------------------------------------------------

cancelCallback PRIVATE bsi

	using	SFdata

space	equ	1

	subroutine (2:action),space

	jsl	freefilelist

	ph4	#sfwindow
	jsl	BSI_deleteevent

	return

	END

;----------------------------------------------------------
; volumeCallback
;   volume button was pressed in getsf
;----------------------------------------------------------

volumeCallback PRIVATE bsi

	using	SFdata

space	equ	1

	subroutine (2:action),space

	lda	#1
	sta	!filemode

	stz	!filefirst
	stz	!filesel

	jsl	BSI_updsf

	ph4	#filelist
	jsl	BSI_drawevent

	return

	END

;----------------------------------------------------------
; closeCallback
;   close button was pressed in getsf
;----------------------------------------------------------

closeCallback PRIVATE bsi

space	equ	1

	subroutine (2:action),space

	jsl	backup

	return

	END

;----------------------------------------------------------
; openCallback
;   open button was pressed in getsf
;----------------------------------------------------------

openCallback PRIVATE bsi

space	equ	1

	subroutine (2:action),space

	jsl	select

	return

	END

;----------------------------------------------------------
; backup
;   backup one directory
;----------------------------------------------------------

backup	PRIVATE bsi

	using	SFdata
	using	BSI_data

ptr	equ	1
hand	equ	ptr+4
space	equ	hand+4

	subroutine (0:dummy),space

; can't back up from volumes

	lda	!filemode
	jne	done

	NewHandle (#516,MMID,#$C018,#0),hand

	lda	[<hand]
	sta	<ptr
	sta	!gpbuf
	ldy	#2
	lda   [<hand],y
	sta	<ptr+2
	sta	!gpbuf+2

	lda	#512
	sta	[<ptr]

	lda	#8
	sta	!pfxnum
	GetPrefix gpparm
	bcs	almostdone

; from end of path, search for previous separator

	ldy	#2
	lda	[<ptr],y
	tay
	clc
	lda	<ptr
	adc	#4
	sta	<ptr
	
	dey
	short	a
	lda	[<ptr],y	;this is the separator
loop	dey
	bmi	volume
	cmp	[<ptr],y
	bne	loop
	long	a

	cpy	#0
	beq	volume

	sec
	lda	<ptr
	sbc	#2
	sta	<ptr
	tya
	sta	[<ptr]

	lda	!gpbuf
	clc
	adc	#2
	sta	!gpbuf

	lda	#8
	sta	!pfxnum
	SetPrefix gpparm
	stz	!pfxnum
	SetPrefix gpparm

	bra	finished

volume	lda	#1
	sta	!filemode

finished	stz	!filefirst
	stz	!filesel

	jsl	BSI_updsf

	ph4	#filelist
	jsl	BSI_drawevent

almostdone	DisposeHandle hand

done	return

gpparm	dc	i2'2'	;pCount
pfxnum	dc	i2'8'	;prefix 8
gpbuf	dc	i4'0'	;prefix

	END     

;----------------------------------------------------------
; select
;   select an item
;----------------------------------------------------------

select	PRIVATE bsi

	using	SFdata
	using	BSI_data

hand	equ	1
file	equ	hand+4
ptr	equ	file+4
list	equ	ptr+4
space	equ	list+4

	subroutine (0:dummy),space

	lda	!filelistptr
	sta	<list
	lda	!filelistptr+2
	sta	<list+2
	ora	<list
	jeq	done

	lda	!filelength
	jeq	done

	lda	!filesel
	asl	a
	asl	a
	tay
	lda	[<list],y	
	sta	<file
	iny
	iny
	lda	[<list],y
	sta	<file+2

	lda	!filemode
	jeq	files

; select a volume

	lda	<file
	clc
	adc	#3
	sta	<file

	ph4	file
	jsr	cstrlen
	pha	

	clc
	adc	#4
	ldx	#0
	NewHandle (@xa,MMID,#$C018,#0),hand
	lda	[<hand]
	sta	<ptr
	ldy	#2
	lda	[<hand],y
	sta	<ptr+2

	pla
	sta	[<ptr]

	clc
	lda	<ptr
	adc	#2
	sta	<ptr

	ldy	#0
	short	a
loop1	lda	[<file],y
	beq	end1
	sta	[<ptr],y
	iny
	bra	loop1
end1	long	a

	sec
	lda	<ptr
	sbc	#2
	ldx	<ptr+2	

	sta	!spbuf
	stx	!spbuf+2

	lda	#8
	sta	!pfxnum
	SetPrefix spparm
	stz	!pfxnum
	SetPrefix spparm

	DisposeHandle hand

	stz	!filemode

	jmp	finished

; select a file

files	lda	[<file]
	and	#$ff
	cmp	#1
	beq	dir

	clc
	lda	<file
	adc	#3

	pei	(<file+2)
	pha
	jsr	cstrlen

	inc	<file
	sta	[<file]

	lda	!filecb
	sta	!gocb+1
	lda	!filecb+1
	sta	!gocb+2

	ph4	#sfwindow
	jsl	BSI_deleteevent

	pei	(<file+2)
	pei	(<file)

gocb	jsl	$ffffff

	jsl	freefilelist

	jmp	done

; selected a directory

dir	lda	<file
	clc
	adc	#3
	sta	<file

	NewHandle (#516,MMID,#$C018,#0),hand

	lda	[<hand]
	sta	<ptr
	sta	!spbuf
	ldy	#2
	lda   [<hand],y
	sta	<ptr+2
	sta	!spbuf+2

	lda	#512
	sta	[<ptr]

	lda	#8
	sta	!pfxnum
	GetPrefix spparm

	ldy	#2
	lda	[<ptr],y
	tay
	lda	<ptr
	clc
	adc	#4
	sta	<ptr

	short	a

loop2	lda	[<file]
	beq	end2
	sta	[<ptr],y
	iny
	inc	<file
	bne   loop2
	inc	<file+1
	bra	loop2

end2	long	a

	lda	<ptr
	sec
	sbc	#2
	sta	<ptr
	sta	!spbuf
	tya
	sta	[<ptr]

	lda	#8
	sta	!pfxnum
	SetPrefix spparm
	stz	!pfxnum
	SetPrefix spparm
                               
	DisposeHandle hand

finished	stz	!filefirst
	stz	!filesel

	jsl	BSI_updsf

	ph4	#filelist
	jsl	BSI_drawevent

done	return

spparm	dc	i2'2'	;pCount
pfxnum	dc	i2'8'	;prefix 8
spbuf	dc	i4'0'	;prefix

	END   

;----------------------------------------------------------
; freefilelist
;   free memory used by the filelist
;----------------------------------------------------------

freefilelist	PRIVATE bsi

	using	SFdata

p	equ	1
space	equ	p+4

	subroutine (0:dummy),space

	lda	!filelistptr
	ora	!filelistptr+2
	beq	done

	lda	!filelistptr
	sta	<p
	lda	!filelistptr+2
	sta	<p+2
	
loop	lda	!filelength
	beq	cont
	bmi	cont
	dec	a
	sta	!filelength
	asl	a
	asl	a
	tay
	lda	[<p],y
	tax
	iny
	iny
	lda	[<p],y
	FindHandle @ax,@ax
	DisposeHandle @xa
	bra	loop

cont	FindHandle p,@ax
	DisposeHandle @xa

	stz	!filelistptr
	stz	!filelistptr+2
	stz	!filelength

done	return

	END

;=========================================================================
;
; Compare two c strings. Return 0 if equal, -1 if less than, +1 greater
;
;=========================================================================

cmpcstr        START	bsi

space          equ   1
q              equ   space+2
p              equ   q+4
end            equ   p+4

               tsc
               phd
               tcd

               short a

               ldx   #0
               
               ldy   #0
strloop        lda	[<q],y
	jsr	tolower
	sta	!char
	lda   [<p],y
               beq   strchk
	jsr	tolower
               cmp   !char
               bne   notequal
               iny
               bra   strloop

strchk         lda   !char
               beq   done

lessthan	dex
	bra	done

notequal	bcc	lessthan
	inx

done           rep	#$21
	longa	on
               lda   space
               sta   end-2
               pld
               tsc
               adc   #end-3
               tcs

               txa
               rts

char	ds	2

               END

;=========================================================================
;
; Convert the accumulator to lower case.
;
;=========================================================================

tolower        START	bsi

	longa	off

	cmp	#'A'
	bcc	done
	cmp	#'Z'+1
	bcs	done
	adc	#'a'-'A'
done	rts

	longa on

               END

;=========================================================================
;
; Get the length of a c string.
;
;=========================================================================

cstrlen        START	bsi

space          equ   1
p              equ   space+2
end            equ   p+4

               tsc
               phd
               tcd

               short a

               ldy   #0
loop           lda   [p],y
               beq   done
               iny
               bra   loop

done           rep	#$21
	longa	on
               lda   space
               sta   end-2
               pld
               tsc
               adc   #end-3
               tcs

               tya

               rts

               END

;--------------------------------------------------
; SFdata
;    data used by standard file
;--------------------------------------------------

SFdata	PRIVDATA bsi
;
; standard file window
;
sfwindow	dc	i2'E_window'	;window type
	dc	i4'0'	;next
	dc	i4'0'	;prev
	dc	i2'F_blockevent'	;flags
	dc	i4'0'	;key list
	dc	i4'0'	;about callback
               dc	i4'sfrect'	;rectangle
	dc	i4'0'	;save handles
sfrect 	dc	i2'15*8,4*8,65*8,21*8'
;
; Cancel button
;
cancelbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'cancelkey'	;key list
	dc	i4'cancelCallback' ;button callback
	dc	i4'cancelrect'   	;button rectangle
	dc	i4'canceltext'    ;button text
cancelrect	dc    i2'53*8-3,19*8-3,63*8+1,20*8+1'
canceltext	dc	i1'55,19',c'Cancel',h'00'
cancelkey	dc	i1'$2E+$80,00'	;OA-.
;
; Close button
;
closebutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'closekey'	;key list
	dc	i4'closecallback' 	;button callback
	dc	i4'closerect'   	;button rectangle
	dc	i4'closetext'    	;button text
closerect	dc    i2'53*8-3,15*8-3,63*8+1,16*8+1'
closetext	dc	i1'56,15',c'Close',h'00'
closekey	dc	i1'$1B,$57+$80,$77+$80,00'	;ESC, OA-W, OA-w
;
; Open button
;
openbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'openkey'	;key list
	dc	i4'opencallback' 	;button callback
	dc	i4'openrect'   	;button rectangle
	dc	i4'opentext'    	;button text
openrect	dc    i2'53*8-3,13*8-3,63*8+1,14*8+1'
opentext	dc	i1'56,13',c'Open',h'00'
openkey	dc	i1'$0D,$4F+$80,$6F+$80,$80,00'	;CR, OA-O, OA-o, Double-Click
;
; Volume button
;
volumebutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'volumekey'	;key list
	dc	i4'volumeCallback' ;button callback
	dc	i4'volumerect'   	;button rectangle
	dc	i4'volumetext'    	;button text
volumerect	dc    i2'53*8-3,9*8-3,63*8+1,10*8+1'
volumetext	dc	i1'54,9',c'Volumes',h'00'
volumekey	dc	i1'$09,$56+$80,$76+$80,00'	;TAB, OA-V, OA-v
;
; File list
;
filelist	dc	i2'E_list'	;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'0'	;key list
	dc	i4'0' 	;button callback
	dc	i4'filerect'   	;button rectangle
	dc	i1'17,9'	;first position
	dc	i2'11'	;number of visible items
filefirst	dc	i2'0'	;first item
filesel	dc	i2'0'	;selected item
filelistptr	dc	i4'0'	;pointer to list
	dc	i2'29'	;width
filelength	dc	i2'0'	;length
filerect	dc    i2'17*8-3,9*8-3,46*8+1,21*8+1'
;
; more variables
;
filemode	ds	2	;0=files, 1=volumes
filecb	ds	4	;sf callback
       
	END
