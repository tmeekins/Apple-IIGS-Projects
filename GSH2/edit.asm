***********************************************************************
* CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL CONFIDENTIAL *
***********************************************************************
                                                                       
**************************************************************************
*                            
* GNO/Shell 2.0
* The GNO/Shell command line editor
*
* Written by Tim Meekins
* Copyright (C) 1993 by Tim Meekins & Procyon Enterprises, Inc.
*
**************************************************************************

               keep  o/edit
               mcopy m/edit.mac

RAW	gequ	$20
CRMOD	gequ	$10
ECHO	gequ	$08
CBREAK	gequ	$02
TANDEM	gequ	$01

OAMAP	gequ	0001		/* map OA-key to some sequence */
OA2META	gequ	0002		/* map OA-key to meta-key */
OA2HIBIT	gequ	0004		/* map OA-key to key|0x80 */
VT100ARROW	gequ	0008		/* map arrows to vt100 arrows */

TIOCGETP	gequ	$40067408
TIOCSETP	gequ	$80067409
TIOCGETK	gequ	$40027414
TIOCSETK	gequ	$80027413

cmdbuflen      gequ  1024

; editor key commands

undefined_char	gequ	0	;<- DO NOT CHANGE THIS DEFINITION
raw_char	gequ	1                  ;<- DO NOT CHANGE THIS DEFINITION
map_char	gequ	2
backward_char	gequ	3
forward_char	gequ	4
up_history	gequ	5
down_history	gequ	6
beginning_of_line gequ 7
end_of_line	gequ	8
complete_word	gequ	9
newline_char	gequ	10
clear_screen	gequ	11
redisplay	gequ	12
kill_whole_line gequ 13
lead_in	gequ	14
backward_delete_char gequ 15
backward_word	gequ	16
forward_word	gequ	17	
list_choices	gequ	18
kill_end_of_line gequ 19
toggle_cursor	gequ	20
delete_char	gequ	21

**************************************************************************
*
* get a command line from the user
*
**************************************************************************

GetCmdLine     START

               using global
**               using HistoryData
**	using	pdata
	using	keybinddata
	using	termdata

	stz	signalled
               stz   cmdlen
               stz   cmdloc
