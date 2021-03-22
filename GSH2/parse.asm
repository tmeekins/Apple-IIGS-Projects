***********************************************************************
* CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL CONFIDENTIAL *
***********************************************************************
                                                                       
**************************************************************************
*                            
* GNO/Shell 2.0
* parses a token list into a command
*
* Written by Tim Meekins and Jawaid Bazyar
* Copyright (C) 1993 by Tim Meekins & Procyon Enterprises, Inc.
*
**************************************************************************

	keep	o/parse
	mcopy	m/parse.mac
	copy	parse.inc
	copy	lex.inc
	copy	error.inc

**************************************************************************
*                            
* freecmdlist
*    - deallocate a command list
*
* entry
*    ph4 cmd	- (command *)
*
**************************************************************************
                              
freecmdlist	START

space	equ	1
cmd	equ	space+2
end	equ	cmd+4

	tsc
	phd
	tcd

loop	lda	<cmd
	ora	<cmd+2
	beq	exit

	ldy	#CMD_argv+2
	lda	[<cmd],y
	pha
	ldy	#CMD_argv
	lda	[<cmd],y
	pha
	jsr	freetoklist

	ldy	#CMD_stdinfile+2
	lda	[<cmd],y
	pha
	ldy	#CMD_stdinfile
	lda	[<cmd],y
	pha
	jsr	freetoklist

	ldy	#CMD_stderrfile+2
	lda	[<cmd],y
	pha
	ldy	#CMD_stderrfile
	lda	[<cmd],y
	pha
	jsr	freetoklist

	ldy	#CMD_stdoutfile+2
	lda	[<cmd],y
	pha
	ldy	#CMD_stdoutfile
	lda	[<cmd],y
	pha
	jsr	freetoklist

	ldy	#CMD_sequence+2
	lda	[<cmd],y
	pha
	ldy	#CMD_sequence
	lda	[<cmd],y
	pha
	jsr	freecmdlist

	pei	(<cmd+2)
	pei	(<cmd)

	ldy	#CMD_sequence+2
	lda	[<cmd],y
	tax
	ldy	#CMD_sequence
	lda	[<cmd],y
	sta	<cmd
	stx	<cmd+2

	pla
	plx
	jsr	freecmd

	bra	loop

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
* parse
*    - parse a token list into a command
*
* entry
*    ph4 inp_ptr	- (token *)
*    ph2 cl_paren
*
**************************************************************************
                              
parse	START

retval	equ	0
prev_type	equ	retval+4
prev	equ	prev_type+2
inp	equ	prev+4
newChain	equ	inp+4
head	equ	newChain+4
tail           equ	head+4
new            equ	tail+4
space	equ	new+4

	subroutine (4:inp_ptr,2:cl_paren),space

	stz	<retval
	stz	<retval+2

	lda	[<inp_ptr]	;derefernce the token list
	sta	<inp
	ldy	#2
	lda	[<inp_ptr],y
	sta	<inp+2

	stz	<head
	stz	<head+2
	stz	<tail
	stz	<tail+2

	jsr	alloccmd	;allocate a new command node
	sta	<new
	stx	<new+2
	sta	<newChain
	stx	<newChain

	ldy	#CMD_stdin
	lda	#RD_NONE
	sta	[<new],y

new_new	anop

	lda	<inp
	sta	<prev
	lda	<inp+2
	sta	<prev+2

	lda	<head
	ora	<head+2
	bne	new1

	lda	<new
	sta	<head
	lda	<new+2
	sta	<head+2

new1	lda	<tail
	ora	<tail+2
	beq	new2

	ldy	#CMD_next
	lda	<new
	sta	[<tail],y
	ldy	#CMD_next+2
	lda	<new+2
	sta	[<tail],y

new2	lda	<new
	sta	<tail
	lda	<new+2
	sta	<tail+2

	lda	#0
	ldy	#CMD_next
	sta	[<new],y
	ldy	#CMD_next+2
	sta	[<new],y
	ldy	#CMD_argv
	sta	[<new],y
	ldy	#CMD_argv+2
	sta	[<new],y	
	ldy	#CMD_flags
	sta	[<new],y

	lda	#RD_NONE
	ldy	#CMD_stdout
	sta	[<new],y
	ldy	#CMD_stderr
	sta	[<new],y	

whileloop	lda	<inp
	ora	<inp+2
	jeq	endwhile

	ldy	#TOK_type
	lda	[<inp],y
	sta	<prev_type
	tax
	jmp	(!jmptbl,x)

