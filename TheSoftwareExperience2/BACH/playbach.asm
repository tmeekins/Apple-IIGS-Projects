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
* PLAYBACH.ASM                                                            *
*  - Play Bach's Toccata and Fugue in D Minor, BWV 565.                   *
*                                                                         *
***************************************************************************

               mcopy playbach.mac

SOUNDCTL       gequ  $C03C
SOUNDDATA      gequ  $C03D
SOUNDADRL      gequ  $C03E
SOUNDADRH      gequ  $C03F
IRQ_SOUND      gequ  $E1002C

PlayBach       START

               using OrganData

               proc

               native

               short a
               long  x
               sei
;
; Copy organ to DOC RAM
;
               ld2   %01100000,SOUNDCTL
               ld2   0,(SOUNDADRL,SOUNDADRH)
               ldx   #0
copyOrgan      lda   Organ,x
               sta   SOUNDDATA
               inx
               cpx   #1024
               bne   copyOrgan

;
; Initialize registers
;
               short ai
               ld2   $F,SOUNDCTL

               ldx   #$40
               ldy   #$20
init1          txa
               sta   SOUNDADRL
               ld2   $FF,SOUNDDATA
               inx
               dey
               bne   init1

               ldx   #$80
               ldy   #$20
init2          txa
               sta   SOUNDADRL
               ld2   0,SOUNDDATA
               inx
               dey
               bne   init2

               ldy   #$20
init3          txa
               sta   SOUNDADRL
               ld2   1,SOUNDDATA
               inx
               dey
               bne   init3

               ldy   #$20
init4          txa
               sta   SOUNDADRL
               ld2   %00010000,SOUNDDATA
               inx
               dey
               bne   init4

               ld2   $E1,SOUNDADRL
               ld2   30*2,SOUNDDATA
;
; Set up oscillator 0 as an interrupt generator.
;
               ld2   $40,SOUNDADRL
               ld2   0,SOUNDDATA
               ld2   $A0,SOUNDADRL
               ld2   %00001000,SOUNDDATA
               ld2   $00,SOUNDADRL
               ld2   $00,SOUNDDATA
               ld2   $20,SOUNDADRL
               ld2   $08,SOUNDDATA
               ld2   $C0,SOUNDADRL
               ld2   $00,SOUNDDATA
;
; Set up pointer to interrupt handler
;
               ld2   $5C,IRQ_SOUND
               ld2   <IRQ_Bach,IRQ_SOUND+1
               ld2   >IRQ_Bach,IRQ_SOUND+2
               ld2   ^IRQ_Bach,IRQ_SOUND+3

               ld2   0,(BachOffset,CmdWait)
               ld2   1,(Tempo,TempoWait)

               cli

               procendl

               END

**************************************************************************
*
* A sound interrupt has occurred, so do something!!
*
**************************************************************************

IRQ_Bach       START

               using FugueData

               proc
               php
               native
               short ai
;
; Wait in case the DOC is busy
;
waitDOC        mv2   $C034,border
               ld2   $C,$C034
               lda   SOUNDCTL
               bmi   waitDOC

               ld2   $F,SOUNDCTL

               ld2   $E0,SOUNDADRL
               lda   SOUNDDATA
               and2  SOUNDDATA,#$7F,SOUNDDATA

               and   #%00111110
               lsr   a
               beq   goodinterrupt

               add2  @,#$A0,SOUNDADRL
               lda   SOUNDDATA
               and2  SOUNDDATA,#%11110111,SOUNDDATA

               mv2   border,$C034
               plp
               xce
               clc
               procendL

goodinterrupt  anop
               jsr   doattdec
               dec   TempoWait
               beq   trycmd
               mv2   border,$C034
               plp
               xce
               clc
               procendL
;
; Are we ready for another command ?
;
trycmd         mv2   Tempo,TempoWait
               lda   CmdWait
               beq   docmd
               dec   CmdWait
               mv2   border,$C034
               plp
               xce
               clc
               procendL
;
; Quit the sequence, stop interrupts
;
SeqDone        ld2   $18,IRQ_SOUND
               ld2   $6B,IRQ_SOUND

               ldx   #$A0
               ldy   #$20
shutdown       txa
               sta   SOUNDADRL
               ld2   1,SOUNDDATA
               inx
               dey
               bne   shutdown

               mv2   border,$C034
               plp
               xce
               clc
               procendL
;
; Begin executing a command sequence
;
docmd          jsr   getbyte
               sta   CmdWait
               cmp   #0
               beq   SeqDone
;
; Get and execute the next commands
;
getcmd         jsr   getbyte
               asl   a
               tax
               long  a
               lda   commands,x
               sta   jump+1
               short a
