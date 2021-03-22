;
; Tim's RegExp test program
; Written by Tim Meekins 6/12/91
;
; Version 1.0
;
; Copyright 1991 by Tim Meekins
; This is hereby dontated to the public domain as long as my name is
; left in this file as the original author.
;
;
; This program takes a pathname and pattern and lists all files which
; match the pattern in that pathname. Match treats upper case the same
; as lower case. Changing the flag from $0000 to $8000 will make it
; case sensitive.
;
; for example, 'match .d1/*doc' would list all files on device 1 which
; end with 'doc'.
;
; meekins@cis.ohio-state.edu
; timm@pro-tcc.cts.com
;
         mcopy match.mac
         keep  match

TEST     START

cl       equ   0
patt     equ   4

         phk
         plb

         sty   cl
         stx   cl+2                     ;Pointer to shell ID and command line
;
; Strip the shell ID and command name
;
         short a
         ldy   #7
strip    iny
         lda   [cl],y
         beq   whoops
         cmp   #' '
         bne   strip
         iny
whoops   long  a
         clc
         tya
         adc   cl
         sta   cl
         lda   cl+2
         adc   #0
         sta   cl+2
;
; Separate path from pattern
;
         ld4   CurDir,pfx
         mv4   cl,patt
         short a
         ldx   #$FFFF
         ldy   #0
seploop  lda   [cl],y
         beq   sepdone
         cmp   #'/'
         beq   sep
         cmp   #':'
         beq   sep
         iny
         bra   seploop
sep      tyx
         iny
         bra   seploop
sepdone  long  a
         txa
         bmi   seppy
         inx
         clc
         txa
         adc   cl
         sta   patt
         lda   cl+2
         adc   #0
         sta   patt+2
         dex
         txa
         dec   cl
         dec   cl
         sta   [cl]
         mv4   cl,pfx
seppy    anop

         WriteChar #10
         WriteLine #str1
         WriteLine #str2
         WriteChar #10
         WriteString #str3
         WriteCString patt
         WriteChar #13
         WriteChar #10
         WriteChar #10
         WriteLine #str4
         WriteChar #10

         Open  OpenParm
         mv2   OpenRef,(GDERef,CloseRef)
;
; Loop through each file
;
DirLoop  GetDirEntry GDEParm
         bcs   done

         ldy   buffer
         lda   #0
         sta   buffer+2,y

         ph4   patt
         ph4   #buffer+2
         ph2   #$0000
         jsl   RegExp
         cmp   #0
         beq   skip

         WriteCString #buffer+2
         WriteChar #13
         WriteChar #10

skip     jmp   DirLoop


Done     Close CloseParm

         lda   #0
         rtl

OpenParm dc    i'2'
Openref  ds    2
pfx      dc    a4'CurDir'

CloseParm dc   i'1'
CloseRef ds    2

GDEParm  dc    i'5'
GDEref   ds    2
         ds    2
         dc    i'1'
         dc    i'1'
         dc    a4'GSbuffer'

CurDir   gsstr '0:'

str1     str   'RegExp Test program'
str2     str   'Written by Tim Meekins'
str3     str   'Pattern: '
str4     str   'Matching...'

GSbuffer dc    i'65'
buffer   ds    65

         END
