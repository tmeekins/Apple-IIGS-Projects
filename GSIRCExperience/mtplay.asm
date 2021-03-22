	mcopy	mtplay.mac
*
* Here's the MT player as seen in GS<>IRC #1.  Usage notes:
*
* start the sound tools and jsr InitSeq; this sets things up
* (note that MyDP must be set to the value of the program's directpage or
*  Bad Things will happen)
* jsr LoadSong with the info setup for the wavebanks and such.
* jsr Play plays the song; jsr Stop stops it
* The VU meters and Parik's BGSound ASIF loader are also included.
*
* To do your own VUs, just check the TrackInst table, it contains 14 entries,
* each of which will contain the current volume level for that track, or a
* zero if no note is being played.  The volume is scaled down to assume
* 16 pixel high VUs, if you want larger values go fish for the LSRs. :)
* see the DoVUMeters routine for a real working example. :)
*
* Equates used:
*
*
nb_track	gequ	14	[TIM]

attrNoSpec     gequ $0008               memory attributes
attrNoCross    gequ $0010
attrFixed      gequ $4000
attrLocked     gequ $8000
TRUE           gequ $0001               boolean values
FALSE          gequ $0000
SystemVolume   gequ  $E100CA            system volume in lo nibble
NewVideo       gequ  $E1C029            video mode select
SoundCtl       gequ  $E1C03C            sound control register
SoundData      gequ  $E1C03D            sound data register
SoundAdrL      gequ  $E1C03E            sound address ptr (lo)
SoundAdrH      gequ  $E1C03F            sound address ptr (hi)
Strobe         gequ  $E1C000            keyboard strobe
ClearStrobe    gequ  $E1C010            keyboard strobe reset
gs_speed       gequ  $E1C036            GS speed register
ShieldCursor   gequ  $E01E98
UnshieldCursor gequ  $E01E9C


Taille_Inst    gequ  12                 # of bytes of each instdef that we use
OscFreqLoReg   gequ  $00                DOC registers
OscFreqHiReg   gequ  $20
OscVolumeReg   gequ  $40
OscWavePtrReg  gequ  $80
OscControlReg  gequ  $A0
OscWaveSizeReg gequ  $C0
OscIntReg      gequ  $E0
OscEnableReg   gequ  $E1
DOCNoAutoInc   gequ  %10011111          SCTL: access DOC registers, no auto inc
EnableAutoInc  gequ  %00100000          SCTL: Enable auto increment
DOCAccess      gequ  %10111111          SCTL: access DOC registers
NoOscInt       gequ  %11110111          OCTL: disable interrupts of an osc
EnableInt      gequ  %00001000          OCTL: turn on interrupts of an osc
HaltOsc        gequ  %00000001          OCTL: halt an oscillator
STP            gequ  128                STP command code
NXT            gequ  129                NXT command code
oLength        gequ  6                  offset to length word
oTempo         gequ  8                  offset to tempo word
oMusLength     gequ  470                offset to musLength word
oMusList       gequ  472                offset to 128 byte musList
oMainBlock     gequ  600                offset to Main block of music in file
MusListLength  gequ  128                size of muslist, in bytes

MyMID          gequ $10
MyID           gequ MyMID+2
Temp1          gequ MyID+2
Digits         gequ Temp1+2
WaveTemp       gequ Digits+4
WaveTemp2      gequ WaveTemp+4

TempM          gequ WaveTemp2+4
SongPtr        gequ TempM+4
InstPtr        gequ SongPtr+4
MusListPtr     gequ InstPtr+4
MainBlockPtr   gequ MusListPtr+4
InstHandle     gequ MainBlockPtr+4
TempDP         gequ InstHandle+4
SongHandle     gequ TempDP+4
FX1Ptr         gequ SongHandle+4
FX2Ptr         gequ FX1Ptr+4
SongPath       gequ FX2Ptr+4
InstPath       gequ SongPath+4
DPTemp         gequ InstPath+4
Temp0          gequ DPTemp+4
MySID          gequ Temp0+4

InitSeq        Start
               using MainDATA
               using SoundDAT
               using Globals
               jsr HaltOscs             ; stop em
               SetSoundMIRQV #SoundIRQRtn
               rts
               END

LoadASong      START
               using MainDATA
               using SoundDAT
               using Globals
               using ParikData

	mv4	SongPath,OpenPath

               ldy #0
CNL            lda [SongPath],y
               sta RealName,y
               iny2
               cpy #$0100
               bcc CNL

               Open 	openParms        ; Open the file
               bcc NoOE
               sec
               rts

