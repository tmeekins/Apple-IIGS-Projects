*************************************************************************
*
* Tim's Memory Manager (TMM)
* A high-speed replacement of the Orca memory manager
*
* Uses heaps to implement high speed memory management.
* Although slightly more wasteful of memory, it is faster and
* and will deal with instances of improper deallocations
*
* Copyright (C) 1991 by Tim Meekins
* May be used freely if proper credit is given to me
* If you make any beneficial modifications, please let me know!
*
* meekins@cis.ohio-state.edu
*
*************************************************************************

	mcopy	mm.mac

	case	on

*************************************************************************
*
* PRIVATE DATA
*
*************************************************************************

~COMMON	PRIVDATA Tims_MM

~MAXCHUNKS	gequ	40	;Number of Memory Manager chunks

~NUMCHUNKS	ds	2	;Number of chunks allocated

~CHUNKPTRTBL	ds	~MAXCHUNKS*4	;Pointer to chunk free list
~CHUNKSIZETBL	ds	~MAXCHUNKS*4	;Block size in this chunk (index)
;			;0 if unknown, -1 if MM block

~SIZETBL	dc	i2'0'	;Restricted block sizes
	dc	i2'16'
	dc	i2'32'
	dc	i2'64'
	dc	i2'96'
	dc	i2'128'
	dc	i2'256'
	dc	i2'384'
	dc	i2'512'
	dc	i2'1024'
	dc	i2'2048'
	dc	i2'4096'
	dc	i2'5000'

	END

*************************************************************************
*
* Initialize the TMM
*
*************************************************************************

~MM_INIT	START	Tims_MM

	using	~COMMON

	phb
	phk
	plb

	stz	~NUMCHUNKS	;No chunks allocated

	ldy	#~MAXCHUNKS	;Clear the chunk tables
	ldx	#0
	txa
clearchunks	sta	~CHUNKPTRTBL,x
	sta	~CHUNKPTRTBL+2,x
	sta	~CHUNKSIZETBL,x
	sta	~CHUNKSIZETBL+2,x
	inx4
	dey
	bne	clearchunks	

	plb
	rtl

	END                  