jmptbl	dc	i2'tok_word'
	dc	i2'tok_singquote'
	dc	i2'tok_dblquote'
	dc	i2'tok_backquote'
	dc	i2'tok_pipe'
	dc	i2'tok_amp'
	dc	i2'tok_lt'
	dc	i2'tok_gt'
	dc	i2'tok_gtgt'
	dc	i2'tok_gtamp'
	dc	i2'tok_gtgtamp'
	dc	i2'tok_cr'
	dc	i2'tok_semi'
	dc	i2'tok_open'
	dc	i2'tok_close'
	dc	i2'tok_pipeamp'

tok_word	anop
tok_singquote	anop
tok_dblquote	anop
tok_backquote	anop

;
; turn keywords into tokens
;

	lda	<inp
	sta	<prev
	lda	<inp+2
	sta	<prev+2

	ldy	#CMD_argv
	lda	[<new],y
	ldy	#CMD_argv+2
	ora	[<new],y
	jne	nextwhile

	lda	<prev+2
	sta	[<new],y
	ldy	#CMD_argv
	lda	<prev
	sta	[<new],y

	lda	<prev_type
	cmp	#T_WORD
	bne	word01




word01	jmp	nextwhile

tok_lt	anop
      
	ldy	#CMD_stdin
	lda	[<new],y
	beq	lt01
	cmp	#RD_PIPE
	bne   lt00a
	pea	APP_GSH
	pea	ERR_PIPE_LT_CONFLICTS
	jsr	shellerror
	jmp	errorexit
lt00a	pea	APP_GSH
	pea	ERR_EXTRA_LT
	jsr	shellerror
	jmp	errorexit

lt01	ldy	#TOK_next
	lda	[<inp],y
	lda	#TOK_next+2
	ora	[<inp],y
	bne	lt02
lt04	pea	APP_GSH
	pea	ERR_NO_FILE_LT
	jsr	shellerror
	jmp	errorexit

lt02	pei	(<inp+2)
	pei	(<inp)
	lda	[<inp],y
	tax
	ldy	#TOK_next
	lda	[<inp],y
	sta	<inp
	stx	<inp+2
	pla
	plx
	jsr	freetoken
	ldy	#TOK_next
	lda	[<inp],y
	sta	[<prev],y
	ldy	#TOK_next+2
	lda	[<inp],y
	sta	[<prev],y

	ldy	#TOK_type
	lda	[<inp],y
	cmp	#T_WORD
	beq	lt03
	cmp	#T_SINGQUOTE
	beq	lt03
	cmp	#T_DBLQUOTE
	bne	lt04
	
lt03	ldy	#CMD_stdin
	lda	#RD_FILE
	sta	[<new],y
	ldy	#CMD_stdinfile
	lda	<inp
	sta	[<new],y
	ldy	#CMD_stdinfile+2
	lda	<inp+2
	sta	[<new],y

	ldy	#TOK_next+2
	lda	[<inp],y
	pha
	ldy	#TOK_next
	lda	[<inp],y
	pha
	lda	#0
	sta	[<inp],y
	ldy	#TOK_next+2
	sta	[<inp],y
	pla
	sta	<inp
	pla
	sta	<inp+2
	jmp	whileloop
	
tok_gt	anop
tok_gtgt	anop

	ldy	#CMD_stdout
	lda	[<new],y
	beq	gt01
	pea	APP_GSH
	pea	ERR_EXTRA_GT
	jsr	shellerror
	jmp	errorexit

gt01	ldy	#TOK_next
	lda	[<inp],y
	lda	#TOK_next+2
	ora	[<inp],y
	bne	gt02
gt04	pea	APP_GSH
	pea	ERR_NO_FILE_GT
	jsr	shellerror
	jmp	errorexit

gt02	pei	(<inp+2)
	pei	(<inp)
	lda	[<inp],y
	tax
	ldy	#TOK_next
	lda	[<inp],y
	sta	<inp
	stx	<inp+2
	pla
	plx
	jsr	freetoken
	ldy	#TOK_next
	lda	[<inp],y
	sta	[<prev],y
	ldy	#TOK_next+2
	lda	[<inp],y
	sta	[<prev],y

	ldy	#TOK_type
	lda	[<inp],y
	cmp	#T_WORD
	beq	gt03
	cmp	#T_SINGQUOTE
	beq	gt03
	cmp	#T_DBLQUOTE
	bne	gt04
	
