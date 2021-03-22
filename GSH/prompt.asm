*************************************************************************
*
* The GNO Shell Project
*
* Developed by:
*   Jawaid Bazyar
*   Tim Meekins
*
**************************************************************************
*
* PROMPT.ASM
*   By Tim Meekins
*
* This displays the command-line prompt
*
**************************************************************************

               keep  o/prompt
               mcopy m/prompt.mac

WritePrompt    START

               using HistoryData


prompt	equ	0
hour           equ   prompt+4
minute         equ   hour+2
offset         equ   minute+2
space          equ   offset+2

year           equ   hour
monday         equ   minute
precmd         equ	prompt

               subroutine (0:dummy),space

	ph4	#precmdstr
	jsl	findalias
	sta	precmd
	stx	precmd+2
	ora	precmd+2
	beq	getvar

	pei	(precmd+2)
	pei	(precmd)
	ph2	#0
	jsl	execute

getvar	Read_Variable promptparm

               php
               sei		;interrupt free environment

               lda   promptbuf
               and   #$FF
               bne   parseprompt

	ldx	#^dfltPrompt
	lda	#dfltPrompt
	jsr	puts

               bra   donemark2

precmdstr	dc	c'precmd',h'00'

parseprompt    anop

	ph4	#promptbuf
	jsr	p2cstr
	phx		;for disposal
	pha
	stx	prompt+2
	sta	prompt

promptloop     lda   [prompt]
	inc	prompt
               and   #$FF
               beq   done
               cmp   #'%'
               beq   special
               cmp   #'!'
               jeq   phist
	cmp	#'\'
	jeq	quoteit
_putchar       jsr   putchar
               bra   promptloop

done           jsr	standend
	jsr	cursoron
	jsl	nullfree
donemark2      plp
	jsr	flush
               return

special        lda   [prompt]
	inc	prompt
               and   #$FF
               beq   done
               cmp   #'%'
               beq   _putchar
               cmp   #'h'
               beq   phist
               cmp   #'!'
               beq   phist
               cmp   #'t'
               beq   ptime
               cmp   #'@'
               beq   ptime
               cmp   #'S'
               jeq   pstandout
               cmp   #'s'
               jeq   pstandend
               cmp   #'U'
               jeq   punderline
               cmp   #'u'
               jeq   punderend
               cmp   #'d'
               jeq   pcwd
               cmp   #'/'
               jeq   pcwd
               cmp   #'c'
               jeq   pcwdend
               cmp   #'C'
               jeq   pcwdend
               cmp   #'.'
               jeq   pcwdend
               cmp   #'n'
               jeq   puser
               cmp   #'W'
               jeq   pdate1
               cmp   #'D'
               jeq   pdate2
	cmp	#'~'
	jeq	ptilde

               jmp   promptloop
;
; Put history number
;
phist          lda   lasthist
               inc   a
               jsr   WriteNum
               jmp   promptloop
;
; Print current time
;
ptime          ReadTimeHex (minute,hour,@a,@a)
               lda   hour
               and   #$FF
               if2   @a,cc,#13,ptime2
               sub2  @a,#12,@a
ptime2         if2	@a,ne,#0,ptime2b
	lda	#12
ptime2b	jsr   WriteNum
	lda	#':'
	jsr	putchar
               lda   minute
               xba
               and   #$FF
               pha
               cmp   #10
               bcs   ptime2a
	lda	#'0'
	jsr	putchar
ptime2a        pla
               jsr   WriteNum
               lda   hour
               and   #$FF
               if2   @a,cs,#12,ptime3
ptime5         lda   #'a'
               bra   ptime4
ptime3         lda   #'p'
ptime4         jsr   putchar
	lda	#'m'
	jmp	_putchar
;
; Set Stand Out
;
pstandout      jsr	standout
	jmp	promptloop
;
; UnSet Stand Out
;
pstandend      jsr	standend
	jmp	promptloop
;
; Set Underline
;
punderline     jsr	underline
	jmp	promptloop
;
; UnSet Underline
;
punderend      jsr	underend
	jmp	promptloop
