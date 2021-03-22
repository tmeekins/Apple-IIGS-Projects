************************************************************************
*
* CHARACTERS
*  - Character writing procedures
*
************************************************************************

               copy  MAXUS.H
               mcopy MAXTEXT.MAC

Characters     start

               using CharData
               using Scanline
;
; Draw a text message
;
DrawText       entry

               ShadowOn
               stz   offset
               stz   cx
               stz   cy
DrawLoop       ldy   offset
               lda   (TextPtr),y
               and   #$7F
               cmp   #$20
               bcc   Control
               jsr   DrawChar
NextChar       inc   offset
               bra   DrawLoop
Control        cmp   #5
               bcs   NextChar
               asl   a
               tax
               jmp   (ControlTbl,x)
Done           rts
Down           add2  cy,#16,cy
               bra   NextChar
Setx           inc   offset
               ldy   offset
               lda   (TextPtr),y
               and   #$FF
               sta   cx
               bra   NextChar
Sety           inc   offset
               ldy   offset
               lda   (TextPtr),y
               and   #$FF
               sta   cy
               bra   NextChar

cx             ds    2
cy             ds    2
offset         ds    2
length         ds    2

ControlTbl     dc    i'Done'            ;0
               dc    i'0'               ;1
               dc    i'Down'            ;2
               dc    i'Setx'            ;3
               dc    i'Sety'            ;4
;
; Draw a character
;
DrawChar       tax
               lda   >charxlate,x
               and   #$FF
               cmp   #62
               bcc   cont
               inc   cx                 ;Do space
               inc   cx
               inc   cx
               rts
cont           tax
               pha
               lda   >charlen,x
               and   #$FF
               dec   a
               sta   length
               pla
               asl2  a
               tax
               lda   >chartbl,x
               sta   TempPtr
               lda   >chartbl+2,x
               sta   TempPtr+2

               ph2   ShadPtr
               lda   cy
               asl   a
               tay
               lda   SLTbl,y
               add2  @,cx,@
               add2  @,ShadPtr,ShadPtr

               ldx   #15
CLoop1         short ai
               ldy   length
CLoop2         lda   [TempPtr],y
               beq   skip
               sta   [ShadPtr],y
skip           dey
               bpl   CLoop2
               long  ai

               add2  ShadPtr,#160,ShadPtr
               add2  TempPtr,length,@
               inc   a
               sta   TempPtr
               dex
               bne   CLoop1

               add2  cx,length,@
               inc   a
               sta   cx

               pl2   ShadPtr
               rts

               end
