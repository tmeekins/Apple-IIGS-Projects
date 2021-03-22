**************************************************************************
*
* Tim's Virtual Memory Manager
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* tvmm.h
*
* Constants and data structures for TVMM
*
**************************************************************************
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
