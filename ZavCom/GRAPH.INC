****************************************************************
*
* Graphics routines
*
****************************************************************

*
* Initialize graphics screen then clear the screen
*
GraphOn  start
         using Tables
         sep   #$30
         longa off
         longi off
         lda   #$C1
         sta   $E0C029
         ldx   #$1F
Copy     lda   Pal640,x
         sta   $E19E00,x
         dex
         bpl   Copy
         ldx   #199
         lda   #$80
ModeLoop sta   $E19D00,x
         dex
         bpl   ModeLoop
         rep   #$30
         longa on
         longi on
         lda   #$e1
         sta   $2
         end                            ;Fall through to clear screen
*
* Clear the graphics screen
*
ClrScr   start
         lda   #0
         sta   $E12000
         phb
         ldx   #$2000
         ldy   #$2001
         lda   #$7CFE
         mvn   $E10000,$E10000
         plb
         jmp   DrawCurs
         end
*
* Home
* Place cursor at 0,0
*
Home     start
         using global
         jsr   DrawCurs
         stz   CH
         stz   CV
         jmp   DrawCurs
         end
*
* HomeClr
* Place cursor at 0,0 and clear the screen
*
HomeClr  start
         using global
         stz   CH
         stz   CV
         bra   ClrScr
         end
*
* Save screen to a buffer
*
SaveScrn start
         using global
         jsr   CursorOff
         lda   SaveHandle
         sta   $0
         lda   SaveHandle+2
         sta   $2
         lda   [$0]
         sta   $4
         ldy   #2
         lda   [$0],y
         sta   $6
         lda   #$2000
         sta   $0
         lda   #$E1
         sta   $2
         ldy   #$7D00
loop     lda   [$0],y
         sta   [$4],y
         dey
         dey
         bpl   loop
         lda   CH
         sta   CHSave
         lda   CV
         sta   CVSave
         rts
         end
*
* Restore screen from a buffer
*
RestScrn start
         using global
         lda   SaveHandle
         sta   $0
         lda   SaveHandle+2
         sta   $2
         lda   [$0]
         sta   $4
         ldy   #2
         lda   [$0],y
         sta   $6
         lda   #$2000
         sta   $0
         lda   #$E1
         sta   $2
         ldy   #$7D00
loop     lda   [$4],y
         sta   [$0],y
         dey
         dey
         bpl   loop
         lda   CHSave
         sta   CH
         lda   CVSave
         sta   CV
         jmp   CursorOn
         end
*
* Draw a Cursor on the screen
*
DrawCurs start
         using global
         using Tables
         lda   CursFlag
         bne   ok
         rts
ok       lda   CV
         asl   a
         asl   a
         asl   a
         asl   a
         tay
         lda   SLAdr,y
         sta   $0
         lda   CH
         asl   a
         tay
         ldx   #8
Loop     lda   [$0],y
         eor   #$FFFF
         sta   [$0],y
         lda   $0
         clc
         adc   #160
         sta   $0
         dex
         bne   Loop
         rts
         end
*
* Draw string pointed to by A
* Delimeted with a 0
*
drawstring start
         sta   $4
DrawS0   entry
         ldy   #0
loop     lda   ($4),y
         and   #$ff
         beq   done
         phy
         jsr   WriteChar
         ply
         iny
         bra   loop
done     rts
         end
*
* Draw a string and center it
*
CenterStr start
         using global
         sta   $4
         ldy   #0
         sep   #$20
loop     lda   ($4),y
         beq   gotit
         iny
         bra   loop
gotit    sty   $6
         rep   #$20
         lda   #80
         sec
         sbc   $6
         lsr   a
         sta   CH
         jmp   DrawS0
         end
*
* Draw a character on the screen
* On input: A = character to print
*
DrawChar start
         using global
         using CharTab
         using Tables
         asl   a
         asl   a
         asl   a
         asl   a
         clc
         adc   #CharSet
         sta   $6
         lda   CV
         asl   a
         asl   a
         asl   a
         asl   a
         tay
         lda   SLAdr,y
         sta   $0
         lda   CH
         asl   a
         tay
         ldx   #8
Loop     lda   ($6)
         eor   InvFlag
         cpx   #1
         bne   Store
         eor   UnderFlag
Store    sta   [$0],y
         inc   $6
         inc   $6
         lda   $0
         clc
         adc   #160
         sta   $0
         dex
         bne   Loop
         rts
         end
*
* Write a character to the screen and update cursor position
* On input: A = character to print
*
WriteChar start
         using global
         using terminal
         and   AndMask
         ora   OrMask
         ldx   numCtl
         beq   noCtl
         ldy   #0
ctlChk   cmp   CtlTbl,y
         beq   doCtl
         iny
         iny
         iny
         iny
         dex
         bne   ctlChk
