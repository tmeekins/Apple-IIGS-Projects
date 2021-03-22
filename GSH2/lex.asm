***********************************************************************
* CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL CONFIDENTIAL *
***********************************************************************
                                                                       
**************************************************************************
*                            
* GNO/Shell 2.0
* lexical analysis routines for scripting and command execution
*
* Written by Tim Meekins and Jawaid Bazyar
* Copyright (C) 1993 by Tim Meekins & Procyon Enterprises, Inc.
*
**************************************************************************

	keep	o/lex
	mcopy	m/lex.mac
	copy	lex.inc
	copy	error.inc

**************************************************************************
*
* freetoklist
*     - deallocates a list of tokens
*
* entry:
*     ph4 tok	      - head of token list
*
**************************************************************************

freetoklist	START

space	equ	1
tok	equ	space+2
end	equ	tok+4

	tsc
	phd
	tcd

	lda	<tok
	ora	<tok+2
	beq	exit

loop	ldy	#TOK_text+2
	lda	[<tok],y
	pha
	ldy	#TOK_text
	lda	[<tok],y
	pha
	jsl	nullfree
	ldy	#TOK_next+2
	lda	[<tok],y
	pha
	ldy	#TOK_next
	lda	[<tok],y
	pha
	lda	<tok
	ldx	<tok+2
	jsr	freetoken
	pla
	sta	<tok
	pla
	sta	<tok+2
	ora	<tok
	bne	loop

exit	lda   space
               sta   end-2
               pld
               tsc
               clc
               adc   #end-3
               tcs

               rts

	END
 
**************************************************************************
*
* get_word
*     - parses a word from the character stream p. The word may be
*       delimited by the character in term.
*     - assumes buffers cannot cross banks.
*
* entry:
*     ph2 term	      - terminating character
*     ph4 p	      - stream pointer
*     ph4 errenv	- error environment pointer
*
* exit
*    ax - pointer to parsed word
*
**************************************************************************
 
get_word	PRIVATE

	using	CharData

STATE1	equ	0
STATE2	equ	2
STATE3	equ	4
STATE4	equ	6

z	equ	1
q	equ	z+4
retval	equ	q+4
space	equ	retval+4
errenv	equ	space+2
p	equ	errenv+4
term	equ	p+4
end	equ	term+2

	tsc
	sec
	sbc	#space-1
	tcs
	phd
	tcd

	lda	[<p]		;Dereference the handle p
	sta	<q
               ldy	#2
               lda	[<p],y
               sta	<q+2

	jsr	alloc256
	sta	<z
	stx	<z+2

	ldy	#0

               lda	<term
               cmp	#'`'
               bne	c1
	ldx	#STATE4
               bra	c4
c1             cmp	#"'"
	bne	c2
               ldx	#STATE3
               bra	c4
c2             cmp	#'"'
               bne	c3
               ldx	#STATE2
               bra	c4
c3	ldx	#STATE1

c4	anop
;
; dispatch to the current state
;
dispatch	anop
               jmp	(!dispatchtbl,x)

dispatchtbl	dc	a2'case1'
	dc	a2'case2'
               dc	a2'case3'
               dc	a2'case4'
;
; STATE 1 - parse a word with no delimiters
;
case1	anop

	lda	[<q]
	and	#$7f
	asl	a
	phx
	tax
	lda	!CharData,x
	plx
	bit	#CH_SPACE+CH_SEMICOLON+CH_AMPERSAND+CH_GREATER+CH_LEFTPAREN+CH_RIGHTPAREN+CH_LESS+CH_PIPE+CH_NEWLINE+CH_EOF
	beq	case1a	;was it a terminating character?
	short	a
	lda	#0
	sta	[<z],y
	long	a

	ldy	#2
	lda	<q
	sta	[<p]
	lda	<q+2
	sta	[<p],y

	iny
	pea	0
	phy
	jsl	~NEW
	sta	<retval
	stx	<retval+2
	pei	(<z+2)
	pei	(<z)
	phx
	pha
	jsr	copycstr
	lda	<z
	ldx	<z+2
	jsr	free256
               jmp	exit

