********************************************************************
*
* MAXUS DEMO #1
* Written by Tim Meekins
*
*********************************************************************

               mcopy MAXUS.MAC
               copy  G16.MEMORY
               copy  G16.QUICKDRAW
               copy  G16.MISCTOOL
               gen   on
;
;Gloal variables
;
TextPtr        gequ  $F2
BackPtr        gequ  $F4
ScrnPtr        gequ  $FC
;
; Main segment
;
MAXUS          start

               using TextData

               proc

               jsr   StartUp            ;Start up the needed Tool Sets
               jsr   Intro              ;Display credits
               jsr   InitStars          ;Initialize Stars

               ld2   StoryText,TextPtr  ;Display text
               jsr   DrawText
               jsr   TransitionFade

               jsr   ShutDown           ;Shutdown the tools

               Quit  QuitParm           ;Quit to launcher

               procendL                 ;Never used

QuitParm       dc    i2'2'
               dc    i4'0'
               dc    i2'0'

               end

************************************************************************
*
* STARTUP
*  - Start up the tool sets required by MAXUS.
*  - At this time there is NO error detection.
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
               QDStartUp ([TempHandle],#0,#320,MaxusID)
;
; Set border to black
;
               VBLWait
               short a                  ;Black border
               lda   $E1C034
               sta   OldBorder
               and   #$F0
               sta   $E1C034
               long  a
;
; Load Font Manager
;
               LoadOneTool (#27,#$204)
               clc
               lda   [TempHandle]
               adc   #FMDP
               tax
               FMStartUp (MaxusID,@x)
;
; Set up screen pointers
;
               ld4   $E12000,ScrnPtr
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
*
****************************************************************

ShutDown       start

               IntSource #vblDisable    ;Turn off interrupts
               ClrHeartBeat             ;Stop all interrupt tasks

               GrafOff                  ;Turn off graphics
               short a                  ;Retore previous border
               lda   OldBorder
               sta   $E1C034
               long  a

               FMShutDown               ;Shut down tools
               QDShutDown
               MTShutDown
               MMShutDown MaxusID
               TLShutDown

               rts

               end

************************************************************************
*
* INTRO
*  - Display credits
*
************************************************************************

Intro          start

;
; Set up colors
;
               SetColorEntry (#0,#00,#$000)
               SetColorEntry (#0,#01,#$000)
               SetColorEntry (#0,#02,#$000)
               SetColorEntry (#0,#03,#$FFF)
               ClearScreen #0           ;Clear screen to color 0
;
; Display Tim presenets..
;
               InstallFont (#0+0*$10000+16*$1000000,#0)
               SetBackColor #0
               SetForeColor #1
               SetTextMode #modeForeCopy
               SetTextSize #16
               StringWidth #TimMsg,@a
               lsr   a
               eor   #$FFFF
               inc   a
               clc
               adc   #160
               MoveTo (@a,#100)
               DrawString #TimMsg
;
; Fade in the message
;
Fade1          VBLWait
               ldx   #1
wait1          VBLWait
               dex
               bpl   wait1
               clc
               lda   $E19E02
               adc   #$111
               sta   $E19E02
               cmp   #$FFF
               bne   Fade1
;
; Display Maxus name
;
               ldx   #100
wait2          VBLWait
               dex
               bpl   wait2

               SetTextMode #modeForeOr
               SetForeColor #2
               StringWidth #DemoMsg,@a
               lsr   a
               eor   #$FFFF
               inc   a
               clc
               adc   #160
               MoveTo (@a,#100)
               DrawString #DemoMsg
;
; Fade in MaXUS, Fade out Tim
;
               jsr   TransitionFade
;
; Copy this screen to background buffer
;
               ldy   #160*200-2
Copy           lda   [ScrnPtr],y
               sta   [BackPtr],y
               dey2
               bpl   Copy

               rts

TimMsg         str   'Tim Meekins Presents'
DemoMsg        str   'MaXUS Demo I'

               end

************************************************************************
*
* STARSDATA
*  - Data structures for star background
*
************************************************************************

StarsData      data

Stars1         ds    2*16
Stars2         ds    2*16
Stars3         ds    2*16
Vis1           ds    2*16
Vis2           ds    2*16
Vis3           ds    2*16

DirectPage     ds    2

               end

************************************************************************
*
* INITSTARS
*  - Initialize star data structures
*
************************************************************************

InitStars      start

               using StarsData
;
; Initialize star colors to black
;
               SetColorEntry (#0,#15,#$000)
               SetColorEntry (#0,#14,#$000)
               SetColorEntry (#0,#13,#$000)
;
; Create close stars
;
               ldx   #0
Star1Loop      jsr   RandStarXY
               sta   Stars1,x
               stz   Vis1,x
               tay
               lda   #$F0
               ora   [ScrnPtr],y
               sta   [ScrnPtr],y
               inx2
               cpx   #16*2
               bne   Star1Loop
;
; Create middle stars
;
               ldx   #0
Star2Loop      jsr   RandStarXY
               sta   Stars2,x
               stz   Vis2,x
               tay
               lda   #$E0
               ora   [ScrnPtr],y
               sta   [ScrnPtr],y
               inx2
               cpx   #16*2
               bne   Star2Loop
;
; Create far stars
;
               ldx   #0
Star3Loop      jsr   RandStarXY
               sta   Stars3,x
               stz   Vis3,x
               tay
               lda   #$D0
               ora   [ScrnPtr],y
               sta   [ScrnPtr],y
               inx2
               cpx   #16*2
               bne   Star3Loop
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
wait1          VBLWait
               dex
               bpl   wait1

Fade1          ldx   #10
wait2          VBLWait
               dex
               bpl   wait2
               lda   $E19E00+15*2
               clc
               adc   #$111
               sta   $E19E00+15*2
               cmp   #$666
               bcc   Fade1

Fade2          ldx   #10
wait3          VBLWait
               dex
               bpl   wait3
               lda   $E19E00+14*2
               clc
               adc   #$111
               sta   $E19E00+14*2
               lda   $E19E00+15*2
               clc
               adc   #$111
               sta   $E19E00+15*2
               cmp   #$AAA
               bcc   Fade2

Fade3          ldx   #10
wait4          VBLWait
               dex
               bpl   wait4
               lda   $E19E00+13*2
               clc
               adc   #$111
               sta   $E19E00+13*2
               lda   $E19E00+14*2
               clc
               adc   #$111
               sta   $E19E00+14*2
               lda   $E19E00+15*2
               clc
               adc   #$111
               sta   $E19E00+15*2
               cmp   #$FFF
               bcc   Fade3

               rts

               end

************************************************************************
*
* RANDOM
*
************************************************************************

Random         start
;
; Get a random number between 0 and 159
;
RandStarX      entry
               phx
               Random @a
               UDivide (@a,#412),(@a,@y)
               plx
               rts
;
; Get a random number between 0 and 200*160-1
;
RandStarXY     entry
               phx
RandLoop       Random @a
               and   #%0111111111111111
               cmp   #160*200-1
               bcs   RandLoop
               plx
               rts

               end

************************************************************************
*
* MOVESTARS
*  - Interrupt tasks for moving star field
*
************************************************************************
;
; Move closeset star field
;
StarsTask1     start

               using StarsData

               ds    4
TaskCount      dc    i'1'
               dc    h'5AA5'

               proc  pd
               long  ai

               lda   DirectPage
               tcd

               short a

               ldx   #0
Loop           ldy   Stars1,x
               lda   Vis1,x
               bne   Move
               lda   [BackPtr],y
               sta   [ScrnPtr],y
Move           long a
               tya
               clc
               adc   #160*2
               cmp   #200*160-1
               bcc   Good
               jsr   RandStarX
Good           sta   Stars1,x
               tay
               short  a
               lda   [ScrnPtr],y
               and   #$F0
               bne   Next
               lda   #$F0
               ora   [ScrnPtr],y
               sta   [ScrnPtr],y
               lda   #0
Next           sta   Vis1,x
               inx2
               cpx   #16*2
               bcc   Loop

               ld2   1,TaskCount

               procendL

               longa on

               end
;
; Move middle star field
;
StarsTask2     start

               using StarsData

               ds    4
TaskCount      dc    i'1'
               dc    h'5AA5'

               proc  pd
               long  ai

               lda   DirectPage
               tcd

               short a

               ldx   #0
Loop           ldy   Stars2,x
               lda   Vis2,x
               bne   Move
               lda   [BackPtr],y
               sta   [ScrnPtr],y
Move           long  a
               tya
               clc
               adc   #160
               cmp   #200*160-1
               bcc   Good
               jsr   RandStarX
Good           sta   Stars2,x
               tay
               short a
               lda   [ScrnPtr],y
               and   #$F0
               bne   Next
               lda   #$E0
               ora   [ScrnPtr],y
               sta   [ScrnPtr],y
               lda   #0
Next           sta   Vis2,x
               inx2
               cpx   #16*2
               bcc   Loop

               ld2   1,TaskCount

               procendL

               longa on

               end
;
; Move far star field
;
StarsTask3     start

               using StarsData

               ds    4
TaskCount      dc    i'2'
               dc    h'5AA5'

               proc  pd
               long  ai

               lda   DirectPage
               tcd

               short a

               ldx   #0
Loop           ldy   Stars3,x
               lda   Vis3,x
               bne   Move
               lda   [BackPtr],y
               sta   [ScrnPtr],y
Move           long  a
               tya
               clc
               adc   #160
               cmp   #200*160-1
               bcc   Good
               jsr   RandStarX
Good           sta   Stars3,x
               tay
               short a
               lda   [ScrnPtr],y
               and   #$F0
               bne   Next
               lda   #$D0
               ora   [ScrnPtr],y
               sta   [ScrnPtr],y
               lda   #0
Next           sta   Vis3,x
               inx2
               cpx   #16*2
               bcc   Loop

               ld2   2,TaskCount

               procendL

               longa on

               end

************************************************************************
*
* FADE
*  - Special color fading routines
*
************************************************************************

Fade           start
;
; Fade color 01b to $000, Fade color 10b to $FFF, color 11b does both!
;
TransitionFade entry
Fade1          VBLWait
               ldx   #1
wait1          VBLWait
               dex
               bpl   wait1
               sec
               lda   $E19E02
               sbc   #$111
               sta   $E19E02
               sec
               lda   $E19E06
               sbc   #$111
               sta   $E19E06
               clc
               lda   $E19E04
               adc   #$111
               sta   $E19E04
               cmp   #$888
               bne   Fade1

               clc
               lda   $E19E06
               adc   #$111
               sta   $E19E06

Fade2          VBLWait
               ldx   #1
wait2          VBLWait
               dex
               bpl   wait2
               sec
               lda   $E19E02
               sbc   #$111
               sta   $E19E02
               clc
               lda   $E19E06
               adc   #$111
               sta   $E19E06
               clc
               lda   $E19E04
               adc   #$111
               sta   $E19E04
               cmp   #$FFF
               bne   Fade2

               rts

               end

************************************************************************
*
* COLORNORM
*  - The current screen message is written in color 10b and 11b. The previous
*    message is still on the screen as color 01b, but defined as black
*  - In 2 passes, we must remove the old message (01b), and replace the
*    current message (10b,11b) to be the color (01b), palettes must also
*    be adjusted. There should be nothing noticeable on the screen.
*
*  - PASS 1
*    Remove all 01b's. When complete set 01b to $FFF (white).
*  - PASS 2
*    Convert all 10b's and 11b's to 01b. When complete set 10b to $000 (black).
*
************************************************************************

ColorNorm      start

temp           equ   $00
;
; PASS 1
;
               short a
               ldy   #200*160-2
Pass1          lda   [BackPtr],y
               tax
               and   #$F0
               sta   temp
               txa
               and   #$0F
               cmp   #$01               ;01b
               bne   Pass1a
               lda   #0                 ;00b
Pass1a         ora   temp
               tax
               and   #$0F
               sta   temp
               txa
               and   #$F0
               cmp   #$10               ;01b
               bne   Pass1b
               lda   #$00               ;00b
Pass1b         ora   temp
               sta   [BackPtr],y
               sta   [ScrnPtr],y
               dey
               bpl   Pass1
;
; Set 01b to white
;
               long  a
               ld2   $FFF,$E19E00+1*2
;
; PASS 2
;
               short a
               ldy   #200*160-2
Pass2          lda   [BackPtr],y
               tax
               and   #$F0
               sta   temp
               txa
               and   #$0F
               cmp   #$02               ;10b
               beq   Pass2a
               cmp   #$03               ;11b
               bne   Pass2b
Pass2a         lda   #$01               ;01b
Pass2b         ora   temp
               tax
               and   #$0F
               sta   temp
               txa
               and   #$F0
               cmp   #$20               ;10b
               beq   Pass2c
               cmp   #$30               ;11b
               bne   Pass2d
Pass2c         lda   #$10               ;01b
Pass2d         ora   temp
               sta   [BackPtr],y
               sta   [ScrnPtr],y
               dey
               bpl   Pass2
;
; Set color 10b to black
;
               long  a
               ld2   $000,$E19E00+2*2

               rts

               end

************************************************************************
*
* CHARACTERS
*  - Character writing procedures
*
************************************************************************

Characters     start

               using Charset
               using Scanline

cx             equ   $10
cy             equ   $12
offset         equ   $14
temp           equ   $1E
count          equ   $20
;
; Draw a text message
;
DrawText       entry

               jsr   ColorNorm
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
TextWait       jsr   TransitionFade
               jsr   ColorNorm
               short a
               sta   $E1C010
Wait           lda   $E1C000
               bpl   Wait
               sta   $E1C010
               long  a
               bra   NextChar
Down           lda   cy
               clc
               adc   #9
               sta   cy
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

ControlTbl     dc    i'Done'            ;0
               dc    i'TextWait'        ;1
               dc    i'Down'            ;2
               dc    i'Setx'            ;3
               dc    i'Sety'            ;4
;
; Draw a character
;
DrawChar       sec
               sbc   #$20
               sta   temp
               asl3  a
               clc
               adc   temp
               asl2  a
               tax
               lda   cy
               asl   a
               tay
               lda   SLTbl,y
               clc
               adc   cx
               tay
               ld2   9,count
CharLoop       lda   CharData,x
               and   #$2222
               ora   [BackPtr],y
               sta   [BackPtr],y
               sta   [ScrnPtr],y
               inx2
               iny2
               lda   CharData,x
               and   #$2222
               ora   [BackPtr],y
               sta   [BackPtr],y
               sta   [ScrnPtr],y
               inx2
               tya
               clc
               adc   #160-2
               tay
               dec   count
               bne   CharLoop

               inc4  cx

               rts

               end

************************************************************************
*
* TEXTDATA
*  - Text messages
*
************************************************************************

TextData       data

StoryText      dc    i1'4,50'
               dc    i1'3,34',c'Welcome to MaXUS Demo I',i1'2'
               dc    i1'3,36',c'Written by Tim Meekins',i1'2'
               dc    i1'3,44',c'Copyright (c) 1990',i1'2,2,2'
               dc    i1'3,0',c'MaXUS  Demo I  is  a  FREEWARE  product.',i1'2'
               dc    i1'3,0',c'This means that you may freely copy this',i1'2'
               dc    i1'3,0',c'but you  CANNOT use this  program or any',i1'2'
               dc    i1'3,0',c'part of it for any other use without the',i1'2'
               dc    i1'3,0',c'consent of the author.',i1'2,2'
               dc    i1'3,26',c'[PRESS ANY KEY TO CONTINUE]',i1'1'

               dc    i1'4,10'
               dc    i1'3,56',c'INTRODUCTION',i1'2,2'
               dc    i1'3,0',c'This series of MaXUS demos is the result',i1'2'
               dc    i1'3,0',c'of attempting to  write a graphics  game',i1'2'
               dc    i1'3,0',c'for the Apple IIgs.  I am  writing  each',i1'2'
               dc    i1'3,0',c'section  of the  game one at a time as a',i1'2'
               dc    i1'3,0',c'method of creating the game.  Even if no',i1'2'
               dc    i1'3,0',c'game is created  directly as a result of',i1'2'
               dc    i1'3,0',c'these  demos,  it  was  well  worth  the',i1'2'
               dc    i1'3,0',c'effort.',i1'2,2'
               dc    i1'3,26',c'[PRESS ANY KEY TO CONTINUE]',i1'1'

               dc    i1'4,10'
               dc    i1'3,50',c'ABOUT THIS DEMO',i1'2,2'
               dc    i1'3,0',c'The main goal of this  first demo was to',i1'2'
               dc    i1'3,0',c'create the  environment for the game and',i1'2'
               dc    i1'3,0',c'to generate an  interrupt  driven moving',i1'2'
               dc    i1'3,0',c'star field.  Other minor goals included:',i1'2,2'
               dc    i1'3,0',c' o Overlapping items on the screen.',i1'2'
               dc    i1'3,0',c' o Smooth fading of overlapping objects.',i1'2'
               dc    i1'3,0',c' o A simple text generator.',i1'2,2,2'
               dc    i1'3,26',c'[PRESS ANY KEY TO CONTINUE]',i1'1'

               dc    i1'4,10'
               dc    i1'3,60',c'THE FUTURE',i1'2,2'
               dc    i1'3,0',c'Watch for  future demos as I continue to',i1'2'
               dc    i1'3,0',c'learn and develop new algorithms. A full',i1'2'
               dc    i1'3,0',c'featured  game may even be released at a',i1'2'
               dc    i1'3,0',c'later date.',i1'2,2'
               dc    i1'3,0',c'For further information:',i1'2'
               dc    i1'3,0',c'   Tim Meekins',i1'2'
               dc    i1'3,0',c'   8372 Morris Rd.',i1'2'
               dc    i1'3,0',c'   Hilliard, OH 43026',i1'2,2'
               dc    i1'3,0',c'   meekins@ohio-state.edu',i1'1'

               dc    i1'0'

               end

************************************************************************
*
* SCANLINE
*  - Addresses for scanlines
*
************************************************************************

Scanline       data
;
; Scanline address table
;
SLTbl          anop
               lcla  &n1
&n1            seta  0
.loop
               dc    i'&n1*160'
&n1            seta  &n1+1
               aif   &n1<200,^loop

               end

               append MAXCH.ASM