jump           jmp   $FFFF
;
; Command Table
;
commands       dc    i'DoEndCmd,DoPlayNote,DoStopNote,DoSetTempo'
;
; Set the tempo
;
DoSetTempo     jsr   getbyte
               sta   Tempo
               sta   TempoWait
               jmp   getcmd
;
; Play a note
;
DoPlayNote     jsr   getbyte
               asl   a
               sta   osc
               jsr   getbyte
               long  ai
               and   #$FF
               asl   a
               tax
               lda   FreqTbl,x
               sta   freq
               short ai

               mv2   osc,SOUNDADRL
               mv2   freq,SOUNDDATA
               add2  osc,#$20,SOUNDADRL
               mv2   freq+1,SOUNDDATA

               ldx   osc

               ld2   $F0,temp
               add2  osc,#$A0,SOUNDADRL
               lda   SOUNDDATA
               lda   SOUNDDATA
               bit   #%00000001
               beq   ps2
               ld2   0,temp
ps2            lda   ChanTbl,x
               sta   SOUNDDATA

               add2  osc,#$40,SOUNDADRL
               mv2   temp,SOUNDDATA
               lda   #0
               sta   decaytbl,x
               lda   #1
               sta   attacktbl,x

               jmp   getcmd
;
; Stop playing a note
;
DoStopNote     jsr   GetByte
               asl   a
               sta   osc

               add2  @,#$40,SOUNDADRL
               ld2   $F8,SOUNDDATA

               ldx   osc
               lda   #1
               sta   decaytbl,x
               lda   #0
               sta   attacktbl,x

               jmp   getcmd
;
; All done with commands list
;
DoEndCmd       anop
               mv2   border,$C034
               plp
               xce
               clc
               procendL
;
; Get the next byte from the sequence
;
getbyte        long  i
               ldx   BachOffset
               lda   Fugue,x
               inx
               stx   BachOffset
               short i
               rts
;
; Decay any notes that need to be decayed
;
doattdec       ldx   #2
decayloop      lda   decaytbl,x
               beq   nextdecay
               add2  @x,#$40,SOUNDADRL
               lda   SOUNDDATA
               lda   SOUNDDATA
               cmp   #$9
               bcs   decay2
               lda   #0
               sta   decaytbl,x
               add2  @x,#$A0,SOUNDADRL
               ld2   %00000101,SOUNDDATA
               jmp   nextdecay
decay2         sub2  @,#8,SOUNDDATA
nextdecay      inx2
               cpx   #28
               bcc   decayloop
;
; Perform attack on any necessary notes
;
               ldx   #2
attackloop     lda   attacktbl,x
               beq   nextattack
               add2  @x,#$40,SOUNDADRL
               lda   SOUNDDATA
               lda   SOUNDDATA
               cmp   #$F0
               bcs   attack2
               add2  @,#$10,SOUNDDATA
               jmp   nextattack

attack2        ld2   $FF,SOUNDDATA
               lda   #0
               sta   attacktbl,x
nextattack     inx2
               cpx   #28
               bcc   attackloop
               rts

border         ds    2

freq           ds    2
osc            ds    2
temp           ds    2

BachOffset     ENTRY
               ds    2
Tempo          ENTRY
               ds    2
TempoWait      ENTRY
               ds    2
CmdWait        ENTRY
               ds    2

attacktbl      dc    16i'0'

decaytbl       dc    16i'0'

ChanTbl        dc    9i'$00+%100,$10+%100'

FreqTbl        dc    i'$00,$16,$17,$18,$1A,$1B,$1D,$1E,$20,$22,$24,$26,$29,$2B'
               dc    i'$2E,$31,$33,$36,$3A,$3D,$41,$45,$49,$4d,$52,$56,$5C,$61'
               dc    i'$67,$6D,$73,$7A,$81,$89,$91,$9A,$A3,$AD,$B7,$C2,$CE,$D9'
               dc    i'$E6,$F4,$102,$112,$122,$133,$146,$15A,$16F,$184,$19B'
               dc    i'$1B4,$1CE,$1E9,$206,$224,$246,$269,$28D,$2B4,$2DD,$309'
               dc    i'$337,$368,$39C,$3D3,$40D,$44A,$48C,$4D1,$51A,$568,$5BA'
               dc    i'$611,$66E,$6D0,$737,$7A5,$81A,$895,$918,$9A2,$A35,$AD0'
               dc    i'$B75,$C23,$CDC,$D9F,$E6F,$F4B,$1033,$112A,$122F,$1344'
               dc    i'$1469,$15A0,$16E9,$1846,$19B7,$1B3F,$1CDE,$1E95,$2066'
               dc    i'$2254,$245E'

               END