case1a	bit	#CH_BACKSLASH	;it was a backslash, so escape the
	beq	case1b             ; next character
	inc	<q
	lda	[<q]
	sta	[<z],y
	inc	<q
	iny
	bra	case1

case1b	bit	#CH_DOUBQUOTE	;if it's a double quote, change case
	beq	case1c
	ldx	#STATE2
               bra	case1d0
	
case1c	bit	#CH_SINGQUOTE	;if it's a single quote, change case
	beq	case1d
	ldx	#STATE3
	bra	case1d0

case1d	bit	#CH_BACKQUOTE	;if it's a backquote, change case
	beq	case1e
	ldx	#STATE4
case1d0	inc	<q
	bra	dispatch
       
case1e	lda	[<q]	;default, just copy a character
	sta	[<z],y
	inc	<q
	iny
	bra	case1
;
; STATE 2 - parse a word delimited by double quotes
;
case2	anop

	lda	[<q]
	and	#$7f
	asl	a
	phx
	tax
	lda	!CharData,x
	plx
	bit	#CH_DOUBQUOTE
	beq	case2a
	inc	<q
	ldx	#STATE1
	jmp	dispatch

case2a	bit	#CH_NEWLINE+CH_EOF
	beq	case2b
	pei	(<errenv+2)
	pei	(<errenv)
	pea	ERR_MISS_DBL
	jsr	raiseerr
	ldx	#STATE1
	jmp	dispatch

case2b	lda	[<q]
	sta	[<z],y
	inc	<q
	iny
	bra	case2	
;
; STATE 3 - parse a word delimited by single quotes
;
case3	anop

	lda	[<q]
	and	#$7f
	asl	a
	phx
	tax
	lda	!CharData,x
	plx
	bit	#CH_SINGQUOTE
	beq	case3a
	inc	<q
	ldx	#STATE1
	jmp	dispatch

case3a	bit	#CH_NEWLINE+CH_EOF
	beq	case3b
	pei	(<errenv+2)
	pei	(<errenv)
	pea	ERR_MISS_SING
	jsr	raiseerr
	ldx	#STATE1
	jmp	dispatch
                             
case3b	lda	[<q]
	sta	[<z],y
	inc	<q
	iny
	bra	case3	
;
; STATE 4 - parse a word delimited by back quotes
;
case4	anop

	lda	[<q]
	and	#$7f
	asl	a
	phx
	tax
	lda	!CharData,x
	plx
	bit	#CH_BACKQUOTE
	beq	case4a
	inc	<q
	ldx	#STATE1
	jmp	dispatch

case4a	bit	#CH_NEWLINE+CH_EOF
	beq	case4b
	pei	(<errenv+2)
	pei	(<errenv)
	pea	ERR_MISS_BACK
	jsr	raiseerr
	ldx	#STATE1
	jmp	dispatch
                             
case4b	lda	[<q]
	sta	[<z],y
	inc	<q
	iny
	bra	case4
	
exit	ldx	<retval+2
	ldy	<retval

               lda   space
               sta   end-2
               pld
               tsc
               clc
               adc   #end-3
               tcs

               tya
               rts
               
	END

**************************************************************************
*
* lex
*    - takes a raw stream of text and parses it into a stream of tokens.
*
**************************************************************************

lex	START

errenv	equ	0
new	equ	errenv+2
tail	equ	new+4
head	equ	tail+4
space	equ	head+4

	subroutine (4:raw),space

	stz	<errenv
	stz	<tail
	stz	<tail+2
	stz	<head
	stz	<head+2
;
; see if an error exception has been raised
;
mainloop	lda	<errenv
	beq	white
               pea	APP_GSH
	pha
	jsr	shellerror
	pei	(<head+2)
	pei	(<head)
	jsr	freetoklist
	stz	<head
	stz	<head+2

exit	return 4:head
;
; main loop, start by stripping leading whitespace, exit if EOF
;
whiteloop	inc	<raw
white	lda	[<raw]
	and	#$7f
	beq	exit
       	cmp	#' '
	beq	whiteloop
	cmp	#9
	beq	whiteloop
;
; allocate a token node and insert into the linked list
;
	jsr	alloctoken
	sta	<new
	stx	<new+2

	lda	<head	
	ora	<head+2
	bne	alloc1
	lda	<new
	sta	<head	
	stx	<head+2
