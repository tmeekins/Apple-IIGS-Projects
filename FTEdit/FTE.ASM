 title 'FTEdit v0.01 - Written by Tim Meekins - Copyright 1990 by Tim Meekins'

***************************************************************************
*
* FTEdit v0.01 - Written by Tim Meekins
* Copyright 1990 - All Rights Reserved except distribution
*
* FTEdit may be distributed FREELY, except FTEdit MAY NOT be distributed with
* any program or computer system without the prior written assent of the author
* FTEdit MAY NOT be distributed for profit.
*
* FTEdit is a program for editing filetype $42 files which contain filetype
* information for use with the Finder (tm) or other shells and applications.
*
***************************************************************************
*
* REVISION HISTORY:
*
* v0.01  4/03/90  Began work on FTEdit.
*
***************************************************************************

               mcopy fte.mac

***************************************************************************
*
* Input port structure
*
***************************************************************************

fill_char      gequ  0
def_cursor     gequ  1
cursor_mode    gequ  2
beep_flag      gequ  3
entry_type     gequ  4
exit_type      gequ  5
last_char      gequ  6
last_mod       gequ  7
last_term_ch   gequ  8
last_term_mod  gequ  9
cursor_pos     gequ  10
input_length   gequ  11
input_field    gequ  12
origin_h       gequ  13
origin_x1      gequ  14
origin_x2      gequ  15
origin_v       gequ  16
input_port_size gequ 17

***************************************************************************
*
* DControl control codes
*
***************************************************************************

DC_SetWait     gequ  $0004
DC_SetIP       gequ  $8000
DC_SetTL       gequ  $8001
DC_ResTP       gequ  $8002
DC_SetRead     gequ  $8003
DC_SetDS       gequ  $8004
DC_Abort       gequ  $8005

***************************************************************************
*
* DStatus subcommands
*
***************************************************************************

DS_RetWait     gequ  $0002
DS_RetTP       gequ  $8000
DS_RetIP       gequ  $8001
DS_RetTL       gequ  $8002
DS_RetTPD      gequ  $8003
DS_RetSC       gequ  $8004
DS_RetRead     gequ  $8005
DS_RetDS       gequ  $8006

***************************************************************************
*
* main
*
***************************************************************************

main           START

               using Global

               phk
               plb
;
; Start up the Memory Manager
;
               MMStartUp UserID
;
; Get device number for the console
;
               GetDevNumber GDN_Parms
;
; Propogate the console device number
;
               lda   GDN_devNum
               sta   IP_devNum
               sta   IP_devNum1
               sta   DC_devNum1
               sta   DC_devNum2
               sta   TP_devNum
;
; Open the console
;
               Open  Open_Parms
;
; Propogate the console file number
;
               lda   Open_refNum
               sta   WR_refNum
               sta   Close_refNum
               sta   Read_refNum
               sta   OneByteRefNum
;
; Get a copy of the standard input port
;
               ld2   DS_RetIP,IP_cmd
               DStatus IP_Parms
;
; Get the input port
;
               ld2   DS_RetIP,IP_cmd1
               DStatus IP_Parms1
;
; Change the fill character
;
               short a
               ld2   $C9,Input_Rec1+fill_char
               long  a
;
; Set the new input port
;
               ld2   DC_SetIP,IP_cmd1
               DControl IP_Parms1
;
; Set up more defaults
;
               DControl DC_Parms1       ;Set terminator list
               DControl DC_Parms2       ;Set UIR mode
;
; Print enter file name message
;
GetInput       lda   #ScrInitMsg
               ldx   #ScrInitLen-ScrInitMsg
               jsr   WriteStr
;
; Get the filename
;
               Read  Read_Parms
;
; Get the terminator key and check for ESC
;
               ld2   DS_RetIP,IP_cmd1
               DStatus IP_Parms1

               lda   Input_Rec1+exit_type
               and   #$FF

               cmp   #2                 ;was is terminator #2 (ESC)?
               beq   Quit_FV
;
; OK. Set up the file name then process it
;
               lda   Input_Rec1+input_length
               and   #$FF
               sta   FileName

               jsr   ProcessFile

               bra   GetInput
;
; Quit
;
Quit_FV        Close Close_Parms
               MMShutDown UserID
               Quit  Quit_Parms
               brk   $00

***************************************************************************
*
* Write a string to the console driver
*  A: Points to string
*  X: Length of string
*
***************************************************************************

WriteStr       ENTRY

               sta   WR_addr
               stx   WR_len

               Write WR_parms

               rts

***************************************************************************
*
* GS/OS Parameters for accessing the console
*
***************************************************************************

Quit_Parms     dc    i'2',i4'0',i'0'

GDN_Parms      dc    i'2',i4'ConsName'
GDN_devNum     ds    2

