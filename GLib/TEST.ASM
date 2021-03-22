;
; GRLIB test program
;
         copy  inlib.equ
         copy  grlib.equ

test     start

         phk
         plb
         jsl   GL_GraphOn
;
; Create a rotation matrix
;
         lda   #<matrix
         sta   MatrixPtr
         lda   #^matrix
         sta   MatrixPtr+2
         jsl   GL_InitMatrix
         lda   #5
         sta   Arg1
         jsl   GL_Rotate
;
;
;
         lda   #20
         sta   count
;
; Convert polygon from integer to fixed
;
         lda   #<Points
         sta   GLParm
         lda   #^Points
         sta   GLParm+2
         lda   #<Points1f
         sta   PointPtr
         lda   #^Points1f
         sta   PointPtr+2
         jsl   GL_Poly2Fi
;
; Find bounding rectangle and set window to it
;
rotloop  lda   #<Poly
         sta   PolyPtr
         lda   #^Poly
         sta   PolyPtr+2
         jsl   GL_BoundPolyFi
         jsl   GL_SetWindow
;
; Map the polygon from the window to the viewport
;
         lda   #<Points1f
         sta   GLParm
         lda   #^Points1f
         sta   GLParm+2
         lda   #<Points
         sta   PointPtr
         lda   #^Points
         sta   PointPtr+2
         jsl   GL_MapPoly
;
; Draw a red polygon
;
         lda   #$7777
         sta   Pattern
         jsl   GL_FramePoly
         sep   #$30
lo       lda   $e0c000
         bpl   lo
         sta   $e0c010
         rep   #$30
         lda   #0
         sta   Pattern
         jsl   GL_FramePoly
;
; Rotate it 90 degrees
;
         lda   #<Points1f
         sta   PointPtr
         lda   #^Points1f
         sta   PointPtr+2
         jsl   GL_TransPoly
;
; loop count number of times
;
         dec   count
         beq   done
         jmp   rotloop
;
; wait for keypress then quit
;
done     sep   #$30
loop     lda   $e0c000
         bpl   loop
         sta   $e0c010
         rep   #$30

         jsl   GL_GraphOff

         rtl

Points   dc    i'10,0'
         dc    i'-2,-2'
         dc    i' 0,-2'
         dc    i' 2,-2'
         dc    i'-3,-1'
         dc    i' 3,-1'
         dc    i'-3, 1'
         dc    i' 3, 1'
         dc    i'-2, 2'
         dc    i' 0, 2'
         dc    i' 2, 2'

Points1f ds    88

Poly     dc    i'10'
         dc    i'1,10,7,2,6,8,3,5,9,4'

matrix   ds    vsize

count    ds    2

         end