**               stz   currenthist
**               stz   currenthist+2

	ioctl	(#1,#TIOCGETP,#oldsgtty)
	ioctl	(#1,#TIOCGETP,#newsgtty)
	lda	#CBREAK+CRMOD
	sta	sg_flags
	ioctl	(#1,#TIOCSETP,#newsgtty)

	ioctl (#1,#TIOCGETK,#oldttyk)
	ioctl (#1,#TIOCSETK,#newttyk)

cmdloop        lda	#keybindtab
	sta	0
	lda	#^keybindtab
	sta	2
nextchar	jsr	cursoron
	jsr	flush
	jsr	getchar
	sta	4
	ldx	signalled
	beq	nextchar2
	jsr	cmdsig
	bra	cmdloop

nextchar2	jsr	cursoroff
	lda	4
	cmp	#-1
	beq	eof
	cmp	#4	;CTL-D
	bne	findcmd

eof	ldx	cmdlen
               bne   findcmd
	ioctl	(#1,#TIOCSETP,#oldsgtty)
	ioctl (#1,#TIOCSETK,#oldttyk)
               sec                     
               rts

findcmd	asl	a
	sta	addidx+1
	asl	a
addidx         adc	#0
	tay
	lda	[0],y	;get the type of key this is
	asl	a
	tax
	jsr	(keytab,x)
	jmp	cmdloop

keytab	dc	i'beep'	;undefined-char
	dc	i'cmdraw'	;raw-char
	dc	i'cmdloop'	;map-char
	dc	i'cmdleft'	;backward-char
	dc	i'cmdright'	;forward-char
**	dc	i'PrevHistory'	;up-history
	dc	i'beep'
**	dc	i'NextHistory'	;down-history
	dc	i'beep'
	dc	i'cmdbegin'	;beginning-of-line
	dc	i'cmdend'	;end-of-line
**	dc	i'dotab'	;complete-word
	dc	i'beep'
	dc	i'cmdnewline'	;newline
	dc	i'cmdclearscrn'	;clear-screen
	dc	i'cmdredraw'	;redisplay
	dc	i'cmdclrline'	;kill-whole-line
	dc	i'cmdleadin'	;lead-in
	dc	i'cmdbackdel'	;backward-delete-char
	dc	i'cmdleftword'	;backward-word
	dc	i'cmdrightword'	;forward-word
**	dc	i'cmdmatch'	;list-choices
	dc	i'beep'
	dc	i'cmdclreol'	;kill-end-of-line
	dc	i'cmdcursor'	;toggle-cursor
	dc	i'cmddelchar'	;delete-char

;-------------------------------------------------------------------------
;
; it's multiple character command
;
;-------------------------------------------------------------------------

cmdleadin	pla		;kill return address
	iny
	iny
	lda	[0],y
	tax
	iny
	iny
	lda	[0],y
	sta	0+2
	stx	0
	jmp	nextchar

;-------------------------------------------------------------------------                        
;
; Insert or overwrite an alphanum character
;
;-------------------------------------------------------------------------

cmdraw         lda   cmdlen
               cmp   #cmdbuflen
               bcc   cmIns0
	jmp	beep

cmIns0         lda   insertflag
               beq   cmOver             ;Do overstrike mode
               short a
               ldy   cmdlen
cmIns1         cpy   cmdloc
               beq   cmins2
               bcc   cmIns2
               lda   cmdline-1,y
               sta   cmdline,y
               dey
               bra   cmIns1
cmIns2         long  a
               inc   cmdlen
;
; Place character in string and output
;
cmOver         lda   4
               ldy   cmdloc             ;Do overstrike mode
               short a
               sta   cmdline,y
               long  a
               iny
               sty   cmdloc
	jsr	putchar
               ldy   cmdloc
               cpy   cmdlen
               bcc   cmdov2 
               beq   cmdov2 
               sty   cmdlen
;
; Redraw shifted text
;
cmdov2         lda   insertflag
               cmp   #0
	bne	cmdov2a
	rts
cmdov2a        ldx   #0
cmdov3         if2   @y,eq,cmdlen,cmdov4
               lda   cmdline,y
               iny
               inx
               phx
               phy
	jsr	putchar
               ply
               plx
               bra   cmdov3
cmdov4         jmp	moveleft

;-------------------------------------------------------------------------
;
; If the shell is interrupted during an edit
;
;-------------------------------------------------------------------------

cmdsig	stz	signalled
	jmp	cmdredraw

;-------------------------------------------------------------------------
;
; end of command...newline
;
;-------------------------------------------------------------------------

cmdnewline     pla		;pull off return address
	sec
	lda	cmdlen
	sbc	cmdlen
	tax
	jsr	moveright
           	ldx   cmdlen	;strip trailing space
	beq	retdone
fix	dex
	lda	cmdline,x
	and	#$FF
	if2	@a,eq,#' ',fix
fix0	inx
	stx	cmdlen
               stz   cmdline,x          ;terminate string
               txy
               beq   retdone
**             lda   #<cmdline
**             ldx   #^cmdline
**             jsr   InsertHistory
retdone	ioctl	(#1,#TIOCSETP,#oldsgtty)
	ioctl (#1,#TIOCSETK,#oldttyk)
	clc             
               rts

;-------------------------------------------------------------------------
;
; moved character to the left
;
;-------------------------------------------------------------------------

cmdleft        lda   cmdloc
               bne   ctl0a
	jmp	beep
ctl0a          dec   a
               sta   cmdloc
	ldx	#1
	jmp	moveleft

;-------------------------------------------------------------------------
;
; move character to the right
;
;-------------------------------------------------------------------------

cmdright       ldy   cmdloc
               if2   @y,ne,cmdlen,ctl1a
	jmp	beep
ctl1a          lda   cmdline,y
	jsr	putchar
               inc   cmdloc
               rts

;-------------------------------------------------------------------------
;
; show matching files
;
;-------------------------------------------------------------------------

cmdmatch	lda	cmdlen	
	beq	dontdomatch
**	jsr	domatcher
**	jmp	cmdredraw
dontdomatch	rts

;-------------------------------------------------------------------------
;
; Clear entire input line 
;
;-------------------------------------------------------------------------

cmdclrline	ldx	cmdloc
	jsr	moveleft
	stz	cmdloc	;fall through to cmdclreol

;-------------------------------------------------------------------------
;
; Clear to end of line
;
;-------------------------------------------------------------------------

cmdclreol      lda	cdcap
	ora	cdcap
	beq	ctl4a0
	tputs (cdcap,#1,#outc)
               bra   ctl4g

ctl4a0         sub2	cmdlen,cmdloc,@a
	inc   a
         	tax
               tay
               phx
ctl4a          phy
	lda	#' '
	jsr	putchar
               ply
               dey
               bne   ctl4a
               plx
          	jsr	moveleft

ctl4g          lda   cmdloc
               sta   cmdlen
               rts

;-------------------------------------------------------------------------
;
; redraw command-line
;
;-------------------------------------------------------------------------

cmdredraw	jsr	newline
redraw2	anop
**	jsl	WritePrompt
	ldx	cmdlen
	stz	cmdline,x
	ldx	#^cmdline
	lda	#cmdline
	jsr	puts
	sec
	lda	cmdlen
	sbc	cmdloc
	tax
	jmp	moveleft

;-------------------------------------------------------------------------
;
; clear screen
;
;-------------------------------------------------------------------------

cmdclearscrn	jsr	clearscrn
	bra	redraw2

;-------------------------------------------------------------------------
;
; Insert toggle
;
;-------------------------------------------------------------------------

cmdcursor      eor2  insertflag,#1,insertflag
	rts

;-------------------------------------------------------------------------
;                                           
; delete character to left
;
;-------------------------------------------------------------------------

cmdbackdel     lda   cmdloc
               bne   ctldel2
	jmp	beep
ctldel2        dec   a
               sta   cmdloc
	ldx	#1
	jsr	moveleft	;fall through to cmddelchar

;-------------------------------------------------------------------------
;
; Delete character under cursor
;
;-------------------------------------------------------------------------

cmddelchar     ldy   cmdloc
               if2   @y,ne,cmdlen,cmdoa2a
               rts
cmdoa2a        short a
cmdoa2aa       if2   @y,eq,cmdlen,cmdoa2b
               lda   cmdline+1,y
               sta   cmdline,y
               iny
               bra   cmdoa2aa
cmdoa2b        lda   #' '
               sta   cmdline-1,y
               sta   cmdline,y
               long  a
               ldy   cmdloc
               ldx   #0
cmdoa2c        if2   @y,eq,cmdlen,cmdoa2e
               bcs   cmdoa2d
cmdoa2e        lda   cmdline,y
               iny
               inx
               phx
               phy
	jsr	putchar
               ply
               plx
               bra   cmdoa2c   

cmdoa2d        jsr	moveleft
        	dec   cmdlen
               rts

;-------------------------------------------------------------------------
;
; Jump to beginning of line
;
;-------------------------------------------------------------------------

cmdbegin       ldx	cmdloc
	stz	cmdloc
	jmp	moveleft

;-------------------------------------------------------------------------
;
; Jump to end of line
;
;-------------------------------------------------------------------------

cmdend         if2   cmdloc,eq,cmdlen,cmdoa4a
	ldx	#1
	jsr	moveright
               inc   cmdloc
               bra   cmdend
cmdoa4a        rts

;-------------------------------------------------------------------------
;
; Left one word
;
;-------------------------------------------------------------------------

cmdleftword    lda   cmdloc
               bne   cmdoa5a   
               jsr	beep
cmdoa5z        rts
cmdoa5a        dec   a
               sta   cmdloc
cmdoa5b	ldx	#1
	jsr	moveleft
	ldy	cmdloc
	beq	cmdoa5z
	lda	cmdline,y
	and	#$FF
	cmp	#' '
	bne	cmdoa5c
	dec	cmdloc
	bra	cmdoa5b
cmdoa5c	ldy	cmdloc
	beq	cmdoa5z
	lda	cmdline-1,y
	and	#$FF
	cmp	#' '
	beq	cmdoa5z
	dec	cmdloc
	ldx	#1
	jsr	moveleft
	bra	cmdoa5c

;-------------------------------------------------------------------------
;
; Move one word to the right
;
;-------------------------------------------------------------------------

cmdrightword	if2	cmdloc,ne,cmdlen,cmdoa6a
	jsr	beep
cmdoa6z        rts
cmdoa6a        inc   a
               sta   cmdloc
cmdoa6b	ldx	#1
	jsr	moveright
	ldy	cmdloc
	if2	@y,eq,cmdlen,cmdoa6z
	lda	cmdline,y
	and	#$FF
	cmp	#' '
	beq	cmdoa6c
	inc	cmdloc
	bra	cmdoa6b
cmdoa6c	ldy	cmdloc
	if2	@y,eq,cmdlen,cmdoa6z
	lda	cmdline,y
	and	#$FF
	cmp	#' '
	bne	cmdoa6z
	inc	cmdloc
	ldx	#1
	jsr	moveright
	bra	cmdoa6c

oldsgtty	dc	i1'0'
	dc	i1'0'
	dc	i1'0'
	dc	i1'0'
	dc	i2'0'

newsgtty	dc	i1'0'
	dc	i1'0'
	dc	i1'0'
	dc	i1'0'
sg_flags	dc	i2'0'

oldttyk	dc	i2'0'
newttyk	dc	i2'OAMAP+OA2META+VT100ARROW'

               END        

**************************************************************************
*
* key bindings data
*
**************************************************************************

keybinddata	DATA

keybindtab	dc	i2'undefined_char',i4'0'		;^@
	dc	i2'beginning_of_line',i4'0'        ;^A
	dc	i2'backward_char',i4'0'		;^B
	dc	i2'undefined_char',i4'0'		;^C
	dc	i2'list_choices',i4'0'		;^D
	dc	i2'end_of_line',i4'0'		;^E
	dc	i2'forward_char',i4'0'		;^F
	dc	i2'undefined_char',i4'0'		;^G
	dc	i2'backward_delete_char',i4'0'	;^H
	dc	i2'complete_word',i4'0'		;^I
	dc	i2'newline_char',i4'0'		;^J
	dc	i2'undefined_char',i4'0'		;^K
	dc	i2'clear_screen',i4'0'		;^L
	dc	i2'newline_char',i4'0'		;^M
	dc	i2'down_history',i4'0'		;^N
	dc	i2'undefined_char',i4'0'		;^O
	dc	i2'up_history',i4'0'		;^P
	dc	i2'undefined_char',i4'0'		;^Q
	dc	i2'redisplay',i4'0'		;^R
	dc	i2'undefined_char',i4'0'		;^S
	dc	i2'undefined_char',i4'0'		;^T
	dc	i2'kill_whole_line',i4'0'		;^U
	dc	i2'undefined_char',i4'0'		;^V
	dc	i2'undefined_char',i4'0'		;^W
	dc	i2'kill_whole_line',i4'0'		;^X
	dc	i2'kill_end_of_line',i4'0'		;^Y
	dc	i2'undefined_char',i4'0'		;^Z
	dc	i2'lead_in',i4'defescmap'		;^[
	dc	i2'undefined_char',i4'0'		;^\
	dc	i2'undefined_char',i4'0'		;^]
	dc	i2'undefined_char',i4'0'		;^^
	dc	i2'undefined_char',i4'0'		;^_
              	dc	95i2'raw_char,0,0'			;' ' .. '~'
	dc	i2'backward_delete_char',i4'0'	;^? (DEL)

defescmap	dc	4i2'undefined_char,0,0'		;^@ .. ^C
	dc	i2'list_choices',i4'0'		;^D
	dc	3i2'undefined_char,0,0'		;^E .. ^G
               dc	i2'backward_word',i4'0'		;^H
	dc	i2'complete_word',i4'0'		;^I
	dc	2i2'undefined_char,0,0'		;^J, ^K
	dc	i2'clear_screen',i4'0'		;^L
	dc	i2'undefined_char,0,0'		;^M
	dc	i2'undefined_char,0,0'		;^N
	dc	i2'undefined_char,0,0'		;^O
	dc	i2'undefined_char,0,0'		;^P
	dc	i2'undefined_char,0,0'		;^Q
	dc	i2'undefined_char,0,0'		;^R
	dc	i2'undefined_char,0,0'		;^S
	dc	i2'undefined_char,0,0'		;^T
	dc	i2'forward_word,0,0'		;^U
	dc	i2'undefined_char,0,0'		;^W
	dc	i2'undefined_char,0,0'		;^X
	dc	i2'undefined_char,0,0'		;^X
	dc	i2'undefined_char,0,0'		;^Y
	dc	i2'undefined_char,0,0'		;^Z
	dc	i2'complete_word',i4'0'		;^[
	dc	16i2'undefined_char,0,0'		;^\ .. +
	dc	i2'beginning_of_line',i4'0'        ; ,
	dc	i2'undefined_char,0,0'		; 
	dc	i2'end_of_line',i4'0'		; .
	dc	19i2'undefined_char,0,0'		; .+1 .. A
	dc	i2'backward_word',i4'0'		;B
	dc	3i2'undefined_char,0,0'		;C ... E
	dc	i2'forward_word',i4'0'		;F
	dc	8i2'undefined_char,0,0'		;G ... N
	dc	i2'lead_in',i4'vt100key'		;O
	dc	18i2'undefined_char,0,0'		;P ... a
	dc	i2'backward_word',i4'0'		;b
	dc	2i2'undefined_char,0,0'		;c ... d
	dc	i2'toggle_cursor',i4'0'		;e
	dc	i2'forward_word',i4'0'		;f
	dc	25i2'undefined_char,0,0'		;g ... ^?

vt100key	dc	65i2'undefined_char,0,0'		;^@ ... @
	dc	i2'up_history',i4'0'		;A
	dc	i2'down_history',i4'0'		;B
	dc	i2'forward_char',i4'0'		;C
	dc	i2'backward_char',i4'0'		;D
	dc	59i2'undefined_char,0,0'		;E ... ^?

	END

**************************************************************************
*
* bind a key to a function
*
**************************************************************************

bindkeyfunc	START

	using	keybinddata

p	equ	0
tbl	equ	p+4
len	equ	tbl+4
space	equ	len+2

	subroutine (4:keystr,2:function),space

	lda	keystr
	ora	keystr+2
	jeq	done

	pei	(keystr+2)
	pei	(keystr)
	jsr	cstrlen
	sta	len
	ld4	keybindtab,tbl

loop	lda	len
	jeq	done
	dec	a
	beq	putit	;last char in string

	lda	[keystr]
	and	#$FF
	asl	a
	sta	addb+1
	asl	a
	clc
addb	adc	#0
	tay
    	lda	[tbl],y
	cmp	#lead_in
	beq	next
	phy
	ph4	#128*6
	jsl	~NEW
	sta	p
	stx	p+2
	ldy	#128*6-2
	lda	#0
zap            sta	[0],y
	dey
	dey
	bpl	zap
	ply
	lda	#lead_in
	sta	[tbl],y
	iny
	iny
	lda	p
	sta	[tbl],y
	iny
	iny
	lda	p+2
	sta	[tbl],y
	mv4	p,tbl
	dec	len
	add4	keystr,#1,keystr
	bra	loop

next	iny
	iny
	lda	[tbl],y
	tax
	iny
	iny
	lda	[tbl],y
	sta	tbl+2
	stx	tbl
	dec	len
	add4	keystr,#1,keystr
	jmp	loop

putit	lda	[keystr]
	and	#$FF
	asl	a
	sta	adda+1
	asl	a
	clc
adda	adc	#0
	tay
	lda	function
	sta	[tbl],y
	iny
	iny
	lda	#0
	sta	[tbl],y
	iny
	iny
	sta	[tbl],y

done	return

	END

**************************************************************************
*
* BINDKEY: builtin command
* syntax: bindkey [-l] function string
*
* bind a keystring to an editor function.
*
**************************************************************************

bindkey	START

str	equ	0
func	equ	str+4
arg	equ	func+2
space	equ	arg+4

	subroutine (4:argv,2:argc),space

	lda	argc
	dec	a
	bne	ok
showusage	ldx	#^usage
	lda	#usage
	jsr	errputs
	jmp	exit

ok	dec	argc
	add2	argv,#4,argv
	lda	[argv]
	sta	arg
	ldy	#2
	lda	[argv],y
	sta	arg+2
	lda	[arg]
	and	#$FF
	cmp	#'-'
	bne	startbind
	ldy	#1
	lda	[arg],y
	cmp	#'l'
	beq	list
	bra	showusage

list	ldx	#^liststr	
	lda	#liststr
	jsr	puts
	jmp	exit

startbind	lda	argc
	dec	a
	jeq	showusage
	dec	a
	jne	showusage

	ldy	#0
findloop	phy
	lda	nametbl,y
	ora	nametbl+2,y
	beq	nofind
	lda	nametbl+2,y
	pha
	lda	nametbl,y
	pha
	pei	(arg+2)
	pei	(arg)
	jsr	cmpcstr
	beq	foundit
	pla
	add2	@a,#4,@y
	bra	findloop

nofind	pla
	ldx	arg+2
	lda	arg
	jsr	errputs
	ldx	#^errstr
	lda	#errstr
	jsr	errputs
	lda	#-1
	jmp	exit

foundit	pla
	lsr	a
	tax
	lda	functbl,x
	sta	func

	add2	argv,#4,argv
	lda	[argv]
	sta	arg
	ldy	#2
	lda	[argv],y
	sta	arg+2

	pei	(arg+2)
	pei	(arg)
	jsr	cstrlen
	inc	a
	inc	a
	pea	0
	pha
	jsl	~NEW
	sta	str
	stx	str+2
	pei	(arg+2)
	pei	(arg)
	phx
	pha
	jsl	decode

	pei	(str+2)
	pei	(str)
	pei	(func)
	jsl	bindkeyfunc

	pei	(str+2)
	pei	(str)
	jsl	nullfree

exit	return
                  
usage	dc	c'Usage: bindkey [-l] function string',h'0d00'
errstr	dc	c': undefined function',h'0d00'

liststr	dc	c'  backward-char        - move cursor left',h'0d'
	dc	c'  backward-delete-char - delete character to left',h'0d'
	dc	c'  backword-word        - move cursor left one word',h'0d'
	dc	c'  beginning-of-line    - move cursor to beginning of line',h'0d'
	dc	c'  clear-screen         - clear screen and redraw prompt',h'0d'
	dc	c'  complete-word        - perform filename completion',h'0d'
	dc	c'  delete-char          - delete character under cursor',h'0d'
	dc	c'  down-history         - replace command line with next history',h'0d'
	dc	c'  end-of-line          - move cursor to end of line',h'0d'
	dc	c'  forward-char         - move cursor to the right',h'0d'
	dc	c'  forward-word         - move cursor one word to the right',h'0d'
	dc	c'  kill-end-of-line     - delete line from cursor to end of line',h'0d'
	dc	c'  kill-whole-line      - delete the entire command line',h'0d'
	dc	c'  list-choices         - list file completion matches',h'0d'
	dc	c'  newline              - finished editing, accept command line',h'0d'
	dc	c'  raw-char             - character as-is',h'0d'
	dc	c'  redisplay            - redisplay the command line',h'0d'
	dc	c'  toggle-cursor        - toggle between insert and overwrite cursor',h'0d'
	dc	c'  undefined-char       - this key does nothing',h'0d'
	dc	c'  up-history           - replace command line with previous history',h'0d'
               dc	h'00'

nametbl	dc	i4'func1,func2,func3,func4,func5,func6,func7,func8'
	dc	i4'func9,func10,func11,func12,func13,func14,func15'
	dc	i4'func16,func17,func18,func19,func20,0'

func1	dc	c'backward-char',h'00'
func2	dc	c'backward-delete-char',h'00'
func3	dc	c'backword-word',h'00'
func4	dc	c'beginning-of-line',h'00'
func5	dc	c'clear-screen',h'00'
func6	dc	c'complete-word',h'00'
func7	dc	c'delete-char',h'00'
func8	dc	c'down-history',h'00'
func9	dc	c'end-of-line',h'00'
func10	dc	c'forward-char',h'00'
func11	dc	c'forward-word',h'00'
func12	dc	c'kill-end-of-line',h'00'
func13	dc	c'kill-whole-line',h'00'
func14	dc	c'list-choices',h'00'
func15	dc	c'newline',h'00'
func16	dc	c'raw-char',h'00'
func17	dc	c'redisplay',h'00'
func18	dc	c'toggle-cursor',h'00'
func19	dc	c'undefined-char',h'00'
func20	dc	c'up-history',h'00'

functbl	dc	i'backward_char'
	dc	i'backward_delete_char'
	dc	i'backward_word'
	dc	i'beginning_of_line'
	dc	i'clear_screen'
	dc	i'complete_word'
	dc	i'delete_char'
	dc	i'down_history'
	dc	i'end_of_line'
	dc	i'forward_char'
	dc	i'forward_word'
	dc	i'kill_end_of_line'
	dc	i'kill_whole_line'
	dc	i'list_choices'
	dc	i'newline_char'
               dc	i'raw_char'
	dc	i'redisplay'	
	dc	i'toggle_cursor'
	dc	i'undefined_char'
	dc	i'up_history'

	END

**************************************************************************
*
* decode does the grung work to decode the
* string escapes.
*
**************************************************************************

decode	START

ch	equ	1
space	equ	ch+2
cp	equ	space+3
str	equ	cp+4
end	equ	str+4

;	subroutine (4:str,4:cp),space

	tsc
	sec
	sbc	#space-1
	tcs
	phd
	tcd

	ldy	#0

loop	lda	[str],y
	and	#$FF
	jeq	breakloop
	iny

	cmp	#'^'
	bne	caseslash

	lda	[str],y
	and	#$1F
	iny
	bra	casebreak0

caseslash	cmp	#'\'
	bne	casebreak0

	lda	[str],y
	and	#$FF
	sta	ch
	iny

	ldx	#0
nextc	lda	dp1,x
	and	#$FF
	beq	nextslash
	cmp	ch
	beq	gotslash
	inx
	bra	nextc
gotslash	lda	dp2,x
	and	#$FF
	bra	casebreak0

nextslash	lda	ch
	cmp	#'0'
	bcc	casebreak0
	cmp	#'9'+1
	bcs	casebreak0

	sec
	sbc	#'0'
	sta	ch

	ldx	#2

numloop	asl	ch
	asl	ch
	asl	ch
	lda	[str],y
	and	#$FF
	sec
	sbc	#'0'
	clc
	adc	ch
               sta	ch
	iny
	dex
	beq	casebreak0
	lda	[str],y
	and	#$FF
	cmp	#'0'
	bcc	casebreak
	cmp	#'9'+1
	bcc	numloop

casebreak	lda	ch
casebreak0	sta	[cp]
	inc	cp
	jne	loop
	inc	cp+2
	jmp	loop

breakloop	lda	#0
	sta	[cp]

	lda	space+1
	sta	end-2
	lda	space
	sta	end-3
	pld
	tsc
	clc
	adc	#end-4
	tcs
	
	rtl
 
dp1	dc	c'E^\:nrtbf',h'00'
dp2	dc	h'1b',c'^\:',h'0a0d09080c'

	END
