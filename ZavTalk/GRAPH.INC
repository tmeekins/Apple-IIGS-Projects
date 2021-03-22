**********************************************************************
*
* Turn on Graphics, set up palettes and SCBs.
*
**********************************************************************

GraphOn        start

               using Tables

               sep   #$30
               longa off
               longi off

               lda   #$80               ;Turn on Super Hi-Res
               ora   $E0C029
               sta   $E0C029

               ldx   #$1F               ;Set up default palette
copy           lda   >Pal640,x
               sta   $E19E00,x
               dex
               bpl   copy

               ldx   #$C8               ;640 mode, palette 0
               lda   #$80
modeloop       sta   $E19CFF,x
               dex
               bne   modeLoop

               rep   #$30
               longa on
               longi on

               lda   #$E1               ;Set up screen bank
               sta   ScrnAdr+2

               jmp   HomeClear

               end

**********************************************************************
*
* Clear the screen to black.
*
**********************************************************************


ClrScrn        start

               longa on
               longi on

               phb
               pea   $E1E1
               plb
               plb
               ldx   #$F9E
bigloop        stz   $2000,x
               stz   $2FA0,x
               stz   $3F40,x
               stz   $4EE0,x
               stz   $5E80,x
               stz   $6E20,x
               stz   $7DC0,x
               stz   $8D60,x
               dex
               dex
               bpl   bigloop
               plb

               jmp   DrawCursor         ;Go draw the cursor

               end
