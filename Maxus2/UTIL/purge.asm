;
; Purge 2.0
;
; Original version by Mike Westerfield, Rewritten by Tim Meekins
;

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

msg1           dc    c'Purge 2.0',h'0d0a0a'
               dc    c'Handle  Ptr     Attr  User  Length  App',h'0d0a00'
msg2           str   ' $'

lb1a           WriteCString #msg1
lb2            lda   handle
               ora   handle+2
               jeq   lb4
               ldy   #next
               lda   [handle],y
               sta   nextHandle
               iny2
               lda   [handle],y
               sta   nextHandle+2
               ldy   #attributes
               lda   [handle],y
               jmi   lb3
               and   #$0300
               jeq   lb3
               WriteChar #'$'
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
               WriteChar #' '
               stz   ref
apploop        ldy   #userID
               lda   [handle],y
               and   #%1111000011111111
               LGetPathname (@a,ref),@yx
               if2   @a,eq,#0,appput
               inc   ref
               if2   ref,cc,#40,apploop
               bra   oops
appput         WriteString @xy
oops           WriteLine #empty
               PurgeHandle handle
lb3            mv4   nextHandle,handle
               jmp   lb2
lb4            CompactMem
               lda   #0
               rtl

empty          str   ''
ref            ds    2
               end

PrintHex1      start

               Int2Hex (@a,#str+1,#2)
               WriteString #str
               rts
str            str   '??'
               end

PrintHex2      start

               Int2Hex (@a,#str+1,#4)
               WriteString #str
               rts
str            str   '????'
               end

PrintHex4      start

               pha
               txa
               jsr   PrintHex1
               pla
               brl   PrintHex2
               end
