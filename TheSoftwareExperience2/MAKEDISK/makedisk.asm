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
* MAKEDISK.ASM                                                            *
*  - Create a boot disk of TSE #2                                         *
*                                                                         *
***************************************************************************

               mcopy makedisk.mac

MakeDisk       START

DPHandle       equ   0
DPPtr          equ   4

               proc
               long  ai
;
; Start up tools
;
               TLStartUp
;
; Tell user to insert the correct disks
;
               jsr   insert
;
; Load boot code and write to block 0
;
               WriteString #Str1
               lda   #1
               jsr   LoadFile
               ld4   Buffer,WriteBuf
               ld4   512,WriteCount
               ld4   0,WriteBlockNum
               jsr   WriteBlocks
;
; Load Splash1 code and write to block 7-18
;
               WriteString #Str2
               lda   #2
               jsr   LoadFile
               ld4   Buffer,WriteBuf
               ld4   512*12,WriteCount
               ld4   7,WriteBlockNum
               jsr   WriteBlocks
;
; Load Splash2 code and write to block 19-28
;
               WriteString #Str3
               lda   #3
               jsr   LoadFile
               ld4   Buffer,WriteBuf
               ld4   512*10,WriteCount
               ld4   19,WriteBlockNum
               jsr   WriteBlocks
;
; Load PlayBach code and write to block 29-41
;
               WriteString #Str4
               lda   #4
               jsr   LoadFile
               ld4   Buffer,WriteBuf
               ld4   512*13,WriteCount
               ld4   29,WriteBlockNum
               jsr   WriteBlocks
;
; Load Splash3 code and write to block 42-58
;
               WriteString #Str5
               lda   #5
               jsr   LoadFile
               ld4   Buffer,WriteBuf
               ld4   512*17,WriteCount
               ld4   42,WriteBlockNum
               jsr   WriteBlocks
;
; Shut down the tools
;
               TLShutDown

               procendL
;
; Write blocks
;
WriteBlocks    Int2Hex (WriteBlockNum,#blockstr2,#4)
               WriteCString #blockstr
               DWrite WriteParm
               Int2Hex (@a,#ErrStr+2,#4)
               WriteLine #ErrStr
               rts

blockstr       dc    c'Writing block $'
blockstr2      dc    c'0000 ',i1'0'
ErrStr         str   '(0000)'

WriteParm      dc    i2'6'
               dc    i2'1'
WriteBuf       dc    i4'buffer'
WriteCount     dc    i4'512'
WriteBlocknum  dc    i4'0'
               dc    i2'512'
               ds    4

Str1           str   'Loading BOOT '
Str2           str   'Loading SPLASH1 '
Str3           str   'Loading SPLASH2 '
Str4           str   'Loading PLAYBACH '
Str5           str   'Loading SPLASH3 '

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

str1           str   'Insert Boot Disk into Drive 1'
str2           str   'Insert /GS.Exp.2.D1 into Drive 2'
str3           str   'OK'

CloseAll       dc    i'1,0'
LevelParm      dc    i'1,0'

prefix         GSStr ':GS.Exp.2.D1:MakeDisk'

PrefixParm     dc    i'2'
               dc    i'0'
               dc    i4'prefix'

               end

***************************************************************************
*                                                                         *
* Load A File                                                             *
*                                                                         *
***************************************************************************

LoadFile       start

               dec   a
               asl2  a
               tay
               lda   filenames,y
               sta   FileName
               lda   filenames+2,y
               sta   FileName+2

               Open  OpenParm
               Int2Hex (@a,#ErrStr+2,#4)
               WriteString #ErrStr
               mv2   OpenRef,(ReadRef,CloseRef)
               Read  ReadParm
               Int2Hex (@a,#ErrStr+2,#4)
               WriteLine #ErrStr
               Close CloseParm

               rts

OpenParm       dc    i'2'
OpenRef        ds    2
FileName       ds    4

ReadParm       dc    i'4'
ReadRef        ds    2
               dc    i4'buffer'
               dc    i4'$8000'
               ds    4

CloseParm      dc    i'1'
CloseRef       ds    2

filenames      dc    i4'file01,file02,file03,file04,file05'

file01         GSStr 'boot'
file02         GSStr 'splash1'
file03         GSStr 'splash2'
file04         GSStr 'playbach'
file05         GSStr 'splash3'

errstr         str   '(0000) '

buffer         ENTRY
               ds    $3000

               end