;                             
; Current working directory
;
pcwd           GetPrefix GPParm
               dec   PfxLn
               ldx   #0
pcwd1          lda   PfxBuf,x
               and   #$FF
	jsr	toslash
         	phx
	jsr	putchar
               plx
               inx
               cpx   PfxLn
               bcc   pcwd1
               jmp   promptloop
;
; Current tail of working directory
;
pcwdend        GetPrefix GPParm
               dec   PfxLn
               ldx   PfxLn
pcwdend1       dex
               bmi   pcwdend2
               lda   PfxBuf,x
               and   #$FF
               cmp   #':'
               bne   pcwdend1
pcwdend2       inx
               cpx   PfxLn
               beq   pcwdend3
               lda   PfxBuf,x
               and   #$FF
               cmp   #':'
               beq   pcwdend3
               cmp   #'/'
               beq   pcwdend3
               phx
	jsr	putchar
               plx
               bra   pcwdend2
pcwdend3       jmp   promptloop
;
; Current working directory substituting '~' if necessary
;
ptilde         GetPrefix GPParm
               ldx   PfxLn
               lda   #0
               sta   PfxBuf,x
	ph4	#PfxBuf
	jsl	path2tilde
	phx
	pha
	jsr	puts
	jsl	~DISPOSE
               jmp   promptloop
;                          
; Write user name
;
puser          Read_Variable userparm
	ldx	#^buf2
	lda	#buf2
	jsr	putp
               jmp   promptloop
;
; Write date as mm/dd/yy
;
pdate1         ReadTimeHex (@a,year,monday,@a)
               lda   monday
               and   #$FF00
               xba
               inc   a
               jsr   WriteNum
	lda	#'/'
	jsr	putchar
               lda   monday
               and   #$FF
               inc   a
               jsr   WriteNum
	lda	#'/'
	jsr	putchar
               lda   year
               and   #$FF00
               xba
               jsr   WriteNum
               jmp   promptloop
;
; Write date as yy-mm-dd
;
pdate2         ReadTimeHex (@a,year,monday,@a)
               lda   year
               and   #$FF00
               xba
               jsr   WriteNum
	lda	#'-'
	jsr	putchar
               lda   monday
               and   #$FF00
               xba
               inc   a
               jsr   WriteNum
	lda	#'-'
	jsr	putchar
               lda   monday
               and   #$FF
               inc   a
               jsr   WriteNum
               jmp   promptloop
;
; check for \ quote
;
quoteit	lda   [prompt]
	inc	prompt
               and   #$FF
               jeq   done
	cmp	#'n'
	beq	newline
	cmp	#'r'
	beq	newline
	cmp	#'t'
	beq	tab
	cmp	#'b'
	beq	backspace
	jmp	_putchar
newline	lda	#13
	jmp	_putchar
tab	lda	#9
	jmp	_putchar
backspace	lda	#8
	jmp	_putchar
;                  
; Write a number between 0 and 9,999
; 
WriteNum       cmp   #10
               bcs   write1
               adc   #'0'
	jmp	putchar
write1         cmp   #100
               bcs   write2
               Int2Dec (@a,#num+2,#2,#0)
	ldx	#^num+2
	lda	#num+2
	jmp	puts
write2         cmp   #1000
               bcs   write3
               Int2Dec (@a,#num+1,#3,#0)
	ldx	#^num+1
	lda	#num+1
	jmp	puts
write3         Int2Dec (@a,#num,#4,#0)
	ldx	#^num
	lda	#num
	jmp	puts

GPParm         dc    i2'2'
               dc    i2'0'
               dc    a4'PfxOut'
promptparm     dc    a4'promptname'
               dc    a4'promptbuf'
promptname     str   'prompt'
dfltPrompt     dc    c'% ',h'00'
num            dc    c'0000',h'00'
promptbuf      ds    256
PfxOut         dc    i2'69'
PfxLn          ds    2
PfxBuf         ds    65
userparm       dc    a4'user'
               dc    a4'buf2'
user           str   'user'
buf2           ds    256

               END