Open_Parms     dc    i'2'
Open_refNum    ds    2
               dc    i4'ConsName'

IP_Parms       dc    i'5'
IP_devNum      ds    2
IP_cmd         ds    2
               dc    i4'Input_Rec,IPR_Size-Input_Rec'
               ds    4
Input_Rec      ds    input_port_size
IPR_Size       anop

IP_Parms1      dc    i'5'
IP_devNum1     ds    2
IP_cmd1        ds    2
               dc    i4'Input_Rec1,IPR_Size1-Input_Rec1'
               ds    4
Input_Rec1     ds    input_port_size
IPR_Size1      anop

DC_Parms1      dc    i'5'
DC_devNum1     ds    2
               dc    i'DC_SetTL',i4'TermList,Size1-TermList'
               ds    4
TermList       dc    i'$A0FF'
               dc    i'2'
               dc    i'$000D'
               dc    i'$001B'
Size1          anop

DC_Parms2      dc    i'5'
DC_devNum2     ds    2
               dc    i'DC_SetRead',i4'RM_List,2'
               ds    4
RM_List        dc    i'0'

WR_Parms       dc    i'4'
WR_refNum      ds    2
WR_addr        dc    i4'WR_addr'
WR_len         dc    i4'0'
               ds    4

Close_Parms    dc    i'2'
Close_refNum   ds    2

Read_Parms     dc    i'4'
Read_refNum    ds    2
               dc    i4'FileNameBuf,30'
               ds    4

TP_Parms       dc    i'5'
TP_devNum      ds    2
TP_cmd         ds    2
               dc    i4'TextPort,TP_Len-TextPort'
TextPort       ds    80*24+2
TP_Len         anop

OneByte        dc    i'4'
OneByteRefNum  ds    2
               dc    i4'TheChar'
               dc    i4'1'
               ds    4
TheChar        ds    1

ConsName       GSStr '.CONSOLE'

ScrInitMsg     dc    i1'$C,$1E,$20,$2C',c'Enter file name: '
ScrInitLen     anop

***************************************************************************
*
* Wait for a keypress
*
***************************************************************************

WaitKey        ENTRY
;
; Save our old input port
;
               ld2   DS_RetIP,IP_cmd1
               DStatus IP_Parms1
;
; Set up a new input port
;
               ld2   DC_SetIP,IP_cmd
               DControl IP_Parms
;
; Read a keypress
;
               Read  OneByte
;
; Restore old input port
;
               ld2   DC_SetIp,IP_Cmd1
               DControl IP_Parms1

               rts

***************************************************************************
*
* Error handler
*
***************************************************************************

Error          ENTRY

               pha
;
; Save text port
;
               ld2   DS_RetTPD,TP_cmd
               DStatus TP_Parms
;
; Print error box
;
               lda   #ErrStr1Msg
               ldx   #ErrStr1Len-ErrStr1Msg
               jsr   WriteStr
;
; Print error message
;
               pla
               dec   a
               asl   a
               tax
               ldy   MessageTbl,x
               ldx   |0,y
               iny2
               tya
               jsr   WriteStr

               jsr   WaitKey

;
; Pop the text port
;
               lda   #ErrStr2Msg
               ldx   #ErrStr2Len-ErrStr2Msg
               jsr   WriteStr
;
; Restore the text port
;
               ld2   DC_ResTP,TP_cmd
               DControl TP_Parms

               rts

MessageTbl     dc    i'BadType'
               dc    i'BadChar'
               dc    i'NotFound'
               dc    i'OpenErr'
               dc    i'MemErr'
               dc    i'ReadErr'
               dc    i'VersErr'

BadType        GSStr 'ERR#01: File must be of type $42.'
BadChar        GSStr 'ERR#02: Invalid characters in the pathname.'
NotFound       GSStr 'ERR#03: File not found.'
OpenErr        GSStr 'ERR#04: There was an trying to open the file.'
MemErr         GSStr 'ERR#05: Could not allocate memory.'
ReadErr        GSStr 'ERR#06: Could not read file.'
VersErr        GSStr 'ERR#07: Filetype version must be 1.0'

ErrStr1Msg     dc    i1'$1,$1E,$25,$29,$F,$10,$20+70'
               dc    i1'$1E,$25,$2A,$20,$E,$10,$20+68,$F,$20'
               dc    i1'$1E,$25,$2B,$20,$E,$10,$20+68,$F,$20'
               dc    i1'$1E,$25,$2C,$20,$E,$10,$20+68,$F,$20'
               dc    i1'$1E,$25,$2D,$10,$20+70'
               dc    i1'$1E,$29,$2B,$E'
ErrStr1Len     anop

ErrStr2Msg     dc    i1'$4'
ErrStr2Len     anop

               END