NoOE           mv2   ORefNum,(RRefNum,CRefNum)	; Transfer out refNum

               jsr HaltOscs             ; reset Ensoniq

               NewHandle (oEOF,MySID,#$C000,#0),Temp1
	Deref Temp1,OpenDestIN

	mv4	oEOF,RLength
               Read 	readParms        	; Read the song
               bcc goodRead
               rts
goodRead       Close closeParms      	; And then close it
	jsr	nextbar

	NewHandle (#47000,MySID,#$C008,#0),DPTemp
	Deref DPTemp,SongPtr
	jsr	compacton
	ph4	OpenDestIN
	ph4	SongPtr
	lda	MySID
	clc
	adc	#$400
               pha
	jsl	LZSSExpandPtoP
	jsr	compactoff
	DisposeHandle Temp1
	jsr	nextbar
       
               ldy #$0006               ; get length of blocks
               lda [SongPtr],y
               sta RLength
               stz RLength+2
               add4 SongPtr,#$258,MainBlockPtr  ; compute addresses of stuff
               add4 MainBlockPtr,RLength,FX1Ptr
               add4 FX1Ptr,RLength,FX2Ptr
               add4 FX2Ptr,RLength,Temp1

               ldy #0
CSDL           lda [Temp1],y            ; get the stereoData
               sta StereoTable,y
               iny2
               cpy #$1e
               bcc CSDL

               stz   Timer              ; Initialize variables.
               stz   NotePlayed
               stz   BlockIndex
               stz   CurBlock

               ldy #oTempo
               lda [SongPtr],y
               sta Tempo

               ldx   #0                 Copy volume of each instrument to a
               ldy   #44                 special array.
loop7          lda   [SongPtr],y
               sta   VolumeTable,x
	add2	@y,#30,@y
               inx2
               cpx   #30
               blt   loop7

               lda   SongPtr+2
               sta   musListPtr+2
               lda   SongPtr            ; Create pointer to MusList.  We do this
               clc                      ; by adding the address of the start of
               adc   #oMusList          ; the song file to the offset of the
               sta   musListPtr         ; muslist.  This involves 32bit addition
               bcc   no_car             ; and is why the BCC/INC are needed.
               inc   musListPtr+2
no_car         anop

               ldx RealName             ; make name into name.W
               lda #'W.'
               sta RealName+2,x
               inc2 RealName             ; increase length

	ld4	RealName,OpenPath

               Open 	openParms        	; try to open the file
	jcc	good

               ldx RealName
               dex2
               lda #'D.'                ; okay, try name.D instead
               sta RealName+2,x

               Open 	openParms
	jcc	good

               ldx RealName             ; make name into name.DOC
               lda #'CO'
               sta RealName+2,x
               inc2 RealName             ; increase length

               Open 	openParms
               jcc	good

	ld4	DOCDatPath,OpenPath ; try for DOC.DATA

               Open 	openparms
	jcc	good

               jsr LoadASIFs            ; try ASIFs instead
               bcs badinst

               ldx #$20                 ; now kludge the data from Parik's table
               ldy #0                   ; to ours
               stz Temp0                ; bytes copied
               stz Temp0+2              ; insts copied
CpyDataLp      lda SSInt_Table9,x
               sta instdef,y
               inx2
               iny2
               inc2 Temp0
               lda Temp0
               cmp #12
               bne CpyDataLp
               stz Temp0
               add2	@x,#$5C-12,@x
               inc Temp0+2
               lda Temp0+2
               cmp #16
               bne CpyDataLp

               brl FinishUp

badinst        sec
               rts
good           anop
               mv2   ORefNum,(RRefNum,CRefNum) ; Transfer out refNum
               mv4   Oeof,RLength              ; transfer the Oeof
               NewHandle (Oeof,MySID,#attrLocked+attrFixed+attrNoSpec,#0),InstHandle
               ldy   #$0002

               lda   [InstHandle]       ; dereference the handle
               sta   InstPtr
               sta   OpenDestIN
               ldy   #2
               lda   [InstHandle],y
               sta   OpenDestIN+2
               sta   InstPtr+2

               Read 	readParms        	; read the file
               Close closeParms      	; close it

	jsr	nextbar

	long	ai
               add4 InstPtr,#2,TempDP
               short	a                 	; copy into DOC RAM
               php
               sei
               lda #$60
               sta >SoundCtl
               lda #0
               sta >SoundAdrL
               sta >SoundAdrH
               ldy #0
CopyToDOCRAM   lda [TempDP],y
               sta >SoundData
               iny
               bne CopyToDOCRAM
               plp
	long	a

; Copy the instrument parametres...

               lda   InstPtr+2          ; Create a pointer to the start of the
               inc   a                  ; instrument pointers stored in the
               sta   tempM+2            ; instrument file.  We do this by adding
               lda   InstPtr            ; $010022 to the address of the start of
               clc                      ; the instrument file.  This involves
               adc   #$22               ; 32-bit addition; and that's why the
               sta   tempM              ; BCC/INC lines are there. :)
               bcc   no_carry
               inc   tempM+2
no_carry       anop


               ldy   #0
               tyx
               lda   [InstPtr]          ; numInsts
               and   #$00FF
               sta   InstIndex
loopagaV1      pha                      ; save numInsts
               lda   #Taille_Inst/2     ;make taille_inst WORDS instead of bytes
loop5          pha
               lda   [tempM],y        ; Wave+$010022
               sta   instdef,x
               inx2
               iny2
               pla
               dec   a
               bne   loop5

	add2	@y,#92-Taille_Inst,@y

               pla
               dec   a
               bne   loopagaV1

               lda   InstPtr+2          ; Create a pointer to the start of the
               inc   a                  ; "CompactTable" stored in the
               sta   tempM+2          ; instrument file.  We do this by adding
               lda   InstPtr            ; $01005E to the address of the start of
               clc                      ; the instrument file.  We use 32bit
               adc   #$5E               ; addition routines...
               sta   tempM
               bcc   no_carry0
               inc   tempM+2
no_carry0      anop

               ldy   #0                 ; It appears a "Compaction table" is
loop6          lda   [tempM],y          ; stored at Wave+$01005E.
               sta   CompactTable,x
               inx2
               iny2
               cpx   #32
               blt   loop6


               pei instHandle+2         ; dispose of instrument memory, as the
               pei instHandle           ; instruments have been dumped to the
               _DisposeHandle           ; DOC RAM and we don't need them anymore


finishUp       anop
               lda #1
               clc
               rts
DErr           anop
               sec
               rts
               END

SoundIRQrtn    Start
               Using SoundDAT
               using MainDATA
               using Globals
               longa off
               longi off

               php                      save size of m,x registers
               phd                      save direct page register
               phb                      save data bank register
               phk                      data bank == code bank
               plb

               long	a
               lda   >MyDP             Use our program's direct page.
               tcd
               short	a

waitFree       lda   >SoundCtl          Wait for DOC to be free.
               bmi   waitFree
               and   #DOCNoAutoInc      Disable auto-inc., access DOC regs.
               sta   >SoundCtl

               lda   #OscIntReg
               sta   >SoundAdrL         Check the interrupt register to see if
               lda   >SoundData          osc. a of pair 0-1 generated the
               lda   >SoundData          interrupt.
               and   #%01111111
               sta   >SoundData

               and   #%00111110         If osc. a of pair 30-31 generated the
               lsr   a                   interrupt, then update the song. If it
               cmp   #$1e
               beq   TimerInterrupt      wasn't then tell the osc that made the
;                                        interrupt not to interrupt us any more.
               clc                       Right here we're checking to see if the
               adc   #OscControlReg      control register of the oscillator that
               sta   >SoundAdrL          generated the interrupt has its int
               lda   >SoundData          enable bit set.  If it is set, then
               lda   >SoundData          clear it (make it stop interrupting).
               bit   #EnableInt          If it's already clear, than leave it.
               beq   No_Op               We do this because at first, all oscs
               and   #%11111110          are set to generate interrupts.  This
               sta   >SoundData          changes that so that only osc 0
;                                        ends up generating interrupts for us.
No_Op          anop
               clc                      Indicate we serviced the interrupt.
               plb                      Restore data bank register.
               pld                      Rrestore direct page register.
               plp                      Rrestore native 8bit mode.
               rtl                      And return to the interrupt manager.

Get_Effects1   Entry
               phy
               txy
               lda   [FX1Ptr],y
               ply
               rts

Get_Effects2   Entry
               phy
               txy
               lda   [FX2Ptr],y
               ply
               rts

TimerInterrupt lda   Pause              The interruptions 50Hz generate the
               and   #$00FF             performance
               jeq   EndInterrupt

WeCanPlay      stz   Temporary          Zero the current track number being
;                                        currently updated
               inc   Timer
               lda   Timer
               cmp   Tempo              Timer=Tempo
               jne   HandleEffects      the effects are updated every 1/50th
;                                        of a second
PlayTracks     stz  Timer               reset timer
NewTrack       anop
	long	i
               short	a
               ldy   NoteIndex
               lda   [MainBlockPtr],y   get a note to play
               tyx
	long	a

               and   #$00FF
               cmp   #$0000
               beq   NotValid           If the note is 0, check for F/X.
               cmp   #128               If the note is > 128, then it's a
               bge   Command            command, so process accordingly.
               brl   NoteFound

NotValid       anop
               pha
               phx
               lda Temporary
               asl a
               tax
               lda #0                   ; 0 out track if no note
               sta TrackInst,x
               plx
               pla
               inc   NoteIndex

               jsr Get_Effects1
               and #$00ff
               cmp #$0003
               beq SetVol
               brl NotSTP
SetVol         jsr Get_Effects2
               and #$00ff
               lsr a
               tay
               lda Temporary            ; store for VU meters
               asl a
               tax
               tya
               lsr a
               lsr a
               lsr a
               lsr a
               sta TrackInst,x

               short	a
               lda VolumeConversion,y   ; volume is still in Y!
               pha
               pha
               lda   >SoundCtl
               and   #%10011111
               sta   >SoundCtl

               lda   Temporary
               asl   a
               clc
               adc   #$40
               sta   >SoundAdrL
               pla
               sta   >SoundData         Set osc.
               lda   Temporary
               asl   a
               clc
               adc   #$41
               sta   >SoundAdrL
               pla
               sta   >SoundData         Set osc.b
               bra NotSTP

Command        inc   NoteIndex
               short	a
               ldy   NoteIndex
               dey                      compensate, we just inc-ed it!
               lda   [MainBlockPtr],y   get note again (this fixes it for some
               tyx                      reason)
               long	a
               and #$00ff
               cmp #$0081               ; is is a NXT?
               bne notNXT

               lda #$ffff               ; trip the NXT mechanism
               sta NXTFlag
               bra NotSTP

notNXT         cmp   #$0080             ; how 'bout a STP?
               bne   NotSTP

               lda   Temporary          ; okay, lets do it!
               asl   a
               tax
               lda   #0
               sta   TrueVolumeTbl,x

               lda   Temporary          ; stop the oscillators
               asl   a
               sta   OscNum

               short	a
               lda #$00                 ; don't auto-inc, doc registers
               sta >SoundCtl

               lda OscNum               ; this came right out of SS 0.95
               clc                      ; and simple tho it be, it works like
               adc #$a0                 ; a charm!
               sta >SoundAdrL
               lda #$01
               sta >SoundData
               lda OscNum
               clc
               adc #$a1
               sta >SoundAdrL
               lda #$01
               sta >SoundData

NotSTP         short	a

               inc   Temporary          Increment the track being updated.
               lda   Temporary
               cmp   #Nb_Track
               jne   NewTrack

NextTrack      anop
               long	a
               brl   EndPlay

NoteFound      sta   Semitone           Save the note.

               short	a
               jsr   Get_Effects1
               ldy   Temporary          Find the instrument to use
               and   #$F0
               bne   ThereIsASample
               lda   SampleTable,y
ThereIsASample sta   SampleTable,y
               bne InstOkay
               brl IgnoreSample    ; if no inst # for track, don't play!
InstOkay       lsr   a
               lsr   a
               lsr   a
               lsr   a
               dec   a
               asl   a
               tay
               lda   VolumeTable,y      ; get inst. volume
               lsr   a
               sta   VolumeInt

               long	a
               jsr   Get_Effects1
               and   #$000F
               bne   NotArpegiatto      If the effect is 0 it's an arpeggio!
               jsr   Get_Effects2
               short	a

               ldy   Temporary          Save the value of the effect in a table
               sta   ArpegiattoTbl,y
               lda   Semitone           And save then note value for later
               sta   ArpegeToneTbl,y

               long	a
               brl   NoTempoChange      End the arpeggio preparation.

NotArpegiatto  pha
               short	a
               ldy   Temporary          Make a note of no arpeggio effect
               lda   #0
               sta   ArpegiattoTbl,y
               long	a
               pla

               cmp   #$03               Effect $3= volume change
               bne   NoVolChange

               jsr   Get_Effects2
               and   #$00FF
               lsr   a
               sta   VolumeInt

ChangeVol      lda   Semitone
               jne   NoTempoChange

               lda   Temporary
               inc   a
               asl   a
               sta   OscNum

               short	a
SetAutoInc     lda   >SoundCtl
               bmi   SetAutoInc
               ora   #%00100000         Auto-increment
               and   #%10111111
               sta   >SoundCtl

               lda   OscNum
               clc
               adc   #OscVolumeReg
               sta   >SoundAdrL
               ldy   VolumeInt
               lda VolumeConversion,y
*              sta   <$FE
*              lda   FullVolume
*              bne   noLess             if TRUE, then don't decrease volume
*              lsr   <$FE
*              lda   HalfVolume
*              bne   noLess             if TRUE, don't decrease volume more
*              lsr   <$FE
* noLess         anop
*              lda   <$FE
               sta   >SoundData         Volume pair
               sta   >SoundData         Volume impair
               long	a

               bra   NoTempoChange

NoVolChange    cmp   #$06               Effect $6= decrease vol
               bne   NoVolChange2

               jsr   Get_Effects2
               and   #$00FF
               lsr   a
               sta   TempInterrupt
               lda   VolumeInt
               sec
               sbc   TempInterrupt
               bpl   VolOk
               lda   #0
VolOk          sta   VolumeInt
               brl   ChangeVol

NoVolChange2   cmp   #$05               Effect $5= raise vol
               bne   NoVolChange3

               jsr   Get_Effects2
               and   #$00FF
               lsr   a
               clc
               adc   VolumeInt
               bcs   VolOk2
               lda   #$ff
VolOk2         sta   VolumeInt
               brl   ChangeVol

NoVolChange3   cmp #$0F               Effect $F= tempo change!
               bne NoTempoChange
               lda FFFlag
               beq NTC
               jsr Get_Effects2
               and #$000f
               sta FFTempo
               lsr a
               sta Tempo
               bra NoTempoChange

NTC            jsr Get_Effects2
               and #$000F
               sta Tempo

NoTempoChange  lda Temporary
               asl a
               tax
               lda VolumeInt
               sta TrueVolumeTbl,x
               lda Semitone
               bne PlayIt

               inc NoteIndex
               brl NotSTP

PlayIt         lda   Temporary          The pair 30-31 of osc's is used to
*                                       generate the interruptions.  Track 0
               asl   a                  uses the osc pair 0-1.
               sta   OscNum

               short	a
               lda   >SoundCtl
               and   #%10011111
               sta   >SoundCtl

               lda   OscNum
               clc
               adc   #OscControlReg
               sta   >SoundAdrL
               lda   >SoundData
               lda   >SoundData
               and   #%11110111
               ora   #%00000001
               sta   >SoundData         Store the oscillator pair
               lda   OscNum
               clc
               adc   #$A1
               sta   >SoundAdrL
               lda   >SoundData
               lda   >SoundData
               and   #%11110111
               ora   #%00000001
               sta   >SoundData         Store the oscillator pair

               ldy   Temporary
               lda   SampleTable,y
               long	a

               and   #%0000000011110000
               lsr   a
               lsr   a
               lsr   a
               lsr   a
               dec   a
               cmp   InstIndex
               jcs   IgnoreSample
SampleExists   asl   a
               tax
               lda   InstIndexTable,x   Offset of start of wave definition
SearchingA     tax
               lda   instdef,x
               and   #$00FF
               cmp   Semitone           If Semitone < Topkey then use that
               bcs   FoundWaveListA     WaveList. Else, keep searching for
               txa                       a wavelist to use
               clc
               adc   #6
               bra   SearchingA

FoundWaveListA stx   IndexInterrupt
               inx
               lda   instdef,x
               sta   TempInterrupt
               inx
               inx
               lda   instdef,x
               and   #$00FF
               sta   Temp2Interrupt
               lda   StereoMode         If StereoMode is zero, then use the
               beq   StereoOk           Mode of the osc. for the stereo.
               lda   Temp2Interrupt     Else use the talle stereoTable to
               and   #$000F             determine if the note will play on the
               sta   Temp2Interrupt     left or the right.
               lda   Temporary
               asl   a
               tax
               lda   StereoTable,x
               beq   StereoOk
               lda   Temp2Interrupt
               ora   #%0000000000010000
               sta   Temp2Interrupt

StereoOk       lda   IndexInterrupt     And check the WaveList for $7F
SearchEndOfA   tax                      The first WaveList for osc.b begins
               lda   instdef,x          6 bytes after.
               and   #$00FF
               cmp   #$7F
               beq   FoundEndOfA
               txa
               clc
               adc   #6
               bra   SearchEndOfA

FoundEndOfA    txa
               clc
               adc   #6

SearchingB     tax                      Do the same for osc.b
               lda   instdef,x
               and   #$00FF
               cmp   Semitone
               bcs   FoundWaveListB
               txa
               clc
               adc   #6
               bra   SearchingB

FoundWaveListB inx
               lda   instdef,x
               sta   Temp3Interrupt
               inx2
               lda   instdef,x
               and   #$00FF
               sta   Temp4Interrupt
               lda   StereoMode
               beq   StereoOk2
               lda   Temp4Interrupt
               and   #$000F
               sta   Temp4Interrupt
               lda   Temporary
               asl   a
               tax
               lda   StereoTable,x
               beq   StereoOk2
               lda   Temp4Interrupt
               ora   #%0000000000010000
               sta   Temp4Interrupt

StereoOk2      lda   Semitone           And convert the semitone to a DOC
               asl   a                  frequency.
               tax
               lda   FreqTable,x
               jsr   Calc_Freq          Compensate for Compact effect.
               sta   TempFreqInt
               lda   #0

               short	a
bcleWait2      lda   >SoundCtl
               bmi   bcleWait2
               ora   #%00100000         Auto-increment
               and   #%10111111
               sta   >SoundCtl

               lda   OscNum
               sta   >SoundAdrL
               lda   TempFreqInt
               sta   >SoundData         Frequency low osc.a
               sta   >SoundData         Frequency low osc.b
               lda   OscNum
               clc
               adc   #OscFreqHiReg
               sta   >SoundAdrL
               lda   TempFreqInt+1
               sta   >SoundData         Frequency high osc.a
               sta   >SoundData         Frequency high osc.b
               lda   OscNum
               clc
               adc   #OscVolumeReg
               sta   >SoundAdrL
               ldy   VolumeInt
               lda   VolumeConversion,y
*              sta   <$FE
*              lda   FullVolume
*              bne   noLess2            if TRUE, then don't decrease volume
*              lsr   <$FE
*              lda   HalfVolume
*              bne   noLess2            if TRUE, don't decrease volume more
*              lsr   <$FE
*noLess2        anop
*              lda   <$FE
               sta   >SoundData         Volume osc.a
               sta   >SoundData         Volume osc.b
               lda   OscNum
               clc
               adc   #OscWavePtrReg
               sta   >SoundAdrL
               lda   TempInterrupt
               sta   >SoundData         Wave Adress osc.a
               lda   Temp3Interrupt
               sta   >SoundData         Wave Adress osc.b
               lda   OscNum
               clc
               adc   #OscWaveSizeReg
               sta   >SoundAdrL
               lda   TempInterrupt+1
               sta   >SoundData         Wave Size osc.a
               lda   Temp3Interrupt+1
               sta   >SoundData         Wave Size osc.b
               lda   OscNum
               clc
               adc   #OscControlReg
               sta   >SoundAdrL
               lda   Temp2Interrupt
               sta   >SoundData         Control register osc.a
               lda   Temp4Interrupt
               sta   >SoundData         Control register osc.b

IgnoreSample   long	ai
               lda Temporary
               asl a
               tax
               lda VolumeInt
               lsr a
               lsr a
               lsr a
               sta TrackInst,x

               inc NoteIndex          Increment the track; check if we're
               inc Temporary           done.
               lda Temporary
               cmp #Nb_Track
               beq EndPlay
               short	a
               brl   NewTrack

               longa on
EndPlay        entry
               lda PlayDirection        ; forward or backwards?
               beq Normal

               lda NotePlayed
               bne OkR0

               lda #63                  ; next block
               sta NotePlayed
               lda BlockIndex
               bne OkR1
               lda NumberOfBlocks
               dec a
               sta BlockIndex
               tay
               bra OkR2
OkR1           anop
               dec BlockIndex
               ldy BlockIndex
OkR2           anop
               lda [MusListPtr],y       ; get next block # to play
               and #$00FF
               sta CurBlock
               inc a                    ; get beginning of next block-14...
               asl a
               tax
               lda BlockTable,x
               sec
               sbc #14
               sta NoteIndex            ; all set!
               jmp EndInterrupt

OkR0           anop
               dec NotePlayed           ; SS Reverse v1.0b3 (c) 1991 Two Meg
               lda NoteIndex
               sec
               sbc #28                  ; back up over what we just played
               sta NoteIndex
               jmp EndInterrupt

Normal         lda NXTFlag              ; normal forwards play
               beq NoNXT
               stz NXTFlag
               bra DoNXT
NoNXT          inc   NotePlayed         If the position of playing is 64,
               lda   NotePlayed         move to the next block!
               cmp   #64
               beq   DoNXT
               brl   endinterrupt
DoNXT          stz   NotePlayed
               inc   BlockIndex         Check if we're at the end of the song
               ldy   BlockIndex
               tyx
               cpy   NumberOfBlocks
               beq   Finished
               lda   [MusListPtr],y     If not, get the next block to play.
               and   #$00FF
               sta   CurBlock
               asl   a
               tax
               lda   BlockTable,x
               sta   NoteIndex
               jmp   EndInterrupt       ; jmp is one cycle faster than bra!

Finished       Entry
               lda   Music_Loop
               beq   Stop_Music

               jsr   HaltOscs
               php
               sei
               short	a
               lda   >SoundCtl
               ora   #%00100000         Auto-increment, DOC registers
               and   #%10111111
               sta   >SoundCtl

               lda #$40
               sta >SoundAdrL
               lda #$00
               ldx #$0000               ; set zero volume on all oscs.
L1             sta >SoundData
               inx
               cpx #$1e
               bne L1

               lda #$a0                 ; see explanation under InitOscs...
               sta >SoundAdrL
               lda #$02
               ldx #$0000
L0             sta >SoundData
               inx
               cpx #$1e
               bne L0

               lda #$00               access DOC registers, no auto-increment
               sta >SoundCtl
               lda #$1e
               sta >SoundAdrL
               lda #$fa
               sta >SoundData
               lda #$3e
               sta >SoundAdrl
               lda #$00
               sta >SoundData
               lda #$e1
               sta >SoundAdrL
               lda #$3e
               sta >SoundData
               lda #$be
               sta >SoundAdrL           ; enable osc. #30, ints on
               lda #$08
               sta >SoundData
               plp                      restore interrupts and mx size
;               jsr   Play2
	jsr	play
               bra   EndInterrupt

Stop_Music     Entry
               jsr HaltOscs
               short	ai
               stz   Pause
               php
               long	ai
               lda #1
               sta SongEnd
               plp
               longa off
               longi off

EndInterrupt   Entry
	long	a
;               inc TTimer               insure good timing for tape wheels
               clc                      indicate we serviced the interrupt
               plb                      restore data bank register
               pld                      restore direct page register
               plp                      restore native 8bit mode
               rtl                      and return to the interrupt manager

HandleEffects  short	ai                  do the effects!
               stz   Temporary
bcleHandleArp  lda   Temporary
               asl   a
               tax
               lda   TrueVolumeTbl,x
               cmp   #3
               bcc   Set0
               sec
               sbc   #3
               bra   TrueVolOk
Set0           lda   #0
TrueVolOk      sta   TrueVolumeTbl,x

               ldy   Temporary
               lda   ArpegiattoTbl,y
               jeq   NoArpegiatto

ThereIsAnArp   lda   Timer
               cmp   #6
TryAgain       bcc   StartArp
               sec
               sbc   #6
               bra   TryAgain

StartArp       cmp   #1                 The arpeggio varies the frequency of
               beq   Stage1             the note.
               cmp   #4
               beq   Stage1             If timer=1 or 4 then use the first
               cmp   #2                 nibble to affect the value of the note
               beq   Stage2             to beplayed.
               cmp   #5                 If Timer=2 or 5 then use the second
               beq   Stage2             nibble to affect the value of the note
;                                       to be played.
Stage3         lda   ArpegiattoTbl,y    If Timer=3 or zero then use the first
               and   #$0F               and second nibble to change the value
               sta   TempInterrupt      of the note to be played.
               lda   ArpegiattoTbl,y
               lsr   a
               lsr   a
               lsr   a
               lsr   a
               clc
               adc   TempInterrupt
               sta   TempInterrupt
               lda   ArpegeToneTbl,y
               sec
               sbc   TempInterrupt
               sta   ArpegeToneTbl,y
               bra   ModifieFreq

Stage1         lda   ArpegiattoTbl,y
               lsr   a
               lsr   a
               lsr   a
               lsr   a
               clc
               adc   ArpegeToneTbl,y
               sta   ArpegeToneTbl,y
               bra   ModifieFreq

Stage2         lda   ArpegiattoTbl,y
               and   #$0F
               clc
               adc   ArpegeToneTbl,y
               sta   ArpegeToneTbl,y

ModifieFreq    long	a
               and   #$00FF             And calculate new frequency
               asl   a
               tax
               lda   FreqTable,x
               jsr   Calc_Freq
               sta   TempFreqInt
               short	a

               lda   Temporary
               asl   a
               sta   OscNum
bcleWait3      lda   >SoundCtl          and modify the frequency registers
               bmi   bcleWait3
               ora   #%00100000
               and   #%10111111
               sta   >SoundCtl

               lda   OscNum
               sta   >SoundAdrL
               lda   TempFreqInt
               sta   >SoundData         Frequency low osc.a
               sta   >SoundData         Frequency low osc.b
               lda   OscNum
               clc
               adc   #OscFreqHiReg
               sta   >SoundAdrL
               lda   TempFreqInt+1
               sta   >SoundData         Frequency high osc.a
               sta   >SoundData         Frequency high osc.b

NoArpegiatto   inc   Temporary
               lda   Temporary
               cmp   #Nb_Track
               jne   bcleHandleArp

Done           Entry

               clc                      indicate we serviced the interrupt
               plb                      restore data bank register
               pld                      restore direct page register
               plp                      restore native 8bit mode
               rtl                      and return to the interrupt manager

Calc_Freq      php                      ; adjust freq. for compacted insts.
               long	ai
               pha
               lda   Temporary
               and   #$00FF
               asl   a
               tay
               lda   CompactTable,y
               tay
               pla
               cpy   #0
               beq   End_Lsr
loop8          lsr   a
               dey
               bne   loop8
End_Lsr        plp
               rts
               End

HaltOscs       Start
               Using SoundDAT

               short	ai
               lda   >SystemVolume
               and   #$0F               access DOC registers, no auto increment
               sta   >SoundCtl

               ldx   #OscControlReg     halt all oscillators
loop           txa
               sta   >SoundAdrL
               lda   #HaltOsc
               sta   >SoundData
               inx
               cpx   #OscWaveSizeReg
               bne   loop

               lda   #OscEnableReg
               sta   >SoundAdrL
               lda   #31*2              enable 31 oscillators
               sta   >SoundData
               long	ai
               rts

               END
*-----------------------------------------------------------------------------*
InitOscs       Start
               Using SoundDAT
               using MainDATA
               php
               sei
               short	a
               stz   Pause              disable music

               lda   >SoundCtl
               ora   #%00100000         Auto-increment, DOC registers
               and   #%10111111
               sta   >SoundCtl

               lda #$40
               sta >SoundAdrL
               lda #$00
               ldx #$0000               ; set zero volume on all oscs.
L1             sta >SoundData
               inx
               cpx #$1e
               bne L1

               lda #$a0
               sta >SoundAdrL
               lda #$02
               ldx #$0000               ; set oneshot, no ints on all oscs.
L0             sta >SoundData
               inx
               cpx #$1e
               bne L0

               lda #$00                 ; this init code is from SS 0.95...
               sta >SoundCtl            ; you were not enabling enough oscs
               lda #$1e                 ; which threw off the osc. frequencies
               sta >SoundAdrL           ; (i.e. the tuning and the timer)
               lda #$fa                 ; enough to make some songs sound very
               sta >SoundData           ; strange.  Fixing this meant that the
               lda #$3e                 ; osc assignments needed to be shifted
               sta >SoundAdrl           ; so that #30 is the timer and 0-29
               lda #$00                 ; run the tracks.
               sta >SoundData
               lda #$e1
               sta >SoundAdrL
               lda #$3e                 ; enable 31 of 32 oscillators
               sta >SoundData
               lda #$be
               sta >SoundAdrL           ; enable osc. #30, ints on
               lda #$08
               sta >SoundData

               plp                      restore interrupts and mx size
               longa on
               longi on
               rts
               END

Play           Start
               Using SoundDAT
               Using MainDATA
               using Globals

	long	ai

               stz SongEnd
               stz   Timer              Initialize variables.
               stz   NotePlayed
               stz   BlockIndex
               stz   CurBlock

               ldy   #omusList          Get offset of the file in bytes to the
               lda   [SongPtr],y           first note of music and store that
               and   #$00FF              offset at NoteIndex.
               pha
               asl   a
               tax
               lda   BlockTable,x
               sta   NoteIndex
               pla
               sta CurBlock             ; keep Graphic Player updated!

               ldy #oTempo
               lda [SongPtr],y
               sta Tempo

               ldy   #oMusLength        Get number of SSBlocks in file.
               lda   [SongPtr],y
               and   #$00FF
               sta   NumberOfBlocks
               beq   SkipPlay           If no SSBlocks then there is no music!

               jsr InitOscs             Start 50Hz interrupts

               short	a
               ldy #0
               lda #0
ILoop          sta SampleTable,y        zero out all tracks instrument numbers
               iny                      to follow SS 0.95 protocol.
               cpy #NB_Track
               bne ILoop

               long	a
               lda #$ffff             Enable the music.
               sta Pause
               sta Playing
SkipPlay       anop
               rts
               End

Stop           Start
               using MainDATA
               using SoundDAT
               using Globals
               jsr HaltOscs
               stz Playing
               rts
               End

LoadASIFs      START
               using ParikDATA
               using MainDATA
               using SoundDAT
               using Globals
WavePtr1       equ 0
WavePtr2       equ 4
TempDP2        equ 8
FileHandle     equ 12
filenotfound   equ $45

               stz   AllInstsFound
;               LongResult     ; Its much faster and simpler to alloc. file mem.
;               ph4 #$FFFF     ; here at the beginning, since no ASIF file will
;               pei MySID      ; ever be >64k (even with more DOCRAM!)
;               ph2 #attrLocked+attrFixed+attrNoSpec
;               ph4 #0
               NewHandle (#$FFFF,MySID,#attrLocked+attrFixed+attrNoSpec,#0),FileHandle
;               pl4 FileHandle
               lda FileHandle
               ora FileHandle+2
               bne OkayForMem
               brl MemoryError
OkayForMem     anop
               NewHandle (#$FFFF,MySID,#attrLocked+attrFixed+attrNoCross+attrNoSpec,#0),@xy
               stx   TempDP
               stx   DFileHandles
               sty   TempDP+2
               sty   DFileHandles+2
               ldy   #InstLoadErr
               jcs   MemoryError
               lda   [TempDP]
               sta   WavePtr1
               ldy   #2
               lda   [TempDP],y
               sta   WavePtr1+2
               NewHandle (#$FFFF,MySID,#attrLocked+attrFixed+attrNoCross+attrNoSpec,#0),@xy
               stx   TempDP
               stx   DFileHandles+4
               sty   TempDP+2
               sty   DFileHandles+6
               ldy   #InstLoadErr
               jcs   MemoryError
               lda   [TempDP]
               sta   WavePtr2
               ldy   #2
               lda   [TempDP],y
               sta   WavePtr2+2

               lda   #20
               sta   CurOffset          current offset
               stz   WaveOffset         waveform offset
               stz   InstDataOffset     inst data offset
               stz   CurInstNum
               stz   Num_Inst_Done
MakeDocFile3   ldy CurOffset
               sty Temp0
               stz Temp0+2
               add4 Temp0,SongPtr,Temp0
               MoveTo (#400,#9)	; print inst. name in menubar
               DrawString Temp0
               ldx #0
               ldy CurOffset
               short	a
               lda   [SongPtr],y        ; Get length byte of next instrument
               long	a                  ; filename.
               and #$00ff               ; If length = 0 then there are no more
               bne TheresMore           ; instruments to load.
               brl MakeDocFileEnd
TheresMore     inc   a                  ; Else add 2 to the length to tack on
               inc   a                  ; "8:" to the filename.
               sta   length
               iny
MakeDocFile4   lda   [SongPtr],y        ; Copy the filename out of the song
               sta   InstFile,x         ; and to our program's memory.
               iny
               iny
               inx
               inx
               cpx   #16
               bcc   MakeDocFile4
               ldx   #RealInstFile
               ldy   #^RealInstFile
               jsr   Read_A_File        ; Load the instrument.
               bcc   GoodLoad
               DisposeHandle FileHandle
               brl   ExitQuick
GoodLoad       lda   OpenDestIN         ; Move memory address the instrument
               sta   TempDP             ; was loaded at to TempDP.
               lda   OpenDestIN+2
               sta   TempDP+2
CheckValid     anop
               lda [TempDP]             ; Get first byte of file
               cmp #$4f46               ; Check for IFF signature (FO)
               bne NotASIF
               ldy #2                   ; 2 bytes later...
               lda [TempDP],y
               cmp #$4d52               ; Check for (RM)
               beq ASIFOk

NotASIF        anop
               brl   MakeDocFile6       ; abort alignment.

ASIFOk         jsr   FindWave           ; Find the start of the WAVE block.
               bcc   WAVEChunkOK        ; If WAVE not found, then abort!

               brl   MakeDocFile6       ; abort alignment.

WAVEChunkOK    phy                      ; Y now points to start of waveform.
               tya
               sec
               sbc   #10                ; Go back 10 to get size in 256-byte
               tay                      ; pages.
               lda   [TempDP],y
               xba                      ; XBA to multiply # of pages by 256
               tax                      ; to get number of bytes of the wave
               tya                      ; ROUNDED TO THE NEAREST 256th!
               sec                      ; Go back 6 to get size in bytes.
               sbc   #6
               tay
               lda   [TempDP],y         ; Get the size in bytes.
               and   #$FF               ; If real size is an even number of
               beq   InstEven           ; pages then skip over next step.
               txa                      ; Increment number of bytes in X.
               clc
               adc   #$100
               tax
InstEven       txa                      ; Store number of pages needed.
               sta   PagesUsed
               lsr   a                  ; Then divide by 2 and put back in X.
               tax
               pla                      ; Get offset to beginning of wave.
               sta   Temp4              ; Store it.
               lda   WaveOffset         ; Save original wave offset.
               pha
MakeDocFile5   ldy   Temp4              ; Copy the wave to our first big block
               lda   [TempDP],y         ; of memory
               ldy   WaveOffset
               sta   [WavePtr1],y
               inc   Temp4
               inc   Temp4
               inc   WaveOffset
               inc   WaveOffset
               dex
               bne   MakeDocFile5
               pla                      ; Restore original wave offset.
               sta   WaveOffset

               jsr   FindInst           ; Find INST chunk.
               bcc   INSTChunkOK        ; If INST chunck is missing, alert!

               InitCursor
               brl   MakeDocFile6       ; abort alignment.

INSTChunkOK    lda   InstDataOffset     ; Get offset into InstData..
               clc                      ; Add 33 (offset to WaveAddr).
               adc   #33
               tax
               ldy   CurInstNum            ; Get the number of bytes used by this
               lda   WaveOffset         ; wave so far, and XBA to get number of
               xba                      ; pages used.
               short	a                   ; Store the address of the waveform,
               sta   SSInt_Table9,x     ; in pages, at these locations.
               sta   SSInt_Table9+6,x   ; [InstRecord1] {waveb}
               sta   OldWaveAdr+1,y ; I'm too lazy to find out. :)
               long	a
               lda   PagesUsed          ; Store number of pages needed in
               sta   WaveSizes,y   ; another table.
               lda   WaveOffset         ; Calculate new offset that now points
               clc                      ; to the first byte free of our big
               adc   PagesUsed          ; wave memory block 1.
               sta   WaveOffset
               lda   InstDataOffset     ; Add 92 to InstDataOffset to make it
               clc                      ; point to next InstData record.
               adc   #$5C
               sta   InstDataOffset
               inc   CurInstNum            ; Move on to next instrument.
               inc   CurInstNum
MakeDocFile6   lda   CurOffset          ; Add 30 to CurOffset into song file
               clc                      ; to make it point to next InstBlock
               adc   #30                ; in song file.
               sta   CurOffset
               inc   Num_Inst_Done      ; Mark another instrument done.
               lda   Num_Inst_Done      ; If we've done 16 instruments then
               cmp   #16                ; stop.  Else repeat.
               beq   MakeDocFileEnd
               brl   MakeDocFile3
MakeDocFileEnd anop
               lda   Num_Inst_Done
               sta   InstIndex
               jsr Sort_DOC_RAM
exitQuick      DisposeHandle DFileHandles
               DisposeHandle DFileHandles+4
               rts

Sort_DOC_Ram   anop                  ; official De-Pariked version by IRSMan!
               lda   #0
               tax
InitMemMap     sta   DOCRAM_Map,x       ; init the docram map to show all
               inx                      ; free.
               inx
               cpx   #$200
               bne InitMemMap

               stz   Instrument_Num     ; init inst #
               stz   RAMPtr
               lda   #7                 ; starting with res=7 (32k waves),
               sta   ResToFind          ; scan each inst. for the current res
MainSortLoop   lda   ResToFind          ; and find a loc. in DOCRAM for it.
               asl   a
               asl   a
               asl   a
               clc
               adc   ResToFind          ; make res into full BTR value
               sta   BTRToFind
               lda   ResToFind
               asl   a
               tax
               lda   LoadInstTable2,x   ; get alignment factor for this res.
               asl   a
               sta   AlignFactor
               lda   Instrument_Num     ; now check each inst. to see if it
               asl   a                  ; matches the current BTR.
               tax
               lda   SSInt_Table8,x     ; get index into inst data table
               clc
               adc   #34                ; offset from start of wave def to
               tax                      ; BTR.
               lda   SSInt_Table9,x     ; get BTR
               and   #$FF               ; mask out garbage
               cmp   BTRToFind          ; is this inst the size we want?
               beq   BTRFound
               brl   NextInst         ; nope
BTRFound       ldx   RAMPtr
               lda   DOCRAM_Map,x       ; is primary align factor free?
               beq   CheckMem1
CheckMem0      lda   RAMPtr             ; check each possible align factor
               clc                      ; for a free space.
               adc   AlignFactor
               sta   RAMPtr
               cmp   #$200
               bne   BTRFound
               brl   InstLoadEnd
CheckMem1      lda   Instrument_Num     ; check found free space to see if its
               asl   a                  ; big enough to hold the wave data.
               tax
               lda   WaveSizes,x
               xba
               tay
               ldx   RAMPtr
CheckMemSize   lda   DOCRAM_Map,x
               bne   CheckMem0          ; if we run into a used block, try
               inx                      ; again!
               inx
               dey
               bne   CheckMemSize
               lda   Instrument_Num     ; okay!  we found a place for the wave!
               asl   a
               tax
               lda   RAMPtr
               lsr   a
               xba
               sta   NewWaveAdr,x       ; store the place we found for the wave
               lda   WaveSizes,x
               xba
               tay
               ldx   RAMPtr             ; mark off the area of docram as "used"
               lda   #$FFFF
MarkUsedLoop   sta   DOCRAM_Map,x
               inx
               inx
               dey
               bne   MarkUsedLoop
NextInst       inc   Instrument_Num     ; do next instrument
               lda   Instrument_Num
               cmp   Num_Inst_Done      ; are we done?
               beq   NextRes            ; yep, go to next resolution
               brl   MainSortLoop
NextRes        dec   ResToFind          ; next smallest wave size
               bmi   FinishUp        ; if done, finish up sort
               stz   RAMPtr
               stz   Instrument_Num
               brl   MainSortLoop
FinishUp       stz   Instrument_Num
FinishUp2      lda   Instrument_Num
               asl   a
               tax
               lda   OldWaveAdr,x
               sta   RAMPtr
               lda   NewWaveAdr,x
               sta   RAMPtr2
               sta   BlkSize
               lda   WaveSizes,x
               tax
CopyData       ldy   RAMPtr             ; copy wave data from "raw" buffer to
               lda   [WavePtr1],y       ; sorted buffer.  Don't assume wave is
               ldy   RAMPtr2            ; even (Parik did, SSS didn't!)
               sta   [WavePtr2],y
               inc   RAMPtr
               inc RAMPtr
               inc   RAMPtr2
               inc RAMPtr2
               dex
               dex
               bne   CopyData
               lda   Instrument_Num
               asl   a
               tax
               lda   SSInt_Table8,x
               clc
               adc   #$21
               tax
               lda   Instrument_Num
               asl   a
               tay
               lda   NewWaveAdr,y
               xba
               ldy   #8
               short	a
               sta   SSInt_Table9,x   ; store the new address into the instdef
               sta   SSInt_Table9+6,x
               long	a
               inc   Instrument_Num
               lda   Instrument_Num
               cmp   Num_Inst_Done
               bne   FinishUp2
               stz   MaxBlockSize
               stz   RAMPtr
CountMaxBlock  ldx   RAMPtr
               lda   DOCRAM_Map,x
               beq   FreeBlkFound
               inc   RAMPtr
               inc   RAMPtr
               lda   RAMPtr
               cmp   #$200
               bne   CountMaxBlock
               bra   AllDone
FreeBlkFound   ldx   RAMPtr
               stx   RAMPtr2
               stz   BlkSize
CkBkSize0      ldx   RAMPtr2
               lda   DOCRAM_Map,x
               bne   IsBlockBiggest
               inc   RAMPtr2
               inc   RAMPtr2
               inc   BlkSize
               lda   RAMPtr2
               cmp   #$200
               bne   CkBkSize0
IsBlockBiggest lda   BlkSize
               xba
               and   #$FF00
               cmp   MaxBlockSize
               bcc   CheckNext
               sta   MaxBlockSize
CheckNext      lda   RAMPtr2
               cmp   #$200
               beq   AllDone
               sta   RAMPtr
               brl   CountMaxBlock

AllDone        long	ai
               php
               sei
               WriteRamBlock (WavePtr2,#0,#$FFFF)
               plp
               rts

InstLoadEnd    anop
               rts
Read_A_File    Entry
               stx   OpenPath
               sty   OpenPath+2
               stz ResNum               ; we want data fork!
               Open 	OpenParms
               bcc OpenOk
               pha
               pea 0001
               pea 0000
               pea 0000
               pha
               _ErrorWindow
               pla
               sec
               rts
OpenOk         lda   ORefNum            Transfer out refNum
               sta   RRefNum
               sta   CRefNum

               lda Oeof
               sta RLength
               stz RLength+2            ASIFs won't be >64k EVER!

OkFM           anop

               lda [FileHandle]
               sta OpenDestIN
               ldy #2
               lda [FileHandle],y
               sta OpenDestIN+2

               Read ReadParms
               bcc ReadOk
               pha
               pea 0001
               pea 0000
               pea 0000
               pha
               _ErrorWindow
               pla
               Close CloseParms
               sec
               rts
ReadOk         Close CloseParms
               clc
               rts

FindInst       ldy   #0
FindInst1      lda   [TempDP],y
               cmp   #$4E49             IN
               bne   FindInst3
               iny
               iny
               lda   [TempDP],y
               cmp   #$5453             ST
               bne   FindInst3
               tya
               clc
               adc   #24
               tay                      ; Y now points to start of instrument
               ldx   InstDataOffset     ; envelope.
               lda   #22
               sta   Temp1
FindInst2      lda   [TempDP],y
               sta   SSInt_Table9,x
               iny
               iny
               inx
               inx
               dec   Temp1
               bne   FindInst2
               clc
               rts
FindInst3      iny
               iny
               dec   HalfInstSize
               bne   FindInst1
               sec
               rts

FindWave       lda   Oeof
               lsr   a
               sta   HalfInstSize
               sta   Temp1
               ldy   #0
FindWave1      lda   [TempDP],y
               cmp   #$4157             WA
               bne   FindWave2
               iny
               iny
               lda   [TempDP],y
               cmp   #$4556             VE
               bne   FindWave2
               tya
               clc
               adc   #38                ; Y now points to start of wave data.
               tay
               clc
               rts
FindWave2      iny
               iny
               dec   Temp1
               bne   FindWave1
               sec
               rts
GSOSError      anop
InstLoadErr    anop
MemoryError    anop
JustLeave      sec                      ; signal unable to load
               rts
               END

MainDATA       Data
PlayDirection  dc i2'0'
MainSpeed      dc i2'0'
NXTFlag        dc i2'0'
;DOCDatPath     gsstr 'DOC.DATA'
DOCDatPath	gsstr '9:edat:edat6.pak'
MyDP           ds 2
TrackInst      ds 32
Music_Loop     dc i2'1'
OscNum         ds 2
Pause          ds 2
openParms      anop
               dc    i'12'              pcount
ORefNum        ds    2                  ref_num
OpenPath       ds    4                  pathname
               dc    i2'3'              request_access: request all access
ResNum         dc    i2'0'              resource_num: open data fork
               ds    2                  access
               ds    2                  file_type
               ds    4                  aux_type
               ds    2                  storage_type
               ds    8                  create_td
               ds    8                  modify_td
               ds    4                  option_list
Oeof           ds    4                  eof

readParms      anop
               dc    i'4'               pcount
RRefNum        ds    2                  ref_num
OpenDestIN     ds    4                  data_buffer
RLength        ds    4                  request_count
               ds    4                  transfer_count

closeParms     anop
               dc    i'1'               pcount
CRefNum        ds    2                  ref_num

Name   ds 4

               End
SoundDAT       Data

FullVolume     dc i2'1'
HalfVolume     dc i2'0'

BlockTable     Entry
               dc    i'Nb_track*64*00,Nb_track*64*01,Nb_track*64*02'
               dc    i'Nb_track*64*03,Nb_track*64*04,Nb_track*64*05'
               dc    i'Nb_track*64*06,Nb_track*64*07,Nb_track*64*08'
               dc    i'Nb_track*64*09,Nb_track*64*10,Nb_track*64*11'
               dc    i'Nb_track*64*12,Nb_track*64*13,Nb_track*64*14'
               dc    i'Nb_track*64*15,Nb_track*64*16,Nb_track*64*17'
               dc    i'Nb_track*64*18,Nb_track*64*19,Nb_track*64*20'
               dc    i'Nb_track*64*21,Nb_track*64*22,Nb_track*64*23'
               dc    i'Nb_track*64*24,Nb_track*64*25,Nb_track*64*26'
               dc    i'Nb_track*64*27,Nb_track*64*28,Nb_track*64*29'
               dc    i'Nb_track*64*30,Nb_track*64*31,Nb_track*64*32'
               dc    i'Nb_track*64*33,Nb_track*64*34,Nb_track*64*35'
               dc    i'Nb_track*64*36,Nb_track*64*37,Nb_track*64*38'
               dc    i'Nb_track*64*39,Nb_track*64*40,Nb_track*64*41'
               dc    i'Nb_track*64*42,Nb_track*64*43,Nb_track*64*44'
               dc    i'Nb_track*64*45,Nb_track*64*46,Nb_track*64*47'
               dc    i'Nb_track*64*48,Nb_track*64*49,Nb_track*64*50'
               dc    i'Nb_track*64*51,Nb_track*64*52,Nb_track*64*53'
               dc    i'Nb_track*64*54,Nb_track*64*55,Nb_track*64*56'
               dc    i'Nb_track*64*57,Nb_track*64*58,Nb_track*64*59'
               dc    i'Nb_track*64*60,Nb_track*64*61,Nb_track*64*62'
               dc    i'Nb_track*64*63,Nb_track*64*64,Nb_track*64*65'
               dc    i'Nb_track*64*66,Nb_track*64*67,Nb_track*64*68'
               dc    i'Nb_track*64*69,Nb_track*64*70,Nb_track*64*71'
               dc    i'Nb_track*64*72'  ; fta only goes to *64*50

StereoMode     dc i2'$FFFF'

InstIndexTable Entry
               dc    i'Taille_Inst*00,Taille_Inst*01,Taille_Inst*02'
               dc    i'Taille_Inst*03,Taille_Inst*04,Taille_Inst*05'
               dc    i'Taille_Inst*06,Taille_Inst*07,Taille_Inst*08'
               dc    i'Taille_Inst*09,Taille_Inst*10,Taille_Inst*11'
               dc    i'Taille_Inst*12,Taille_Inst*13,Taille_Inst*14'
               dc    i'Taille_Inst*15'

VolumeConversion anop
               dc    i1'$0,$2,$4,$5,$6,$7,$9,$A,$C,$D,$F,$10,$12,$13,$15'
               dc    i1'$16,$18,$19,$1B,$1C,$1E,$1F,$21,$22,$24,$25'
               dc    i1'$27,$28,$2A,$2B,$2D,$2E,$30,$31,$33,$34,$36'
               dc    i1'$37,$39,$3A,$3C,$3D,$3F,$40,$42,$43,$45,$46'
               dc    i1'$48,$49,$4B,$4C,$4E,$4F,$51,$52,$54,$55,$57'
               dc    i1'$58,$5A,$5B,$5D,$5E,$60,$61,$63,$64,$66,$67'
               dc    i1'$69,$6A,$6C,$6D,$6F,$70,$72,$73,$75,$76,$78'
               dc    i1'$79,$7B,$7C,$7E,$7F,$81,$82,$84,$85,$87,$88'
               dc    i1'$8A,$8B,$8D,$8E,$90,$91,$93,$94,$96,$97,$99'
               dc    i1'$9A,$9C,$9D,$9F,$A0,$A2,$A3,$A5,$A6,$A8,$A9'
               dc    i1'$AB,$AC,$AE,$AF,$B1,$B2,$B4,$B5,$B7,$B8,$BA'
               dc    i1'$BB,$BD,$BE,$C0,$C0'

FreqTable      anop
 dc a'$00,$16,$17,$18,$1A,$1B,$1D,$1E,$20,$22,$24,$26' ; Octave 0
 dc a'$29,$2B,$2E,$31,$33,$36,$3A,$3D,$41,$45,$49,$4D' ; Octave 1
 dc a'$52,$56,$5C,$61,$67,$6D,$73,$7A,$81,$89,$91,$9A' ; Octave 2
 dc a'$0A3,$0AD,$0B7,$0C2,$0CE,$0D9,$0E6,$0F4,$102,$112,$122,$133' ; Octave 3
 dc a'$146,$15A,$16F,$184,$19B,$1B4,$1CE,$1E9,$206,$225,$246,$269' ; Octave 4
 dc a'$28D,$2B4,$2DD,$309,$337,$368,$39C,$3D3,$40D,$44A,$48C,$4D1' ; Octave 5
 dc a'$51A,$568,$5BA,$611,$66E,$6D0,$737,$7A5,$81A,$895,$918,$9A2' ; Octave 6
 dc a'$A35,$AD0,$B75,$C23,$CDC,$D9F,$E6F,$F4B,$1033,$112A,$122F,$1344' ;Octave7
 dc a'$1469,$15A0,$16E9,$1846,$19B7,$1B3F'
 dc a'$1CDE,$1E95,$2066,$2254,$245E,$2688' ; Octave 8

Table_Son      Entry
               dc    i1'OscFreqLoReg,$fa'
               dc    i1'OscFreqHiReg,$00'
               dc    i1'OscVolumeReg,$00'        Volume
               dc    i1'OscWavePtrReg,$00'       Wave pointer
               dc    i1'OscWaveSizeReg,$00'      size
               dc    i1'OscEnableReg,$3e'        enable 31 oscillators
               dc    i1'OscControlReg,$03'       Mode Halt   , enable ints


CurBlock       entry
               ds 2
Timer          ds    2
NumberOfBlocks entry                    ; # of blocks
               ds 2
NotePlayed     ds    4                  ; pos. in block
BlockIndex     ds    2                  ; index into blocks
NoteIndex      ds    2                  ; index into block
PositionBock   ds    2
Tempo          entry                    ; tempo of song
               ds 2
VolumeInt      ds    2                  ; volume temp. storage loc.
CurrInstInt    ds    2
InstIndex      ds    2

SampleTable    ds    Nb_Track
ArpegiattoTbl  ds    Nb_Track
ArpegeToneTbl  ds    Nb_Track
TrueVolumeTbl  ds    Nb_Track*2

OscNumber      ds    2
Temporary      ds    2
Semitone       ds    2
TempInterrupt  ds    2
Temp2Interrupt ds    2
Temp3Interrupt ds    2
Temp4Interrupt ds    2
TempFreqInt    ds    2
IndexInterrupt ds    2

VolumeTable    ds    32
StereoTable    ds    32
CompactTable   ds    32
instdef        ds    16*taille_inst
               END
ParikDATA      DATA
LoadInstTable2 dc    i2'$0001'          ; BTR to pages translation table
               dc    i2'$0002'
               dc    i2'$0004'
               dc    i2'$0008'
               dc    i2'$0010'
               dc    i2'$0020'
               dc    i2'$0040'
               dc    i2'$0080'
SSInt_Table8   anop                   ; offsets into SSInt_Table9
               dc    i2'$0000'        ; (i.e. instdef as us real pgmrs call it)
               dc    i2'$005C'
               dc    i2'$00B8'
               dc    i2'$0114'
               dc    i2'$0170'
               dc    i2'$01CC'
               dc    i2'$0228'
               dc    i2'$0284'
               dc    i2'$02E0'
               dc    i2'$033C'
               dc    i2'$0398'
               dc    i2'$03F4'
               dc    i2'$0450'
               dc    i2'$04AC'
               dc    i2'$0508'
               dc    i2'$0564'

SSInt_Table9   ds    1500               Instrument definition table

DFileHandles   ds    8
Instrument_Num ds 2
RAMPtr         ds 2
ResToFind      ds 2
BTRToFind      ds 2
AlignFactor    ds 2
RAMPtr2        ds 2
BlkSize        ds 2
MaxBlockSize   ds 2
DOCRAM_Map     ds 512
WaveSizes      ds 32
NewWaveAdr     ds 32
OldWaveAdr     ds 32
Num_Inst_Done  ds    2
HalfInstSize   ds 2
AllInstsFound  ds 2
CurOffset      ds 2
CurInstNum     ds 2
InstDataOffset ds 2
PagesUsed      ds 2
WaveOffset     ds 2
Temp4          ds 4
RealInstFile   anop
length         ds    2
               dc    c'8:'
InstFile       ds    300
               END

Globals	DATA
RealName	ds	$100
VUSpeed	dc	i2'2'
Playing	dc	i2'0'
SongEnd	dc	i2'0'
FFFlag	dc	i2'0'
FFTempo	dc	i2'2'
	END
