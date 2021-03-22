***************************************************************************
*                                                                         *
* The Software Experience #2                                              *
* Written and Produced by Tim Meekins                                     *
* Zavtra Software                                                         *
*                                                                         *
* Copyright 1990 by Tim Meekins, distribution rights granted, all other   *
* rights are reserved.                                                    *
*                                                                         *
***************************************************************************
*                                                                         *
* MKFONT.ASM                                                              *
*  - Takes the SHR file of ATHEN.FONT and creates an assemblable file     *
*                                                                         *
*  Written July 11, 1990                                                  *
*                                                                         *
***************************************************************************

               mcopy mkfont.mac

mkfont         start

               proc
;
; Load the font picture
;
               Open  OpenParm
               mv2   OpenRef,(ReadRef,CloseRef)
               Read  ReadParm
               Close CloseParm
;
; Compress the font picture
;
               PackBytes (#start,#length,#data2,#160*58),PackLen
;
; Output compressed information
;
               WriteLine #FontStr       ;FontData data Linguist
               WriteString #PackSize    ;PackSize dc i'
               Int2Hex (PackLen,#SizeStr+1,#4)
               WriteLine #SizeStr
               WriteLine #Label1
               jsr   WriteLine
;
; Loop through compressed data and output the data
;
               ldy   #0
Loop           lda   Data2,y
               and   #$FF
               phy
               jsr   WriteByte
               ply
               iny
               cpy   PackLen
               bcc   Loop

               WriteLine #EndStr
               WriteLine #Label2
               WriteLine #DoneStr

               procendL
;
; Output a byte of data to standard out, if hit end of line, then start a new
; line
;
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
;
; Start a new line
;
WriteLine      WriteString #LineStr
               stz   NumByteOut
               rts

NumByteOut     ds    2

FontStr        str   'FontData data'
Label1         str   'PackedFont anop'
Label2         str   'TheFont anop'
PackSize       str   'FontPackSize dc i''$'
SizeStr        str   '0000'''
LineStr        str   ' dc h'''
EndStr         str   ''''
HexStr         str   '00'
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

FileName       GSStr 'athen.font'

Data           ds    $8000

start          dc    i4'Data'
length         dc    i4'160*58'
packlen        ds    2

Data2          ds    160*58

               end