***************************************************************************
*
* Global data structures
*
***************************************************************************

Global         DATA
;
; Memory Manager User ID
;
UserID         ds    2
;
; The file name
;
FileName       ds    2
FileNameBuf    ds    30

               END

***************************************************************************
*
* Process the file
*
***************************************************************************

ProcessFile    START

               using Global

memHandle      equ   0
memPtr         equ   memHandle+4
idxPtr         equ   memPtr+4
loop           equ   idxPtr+4
size           equ   loop+2
;
; Open the file
;
               Open  Open_parms
;
; did any errors occur?
;
               bcc   ChkFType

               cmp   #$40
               bne   err1
               lda   #2
               jmp   Error
err1           cmp   #$42
               bcc   err2
               cmp   #$47
               bcs   err2
               lda   #3
               jmp   Error
err2           lda   #4
               jmp   Error
;
; Is the file type $42?
;
ChkFType       cm2   Open_Filetype,#$42
               beq   GetFileMem

               lda   #1
;
; an error occur trying to read the file
;
FileError      pha
               lda   Open_refNum
               sta   Close_refNum
               Close Close_parms
               pla
               jmp   Error
;
; Get memory to read file
;
GetFileMem     NewHandle (Open_eof,UserID,#$8000,#0),memHandle
               bcc   DerefMem
               lda   #5
               bra   FileError

DerefMem       lda   [memHandle]
               sta   memPtr
               sta   Read_addr
               ldy   #2
               lda   [memHandle],y
               sta   memPtr+2
               sta   Read_addr+2
;
; Read the file
;
               lda   Open_refNum
               sta   Close_refNum
               sta   Read_refNum

               mv4   Open_eof,Read_request

               Read  Read_parms
               bcc   closefile

               lda   #6
               jmp   FileError

closefile      Close Close_parms

               lda   [memPtr]
               cmp   #$0100
               beq   DoHeader
               lda   #7
               jmp   FileError

DoHeader       ldy   #2
               lda   [memPtr],y
               Int2Hex (@a,#HeaderFlag,#4)
               ldy   #4
               lda   [memPtr],y
               sta   loop
               Int2Hex (@a,#HeaderEntries,#4)
               ldy   #8
               lda   [memPtr],y
               sta   size
               Int2Hex (@a,#HeaderSize,#4)
               lda   #HeaderStr
               ldx   #HeaderEnd-HeaderStr
               jsr   writeStr

               ldy   #10
               clc
               lda   [memPtr],y
               adc   memPtr
               sta   idxPtr
               lda   memPtr+2
               adc   #0
               sta   idxPtr+2

printloop      lda   [idxPtr]
               Int2Hex (@a,#Str1,#2)
               ldy   #2
               lda   [idxPtr],y
               Int2Hex (@a,#Str1Aux+4,#4)
               ldy   #4
               lda   [idxPtr],y
               Int2Hex (@a,#Str1Aux,#4)
               ldy   #6
               lda   [idxPtr],y
               Int2Hex (@a,#Str1Flag,#4)
               lda   #Str1
               ldx   #Str1End-Str1
               jsr   writestr

               ldy   #8
               lda   [idxPtr],y
               tay
               lda   [memPtr],y
               and   #$FF
               tax
               iny
               tya
               jsr   writestr

               lda   #NextLine
               ldx   #1
               jsr   writestr

               clc
               lda   idxPtr
               adc   size
               sta   idxPtr
               lda   idxPtr+2
               adc   #0
               sta   idxPtr+2

               dec   loop
               beq   done
               jmp   printloop

done           jsr   WaitKey

               rts

HeaderStr      dc    i1'$1E,$20,$30'
               dc    c'Vers 1.0  Flags: '
HeaderFlag     dc    c'0000  # Entries: '
HeaderEntries  dc    c'0000  Size: '
HeaderSize     dc    c'0000'
               dc    i1'$D'
               dc    c'--------------------------------------------------'
NextLine       dc    i1'$D'
HeaderEnd      anop

Str1           dc    c'00 '
Str1Aux        dc    c'00000000 '
Str1Flag       dc    c'0000  '
Str1End        anop


***************************************************************************
*
* GS/OS parms
*
***************************************************************************

Open_parms     dc    i'12'
Open_refNum    ds    2
               dc    i4'FileName'
               dc    i'0'
               dc    i'0'
               dc    i'1'
Open_filetype  ds    2
               ds    4
               ds    2
               ds    8
               ds    8
               ds    4
Open_eof       ds    4

Read_parms     dc    i'5'
Read_refNum    ds    2
Read_addr      ds    4
Read_request   ds    4
               ds    4
               dc    i'1'

Close_Parms    dc    i'1'
Close_refNum   ds    2

               END
