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
* MKORGAN.ASM                                                             *
*  - Creates Organ data. Steals it from SynthLab.                         *
*                                                                         *
***************************************************************************

               mcopy mkorgan.mac

MkOrgan        START

               proc

               jsr   Insert
               jsr   LoadFile

               WriteLine #OrganStr
               WriteLine #OrganStr2
               jsr   WriteLine
;
; Output organ data
;
               ldy   #0
Loop           lda   buffer,y
               and   #$FF
               phy
               jsr   WriteByte
               ply
               iny
               cpy   #1024
               bcc   Loop

               WriteLine #EndStr
               WriteLine #DoneStr

               procendL
;
; Output a byte of data to standard out.
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
WriteLine      WriteString #LineStr
               stz   NumByteOut
               rts

NumByteOut     ds    2

OrganStr       str   'OrganData data'
OrganStr2      str   'Organ anop'
EndStr         str   ''''
DoneStr        str   ' end'
LineStr        str   ' dc h'''
HexStr         str   '00'

               END

***************************************************************************
*                                                                         *
* Insert Disks dialog                                                     *
*                                                                         *
***************************************************************************

               longa on
               longi on

insert         start

               TLTextMountVolume (#str1,#str2,#str3,#str3),@A

               rts

str1           str   'Insert SynthLab Disk and'
str2           str   'keep GS.Exp.2.D1'
str3           str   'OK'

               end

***************************************************************************
*                                                                         *
* Load A SynthLab Wave File                                               *
*                                                                         *
***************************************************************************

LoadFile       start

               Open  OpenParm
               mv2   OpenRef,(ReadRef,CloseRef,MarkRef)
               SetMark MarkParm
               Read  ReadParm
               Close CloseParm

               rts

OpenParm       dc    i'2'
OpenRef        ds    2
               dc    i4'FileName'

MarkParm       dc    i'3'
MarkRef        ds    2
               dc    i'0'
               dc    i4'$900+$2800'

ReadParm       dc    i'4'
ReadRef        ds    2
               dc    i4'buffer'
               dc    i4'1024'
               ds    4

CloseParm      dc    i'1'
CloseRef       ds    2

FileName       GSStr ':SynthLab.1.b0:Seq.and.Instr:Demo.WAV'

buffer         ENTRY
               ds    1024

               end
