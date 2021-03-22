         keep  makesin
         mcopy makesin.mac

Makesin  START

         pha
         pha
         pha
         pha
         ph2   #31416
         ph2   #10000
         _FixRatio
         ph4   #$00b40000
         _FixDiv
         pl4   Factor

         stz   degree
         stz   degree+2
loop     pha                            ;for 2fix
         pha

         pha                            ;for sin
         pha

         pha                            ;for mult
         pha
         ph4   factor
         ph4   degree
         _FixMul
         _FracSin
         _Frac2Fix
         ph4   #bytes
         ph2   #8
         _Long2Hex
         ph2   degree+2
         ph4   #angle
         ph2   #3
         ph2   #-1
         _Int2Dec
         ph4   #text
         _WriteCString

         inc   degree+2
         lda   degree+2
         cmp   #361
         bcc   loop
         rtl


factor   ds    4
degree   ds    4

text     dc    c'         dc    i4''$'
bytes    dc    c'00000000''  ; sin('
angle    dc    c'000)',h'0d 0a',i1'0'

         END
