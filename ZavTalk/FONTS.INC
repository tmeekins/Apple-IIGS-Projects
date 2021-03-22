**********************************************************************
*
* Load all fonts
*
**********************************************************************

LoadFonts      start

               Using FontGlobal
               longa on
               longi on

               phb
               phk
               plb

               ldx   #<NormalFontStr
               ldy   #^NormalFontStr
               jsr   LoadOneFont
               stx   NormalFontPtr
               sty   NormalFontPtr+2

               plb

               rtl

               end

**********************************************************************
*
* Load one font
*
**********************************************************************

LoadOneFont    start

               using FontGlobal
               using Global

               stx   OpenName
               sty   OpenName+2

               Open  OpenParm

*
* At some point in time we should add error checking here to see that
* we were able to load the font in correctly.
*

               lda   OpenRef
               sta   ReadRef
               sta   CloseRef

               Newhandle (OpenEOF,UserID,#$18,#0),$0

               lda   OpenEOF
               sta   ReadReq
               lda   OpenEOF+2
               sta   ReadReq+2

               lda   [$0]
               sta   ReadData
               ldy   #2
               lda   [$0],y
               sta   ReadData+2

               Read  ReadParm

*
* At some point in time we should check the requested bytes read
* and actual bytes read. If they aren't equal then "Unexpected end
* of input in ****.FONT"
*

               Close CloseParm

               lda   [$0]
               tax
               ldy   #2
               lda   [$0],y
               tay

               rts

*
* GS/OS call parameters
*

OpenParm       dc    i2'15'
OpenRef        ds    2
OpenName       dc    i4'DefaultFontStr'
               dc    i2'1'
               dc    i2'0'
               ds    2
               ds    2
               ds    4
               ds    2
               ds    8
               ds    8
               ds    4
OpenEOF        ds    4
               ds    4
               ds    4
               ds    4

ReadParm       dc    i2'5'
ReadRef        ds    2
ReadData       ds    4
ReadReq        ds    4
ReadLen        ds    4
               dc    i2'1'

CloseParm      dc    i2'1'
CloseRef       ds    2

               end

**********************************************************************
*
* Font global information
*
**********************************************************************

FontGlobal     data

NormalFontStr  GSStr 'NORMAL.FONT'
MouseFontStr   GSStr 'MOUSETEXT.FONT'
IBMFontStr     GSStr 'IBM.FONT'
DefaultFontStr GSStr 'DEFAULT.FONT'

NormalFontPtr  ds    4
MouseFontPtr   ds    4
IBMFontPtr     ds    4

               end
