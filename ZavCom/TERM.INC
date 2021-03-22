****************************************************************
*
* Terminal information data
*
****************************************************************
*
* Load Terminal information dialog
*
LoadTerm start
         using FileData
         jsr   SaveScrn
         lda   #TermFilter
         ldy   #Title
         jsr   SelectFile
         bcs   Done
         jsr   ReadTerm
Done     jmp   RestScrn
*
TermFilter longa off
         pha
         lda   buffer+1
         cmp   #'T'
         bne   bad
         lda   buffer+2
         cmp   #'D'
         bne   bad
         lda   buffer+3
         cmp   #'.'
         bne   bad
         clc
         pla
         rts
bad      sec
         pla
         rts
         longa on

Title    dc    c'Select a terminal to load:',i1'0'

         end
*
* Read in the terminal file
*
ReadTerm start
         Using Terminal
         Using Global
         Using Commands

Adr      equ   $10

         jsr   HomeClr
         lda   #1
         sta   CV
         stz   numCtl
         lda   #0
         ldy   #0
init     sta   OutTbl,y
         iny
         iny
         inc   a
         cmp   #256
         bne   init

         OPEN  OpenParm
         bcs   Error0
         lda   OpenRef
         sta   NLRef
         sta   ReadRef
         sta   CloseRef
         NEWLINE NLParm
         bcs   Error0
ReadLoop READ  ReadParm
         bcc   cont
         cmp   #$4c
         bne   Error0
         bra   Done
cont     jsr   DoLine
         bra   ReadLoop

Error0   CLOSE ClosePrm
         jsr   Error
         sec
         rts

Done     CLOSE ClosePrm
         clc
         rts

DoLine   lda   LineLen
         cmp   #2
         bcs   DoLin2
         lda   #Ignore
         jsr   DrawString
         jmp   CRLF
DoLin2   lda   Line
         and   #$7f
         cmp   #'"'
         bne   DoLin4
         jmp   Name
DoLin4   cmp   #'!'
         beq   Comment
         cmp   #'&'
         beq   PAnd
         cmp   #'+'
         beq   POr
         cmp   #'#'
         beq   Type
         cmp   #'$'
         bne   DoLin3
         jmp   Define
DoLin3   lda   #BadComStr
         jsr   DrawString
         jmp   CRLF

Type     rts

PAnd     ldx   #1
         jsr   ReadHex
         sta   andMask
         rts

POr      ldx   #1
         jsr   ReadHex
         sta   orMask
         rts

Name     lda   LineLen
         dec   a
         dec   a
         sta   Length
         ldx   #0
NLoop    lda   Line+1,x
         and   #$7f
         sta   title,x
         inx
         cpx   Length
         bcc   NLoop
Comment  rts

Define   ldx   #1
         jsr   ReadHex
         sta   Char
DefLoop  lda   Line,x
         inx
         and   #$7f
         cmp   #' '
         beq   DefLoop
         cmp   #'$'
         bne   DLabel
         jmp   ReDef
DLabel   lda   #' '
         dex
         ldy   #0
DLoop0   sta   Label,y
         iny
         cpy   #10
         bcc   DLoop0
         ldy   #0
DLoop1   lda   Line,x
         jsr   Convert
         cmp   #'0'
         bcc   DDEnd
         sta   Label,y
         inx
         iny
         cpy   #10
         bcc   DLoop1
DDEnd    lda   #$2020
         sta   Label,y
         lda   #CmdTable
         sta   Adr
DLoop2   ldy   #0
DLoop3   lda   (Adr),y
         beq   NotFound
         and   #$7f7f
         cmp   Label,y
         bne   Next
         iny
         iny
         cpy   #10
         bcc   DLoop3
         bra   Found
Next     lda   #12
         clc
         adc   Adr
         sta   Adr
         bra   DLoop2
NotFound lda   #NotFoundStr
         jsr   DrawString
         ldx   #0
PErLoop  lda   Label,x
         and   #$7f
         phx
         jsr   DrawChar
         inc   CH
         plx
         inx
         cpx   #10
         bcc   PErLoop
PErDone  jsr   CRLF
         jmp   GetKey
