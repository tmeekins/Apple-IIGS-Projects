*
* opcode hashing routines
*
	mcopy	opcode.mac

**************************************************************************
*
* Build the opcode hash table
*
**************************************************************************

buildophash	START

	using	opcodedata

ptr	equ	0
p	equ	ptr+4
space	equ	p+4

	subroutine (0:dummy),space

;
; clear the hash table to all nulls, we shouldn't need to, but let's make
; it restartable if possible.
;
	ldx	#211*4-2
	lda	#0
zap	sta	ophashtab,x
	dex
	dex
	bpl	zap

	ld4	opcodes,ptr
loop	pei	(ptr+2)
	pei	(ptr)
	jsl	ophash
	asl	a
	asl	a
	tay
	lda	ophashtab,y
	ora	ophashtab+2,y
	bne	follow
	lda	ptr
	sta	ophashtab,y
	lda	ptr+2
	sta	ophashtab+2,y
	bra	next
follow	lda	ophashtab,y
	sta	p
	lda	ophashtab+2,y
	sta	p+2
follow2	ldy	#8
	lda	[p],y
	bne	follownext2
	ldy	#10
	lda	[p],y
	bne	follownext
	lda	ptr+2
	sta	[p],y
	ldy	#8
	lda	ptr
	sta	[p],y
	bra	next
follownext    	ldy	#8
follownext2	lda	[p],y
	tax
	ldy	#10
	lda	[p],y
	sta	p+2
	stx	p
	bra	follow2
next	add4	ptr,#12,ptr
	lda	ptr
	cmp	#lastopcode
	bne	loop
	lda	ptr+2
	cmp	#^lastopcode
	bne	loop

	return

	END

**************************************************************************
*
* Get the hash value for an opcode, the hashed word is 8 characters,
* all upper case, and padded with space...anything else and wrong hash
* values will be generated.
*
**************************************************************************

ophash	START

h	equ	0
retval	equ	h+4
space	equ	retval+2

	subroutine (4:str),space

	ldx	#8
	ldy	#0
loop	asl	h
	bcc	hash2
	asl	h+2
hash2          asl	h
	bcc	hash3
	asl	h+2
hash3	asl	h
	bcc	hash4
	asl	h+2
hash4	asl	h
	bcc	hash5
	asl	h+2
hash5	lda	[str],y
	and	#$FF
	clc
	adc	h
	bcc	hash6
	inc	h+2
hash6	lda	h+2
	and	#$F000
	beq	next
	xba
	eor	h
	sta	h
