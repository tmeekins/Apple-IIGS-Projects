               keep  purge
               mcopy purge.mac

Purge          start
handle         equ   0
nextHandle     equ   4
location       equ   0
;
attributes     equ   4
userID         equ   6
length         equ   8
last           equ   12
next           equ   16

               phk
               plb

               FindHandle #Purge,handle

lb1            ldy   #last
               lda   [handle],y
               tax
               iny2
               ora   [handle],y
               beq   lb1a
               lda   [handle],y
               sta   handle+2
               stx   handle
               bra   lb1

msg1           str   'Handles purged:'
msg2           str   ' $'

lb1a           WriteLine #msg1
lb2            lda   handle
               ora   handle+2
               bne   abc1
               brl   lb4
abc1           ldy   #next
               lda   [handle],y
               sta   nextHandle
               iny2
               lda   [handle],y
               sta   nextHandle+2
               ldy   #attributes
               lda   [handle],y
               bpl   abc2
               brl   lb3
abc2           and   #$0300
               bne   abc3
               brl   lb3
abc3           WriteChar #'$'
               ldx   handle+2
               lda   handle
               jsr   PrintHex4
               WriteString #msg2
               ldy   #2
               lda   [handle],y
               tax
               lda   [handle]
               jsr   PrintHex4
               WriteString #msg2
               ldy   #attributes
               lda   [handle],y
               jsr   PrintHex2
               WriteString #msg2
               ldy   #userID
               lda   [handle],y
               jsr   PrintHex2
               WriteString #msg2
               ldy   #length+2
               lda   [handle],y
               tax
               dey2
               lda   [handle],y
               jsr   PrintHex4
               WriteString #msg2
               ldy   #last+2
               lda   [handle],y
               tax
               dey2
               lda   [handle],y
               jsr   PrintHex4
               WriteString #msg2
               ldy   #next+2
               lda   [handle],y
               tax
               dey2
               lda   [handle],y
               jsr   PrintHex4
               WriteLine #empty
               PurgeHandle handle
lb3            mv4   nextHandle,handle
               brl   lb2
lb4            CompactMem
               lda   #0
               rtl

empty          str   ''
               end

PrintHex2      start

               Int2Hex (@a,#str+1,#4)
               WriteString #str
               rts
str            str   '????'
               end

PrintHEx4      start

               pha
               txa
               jsr   PrintHex2
               pla
               brl   PrintHex2
               end
