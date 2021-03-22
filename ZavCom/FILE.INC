****************************************************************
*
* File commands
*
****************************************************************

*
* Select a file
* Allows the user to use the arrow keys to select a file to work with
* On Input: A = address of file type filter procedure (short registers)
*           Y = address of title to dusplay
*
SelectFile start
         Using global
         Using FileData

EntryLen equ   $10
EntryBlk equ   $11
FileCnt  equ   $12
CurFile  equ   $14
NumFile  equ   $16
FileAdr  equ   $18
FileMax  equ   $1A
FileLen  equ   $1C

         sta   Filter
         sty   TitlePtr
         jsr   HomeClr
         lda   TitlePtr
         jsr   CenterStr
         jsr   crlf
         lda   #79
         sta   CH
loop1    lda   #$8C
         jsr   DrawChar
         dec   CH
         bpl   loop1
         lda   #23
         sta   CV
         lda   #79
         sta   CH
loop2    lda   #'_'
         jsr   DrawChar
         dec   CH
         bpl   loop2
         inc   CV
         stz   CH
loop3    ldy   CH
         lda   prompt1,y
         and   #$ff
         beq   done1
         jsr   DrawChar
         inc   CH
         bra   loop3
done1    anop

* Get the initial device to start with

retry1   GET_LAST_DEV DevNum
         bcs   retry1
         lda   DevNum
         and   #$ff
         clc
         adc   #'0'
         sta   DevName+3
         lda   #5
         sta   CV
         stz   CH

* Get the device's name

GetName  VOLUME VolParm

* Add a '/' to the prefix ending

DownPath sep   #$30
         longa off
         inc   Prefix
         ldx   Prefix
         lda   #'/'
         sta   Prefix,x
         inx
         stz   Prefix,x
         rep   #$30
         longa on

* Print the prefix

         lda   #2
         sta   CV
         sta   CH
         jsr   Inverse
         lda   #PfxStr
         jsr   DrawString
         jsr   Normal
         inc   CH
         lda   #Prefix+1
         jsr   DrawString
         jsr   ClrEOL

         jsr   CRLF
         jsr   LF
         ldx   #19
EraseL   phx
         jsr   ClrEOL
         jsr   LF
         plx
         dex
         bne   EraseL

* Open directory and read file entries

         stz   NumFile
         OPEN  OpenParm
         bcs   GoErr0
         lda   OpenRef
         sta   ReadRef
         sta   PosRef
         sta   CloseRef
         lda   #$2b
         sta   ReadLen
         stz   ReadLen+2
         READ  ReadParm
GoErr0   bcs   GoError
         sep   #$30
         longi off
         ldx   #3
copyloop lda   buffer+$23,x
         sta   <EntryLen,x
         dex
         bpl   copyloop
         sta   ReadLen
         rep   #$30
         longi on
         lda   #1
         sta   CurFile
         stz   Position
         stz   Position+2
         lda   FileCnt
         bne   ReadLoop
DoneRead jmp   Select

* Read each file description one at a time

ReadLoop rep   #$30
         lda   FileCnt
         beq   DoneRead
CalcPos  sep   #$30
         longa off
         longi off
         lda   Position+1
         and   #$fe
         sta   Position+1
         ldy   CurFile
         lda   #0
         cpy   EntryBlk
         bcc   AddLen
         tay
         sty   CurFile
         inc   Position+1
IncPage  inc   Position+1
Addlen   dey
         clc
         bmi   ReadEnt
         adc   EntryLen
         bcc   AddLen
         bcs   IncPage
ReadEnt  adc   #4
         sta   Position
         rep   #$30
         SET_MARK PosParm
GoError  bcs   Error0
         READ  ReadParm
         bcs   Error0
         sep   #$30
         inc   CurFile
         lda   buffer
         and   #$f0
         beq   CalcPos
         rep   #$20
         dec   FileCnt
         sep   #$20
         ror   buffer+$1e
         bcc   ReadLoop
         lda   buffer+$10
         cmp   #$f
         beq   GoodFile
         ldx   #0
         jsr   (Filter,x)
         bcs   ReadLoop
GoodFile ldx   NumFile
         cpx   #$40
         bcs   Select
         sta   Types,x
         rep   #$30
         jsr   CalcAdr
         sep   #$10
         ldy   #16
CopyFN   lda   buffer,y
         sta   (FileAdr),y
         dey
         dey
         bpl   CopyFN
         sep   #$20
         inc   NumFile
         jmp   ReadLoop

* Disk error occurred

Error0   CLOSE CloseParm
Error    Entry
         longa on
         longi on
         pha
         ph4   #ErrNum
         ph2   #4
         _Int2Hex
         jsr   CRLF
         jsr   LF
         lda   #ErrMsg
         jsr   DrawString
         jsr   GetKey
         sec
         rts

* Find the next Device

NextDev  inc   DevName+3
         lda   DevName+3
         and   #$ff
         cmp   #'9'+1
         bne   scan
restart  lda   #'1'
         sta   DevName+3
scan     VOLUME VolParm
         bcc   done
         cmp   #$11
         beq   restart
         bra   NextDev
done     jmp   GetName

* Select a file

Select   rep   #$30
         longa on
         longi on
         CLOSE CloseParm
         bcs   Error0
         lda   NumFile
         and   #$FF
         bne   PrFiles
         lda   #5
         sta   CV
         lda   #4
         sta   CH
         lda   #NoFiles
         jsr   DrawString
