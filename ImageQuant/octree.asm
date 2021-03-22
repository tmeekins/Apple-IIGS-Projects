**************************************************************************
*
* OctTree Quantization support subroutines
*
**************************************************************************

	mcopy	octree.mac

;
; The Octree data structure
;
o_next1	gequ	0
o_next2	gequ	o_next1+2
o_next3	gequ	o_next2+2
o_next4	gequ	o_next3+2
o_next5	gequ	o_next4+2
o_next6	gequ	o_next5+2
o_next7	gequ	o_next6+2
o_next8	gequ	o_next7+2
o_leaf	gequ	o_next8+2
o_level	gequ	o_leaf+2
o_children	gequ	o_level+2
o_colorcount	gequ	o_children+2
o_rgbsumr	gequ	o_colorcount+4
o_rgbsumg	gequ	o_rgbsumr+4
o_rgbsumb	gequ	o_rgbsumg+4
o_nextreduceable gequ o_rgbsumb+4
o_size	gequ	o_nextreduceable+2

MAXNODE	gequ	256	;maximum number of nodes

**************************************************************************
*
* Initialize some octree variables
*
**************************************************************************

InitOct	START

	using	OctData
	using	Globals

	stz	size
	lda	#3
	sta	reducelevel
	inc	a
	sta	leaflevel

	stz	reducelist+0*2
	stz	reducelist+1*2
	stz	reducelist+2*2
	stz	reducelist+3*2
	stz	reducelist+4*2
	stz	reducelist+5*2
	stz	reducelist+6*2
	stz	reducelist+7*2
;
; initialize the node allocator
;
	lda	#o_size
	tax
	ldy	#MAXNODE-1
	clc
init	sta	nodelist,x
	adc	#o_size
	inx
	inx
	dey
	bpl	init

	lda	#(MAXNODE-1)*2
	sta	nodeidx	

	rts	

	END

**************************************************************************
*
* Insert a color into the Octree
*
**************************************************************************

inserttree	START
	
	using	OctData

putptr	equ	1	
retval	equ	putptr+4
depthbit	equ	retval+2
space	equ	depthbit+2
depth	equ	space+2
rgb	equ	depth+2
tree	equ	rgb+4
end	equ	tree+2

;	subroutine (2:tree,4:rgb,2:depth),space

	tsc
	sec
	sbc	#space-1
	tcs
	phd
	tcd

	lda	tree
	sta	retval

	tdc
	clc
	adc	#retval
	sta	putptr
	stz	putptr+2

loop	ldx	tree
	bne	doneinit

	ldy	nodeidx
	ldx	nodelist,y
	dey
	dey
	sty	nodeidx
	bpl	allocok
	brk	0
allocok	anop

	stx	tree
	txa
	sta	[putptr]

	stz	nodeheap+o_next1,x
	stz	nodeheap+o_next2,x
	stz	nodeheap+o_next3,x
	stz	nodeheap+o_next4,x
	stz	nodeheap+o_next5,x
	stz	nodeheap+o_next6,x
	stz	nodeheap+o_next7,x
	stz	nodeheap+o_next8,x
	stz	nodeheap+o_leaf,x
	stz	nodeheap+o_children,x
	stz	nodeheap+o_colorcount,x
	stz	nodeheap+o_colorcount+2,x
	stz	nodeheap+o_rgbsumr,x
	stz	nodeheap+o_rgbsumr+2,x
	stz	nodeheap+o_rgbsumg,x
	stz	nodeheap+o_rgbsumg+2,x
	stz	nodeheap+o_rgbsumb,x
	stz	nodeheap+o_rgbsumb+2,x
	stz	nodeheap+o_nextreduceable,x

	lda	depth
	sta	nodeheap+o_level,x

	cmp	leaflevel
	bcc	doneinit

	lda	#1
	sta	nodeheap+o_leaf,x
	inc	size

doneinit	inc	nodeheap+o_colorcount,x
	bne	colorinit2
	inc	nodeheap+o_colorcount+2,x
colorinit2	anop

	lda	rgb
	and	#$FF
	clc
	adc	nodeheap+o_rgbsumr,x
	sta	nodeheap+o_rgbsumr,x
	bcc	adda
	inc	nodeheap+o_rgbsumr+2,x

adda	lda	rgb+1
	and	#$FF
	clc
	adc	nodeheap+o_rgbsumg,x
	sta	nodeheap+o_rgbsumg,x
	bcc	addb
	inc	nodeheap+o_rgbsumg+2,x

addb	lda	rgb+2
	and	#$FF
	clc
	adc	nodeheap+o_rgbsumb,x
	sta	nodeheap+o_rgbsumb,x
	bcc	addc
	inc	nodeheap+o_rgbsumb+2,x
                         
addc	lda	nodeheap+o_leaf,x
	bne	done
	lda	depth
	cmp	leaflevel
	bcs	done

	ldy	#0
	asl	a
	tax
	lda	bittbl2,x
	sta	depthbit
	bit	rgb
	beq	bra0
	ldy	#%1000
bra0	bit	rgb+1
	beq	bra1
	tya
	ora	#%0100
	tay
	lda	depthbit
bra1	bit	rgb+2
	beq	bra2
	tya
	ora	#%0010
	tay

bra2	tya
	clc
	adc	tree
	tax
	lda	nodeheap,x
	bne	insert
	phx
	ldx	tree
	inc	nodeheap+o_children,x
	lda	nodeheap+o_children,x
	cmp	#2
	bne	preins	
	lda	depth
	asl	a
	tay
	lda	reducelist,y
	sta	nodeheap+o_nextreduceable,x

	txa
	sta	reducelist,y

preins	plx