gt03	lda	<prev_type
	cmp	#T_GT
	bne	gt03a
	lda	#RD_FILE
	bra	gt03b
gt03a	lda	#RD_APP
gt03b	ldy	#CMD_stdout
	sta	[<new],y
	ldy	#CMD_stdoutfile
	lda	<inp
	sta	[<new],y
	ldy	#CMD_stdoutfile+2
	lda	<inp+2
	sta	[<new],y

	ldy	#TOK_next+2
	lda	[<inp],y
	pha
	ldy	#TOK_next
	lda	[<inp],y
	pha
	lda	#0
	sta	[<inp],y
	ldy	#TOK_next+2
	sta	[<inp],y
	pla
	sta	<inp
	pla
	sta	<inp+2
	jmp	whileloop

tok_gtamp	anop
tok_gtgtamp	anop

	ldy	#CMD_stderr
	lda	[<new],y
	beq	gtamp01
	pea	APP_GSH
	pea	ERR_EXTRA_GTAMP
	jsr	shellerror
	jmp	errorexit

gtamp01	ldy	#TOK_next
	lda	[<inp],y
	lda	#TOK_next+2
	ora	[<inp],y
	bne	gtamp02
gtamp04	pea	APP_GSH
	pea	ERR_NO_FILE_GT
	jsr	shellerror
	jmp	errorexit

gtamp02	pei	(<inp+2)
	pei	(<inp)
	lda	[<inp],y
	tax
	ldy	#TOK_next
	lda	[<inp],y
	sta	<inp
	stx	<inp+2
	pla
	plx
	jsr	freetoken
	ldy	#TOK_next
	lda	[<inp],y
	sta	[<prev],y
	ldy	#TOK_next+2
	lda	[<inp],y
	sta	[<prev],y

	ldy	#TOK_type
	lda	[<inp],y
	cmp	#T_WORD
	beq	gtamp03
	cmp	#T_SINGQUOTE
	beq	gtamp03
	cmp	#T_DBLQUOTE
	bne	gtamp04
	
gtamp03	lda	<prev_type
	cmp	#T_GTAMP
	bne	gtamp03a
	lda	#RD_FILE
	bra	gtamp03b
gtamp03a	lda	#RD_APP
gtamp03b	ldy	#CMD_stderr
	sta	[<new],y
	ldy	#CMD_stderrfile
	lda	<inp
	sta	[<new],y
	ldy	#CMD_stderrfile+2
	lda	<inp+2
	sta	[<new],y

	ldy	#TOK_next+2
	lda	[<inp],y
	pha
	ldy	#TOK_next
	lda	[<inp],y
	pha
	lda	#0
	sta	[<inp],y
	ldy	#TOK_next+2
	sta	[<inp],y
	pla
	sta	<inp
	pla
	sta	<inp+2
	jmp	whileloop

tok_semi	anop
tok_cr	anop
tok_amp	anop

	ldy	#CMD_argv
	lda	[<new],y
	ldy	#CMD_argv+2
	ora	[<new],y
	bne	semi01

	ldy	#CMD_stdin
	lda	[<new],y
	ldy	#CMD_stdout
	ora	[<new],y
	ldy	#CMD_stdin
	ora	[<new],y
	beq	semi01
	
	pea	APP_GSH
	pea	ERR_NULL_COMMAND
	jsr	shellerror
	jmp	errorexit
               
semi01	ldy	#TOK_type
	lda	[<inp],y
	cmp	#T_AMP
	bne	semi02

	lda	#FL_BACKGROUND
	ldy	#CMD_flags
	ora	[<new],y
	sta	[<new],y

semi02	pei	(<inp+2)
	pei	(<inp)
	ldy	#TOK_next+2
	lda	[<inp],y
	tax
	ldy	#TOK_next
	lda	[<inp],y
	sta	<inp
	stx	<inp+2
	pla
	plx
	jsr	freetoken
	lda	#0
	ldy	#TOK_next
	sta	[<prev],y
	ldy	#TOK_next+2
	sta	[<prev],y

	jsr	alloccmd
	pha
	ldy	#CMD_next
	sta	[<new],y
	txa
	ldy	#CMD_next
	sta	[<new],y
	sta	<new+2
	pla
	sta	<new
	ldy	#CMD_stdin
	lda	#RD_NONE
	sta	[<new],y

	jmp	new_new