noCtl    clc
         adc   MouseTxt
         asl   a
         tay
         lda   OutTbl,y
         jsr   DrawChar
         inc   CH
         lda   CH
         cmp   #80
         bcs   CRLF0
         jmp   DrawCurs
doCtl    iny
         iny
         lda   CtlTbl,y
         sta   jump+1
jump     jmp   $FFFF
         end
*
* Carriage Return
* Reset the cursor to column 0
*
CR       start
         using global
         jsr   DrawCurs
         stz   CH
         jmp   DrawCurs
         end
*
* Carriage Return followed by a line feed
*
CRLF     start
         using global
         jsr   DrawCurs
CRLF0    entry
         stz   CH
         bra   LF0                      ;Fall through to LF
         end
*
* Line Feed
* Move cursor to next row. Scroll if necessary
*
LF       start
         using global
         jsr   DrawCurs
LF0      entry
         inc   CV
         lda   CV
         cmp   #25
         bcc   done
         dec   CV
         jsr   ScrollUp
done     jmp   DrawCurs
         end
*
* Scroll the screen up one row
*
ScrollUp start
         phb
         ldx   #$2500
         ldy   #$2000
         lda   #$77FF
         mvn   $E12500,$E12000
         lda   #$0
         sta   $E19800
         ldx   #$9800
         ldy   #$9801
         lda   #$4FE
         mvn   $E19800,$E19801
         plb
         rts
         end
*
* Acessable scroll screen up
*
UpScroll start
         jsr   DrawCurs
         jsr   ScrollUp
         jmp   DrawCurs
         end
*
* Scroll screen down
*
ScrollDown start
         using global
         lda   CV
         pha
         jsr   Home
         jsr   DelLine
         jsr   DrawCurs
         pla
         sta   CV
         jmp   DrawCurs
         end
*
* Set underline mode
*
Underline start
         using global
         lda   #$ffff
         sta   UnderFlag
         rts
         end
*
* Set inverse mode
*
Inverse  start
         using global
         lda   #$ffff
         sta   InvFlag
         stz   MouseTxt
         rts
         end
*
* Set normal mode
*
Normal   start
         using global
         stz   InvFlag
         stz   MouseTxt
         stz   UnderFlag
         rts
         end
*
* Show Mouse Text
*
MouseText start
         using global
         stz   InvFlag
         lda   #$40
         sta   MouseTxt
         rts
         end
*
* Move cursor left
*
BS       start
         using global
         lda   CH
         beq   done
         jsr   DrawCurs
         dec   CH
         jmp   DrawCurs
done     rts
         end
*
* Move up one line
*
Up       start
         using global
         lda   CV
         beq   done
         jsr   DrawCurs
         dec   CV
         jmp   DrawCurs
done     rts
         end
*
* Move cursor right
*
Right    start
         using global
         lda   CH
         cmp   #79
         beq   done
         jsr   DrawCurs
         inc   CH
         jmp   DrawCurs
done     rts
         end
*
* Put cursor at end of line
*
EOL      start
         using global
         jsr   DrawCurs
         lda   #79
         sta   CH
         jmp   DrawCurs
         end
*
* Position cursor at X,Y - 32 offset
*
PosXY32  start
         using global
         jsr   DrawCurs
         jsr   ReadChar
         sec
         sbc   #$20
         sta   CH
         jsr   ReadChar
         sec
         sbc   #$20
         sta   CV
         jmp   DrawCurs
         end
*
* Repeat character
*
Repeat   start
         jsr   ReadChar
         pha
         jsr   ReadChar
         tay
         pla
loop     pha
         phy
         jsr   WriteChar
         ply
         pla
         dey
         bne   loop
         rts
         end
*
* Produce a tone for ProTerm
*
Tone     start
         jsr   ReadChar
         jsr   ReadChar
         jsr   ReadChar
         rts
         end
*
* Ring the bell
*
Bell     start
         rts
         end
*
* Send ProTerm Special ID
*
PTSpec   start
         ph2   #29
         _WriteChar
         rts
         end
*
* Tab
*
Tab      start
         using global
         jsr   DrawCurs
         lda   #0
loop     cmp   CH
         beq   next
         bcs   good
next     clc
         adc   #8
         bra   loop
good     cmp   #80
         bcc   cont
         lda   #79
cont     sta   CH
         jmp   DrawCurs
         end
*
* Clear the current line
*
ClrLine  start
         using global
         lda   CH
         pha
         stz   CH
         jsr   ClrEOL
         pla
         sta   CH
         jmp   DrawCurs
         end
*
* Clear to end of line
*
ClrEOL   start
         using global
         using Tables
         lda   CH
         cmp   #80
         bcc   cont
         rts
