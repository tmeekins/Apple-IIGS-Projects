**************************************************************************
*
* Tim's Virtual Memory Manager v1.1
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
* TVMM Requires that BSI is active.
*
**************************************************************************
*
* tvmm.asm
*
* This is the entire code for TVMM
*
**************************************************************************

	mcopy	m/tvmm.mac

; 	copy	tvmm.h
;
; Constants
;
MAX_HANDLES	gequ	2048	; Maximum number of handles allowed
MAX_BLOCKS	gequ	256	; Maximum number of blocks allowed
BLOCK_SIZE	gequ	32768	; Size of block
;
; Block Node Structure
;
TVBN_time	gequ	0	; Time of last access
TVBN_next	gequ	TVBN_time+4	; Next Block in list
TVBN_handles	gequ	TVBN_next+2	; Pointer to list of handles
TVBN_filenum	gequ	TVBN_handles+2	; Swap file number
TVBN_baseaddr	gequ	TVBN_filenum+2	; Base address for this block
TVBN_lastaddr	gequ	TVBN_baseaddr+4	; Ending address for this block
TVBN_nextaddr	gequ	TVBN_lastaddr+4	; Next address to allocate from
TVBN_sizeof	gequ	TVBN_nextaddr+4	; Size of data structure
;
; Handle Node Structure
;
TVHN_ptr	gequ	0	; Pointer to memory
TVHN_inuse	gequ	TVHN_ptr+4	; In use counter
TVHN_next	gequ	TVHN_inuse+2	; Next Handle in list
TVHN_block	gequ	TVHN_next+2	; Pointer to Block owner
TVHN_sizeof	gequ	TVHN_block+2	; Size of data structure
;
; Error Numbers
;
TVMM_TooManyBlocks	gequ $0001	; Too Many blocks allocated
TVMM_TooManyHandles	gequ $0002	; Too Many Handles allocated
TVMM_OutOfMemory	gequ $0003	; Out of Memory
TVMM_BadHandle		gequ $0004	; Unknown Handle
TVMM_BadBlockNum	gequ $0005	; Corrupted Block Number
TVMM_CreateSwapErr	gequ $0006	; Cannot create swap file
TVMM_OpenWriteErr	gequ $0007	; Cannot open swap file for write
TVMM_WriteSwapErr	gequ $0008	; Swap file write error
TVMM_OpenReadErr	gequ $0009	; Cannot open swap file for read
TVMM_ReadSwapErr	gequ $000A	; Swap file read error
TVMM_DeleteSwapErr	gequ $000B	; Cannot delete swap file

	copy	bsi.h

;-------------------------------------------------------------------------
; TVMM_init
;    Initialize TVMM
;-------------------------------------------------------------------------

TVMM_init	START	tvmm

	using	TVMM_data

count	equ	1
space	equ	count+2

	subroutine (4:callback),space
;
; create free handle list
;
	lda	#MAX_HANDLES-1
	sta	<count
	
	ldx	#<HandleNodes
	stx	!FreeHandles

handinit	clc
	txa
	adc	#TVHN_sizeof
	sta	!TVHN_next,x
	tax

	dec	<count
	bne	handinit

	stz	!TVHN_next,x
;
; create free block list
;
	lda	#MAX_BLOCKS-1
	sta	<count
	
	ldx	#<BlockNodes
	stx	!FreeBlocks

blockinit	clc
	txa
	adc	#TVBN_sizeof
	sta	!TVBN_next,x
	tax

	dec	<count
	bne	blockinit

	stz	!TVBN_next,x
;                          
; initialize the file name counter
;
	stz	!FNCounter
;
; initialize the block list
;
	stz	!BlockList
;
; set up error callback
;
	lda	<callback
	sta	!ErrCallback
	lda	<callback+2
	sta	!ErrCallback+2
;
; init the size variables
;
	stz	!TVMM_SwapSize
	stz	!TVMM_SwapSize+2
	stz	!TVMM_RamSize
	stz	!TVMM_RamSize+2

	return
	
	END

