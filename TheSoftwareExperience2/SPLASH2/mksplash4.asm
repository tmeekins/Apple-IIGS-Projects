
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
* MKSPLASH4.ASM                                                           *
*  - Make data for "Two Logo"                                             *
*                                                                         *
***************************************************************************

               mcopy mksplash3.mac

MkSplash4      START

               proc
;
; Show graphics
;
               short a
               ld2   $C1,$E1C029
               long  a
;
; Load and unpack the picture
;
               jsr   UnpackOne
;
; Compress the data
;
               Packbytes (#start,#length,#data,#160*46),PackLen
;
; Output compressed information
;
               WriteLine #SplashStr
               WriteString #PackSize
               Int2Hex (PackLen,#SizeStr+1,#4)
               WriteLine #SizeStr
               WriteLine #Label1
               jsr   WriteLine
;
; Output compressed data
;
               ldy   #0
Loop           lda   Data,y
               and   #$FF
               phy
               jsr   WriteByte
               ply
               iny
               cpy   PackLen
               bcc   Loop

               WriteLine #EndStr
;
; Output the palette
;
               WriteLine #palStr
               jsr   WriteLine

               ldx   #$7E00
palloop        lda   $E12000,x
               phx
               jsr   WriteByte
               plx
               inx
               cpx   #$7E20
               bcc   palloop

               WriteLine #EndStr
               WriteLine #DoneStr
;
; Text mode
;
               short a
               ld2   $41,$E1C029
               long  a

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

SplashStr      str   'Splash4Data data'
PackSize       str   'Splash4PackSize dc i''$'
SizeStr        str   '0000'''
Label1         str   'PackedSplash4 anop'
EndStr         str   ''''
DoneStr        str   ' end'
LineStr        str   ' dc h'''
HexStr         str   '00'
PalStr         str   'Splash4Pal anop'

start          dc    i4'$E12000'
length         dc    i4'160*46'
packlen        ds    2
data           ds    160*46

               END

**************************************************************************
*
* The following routines have been graciously borrowed from an OLD version
* of HodgePodge, from Apple. I have re-written most of it.
*
**************************************************************************

****************************************************************
*
* UnPackOne
*
****************************************************************

UNPackOne      START

               OPEN  OpenParams

               mv2   OpenID,(PReadID,CloseID,MarkID)
               ld4   HeaderBuff,PReadLoc
               ld4   4,PReadSize

               READ  PReadParams

               mv4   HeaderBuff,PReadSize
               ld4   BigBuff,(4,PReadLoc)

               stz   mark               ; reset to the start of the file
               stz   mark+2
               SetMark markparams

               Read  PReadparams        ; now read in the first part
               Close CloseParams

               jsr   GetPallets
               jsr   GetSCBs
               jsr   GetScanLines

exit           rts

OpenParams     dc    i'3'
OpenID         ds    2
NamePtr        dc    i4'FileName'
               ds    2

FileName       GSStr 'Two.Shr'

PReadParams    dc    i'4'               ; for reading a packed file
PReadID        ds    2
PReadLoc       ds    4
PReadSize      ds    4                     ; this many bytes
               ds    4                     ; how many xfered

MarkParams     dc    i'3'
MarkID         ds    2
               dc    i'0'
Mark           ds    4

CloseParams    dc    i'1'
CloseID        ds    2


HeaderBuff     ds    4

BigBuff        ds    $8000

WBPointer      ds    2

CTPointer      ds    4

ScanCounter    ds    2

****************************************************************
*
* GetPallets - This routine will get the pallet array and
*        move it to its final destination, as indicated by
*        PicDestIN.
*
****************************************************************

GetPallets     anop

               ldy   #$D                ; get the number of pallets
               lda   [4],y
               sta   NumPallets
               iny2                     ; point it to the pallets array

               ld4   $E19DF1,0

loop1          ldx   #16
loop2          anop                     ; move the pallet
               lda   [4],y
               sta   [0],y
               iny2
               dex
               bne   loop2

               dec   NumPallets         ; have we moved all of the pallets?
               bne   loop1              ; no, move the next one

               sty   WBPointer

               rts

NumPallets     ds    2

****************************************************************
*
* GetSCBs - This routine will get the SCBs from the ScanLine
*        Directory and mvoe them to their final destinations,
*        as indicated by PicDestIN.
*
****************************************************************

GetSCBs        anop

               ldy   WBPointer          ; get the number of Scanlines
               lda   [4],y
               sta   NumEntries
               sta   ScanCounter
               iny2
               sty   WBPointer
               sty   CTPointer          ; keep a pointer to the DirEntry array

               ld4   $E19D00,0

               ldx   #0
loop3          anop                     ; move the pallet
               iny2                     ; point to SCB part of dir entry
               lda   [4],y
               phy
               txy
               short a                  ; store in 8-bit mode
               sta   [0],y
               long  a
               ply
               iny2                     ; point to next directory entry
               inx                      ; point to next SCB location

               dec   NumEntries         ; have we moved all of the SCBs?
               bne   loop3              ; no, move the next one

               sty   WBPointer          ; now pointing to start of packed array

               rts

NumEntries     ds 2

****************************************************************
*
* GetScanLines
*
* This routine is not as general as it could have been.  It trys to
* handle any size scan line but only keeps 160 bytes worth of data.
* Additionally, it only keeps 200 scan lines worth of data.
*
****************************************************************

GetScanLines   anop

               ldy   #9                 ; get the Master SCB mode
               lda   [4],y
               sta   Mode
               iny2
               lda   [4],y              ; get the number of pixels/line
               sta   PixelsPerLine

               lsr   a                  ; now find the number of bytes per line
               sta   BytesPerLine       ; by dividing PixelsPerLine by 2 if we
               lda   Mode               ; are in 640 mode, and 4 if in 320 mode.
               and   #$0080
               beq   mode320
               lsr   BytesPerLine
mode320        anop


; Clip to 200 scan lines.
;
               cm2   ScanCounter,#200
               bcc   OKNSL              ; = "OK Number of Scan Lines"
               ld2   200,ScanCounter    ; limit number of scanlines to 200
OKNSL          anop

loop4          anop
               ld2 160,LineSize         ; unpack 160 bytes max right now

               pha
               clc                      ; push pointer to packed data
               lda 4
               adc WBPointer
               tay
               lda 6
               adc #0
               pha
               phy
               ldy CTPointer            ; push packed data length
               lda [4],y
               pha
               ph4 #picDestIN           ; These get adjusted by UnPackBytes
               ph4 #LineSize

               _UnPackBytes             ; UnPack the rest of the file
               pla                      ; get rid of this

               ldy CTPointer            ; point to next set of packed bytes
               lda [4],y
               clc
               adc WBPointer
               sta WBPointer

               iny4                     ; point to next directory entry so that
               sty CTPointer

               dec ScanCounter          ; have we done all lines?
               bne loop4                ; no - keep going

               rts

LineSize       ds    4
Mode           ds    2
PixelsPerLine  ds    2
BytesPerLine   ds    2
PicDestIN      dc    i4'$E12000'

               end
