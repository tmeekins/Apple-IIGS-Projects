****************************************************************************
*
* MaXUS
*
* Reads TOP.SHR and creates an ORCA/M assembly language file
* for assembling STAT graphics data. Redirect output to MaxStat.asm
*
****************************************************************************

               mcopy mkstat.mac

mkstat         start

               proc

               Open  OpenParm
               mv2   OpenRef,ReadRef
               sta   CloseRef
               Read  ReadParm
               Close CloseParm

               WriteLine #LogoStr1
               WriteLine #LogoStr2
               jsr   WriteLine

               ldy   #0
               ldx   #114
Loop           lda   Data,y
               and   #$FF
               phy
               phx
               jsr   WriteByte
               plx
               ply
               dex
               bne   next
               ldx   #114
               tya
               clc
               adc   #46
               tay
next           iny
               cpy   #160*60
               bcc   Loop

               WriteLine #EndStr
               WriteLine #LogoStr3
               jsr   WriteLine

               ldy   #160*60
               ldx   #46
Loop1          lda   Data,y
               and   #$FF
               phy
               phx
               jsr   WriteByte
               plx
               ply
               dex
               bne   next1
               ldx   #46
               tya
               clc
               adc   #114
               tay
next1          iny
               cpy   #160*78
               bcc   Loop1

               WriteLine #EndStr
               WriteLine #PalStr
               jsr   WriteLine

               ldy   #0                 ;This could OBVIOUSLY be written better
               ldx   #$7E00             ;but what do you expect for a quick
Loop2          lda   Data,x             ;HACK??
               and   #$FF
               phy
               phx
               jsr   WriteByte
               plx
               ply
               inx
               iny
               cpy   #16*2
               bcc   Loop2

               WriteLine #EndStr
               WriteLine #DoneStr

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

NumByteOut     ds    2

LogoStr1       str   'LogoDat start'
LogoStr2       str   'LogoPic anop'
LogoStr3       str   'MaxPic anop'
LineStr        str   ' dc h'''
EndStr         str   ''''
HexStr         str   '00'
PalStr         str   'LogoPal anop'
DoneStr        str   ' end'

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

FileName       GSStr 'LOGO.SHR'

Data           ds    $8000

               end