tok_pipe	anop
tok_pipeamp	anop

	ldy	#CMD_argv
	lda	[<new],y
	ldy	#CMD_argv+2
	ora	[<new],y
	bne	pipe01

	pea	APP_GSH
	pea	ERR_NULL_COMMAND
	jsr	shellerror
	jmp	errorexit
               
pipe01	ldy	#CMD_stdout
	lda	[<new],y
	beq	pipe02

	pea	APP_GSH
	pea	ERR_PIPE_CONFLICTS
	jsr	shellerror
	jmp	errorexit

pipe02	lda	#RD_PIPE
	sta	[<new],y

	lda	#TOK_type
	lda	[<inp],y
	cmp	#T_PIPEAMP
	bne	pipe04

	ldy	#CMD_stderr
	lda	[<new],y
	beq	pipe03
	
	pea	APP_GSH
	pea	ERR_PIPE_ERR_CONFL
	jsr	shellerror
	jmp	errorexit

pipe03	lda	#RD_PIPE
	sta	[<new],y

pipe04	pei	(<inp+2)
	pei	(<inp)
	ldy	#TOK_next+2
	lda	[<inp],y
	tax
	ldy	#TOK_next
	lda	[<inp],y
	sta	<inp
	stx	<inp+2
	pla
	plx
	jsr	freetoken
	lda	#0
	ldy	#TOK_next
	sta	[<prev],y
	ldy	#TOK_next+2
	sta	[<prev],y

	jsr	alloccmd
	pha
	ldy	#CMD_next
	sta	[<new],y
	txa
	ldy	#CMD_next
	sta	[<new],y
	sta	<new+2
	pla
	sta	<new
	ldy	#CMD_stdin
	lda	#RD_PIPE
	sta	[<new],y

	jmp	new_new

tok_open	anop

	ldy	#CMD_argv
	lda	[<new],y
	ldy	#CMD_argv+2
	ora	[<new],y
	beq	open01

	


open01         anop

tok_close	anop

nextwhile	ldy	#TOK_next+2
	lda	[<inp],y
	tax
	ldy	#TOK_next
	lda	[<inp],y
	sta	<inp
	stx	<inp+2
	jmp	whileloop

endwhile       anop


errorexit	ldy	#CMD_argv
	lda	[<new],y
	ldy	#CMD_argv+2
	ora	[<new],y
	bne	errorexit2
	lda	[<new],y
	tax
	ldy	#CMD_argv
	lda	[<new],y
	jsr	freetoklist
errorexit2	lda	<head
	ldx	<head
	jsr	freecmdlist

exit	return 4:retval

	END

**************************************************************************
*                            
* parsedata
*
**************************************************************************
                              
parsedata	DATA

keywords	dc	i2'key00'
	dc	i2'key01'
	dc	i2'key02'
	dc	i2'key03'
	dc	i2'key04'
	dc	i2'key05'
	dc	i2'key06'
	dc	i2'key07'
	dc	i2'key08'
	dc	i2'key09'
	dc	i2'key10'
	dc	i2'key11'
	dc	i2'key12'
	dc	i2'key13'
	dc	i2'key14'
	dc	i2'key15'
                              
key00	dc	c'break',h'00'
key01	dc	c'brksw',h'00'
key02	dc	c'case',h'00'
key03	dc	c'else',h'00'
key04	dc	c'end',h'00'
key05	dc	c'endif',h'00'
key06	dc	c'endsw',h'00'
key07	dc	c'exit',h'00'
key08	dc	c'foreach',h'00'
key09	dc	c'goto',h'00'
key10	dc	c'if',h'00'
key11	dc	c'set',h'00'
key12	dc	c'switch',h'00'
key13	dc	c'test',h'00'
key14	dc	c'then',h'00'
key15	dc	c'while',h'00'

keytokens	dc	i2'T_BREAK'
	dc	i2'T_BRKSW'
	dc	i2'T_CASE'
	dc	i2'T_ELSE'
	dc	i2'T_END'
	dc	i2'T_ENDIF'
	dc	i2'T_ENDSW'
	dc	i2'T_EXIT'
	dc	i2'T_FOREACH'
	dc	i2'T_GOTO'
	dc	i2'T_IF'
	dc	i2'T_SET'
	dc	i2'T_SWITCH'
	dc	i2'T_TEST'
	dc	i2'T_THEN'
	dc	i2'T_WHILE'
                             
	END
