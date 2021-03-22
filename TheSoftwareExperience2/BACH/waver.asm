
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
* WAVER.ASM                                                               *
*  - Loads DOC memory from a SynthLab .WAV file.                          *
*    The up and down arrows advance start of sound, left and right arrows *
*    adjust the length of the sound. This utility is used to pull         *
*    instruments out of a wave file. Can be easily modified for many      *
*    other wave files besides SynthLab.                                   *
*                                                                         *
***************************************************************************

               mcopy waver.mac

Waver          START

TempHandle     equ   0

               proc

               TLStartUp
               MMStartUp ID
               NewHandle (#$100,ID,#%1100000000000101,#0),TempHandle
               SoundStartUp [TempHandle]

               jsr   insert
               jsr   LoadFile

               short ai
               ld2   %00001111,$E0C03C
               ld2   $E1,$E0C03E
               ld2   8,$E0C03D          ;Using 4 oscillators

               ld2   $02,$E0C03E        ;Set freq ($100)
               ld2   $00,$E0C03D
               ld2   $22,$E0C03E
               ld2   $01,$E0C03D
               ld2   $03,$E0C03E
               ld2   $00,$E0C03D
               ld2   $23,$E0C03E
               ld2   $01,$E0C03D

               ld2   $42,$E0C03E        ;set volume
               ld2   $FF,$E0C03D
               ld2   $43,$E0C03E
               ld2   $FF,$E0C03D

sloop          anop

               long  ai
               Int2Hex (adr,#start,#2)
               Int2Dec (len,#length,#1,#0)
               WriteCString #str
               short ai

               ld2   $C2,$E0C03E        ;table size
               ldx   len
               lda   lentbl,x
               sta   $E0C03D
               ld2   $C3,$E0C03E
               ldx   len
               lda   lentbl,x
               sta   $E0C03D

               ld2   $82,$E0C03E        ;wave ptr
               mv2   adr,$E0C03D
               ld2   $83,$E0C03E
               mv2   adr,$E0C03D

               ld2   $A2,$E0C03E        ;Control
               ld2   %00010100,$E0C03D
               ld2   $A3,$E0C03E
               ld2   %00000100,$E0C03D

               sta   $E0C010
wait           lda   $E0C000
               bpl   wait
               sta   $E0C000

               and   #$7F

               cmp   #$20
               bcs   wait
               cmp   #11
               bne   key2
               inc   adr
key2           cmp   #10
               bne   key3
               dec   adr
key3           cmp   #27
               bne   key4
               ld2   1,done
key4           cmp   #21
               bne   key5
               inc   len
key5           cmp   #8
               bne   key6
               dec   len
key6           anop

               ld2   $A2,$E0C03E        ;stop
               ld2   1,$E0C03D
               ld2   $A3,$E0C03E
               ld2   1,$E0C03D

               lda   done
               bne   alldone
               jmp   sloop

alldone        long  ai

               SoundShutDown
               MMShutDown ID
               TLShutDown

               procendL

SoundParm      anop

done           dc    i1'0'
adr            dc    i1'0'
               dc    i1'0'
len            dc    i1'0'
               dc    i1'0'
lentbl         dc    i1'%00000000,%00001000,%00010000,%0001100'
               dc    i1'%00100000,%00101000,%00110000,%0011100'

str            dc    c'Start: $'
start          dc    c'00'
               dc    c' Len: '
length         dc    c'0'
               dc    i1'13'
               dc    i1'0'

ID             ds    2

               END

***************************************************************************
*                                                                         *
* Insert Disks dialog                                                     *
*                                                                         *
***************************************************************************

               longa on
               longi on

insert         start

               SetLevel LevelParm
               Close CloseAll

               TLTextMountVolume (#str1,#str2,#str3,#str3),@A

               SetPrefix PrefixParm

               rts

str1           str   'Insert SynthLab Disk'
str2           str   '  and Press return'
str3           str   'OK'

CloseAll       dc    i'1,0'
LevelParm      dc    i'1,0'

prefix         GSStr ':SynthLab.1.b0:Seq.and.Instr:'

PrefixParm     dc    i'2'
               dc    i'0'
               dc    i4'prefix'

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
               sei
               WriteRamBlock (#buffer,#$0000,#$8000)
               cli

               Read  ReadParm
               sei
               WriteRamBlock (#buffer,#$8000,#$8000)
               cli

               Close CloseParm


               rts

OpenParm       dc    i'2'
OpenRef        ds    2
               dc    i4'FileName'

MarkParm       dc    i'3'
MarkRef        ds    2
               dc    i'0'
               dc    i4'$900'

ReadParm       dc    i'4'
ReadRef        ds    2
               dc    i4'buffer'
               dc    i4'$8000'
               ds    4

CloseParm      dc    i'1'
CloseRef       ds    2

FileName       GSStr 'Demo.WAV'

buffer         ds    $8000

               end
