************************************************************************
*
* The GNO Shell Project
*
* Developed by:
*   Jawaid Bazyar
*   Tim Meekins
*
**************************************************************************
*
* JOBS.ASM
*   By Tim Meekins
*
* Job control handling routines
*
**************************************************************************

	mcopy	m/jobs.mac
	keep	o/jobs

WSTOPPED	gequ	$7F

SIGINT	gequ	 2
SIGKILL	gequ	 9
SIGTERM	gequ	15
SIGSTOP	gequ	17
SIGTSTP	gequ	18
SIGCONT	gequ	19
SIGCHLD	gequ	20
SIGTTIN	gequ	21
SIGTTOU	gequ	22
;
; process structure used in job control
;
p_next	gequ	0	;next in global proclist
p_friends	gequ	p_next+4	;next in job list
p_flags	gequ	p_friends+4	;various job status flags
p_reason	gequ	p_flags+2	;reason for entering this state
p_index	gequ	p_reason+2	;job index
p_pid	gequ	p_index+2	;process id
p_jobid	gequ	p_pid+2	;process id of job leader
p_command	gequ	p_jobid+2	;command (how job invoked)
p_space	gequ	p_command+4	;space for structure
;
; p_flags values
;
PRUNNING	gequ	%0000000000000001	;running
PSTOPPED	gequ	%0000000000000010  ;stopped
PNEXITED	gequ	%0000000000000100  ;normally exited
PAEXITED	gequ	%0000000000001000	;abnormally exited
PSIGNALED	gequ	%0000000000010000	;terminated by signal != SIGINT
PNOTIFY	gequ	%0000000000100000	;notify async when done
PTIME	gequ	%0000000001000000	;job times should be printed
PAWAITED       gequ	%0000000010000000  ;top level is waiting for it
PFOREGND       gequ	%0000000100000000  ;started in shells pgrp
PDUMPED        gequ	%0000001000000000  ;process dumped core
PDIAG          gequ	%0000010000000000  ;diagnostic output also piped out
PPOU           gequ	%0000100000000000  ;piped output
PREPORTED      gequ	%0001000000000000  ;status has been reported
PINTERRUPTED   gequ	%0010000000000000  ;job stopped via interrupt signal
PPTIME         gequ	%0100000000000000  ;time individual process
PNEEDNOTE      gequ	%1000000000000000  ;notify as soon as practicle

;====================================================================
;
; pwait - wait for foreground processes to finish up.
;
;====================================================================

pwait	START

	using	pdata

waitpid	equ	1
oldsig	equ	waitpid+2
p	equ	oldsig+4
space	equ	p+4
end	equ	space+3

;	subroutine (0:dummy),space

	tsc
	sec
	sbc	#space-1
	tcs
	phd
	tcd

	getpid
	sta	waitpid

waitloop	ldx	#%0000000000001010
	lda	#%0100000000000000
	sigblock @xa
	sta	oldsig
	stx	oldsig+2

	lda	pjoblist
	ldx	pjoblist+2

loop	sta	p
	stx	p+2

	ora	p+2
	beq	done
	ldy	#p_flags
	lda	[p],y
	and	#PFOREGND+PRUNNING
	cmp	#PFOREGND+PRUNNING
	bne	loop2
	ldy	#p_pid
	lda	[p],y
	cmp	waitpid
	beq	loop2

; check if the process is actually running..if it is not, report to the
; user that a stale process was detected and remove it from job control.

	sigsetmask oldsig
	sigpause #0
               bra	waitloop           
loop2	ldy	#p_next+2
	lda	[p],y
	tax
	ldy	#p_next
	lda	[p],y
	bra	loop

done	sigsetmask oldsig

	pld
	tsc
	clc
	adc	#end-4
	tcs

	rtl

	END

;====================================================================
;
; jobkiller - kills all jobs
;
;====================================================================

jobkiller	START

	using	pdata

p	equ	0
space	equ	p+4

	subroutine (0:dummy),space