;-------------------------------------------------------------------------
; TVMM_exit
;    Shutdown TVMM
;-------------------------------------------------------------------------

TVMM_exit	START	tvmm

	using	TVMM_data

	phb
	phk
	plb

loop	lda	!BlockList
	beq	done

	pha
	jsl	TVMM_freebn
	bra	loop

done	plb
	rtl	
	
	END

;-------------------------------------------------------------------------
; TVMM_alloc
;    Allocate memory
;-------------------------------------------------------------------------

TVMM_alloc	START	tvmm

	using	TVMM_data

ptr	equ	1
hand	equ	ptr+4
block	equ	hand+2
space	equ	block+2

	subroutine (4:size),space
;
; if requested memory is larger than max block size
;
	lda	<size+2
	jne	biggie
	lda	<size
	cmp	#BLOCK_SIZE
	jcs	biggie
;
; start searching for a block with enough free memory
;
	ldx	!BlockList
	beq	newblock

findloop	lda	!TVBN_filenum,x
	bmi	findnext

	sec
	lda	!TVBN_lastaddr,x
	sbc	!TVBN_nextaddr,x
	cmp	<size
	bcs	found
	
findnext 	lda	!TVBN_next,x
	tax
	bne	findloop
;
; allocate a new block
;
newblock	pea	$C018
	pea	0
	pea	BLOCK_SIZE
	jsl	TVMM_allocreal
	sta	<ptr
	stx	<ptr+2

	jsr	TVMM_allocbn
	tax
	
	clc
	lda	<ptr
	sta	!TVBN_baseaddr,x
	sta	!TVBN_nextaddr,x
	adc	#BLOCK_SIZE
	sta	!TVBN_lastaddr,x
	lda	<ptr+2
	sta	!TVBN_baseaddr+2,x
	sta	!TVBN_nextaddr+2,x	
	adc	#0
	sta	!TVBN_lastaddr+2,x

	lda	!TVMM_RamSize
	adc	#BLOCK_SIZE
	sta	!TVMM_RamSize
	lda	!TVMM_RamSize+2
	adc	#0
	sta	!TVMM_RamSize+2
;
; found a block to allocate a handle from
;
found	stx	<block

	jsr	TVMM_allochn
	sta	<hand
	tax

	ldy	<block

	tya
	sta	!TVHN_block,x

	lda	!TVBN_handles,y
	sta	!TVHN_next,x

	txa
	sta	!TVBN_handles,y

	lda	!TVBN_nextaddr,y
	sta	!TVHN_ptr,x
	lda	!TVBN_nextaddr+2,y
	sta	!TVHN_ptr+2,x

	clc
	lda	!TVBN_nextaddr,y
	adc	<size
	sta	!TVBN_nextaddr,y
	lda	!TVBN_nextaddr+2,y
	adc	#0
	sta	!TVBN_nextaddr+2,y

	bra	done
;
; The requested memory is larger than a block, so allocate a single
; block the size of the requested memory.
;
biggie	pea	$C008
	pei	(<size+2)
	pei	(<size)
	jsl	TVMM_allocreal
	sta	<ptr
	stx	<ptr+2

	jsr	TVMM_allocbn
	sta	<block

	jsr	TVMM_allochn
	sta	<hand
	tax

	ldy	<block

	sta	!TVBN_handles,y

	tya
	sta	!TVHN_block,x

	clc
	lda	<ptr
	sta	!TVHN_ptr,x
	sta	!TVBN_baseaddr,y
               adc	<size
	sta	!TVBN_lastaddr,y
	sta	!TVBN_nextaddr,y

	lda	<ptr+2
	sta	!TVHN_ptr+2,x
	sta   !TVBN_baseaddr+2,y
	adc	<size+2
	sta	!TVBN_lastaddr+2,y
	sta	!TVBN_nextaddr+2,y

	lda	!TVMM_RamSize
	adc	<size
	sta	!TVMM_RamSize
	lda	!TVMM_RamSize+2
	adc	<size+2
	sta	!TVMM_RamSize+2