alloc1	lda	#0
	ldy	#TOK_next
	sta	[<new],y
	ldy	#TOK_next+2
	sta	[<new],y
	lda	<tail
	ora	<tail+2
               beq	alloc2
	lda	new
	ldy	#TOK_next
	sta	[<tail],y
	txa
	ldy	#TOK_next+2
	sta	[<tail],y
alloc2	lda	<new
	sta	<tail
	stx	<tail+2
;
; lex the data based on the next character in the stream
;
	lda	[<raw]
	and	#$7f
	asl	a
               tay
	ldx	!casexlat,y
	jmp	(!casejmptbl,x)

casejmptbl	dc	i2'default'
	dc	i2'case1'	;double quote
	dc	i2'case2'	;back quote
	dc	i2'case3'          ;single quote
	dc	i2'case4'	;ampersand
	dc	i2'case5'	;pipe
	dc	i2'case6'	;less than
	dc	i2'case7'	;open paren
	dc	i2'case8'	;close paren
	dc	i2'case9'	;newline
	dc	i2'case10'	;semicolon
	dc	i2'case11'	;greater than
;
; The default case
;
default	lda	#T_WORD
	ldx	#' '
	bra	case3b
;
; double-quote
;
case1	lda	#T_DBLQUOTE
               ldx	#'"'
               bra	case3a
;
; back-quote
;
case2	lda	#T_BACKQUOTE
	ldx	#'`'
	bra	case3a
;
; single-quote
;
case3	lda	#T_SINGQUOTE
               ldx	#"'"
case3a	inc	<raw
case3b	ldy	#TOK_type
	sta	[<new],y
	phx
	pea	0
	tdc
	clc
	adc	#raw
	pha
	pea	0
	tdc
	adc	#errenv
	pha
	jsr	get_word
	ldy	#TOK_text
	sta	[<new],y
	txa
	ldy	#TOK_text+2
	sta	[<new],y
	jmp	mainloop
;
; ampersand
;
case4	lda	#T_AMP
case4a	inc	<raw
case4b	ldy	#TOK_type
	sta	[<new],y
	jmp	mainloop
;
; pipe
;
case5	inc	<raw
	lda	[<raw]
	and	#$7f
	cmp	#'&'
	bne	case5a
	lda	#T_PIPEAMP
	bra	case4a
case5a	lda	#T_PIPE
	bra	case4b
;
; less than
;
case6	lda	#T_LT
	bra	case4a
;
; open parentheses
;
case7	lda	#T_OPEN
	bra	case4a
;
; close parentheses
;
case8	lda	#T_CLOSE
	bra	case4a
;
; newline
;
case9	lda	#T_CR
	bra	case4a
;
; semicolon
;
case10	lda	#T_SEMI
	bra	case4a
;
; greater than
;
case11	inc	<raw
	lda	[<raw]
	and	#$7f
	cmp	#'>'
	bne	case11a
	inc	<raw
	lda	[<raw]
	and	#$7f
	cmp	#'&'
	bne	case11c
               lda	#T_GTGTAMP	;>>&
	bra	case4a
case11c	lda	#T_GTGT	;>>
               bra	case4b
case11a	cmp	#'&'
	bne	case11b
               lda	#T_GTAMP	;>&
	bra	case4a
case11b	lda	#T_GT	;>
	bra	case4b

