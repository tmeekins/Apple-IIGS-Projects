**********************************************************************
*
* Draw a character
*
**********************************************************************

DrawChar       start

               longa on
               longi on

               using Tables
               using CharGlobal
               using FontGlobal

               and   #$FF
               sec
               sbc   #$20
               asl   a
               asl   a
               asl   a
               asl   a
               clc
               adc   NormalFontPtr
               sta   $0
               lda   NormalFontPtr+2
               sta   $2

               lda   CV                 ;Point to beginning Scanline
               asl   a
               tay
               lda   CharYTable,y
               sta   ScrnAdr

               lda   CH                 ;Character horizontal position
               asl   a
               tay

               clc
               ldx   #8
Loop           lda   [$0]
               sta   [ScrnAdr],y
               inc   $0
               inc   $0
               tya
               adc   #160
               tay
               dex
               bne   Loop

               rts

               end

**********************************************************************
*
* Draw a string
*
**********************************************************************

DrawString     start

               longa on
               longi on

               using CharGlobal

               sta   $8
               lda   ($8)
               and   #$FF
               tax
               beq   Done               ;Quick, before we slit our throat!

               ldy   #1
Loop           phy
               phx
               lda   ($8),y
               jsr   DrawChar
               inc   CH
               plx
               ply
               iny
               dex
               bne   Loop

Done           jmp   DrawCursor

               end

**********************************************************************
*
* Center String
*
**********************************************************************

CenterString   start

               longa on
               longi on

               using CharGlobal

               sta   $0
               jsr   DrawCursor

               sep   #$20
               longa off
               sec
               lda   #80
               sbc   ($0)
               lsr   a
               sta   CH
               rep   #$20
               longa on

               lda   $0
               jmp   DrawString

               end

**********************************************************************
*
* Move cursor down one line
*
**********************************************************************

NewLine        start

               using CharGlobal

               longa on
               longi on

               jsr   DrawCursor
               inc   CV
               jmp   DrawCursor

               end

**********************************************************************
*
* Place the cursor at the beginning of the line
*
**********************************************************************

StartLine      start

               using CharGlobal

               longa on
               longi on

               lda   CH                 ;So the cursor doesn't flash
               beq   done               ; when there is no cursor motion.

               jsr   DrawCursor
               stz   CH
               jmp   DrawCursor

done           rts

               end

**********************************************************************
*
* Home the cursor then clear the screen
*
**********************************************************************

HomeClear      start

               longa on
               longi on

               using CharGlobal

               stz   CH                 ;move to 0,0
               stz   CV
               jmp   ClrScrn            ;Clear the screen

               end

**********************************************************************
*
* Home the cursor
*
**********************************************************************

Home           start

               longa on
               longi on

               using CharGlobal

               jsr   DrawCursor         ;Erase the cursor
               stz   CH                 ;Move cursor to 0,0
               stz   CV
               jmp   DrawCursor         ;Draw the cursor

               end

**********************************************************************
*
* Draw the cursor
*
**********************************************************************

DrawCursor     start

               longa on
               longi on

               using CharGlobal
               using Tables

               lda   CursorFlag
               bne   Draw
               rts

Draw           lda   CV                 ;Point to beginning Scanline
               asl   a
               tay
               lda   CharYTable,y
               sta   ScrnAdr

               lda   CH                 ;Character horizontal position
               asl   a
               tay

               clc
               ldx    #8                ;Draw the cursor
Loop           lda   [ScrnAdr],y
               eor   #$FFFF
               sta   [ScrnAdr],y
               tya
               adc   #$A0
               tay
               dex
               bne   Loop

               rts

               end

**********************************************************************
*
* Character Globals
*
**********************************************************************

CharGlobal     data

CursorFlag     ds    2                  ;Display the cursor
CH             ds    2                  ;Cursor horizontal position
CV             ds    2                  ;Cursor vertical position

               end