Found    lda   NumCtl
         asl   a
         asl   a
         tax
         lda   Char
         sta   CtlTbl,x
         inx
         inx
         ldy   #10
         lda   (Adr),y
         sta   CtlTbl,x
         inc   NumCtl
         rts
ReDef    jsr   ReadHex
         tay
         lda   Char
         asl   a
         tax
         tya
         sta   OutTbl,x
         rts

ReadHex  stz   Value
HexLoop  lda   Line,x
         jsr   Convert
         cmp   #'0'
         bcc   HexDone
         cmp   #'9'+1
         bcs   CheckAlf
         and   #%00001111
         bra   Con
CheckAlf cmp   #'A'
         bcc   HexDone
         cmp   #'G'
         bcs   HexDone
         sec
         sbc   #'A'-10
Con      asl   Value
         asl   Value
         asl   Value
         asl   Value
         ora   Value
         sta   Value
         inx
         bra   HexLoop
HexDone  lda   Value
         rts

* Lowercase to Uppercase

Convert  and   #$7f
         cmp   #'a'
         bcc   DoneCon
         and   #%01011111
DoneCon  rts

Label    ds    12
Length   ds    2
Value    ds    2
Char     ds    2
Line     ds    80

BadComStr dc   c'Bad Command encountered',i1'0'
Ignore   dc    c'Ignored NULL line',i1'0'
NotFoundStr dc c'Illegal Procedure: ',i1'0'

OpenParm anop
OpenRef  ds    2
         dc    i4'Prefix'
         ds    4

NLParm   anop
NLRef    ds    2
         dc    i2'$7f'
         dc    i2'$0d'

ReadParm anop
ReadRef  ds    2
         dc    i4'Line'
         dc    i4'80'
LineLen  ds    4

ClosePrm anop
CloseRef ds    2

         end
*
* Specifications for the current terminal information
*
Terminal data

         dc    c'AND/OR'
andMask  dc    i'$7F'
orMask   dc    i'$00'
title    ds    80
numCtl   dc    i2'0'
CtlTbl   ds    4*128
OutTbl   ds    2*256
InTbl    ds    2*256

         end
*
* A Table of all commands available to the terminal
*
Commands data

CmdTable dc    c'BELL      ',i2'Bell'
         dc    c'BS        ',i2'BS'
         dc    c'CLREOL    ',i2'ClrEOL'
         dc    c'CLREOS    ',i2'ClrEOS'
         dc    c'CLRLINE   ',i2'ClrLine'
         dc    c'CLRSCR    ',i2'ClrScr'
         dc    c'CR        ',i2'CR'
         dc    c'CRLF      ',i2'CRLF'
         dc    c'CURSOROFF ',i2'CursorOff'
         dc    c'CURSORON  ',i2'CursorOn'
         dc    c'DELCHAR   ',i2'DelCH'
         dc    c'DELLINE   ',i2'DelLine'
         dc    c'EOL       ',i2'EOL'
         dc    c'HOME      ',i2'Home'
         dc    c'HOMECLR   ',i2'HomeClr'
         dc    c'INSCHAR   ',i2'InsCH'
         dc    c'INSLINE   ',i2'InsLine'
         dc    c'INVERSE   ',i2'Inverse'
         dc    c'LF        ',i2'LF'
         dc    c'MOUSETEXT ',i2'MouseText'
         dc    c'NORMAL    ',i2'Normal'
         dc    c'NULL      ',i2'Null'
         dc    c'PAUSE     ',i2'Pause'
         dc    c'POSXY32   ',i2'PosXY32'
         dc    c'PROTERM   ',i2'PTSpec'
         dc    c'REPEAT    ',i2'Repeat'
         dc    c'RIGHT     ',i2'Right'
         dc    c'SCROLLDOWN',i2'ScrollDown'
         dc    c'SCROLLUP  ',i2'UpScroll'
         dc    c'TAB       ',i2'Tab'
         dc    c'TONE      ',i2'Tone'
         dc    c'UNDERLINE ',i2'Underline'
         dc    c'UP        ',i2'Up'
         dc    12i1'0'

         end
