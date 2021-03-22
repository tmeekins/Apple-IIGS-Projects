
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
* DOSPLASH1.ASM                                                           *
*  - Perform Splash #1. Scroll The Experience Logo and fade-in "IT!"      *
*                                                                         *
***************************************************************************

               mcopy dosplash1.mac

               org   $1000

DoSplash1      START

               using Splash1Data
               using Splash2Data

               native
               short ai
;
; Set up the Super Hi-Res screen since this hasn't been done yet
;
               stz   $C035              ;Shadow everything

               phb
               lda   #1
               pha
               plb

               long  ai
               ldx   #$0000
               lda   #0
ClearLoop      sta   |$2000,x
               inx2
               cpx   #$8000
               bne   ClearLoop

               plb

               short a
               ld2   $C1,$C029
               long  a
;
; Unpack the picture
;
       UnPackBytes (#PackedSplash1,Splash1PackSize,#Splash1Ptr,#Splash1Size),tmp
;
; Copy Palette
;
               ldx   #$1E
PalLoop        lda   Splash1Pal,x
               sta   $019E00,x
               dex2
               bpl   PalLoop
;
; Scroll "Experience"
;
topoff         equ   0
botoff         equ   2

               jsr   mkscroll
               short ax
               phb
               lda   #1
               pha
               plb
               ld2   0,topoff
               ld2   158,botoff
scrollloop     short a
vertwait1      lda   >$E0C02E
               asl   a
               bmi   vertwait1
vertwait2      lda   >$E0C02E
               asl   a
               cmp   #110
               bcc   vertwait2
               long  a
               jsl   $020000
               ldx   topoff
               lda   |160*0,x
               sta   $2000+160*83+158
               lda   |160*1,x
               sta   $2000+160*84+158
               lda   160*2,x
               sta   $2000+160*85+158
               lda   160*3,x
               sta   $2000+160*86+158
               lda   160*4,x
               sta   $2000+160*87+158
               lda   160*5,x
               sta   $2000+160*88+158
               lda   160*6,x
               sta   $2000+160*89+158
               lda   160*7,x
               sta   $2000+160*90+158
               lda   160*8,x
               sta   $2000+160*91+158
               lda   160*9,x
               sta   $2000+160*92+158
               lda   160*10,x
               sta   $2000+160*93+158
               inx
               inx
               stx   topoff
               ldx   botoff
               lda   160*12,x
               sta   $2000+160*95
               lda   160*13,x
               sta   $2000+160*96
               lda   160*14,x
               sta   $2000+160*97
               lda   160*15,x
               sta   $2000+160*98
               lda   160*16,x
               sta   $2000+160*99
               lda   160*17,x
               sta   $2000+160*100
               lda   160*18,x
               sta   $2000+160*101
               lda   160*19,x
               sta   $2000+160*102
               lda   160*20,x
               sta   $2000+160*103
               lda   160*21,x
               sta   $2000+160*104
               lda   160*22,x
               sta   $2000+160*105
               lda   160*23,x
               sta   $2000+160*106
               lda   160*24,x
               sta   $2000+160*107
               lda   160*25,x
               sta   $2000+160*108
               lda   160*26,x
               sta   $2000+160*109
               lda   160*27,x
               sta   $2000+160*110
               lda   160*28,x
               sta   $2000+160*111
               lda   160*29,x
               sta   $2000+160*112
               lda   160*30,x
               sta   $2000+160*113
               lda   160*31,x
               sta   $2000+160*114
               lda   160*32,x
               sta   $2000+160*115
               lda   160*33,x
               sta   $2000+160*116
               lda   160*34,x
               sta   $2000+160*117
               dex
               dex
               stx   botoff
               cpx   #$FE
               beq   donescroll
               jmp   scrollloop
donescroll     plb
;
; Fade in the "IT!"
;
               short ai
               ldy   #56
               lda   #1
               ldx   #145
ITScb          sta   $019D00,x
               inx
               dey
               bne   ITScb
               long  ai
       UnPackBytes (#PackedSplash2,Splash2PackSize,#Splash2Ptr,#Splash2Size),tmp
               ldx   #$9E20
               ldy   #Splash2Pal
               jsr   SmoothFade
;
; All Done
;
               emulate
               rts

;
; Make splash1 scrolling code
;
mkscroll       long  a
               ld4   $020000,0
               ld2   $2000+160*83,addr
               short ai
               ldy   #0
mkloop1        ldx   #0
               mv2   addr,oldaddr
               mv2   addr+1,oldaddr+1
mkloop2        lda   #$AD               ;LDA addr+1
               jsr   putcode
               clc
               lda   addr
               adc   #2
               php
               jsr   putcode
               plp
               lda   addr+1
               adc   #0
               jsr   putcode
               lda   #$8D               ;STA addr
               jsr   putcode
               lda   addr
               jsr   putcode
               lda   addr+1
               jsr   putcode
               long  a
               inc2  addr
               short a
               inx2
               cpx   #158
               bcc   mkloop2
               long  a
               add2  oldaddr,#160,addr
               short a
               iny
               cpy   #11
               bcc   mkloop1

               long  a
               ld2   $2000+160*95,addr
               short a
               ldy   #12
mkloop3        ldx   #0
               long  a
               mv2   addr,oldaddr
               add2  addr,#158,addr
               short a
mkloop4        lda   #$AD               ;LDA addr-1
               jsr   putcode
               sec
               lda   addr
               sbc   #2
               php
               jsr   putcode
               plp
               lda   addr+1
               sbc   #0
               jsr   putcode
               lda   #$8D               ;STA addr
               jsr   putcode
               lda   addr
               jsr   putcode
               lda   addr+1
               jsr   putcode
               long  a
               dec2  addr
               short a
               inx2
               cpx   #158
               bcc   mkloop4
               long  a
               add2  oldaddr,#160,addr
               short a
               iny
               cpy   #35
               bcc   mkloop3

               lda   #$6B               ;RTL
               sta   [0]
               rts
;
; Output the data
;
putcode        sta   [0]
               long  a
               inc   0
               short a
               rts
;
; Data
;
addr           ds    2
oldaddr        ds    2

Splash1Ptr     dc    i4'$010000'
Splash1Size    dc    i4'160*35'
Splash2Ptr     dc    i4'$012000+145*160+63'
Splash2Size    dc    i4'160*26'
tmp            ds    4

               END


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
vblwait1       lda   $C019-1
               bpl   vblwait1
vblwait2       lda   $C019-1
               bmi   vblwait2
vblwait3       lda   $C019-1
               bpl   vblwait3
vblwait4       lda   $C019-1
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

