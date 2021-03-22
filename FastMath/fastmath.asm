	mcopy	fastmath.mac

imBadinptParam	gequ	$0B01

fastmath	START

	str	'fastmath'
	dc	i4'install'
	dc	i4'nothing'
nothing	rtl

install	SetTSPtr (#0,#$B,#tooltbl)
	rtl

tooltbl	dc	i4'43'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'Multiply-1'
	dc	i4'0'
	dc	i4'UDivide-1'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'
	dc	i4'0'

	END

**************************************************************************
*
* Unsigned 16 bit multiplication
*
**************************************************************************

Multiply	START

multiplier	equ	$09
multiplicand	equ	$0B
longIntResult	equ	$0D

	phd
	tsc
	tcd

	lda	<multiplier
	sta	<longIntResult

	lda	#0
	clc

	ror	a
	ror	<longIntResult
	bcc	mul1
	clc
	adc	<multiplicand
mul1	ror	a
	ror	<longIntResult
	bcc	mul2
	clc
	adc	<multiplicand
mul2	ror	a
	ror	<longIntResult
	bcc	mul3
	clc
	adc	<multiplicand
mul3	ror	a
	ror	<longIntResult
	bcc	mul4
	clc
	adc	<multiplicand
mul4	ror	a
	ror	<longIntResult
	bcc	mul5
	clc
	adc	<multiplicand
mul5	ror	a
	ror	<longIntResult
	bcc	mul6
	clc
	adc	<multiplicand
mul6	ror	a
	ror	<longIntResult
	bcc	mul7
	clc
	adc	<multiplicand
mul7	ror	a
	ror	<longIntResult
	bcc	mul8
	clc
	adc	<multiplicand
mul8	ror	a
	ror	<longIntResult
	bcc	mul9
	clc
	adc	<multiplicand
mul9	ror	a
	ror	<longIntResult
	bcc	mul10
	clc
	adc	<multiplicand
mul10	ror	a
	ror	<longIntResult
	bcc	mul11
	clc
	adc	<multiplicand
mul11	ror	a
	ror	<longIntResult
	bcc	mul12
	clc
	adc	<multiplicand
mul12	ror	a
	ror	<longIntResult
	bcc	mul13
	clc
	adc	<multiplicand
mul13	ror	a
	ror	<longIntResult
	bcc	mul14
	clc
	adc	<multiplicand
mul14	ror	a
	ror	<longIntResult
	bcc	mul15
	clc
	adc	<multiplicand
mul15	ror	a
	ror	<longIntResult
	bcc	mul16
	clc
	adc	<multiplicand
mul16	ror	a
	ror	<longIntResult
	bcc	mul17
	clc
	adc	<multiplicand
mul17	anop

	sta	<longIntResult+2

	lda	<5+2
	sta	<5+4+2
	lda	<3+2
	sta	<3+4+2
	lda	<1+2
	sta	<1+4+2
	pld
	tsc
	clc
	adc	#4
	tcs
	lda	#0	;clc already done
	rtl	

	END

**************************************************************************
*
* Unsigned 16 bit division
*
**************************************************************************

UDivide	START

divisor	equ	$09
dividend	equ	$0B
quotient	equ	$0D
remainder	equ	$0F

	phd
	tsc
	tcd

	lda	<divisor
	bne	div0
	ldy	#imBadInptParam
	jmp	err

div0	lda	<dividend
	sta	<quotient

	sec
	lda	#0
	tay

	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div1
	txa
div1	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div2
	txa
div2	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div3
	txa
div3	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div4
	txa
div4	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div5
	txa
div5	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div6
	txa
div6	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div7
	txa
div7	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div8
	txa
div8	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div9
	txa
div9	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div10
	txa
div10	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div11
	txa
div11	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div12
	txa
div12	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div13
	txa
div13	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div14
	txa
div14	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div15
	txa
div15	rol	<quotient
	rol	a
	tax
	sec
	sbc	<divisor
	bcs	div16
	txa

div16	sta	<remainder
	rol	<quotient

err	lda	<5+2
	sta	<5+4+2
	lda	<3+2
	sta	<3+4+2
	lda	<1+2
	sta	<1+4+2
	pld
	tsc
	clc
	adc	#4
	tcs
	tya
	cmp	#1
	rtl	

	END
