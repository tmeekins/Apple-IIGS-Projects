               keep  'graf'
               copy  'z3d.h'
               mcopy 'graf.mac'

LineStart      START

               stx   StartY
               sta   StartX
               rts
;
; Draw a line
;
DrawLine       ENTRY

               stx   EndY
               sta   EndX
;
; If End Y <= Start Y then Swap coordinates so that we progress in positve
; Y direction
;
               lda   StartY
               cmp   EndY
               bcc   GetAddr

               ldy   EndY               ;Start X <=> End X
               sta   EndY
               sty   StartY

               lda   StartX             ;Start Y <=> End Y
               ldy   EndX
               sty   StartX
               sta   EndX
;
; Calculate the starting screen address
; 
GetAddr        lda   StartY
               asl2  a
               adc   StartY
               asl4  a
               asl2  a
               adc   StartX
               sta   LineAdr

               sub2  EndY,StartY,DY     ;DY = ENDY - ENDX
               if2   StartX,lt,EndX,OctantB
               sbc   EndX
               sta   DX
               cmp   DY
               bcc   OctantA
               brl   OctantD
;
; Draw octant A line
;
OctantA        anop
               phb
               ph2   #$0101
               plb
               plb
               lda   DY
               tay
               lsr   a
               eor   #$FFFF
               inc   a
               sta   Err
               lda   >LineAdr
               lsr   a
               tax
               bcc   OctantAEven
               clc
               bra   OctantAOdd

OctantA0       sta   Err
OctantAOdd     lda   #$0A
               ora   $2000,x
               sta   $2000,x
               dey
               bmi   OctantADone
               txa
               adc   #160
               tax
               lda   DX
               adc   Err
               bmi   OctantA0
               sbc   DY

OctantA1       sta   Err
OctantAEven    lda   #$A000
               ora   $2000-1,x
               sta   $2000-1,x
               dey
               bmi   OctantADone
               txa
               adc   #160
               tax
               lda   DX
               adc   Err
               bmi   OctantA1
               sbc   DY
               dex
               bra   OctantA0
OctantADone    plb
               rts
;
; Draw octant B line
;
OctantB        anop
               sub2  EndX,StartX,DX
               cmp   DY
               bcs   OctantC
               phb
               ph2   #$0101
               plb
               plb
               lda   DY
               tay
               inc   a
               lsr   a
               eor   #$FFFF
               inc   a
               sta   Err
               lda   >LineAdr
               lsr   a
               tax
               bcc   OctantBEven
               clc
               bra   OctantBOdd

OctantB0       sta   Err
OctantBOdd     lda   #$0A
               ora   $2000,x
               sta   $2000,x
               dey
               bmi   OctantBDone
               txa
               adc   #160
               tax
               lda   DX
               adc   Err
               bmi   OctantB0
               sbc   DY
               inx

OctantB1       sta   Err
OctantBEven    lda   #$A000
               ora   $2000-1,x
               sta   $2000-1,x
               dey
               bmi   OctantBDone
               txa
               adc   #160
               tax
               lda   DX
               adc   Err
               bmi   OctantB1
               sbc   DY
               bra   OctantB0
OctantBDone    plb
               rts
;
; Draw Octant C Line
;
OctantC        phb
               ph2   #$0101
               plb
               plb
               lda   DX
               tay
               lsr   a
               eor   #$FFFF
               inc   a
               sta   Err
               lda   >LineAdr
               lsr   a
               tax
               bcc   OctantCEven
               clc
               bra   OctantCOdd

OctantC0       sta   Err
OctantCOdd     lda   #$0A
               ora   $2000,x
               sta   $2000,x
               dey
               bmi   OctantCDone
               inx
               lda   DY
               adc   Err
               bmi   OctantC1
               sbc   DX
               sta   Err
               txa
               adc   #160
               tax
               bra   OctantCEven

OctantC1       sta   Err
OctantCEven    lda   #$A000
               ora   $2000-1,x
               sta   $2000-1,x
               dey
               bmi   OctantCDone
               lda   DY
               adc   Err
               bmi   OctantC0
               sbc   DX
               sta   Err
               txa
               adc   #160
               tax
               bra   OctantCOdd
OctantCDone    plb
               rts
;
; Draw Octant D line
;
OctantD        phb
               ph2   #$0101
               plb
               plb
               lda   DX
               tay
               lsr   a
               eor   #$FFFF
               inc   a
               sta   Err
               lda   >LineAdr
               lsr   a
               tax
               bcc   OctantDEven
               clc
               bra   OctantDOdd

OctantD0       sta   Err
OctantDOdd     lda   #$0A
               ora   $2000,x
               sta   $2000,x
               dey
               bmi   OctantDDone
               lda   DY
               adc   Err
               bmi   OctantD1
               sbc   DX
               sta   Err
               txa
               adc   #160
               tax
               bra   OctantDEven

OctantD1       sta   Err
OctantDEven    lda   #$A000
               ora   $2000-1,x
               sta   $2000-1,x
               dey
               bmi   OctantDDone
               dex
               lda   DY
               adc   Err
               bmi   OctantD0
               sbc   DX
               sta   Err
               txa
               adc   #160
               tax
               bra   OctantDOdd
OctantDDone    plb
               rts

LineAdr        ds    2

               END