insert	lda	nodeheap,x
	sta	tree
	txa
	clc
	adc	#nodeheap
	sta	putptr
	lda	#^nodeheap
	sta	putptr+2
	inc	depth
	jmp	loop

done	ldy	retval
	lda	space
	sta	end-2
	pld
	tsc
	clc
	adc	#end-3
	tcs
	tya

	rts
            
	END

**************************************************************************
*
* We have too many colors, so trim the octree
*
**************************************************************************

reducetree	START

	using	OctData

minprev	equ	1
prev	equ	minprev+2
minp	equ	prev+2
mincount	equ	minp+2
offset	equ	mincount+4
node	equ	offset+2
space	equ	node+2
end	equ	space+2

;	subroutine (0:dummy),space

	tsc
	sec
	sbc	#space-1
	tcs
	phd
	tcd

	lda	reducelevel
	asl	a
	tax

loop	lda	reducelist,x
	bne	gotit
	dex
	dex
	bra	loop

gotit	stx	offset
	lda	reducelist,x
	sta	node
	
	lda	#$FFFF
	sta	mincount
	sta	mincount+2
;	stz	mincount
;	stz	mincount+2
	stz	minp
	stz	prev
;
; find the minimum color count in the reduceable list
;
	ldx	node
	beq	gotmin
findmin	anop
	lda	nodeheap+o_colorcount+2,x
	cmp	mincount+2
	bcc	okmin
	beq	min2
	bcs	nextmin
min2	lda	nodeheap+o_colorcount,x
	cmp	mincount
	bcs	nextmin

;	lda	nodeheap+o_colorcount+2,x
;	cmp	mincount+2
;	bcc	nextmin
;	beq	min2
;	bra	okmin
;min2	lda	nodeheap+o_colorcount,x
;	cmp	mincount
;	bcc	nextmin


okmin	stx	minp
	lda	nodeheap+o_colorcount,x
	sta	mincount
	lda	nodeheap+o_colorcount+2,x
	sta	mincount+2
	lda	prev
	sta	minprev
nextmin	stx	prev
	lda	nodeheap+o_nextreduceable,x
	sta	node
	tax
	bne	findmin
;
; got the minimum, now delete the node
;
gotmin	ldx	minprev
	beq	firstdel
	ldy	minp
	lda	nodeheap+o_nextreduceable,y
	sta	nodeheap+o_nextreduceable,x
	bra	donedel
firstdel	ldy	minp
	ldx	offset
	lda	nodeheap+o_nextreduceable,y
	sta	reducelist,x

donedel	lda	#1
	sta	nodeheap+o_leaf,y
	sec
	lda	size
	sbc	nodeheap+o_children,y
	inc	a
	sta	size
	lda	nodeheap+o_level,y
	cmp	reducelevel
	bcs	done
	sta	reducelevel
	inc	a
	sta	leaflevel

done	pld
               tsc
               clc
               adc   #end-3
               tcs

               rts

	END    

**************************************************************************
*
* Create a color table
*
**************************************************************************

initcolortable	START

	using	OctData
	using	tables

color	equ	1
colorcount	equ	color+2
space	equ	colorcount+4
table	equ	space+2
index	equ	table+4
tree	equ	index+4
end	equ	tree+2

;	subroutine (2:tree,4:index,4:table),space

	tsc
	sec
	sbc	#space-1
	tcs
	phd
	tcd

	ldx	tree  
	jeq	done

	lda	nodeheap+o_leaf,x
	bne	calc
	lda	nodeheap+o_level,x
 	cmp	leaflevel
 	jne	doloop
calc	lda	nodeheap+o_colorcount,x
	sta	colorcount
	lda	nodeheap+o_colorcount+2,x
	sta	colorcount+2
	lda	nodeheap+o_rgbsumr,x
	ldy	nodeheap+o_rgbsumr+2,x
	LongDivide (@ya,colorcount),(@ax,@yy)
	and	#$FF
	tax
	lda	cliptbl,x
	and	#$0F
	xba
	sta	color
	ldx	tree
	lda	nodeheap+o_rgbsumg,x
	ldy	nodeheap+o_rgbsumg+2,x
	LongDivide (@ya,colorcount),(@ax,@yy)
	and	#$FF
	tax
	lda	cliptbl,x
	and	#$0F
	asl	a
	asl	a
	asl	a
	asl	a
	tsb	color
	ldx	tree
	lda	nodeheap+o_rgbsumb,x
	ldy	nodeheap+o_rgbsumb+2,x
	LongDivide (@ya,colorcount),(@ax,@yy)
	and	#$FF
	tax
	lda	cliptbl,x
	and	#$0F
	tsb	color
	lda	[index]
	asl	a
	tay
	lda	color
	sta	[table],y
	ldx	tree
	lda	[index]
	inc	a
	sta	[index]
	lda	#1
	sta	nodeheap+o_leaf,x
	bra	done

doloop	ldy	tree
	ldx	#7
loop	lda	nodeheap,y
	beq	next
	phx
	phy
	pha
	pei	(index+2)
	pei	(index)
	pei	(table+2)
	pei	(table)
	jsr	initcolortable
	ply
	plx
next	iny	
	iny
	dex
	bpl	loop

done	lda   space
               sta   end-2
               pld
               tsc
               clc
               adc   #end-3
               tcs

               rts
               
	END         

**************************************************************************
*
* Some data for the octree
*
**************************************************************************

OctData	DATA

size	ds	2
leaflevel	ds	2
reducelevel	ds	2
reducelist	ds	8*2
bittbl2	dc	i2'$0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001'

nodeidx	ds	2
nodelist	ds	MAXNODE*2-o_size

nodeheap	ds	o_size*(MAXNODE+1)	

	END
