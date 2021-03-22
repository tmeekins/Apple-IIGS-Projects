*************************************************************************
*
* Compile routines for shadowing and clearing the super-hires screen
*
*************************************************************************

               keep  'mkstuff'
               mcopy 'mkstuff.mac'

mkshad         START makestuff

width          gequ  36
left           gequ	62
top            gequ  18
bot            gequ  62

ptr            equ   $00
adr            equ   $04
olddp          equ   $06

               phb

               ld4   shadproc,ptr

               ldx   #0
mkHeader       lda   >Header,x
               beq   doneheader
               sta   [ptr]
               inc   ptr
               inx
               bra   mkHeader
doneheader     anop

               ld2   $2000+160*top+left,adr
               ld2   $1234,olddp

makeloop       anop

               ld2   $A9,"[ptr]"        ;LDA #x
               inc   ptr
               add2  adr,#Width,@a
               dec   a
               sta   [ptr]
               inc2  ptr
               ld2   $1B,"[ptr]"        ;TCS
               inc   ptr

               ld2   $A9,"[ptr]"        ;LDA #xx
               inc   ptr
               mv2   adr,"[ptr]"
               inc2  ptr
               ld2   $5B,"[ptr]"        ;TCD
               inc   ptr

               ldy   #Width-2
SLLoop         ld2   $D4,"[ptr]"        ;PEI
               inc   ptr
               tya
               sta   [ptr]
               inc   ptr
               dey2
               bpl   SLLoop

               add2  adr,#160,adr
               if2   @a,lt,#$2000+160*bot,makeloop

done           anop
               ldx   #0
mkFooter       lda   >Footer,x
               beq   doneFooter
               sta   [ptr]
               inc   ptr
               inx
               bra   mkFooter
doneFooter     anop

               plb
               rtl

Header         phd
               lda   >$E1C068
               ora   #$30
               sta   >$E1C068
               tsx
               dc    i'0'

Footer         lda   >$E1C068
               and   #$FFCF
               sta   >$E1C068
               txs
               pld
               rtl
               dc    i'0'

               END


mkclr          START makestuff

ptr            equ   $00
adr            equ   $04
olddp          equ   $06
count          equ   $08

               phb

               ld4   clrproc,ptr

               ldx   #0
mkHeader       lda   >Header,x
               beq   doneheader
               sta   [ptr]
               inc   ptr
               inx
               bra   mkHeader
doneheader     anop

               ld2   $2000+160*top+left,adr
               ld2   $1234,olddp
               stz   count

makeloop       and2  adr,#$FF00,@y
               if2   @a,eq,olddp,skip
               sta   olddp
               ld2   $A9,"[ptr]"        ;LDA #xx
               inc   ptr
               tya
               sta   [ptr]
               inc2  ptr
               ld2   $5B,"[ptr]"        ;TCD
               inc   ptr

skip           ld2   $64,"[ptr]"        ;STZ dp
               inc   ptr
               lda   adr
               sta   [ptr]
               inc   ptr
               inc2  adr
               inc2  count
               if2   count,le,#width,makeloop

               stz   count
               add2  adr,#158-width,adr
               if2   @a,lt,#$2000+160*bot,makeloop

done           anop
               ldx   #0
mkFooter       lda   >Footer,x
               beq   doneFooter
               sta   [ptr]
               inc   ptr
               inx
               bra   mkFooter
doneFooter     anop

               plb
               rtl

Header         phd
               lda   >$E1C068
               ora   #$30
               sta   >$E1C068
               tsx
               dc    i'0'

Footer         lda   >$E1C068
               and   #$FFCF
               sta   >$E1C068
               txs
               pld
               rtl
               dc    i'0'

               END

clrproc        START clr    

               ds    $3000

               END

shadproc       START shad

               ds    $3000

               END
