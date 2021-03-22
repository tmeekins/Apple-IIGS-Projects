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
* BOOT.ASM                                                                *
*  - Boot Code                                                            *
*                                                                         *
***************************************************************************

               mcopy boot.mac

               org   $800

Boot           START

               dc    i1'1'

               emulate                  ;Emulation mode

               sei

               lda   #%10000000
               tsb   $C036

vblwait1       lda   $C019
               bmi   vblwait1
vblwait2       lda   $C019
               bpl   vblwait2
;
; Black the screen
;
               ld2   $41,$C029          ;text
               stz   $C034              ;black border
               stz   $C022              ;black bg and text
;
; Load and do Splash1 at $0/1000
;
               lda   #7
               sta   block
               stz   block+1
               stz   Block+2
               stz   Block+3
               stz   ReadBuf
               lda   #$10
               sta   ReadBuf+1
               stz   ReadBuf+2
               stz   ReadBuf+3
ReadLoop1      jsr   ReadABlock
               clc
               lda   ReadBuf+1
               adc   #2
               sta   ReadBuf+1
               inc   Block
               lda   Block
               cmp   #19
               bcc   ReadLoop1

               jsr   $1000
;
; Load and do Splash2 $0/1000
;
               emulate
               lda   #$10
               sta   ReadBuf+1
ReadLoop2      jsr   ReadABlock
               clc
               lda   ReadBuf+1
               adc   #2
               sta   ReadBuf+1
               inc   Block
               lda   Block
               cmp   #29
               bcc   ReadLoop2

               jsr   $1000
;
; Load and copy PlayBach  $1/A000
;
               emulate
               ld2   $A0,ReadBuf+1
               ld2   $1,ReadBuf+2
ReadLoop3      jsr   ReadABlock
               clc
               lda   ReadBuf+1
               adc   #2
               sta   ReadBuf+1
               inc   Block
               lda   Block
               cmp   #42
               bcc   ReadLoop3
;
; Load and copy Splash3 $2/4000
;
               ld2   $40,ReadBuf+1
               ld2   $2,ReadBuf+2
ReadLoop4      jsr   ReadABlock
               clc
               lda   ReadBuf+1
               adc   #2
               sta   ReadBuf+1
               inc   Block
               lda   Block
               cmp   #59
               bcc   ReadLoop4
;
; Eject Disk
;
               jsr   $C50D
               dc    i1'4'
               dc    i2'EjectParm'
;
; Start the Demo...
;
               jsl   $1A000
               jmp   $24000

loop           jmp   loop

ReadABlock     jsr   $C50D
               dc    i1'$41'
               dc    i4'ReadParm'
               bcs   ReadABlock
               rts

ReadParm       dc    i1'3'
               dc    i1'1'
ReadBuf        dc    i4'0'
Block          dc    i4'0'

EjectParm      dc    i1'3'
               dc    i1'1'
               dc    i2'EjectCtl'
               dc    i1'4'

EjectCtl       dc    i'0'

               END
