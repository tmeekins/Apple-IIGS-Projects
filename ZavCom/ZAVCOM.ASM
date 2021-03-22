****************************************************************
*
* ZavCom 1.00a
* A telecommunications program written by Tim Meekins
*
* Copyright (C) 1988 by Tim Meekins, All Rights Reserved
*
****************************************************************

         keep  zavcom
         mcopy zavcom.mac

ZavCom   start
         using global
         using Terminal

         phk
         plb

         pha
         _MMStartUp
         pl2   UserID
         pha
         pha
         ph4   #$7D00
         ph2   UserID
         ph2   #$18
         ph4   #0
         _NewHandle
         pl4   SaveHandle

         _TextStartUp
         ph2   #$FF
         ph2   #$00
         _SetInGlobals
         ph2   #$FF
         ph2   #$00
         _SetOutGlobals
         ph2   #1
         ph4   #2
         _SetInputDevice
         ph2   #1
         ph4   #2
         _SetOutputDevice
         ph2   #0
         _InitTextDev
         ph2   #1
         _InitTextDev
         jsr   GraphOn
         stz   numCtl
         lda   #0
         ldy   #0
init     sta   OutTbl,y
         iny
         iny
         inc   a
         cmp   #256
         bne   init
         jsr   dotitle
         jmp   term

UserID   ds    2

         end
*
* Term portion
*
term     start

         sep   #$20
         lda   $e0c000
         bmi   key
         rep   #$20
term1    ph2   #0
         ph2   #1
         _StatusTextDev
         bcc   term
         pha
         ph2   #0
         _ReadChar
         pla
         and   #$FF
         jsr   writechar
         bra   term
key      lda   $e0c000
         sta   $e0c010
         pha
         lda   $e0c061
         bmi   OpenApple
         pla
         rep   #$20
send     and   #$7f
         pha
         _WriteChar
         bra   term1
OpenApple pla
         rep  #$20
         and   #$7f
         cmp   #'a'
         bcc   Goodcase
         sec
         sbc   #$20
Goodcase cmp   #'Q'
         beq   quit
         cmp   #'E'
         bne   aa
         jsr   LoadTerm
         jmp   send
aa       jmp   send
quit     sep   #$20
         longa off
         lda   #$1
         sta   $e0c029
         rep   #$20
         longa on
         rtl
         end
*
* Display title of program
*
dotitle  start
         using global
         jsr   Home
         jsr   CursorOff
         lda   #title1
         jsr   CenterStr
         jsr   crlf
         lda   #title2
         jsr   CenterStr
         jsr   crlf
         lda   #79
         sta   CH
loop     lda   #$8C
         jsr   DrawChar
         dec   CH
         bpl   loop
         lda   #3
         sta   CV
         stz   CH
         jmp   CursorOn

title1   dc    c'ZavCom v1.00a',i1'0'
title2   dc    c'Copyright (C) 1988 by Tim Meekins',i1'0'

         end

         copy  graph.inc
         copy  data.inc
         copy  tables.inc
         copy  charset.inc
         copy  term.inc
         copy  file.inc