next	iny
	dex
	bne	loop

	UDivide (h,#211),(@a,retval)

	return 2:retval

	END

**************************************************************************
*
* This is a table of opcodes and assembler directives.
*
**************************************************************************

opcodedata	DATA

ophashtab	dc	211i4'0'

opcodes	dc	c'65C02   ',i4'0'
	dc	c'65816   ',i4'0'
	dc	c'ABSADDR ',i4'0'
	dc	c'ACTR    ',i4'0'
	dc	c'ADC     ',i4'0'
	dc	c'AGO     ',i4'0'
	dc	c'AIF     ',i4'0'
	dc	c'AINPUT  ',i4'0'
	dc	c'ALIGN   ',i4'0'
	dc	c'AMID    ',i4'0'
	dc	c'AND     ',i4'0'
	dc	c'ANOP    ',i4'0'
	dc	c'APPEND  ',i4'0'
	dc	c'ASEARCH ',i4'0'
	dc	c'ASL     ',i4'0'
	dc	c'BCC     ',i4'0'
	dc	c'BCS     ',i4'0'
	dc	c'BEQ     ',i4'0'
	dc	c'BGE     ',i4'0'
	dc	c'BIT     ',i4'0'
	dc	c'BLT     ',i4'0'
	dc	c'BMI     ',i4'0'
	dc	c'BNE     ',i4'0'
	dc	c'BPL     ',i4'0'
	dc	c'BRA     ',i4'0'
	dc	c'BRK     ',i4'0'
	dc	c'BRL     ',i4'0'
	dc	c'BVC     ',i4'0'
	dc	c'BVS     ',i4'0'
	dc	c'CASE    ',i4'0'
	dc	c'CLC     ',i4'0'
	dc	c'CLD     ',i4'0'
	dc	c'CLI     ',i4'0'
	dc	c'CLV     ',i4'0'
	dc	c'CMP     ',i4'0'
	dc	c'CODECHK ',i4'0'
	dc	c'COP     ',i4'0'
	dc	c'COPY    ',i4'0'
	dc	c'CPA     ',i4'0'
	dc	c'CPX     ',i4'0'
	dc	c'CPY     ',i4'0'
	dc	c'DATA    ',i4'0'
	dc	c'DATACHK ',i4'0'
	dc	c'DC      ',i4'0'
	dc	c'DEC     ',i4'0'
	dc	c'DEX     ',i4'0'
	dc	c'DEY     ',i4'0'
	dc	c'DIRECT  ',i4'0'
	dc	c'DS      ',i4'0'
	dc	c'EJECT   ',i4'0'
	dc	c'END     ',i4'0'
	dc	c'ENTRY   ',i4'0'
	dc	c'EOR     ',i4'0'
	dc	c'EQU     ',i4'0'
	dc	c'ERR     ',i4'0'
	dc	c'EXPAND  ',i4'0'
	dc	c'GBLA    ',i4'0'
	dc	c'GBLB    ',i4'0'
	dc	c'GBLC    ',i4'0'
	dc	c'GEN     ',i4'0'
	dc	c'GEQU    ',i4'0'
	dc	c'IEEE    ',i4'0'
	dc	c'INC     ',i4'0'
	dc	c'INX     ',i4'0'
	dc	c'INY     ',i4'0'
	dc	c'INSTIME ',i4'0'
	dc	c'JML     ',i4'0'
	dc	c'JMP     ',i4'0'
	dc	c'JSL     ',i4'0'
	dc	c'JSR     ',i4'0'
	dc	c'KEEP    ',i4'0'
	dc	c'KIND    ',i4'0'
	dc	c'LCLA    ',i4'0'
	dc	c'LCLB    ',i4'0'
	dc	c'LCLC    ',i4'0'
	dc	c'LDA     ',i4'0'
	dc	c'LDX     ',i4'0'
	dc	c'LDY     ',i4'0'
	dc	c'LIST    ',i4'0'
	dc	c'LONGA   ',i4'0'
	dc	c'LONGI   ',i4'0'
	dc	c'LSR     ',i4'0'
	dc	c'MACRO   ',i4'0'
	dc	c'MCOPY   ',i4'0'
	dc	c'MDROP   ',i4'0'
	dc	c'MEM     ',i4'0'
	dc	c'MEND    ',i4'0'
	dc	c'MERR    ',i4'0'
	dc	c'MEXIT   ',i4'0'
	dc	c'MLOAD   ',i4'0'
	dc	c'MNOTE   ',i4'0'
	dc	c'MSB     ',i4'0'
	dc	c'MVN     ',i4'0'
	dc	c'MVP     ',i4'0'
	dc	c'NOP     ',i4'0'
	dc	c'NUMSEX  ',i4'0'
	dc	c'OBJ     ',i4'0'
	dc	c'OBJCASE ',i4'0'
	dc	c'OBJEND  ',i4'0'
	dc	c'ORA     ',i4'0'
	dc	c'ORG     ',i4'0'
	dc	c'PEA     ',i4'0'
	dc	c'PEI     ',i4'0'
	dc	c'PER     ',i4'0'
	dc	c'PHA     ',i4'0'
	dc	c'PHB     ',i4'0'
	dc	c'PHD     ',i4'0'
	dc	c'PHK     ',i4'0'
	dc	c'PHP     ',i4'0'
	dc	c'PHX     ',i4'0'
	dc	c'PHY     ',i4'0'
	dc	c'PLA     ',i4'0'
	dc	c'PLB     ',i4'0'
	dc	c'PLD     ',i4'0'
	dc	c'PLP     ',i4'0'
	dc	c'PLX     ',i4'0'
	dc	c'PLY     ',i4'0'
	dc	c'PRINTER ',i4'0'
	dc	c'PRIVATE ',i4'0'
	dc	c'PRIVDATA',i4'0'
	dc	c'RENAME  ',i4'0'
	dc	c'REP     ',i4'0'
	dc	c'ROL     ',i4'0'
	dc	c'ROR     ',i4'0'
	dc	c'RTI     ',i4'0'
	dc	c'RTL     ',i4'0'
	dc	c'RTS     ',i4'0'
	dc	c'SBC     ',i4'0'
	dc	c'SEC     ',i4'0'
	dc	c'SED     ',i4'0'
	dc	c'SEI     ',i4'0'
	dc	c'SEP     ',i4'0'
	dc	c'SETA    ',i4'0'
	dc	c'SETB    ',i4'0'
	dc	c'SETC    ',i4'0'
	dc	c'SETCOM  ',i4'0'
	dc	c'STA     ',i4'0'
	dc	c'START   ',i4'0'
	dc	c'STP     ',i4'0'
	dc	c'STX     ',i4'0'
	dc	c'STY     ',i4'0'
	dc	c'STZ     ',i4'0'
	dc	c'SYMBOL  ',i4'0'
	dc	c'TAX     ',i4'0'
	dc	c'TAY     ',i4'0'
	dc	c'TCD     ',i4'0'
	dc	c'TCS     ',i4'0'
	dc	c'TDC     ',i4'0'
	dc	c'TITLE   ',i4'0'
	dc	c'TRACE   ',i4'0'
	dc	c'TRB     ',i4'0'
	dc	c'TSB     ',i4'0'
	dc	c'TSC     ',i4'0'
	dc	c'TSX     ',i4'0'
	dc	c'TXA     ',i4'0'
	dc	c'TXS     ',i4'0'
	dc	c'TXY     ',i4'0'
	dc	c'TYA     ',i4'0'
	dc	c'TYX     ',i4'0'
	dc	c'USING   ',i4'0'
	dc	c'WAI     ',i4'0'
	dc	c'WDM     ',i4'0'
	dc	c'XBA     ',i4'0'
	dc	c'XCE     ',i4'0'
lastopcode	anop

	END      
