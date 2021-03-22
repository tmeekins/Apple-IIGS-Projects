***********************************************************************
* CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL CONFIDENTIAL *
***********************************************************************
                                                                       
**************************************************************************
*                            
* GNO/Shell 2.0
* Routines for maintaining pools of buffers and heaps.
*
* Written by Tim Meekins
* Copyright (C) 1993 by Tim Meekins & Procyon Enterprises, Inc.
*
**************************************************************************
*
* Contains anal rententive paranoid checking code...remove before final
*
**************************************************************************
 
               keep  o/bufpool
               mcopy m/bufpool.mac
	copy	lex.inc
	copy	parse.inc

**************************************************************************
*
* get a buffer of size 256
*
**************************************************************************

alloc256	START

	using	bufpool

	lock	pool256mutex

	lda	pool256
	ora	pool256+2
	beq	allocbuf

	phd
	ph4	pool256
	tsc
	tcd
	lda	[1]
	sta	pool256
	ldy	#2
	lda	[1],y
	sta	pool256+2
	unlock pool256mutex
               pla
	plx
	pld
	rts

allocbuf	unlock pool256mutex
	ph4	#256
	jsl	~NEW
	rts
	
	END

**************************************************************************
*
* free a buffer of size 256
*
**************************************************************************

free256	START

	using bufpool

	phd
	phx
	pha
	tsc
	tcd
	lock pool256mutex
	lda	pool256
	sta	[1]
	ldy	#2
	lda	pool256+2
	sta	[1],y
	lda	1
	sta	pool256
	lda	3
	sta	pool256+2
;
; paranoid check to see if we've already freed this block
;
anal           lda	[1],y
	tax
	lda	[1]
	sta	1
	stx	3
	ora	3
	beq	done
	lda	[1]
	cmp	pool256
	bne	anal
	lda	[1],y
	cmp	pool256+2
	bne	anal

	lda	#err
	ldx	#^err
	jsr	errputs

done	anop

	unlock pool256mutex
	pla
	plx	
	pld
	rts

err	dc	c'free256 PANIC!',h'0d00'

	END

**************************************************************************
*
* get a buffer of size 1024
*
**************************************************************************

alloc1024	START

	using	bufpool

	lock	pool1024mutex

	lda	pool1024
	ora	pool1024+2
	beq	allocbuf

	phd
	ph4	pool1024
	tsc
	tcd
	lda	[1]
	sta	pool1024
	ldy	#2
	lda	[1],y
	sta	pool1024+2
	unlock pool1024mutex
               pla
	plx
	pld
	rts

allocbuf	unlock pool1024mutex
	ph4	#1024
	jsl	~NEW
	rts

	END

**************************************************************************
*
* free a buffer of size 1024
*
**************************************************************************

free1024	START

	using bufpool

	phd
	phx
	pha
	tsc
	tcd
	lock pool1024mutex
	lda	pool1024
	sta	[1]
	ldy	#2
	lda	pool1024+2
	sta	[1],y
	lda	1
	sta	pool1024
	lda	3
	sta	pool1024+2
;
; paranoid check to see if we've already freed this block
;
anal           lda	[1],y
	tax
	lda	[1]
	sta	1
	stx	3
	ora	3
	beq	done
	lda	[1]
	cmp	pool1024
	bne	anal
	lda	[1],y
	cmp	pool1024+2
	bne	anal

	lda	#err
	ldx	#^err
	jsr	errputs

done	anop

	unlock pool1024mutex
	pla
	plx	
	pld
	rts

err	dc	c'free1024 PANIC!',h'0d00'

	END

**************************************************************************
*
* allocate a token node
*
**************************************************************************

alloctoken	START

	using	bufpool

	lock	pooltokenmutex

	lda	pooltoken
	ora	pooltoken+2
	beq	allocbuf

	phd
	ph4	pooltoken
	tsc
	tcd
	lda	[1]
	sta	pooltoken
	ldy	#2
	lda	[1],y
	sta	pooltoken+2
	unlock pooltokenmutex
               pla
	plx
	pld
	rts

allocbuf	unlock pooltokenmutex
	ph4	#TOK_sizeof
	jsl	~NEW
	rts

	END

**************************************************************************
*
* free a token node
*
**************************************************************************

freetoken	START

	using bufpool

	phd
	phx
	pha
	tsc
	tcd
	lock pooltokenmutex
	lda	pooltoken
	sta	[1]
	ldy	#2
	lda	pooltoken+2
	sta	[1],y
	lda	1
	sta	pooltoken
	lda	3
	sta	pooltoken+2
;
; paranoid check to see if we've already freed this block
;
anal           lda	[1],y
	tax
	lda	[1]
	sta	1
	stx	3
	ora	3
	beq	done
	lda	[1]
	cmp	pooltoken
	bne	anal
	lda	[1],y
	cmp	pooltoken+2
	bne	anal

	lda	#err
	ldx	#^err
	jsr	errputs

done	anop

	unlock pooltokenmutex
	pla
	plx	
	pld
	rts

err	dc	c'freetoken PANIC!',h'0d00'

	END             

**************************************************************************
*
* allocate a command node
*
**************************************************************************

alloccmd	START

	using	bufpool

	lock	poolcmdmutex

	lda	poolcmd
	ora	poolcmd+2
	beq	allocbuf

	phd
	ph4	poolcmd
	tsc
	tcd
	lda	[1]
	sta	poolcmd
	ldy	#2
	lda	[1],y
	sta	poolcmd+2
	unlock poolcmdmutex
               pla
	plx
	pld
	rts

allocbuf	unlock poolcmdmutex
	ph4	#CMD_sizeof
	jsl	~NEW
	rts

	END

**************************************************************************
*
* free a command node
*
**************************************************************************

freecmd	START

	using bufpool

	phd
	phx
	pha
	tsc
	tcd
	lock 	poolcmdmutex
	lda	poolcmd
	sta	[1]
	ldy	#2
	lda	poolcmd+2
	sta	[1],y
	lda	1
	sta	poolcmd
	lda	3
	sta	poolcmd+2
;
; paranoid check to see if we've already freed this block
;
anal           lda	[1],y
	tax
	lda	[1]
	sta	1
	stx	3
	ora	3
	beq	done
	lda	[1]
	cmp	poolcmd
	bne	anal
	lda	[1],y
	cmp	poolcmd+2
	bne	anal

	lda	#err
	ldx	#^err
	jsr	errputs

done	anop

	unlock poolcmdmutex
	pla
	plx	
	pld
	rts

err	dc	c'freecmd PANIC!',h'0d00'

	END              

**************************************************************************
*
* buffer pool data
*
**************************************************************************

bufpool	PRIVDATA

pool256	dc	i4'0'
pool256mutex	key
pool1024	dc	i4'0'
pool1024mutex	key
pooltoken	dc	i4'0'
pooltokenmutex	key
poolcmd	dc	i4'0'
poolcmdmutex	key
                               
	END
