****************************************************************************
*
* MaXUS
*
* Reads CHAR.SHR and creates an ORCA/M assembly language file
*
****************************************************************************

               mcopy mkchar.mac

mkchar         start

               proc

               Open  OpenParm
               mv2   OpenRef,ReadRef
               sta   CloseRef
               Read  ReadParm
               Close CloseParm

               WriteLine #str1

               stz   count
loop           WriteString #labstr
               lda   #1
               sta   numbyteout
               lda   count
               jsr   WriteByte
               jsr   WriteLine
               lda   #3
               sta   numbyteout


               lda   count
               asl   a
               tay
               lda   xtbl,y
               sta   offset
               lda   lentbl,y
               sta   width
               lda   ytbl,y
               clc
               adc   offset
               sta   offset
               lda   #15
               sta   height

hloop          ldx   offset
               ldy   width
iloop          lda   data,x
               jsr   WriteByte
               inx
               dey
               bne   iloop
               clc
               lda   offset
               adc   #160
               sta   offset
               dec   height
               bne   hloop

               WriteLine #EndStr
               inc   count
               lda   count
               cmp   #62
               bcs   loopend
               jmp   loop

loopend        WriteLine #str2
               jsr   WriteLine

               ldy   #0
lenloop        tya
               asl   a
               tax
               lda   lentbl,x
               jsr   WriteByte
               iny
               cpy   #62
               bne   lenloop
               WriteLine #EndStr

               WriteLine #str3
               jsr   WriteLine

               ldy   #0
xlloop         lda   xlate,y
               jsr   WriteByte
               iny
               cpy   #128
               bne   xlloop
               WriteLine #EndStr

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

               WriteLine #str4

               ldy   #0
loop00         phy
               WriteString #line0
               stz   NumByteOut
               ply
               phy
               tya
               jsr   WriteByte
               WriteLine #EndStr
               ply
               iny
               cpy   #62
               bne   loop00

               WriteLine #str5


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

count          ds    2
numbyteout     ds    2
offset         ds    2
width          ds    2
height         ds    2

str1           str   'chardata data charseg'
str2           str   'charlen anop'
str3           str   'charxlate anop'
str4           str   'chartbl anop'
str5           str   ' end'
palstr         str   'charpal anop'
linestr        str   ' dc h'''
line0          str   ' dc i4''char'
endstr         str   ''''
hexstr         str   '00'
labstr         str   'char'

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

FileName       GSStr 'CHAR.SHR'

xtbl           dc    i'0,3,6,11,15,21,28,30,34,38,42,47,49,54,57,60,65,68'
               dc    i'73,77,82,86,91,95,100,105,107,110,113,117,121'
               dc    i'0,5,11,16,20,25,29,34,38,44,46,50,57,61,67,73,78,83'
               dc    i'89,96,101,106,112,118,126,134,139,147,150,154,157'

lentbl         dc    i'2,3,5,4,6,6,1,3,3,3,4,2,4,2,3,5,3,5,4,5,4,5,4,5,4'
               dc    i'2,2,3,4,3,3,5,6,5,4,5,4,6,4,6,2,4,7,4,6,6,5,5,6,7'
               dc    i'5,5,6,6,8,8,5,8,2,3,2,3'

ytbl           dc    31i'4*160',31i'23*160'

xlate          dc    32i1'31'
               dc    i1'62,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19'
               dc    i1'20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37'
               dc    i1'38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55'
               dc    i1'56,57,58,59,60,61,12,6,32,33,34,35,36,37,38,39,40,41'
               dc    i1'42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59'
               dc    i1'60,61,31'

Data           ds    $8000

               end
