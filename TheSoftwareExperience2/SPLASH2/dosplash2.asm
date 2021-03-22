
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
* DOSPLASH2.ASM                                                           *
*  - Perform Splash #2. Scroll "Software". Fade-out "IT!". Fade-in "2"    *
*                                                                         *
***************************************************************************

               mcopy dosplash2.mac

               org   $1000

DoSplash2      START

               using Splash3Data
               using Splash4Data

               native
;
; Setup screen and palette for "Software" Logo
;
               short ai
               ldy   #81
               lda   #2
               ldx   #0
SoftwareScb    sta   $019D00,x
               inx
               dey
               bne   SoftwareScb
               long  ai

               ldx   #$1E
PalLoop        lda   Splash3Pal,x
               sta   $019E40,x
               dex2
               bpl   PalLoop
;
; Unpack the "Software Logo"
;
       UnPackBytes (#PackedSplash3,Splash3PackSize,#Splash3Ptr,#Splash3Size),tmp
;
; Generate some special scrolling code to scroll the "Software" Logo
;
               jsr   mksoftcode
;
; Scroll the "Software" logo
;
softoff        equ   $0
numrows        equ   $2
rownum         equ   $4

               long  ai
               ld2   160*61,softoff
               ld2   1,numrows
sloop1         stz   rownum
               short a
vertwait1      lda   >$E0C02E
               asl   a
               bmi   vertwait1
vertwait2      lda   >$E0C02E
               asl   a
               cmp   #20
               bcc   vertwait2
               long  a
               ldx   softoff
               ldy   #0
sloop2         jsl   $010000
               add2  @x,#160,@x
               add2  @y,#160,@y
               inc   rownum
               lda   rownum
               cmp   numrows
               bcc   sloop2

               sub2  softoff,#160,softoff
               inc   numrows
               lda   numrows
               cmp   #63
               bcc   sloop1
;
; Fade-out "IT!"
;
               ldx   #$9E20
               ldy   #black
               jsr   SmoothFade
;
; Unpack "2" logo to the screen then fade-in
;
       UnPackBytes (#PackedSplash4,Splash4PackSize,#Splash4Ptr,#Splash4Size),tmp
               ldx   #$9E20
               ldy   #Splash4Pal
               jsr   SmoothFade

               emulate
               rts
;
; Generate "software" scrolling code.
;
mksoftcode     long  ai
               ld4   $010000,0
               ld2   0,adr1
               ld2   $2000+37,adr2
               short ai
               lda   #$8B               ;PHB
               jsr   putcode
               lda   #$4B               ;PHK
               jsr   putcode
               lda   #$AB               ;PLB
               jsr   putcode
               ldx   #88
mkscloop       lda   #$BF               ;LDA long,X
               jsr   putcode
               lda   adr1
               jsr   putcode
               lda   adr1+1
               jsr   putcode
               lda   #2
               jsr   putcode
               lda   #$99               ;STA addr,Y
               jsr   putcode
               lda   adr2
               jsr   putcode
               lda   adr2+1
               jsr   putcode
               inc2  adr1
               inc2  adr2
               dex2
               bne   mkscloop
               lda   #$AB               ;PLB
               jsr   putcode
               lda   #$6B               ;RTL
               sta   [0]
               long  ai
               rts

adr1           ds    2
adr2           ds    2
;
; Output the data
;
putcode        sta   [0]
               long  a
               inc   0
               short a
               rts

black          dc    16i'0'
Splash3Ptr     dc    i4'$020000'
Splash3Size    dc    i4'160*62'
Splash4Ptr     dc    i4'$012000+145*160+68'
Splash4Size    dc    i4'160*46'
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


