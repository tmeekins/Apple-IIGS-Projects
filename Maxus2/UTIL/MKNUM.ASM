****************************************************************************
*
* MaXUS
*
* Reads TOP.SHR and creates an ORCA/M assembly language file
* for assembling score numbers
*
****************************************************************************

               mcopy mkstat.mac

mknum          start

               proc

               Open  OpenParm
               mv2   OpenRef,ReadRef
               sta   CloseRef
               Read  ReadParm
               Close CloseParm

               WriteLine #StatStr2
               jsr   WriteLine

               lda   #9
               sta   Left
               ldy   #160*14
               ldx   #40
Loop           lda   Data,y
               and   #$FF
               phy
               phx
               jsr   WriteByte
               plx
               ply
               iny
               dex
               bne   next
               ldx   #40
               tya
               clc
               adc   #120
               tay
               phy
               phx
               sep   #$30
               inc   StatStr2+7
               rep   #$30
               WriteLine #EndStr
               WriteLine #StatStr2
               jsr   WriteLine
               plx
               ply
               dec   left
next           lda   left
               bne   loop

               WriteLine #EndStr

               procendL

WriteByte      pha
               lda   NumByteOut
               cmp   #36
               bne   DoWrite
               WriteLine #EndStr
               jsr   WriteLine
DoWrite        pla
               Int2Hex (@a,#HexStr+1,#2)
               WriteString #HexStr
               inc   NumByteOut
               rts

WriteLine      WriteString #LineStr
               stz   NumByteOut
               rts

left           ds    2
NumByteOut     ds    2

StatStr2       str   'NumLin0 anop'
LineStr        str   ' dc h'''
EndStr         str   ''''
HexStr         str   '00'

OpenParm       dc    i'2'
OpenRef        ds    2
               dc    i4'FileName'

ReadParm       dc    i'4'
ReadRef        ds    2
               dc    i4'Data'
               dc    i4'$8000'
               ds    4

CloseParm      dc    i'1'
CloseRef       ds    2

FileName       GSStr 'STAT.SHR'

Data           ds    $8000

               end
