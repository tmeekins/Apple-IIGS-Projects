               keep  'main'
               copy  z3d.h
               mcopy main.mac

bcolor         gequ  0

main           START

	using	LineData
	using	z3ddata
	using	drawdat

               proc

               TLStartUp
               MMStartUp UserID
               StartUpTools (UserID,#0,#StartStop),StartStopRef
               HideCursor

	ldx	#$7FFE
showbak	lda	>ground,x
	sta	>$012000,x
	dex
	dex
	bpl	showbak

               mv2   $E1C034,oldborder
               ld2   bcolor,$E1C034

               jsr   InitMath

               SetVector (#$A,#IntHand)
               IntSource #$C

	tdc
	sta	dpage

	stz	linecachelen
	stz	linesave
	stz	curline
	lda	#8000
	sta	oldline
	lda	#-1
	sta	LineBuf+8000

	lda	#$FFFF
	jsr	ColorChange

	short	a
              	ora2  $E19D00+180,#%01000000,$E19D00+180
	lda	#$1F	;shadow off
	sta	>$E0C035
               sta   $E1C010
               long  a

               ld4   +$00000200,(ScaleX,ScaleY,ScaleZ)

               ld2   60,tick
               stz   frame
               stz   sec

               ld2   170,PerspD
               ld2   160,cox
               ld2   100,coy
               ld2   IRCPnts,PntPtr
               ld2   IRCData,ObjPtr

zoomloop       anop
;               add2  IRCXRot,#-8,IRCXRot
;	add2	IRCYRot,#1,IRCYRot
;               jsr   IdentityMat
               jsr   MkScaleMat         
;               lda   IRCXRot
;               jsr   FixSinCos
;               jsr   RotXMat
;               lda   IRCYRot
;               jsr   FixSinCos
;               jsr   RotYMat
               jsr   TransformObj
              	jsr   PerspectObj
               jsr   MapObj
               jsr   DrawObjLineBF
               inc   drawflag
               inc   frame
	stz	linecachelen
	clc
	lda	ScaleX
	adc	#$400
	sta	ScaleX
	sta	ScaleY
	sta	ScaleZ
	cmp	#$F800
	bcc	zoomloop

mainloop       anop          
;               add2  IRCXRot,#-10,IRCXRot
;	add2	IRCYRot,#2,IRCYRot
               add2  IRCXRot,#-2,IRCXRot
	add2	IRCYRot,#1,IRCYRot
;               jsr   IdentityMat
               jsr   MkScaleMat         
               lda   IRCXRot
               jsr   FixSinCos
               jsr   RotXMat
               lda   IRCYRot
               jsr   FixSinCos
               jsr   RotYMat
               jsr   TransformObj
              	jsr   PerspectObj
               jsr   MapObj
               jsr   DrawObjLineBF
;
; Set draw flag and check for keypress
;
               inc   drawflag
               inc   frame
	stz	linecachelen

               short a
               lda   $E1C000
               bmi   done
               long  a
               jmp   mainloop

done           sta   $E1C010
               long  a

               IntSource #$D
               mv2   oldborder,$E1C034

               ShutDownTools (#0,StartStopRef)
               MMShutDown USerID
               TLShutDown

               Quit  QuitParm
QuitParm       dc    i'0'

UserID         ds    2
OldBorder      ds    2

StartStopRef   ds    4

StartStop      dc    i'0'
               dc    i'$8000'
               ds    2
               ds    4
               dc    i'1'
               dc    i'$4,$0300'

               END

z3ddata        DATA

tick           ds    2
frame          ds    2
sec            ds    2
dpage	ds	2

matrix         ds    matsize
;
; IRC
;
IRCXRot        dc    i'0'
IRCYRot	dc	i'0'

IRCPnts	anop
       	dc    i1'0',i'-080,-020,+020',i3'0,0,0'
               dc    i1'0',i'-080,+020,+020',i3'0,0,0'
               dc    i1'0',i'+080,-020,+020',i3'0,0,0'
               dc    i1'0',i'+080,+020,+020',i3'0,0,0'
               dc    i1'0',i'-080,-020,-020',i3'0,0,0'
               dc    i1'0',i'-080,+020,-020',i3'0,0,0'
               dc    i1'0',i'+080,-020,-020',i3'0,0,0'
               dc    i1'0',i'+080,+020,-020',i3'0,0,0'
               dc    h'ff'

	dc    i1'0',i'-29,+15,-3',i3'0,0,0'
	dc    i1'0',i'-23,+15,-3',i3'0,0,0'
	dc    i1'0',i'-29,-15,-3',i3'0,0,0'
	dc    i1'0',i'-23,-15,-3',i3'0,0,0'
	dc    i1'0',i'-29,+15,+3',i3'0,0,0'
	dc    i1'0',i'-23,+15,+3',i3'0,0,0'
	dc    i1'0',i'-29,-15,+3',i3'0,0,0'
	dc    i1'0',i'-23,-15,+3',i3'0,0,0'

	dc    i1'0',i'-17,-15,-3',i3'0,0,0'
	dc    i1'0',i'-17,+05,-3',i3'0,0,0'
	dc    i1'0',i'-15,+09,-3',i3'0,0,0'
	dc    i1'0',i'-11,+13,-3',i3'0,0,0'
	dc    i1'0',i'-07,+15,-3',i3'0,0,0'
	dc    i1'0',i'+03,+15,-3',i3'0,0,0'
	dc    i1'0',i'+03,+09,-3',i3'0,0,0'
	dc    i1'0',i'-07,+09,-3',i3'0,0,0'
	dc    i1'0',i'-11,+05,-3',i3'0,0,0'
	dc    i1'0',i'-11,-15,-3',i3'0,0,0'
	dc    i1'0',i'-17,-15,+3',i3'0,0,0'
	dc    i1'0',i'-17,+05,+3',i3'0,0,0'
	dc    i1'0',i'-15,+09,+3',i3'0,0,0'
	dc    i1'0',i'-11,+13,+3',i3'0,0,0'
	dc    i1'0',i'-07,+15,+3',i3'0,0,0'
	dc    i1'0',i'+03,+15,+3',i3'0,0,0'
	dc    i1'0',i'+03,+09,+3',i3'0,0,0'
	dc    i1'0',i'-07,+09,+3',i3'0,0,0'
	dc    i1'0',i'-11,+05,+3',i3'0,0,0'
	dc    i1'0',i'-11,-15,+3',i3'0,0,0'

	dc    i1'0',i'+19,+15,-3',i3'0,0,0'
	dc    i1'0',i'+29,+15,-3',i3'0,0,0'
	dc    i1'0',i'+29,+09,-3',i3'0,0,0'
	dc    i1'0',i'+19,+09,-3',i3'0,0,0'
	dc    i1'0',i'+15,+05,-3',i3'0,0,0'
	dc    i1'0',i'+15,-05,-3',i3'0,0,0'
	dc    i1'0',i'+19,-09,-3',i3'0,0,0'
	dc    i1'0',i'+29,-09,-3',i3'0,0,0'
	dc    i1'0',i'+29,-15,-3',i3'0,0,0'
	dc    i1'0',i'+19,-15,-3',i3'0,0,0'
	dc    i1'0',i'+15,-13,-3',i3'0,0,0'
	dc    i1'0',i'+11,-09,-3',i3'0,0,0'
	dc    i1'0',i'+09,-05,-3',i3'0,0,0'
	dc    i1'0',i'+09,+05,-3',i3'0,0,0'
	dc    i1'0',i'+11,+09,-3',i3'0,0,0'
	dc    i1'0',i'+15,+13,-3',i3'0,0,0'
	dc    i1'0',i'+19,+15,+3',i3'0,0,0'
	dc    i1'0',i'+29,+15,+3',i3'0,0,0'
	dc    i1'0',i'+29,+09,+3',i3'0,0,0'
	dc    i1'0',i'+19,+09,+3',i3'0,0,0'
	dc    i1'0',i'+15,+05,+3',i3'0,0,0'
	dc    i1'0',i'+15,-05,+3',i3'0,0,0'
	dc    i1'0',i'+19,-09,+3',i3'0,0,0'
	dc    i1'0',i'+29,-09,+3',i3'0,0,0'
	dc    i1'0',i'+29,-15,+3',i3'0,0,0'
	dc    i1'0',i'+19,-15,+3',i3'0,0,0'
	dc    i1'0',i'+15,-13,+3',i3'0,0,0'
	dc    i1'0',i'+11,-09,+3',i3'0,0,0'
	dc    i1'0',i'+09,-05,+3',i3'0,0,0'
	dc    i1'0',i'+09,+05,+3',i3'0,0,0'
	dc    i1'0',i'+11,+09,+3',i3'0,0,0'
	dc    i1'0',i'+15,+13,+3',i3'0,0,0'
                                                                       
               dc    h'ff'
	
                  


IRCData       	anop
               dc    i'0,1,3,2,0,-1'
               dc    i'2,3,7,6,2,-1'
               dc    i'3,1,5,7,3,-1'
               dc    i'7,5,4,6,7,-1'
               dc    i'0,2,6,4,0,-1'
               dc    i'1,0,4,5,1,-1'
               dc    i'-1'

	dc	i'0,1,3,2,0,-1'
	dc	i'1,5,7,3,1,-1'
	dc	i'5,4,6,7,5,-1'
	dc	i'4,0,2,6,4,-1'
	dc	i'4,5,1,0,4,-1'
	dc	i'2,3,7,6,2,-1'

	dc	i'8,9,10,11,12,13,14,15,16,17,8,-1'
	dc	i'19,9,8,18,19,-1'
	dc	i'20,10,9,19,20,-1'
	dc	i'21,11,10,20,21,-1'
	dc	i'22,12,11,21,22,-1'
	dc	i'23,13,12,22,23,-1'
	dc	i'24,14,13,23,24,-1'
	dc	i'25,15,14,24,25,-1'
	dc	i'26,16,15,25,26,-1'
	dc	i'27,17,16,26,27,-1'
	dc	i'18,8,17,27,18,-1'
	dc	i'18,27,26,25,24,23,22,21,20,19,18,-1'

	dc	i'28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,28,-1'
	dc	i'28,44,45,29,28,-1'
	dc	i'29,45,46,30,29,-1'
	dc	i'30,46,47,31,30,-1'
	dc	i'31,47,48,32,31,-1'
	dc	i'32,48,49,33,32,-1'
	dc	i'33,49,50,34,33,-1'
	dc	i'34,50,51,35,34,-1'
	dc	i'35,51,52,36,35,-1'
	dc	i'36,52,53,37,36,-1'
	dc	i'37,53,54,38,37,-1'
	dc	i'38,54,55,39,38,-1'
	dc	i'39,55,56,40,39,-1'
	dc	i'40,56,57,41,40,-1'
	dc	i'41,57,58,42,41,-1'
	dc	i'42,58,59,43,42,-1'
	dc	i'43,59,44,28,43,-1'
	dc	i'44,59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,-1'

	dc	i'-1'                    

               END

IntHand        START

	using	z3ddata
	using	drawdat

               long  ai

               lda   >tick
               dec   a
               bne   tick2
               lda   >sec
               inc   a
               sta   >sec
              	jsr   updatefps
               lda   #60
tick2          sta   >tick

               lda   >drawflag
               beq   skip

	jsr	Swap

               lda   #0
               sta   >drawflag
skip           anop

               short ai

               and2  $E1C032,#%11011111,$E1C032

               clc
               rtl

               END

updatefps      START
               longa on
               longi on

	using	z3ddata

	phb
	phk
	plb

               ldx   frame
               lda   sec
               jsr   SIntDiv

               ldy   #0
               lda   Quotient
bcd            cmp   #10
               bcc   bcd2
               sbc   #10
               iny
               bra   bcd

bcd2           tax

               tya
         	and   #$0F
               asl4  a
               tay

               mv2   "numtbl+0,y",">$e12000+160*0+8*160+150"
               mv2   "numtbl+2,y",">$e12000+160*1+8*160+150"
               mv2   "numtbl+4,y",">$e12000+160*2+8*160+150"
               mv2   "numtbl+6,y",">$e12000+160*3+8*160+150"
               mv2   "numtbl+8,y",">$e12000+160*4+8*160+150"
               mv2   "numtbl+10,y",">$e12000+160*5+8*160+150"
               mv2   "numtbl+12,y",">$e12000+160*6+8*160+150"

               txa
         	and   #$0F
               asl4  a
               tay

               mv2   "numtbl+0,y",">$e12000+160*0+8*160+150+3"
               mv2   "numtbl+2,y",">$e12000+160*1+8*160+150+3"
               mv2   "numtbl+4,y",">$e12000+160*2+8*160+150+3"
               mv2   "numtbl+6,y",">$e12000+160*3+8*160+150+3"
               mv2   "numtbl+8,y",">$e12000+160*4+8*160+150+3"
               mv2   "numtbl+10,y",">$e12000+160*5+8*160+150+3"
               mv2   "numtbl+12,y",">$e12000+160*6+8*160+150+3"

	plb
               rts

numtbl         dc    h'0FF0'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'0FF0'
               dc    h'0000'

               dc    h'0F00'
               dc    h'0F00'
               dc    h'0F00'
               dc    h'0F00'
               dc    h'0F00'
               dc    h'0F00'
               dc    h'0F00'
               dc    h'0000'

               dc    h'FFF0'
               dc    h'000F'
               dc    h'000F'
               dc    h'FFF0'
               dc    h'F000'
               dc    h'F000'
               dc    h'FFFF'
               dc    h'0000'

               dc    h'FFF0'
               dc    h'000F'
               dc    h'000F'
               dc    h'0FF0'
               dc    h'000F'
               dc    h'000F'
               dc    h'FFF0'
               dc    h'0000'

               dc    h'000F'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'FFFF'
               dc    h'000F'
               dc    h'000F'
               dc    h'000F'
               dc    h'0000'

               dc    h'FFFF'
               dc    h'F000'
               dc    h'F000'
               dc    h'FFF0'
               dc    h'000F'
               dc    h'000F'
               dc    h'FFF0'
               dc    h'0000'

               dc    h'0FF0'
               dc    h'F00F'
               dc    h'F000'
               dc    h'FFF0'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'0FF0'
               dc    h'0000'

               dc    h'FFFF'
               dc    h'000F'
               dc    h'000F'
               dc    h'00F0'
               dc    h'00F0'
               dc    h'00F0'
               dc    h'00F0'
               dc    h'0000'

               dc    h'0FF0'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'0FF0'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'0FF0'
               dc    h'0000'

               dc    h'0FF0'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'0FFF'
               dc    h'000F'
               dc    h'000F'
               dc    h'00F0'
               dc    h'0000'

               dc    h'0FF0'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'FFFF'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'0000'

               dc    h'FFF0'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'FFF0'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'FFF0'
               dc    h'0000'

               dc    h'0FF0'
               dc    h'F00F'
               dc    h'F000'
               dc    h'F000'
               dc    h'F000'
               dc    h'F00F'
               dc    h'0FF0'
               dc    h'0000'

               dc    h'FFF0'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'F00F'
               dc    h'FFF0'
               dc    h'0000'

               dc    h'FFFF'
               dc    h'F000'
               dc    h'F000'
               dc    h'FFFF'
               dc    h'F000'
               dc    h'F000'
               dc    h'FFFF'
               dc    h'0000'

               dc    h'FFFF'
               dc    h'F000'
               dc    h'F000'
               dc    h'FFF0'
               dc    h'F000'
               dc    h'F000'
               dc    h'F000'
               dc    h'0000'

               END
