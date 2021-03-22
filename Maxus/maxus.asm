               title 'MaXUS - Written by Tim Meekins - 1/90'

********************************************************************
*
* MAXUS
* Written by Tim Meekins
*
*********************************************************************

               mcopy MAXUS.MAC
               mcopy SPECIAL.MAC
               copy  INCLUDE/G16.MEMORY
               copy  INCLUDE/G16.QUICKDRAW
               copy  INCLUDE/G16.MISCTOOL
               copy  MAXUS.H
               gen   on

ActFlag        gequ  0                  ;Monitor activity

;
; Main segment
;
MAXUS          start

               using chardata

               proc

               jsr   StartUp            ;Start up the needed Tool Sets
               jsr   Intro              ;Display credits
               jsr   InitStars          ;Initialize Stars
               jsr   InitStat           ;Initialize stat bar
               jsr   InitShip           ;Initialize ship
               jsr   ClockInit          ;Initialize real-time clock

               lda   >CharPal+10*2
               sta   >$E19E00+10*2
               lda   >CharPal+11*2
               sta   >$E19E00+11*2
               lda   >CharPal+12*2
               sta   >$E19E00+12*2
               ld2   testmsg,textPtr
               jsr   DrawText

               short a
               sta   $E1C010
Wait           lda   $E1C000
               bpl   Wait
               sta   $E1C010
               long  a

               jsr   ShutDown           ;Shutdown the tools

;               Quit  QuitParm           ;Quit to launcher

               procendL                 ;Never used

testmsg        dc    i1'3,50,4,55',c'MaXUS Demo 2',i1'2'
               dc    i1'3,50',c'By Tim Meekins',i1'0'

QuitParm       dc    i2'2'
               dc    i4'0'
               dc    i2'0'

               end

************************************************************************
*
* STARTUP
*  - Start up the tool sets required by MAXUS.
*  - At this time there is NO error detection. ADD THIS RSN!!
*  - NEED TO CHANGE STARTUP TOOLS TO NEW STARTUP CALL (Re: System Disk 5.0)
*
************************************************************************

StartUp        start

TempHandle     equ   $00

DPAttr         equ   attrLocked+attrFixed+attrPage+attrBank
ShadowAttr     equ   attrLocked+attrFixed+attrAddr+attrBank
BackAttr       equ   attrLocked+attrFixed+attrNoCross

QDDP           equ   $0
FMDP           equ   QDDP+$300
TotalDP        equ   FMDP+$100
;
; Start up the first 3 basic tools
;
               TLStartUp                ;Start up the Tool Locator
               MMStartUp MaxusID        ;Start up the Memory Manager
               MTStartup                ;Start up Miscellaneous Tool Set