casexlat dc    i2'0'                                   		$00
         dc    i2'0'                                        	$01
         dc    i2'0'                                        	$02
         dc    i2'0'                                        	$03
         dc    i2'0'                                         	$04
         dc    i2'0'                                          	$05
         dc    i2'0'                                         	$06
         dc    i2'0'                                       	$07
         dc    i2'0'                                          	$08
         dc    i2'0'                                            $09
         dc    i2'9*2'                                   	$0A
         dc    i2'0'                                         	$0B
         dc    i2'0'                                         	$0C
         dc    i2'9*2'                                          $0D
         dc    i2'0'                                         	$0E
         dc    i2'0'                                      	$0F
         dc    i2'0'                                        	$10
         dc    i2'0'                                                    $11
         dc    i2'0'                                                    $12
         dc    i2'0'                                                    $13
         dc    i2'0'                                                    $14
         dc    i2'0'                                                    $15
         dc    i2'0'                                                    $16
         dc    i2'0'                                                    $17
         dc    i2'0'                                                    $18
         dc    i2'0'                                                    $19
         dc    i2'0'                                                    $1A
         dc    i2'0'                                                    $1B
         dc    i2'0'                                                    $1C
         dc    i2'0'                                                    $1D
         dc    i2'0'                                            $1E
         dc    i2'0'                                            $1F
         dc    i2'0'                                            ' '
         dc    i2'0'                                            !
         dc    i2'1*2'                               		"
         dc    i2'0'                                            #
         dc    i2'0'                                            $
         dc    i2'0'                                            %
         dc    i2'4*2'                                          &
         dc    i2'3*2'                           	        '
         dc    i2'7*2'                                 		(
         dc    i2'8*2'                                		)
         dc    i2'0'                                            *
         dc    i2'0'                                            +
         dc    i2'0'                                            ,
         dc    i2'0'                                            -
         dc    i2'0'                                            .
         dc    i2'0'                                            /
         dc    i2'0'                                         	0
         dc    i2'0'                                         	1
         dc    i2'0'                                         	2
         dc    i2'0'                                         	3
         dc    i2'0'                                         	4
         dc    i2'0'                                         	5
         dc    i2'0'                                         	6
         dc    i2'0'                                         	7
         dc    i2'0'                                            8
         dc    i2'0'                                            9
         dc    i2'0'                                            :
         dc    i2'10*2'                                         ;
         dc    i2'6*2'                                    	<
         dc    i2'0'                                            =
         dc    i2'11*2'                                         >
         dc    i2'0'                                            ?
         dc    i2'0'                                            @
         dc    i2'0'                                         	A
         dc    i2'0'                                         	B
         dc    i2'0'                                         	C
         dc    i2'0'                                         	D
         dc    i2'0'                                         	E
         dc    i2'0'                                         	F
         dc    i2'0'                                         	G
         dc    i2'0'                                         	H
         dc    i2'0'                                         	I
         dc    i2'0'                                         	J
         dc    i2'0'                                        	K
         dc    i2'0'                                        	L
         dc    i2'0'                                         	M
         dc    i2'0'                                         	N
         dc    i2'0'                                         	O
         dc    i2'0'                                         	P
         dc    i2'0'                                         	Q
         dc    i2'0'                                         	R
         dc    i2'0'                                         	S
         dc    i2'0'                                         	T
         dc    i2'0'                                         	U
         dc    i2'0'                                         	V
         dc    i2'0'                                         	W
         dc    i2'0'                                         	X
         dc    i2'0'                                         	Y
         dc    i2'0'                                         	Z
         dc    i2'0'                                         	[
         dc    i2'0'                                         	\
         dc    i2'0'                                         	]
         dc    i2'0'                                         	^
         dc    i2'0'                                         	_
         dc    i2'2*2'                         			`
         dc    i2'0'                                         a
         dc    i2'0'                                         b
         dc    i2'0'                                         c
         dc    i2'0'                                         d
         dc    i2'0'                                         e
         dc    i2'0'                                         f
         dc    i2'0'                                         g
         dc    i2'0'                                         h
         dc    i2'0'                                         i
         dc    i2'0'                                         j
         dc    i2'0'                                         k
         dc    i2'0'                                         l
         dc    i2'0'                                         m
         dc    i2'0'                                         n
         dc    i2'0'                                         o
         dc    i2'0'                                         p
         dc    i2'0'                                         q
         dc    i2'0'                                         r
         dc    i2'0'                                         s
         dc    i2'0'                                         t
         dc    i2'0'                                         u
         dc    i2'0'                                         v
         dc    i2'0'                                         w
         dc    i2'0'                                         x
         dc    i2'0'                                         y
         dc    i2'0'                                         z
         dc    i2'0'                                         	{
         dc    i2'5*2'                                     	|
         dc    i2'0'                                         	}
         dc    i2'0'                                         	~
         dc    i2'0'	                                     	$7F

	END

**************************************************************************
*
* printtoken
*    displays an ascii representation of a token
*
**************************************************************************

printtoken	START

space	equ	0

	subroutine (4:token),space

	ldy	#TOK_type
	lda	[<token],y

	cmp	#T_WORD
	beq	showword
	cmp	#T_DBLQUOTE
	beq	showword
	cmp	#T_SINGQUOTE
	beq	showword
	cmp	#T_BACKQUOTE
	beq	showback

	tax
	lda	!toktbl,x
	ldx	#^str00
	jsr	puts
	
exit	return

showword	ldy	#TOK_text+2
	lda	[<token],y
	tax
	ldy	#TOK_text
	lda	[<token],y
	jsr	puts
	lda	#' '
	jsr	putchar
	bra	exit

showback	lda	#bak00
	ldx	#^bak00
	jsr	puts
	ldy	#TOK_text+2
	lda	[<token],y
	tax
	ldy	#TOK_text
	lda	[<token],y
	jsr	puts
                         
	lda	#bak01
	ldx	#^bak01
	jsr	puts
               bra	exit

toktbl	dc	i2'0'	;T_WORD
	dc	i2'0'	;T_SINGQUOTE
	dc	i2'0'	;T_DBLQUOTE
	dc	i2'0'	;T_BACKQUOTE
	dc	i2'str00'	;T_PIPE
	dc	i2'str01'	;T_AMP
	dc	i2'str02'	;T_LT
	dc	i2'str03'	;T_GT
	dc	i2'str04'	;T_GTGT
	dc	i2'str05'	;T_GTAMP
	dc	i2'str06'	;T_GTGTAMP
	dc	i2'str07'	;T_CR
	dc	i2'str08'	;T_SEMI
	dc	i2'str09'	;T_OPEN
	dc	i2'str10'	;T_CLOSE
	dc	i2'str11'	;T_PIPEAMP

str00	dc	c'| ',h'00'
str01	dc	c'& ',h'00'
str02	dc	c'< ',h'00'
str03	dc	c'> ',h'00'
str04	dc	c'>> ',h'00'
str05	dc	c'>& ',h'00'
str06	dc	c'>>& ',h'00'
str07	dc	c'[CR] ',h'00'
str08	dc	c'; ',h'00'
str09	dc	c'( ',h'00'
str10	dc	c') ',h'00'
str11	dc	c'|& ',h'00'

bak00	dc	c'[pipe `',h'00'
bak01	dc	c'`] ',h'00'

	END