done	return 2:hand
	
	END

;-------------------------------------------------------------------------
; TVMM_free
;    Free a handle
;-------------------------------------------------------------------------

TVMM_free	START	tvmm

	using	TVMM_data

space	equ	1

	subroutine (2:hand),space

	ldx	<hand
	ldy	!TVHN_block,x
;
; is it the head node or somewhere in the list?
;
	lda	!TVBN_handles,y
	cmp	<hand
	bne	list

	lda	!TVHN_next,x
	sta	!TVBN_handles,y

	bra	del

list	tay
	bne	cont

bad	lda	#TVMM_BadHandle
	jmp	TVMM_Error

cont	lda	!TVHN_next,y
	cmp	<hand
	beq	rem
	bra	list

rem	lda	!TVHN_next,x
	sta	!TVHN_next,y

del	lda	!FreeHandles
	sta	!TVHN_next,x

	stx	!FreeHandles

	ldy	!TVHN_block,x
	lda	!TVBN_handles,y
	bne	done

	phy
	jsl	TVMM_freebn

done	return

	END

;-------------------------------------------------------------------------
; TVMM_acquire
;    Acquire the use of a handle
;-------------------------------------------------------------------------

TVMM_acquire	START	tvmm

	using	TVMM_data

ptr	equ	1
space	equ	ptr+4

	subroutine (2:hand),space

	ldx	<hand

	ldy	!TVHN_block,x
	phy
	lda	!TVBN_filenum,y
	bpl	continue

	phy
	jsl	TVMM_swapin

	ldx	<hand

continue	lda	!TVHN_ptr,x
	sta	<ptr
	lda	!TVHN_ptr+2,x
	sta	<ptr+2

	inc	!TVHN_inuse,x

	GetTick @ay

	plx
	sta	!TVBN_time,x
	tya
	sta	!TVBN_time+2,x

	return 4:ptr

	END

;-------------------------------------------------------------------------
; TVMM_release
;    Release the use of a handle
;-------------------------------------------------------------------------

TVMM_release	START	tvmm

	using	TVMM_data

space	equ	1

	subroutine (2:hand),space

	ldx	<hand

	lda	!TVHN_inuse,x
	beq	done

	dec	!TVHN_inuse,x

done	return

	END

;-------------------------------------------------------------------------
; TVMM_freebn
;    Free a block node
;-------------------------------------------------------------------------

TVMM_freebn	PRIVATE tvmm

	using	TVMM_data

space	equ	1

	subroutine (2:block),space

	ldx	<block
	cpx	!BlockList
	bne	list

	lda	!TVBN_next,x
	sta	!BlockList

	bra	del

list	lda	!BlockList

loop	tay
	jeq	err
	lda	!TVBN_next,y
	cmp	<block
	bne	loop

	lda	!TVBN_next,x
	sta	!TVBN_next,y

del	lda	!FreeBlocks
	sta	!TVBN_next,x
	stx	!FreeBlocks

	lda	!TVBN_filenum,x
	bpl	free

	and	#$7fff
	jsr	TVMM_mkname

	Destroy CreateParm

	sec
	ldx	!FreeBlocks
	lda	!TVBN_nextaddr,x
	sbc	!TVBN_baseaddr,x
	pha
	lda	!TVBN_nextaddr+2,x
	sbc	!TVBN_baseaddr+2,x
	pha

	sec
	lda	!TVMM_SwapSize
	sbc	3,s
	sta	!TVMM_SwapSize
	lda	!TVMM_SwapSize+2
	sbc	1,s
	sta	!TVMM_SwapSize+2

	pla
	pla

	bra	done