selw0    jsr   GetKey
         and   #$ff
         cmp   #$89                     ;tab
         bne   selq0
SelDisk  jmp   NextDev
selq0    cmp   #$9b                     ;ESC
         bne   selw0
SelQuit  sec
         rts

* Display files

PrFiles  sta   FileMax
         dec   FileMax
PrFLoop  dec   NumFile
         beq   GetSel
         jsr   PrName
         bra   PrFLoop

* Hilight selection and get keypress

GetSel   jsr   Inverse
         jsr   PrName
         jsr   Normal
         jsr   GetKey
         and   #$ff
         cmp   #$9b                     ;esc
         beq   SelQuit
         cmp   #$89                     ;tab
         beq   SelDisk
         cmp   #$8a                     ;down arrow
         beq   Down
         cmp   #$8b                     ;up arrow
         beq   Up
         cmp   #$95                     ;right arrow
         bne   GetSel1
         jmp   Right
GetSel1  cmp   #$88                     ;left arrow
         bne   GetSel0
         jmp   Left
GetSel0  cmp   #$8d                     ;carriage return
         bne   GetSel

* Carriage return

         SET_PREFIX PfxParm
         bcc   Sel00
         jmp   Error0
Sel00    jsr   CalcAdr
         sep   #$30
         longa off
         longi off
         ldx   Prefix
         ldy   #0
         lda   (FileAdr),y
         and   #$f
         sta   FileLen
SelAA    iny
         lda   (FileAdr),y
         and   #$7f
         inx
         sta   Prefix,x
         cpy   FileLen
         bcc   SelAA
         stx   Prefix
         ldy   NumFile
         lda   Types,y
         cmp   #$f
         bne   SelBB
         rep   #$30
         longa on
         longi on
         jmp   DownPath
SelBB    rep   #$30
         clc
         rts


* Down arrow

Down     jsr   PrName
         lda   NumFile
         cmp   FileMax
         beq   Top1
         and   #$f
         cmp   #$f
         beq   Top
         inc   NumFile
         bne   ArrowQ1
Top      lda   NumFile
Top1     and   #$f0
         bpl   ArrowQ

* Up arrow

Up       jsr   PrName
         lda   NumFile
         and   #$f
         beq   Bot
         dec   NumFile
         bpl   ArrowQ1
Bot      lda   NumFile
         ora   #$f
         cmp   FileMax
         bcc   ArrowQ
         lda   FileMax
         bpl   ArrowQ

* Right arrow

Right    jsr   PrName
         lda   NumFile
         clc
         adc   #$10
         cmp   FileMax
         bcc   ArrowQ
         beq   ArrowQ
         and   #$f
         bpl   ArrowQ

* Left arrow

Left     jsr   PrName
         lda   NumFile
         sec
         sbc   #$10
         bpl   ArrowQ
         lda   FileMax
         and   #$f0
         sta   LTemp
         lda   NumFile
         and   #$f
         ora   LTemp
         cmp   FileMax
         bcc   ArrowQ
         beq   ArrowQ
         sbc   #$10
ArrowQ   sta   NumFile
ArrowQ1  jmp   GetSel
LTemp    ds    2

* Calculate address of file

CalcAdr  longa on
         longi on
         lda   NumFile
         and   #$ff
         asl   a
         asl   a
         asl   a
         asl   a
         clc
         adc   #storage
         sta   FileAdr
         rts

* Print File Name

PrName   lda   NumFile
         lsr   a
         lsr   a
         lsr   a
         lsr   a
         asl   a
         tay
         lda   HPos,y
         sta   CH
         lda   NumFile
         tay
         and   #$f
         clc
         adc   #4
         sta   CV
         lda   Types,y
         and   #$ff
         cmp   #$f
         bne   NoDir
         lda   #'/'
         jsr   DrawChar
         inc   CH
NoDir    jsr   CalcAdr
         ldy   #0
         lda   (FileAdr),y
         and   #$f
         tax
         iny
PrNam1   lda   (FileAdr),y
         and   #$ff
         phy
         phx
         jsr   DrawChar
         inc   CH
         plx
         ply
         iny
         dex
         bne   PrNam1
         rts

         end

FileData data
         Using Global

Filter   ds    2
TitlePtr ds    2
prompt1  dc    c'      Use ',i1'$8B',c',',i1'$8A',c',',i1'$88',c',',i1'$95'
         dc    c' to hilight file, <RETURN> to select, <TAB> to change disk'
         dc    i1'0'
PfxStr   dc    c'Prefix:',i1'0'
ErrMsg   dc    c'ProDOS Error $'
ErrNum   dc    c'    ',i1'0'
NoFiles  dc    c'No Files',i1'0'

HPos     dc    i2'4,23,42,61'

DevNum   ds    2
buffer   ds    128

VolParm  anop
         dc    i4'DevName'
         dc    i4'Prefix'
         ds    4
         ds    4
         ds    2

OpenParm anop
OpenRef  ds    2
         dc    i4'Prefix'
         ds    4

ReadParm anop
ReadRef  ds    2
         dc    i4'buffer'
ReadLen  dc    i4'0'
         ds    4

PosParm  anop
PosRef   ds    2
Position dc    i4'0'

         dc    c'HERE!'

CloseParm anop
CloseRef ds    2

PfxParm  anop
         dc    i2'0'
         dc    i4'Prefix'

types    ds    64
storage  ds    1024

         end