**************************************************************************
*
* printtokenlist
*    display a list of tokens
*
**************************************************************************

printtokenlist	START

space	equ	0

	subroutine (4:x),space

	lda	<x
	ora	<x+2
	beq	exit

loop	pei	(<x+2)
	pei	(<x)
	jsl	printtoken
	ldy	#TOK_next+2
	lda	[<x],y
	tax
	ldy	#TOK_next
	lda	[<x],y
	sta	<x
	stx	<x+2
	ora	<x+2
	bne	loop
	
	lda	#13
	jsr	putchar

exit	return

	END

**************************************************************************
*
* This table lets us use a single BIT instruction to compare a single
* character to a set of characters.
*
**************************************************************************
 
CharData	PRIVDATA                                

CharTable dc   i2'CH_EOF'                                               $00
         dc    i2'0'                                                    $01
         dc    i2'0'                                                    $02
         dc    i2'0'                                                    $03
         dc    i2'0'                                                    $04
         dc    i2'0'                                                    $05
         dc    i2'0'                                                    $06
         dc    i2'0'                                                    $07
         dc    i2'0'                                                    $08
         dc    i2'CH_SPACE'                                             $09
         dc    i2'CH_NEWLINE'                                           $0A
         dc    i2'0'                                                    $0B
         dc    i2'0'                                                    $0C
         dc    i2'CH_NEWLINE'                                           $0D
         dc    i2'0'                                                    $0E
         dc    i2'0'                                                    $0F
         dc    i2'0'                                                    $10
         dc    i2'0'                                                    $11
         dc    i2'0'                                                    $12
         dc    i2'0'                                                    $13
         dc    i2'0'                                                    $14
         dc    i2'0'                                                    $15
         dc    i2'0'                                                    $16
         dc    i2'0'                                                    $17
         dc    i2'0'                                                    $18
         dc    i2'0'                                                    $19
         dc    i2'0'                                                    $1A
         dc    i2'0'                                                    $1B
         dc    i2'0'                                                    $1C
         dc    i2'0'                                                    $1D
         dc    i2'0'                                                    $1E
         dc    i2'0'                                                    $1F
         dc    i2'CH_SPACE'                                     ' '
         dc    i2'0'                                            !
         dc    i2'CH_DOUBQUOTE'                                 "
         dc    i2'0'                                            #
         dc    i2'0'                                            $
         dc    i2'0'                                            %
         dc    i2'CH_AMPERSAND'                                 &
         dc    i2'CH_SINGQUOTE'               			'
         dc    i2'CH_LEFTPAREN'                                 (
         dc    i2'CH_RIGHTPAREN'                                )
         dc    i2'0'                                            *
         dc    i2'0'                                            +
         dc    i2'0'                                            ,
         dc    i2'0'                                            -
         dc    i2'0'                                            .
         dc    i2'0'                                            /
         dc    i2'0'                                         	0
         dc    i2'0'                                         	1
         dc    i2'0'                                         	2
         dc    i2'0'                                         	3
         dc    i2'0'                                         	4
         dc    i2'0'                                         	5
         dc    i2'0'                                         	6
         dc    i2'0'                                         	7
         dc    i2'0'                                            8
         dc    i2'0'                                            9
         dc    i2'0'                                            :
         dc    i2'CH_SEMICOLON'                                 ;
         dc    i2'CH_LESS'                                      <
         dc    i2'0'                                            =
         dc    i2'CH_GREATER'                                   >
         dc    i2'0'                                            ?
         dc    i2'0'                                            @
         dc    i2'0'                                         	A
         dc    i2'0'                                         	B
         dc    i2'0'                                         	C
         dc    i2'0'                                         	D
         dc    i2'0'                                         	E
         dc    i2'0'                                         	F
         dc    i2'0'                                         	G
         dc    i2'0'                                         	H
         dc    i2'0'                                         I
         dc    i2'0'                                         J
         dc    i2'0'                                         K
         dc    i2'0'                                         L
         dc    i2'0'                                         M
         dc    i2'0'                                         N
         dc    i2'0'                                         O
         dc    i2'0'                                         P
         dc    i2'0'                                         Q
         dc    i2'0'                                         R
         dc    i2'0'                                         S
         dc    i2'0'                                         T
         dc    i2'0'                                         U
         dc    i2'0'                                         V
         dc    i2'0'                                         W
         dc    i2'0'                                         X
         dc    i2'0'                                         Y
         dc    i2'0'                                         Z
         dc    i2'0'                                         [
         dc    i2'CH_BACKSLASH'                              \
         dc    i2'0'                                         ]
         dc    i2'0'                                         ^
         dc    i2'0'                                         _
         dc    i2'CH_BACKQUOTE'                              `
         dc    i2'0'                                         a
         dc    i2'0'                                         b
         dc    i2'0'                                         c
         dc    i2'0'                                         d
         dc    i2'0'                                         e
         dc    i2'0'                                         f
         dc    i2'0'                                         g
         dc    i2'0'                                         h
         dc    i2'0'                                         i
         dc    i2'0'                                         j
         dc    i2'0'                                         k
         dc    i2'0'                                         l
         dc    i2'0'                                         m
         dc    i2'0'                                         n
         dc    i2'0'                                         o
         dc    i2'0'                                         p
         dc    i2'0'                                         q
         dc    i2'0'                                         r
         dc    i2'0'                                         s
         dc    i2'0'                                         t
         dc    i2'0'                                         u
         dc    i2'0'                                         v
         dc    i2'0'                                         w
         dc    i2'0'                                         x
         dc    i2'0'                                         y
         dc    i2'0'                                         z
         dc    i2'0'                                         {
         dc    i2'CH_PIPE'                                   |
         dc    i2'0'                                         }
         dc    i2'0'                                         ~
         dc    i2'0'	                                     $7F

         END