;
; Find 3 pages in bank 0 for QuickDraw II's direct page variables
;
               NewHandle (#TotalDP,MaxusID,#DPAttr,#0),TempHandle
;
; Start up QuickDraw II and derefence direct page handle
;
               QDStartUp ([TempHandle],#%1000000000000000,#320,MaxusID)
;
; Set border to black
;
               VBLWait
               short a
               mv2   $E1C034,OldBorder  ;Save old border color
               and   #$F0               ;Set new border to black
               sta   $E1C034
               long  a
;
; Set up screen pointers
;
               ld4   $E12000,ScrnPtr
               ld4   $012000,ShadPtr
               NewHandle (#$8000,MaxusID,#BackAttr,#0),Temphandle
               lda   [TempHandle]
               sta   BackPtr
               ldy   #2
               lda   [TempHandle],y
               sta   BackPtr+2
               rts

MaxusID        entry
               ds    2                  ;Memory Manager ID for MAXUS

OldBorder      entry
               ds    1                  ;Old Border color

               end

****************************************************************
*
* SHUTDOWN
* - ShutDown all of the tools
* - LIKE STARTUP, CONVERT TO NEW TOOL CALL
*
****************************************************************

ShutDown       start

               SetMouse #mouseOff       ;Turn off mouse
               IntSource #vblDisable    ;Turn off interrupts
               IntSource #oSecDisable
               ClrHeartBeat             ;Stop all interrupt tasks

               GrafOff                  ;Turn off graphics (NECESSARY?)
               short a                  ;Retore previous border
               mv2   OldBorder,$E1C034
               long  a

               QDShutDown               ;Shut down the tools
               MTShutDown
               MMShutDown MaxusID
               TLShutDown

               rts

               end

************************************************************************
*
* STARS
*  - Interrupt tasks for moving star field
*
************************************************************************

Stars          start

InitStars      entry

               ShadowOff
;
; Initialize star colors to black
;
               lda   #0
               sta   $E19E00+15*2
               sta   $E19E00+14*2
               sta   $E19E00+13*2
;
; Create initial star positions
;
               ldx   #0
StarLoop       jsr   RandStarXY         ;Create a close star
               sta   Stars1,x
               stz   Vis1,x
               tay
               lda   #$F0
               ora   [ScrnPtr],y
               sta   [ScrnPtr],y
               jsr   RandStarXY         ;Create a middle star
               sta   Stars2,x
               stz   Vis2,x
               tay
               lda   #$E0
               ora   [ScrnPtr],y
               sta   [ScrnPtr],y
               jsr   RandStarXY         ;Create a far star
               sta   Stars3,x
               stz   Vis3,x
               tay
               lda   #$D0
               ora   [ScrnPtr],y
               sta   [ScrnPtr],y
               inx2
               cpx   #16*2
               bne   StarLoop
;
; Save direct page for task handlers
;
               tdc
               sta   DirectPage
;
; Set up interrupt-driven stars
;
               SetHeartBeat #StarsTask1
               SetHeartBeat #StarsTask2
               SetHeartBeat #StarsTask3
               IntSource #vblEnable
;
; Delay, then slowly fade in stars
;
               ldx   #50
               jsr   Delay
               ldx   #$9E00
               ldy   #StarPal
               jsr   SmoothFade
;
; Remove remnants of MaXUS logo
; [IS THIS NECESSARY?]
;
               ShadowOn
               ldx   #160*91+57
               lda   #0
loop           sta   $012000,x
               inx2
               cpx   #160*109
               bcc   loop
               rts

StarPal        dc    i'0,0,0,$F00,0,0,0,0,0,0,0,0,0,$555,$999,$FFF'
;
; Move closeset star field
;
StarsTask1     ds    4
TaskCount1     dc    i'1'
               dc    h'5AA5'

               proc  pd
               long  ai

               lda   DirectPage
               tcd

               short a
               active $F,actflag
               lda   $E1C035
               pha

               ShadowOff
               ldy   #0
Loop1          ldx   Stars1,y
               lda   Vis1,y
               bne   Move1
               ShadowOn
               lda   $012000,x
               sta   $012000,x
               ShadowOff
Move1          long a
               txa
               add2  @,#160*2,@
               cmp   #200*160-1
               bcc   Good1
               jsr   RandStarX
Good1          sta   Stars1,y
               tax
               short  a
               lda   $E12000,x
               bit   #$F0
               bne   Next1
               ora   #$F0
               sta   $E12000,x
               lda   #0
Next1          sta   Vis1,y
               iny2
               cpy   #16*2
               bcc   Loop1

               ld2   1,TaskCount1

               pla
               sta   $E1C035
               active $0,actflag

               procendL
;
; Move middle star field
;
StarsTask2     ds    4
TaskCount2     dc    i'1'
               dc    h'5AA5'

               proc  pd
               long  ai

               lda   DirectPage
               tcd

               short a
               active $E,actflag
               lda   $E1C035
               pha

               ShadowOff
               ldy   #0
Loop2          ldx   Stars2,y
               lda   Vis2,y
               bne   Move2
               ShadowOn
               lda   $012000,x
               sta   $012000,x
               ShadowOff
Move2          long  a
               txa
               add2  @,#160,@
               cmp   #200*160-1
               bcc   Good2
               jsr   RandStarX
Good2          sta   Stars2,y
               tax
               short a
               lda   $E12000,x
               bit   #$F0
               bne   Next2
               ora   #$E0
               sta   $E12000,x
               lda   #0
Next2          sta   Vis2,y
               iny2
               cpy   #16*2
               bcc   Loop2

               ld2   1,TaskCount2

               pla
               sta   $E1C035
               active $0,actflag

               procendL
;
; Move far star field
;
StarsTask3     ds    4
TaskCount3     dc    i'2'
               dc    h'5AA5'

               proc  pd
               long  ai

               lda   DirectPage
               tcd

               short a
               active $D,actflag
               lda   $E1C035
               pha

               ShadowOff
               ldy   #0
Loop3          ldx   Stars3,y
               lda   Vis3,y
               bne   Move3
               ShadowOn
               lda   $012000,x
               sta   $012000,x
               ShadowOff
Move3          long  a
               txa
               add2  @,#160,@
               cmp   #200*160-1
               bcc   Good3
               jsr   RandStarX
Good3          sta   Stars3,y
               tax
               short a
               lda   $E12000,x
               bit   #$F0
               bne   Next3
               ora   #$D0
               sta   $E12000,x
               lda   #0
Next3          sta   Vis3,y
               iny2
               cpy   #16*2
               bcc   Loop3

               ld2   2,TaskCount3

               pla
               sta   $E1C035
               active $0,actflag

               procendL

               longa on
;
; Get a random number between 0 and 159 then add 160 to it for row 1.
;
temp           equ   $30

RandStarX      phy
               Random @a
               short a
               and   #%00011111
               sta   temp
               xba
               and   #%01111111
               clc
               adc   temp
               long  a
               and   #$FF
               clc
               adc   #160

               ply
               rts
;
; Get a random number between 0 and 200*160-1
;
RandStarXY     phx
RandLoop       Random @a
               and   #%0111111111111111
               cmp   #160*200-1
               bcs   RandLoop
               plx
               rts
;
; Star Data
;
Stars1         ds    2*16
Stars2         ds    2*16
Stars3         ds    2*16
Vis1           ds    2*16
Vis2           ds    2*16
Vis3           ds    2*16

DirectPage     entry
               ds    2

               end

************************************************************************
*
* FADE
*  - Special color fading routines
*    o Smooth fade fades all palettes from the current palette definition
*      to a given destination palette
*
************************************************************************

Fade           start
;
; Smooth fade. Proportional fade between all colors.
; NOTE: This routine is NOT at all like the algorithm developed by Jason
;       Blochowiak. I believe mine to be far superior and much faster (although
;       my data tables may make my code larger.)
;   INPUT: X = Dest palette addr
;          Y = New palette addr
;
; [SHOULD I SEPARATELY COPYRIGHT THIS ALGORITHM??]
;
SmoothFade     entry

               using FadeDat

palPtr         equ   $10
colPtr         equ   $14
addptr         equ   $16
subptr         equ   $18
propptr        equ   $1a
newcol         equ   $1c
oldcol         equ   $1e

               active $1,actflag

               stx   palPtr
               ld2   $E1,palPtr+2
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

               active $0,actflag

               sub2  palPtr,#16*2,palPtr
               ldx   #0                        ;Loop 16 times and
floop          VBLWait                         ; and add/sub proportional
               VBLWait                         ; constant to each color.
;              VBLWait                         ; This is the actual fade code.
               active $1,actflag
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
               active $0,actflag
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
               longi on
;
; CIRCLEFADE
;  - This isn't actually a fade, but it replaces one screen with another
;    in a circular fashion. Used to fade from Zavtra logo to MaXUS logo.
;
CircleFade     entry

               using ScanLine

radius         equ   $10
xp             equ   $12
yp             equ   $14
delta          equ   $16
t1             equ   $18
t2             equ   $1A
xc             equ   $1C

               phb
               pea   $0101
               plb
               plb

               stx   radius	;we were called with the radius in x
               stx   xp                 ;starting x position is the radius
               stz   yp                 ;starting y position is 0
	sec
	lda	#1
	sbc	radius
	sta	delta
	lda	xp
repeat         jsr   cplot	;draw the first point
               inc   yp                 ;y position always increments
               lda   delta              ;if delta positive, then dec x position
               bpl   else
	sec		;the sec will do an inc
	adc	yp                 ;delta = 1+delta+yp*2
	clc
	adc	yp	
	sta	delta
          	lda	xp
	cmp	yp
               bpl   repeat
               plb
               rts
else           dec   xp	;decrement x position
	sec		;sec will increment
	adc	yp
	clc
	adc	yp
	sec
	sbc	xp
	sec
	sbc	xp
	sta	delta
          	lda	xp
	cmp	yp
               bpl   repeat
               plb
               rts

cplot          clc
	adc	#160	
               lsr   a
               sta   xc
               tay
	clc
	lda	yp
	adc	#100
               jsr   plot2	;(160+xp,100+yp)
	sec
	lda	#160
	sbc	xp
               lsr   a
               sta   xc
               jsr   plot3	;(160-xp,100+yp)
	sec
	lda	#100
	sbc	yp
               jsr   plot2	;(160-xp,100-yp)
               tya
               jsr   plot3	;(160+xp,100-yp)
	clc
	lda	yp
	adc	#160
               lsr   a
               sta   xc
               tay
	clc
	lda	xp
	adc	#100
               jsr   plot2	;(160+yp,100+xp)
	sec
	lda	#160
	sbc	yp
               lsr   a
               sta   xc
               jsr   plot3	;(160-yp,100+xp)
	sec
	lda	#100
	sbc	xp
               jsr   plot2	;(160-yp,100-xp)
               tya	                   ;(160+yp,100-xp)
plot3          clc
               adc   t1
               tax
               short a
               lda   $2000,x
               sta   $2000,x
               long  a
               rts

plot2          asl   a
               tax
               lda   >SLTbl,x
               sta   t1
               adc   xc	;(cf=0)
               tax
               short a
               lda   $2000,x
               sta   $2000,x
               long  a
               rts

;
; Delay for x 1/60th of a second
;
Delay          entry
wait           VBLWait
               dex
               bpl   wait
               rts

               end

************************************************************************
*
* INITSTAT
*  - Set up the stat bar at the top of the screen
*
************************************************************************

InitStat       start

               using StatDat
               using PalDat
;
; Clear palette to black
;
               ShadowOff
               ldx   #16*2-2
               lda   #0
Loop1          sta   $E19E00+1*16*2,x
               dex2
               bpl   Loop1
;
; Set rows 0 to 12 to palette 1
;
               short a
               lda   #1
               ldx   #12
Loop2          sta   $E19D00,x
               dex
               bpl   Loop2
               long  a
;
; Draw the status bar
;
               ShadowOn
               ldy   #0
Loop3          tyx
               lda   >StatPic,x
               sta   [ShadPtr],y
               iny2
               cpy   #13*160
               bcc   Loop3
;
; Fade in the status bar
;
               ShadowOff
               ldx   #$9E00+16*2
               ldy   #StatPal
               jmp   SmoothFade

               end

************************************************************************
*
* INTRO
*  - Display credits
*
************************************************************************

Intro          start

ptr            equ   $10

               using PalDat
               using LogoDat

               ShadowOn
;
; initiliaze palette to black
;
               ldx   #16*2-2
               lda   #0
Loop1          sta   $019E00,x
               dex2
               bpl   Loop1
;
; Draw Zavtra logo
;
               ld4   LogoPic,ptr

               ldy   #160*70+23
               ldx   #114
Loop2          lda   [ptr]
               sta   [shadPtr],y
               dex2
               bne   next1
               ldx   #114
               tya
               add2  @,#46,@
               tay
next1          add2  ptr,#2,ptr         ;An INC2 will NOT work if the
               bcc   GoodBank1          ; picture data is crossing a bank.
               inc   ptr+2              ;Trust me, I found out the HARD WAY!
GoodBank1      iny2
               cpy   #160*130+21
               bcc   Loop2
;
; Fade in Zavtra logo
;
               ShadowOff
               ldx   #$9E00
               ldy   #LogoPal
               jsr   SmoothFade
               ldx   #130
               jsr   Delay
;
; Clear background to black
;
               ldy   #160*200-2
               lda   #0
Clear          sta   [shadPtr],y
               dey2
               bpl   Clear
;
; Draw MaXUS logo
;
               ld4   MaxPic,ptr
               ldy   #160*91+57
               ldx   #46
Loop4          lda   [ptr]
               sta   [shadPtr],y
               dex2
               bne   next2
               ldx   #46
               tya
               add2  @,#114,@
               tay
next2          add2  ptr,#2,ptr         ;An INC2 will NOT work if the
               bcc   GoodBank2          ; picture data is crossing a bank.
               inc   ptr+2              ;Trust me, I found out the HARD WAY!
GoodBank2      iny2
               cpy   #160*109+55
               bcc   Loop4
;
; Fade in MaXUS logo
;
               ShadowOn
               ldx   #1
circLoop       VBLWait
               phx
               jsr   CircleFade
               plx
               inx
               cpx   #124
               bcc   circLoop

               ldx   #100
               jsr   Delay
;
; Fade out to black
;
               ShadowOff
               ldx   #$9E00
               ldy   #BlackPal
               jsr   SmoothFade
;
; Set MaXUS screen memory to 0s
;
               ShadowOn
               ldx   #160*91+57
               lda   #0
loop5          sta   $012000,x
               inx2
               cpx   #160*109
               bcc   loop5

               rts

               end

************************************************************************
*
* NUMBERS
*  - Number drawing procs
*
************************************************************************

Numbers        start
*
* DRAWDIGIT
*  - Draw a digit
*  INPUT: Y = Digit * 4
*         X = X Coord / 2
*
DrawDigit      entry

               ShadowOn
               lda   NumLin0,y
               sta   $12000+2*160,x
               lda   NumLin1,y
               sta   $12000+3*160,x
               lda   NumLin2,y
               sta   $12000+4*160,x
               lda   NumLin3,y
               sta   $12000+5*160,x
               lda   NumLin4,y
               sta   $12000+6*160,x
               lda   NumLin5,y
               sta   $12000+7*160,x
               lda   NumLin6,y
               sta   $12000+8*160,x
               lda   NumLin7,y
               sta   $12000+9*160,x
               lda   NumLin8,y
               sta   $12000+10*160,x
               lda   NumLin0+2,y
               sta   $12000+2*160+2,x
               lda   NumLin1+2,y
               sta   $12000+3*160+2,x
               lda   NumLin2+2,y
               sta   $12000+4*160+2,x
               lda   NumLin3+2,y
               sta   $12000+5*160+2,x
               lda   NumLin4+2,y
               sta   $12000+6*160+2,x
               lda   NumLin5+2,y
               sta   $12000+7*160+2,x
               lda   NumLin6+2,y
               sta   $12000+8*160+2,x
               lda   NumLin7+2,y
               sta   $12000+9*160+2,x
               lda   NumLin8+2,y
               sta   $12000+10*160+2,x

               rts
;
; Numbers for scores
;
NumLin0 dc h'A999A555555595559999A5559999A55595559555A9999555955555559999A555A999A555A999A555'
NumLin1 dc h'95559555555595555555955555559555955595559555555595555555555595559555955595559555'
NumLin2 dc h'95CB9BC5555595B555BB9BC555BB9BC595B595B595CBBBB595B5555555BB9BC595CB9BC595CB9BC5'
NumLin3 dc h'95B595B5555595B5A999A5B59999A5B5A999A5B5A999A555A999A555555595B5A999A5B5A999A5B5'
NumLin4 dc h'95B595B5555595B5955555B5555595B555B595B555B5955595B59555555595B595B595B555B595B5'
NumLin5 dc h'95B595B5555595B595CBBBC555BB9BC555CB9BC555CB9BC595CB9BC5555595B595CB9BC555CB9BC5'
NumLin6 dc h'A999A5B5555595B5A99995559999A5B5555595B59999A5B5A999A5B5555595B5A999A5B5555595B5'
NumLin7 dc h'55B555B5555555B555B55555555555B5555555B5555555B555B555B5555555B555B555B5555555B5'
NumLin8 dc h'55CBBBC5555555B555CBBBB555BBBBC5555555B555BBBBC555CBBBC5555555B555CBBBC5555555B5'

               end

************************************************************************
*
* CLOCK STUFF
*  - Realtime clock routines
*
************************************************************************
;
; Initiliaze clock
;   - Get current time and display it
;   - Set clock interrupt task
;     [NEED TO ADD ERROR HANDLING TO THIS!!]
;
ClockInit      start

               ReadTimeHex (@x,@a,@y,@y)

               jsr   Hex2Dec
               sta   hour
               txa
               xba
               jsr   Hex2Dec
               sta   min
               txa
               jsr   Hex2Dec
               sta   second

               jsr   drawhour
               jsr   drawmin
               jsr   drawsec

               SetVector (#oneSecHnd,#ClockTask)
               IntSource #oSecEnable

               rts

;
; Interrupt clock task
;  - We arrive here once every second, so we increment the time by 1 each time
;
ClockTask      proc

               longi off
               longa off

               active $C,actflag
               lda   $E1C035
               pha

               inc   second
               lda   second
               cmp   #10
               bcc   done1
               stz   second

               inc   second+1
               lda   second+1
               cmp   #6
               bcc   done1
               stz   second+1

               inc   min
               lda   min
               cmp   #10
               bcc   done2
               stz   min

               inc   min+1
               lda   min+1
               cmp   #6
               bcc   done2
               stz   min+1

               inc   hour
               lda   hour
               cmp   #10
               bcs   zero
               cmp   #4
               bcc   done3
               lda   hour+1
               cmp   #2
               bcc   Done3
               stz   hour
               bra   zero2

zero           stz   hour

               inc   hour+1
               lda   hour+1
               cmp   #3
               bcc   done3
zero2          stz   hour+1

done3          long  ai
               jsr   drawhour
done2          long  ai
               jsr   drawmin
done1          long  ai
               jsr   drawsec

               short a
               active $0,actflag
               lda   $E1C032            ;Reset one-sec interrupt
               and   #%10111111
               sta   $E1C032

               pla
               sta   $E1C035

               clc                      ;Must return carry clear
               procendL

               longa on
;
; Draw hour
;
drawhour       lda   hour+1
               and   #$FF
               asl2  a
               tay
               ldx   #7
               jsr   DrawDigit
               lda   hour
               and   #$FF
               asl2  a
               tay
               ldx   #11
               jmp   DrawDigit
;
; draw minute
;
drawmin        lda   min+1
               and   #$FF
               asl2  a
               tay
               ldx   #18
               jsr   DrawDigit
               lda   min
               and   #$FF
               asl2  a
               tay
               ldx   #22
               jmp   DrawDigit
;
; draw second
;
drawsec        lda   second+1
               and   #$FF
               asl2  a
               tay
               ldx   #29
               jsr   DrawDigit
               lda   second
               and   #$FF
               asl2  a
               tay
               ldx   #33
               jmp   DrawDigit
;
; convert a hex byte into two decimal digits
;
Hex2Dec        stz   hi
               and   #$FF
Loop           cmp   #10
               bcc   HexDone
               inc   hi
               sub2  @,#10,@
               bra   Loop
HexDone        xba
               ora   hi
               xba
               rts

hi             ds    2

hour           ds    2
min            ds    2
second         ds    2

               end

************************************************************************
*
* SHIP
*  - Procedures for dealing with the ships
*
************************************************************************

Ship           start

               using PalDat
               using ShipDat
;
; Initialize the ship
;
InitShip       entry

BaseAdr        equ   $10
ShipAdr        equ   $10
;
; Set up ship palette info
;
               ShadowOff
               short ai
               ldx   #23
               lda   #2
PalLoop1       sta   $E19D00+176,x
               dex
               bpl   PalLoop1

               long  a
               ldx   #15*2
PalLoop2       lda   >ShipPal,x
               sta   $E19E00+2*16*2,x
               dex2
               bpl   PalLoop2
;
; Draw base
;
               ShadowOn
               ldx   #24
               ld4   BasePic,BaseAdr
               ld2   $2000+176*160+75,ShadPtr
baseloop1      ldy   #0
baseloop2      lda   [BaseAdr],y
               sta   [ShadPtr],y
               iny2
               cpy   #10
               bcc   baseloop2
               short a
               lda   [BaseAdr],y
               sta   [ShadPtr],y
               long  a
               add2  BaseAdr,#11,BaseAdr
               bcc   GoodBank1
               inc   BaseAdr+2
GoodBank1      add2  ShadPtr,#160,ShadPtr
               dex
               bne   baseloop1
               ld2   $2000,ShadPtr
;
; Draw initial ship position
;
               long  ai
               lda   #16
               jsr   DrawShip
;
; initialize mouse
;
               InitMouse #0
               ClampMouse (#0,#64,#0,#0)
               PosMouse (#32,#0)
               SetVector (#$D,#MoveShip)
               SetMouse #bttnOrMoveVI

               rts
*
* Interrupt handler for ship
*
MoveShip       proc  pd

               long  ai
               ph2   $E1C035
               ShadowOn

               lda   DirectPage
               tcd

               ReadMouse (@a,@y,@x)

               and   #%10
               beq   doneMove

               txa
               lsr   a
               jsr   DrawShip

doneMove       pl2   $E1C035
               clc
               procendL
*
* Draw a ship
* INPUT: A = ship number
*
DrawShip       short i
               asl2  a
               tax
               lda   >ShipTbl,x
               sta   ShipAdr
               lda   >ShipTbl+2,x
               sta   ShipAdr+2
               ldx   #17
               ld2   $2000+176*160+75,ShadPtr
shiploop1      ldy   #0
shiploop2      lda   [ShipAdr],y
               sta   [ShadPtr],y
               iny2
               cpy   #10
               bcc   shiploop2
               short a
               lda   [ShipAdr],y
               sta   [ShadPtr],y
               long  a
               add2  ShipAdr,#11,ShipAdr
               bcc   GoodBank2
               inc   ShipAdr+2
GoodBank2      add2  ShadPtr,#160,ShadPtr
               dex
               bne   shiploop1

               ld2   $2000,ShadPtr
               long  i
               rts

               end