cont     lda   CV
         asl   a
         asl   a
         asl   a
         asl   a
         tay
         lda   SLAdr,y
         sta   $0
         lda   CH
         asl   a
         pha
         ldx   #8
Loop1    ply
         phy
         lda   #0
Loop2    sta   [$0],y
         iny
         iny
         cpy   #160
         bcc   Loop2
         lda   $0
         clc
         adc   #160
         sta   $0
         dex
         bne   Loop1
         ply
         jmp   DrawCurs
         end
*
* Clear to end of screen
*
ClrEOS   start
         using global
         using Tables
         jsr   ClrEOL
         lda   CV
         cmp   #25
         bcc   cont
         rts
cont     inc   a
         asl   a
         asl   a
         asl   a
         asl   a
         tay
         lda   SLAdr,y
         sta   $0
         pha
         inc   a
         pha
         lda   #0
         sta   [$0]
         lda   #$9CFE
         sec
         sbc   $0
         ply
         plx
         phb
         mvn   $E10000,$E10000
         plb
         rts
         end
*
* Delete Char
*
DelCH    start
         using global
         using Tables
         lda   CV
         asl   a
         asl   a
         asl   a
         asl   a
         tay
         lda   SLAdr,y
         sta   $0
         inc   a
         inc   a
         sta   $4
         lda   $2
         sta   $6
         lda   CH
         asl   a
         pha
         ldx   #8
Loop1    ply
         phy
Loop2    lda   [$4],y
         sta   [$0],y
         iny
         iny
         cpy   #160
         bcc   Loop2
         ldy   #158
         lda   #0
         sta   [$0],y
         lda   $0
         clc
         adc   #160
         sta   $0
         inc   a
         inc   a
         sta   $4
         dex
         bne   Loop1
         ply
         jmp   DrawCurs
         end
*
* Insert Character
*
InsCH    start
         using global
         using Tables
         jsr   DrawCurs
         lda   CV
         asl   a
         asl   a
         asl   a
         asl   a
         tay
         lda   SLAdr,y
         sta   $0
         inc   a
         inc   a
         sta   $4
         lda   $2
         sta   $6
         lda   CH
         asl   a
         sta   $8
         ldx   #8
Loop1    ldy   #156
Loop2    lda   [$0],y
         sta   [$4],y
         dey
         dey
         bmi   skip
         cpy   $8
         bcs   Loop2
skip     ldy   $8
         lda   #0
         sta   [$0],y
         lda   $0
         clc
         adc   #160
         sta   $0
         inc   a
         inc   a
         sta   $4
         dex
         bne   Loop1
         jmp   DrawCurs
         end
*
* Delete Line
*
DelLine  start
         using global
         using Tables
         lda   CV
         cmp   #24
         beq   blank
         asl   a
         asl   a
         asl   a
         asl   a
         tay
         lda   SLAdr,y
         tay
         clc
         adc   #1280
         tax
         sta   $0
         lda   #$9CFF
         sec
         sbc   $0
         phb
         mvn   $E10000,$E10000
         plb
blank    lda   CH
         pha
         lda   CV
         pha
         stz   CH
         lda   #24
         sta   CV
         jsr   ClrEOL
         jsr   DrawCurs
         pla
         sta   CV
         pla
         sta   CH
         jmp   Drawcurs
         end
*
* Insert Line
*
InsLine  start
         using global
         using Tables
         jsr   DrawCurs
         lda   CV
         cmp   #24
         beq   blank
         inc   a
         asl   a
         asl   a
         asl   a
         asl   a
         tay
         lda   SLAdr,y
         sta   $0
         lda   #$9CFF
         sec
         sbc   $0
         ldy   #$9CFF
         ldx   #$9CFF-1280
         phb
         mvp   $E10000,$E10000
         plb
blank    lda   CH
         pha
         stz   CH
         jsr   ClrEOL
         jsr   DrawCurs
         pla
         sta   CH
         jmp   Drawcurs
         end
*
* Pause after a Ctl-S
* wait for another character
*
Pause    start
         jmp   ReadChar
         end
*
* Null
* Do nothing at all
*
Null     start
         rts
         end
*
* Cursor on
*
CursorOn start
         using global
         lda   CursFlag
         bne   done
         lda   #$FFFF
         sta   CursFlag
         jmp   DrawCurs
done     rts
         end
*
* Cursor off
*
CursorOff start
         using global
         lda   CursFlag
         beq   done
         jsr   DrawCurs
         stz   CursFlag
done     rts
         end
*
* Read character from modem
*
ReadChar start
         pha
         ph2   #0
         _ReadChar
         pla
         and   #$7f
         rts
         end
*
* Get keypress
*
GetKey   start
         sep   #$20
loop     lda   $e0c000
         bpl   loop
         sta   $e0c010
         rep   #$20
         rts
         end
