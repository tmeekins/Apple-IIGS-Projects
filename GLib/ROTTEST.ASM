         copy  grlib.equ
         copy  inlib.equ
test     start
         phk
         plb
         jsl   GL_GraphOn

         lda   #$7777
         sta   Pattern

         lda   #<Poly
         sta   PolyPtr
         lda   #^Poly
         sta   PolyPtr+2

         lda   #<Points2
         sta   PointPtr
         lda   #^Points2
         sta   PointPtr+2

         lda   #<Points
         sta   GLParm
         lda   #^Points
         sta   GLParm+2

         lda   #<matrix
         sta   MatrixPtr
         lda   #^matrix
         sta   MatrixPtr+2
         jsl   GL_InitMatrix

         lda   #130
         sta   XCoord1
         lda   #65
         sta   YCoord1
         jsl   GL_TranslateXY

bl       lda   #-160
         sta   XCoord1
         lda   #-100
         sta   YCoord1
         jsl   GL_TranslateXY
         lda   #-10
         sta   Arg1
         jsl   GL_Rotate
         lda   #160
         sta   XCoord1
         lda   #100
         sta   YCoord1
         jsl   GL_TranslateXY

         lda   #0
         sta   Pattern
;         sep   #$20
;zz       lda   $e0c019
;         bpl   zz
;         rep   #$20
         jsl   GL_FramePoly2

         jsl   GL_TransPoly

         lda   #$7777
         sta   Pattern
;         sep   #$20
;yy       lda   $e0c019
;         bpl   yy
;         rep   #$20
         jsl   GL_FramePoly2

         sep   #$20
         lda   $e0c000
         bmi   done
         rep   #$20

         jmp   bl

done     sep   #$30
loop     lda   $e0c000
         bpl   loop
         sta   $e0c010
         rep   #$30

         jsl   GL_GraphOff

         rtl

count    ds    2

matrix   ds    vsize

Points   dc    i'18,0'
         dc    i'20,0,40,0,50,10,40,10,50,30,40,60,50,60,60,70'
         dc    i'0,70,10,60,20,60,10,30,20,30,30,40,40,30,30,20'
         dc    i'20,10,10,10'

Poly     dc    i'20'
         dc    i'1,2,3,4,5,6,7,8,9,10,11,12,-13,14,15,16,13,-12,17,18'

Points2  ds    80

         end
