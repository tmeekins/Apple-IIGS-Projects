;
; test file for parsearg
; written by tim meekins, 11/27/91
;
	keep	test
	mcopy	m/test.mac

testparse	START
	jml	~GNO_COMMAND
	END
;
; the main routine...
;

main	START

space	equ	0

	subroutine (2:argc,4:argv),space

	WriteCString #str1
;
; display each argv value
;
loop	lda	argc
	and	#$FF
	beq	done
	ldy	#2
	lda	[argv],y
	tax
	lda	[argv]
	WriteCString @xa
               WriteCString #crlf
	add2	argv,#4,argv
	dec	argc
	bra	loop

done	return

str1	dc	c'PARSEARG tester...',h'0d0a0a00'
crlf	dc	h'0d0a00'

	END
