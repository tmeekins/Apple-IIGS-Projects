***************************************************************************
*                                                                         *
* The Software Experience #2                                              *
* Written and Produced by Tim Meekins                                     *
* Zavtra Software                                                         *
*                                                                         *
* Copyright 1990 by Tim Meekins, distribution rights granted, all other   *
* rights are reserved.                                                    *
*                                                                         *
***************************************************************************
*                                                                         *
* DOSPLASH3.ASM                                                           *
*                                                                         *
***************************************************************************

               mcopy dosplash3.mac

               org   $24000

dosplash3      START

               using FontTables
               using FontData

textoffset     equ   $10
length         equ   $12
fontoffset     equ   $14

               native
               long  ai

               phk
               plb
;
; Unpack the font
;
            UnPackBytes (#PackedFont,FontPackSize,#FontPtr,#FontSize),FontSize
;
; Fade out old colors
;
               ldx   #$9E40
               ldy   #Black
               jsr   SmoothFade
               ldx   #$9E20
               ldy   #Black
               jsr   SmoothFade
               ldx   #$9E00
               ldy   #Black
               jsr   SmoothFade
;
; Clear the screen to 0's
;
               ldx   #$7FFE
               lda   #0
clrloop        sta   $012000,x
               dex2
               bpl   clrloop
;
; Create code for scrolling text
;
               jsr   MkScrollCode
;
; Set up palette number #1 for font area
;
               short ai
               ldx   #178
               lda   #1
initfontscb    sta   $019D00,x
               inx
               cpx   #196
               bcc   initfontscb
               ld2   2,($19D00+179,$19D00+183,$19D00+187,$19D00+191,$19D00+195)
               long  a
;
; Palette setup
;
               ldx   #0
copypal        lda   fontpal1,x
               sta   $019E20,x
               lda   fontpal2,x
               sta   $019E40,x
               inx2
               cpx   #$20
               bcc   copypal
;
; From now on the data bank is 1!!!
;
               phb
               pea   $0101
               plb
               plb
;
; Initialize some stuff
;
               ld2   $FFFF,textoffset
               stz   length
               long  i
;
; Wait for vertical blanking
;
loop           short a

vblwait2       lda   $C019
               bpl   vblwait2

;               ld2   1,$C034
               jsr   ScrollText
;               ld2   0,$C034

               jmp   loop
;
; Scroll the text. Nasty, but it works!!
;
ScrollText     anop
               tsx
               txy
               ldx   #$100
               txs
               phd
               lda   $C083
               lda   $C083
               ora2  $C068,#$30,$C068

               pea   $2000+160*178
               pld
               jsr   ScrollCode
               pea   $2000+160*179
               pld
               jsr   ScrollCode
               pea   $2000+160*180
               pld
               jsr   ScrollCode
               pea   $2000+160*181
               pld
               jsr   ScrollCode
               pea   $2000+160*182
               pld
               jsr   ScrollCode
               pea   $2000+160*183
               pld
               jsr   ScrollCode
               pea   $2000+160*184
               pld
               jsr   ScrollCode
               pea   $2000+160*185
               pld
               jsr   ScrollCode
               pea   $2000+160*186
               pld
               jsr   ScrollCode
               pea   $2000+160*187
               pld
               jsr   ScrollCode
               pea   $2000+160*188
               pld
               jsr   ScrollCode
               pea   $2000+160*189
               pld
               jsr   ScrollCode
               pea   $2000+160*190
               pld
               jsr   ScrollCode
               pea   $2000+160*191
               pld
               jsr   ScrollCode
               pea   $2000+160*192
               pld
               jsr   ScrollCode
               pea   $2000+160*193
               pld
               jsr   ScrollCode
               pea   $2000+160*194
               pld
               jsr   ScrollCode
               pea   $2000+160*195
               pld
               jsr   ScrollCode

               and2  $C068,#$CF,$C068
               sta   $C081
               sta   $C081
               pld
               tyx
               txs
;
; Draw a character column
;
               lda   length
               bne   drawchar

nextchar       long  a
               ldx   textoffset
               inx
char2          stx   textoffset
               lda   >text,x
               and   #$FF
               bne   contchar
               ldx   #0
               jmp   char2

contchar       asl   a
               tax
               lda   >fontadr,x
               sta   fontoffset
               lda   >fontwidth,x
               sta   length
;
; Write a 0 column between each letter
;
               short a
               stz   $2000+178*160+159
               stz   $2000+179*160+159
               stz   $2000+180*160+159
               stz   $2000+181*160+159
               stz   $2000+182*160+159
               stz   $2000+183*160+159
               stz   $2000+184*160+159
               stz   $2000+185*160+159
               stz   $2000+186*160+159
               stz   $2000+187*160+159
               stz   $2000+188*160+159
               stz   $2000+189*160+159
               stz   $2000+190*160+159
               stz   $2000+191*160+159
               stz   $2000+192*160+159
               stz   $2000+193*160+159
               stz   $2000+194*160+159
               stz   $2000+195*160+159
               jmp   donechar
;
; Actually draw the character's next column
;
drawchar       ldx   fontoffset
               lda   >thefont+0*160,x
               sta   $2000+159+178*160
               lda   >thefont+1*160,x
               sta   $2000+159+179*160
               lda   >thefont+2*160,x
               sta   $2000+159+180*160
               lda   >thefont+3*160,x
               sta   $2000+159+181*160
               lda   >thefont+4*160,x
               sta   $2000+159+182*160
               lda   >thefont+5*160,x
               sta   $2000+159+183*160
               lda   >thefont+6*160,x
               sta   $2000+159+184*160
               lda   >thefont+7*160,x
               sta   $2000+159+185*160
               lda   >thefont+8*160,x
               sta   $2000+159+186*160
               lda   >thefont+9*160,x
               sta   $2000+159+187*160
               lda   >thefont+10*160,x
               sta   $2000+159+188*160
               lda   >thefont+11*160,x
               sta   $2000+159+189*160
               lda   >thefont+12*160,x
               sta   $2000+159+190*160
               lda   >thefont+13*160,x
               sta   $2000+159+191*160
               lda   >thefont+14*160,x
               sta   $2000+159+192*160
               lda   >thefont+15*160,x
               sta   $2000+159+193*160
               lda   >thefont+16*160,x
               sta   $2000+159+194*160
               lda   >thefont+17*160,x
               sta   $2000+159+195*160
               inx
               stx   fontoffset
               dec   length

donechar       rts
;
; Make scroll code
;
MkScrollCode   long  a
               stz   CodePtr
               short ai
               ldx   #0
MkScrollLoop   lda   #$A5               ;LDA dp
               jsr   putcode
               txa
               inc   a
               jsr   putcode
               lda   #$85               ;STA dp
               jsr   putcode
               txa
               jsr   putcode
               inx
               cpx   #159
               bcc   MkScrollLoop
               lda   #$60               ;RTS
               jsr   putcode
               long  ai
               rts

putcode        long  y
               ldy   CodePtr
               sta   scrollcode,y
               iny
               sty   CodePtr
               short y
               rts

CodePtr        ds    2

FontPtr        dc    i4'TheFont'
FontSize       dc    i2'160*58'

black          dc    16i'0'
fontpal1       dc    i'$000,$000,$000,$000,$000,$000,$000,$000'
               dc    i'$000,$000,$000,$000,$000,$000,$1D0,$1D0'
fontpal2       dc    i'$800,$000,$000,$000,$000,$000,$000,$000'
               dc    i'$000,$000,$000,$000,$000,$000,$1D0,$1D0'

scrollcode     ds    160*4+10

               end

************************************************************************
*
* Smooth fade. Proportional fade between all colors.
*   INPUT: X = Dest palette addr
*          Y = New palette addr
*
************************************************************************

SmoothFade     start
;
;
palPtr         equ   $10
colPtr         equ   $14
addPtr         equ   $16
subPtr         equ   $18
propptr        equ   $1a
newcol         equ   $1c
oldcol         equ   $1e

               long  ai

               stx   palPtr
               ld2   $1,palPtr+2
               sty   colPtr

               ldx   #16*16*2-2
loop1          stz   addtbl,x           ;Init Fade tables to all 0s
               stz   subtbl,x
               dex2
               bpl   loop1

               short i                  ;X & Y values are never larger than 32!

               ld2   addtbl,addptr
               ld2   subtbl,subptr

               ldy   #0                 ;loop through each color entry
loop2          phy
               lda   [palPtr]           ;Calculate fade difference for each
               and   #$F                ; hue (Red, Green, Blue)
               tax
               lda   (colPtr)
               and   #$F
               ldy   #0
               jsr   diff
               lda   [palPtr]
               and   #$F0
               lsr4  a
               tax
               lda   (colPtr)
               and   #$F0
               lsr4  a
               ldy   #2
               jsr   diff
               lda   [palPtr]
               and   #$F00
               xba
               tax
               lda   (colPtr)
               and   #$F00
               xba
               ldy   #4
               jsr   diff
               add2  addptr,#16*2,addptr       ;Set up for next color
               add2  subptr,#16*2,subptr
               inc2  palPtr
               inc2  colPtr
               ply
               iny
               cpy   #16
               bne   loop2

               sub2  palPtr,#16*2,palPtr
               ldx   #0                        ;Loop 16 times
floop          anop
vblwait1       lda   $E0C019-1
               bpl   vblwait1
vblwait2       lda   $E0C019-1
               bmi   vblwait2
vblwait3       lda   $E0C019-1
               bpl   vblwait3
vblwait4       lda   $E0C019-1
               bmi   vblwait4
               ld2   subtbl,subptr
               ld2   addtbl,addptr
               ldy   #0
cloop          clc
               lda   [palPtr],y
               phy
               txy
               clc
               adc   (addptr),y
               sec
               sbc   (subptr),y
               ply
               sta   [palPtr],y
               add2  addptr,#16*2,addptr
               add2  subptr,#16*2,subptr
               iny2
               cpy   #16*2
               bne   cloop

               inx2
               cpx   #16*2
               bne   floop

               long  i

               rts

               longi off

diff           stx   oldcol             ;Create proportional fade table
               stz   oldcol+1
               tyx                      ; for an individually given hue
               sta   newcol
               cmp   oldcol
               beq   done
               bcc   subcol
addcol         sub2  @,oldcol,@
               asl4  a
               asl   a
               add2  @,#prop0,propptr
               ldy   #0
addloop        lda   (propptr),y
               beq   addskip
               lda   hue,x
               ora   (addptr),y
               sta   (addptr),y
addskip        iny2
               cpy   #16*2
               bne   addloop
done           rts
subcol         sub2  oldcol,newcol,@
               asl4  a
               asl   a
               add2  @,#prop0,propptr
               ldy   #0
subloop        lda   (propptr),y
               beq   subskip
               lda   hue,x
               ora   (subptr),y
               sta   (subptr),y
subskip        iny2
               cpy   #16*2
               bne   subloop

               rts

hue            dc    i'$001,$010,$100'  ;Hue value mask
addtbl         ds    16*16*2            ;proportion to add for each color
subtbl         ds    16*16*2            ;"   "         sub   "     "
prop0          dc    i'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'        ;init proportion
prop1          dc    i'0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0'        ;table
prop2          dc    i'0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0'
prop3          dc    i'0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0'
prop4          dc    i'0,0,1,0,0,1,0,0,0,1,0,0,1,0,0,0'
prop5          dc    i'0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0'
prop6          dc    i'0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,1'
prop7          dc    i'0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0'
prop8          dc    i'1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0'
prop9          dc    i'1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,0'
prop10         dc    i'1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,0'
prop11         dc    i'1,1,0,1,1,0,1,1,1,0,1,1,0,1,1,0'
prop12         dc    i'1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0'
prop13         dc    i'1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,0'
prop14         dc    i'1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0'
prop15         dc    i'1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0'

               end

***************************************************************************
*                                                                         *
* Font tables                                                             *
*                                                                         *
***************************************************************************

FontTables     data

fontadr        ds    2
               dc    i'99+6400'         ;Experience
               ds    30*2               ;control characters
               dc    i'150'             ;space
               dc    i'55+6400'         ;!
               dc    i'56+6400'         ;"
               dc    i'59+6400'         ;#
               dc    i'64+6400'         ;$
               ds    2                  ;%
               dc    i'68+6400'         ;&
               dc    i'56+6400'         ;'
               dc    i'73+6400'         ;(
               dc    i'76+6400'         ;)
               dc    i'95+6400'         ;*
               dc    i'79+6400'         ;+
               dc    i'83+6400'         ;,
               dc    i'84+6400'         ;-
               dc    i'88+6400'         ;.
               dc    i'89+6400'         ;/
               dc    i'0+6400'          ;0
               dc    i'4+6400'          ;1
               dc    i'6+6400'          ;2
               dc    i'10+6400'         ;3
               dc    i'14+6400'         ;4
               dc    i'18+6400'         ;5
               dc    i'22+6400'         ;6
               dc    i'26+6400'         ;7
               dc    i'30+6400'         ;8
               dc    i'34+6400'         ;9
               dc    i'45+6400'         ;:
               ds    2                  ;;
               ds    2                  ;<
               dc    i'46+6400'         ;=
               ds    2                  ;>
               dc    i'51+6400'         ;?
               dc    i'38+6400'         ;@
               dc    i'0'               ;A
               dc    i'5'               ;B
               dc    i'10'              ;C
               dc    i'14'              ;D
               dc    i'19'              ;E
               dc    i'24'              ;F
               dc    i'29'              ;G
               dc    i'33'              ;H
               dc    i'38'              ;I
               dc    i'40'              ;J
               dc    i'43'              ;K
               dc    i'49'              ;L
               dc    i'54'              ;M
               dc    i'62'              ;N
               dc    i'67'              ;O
               dc    i'71'              ;P
               dc    i'76'              ;Q
               dc    i'80'              ;R
               dc    i'85'              ;S
               dc    i'89'              ;T
               dc    i'94'              ;U
               dc    i'99'              ;V
               dc    i'104'             ;W
               dc    i'112'             ;X
               dc    i'118'             ;Y
               dc    i'123'             ;Z
               ds    2                  ;[
               ds    2                  ;\
               ds    2                  ;]
               ds    2                  ;^
               ds    2                  ;_
               ds    2                  ;`
               dc    i'0+3200'          ;a
               dc    i'4+3200'          ;b
               dc    i'8+3200'          ;c
               dc    i'12+3200'         ;d
               dc    i'16+3200'         ;e
               dc    i'20+3200'         ;f
               dc    i'23+3200'         ;g
               dc    i'27+3200'         ;h
               dc    i'32+3200'         ;i
               dc    i'34+3200'         ;j
               dc    i'36+3200'         ;k
               dc    i'41+3200'         ;l
               dc    i'43+3200'         ;m
               dc    i'50+3200'         ;n
               dc    i'55+3200'         ;o
               dc    i'59+3200'         ;p
               dc    i'63+3200'         ;q
               dc    i'67+3200'         ;r
               dc    i'71+3200'         ;s
               dc    i'75+3200'         ;t
               dc    i'78+3200'         ;u
               dc    i'83+3200'         ;v
               dc    i'88+3200'         ;w
               dc    i'95+3200'         ;x
               dc    i'100+3200'        ;y
               dc    i'105+3200'        ;z

fontwidth      dc    i'0,49,0,0,0,0,0,0,0,0,0,0,0,0,0,0' ;00-0F
               dc    i'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0' ;10-1F
               dc    i'3,1,3,5,4,0,5,1,3,3,2,4,1,4,1,4' ;20-2F
               dc    i'4,2,4,4,4,4,4,4,4,4,1,0,0,5,0,4' ;30-3F
               dc    i'7,5,5,4,5,5,5,4,5,2,3,6,5,8,5,4' ;40-4F
               dc    i'5,4,5,4,5,5,5,8,6,5,4,0,0,0,0,0' ;50-5F
               dc    i'0,4,4,4,4,4,3,4,5,2,2,5,2,7,5,4' ;60-6F
               dc    i'4,4,4,4,3,5,5,7,5,5,4,0,0,0,0,0' ;70-7F

text           dc    c'Welcome to THE SOFTWARE EXPERIENCE #2    '
               dc    c'Pre-Release 0.02  '
               dc    c'September 15, 1990   '
               dc    c'Written and Produced by Tim Meekins   '
               dc    c'Copyright 1990 by Tim Meekins    '
               dc    c'Please send all comments to:  '
               dc    c'meekins@cis.ohio-state.edu,  '
               dc    c'timm@pro-tcc.cts.com,  '
               dc    c'or send snail-mail:   '
               dc    c'8372 Morris Rd., Hilliard, OH  43026  '
               dc    c'ABCDEFGHIJKLMNOPQRSTUVWXYZ    '
               dc    c'abcdefghijklmnopqrstuvwxyz    '
               dc    i'0'

               end