free	ldy	!TVBN_baseaddr+2,x
               lda	!TVBN_baseaddr,x

	FindHandle @ya,@ax
	DisposeHandle @xa

	sec
	ldx	!FreeBlocks
	lda	!TVBN_lastaddr,x
	sbc	!TVBN_baseaddr,x
	pha
	lda	!TVBN_lastaddr+2,x
	sbc	!TVBN_baseaddr+2,x
	pha

	sec
	lda	!TVMM_RamSize
	sbc	3,s
	sta	!TVMM_RamSize
	lda	!TVMM_RamSize+2
	sbc	1,s
	sta	!TVMM_RamSize+2

	pla
	pla

done	return

err	lda	#TVMM_BadBlockNum
	jmp	TVMM_Error

	END

;-------------------------------------------------------------------------
; TVMM_allocreal
;    Allocate real memory
;-------------------------------------------------------------------------

TVMM_allocreal	START tvmm

	using	TVMM_data
	using	BSI_data

time	equ	1
p	equ	time+4
space	equ	p+4

	subroutine (2:flags,4:size),space

loop	lda	>MMID
	tax
	NewHandle (size,@x,flags,#0),@xy
	bcs	notenough
	stx	<p
	sty	<p+2

	lda	[<p]
	tax
	ldy	#2
	lda	[<p],y
	sta	<p+2
	stx	<p

	return 4:p
;
; find oldest block we can swap
;
notenough	lda	#$ffff
	sta	<time
	sta	<time+2
	stz	<p

	lda	!BlockList	
find1	tax
	beq	found

	lda	!TVBN_filenum,x	        ;already swapped out
	bmi	next

	lda	!TVBN_handles,x
find2	tay
	beq	end
	lda	!TVHN_inuse,y
	bne	next
	lda	!TVHN_next,y
	bra	find2

end	lda	!TVBN_time+2,x
	cmp	<time+2
	beq	end2
	bcs	next
	bcc	cont
end2	lda	!TVBN_time,x
	cmp	<time
	bcs	next
cont	stx	<p
	lda	!TVBN_time,x
	sta	<time
	lda	!TVBN_time+2,x
	sta	<time+2	

next	lda	!TVBN_next,x
	bra	find1	

found	lda	<p
	beq	err

	pha
	jsl	TVMM_swapout

	jmp	loop

err	lda	#TVMM_OutOfMemory
	jmp	TVMM_Error

	END

;-------------------------------------------------------------------------
; TVMM_allocbn
;    Allocate a block node
;-------------------------------------------------------------------------

TVMM_allocbn	PRIVATE tvmm

	using	TVMM_data

	ldx	!FreeBlocks
	bne	continue
;
; no more blocks left
;
	lda	#TVMM_TooManyBlocks
	jmp	TVMM_Error
;
; remove node from free list
;
continue	lda	!TVBN_next,x
	sta	!FreeBlocks
;
; add node to block list
;
	lda	!BlockList
	sta	!TVBN_next,x

	stx	!BlockList
;
; initialize the node
;
	stz	!TVBN_handles,x
	lda	#1
	sta	!TVBN_time,x
	stz	!TVBN_time+2,x

	lda	!FNCounter
	sta	!TVBN_filenum,x
	inc	!FNCounter

	txa
	rts

	END

;-------------------------------------------------------------------------
; TVMM_allochn
;    Allocate a handle node
;-------------------------------------------------------------------------

TVMM_allochn	PRIVATE tvmm

	using	TVMM_data

	ldx	!FreeHandles
	beq	err
;
; remove node from free list
;
	lda	!TVHN_next,x
	sta	!FreeHandles
;
; initialize the node
;
	stz	!TVHN_inuse,x
	stz	!TVHN_next,x

	txa
	rts
;
; no more handles left
;
err	lda	#TVMM_TooManyHandles
	jmp	TVMM_Error

	END

;-------------------------------------------------------------------------
; TVMM_swapout
;    Swap out a block
;-------------------------------------------------------------------------

TVMM_swapout	PRIVATE tvmm

	using	TVMM_data

space	equ	1

	subroutine (2:block),space

	short	a
	lda	#$1
	sta	>$E1C034
	long	a

	ldx	<block
	lda	!TVBN_filenum,x

	jsr	TVMM_mkname

	Create CreateParm
	bcc	cont
	cmp	#$47	;duplicate pathname
	beq	cont
	jmp	err1

cont	Open	OpenParm
	jcs	err2

	lda	!OpenRef
	sta	!WriteRef
	sta	!CloseRef

	ldx	<block
	lda	!TVBN_baseaddr,x
	sta	!WriteBuf
	lda	!TVBN_baseaddr+2,x
	sta	!WriteBuf+2

	sec
	lda	!TVBN_nextaddr,x
	sbc	!TVBN_baseaddr,x
	sta	!WriteSize
	lda	!TVBN_nextaddr+2,x
	sbc	!TVBN_baseaddr+2,x
	sta	!WriteSize+2

	Write	WriteParm
	jcs	err3

	Close	CloseParm

	ldx	<block

	sec
	lda	!TVBN_nextaddr,x
	sbc	!TVBN_baseaddr,x
	pha	
	lda	!TVBN_nextaddr+2,x
	sbc	!TVBN_baseaddr+2,x
	pha

	clc
	lda	!TVMM_SwapSize
	adc	3,s
	sta	!TVMM_SwapSize
	lda	!TVMM_SwapSize+2
	adc	1,s
	sta	!TVMM_SwapSize+2

	sec
	lda	!TVBN_lastaddr,x
	sbc	!TVBN_baseaddr,x
	sta	3,s	
	lda	!TVBN_lastaddr+2,x
	sbc	!TVBN_baseaddr+2,x
	sta	1,s

	sec             
	lda	!TVMM_RamSize
	sbc	3,s
	sta	!TVMM_RamSize
	lda	!TVMM_RamSize+2
	sbc	1,s
	sta	!TVMM_RamSize+2

	pla
	pla

	lda	!TVBN_filenum,x
	ora	#$8000
	sta	!TVBN_filenum,x

	ldy	!TVBN_baseaddr+2,x
	lda	!TVBN_baseaddr,x
	
	FindHandle @ya,@ax
	DisposeHandle @xa

	short	a
	lda	#$A
	sta	>$E1C034
	long	a

	return 

err1	lda	#TVMM_CreateSwapErr
	jmp	TVMM_error

err2	lda	#TVMM_OpenWriteErr
	jmp	TVMM_error
                          
err3	lda	#TVMM_WriteSwapErr
	jmp	TVMM_error
                          
	END

;-------------------------------------------------------------------------
; TVMM_swapin
;    Swap in a block
;-------------------------------------------------------------------------

TVMM_swapin	PRIVATE tvmm

	using	TVMM_data

old	equ	1
ptr	equ	old+4
space	equ	ptr+4

	subroutine (2:block),space

	ldx	<block

	lda	!TVBN_baseaddr,x
	sta	<old
	lda	!TVBN_baseaddr+2,x
	sta	<old+2

	sec
	lda	!TVBN_lastaddr,x
	sbc	<old
	tay
	lda	!TVBN_lastaddr+2,x
	sbc	<old+2

	bne	big
;	cpy	#BLOCK_SIZE
;	bne	big

	pea	$C018
	bra	alloced

big	pea	$C008
alloced	pha
	phy
	jsl	TVMM_allocreal

	sta	<ptr
	stx	<ptr+2

	short	a
	lda	#$C
	sta	>$E1C034
	long	a

	ldx	<block
	lda	!TVBN_filenum,x
	and	#$7fff
	sta	!TVBN_filenum,x

	jsr	TVMM_mkname

	Open	OpenParm
	jcs	err1

	lda	!OpenRef
	sta	!WriteRef
	sta	!CloseRef

	lda	<ptr
	sta	!WriteBuf
	lda	<ptr+2
	sta	!WriteBuf+2

	sec
	ldx	<block
	lda	!TVBN_nextaddr,x
	sbc	<old
	sta	!WriteSize
	lda	!TVBN_nextaddr+2,x
	sbc	<old+2
	sta	!WriteSize+2

	Read	WriteParm
	jcs	err2

	Close	CloseParm

	Destroy CreateParm
	jcs	err3

	ldx	<block

	sec
	lda	!TVBN_lastaddr,x
	sbc	<old
	pha	
	lda	!TVBN_lastaddr+2,x
	sbc	<old+2
	pha

	clc
	lda	!TVMM_RamSize
	adc	3,s
	sta	!TVMM_RamSize
	lda	!TVMM_RamSize+2
	adc	1,s
	sta	!TVMM_RamSize+2

	sec
	lda	!TVBN_nextaddr,x
	sbc	<old
	sta	3,s	
	lda	!TVBN_nextaddr+2,x
	sbc	<old+2
	sta	1,s

	sec               
	lda	!TVMM_SwapSize
	sbc	3,s
	sta	!TVMM_SwapSize
	lda	!TVMM_SwapSize+2
	sbc	1,s
	sta	!TVMM_SwapSize+2

	pla
	pla

; rebuild pointers

	sec      
	lda	<ptr
	sta	!TVBN_baseaddr,x
	sbc	<old
	sta	<ptr
	lda	<ptr+2
	sta	!TVBN_baseaddr+2,x
	sbc	<old+2
	sta	<ptr+2

	clc
	lda	!TVBN_nextaddr,x
	adc	<ptr
	sta	!TVBN_nextaddr,x
	lda	!TVBN_nextaddr+2,x
	adc	<ptr+2
	sta	!TVBN_nextaddr+2,x

	lda	!TVBN_lastaddr,x
	adc	<ptr
	sta	!TVBN_lastaddr,x
	lda	!TVBN_lastaddr+2,x
	adc	<ptr+2
	sta	!TVBN_lastaddr+2,x

	lda	!TVBN_handles,x
loop	tay
	beq	done

	clc
	lda	!TVHN_ptr,y
	adc	<ptr
	sta	!TVHN_ptr,y
	lda	!TVHN_ptr+2,y
	adc	<ptr+2
	sta	!TVHN_ptr+2,y

	lda	!TVHN_next,y
	bra	loop

done	short	a
	lda	#$A
	sta	>$E1C034
	long	a

	return

err1	lda	#TVMM_OpenReadErr
	jmp	TVMM_error

err2	lda	#TVMM_ReadSwapErr
	jmp	TVMM_error
                               
err3	lda	#TVMM_DeleteSwapErr
	jmp	TVMM_error

	END

;-------------------------------------------------------------------------
; TVMM_mkname
;    Create a swap file name
;-------------------------------------------------------------------------

TVMM_mkname	PRIVATE tvmm

	using	TVMM_data

	Int2Hex (@a,#swapname+9,#3,#-1)

	rts

	END

;-------------------------------------------------------------------------
; TVMM_Error
;    TVMM Fatal Error
;-------------------------------------------------------------------------

TVMM_Error	PRIVATE tvmm

	using	TVMM_data

	pha
	Int2Hex (@a,#errnumstr,#4,#0)

	jsl	BSI_normal

	ph4	#errwindow
	jsl	BSI_addevent
	ph4	#errokbutton
	jsl	BSI_addevent
	ph4	#errstr1
	jsl	BSI_writetext

	pla
	dec	a
	asl	a
	asl	a
	tax
	lda	!errtbl+2,x
	pha
	lda	!errtbl,x
	pha
	jsl	BSI_writetext

	jsl	BSI_Event

shazam	TLTextMountVolume (#str1,#str2,#btn,#btn),@a
	OSShutDown sdparm

ErrOkCallback	subroutine (2:action),1

	lda	!ErrCallback
	ora	!ErrCallBack+2
	beq	shazam

	lda	!ErrCallback
	sta	!jmpvect+1
               lda	!ErrCallback+1
	sta	!jmpvect+2

jmpvect	jmp	$ffffff
;
; Error window
;
errwindow	dc	i2'E_window'	;window type
	dc	i4'0'	;next
	dc	i4'0'	;prev
	dc	i2'F_blockevent'	;flags
	dc	i4'0'	;key list
	dc	i4'0'	;about callback
               dc	i4'errwrect'	;rectangle
	dc	i4'0'	;save handle
errwrect 	dc	i2'20*8,6*8,60*8,17*8'

errstr1	dc	i1'22,9',c'TVMM FATAL ERROR #'
errnumstr	dc	c'0000',h'00'
;
; Error "OK" button
;
errokbutton	dc	i2'E_button'       ;button type
	dc	i4'0'       	;next
	dc	i4'0'              ;prev
	dc	i2'0'	;flags
	dc	i4'errokkey'	;key list
	dc	i4'ErrOkCallback' ;button callback
	dc	i4'errokrect'   	;button rectangle
	dc	i4'erroktext'    ;button text
errokrect	dc    i2'53*8-3,15*8-3,58*8+1,16*8+1'
erroktext	dc	i1'55,15',c'OK',h'00'
errokkey	dc	i1'$0D,$4F,$6F,$4F+$80,$6F+$80,00'	;CR,O,o,OA-O,OA-o

errtbl	dc	i4'err1'
	dc	i4'err2'
	dc	i4'err3'
	dc	i4'err4'
	dc	i4'err5'
	dc	i4'err6'
	dc	i4'err7'
	dc	i4'err8'
	dc	i4'err9'
	dc	i4'err10'
	dc	i4'err11'

err1	dc	i1'24,11',c'Too Many Blocks Allocated',h'00'
err2	dc	i1'24,11',c'Too Many Handles Allocated',h'00'
err3	dc	i1'24,11',c'Out of Real Memory',h'00'
err4	dc	i1'24,11',c'Corrupted Memory Handle',h'00'
err5	dc	i1'24,11',c'Corrupted Block Number',h'00'
err6	dc	i1'24,11',c'Cannot Create Swap File',h'00'
err7	dc	i1'24,11',c'Cannot Open Swap File For Write',h'00'
err8	dc	i1'24,11',c'Error Writing Swap File',h'00'
err9	dc	i1'24,11',c'Cannot Open Swap File For Read',h'00'
err10	dc	i1'24,11',c'Error Reading Swap File',h'00'
err11	dc	i1'24,11',c'Cannot Delete Swap File',h'00'

str1	str	'TVMM FATAL ERROR!!!'
str2	str	'No Error Handling procedure installed'
btn	str	'Reboot'

sdparm	dc	i2'1'
	dc	i2'%11'	;invalidate memory and reboot

	END

;-------------------------------------------------------------------------
; TVMM_data
;    Data used by TVMM
;-------------------------------------------------------------------------

TVMM_data	DATA tvmm
;
; Buffers
;
HandleNodes	ds	TVHN_sizeof*MAX_HANDLES	; Handle Nodes
BlockNodes	ds	TVBN_sizeof*MAX_BLOCKS	; Block Nodes
;
; variables
;
FreeHandles	ds	2		; List of free handle nodes
FreeBlocks	ds	2		; List of free block nodes
FNCounter	ds	2		; File Name Counter
BlockList	ds	2		; List of Blocks
ErrCallBack	ds	4		; Error Callback
;
; Memory Stats
;
TVMM_SwapSize	ds	4		; Amount of swapped memory
TVMM_RamSize	ds	4		; Amount of allocated RAM
;
; swap file name
;
swapname	gsstr	"9:tvswp000"
;
; GS/OS Parm tables
;
CreateParm	dc	i2'1'
	dc	i4'swapname'

OpenParm	dc	i2'2'
OpenRef	dc	i2'0'
	dc	i4'swapname'

CloseParm	dc	i2'1'
CloseRef	dc	i2'0'

WriteParm	dc	i2'4'
WriteRef	dc	i2'0'
WriteBuf	dc	i4'0'
WriteSize	dc	i4'0'
	dc	i4'0'

	END
