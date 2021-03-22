**************************************************************************
*
* The GNO Shell Project
*
* Developed by:
*   Jawaid Bazyar
*   Tim Meekins
*
**************************************************************************
*
* SHELL.ASM
*   By Tim Meekins
*
* This is the main routines for the shell.
*
**************************************************************************

               keep  o/shell
               mcopy m/shell.mac

SIGINT	gequ	 2
SIGTSTP	gequ	18
SIGCHLD	gequ	20

cmdbuflen      gequ  1024

               case  on
shell          start
               case  off

               using global
	using	pdata
	using	HistoryData

p	equ	0
space	equ	p+4

	subroutine (0:dummy),space

               tsc
               sta   cmdcontext
	tdc
	sta	cmddp

*               PushVariables 0

	Open	ttyopen
	bcc	settty
	ErrWriteCString #ttyerr
	jmp	quit
ttyerr	dc	c'gsh: Failed opening tty.',h'0d00'

settty	mv2	ttyref,gshtty
	tcnewpgrp gshtty
	settpgrp gshtty
	getpid
	sta	gshpid

	jsr	InitTerm

	lda	FastFlag
	bne	fastskip1
	ldx	#^gnostr
	lda	#gnostr
	jsr	puts
fastskip1	anop

	signal (#SIGINT,#signal2)
	signal (#SIGTSTP,#signal18)
	signal (#SIGCHLD,#pchild)
	setsystemvector #system
;
; Initialize some stuff
;
	lda	FastFlag
	bne	fastskip2
               jsr   ReadHistory	;Read in history from disk
fastskip2	jsr	initalias	;initialize alias
	jsr	InitDStack	;initialize directory stack
	lda	FastFlag
	bne	fastskip3
               jsr   DoLogin            ;Read gshrc
	jsr	newline
fastskip3	jsl   hashpath	;hash $path

	lda	CmdFlag
	beq	cmdskip

	mv4	CmdArgV,p
	ldy	#2
	lda	[p],y
	pha
	lda	[p]
	pha
	ph2	CmdArgc
	pei	(p+2)
	pei	(p)
	pea	0
	jsl	ShellExec
	jmp	done1

cmdskip	lda	ExecFlag
	beq	execskip

	ph4	ExecCmd
	ph2	#0
	jsl	Execute
               jmp	done1

execskip       anop

	stz	lastabort

gnoloop        entry

	phk
	plb

               lda   cmdcontext	;dare you to make a mistake
               tcs
	lda	cmddp
	tcd

               jsl   WritePrompt
               jsr   GetCmdLine
               bcs   done
	jsr	newline
               lda   cmdlen
               beq   gnoloop
	jsr	cursoron
	jsr	newlineX
	jsr	flush
               ph4   #cmdline
	ph2	#0
               jsl   execute
	lda	exitamundo
	bne	done1
               jsr   newlineX
	stz	lastabort
               bra   gnoloop
;
; shut down gsh
;
done           jsr	newline
	jsr	newlineX
done1	ora2  pjoblist,pjoblist+2,@a
	beq	done2
               lda	lastabort
	bne	donekiller
	inc	lastabort
	stz	exitamundo
	ldx	#^stopstr
	lda	#stopstr
	jsr	puts
	jsr	newlineX
	bra	gnoloop
donekiller	jsl	jobkiller
done2	lda	FastFlag
	bne	fastskip5
	jsr   SaveHistory
fastskip5	jsr   dispose_hash

quit	PopVariables 0
	Quit  QuitParm
QuitParm       dc    i'0'

gnostr         dc    h'0d',c'GNO/Shell 1.1b05',h'0d'
               dc    c'Copyright 1991-1993, Procyon, Inc. & Tim Meekins. '
               dc    c'ALL RIGHTS RESERVED',h'0d'
               dc    h'0d00'
stopstr	dc	c'gsh: There are stopped jobs.',h'0d00'

ttyopen	dc	i2'2'
ttyref	dc	i2'0'
	dc	i4'ttyname'
ttyname	gsstr	'.tty'

exitstr	dc	c'000000',h'0d00'

lastabort	ds	2

               END                       

;=========================================================================
;
; Interpret the login file (gshrc)
;
;=========================================================================

DoLogin        START

	ph4	#file
	lda	#0
	pha
	pha
	pha
	pea	0
	jsl	shellexec

	rts

file	dc	c'@:gshrc',h'00'

               END

;=========================================================================
;
; GLOBAL data
;
;=========================================================================

global         DATA

ID             ds    2
GSOSDP         ds    2
cmdloc         ds    2
cmdlen         ds    2
cmdline        ds    cmdbuflen
buffer         ds    256
wordlen	ds	2
wordpbuf	ds	1
wordbuf	ds	256
nummatch	ds	2
matchbuf	ds	512*4
cmdcontext     ds    2
cmddp	ds	2
gshtty	ds	2
gshpid         ds	2
exitamundo     dc    i'0'               ;!=0 if exit
signalled	dc	i'0'

FastFlag	dc	i'0'
CmdFlag	dc	i'0'
CmdArgV	ds	4
CmdArgC	ds	2
ExecFlag	dc	i'0'
ExecCmd	ds	4

               END

;=========================================================================
;
; SIGINT handler when typed at command-line
;
;=========================================================================

signal2	START

	using	global

	subroutine (4:fubar),0
	WriteCString #msg
	inc	signalled
	ld2	$80,$E0C000
	return

msg	dc	c'^C',h'0d0a00'

	END

;=========================================================================
;
; SIGTSTP handler when typed at command-line
;
;=========================================================================

signal18	START

	using	global

	subroutine (4:fubar),0
	WriteCString #msg
	inc	signalled
	ld2	$80,$E0C000
	return           

msg	dc	c'^Z',h'0d0a00'

	END
