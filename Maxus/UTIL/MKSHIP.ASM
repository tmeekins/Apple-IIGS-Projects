****************************************************************************
*
* MaXUS
*
* Reads SHIP.SHR and creates an ORCA/M assembly language file
*
****************************************************************************

               mcopy mkstat.mac

mkship         start

               proc

               Open  OpenParm
               mv2   OpenRef,ReadRef
               sta   CloseRef
               Read  ReadParm
               Close CloseParm

               WriteLine #BaseStr
               jsr   WriteLine

               lda   #24
               sta   linesleft
               ldy   #0
               ldx   #11
baseloop       lda   data,y
               jsr   WriteByte
               iny
               dex
               bne   baseloop
               phy
               WriteLine #EndStr
               jsr   WriteLine
               ply
               ldx   #11
               tya
               clc
               adc   #160-11
               tay
               dec   linesleft
               bne   baseloop
               WriteLine #EndStr

               lda   #0
               sta   shipnum
bigloop        WriteLine #ShipStr
               jsr   WriteLine
               lda   #17
               sta   linesleft
               lda   shipnum
               asl   a
               tax
               ldy   ytbl,x
               lda   sltbl,y
               clc
               adc   xtbl,x
               tay
               ldx   #11
shiploop       lda   data,y
               jsr   WriteByte
               iny
               dex
               bne   shiploop
               phy
               WriteLine #EndStr
               jsr   WriteLine
               ply
               ldx   #11
               tya
               clc
               adc   #160-11
               tay
               dec   linesleft
               bne   shiploop
               WriteLine #EndStr
               inc   shipnum
               lda   shipnum
               cmp   #33
               bcs   shipdone
               Int2Hex (@a,#shipstr+8,#2)
               jmp   bigloop

shipdone       anop

               WriteLine #PalStr
               jsr   WriteLine

               ldy   #0                 ;This could OBVIOUSLY be written better
               ldx   #$7E00             ;but what do you expect for a quick
Loop2          lda   Data,x             ;HACK??
               jsr   WriteByte
               inx
               iny
               cpy   #16*2
               bcc   Loop2

               WriteLine #EndStr

               procendL

WriteByte      phx
               phy
               pha
               lda   NumByteOut
               cmp   #36
               bne   DoWrite
               WriteLine #EndStr
               jsr   WriteLine
DoWrite        pla
               and   #$ff
               Int2Hex (@a,#HexStr+1,#2)
               WriteString #HexStr
               inc   NumByteOut
               ply
               plx
               rts

WriteLine      WriteString #LineStr
               stz   NumByteOut
               rts

linesleft      ds    2
shipnum        ds    2
NumByteOut     ds    2

ShipStr        str   'ShipPic00 anop'
BaseStr        str   'BasePic anop'
LineStr        str   ' dc h'''
EndStr         str   ''''
HexStr         str   '00'
PalStr         str   'ShipPal anop'

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

FileName       GSStr 'SHIP.SHR'

xtbl           dc    i'11,22,33,44,55,66,77,88,99,110'
               dc    i'0,11,22,33,44,55,66,77,88,99,110,121,132'
               dc    i'0,11,22,33,44,55,66,77,88,99'
ytbl           dc    i'0,0,0,0,0,0,0,0,0,0'
               dc    i'2,2,2,2,2,2,2,2,2,2,2,2,2'
               dc    i'4,4,4,4,4,4,4,4,4,4'
sltbl          dc    i'0,160*25,160*50'

Data           ds    $8000

               end