loop	lda	pjoblist
	beq	done
	ldx	pjoblist+2
	beq	done
	sta	p
	stx	p+2
	ldy	#p_pid
	lda	[p],y
	kill	(@a,#SIGKILL)
	bra	loop

done	return

	END

;====================================================================
;
; palloc - allocate a process structure and fill it up
;
;====================================================================

palloc	START

	using	pdata
	using	global

pp	equ	1
space	equ	pp+4
cmd	equ	space+3
bg	equ	cmd+4
pid	equ	bg+2
end	equ	pid+2

;	subroutine (2:pid,2:bg,4:cmd),space

	tsc
	sec
	sbc	#space-1
	tcs
	phd
	tcd

	ldx	#%0000000000001000
	lda	#%0000000000000000
	sigblock @xa
	phx
	pha

	ph4	#p_space
	jsl	~NEW
	sta	pp
	stx	pp+2

	ldy	#p_pid	;set pid
	lda	pid
	sta	[pp],y
	ldy	#p_jobid
	sta	[pp],y

	lda	bg	;set running flags
	bne	bg00
	lda	#PRUNNING+PFOREGND
	bra	bg01
bg00	lda	#PRUNNING
bg01	ldy	#p_flags
	sta	[pp],y

	ldy	#p_next
	lda	pjoblist
	sta	[pp],y
	ldy	#p_next+2
	lda	pjoblist+2
	sta	[pp],y

	ldx	pp+2
	ldy	pp
	stx	pjoblist+2
	sty	pjoblist

	lda	pcurrent
	ora	pcurrent+2
	bne	in01
	stx	pcurrent+2
	sty	pcurrent
	bra	in02
in01	lda	pprevious
	ora	pprevious+2
	bne	in02
	stx	pprevious+2
	sty	pprevious
in02	anop

	ldy	#p_friends
	lda	#0
	sta	[pp],y
	ldy	#p_friends+2
	sta	[pp],y

	inc	pmaxindex	;set job number
	ldy	#p_index
	lda	pmaxindex
	sta	[pp],y

	pei	(cmd+2)
	pei	(cmd)
	jsr	cstrlen
	inc	a
	pea	0
	pha
	jsl	~NEW
	pei	(cmd+2)	
	pei	(cmd)
	phx
	pha
	ldy	#p_command	;set command
	sta	[pp],y
	txa
	ldy	#p_command+2
	sta	[pp],y
	jsr	copycstr

	lda	bg
	beq	noprint
	pei	(pp+2)
	pei	(pp)
	pea	1
	pea	0
	jsl	pprint
noprint	anop

	case	on
	jsl	sigsetmask
	case	off

	lda	space
	sta	end-3
	lda	space+1
	sta	end-2
	pld
	tsc
	clc
	adc	#end-4
	tcs

	rtl

	END

;====================================================================
;
; pallocpipe - allocate a process structure and fill it up and append
; to previous command pipeline.
;
;====================================================================

pallocpipe	START

	using	pdata
	using	global

p	equ	1
pp	equ	p+4
space	equ	pp+4
cmd	equ	space+3
bg	equ	cmd+4
pid	equ	bg+2
end	equ	pid+2

;	subroutine (2:pid,2:bg,4:cmd),space

	tsc
	sec
	sbc	#space-1
	tcs
	phd
	tcd

	ldx	#%0000000000001000
	lda	#%0000000000000000
	sigblock @xa
	phx
	pha

	ph4	#p_space
	jsl	~NEW
	sta	pp
	stx	pp+2

	ldy	#p_pid	;set pid
	lda	pid
	sta	[pp],y
	ldy	#p_jobid
	sta	[pp],y

	lda	bg	;set running flags
	bne	bg00
	lda	#PRUNNING+PFOREGND
	bra	bg01
bg00	lda	#PRUNNING
bg01	ldy	#p_flags
	sta	[pp],y

	ldy	#p_next
	lda	#0
	sta	[pp],y
	ldy	#p_next+2
	sta	[pp],y
	ldy	#p_friends
	sta	[pp],y
	ldy	#p_friends+2
	sta	[pp],y

	pei	(cmd+2)
	pei	(cmd)
	jsr	cstrlen
	inc	a
	pea	0
	pha
	jsl	~NEW
	pei	(cmd+2)	
	pei	(cmd)
	phx
	pha
	ldy	#p_command	;set command
	sta	[pp],y
	txa
	ldy	#p_command+2
	sta	[pp],y
	jsr	copycstr
;
; update the current pipeline to know about the last pipe.
;                     
	lda	pjoblist
	ldx	pjoblist+2
loop	sta	p
	stx	p+2
	ldy	#p_flags
	lda	[pp],y
	sta	[p],y
	ldy	#p_jobid
	lda	[pp],y
	sta	[p],y	
	ldy	#p_friends
	lda	[p],y
	ldy	#p_friends+2
	ora	[p],y
	beq	addit
	lda	[p],y
	tax
	ldy	#p_friends
	lda	[p],y
	bra	loop

addit	ldy	#p_friends
	lda	pp
	sta	[p],y
	ldy	#p_friends+2
	lda	pp+2
	sta	[p],y

	case	on
	jsl	sigsetmask	
	case	off

	lda	space
	sta	end-3
	lda	space+1
	sta	end-2
	pld
	tsc
	clc
	adc	#end-4
	tcs

	rtl

	END

;====================================================================
;
; handle a SIGCHLD signal
;
;====================================================================

pchild	START

	using	pdata
	using	global

waitstatus	equ	1
pid	equ	waitstatus+4	;just in case
p	equ	pid+2
space	equ	p+4
signum	equ	space+3
code	equ	signum+2
end	equ	code+2

;	subroutine (2:code,2:signum),space

	tsc
	sec
	sbc	#space-1
	tcs
	phd
	tcd

	phb
	phk
	plb

	stz	signum
;                                  
; get status for the process that just died
;
	ldx	#0
	clc
	tdc
	adc	#waitstatus
	wait	@xa
	sta	pid
;
; search for the job that has finished.
;
search	lda	pjoblist
	ldx	pjoblist+2
lookloop	sta	p
	stx	p+2
	ora	p+2
	jeq	done
	ldy	#p_jobid
	lda	[p],y
	cmp	pid
	beq	lookfound
	ldy	#p_next+2
	lda	[p],y
	tax
	ldy	#p_next
	lda	[p],y
	bra	lookloop
;
; see how wait was signaled.
;
lookfound	anop
	lda	waitstatus
	and	#$FF
	cmp	#WSTOPPED
	jne	kill
	lda	waitstatus
	xba
	and	#$FF	;<- signal number
	sta	signum
	cmp	#SIGTSTP
	beq	stop
	cmp	#SIGTERM
	jeq	zap
	cmp	#SIGINT
	beq	zap
	cmp	#SIGSTOP
	beq	stop
	cmp	#SIGTTIN	
	beq	stop
	cmp	#SIGTTOU	
	bne	zap

stop	ldy	#p_flags
	lda	[p],y
	eor	#PRUNNING
	ora	#PSTOPPED
	sta	[p],y
	pei	(p+2)
	pei	(p)
	jsr	mkjobcur
	ldy	#p_flags
	lda	[p],y
	bit	#PFOREGND
	beq	stop2
	tctpgrp (gshtty,gshpid)
stop2	pei	(p+2)
	pei	(p)
	pea	0
	pei	(signum)
	jsl	pprint
               bra	done          
kill	ldy	#p_flags
	lda	[p],y
	bit	#PFOREGND	;only set status variable if in
	beq	zap0               ; foreground
	lda	waitstatus
	jsr	setstatus
	bra	zap
zap0	inc	signalled
zap	ldy	#p_index
	lda	[p],y
	pha
	jsl	removejob
	ldy	#p_flags
	lda	[p],y
	bit	#PFOREGND
	beq	done
	tctpgrp (gshtty,gshpid)
                           
done	anop
	plb
	lda	space
	sta	end-3
	lda	space+1
	sta	end-2
	pld
	tsc
	clc
	adc	#end-4
	tcs
	
	rtl
;                     
; set status return variable
;
setstatus	ENTRY

	xba
	and	#$FF

	cmp	#100
	bcc	set1
	Int2Dec (@a,#valstat1+1,#3,#0)
	lda	#valstat1
	ldx	#^valstat1
	bra	set0

set1	cmp	#10
	bcc	set2
	Int2Dec (@a,#valstat2+1,#2,#0)
	lda	#valstat2
	ldx	#^valstat2
	bra	set0
                                             
set2	Int2Dec (@a,#valstat3+1,#1,#0)
	lda	#valstat3
	ldx	#^valstat3

set0	sta	SetParm+4
	stx	SetParm+6
	Set_Variable SetParm

	rts                          

SetParm	dc	a4'name'
	ds	4
name	str	'status'
valstat1	str	'000'
valstat2	str	'00'
valstat3	str	'0'

	END         

;====================================================================
;
; remove a job
;
;====================================================================

removejob	START

	using	pdata

p	equ	1
prev	equ	p+4
space	equ	prev+4
jobnum	equ	space+3
end	equ	jobnum+2

;	subroutine (2:jobnum),space

	tsc
	sec
	sbc	#space-1
	tcs
	phd
	tcd

	stz	prev  
	stz	prev+2
	lda	pjoblist
	ldx	pjoblist+2

loop	sta	p
	stx	p+2
	ora	p+2
	jeq	done
	ldy	#p_index
	lda	[p],y
	cmp	jobnum
	beq	gotit
	lda	p
	sta	prev
	stx	prev+2
	ldy	#p_next+2
	lda	[p],y
	tax
	ldy	#p_next
	lda	[p],y
	bra	loop
;
; adjust linked list pointers
;
gotit	ora2	prev,prev+2,@a
	beq	gotit2
	ldy	#p_next
	lda	[p],y
	sta	[prev],y
	ldy	#p_next+2
	lda	[p],y
	sta	[prev],y
	bra	gotit3
gotit2	ldy	#p_next
	lda	[p],y
	sta	pjoblist
	ldy	#p_next+2
	lda	[p],y
	sta	pjoblist+2
;
; free the node (may want to check currjob and prevjob pointers)
;
gotit3	anop

	ldy	#p_flags
	lda	[p],y
	and	#PFOREGND
	bne	gotit3c
	jsr	newline
	ldy	#p_flags
               lda	#0
	sta	[p],y
	pei	(p+2)
	pei	(p)
	pea	0
	pea 	0
	jsl	pprint
gotit3c	anop

	ldy	#p_command+2
	lda	[p],y
	pha
	dey2
	lda	[p],y
	pha
	jsl	nullfree

	lda	pcurrent
	eor	pcurrent+2
	eor	p
	eor	p+2
	bne	gotit3a
	mv4	pprevious,pcurrent
	stz	pprevious
	stz	pprevious+2
	lda	prev
	eor	prev+2
	eor	pcurrent
	eor	pcurrent+2
	beq	gotit3a
	mv4	prev,pprevious
gotit3a	lda	pprevious
	eor	pprevious+2
	eor	p
	eor	p+2
	bne	gotit3b
	stz	pprevious
	stz	pprevious+2
gotit3b	anop

gotit4	ldy	#p_friends
	lda	[p],y
	pha
	ldy	#p_friends+2
	lda	[p],y
	pha
	pei	(p+2)
	pei	(p)
	jsl	nullfree
               pla
	sta	P+2
	pla
	sta	p
	ora	p+2
	beq	gotit5	

	ldy	#p_command+2
	lda	[p],y
	pha
	ldy	#p_command
	lda	[p],y
	pha
	jsl	nullfree
	bra	gotit4

gotit5	anop
;
; find maximum job number
;	
	stz	prev
	lda	pjoblist
	ldx	pjoblist+2
fmaxloop	sta	p
	stx	p+2
	ora	p+2
	beq	gotmax
	ldy	#p_index
               lda	[p],y
	cmp	prev
	bcc	skipmax
	sta	prev
skipmax	ldy	#p_next+2
	lda	[p],y
	tax
	ldy	#p_next
	lda	[p],y
	bra	fmaxloop
gotmax	mv2	prev,pmaxindex	

done	anop
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

	END


;====================================================================
;
; mkjobcur
;
;====================================================================

mkjobcur	START

	using	pdata

space	equ	1
p	equ	space+2
end	equ	p+4

;	subroutine (4:p),space

	lda	p,s
	eor	p+2,s
	eor	pcurrent
	eor	pcurrent+2
	beq	done

	mv4	pcurrent,pprevious
	lda	p,s
	sta	pcurrent
	lda	p+2,s
	sta	pcurrent+2

done	lda	space,s
	sta	end-2,s
	tsc
	clc
	adc	#end-3
	tcs
	
	rts
                        
	END

**************************************************************************
*
* JOBS: builtin command
* syntax: exit
*
* displays jobs
*
**************************************************************************

jobs	START

	using	pdata

pidflag	equ	0
pp	equ	pidflag+2
count	equ	pp+4
space	equ	count+2

	subroutine (4:argv,2:argc),space

	stz	pidflag
	lda	argc
	dec	a
	beq	cont
	dec	a
	beq	grab
shit	ldx	#^Usage
	lda	#Usage
	jsr	errputs
	jmp	done

grab	ldy	#4
	lda	[argv],y
	sta	pp
	ldy	#4+2
	lda	[argv],y
	sta	pp+2
	lda	[pp]
	and	#$FF
	if2	@a,ne,#'-',shit
	ldy	#1
	lda	[pp],y
	if2	@a,ne,#'l',shit
	inc	pidflag	

cont	ld2	1,count
loop	lda	pjoblist
	ldx	pjoblist+2
loop2	sta	pp
	stx	pp+2
	ora	pp+2
	beq	next
	ldy	#p_index
	lda	[pp],y
	cmp	count
	beq	gotit
	ldy	#p_next+2
	lda	[pp],y
	tax
	ldy	#p_next
	lda	[pp],y
	bra	loop2

gotit	pei	(pp+2)
	pei	(pp)
	pei	(pidflag)
	pea	0
	jsl	pprint

next	inc	count
	lda	count
	cmp	pmaxindex
	beq	loop
	bcc	loop

done	return

Usage	dc	c'Usage: jobs [-l]',h'0d00'

	END

**************************************************************************
*
* KILL: builtin command
* syntax: kill [-sig] [pid ...]
*
* sends a [kill] signal to a process
*
**************************************************************************

kill	START

ptr	equ	1
arg	equ	ptr+4
signum	equ	arg+4
pid	equ	signum+2
space	equ	pid+2
argc	equ	space+3
argv	equ	argc+2
end	equ	argv+4

;	 subroutine (4:argv,2:argc),space

	tsc
	sec
	sbc	#space-1
	tcs
	phd
	tcd

	lda	argc
	dec	a
	bne	init

	ldx	#^Usage
	lda	#Usage	
	jsr	errputs
	jmp	done

init	stz	pid
	ld2	SIGTERM,signum

	dec	argc
	jeq	dokill
	add2	argv,#4,argv
	ldy	#2
	lda	[argv]
	sta	arg
	lda	[argv],y
	sta	arg+2
	lda	[arg]
	and	#$FF
	cmp	#'-'
	jne	getpid

	inc	arg

	lda	[arg]
	and	#$FF
	cmp	#'0'
	bcc	getname
	cmp	#'9'+1
	bcs	getname
	pei	(arg+2)
	pei	(arg)
	jsr	cstrlen
	tax
	Dec2Int (arg,@x,#0),signum

	lda	signum	;yeah, yeah, I know...
	bmi	ohshitnum
	cmp	#1
	bcc	ohshitnum
	cmp	#25
	bcc	next
	cmp	#30
	beq	next
	cmp	#31
	beq	next

ohshitnum	ldx	#^err1
	lda	#err1
	jsr	errputs
	jmp	done

getname	lda	[arg]
	cmp	#'l'
	beq	lister
	pei	(arg+2)
	pei	(arg)
	jsr	lowercstr
	ld2	1,signum
	ld4	names,ptr

nameloop	pei	(arg+2)
	pei	(arg)
	pei	(ptr+2)
	pei	(ptr)
	jsr	cmpcstr
	cmp	#0
	beq	next
	inc	signum
	add2	ptr,#8,ptr
	lda	signum
	cmp	#32
	bcc	nameloop

	ldx	#^err3
	lda	#err3
	jsr	errputs
	bra	done

next	dec	argc
	jeq	dokill
	add2	argv,#4,argv
	ldy	#2
	lda	[argv]
	sta	arg
	lda	[argv],y
	sta	arg+2

getpid	pei	(arg+2)
	pei	(arg)
	jsl	parsepid
	sta	pid
	cmp	#0
	beq	killnull
	cmp	#-1
	bne	dokill

	ldx	#^err2
	lda	#err2
	jsr	errputs
	bra	done

lister	ldx	#^liststr
	lda	#liststr
	jsr	puts
	bra	done

killnull	ldx	#^err4
	lda	#err4
	jsr	errputs
	bra	done

dokill	kill	(pid,signum)

done	lda	space
	sta	end-3
	lda	space+1
	sta	end-2
	pld
	tsc
	clc
	adc	#end-4
	tcs

	lda	#0

	rtl     

Usage	dc	c'Usage: kill [-signum | -signame] [pid | %jobid] ...',h'0d00'
err1	dc	c'kill: Invalid signal number.',h'0d00'
err2	dc	c'kill: No such job or pid.',h'0d00'
err3	dc	c'kill: Invalid signal name.',h'0d00'
err4	dc	c'kill: Killing the kernel null process isn''t such a good idea.',h'0d00'

liststr	dc	c'sighup sigint sigquit sigill sigtrap sigabrt sigemt '
	dc	c'sigfpe sigkill sigbus sigsegv sigsys sigpipe sigalrm '
	dc	c'sigterm sigurg sigstop sigtstp sigcont sigchld sigttin '
	dc	c'sigttou sigio sigxcpu sigusr1 sigusr2',h'0d00'

names	dc	c'sighup',h'0000'	;1
	dc	c'sigint',h'0000'  ;2
	dc	c'sigquit',h'00'   ;3
	dc	c'sigill',h'0000'  ;4
	dc	c'sigtrap',h'00'   ;5
	dc	c'sigabrt',h'00'   ;6
	dc	c'sigemt',h'0000'  ;7
	dc	c'sigfpe',h'0000'  ;8
	dc	c'sigkill',h'00'   ;9
	dc	c'sigbus',h'0000'  ;10
	dc	c'sigsegv',h'00'   ;11
	dc	c'sigsys',h'0000'  ;12
	dc	c'sigpipe',h'00'   ;13
	dc	c'sigalrm',h'00'   ;14
	dc	c'sigterm',h'00'   ;15
	dc	c'sigurg',h'0000'  ;16
	dc	c'sigstop',h'00'   ;17
	dc	c'sigtstp',h'00'   ;18
	dc	c'sigcont',h'00'   ;19
	dc	c'sigchld',h'00'   ;20
	dc	c'sigttin',h'00'   ;21
	dc	c'sigttou',h'00'   ;22
	dc	c'sigio',h'000000' ;23
	dc	c'sigxcpu',h'00'   ;24
	dc	h'0000000000000000' ;25
	dc	h'0000000000000000' ;26
	dc	h'0000000000000000' ;27
	dc	h'0000000000000000' ;28
	dc	h'0000000000000000' ;29
	dc	c'sigusr1',h'00'   ;30
	dc	c'sigusr2',h'00'   ;31
                                        
	END

**************************************************************************
*
* FG: builtin command
*
**************************************************************************

fg	START

               using	pdata
	using	global
	
pid	equ	0
p	equ	pid+2
space	equ	p+4

	subroutine (4:argv,2:argc),space

	lda	argc
	dec	a
	bne	getit
	ora2	pjoblist,pjoblist+2,@a
	jeq	whoashit
	mv4	pjoblist,p
	bra	dofg

getit	dec	a
	beq	getit2
	ldx	#^usage
	lda	#usage
	jmp	puterr
getit2	ldy	#4+2
	lda	[argv],y
	pha
	ldy	#4
	lda	[argv],y
	pha
	jsl	parsepid
	sta	pid
	cmp	#-1
	jeq	nojob
	mv4	pjoblist,p
loop	ora2	p,p+2,@a
	jeq	nojob
	ldy	#p_jobid
	lda	[p],y
	cmp	pid
	beq	dofg
	ldy	#p_next
	lda	[p],y
	tax
	ldy	#p_next+2
	lda	[p],y
	sta	p+2
	stx	p
	bra	loop	

dofg	ldy	#p_flags
	lda	[p],y
	and	#PFOREGND+PRUNNING
	cmp	#PFOREGND+PRUNNING
	bne	dofg1
	ldx	#^err02
	lda	#^err01
	bra	puterr
dofg1	lda	[p],y
	ora	#PRUNNING+PFOREGND
	sta	[p],y
	ldy	#p_jobid
	lda	[p],y
	tax
	tctpgrp (gshtty,@x)
	ldy	#p_flags
	lda	[p],y
	bit	#PSTOPPED
	beq	dofg2
;	lda	[p],y
	eor	#PSTOPPED
	sta	[p],y
	pei	(p+2)
	pei	(p)
	pea	0
	pea	0
	jsl	pprint
	ldy	#p_jobid
	lda	[p],y
	getpgrp @a
	eor	#$FFFF
	inc	a
	kill	(@a,#SIGCONT)
	bra	dofg3
dofg2	pei	(p+2)
	pei	(p)
	pea	0
	pea	0
	jsl	pprint
dofg3	jsl	pwait
	bra	done	

whoashit	ldx	#^err01
	lda	#err01
	bra	puterr
nojob	ldx	#^err03
	lda	#err03
puterr	jsr	errputs

done	return

usage	dc	c'Usage: fg [%job | pid]',h'0d00'
err01	dc	c'fg: No job to foreground.',h'0d00'
err02	dc	c'fg: Gee, this job is already in the foreground.',h'0d00'
err03	dc	c'fg: No such job.',h'0d00'

	END

**************************************************************************
*
* BG: builtin command
*
**************************************************************************

bg	START

               using	pdata
	using	global
	
pid	equ	0
p	equ	pid+2
space	equ	p+4

	subroutine (4:argv,2:argc),space

	lda	argc
	dec	a
	bne	getit
	ora2	pjoblist,pjoblist+2,@a
	jeq	whoashit
	mv4	pjoblist,p
	bra	dofg

getit	dec	a
	beq	getit2
	ldx	#^usage
	lda	#usage
	jmp	puterr
getit2	ldy	#4+2
	lda	[argv],y
	pha
	ldy	#4
	lda	[argv],y
	pha
	jsl	parsepid
	sta	pid
	cmp	#-1
	jeq	nojob
	mv4	pjoblist,p
loop	ora2	p,p+2,@a
	jeq	nojob
	ldy	#p_jobid
	lda	[p],y
	cmp	pid
	beq	dofg
	ldy	#p_next
	lda	[p],y
	tax
	ldy	#p_next+2
	lda	[p],y
	sta	p+2
	stx	p
	bra	loop	

dofg	ldy	#p_flags
	lda	[p],y
	bit	#PRUNNING
;	cmp	#PRUNNING
;	bne	dofg1
	beq	dofg1
	ldx	#^err02
	lda	#err02
	bra	puterr
dofg1	anop
;	lda	[p],y
	ora	#PRUNNING
	sta	[p],y
	bit	#PFOREGND
	beq	dobg0
;	lda	[p],y
	eor	#PFOREGND	
               sta	[p],y
dobg0	anop
;	lda	[p],y
	bit	#PSTOPPED
	beq	dofg2
;	lda	[p],y
	eor	#PSTOPPED
	sta	[p],y
	tctpgrp (gshtty,gshpid)
	pei	(p+2) 
	pei	(p)
	pea	0
	pea	0
	jsl	pprint
	ldy	#p_jobid
	lda	[p],y
	getpgrp @a
	eor	#$FFFF
	inc	a
	kill	(@a,#SIGCONT)
	bra	dofg3
dofg2	pei	(p+2)
	pei	(p)
	pea	0
	pea	0
	jsl	pprint
dofg3	bra	done

whoashit	ldx	#^err01
	lda	#err01
	bra	puterr
nojob	ldx	#^err03
	lda	#err03
puterr	jsr	errputs

done	return

usage	dc	c'Usage: bg [%job | pid]',h'0d00'
err01	dc	c'bg: No job to background.',h'0d00'
err02	dc	c'bg: Gee, this job is already in the background.',h'0d00'
err03	dc	c'bg: No such job.',h'0d00'

	END

**************************************************************************
*
* STOP: builtin command
*
**************************************************************************

stop	START

               using	pdata
	using	global
	
pid	equ	0
p	equ	pid+2
space	equ	p+4

	subroutine (4:argv,2:argc),space

	lda	argc
	dec	a
	bne	getit
	ora2	pjoblist,pjoblist+2,@a
	jeq	whoashit
	mv4	pjoblist,p
	bra	dofg

getit	dec	a
	beq	getit2
	ldx	#^usage
	lda	#usage
	jmp	puterr
getit2	ldy	#4+2
	lda	[argv],y
	pha
	ldy	#4
	lda	[argv],y
	pha
	jsl	parsepid
	sta	pid
	cmp	#-1
	jeq	nojob
	mv4	pjoblist,p
loop	ora2	p,p+2,@a
	jeq	nojob
	ldy	#p_jobid
	lda	[p],y
	cmp	pid
	beq	dofg
	ldy	#p_next
	lda	[p],y
	tax
	ldy	#p_next+2
	lda	[p],y
	sta	p+2
	stx	p
	bra	loop	

dofg	ldy	#p_flags
	lda	[p],y
	and	#PSTOPPED
	beq	dofg1
	ldx	#^err02
	lda	#err02
	bra	puterr
dofg1	tctpgrp (gshtty,gshpid)
	ldy	#p_jobid
	lda	[p],y
	getpgrp @a
	eor	#$FFFF
	inc	a
	kill	(@a,#SIGSTOP)
	bra	done	

whoashit	ldx	#^err01
	lda	#err01
	bra	puterr
nojob	ldx	#^err03
	lda	#err03
puterr	jsr	errputs

done	return

usage	dc	c'Usage: stop [%job | pid]',h'0d00'
err01	dc	c'stop: No job to stop.',h'0d00'
err02	dc	c'stop: Gee, this job is already stopped.',h'0d00'
err03	dc	c'stop: No such job.',h'0d00'

	END

;====================================================================
;
; print job
;
;====================================================================

pprint	START

	using	pdata

p	equ	0
count	equ	p+4
space	equ	count+2

	subroutine (4:pp,2:idflag,2:signum),space

	stz	count
;
; display job number
;
	lda	#'['
	jsr	putchar
	ldy	#p_index
	lda	[pp],y
	cmp	#10
	bcs	id10
	adc	#'0'	
	jsr	putchar
	lda	#']'
	jsr	putchar
	lda	#' '
	jsr	putchar
	bra	ida
id10	Int2Dec (@a,#dec10,#2,#0)
	ldx	#^dec10
	lda	#dec10
	jsr	puts
ida	lda	#' '
	jsr	putchar
;
; display '+' or '-'
;	
	if2	pp,ne,pcurrent,pcur1
	if2	pp+2,ne,pcurrent+2,pcur1
	lda	#'+'
	bra	pcur3
pcur1	if2	pp,ne,pprevious,pcur2
	if2	pp+2,ne,pprevious+2,pcur2
	lda	#'-'
	bra	pcur3
pcur2	lda	#' '
pcur3	jsr	putchar
	lda	#' '
	jsr	putchar
;
; display process id
;
	lda	idflag
	beq	stat
	ldy	#p_jobid
	lda	[pp],y
	Int2Dec (@a,#pidstr,#5,#0)
	ldx	#^pidstr
	lda	#pidstr
	jsr	puts
	ld2	6,count
;
; status
;
stat	ldy	#p_flags
	lda	[pp],y
	bit	#PRUNNING
	beq	stat2
	ldx	#^statrun
	lda	#statrun
	bra	stat0
stat2	bit	#PSTOPPED
	beq	stat3
	ldx	#^statstop
	lda	#statstop
	bra	stat0
stat3	ldx	#^statohshit
	lda	#statohshit
stat0	jsr	puts
;
; show signal
;
	lda	signum	
	beq	sig0
	if2	@a,ne,#SIGTTIN,sig2
               ldx	#^sigttinstr
	lda	#sigttinstr
	bra	sig1
sig2	if2	@a,ne,#SIGTTOU,sig3
               ldx	#^sigttoustr
	lda	#sigttoustr
	bra	sig1
sig3	ldx	#^sigotherstr
	lda	#sigotherstr	
sig1	phx
	pha
	jsr	puts
	jsr	cstrlen
	clc
	adc	count
	sta	count
sig0	anop
;
; display command
;
showcmd	ldy	#p_command
	lda	[pp],y
	sta	p
	ldy	#p_command+2
	lda	[pp],y
	sta	p+2
	ldy	#0
chloop	lda	[p],y
	and	#$FF
	beq	next
	phy
	jsr	putchar
	ply
	iny
	inc	count
	if2	count,cc,#60,chloop
showell	ldx	#^ellipsis
	lda	#ellipsis
	jsr	puts
	bra	cmd01

next	ldy	#p_friends
	lda	[pp],y
	pha
	ldy	#p_friends+2
	lda	[pp],y
	ora	1,s
	beq	donename
	lda	[pp],y
	sta	pp+2
	plx
	stx	pp
	if2	count,cs,#57,showell
	clc
	adc	#3
	sta	count
	ldx	#^pipestr
	lda	#pipestr
	jsr	puts
	bra	showcmd
	
donename	pla

	ldy	#p_flags
	lda	[pp],y
	and	#PFOREGND
	bne	cmd01
	ldx	#^ampstr
	lda	#ampstr
	jsr	puts

cmd01	anop

	jsr	newline

	return

dec10	dc	c'00]',h'00'
pidstr	dc	c'00000 ',h'00'
statrun	dc	c'Running ',h'00'
statstop	dc	c'Stopped ',h'00'
statohshit	dc	c'Done    ',h'00'
ampstr	dc	c' &',h'00'
ellipsis	dc	c'...',h'00'
pipestr	dc	c' | ',h'00'
sigttinstr	dc	c'(tty input) ',h'00'
sigttoustr	dc	c'(tty output) ',h'00'
sigotherstr	dc	c'(signal) ',h'00'

	END

;====================================================================
;
; parse process id (if starts with '%', then parse job num and
; concert to process id).
;
;====================================================================

parsepid	START

	using	pdata

p	equ	0
len	equ	p+4
pid	equ	len+2
space	equ	pid+2

	subroutine (4:str),space

	pei	(str+2)
	pei	(str)
	jsr	cstrlen
	sta	len
	lda	[str]
	and	#$FF
	cmp	#'%'
	beq	dojob
	cmp	#'0'
	jcc	nojob
	cmp	#'9'+1
	jcs	nojob
	Dec2Int (str,len,#0),pid
	jmp	done
dojob	ldy	#1
	lda	[str],y
	and	#$FF
	beq	docurjob
	if2	@a,eq,#'+',docurjob
	if2	@a,eq,#'%',docurjob
	if2	@a,ne,#'-',dojobnum
	lda	pprevious
	ldx	pprevious+2
	bra	gotjob
docurjob	lda	pcurrent
	ldx	pcurrent+2
	bra	gotjob
dojobnum	ldy	len
	dey
	ldx	str+2
	lda	str
	inc   a
	Dec2Int (@xa,@y,#0),pid
	lda	pjoblist
	ldx	pjoblist+2
	sta	p
	stx	p+2
loop	ora2	p,p+2,@a
	beq	nojob
	ldy	#p_index
	lda	[p],y
	cmp	pid
	beq	gotjob2
	ldy	#p_next
	lda	[p],y
	tax
	ldy	#p_next+2
	lda	[p],y
	sta	p+2
	stx	p
	bra	loop
gotjob	sta	p
	stx	p+2
gotjob2	ora2	p,p+2,@a
	beq	nojob
	ldy	#p_jobid
	lda	[p],y
	sta	pid
	bra	done
nojob	ld2	-1,pid

done	return 2:pid

	END

;====================================================================
;
; process data
;
;====================================================================

pdata	DATA

pwaitsem	dc	i2'0'

pjoblist	dc	i4'0'	;job list
pcurrent	dc	i4'0'	;current job in table
pprevious	dc	i4'0'	;previous job in table

pmaxindex	dc	i2'0'	;current maximum job index

	END
