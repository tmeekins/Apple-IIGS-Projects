*********************************************************************
*
* MaXUS Character Set
*
*********************************************************************

;
; This is separate segment so use long addressing!
;
CharSet  DATA  CHARSEG
;
; Since space is first, subtract $20 from ASCII values before calculating
; offset into this table
;
CharData dc    h'00000000'              ;SPACE
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'000F0000'              ;!
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00F0F000'              ;"
         dc    h'00F0F000'
         dc    h'00F0F000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00F00F00'              ;#
         dc    h'00F00F00'
         dc    h'0FFFFFF0'
         dc    h'00F00F00'
         dc    h'0FFFFFF0'
         dc    h'00F00F00'
         dc    h'00F00F00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'000F0000'              ;$
         dc    h'0FFFFF00'
         dc    h'F00F0000'
         dc    h'0FFFFF00'
         dc    h'000F00F0'
         dc    h'0FFFFF00'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'FF0000F0'              ;%
         dc    h'FF000F00'
         dc    h'0000F000'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'0F000FF0'
         dc    h'F0000FF0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00F00000'              ;&
         dc    h'0F0F0000'
         dc    h'0F0F0000'
         dc    h'0FF000F0'
         dc    h'F00F0F00'
         dc    h'F000F000'
         dc    h'0FFF0FF0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0000F000'              ;'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0000F000'              ;(
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'00F00000'
         dc    h'00F00000'
         dc    h'000F0000'
         dc    h'0000F000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00F00000'              ;)
         dc    h'000F0000'
         dc    h'0000F000'
         dc    h'0000F000'
         dc    h'0000F000'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;*
         dc    h'00F00F00'
         dc    h'000FF000'
         dc    h'0FFFFFF0'
         dc    h'000FF000'
         dc    h'00F00F00'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;+
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'0FFFFF00'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;,
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'000FF000'
         dc    h'000FF000'
         dc    h'0000F000'
         dc    h'000F0000'

         dc    h'00000000'              ;-
         dc    h'00000000'
         dc    h'00000000'
         dc    h'0FFFFFF0'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;.
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'000FF000'
         dc    h'000FF000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'000000F0'              ;/
         dc    h'00000F00'
         dc    h'0000F000'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'0F000000'
         dc    h'F0000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFF000'              ;0
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'00FFF000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'000F0000'              ;1
         dc    h'00FF0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'00FFF000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFFF00'              ;2
         dc    h'0F0000F0'
         dc    h'000000F0'
         dc    h'0000FF00'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'0FFFFFF0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFFF00'              ;3
         dc    h'0F0000F0'
         dc    h'000000F0'
         dc    h'000FFF00'
         dc    h'000000F0'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0000FF00'              ;4
         dc    h'000F0F00'
         dc    h'00F00F00'
         dc    h'0F000F00'
         dc    h'0FFFFFF0'
         dc    h'00000F00'
         dc    h'00000F00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0FFFFFF0'              ;5
         dc    h'0F000000'
         dc    h'0FFFFF00'
         dc    h'000000F0'
         dc    h'000000F0'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000F00'              ;6
         dc    h'0000F000'
         dc    h'000F0000'
         dc    h'00FFFF00'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0FFFFFF0'              ;7
         dc    h'000000F0'
         dc    h'00000F00'
         dc    h'0000F000'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'00F00000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFFF00'              ;8
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFFF00'              ;9
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'0000F000'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;:
         dc    h'00000000'
         dc    h'000FF000'
         dc    h'000FF000'
         dc    h'00000000'
         dc    h'000FF000'
         dc    h'000FF000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;;
         dc    h'00000000'
         dc    h'000FF000'
         dc    h'000FF000'
         dc    h'00000000'
         dc    h'000FF000'
         dc    h'000FF000'
         dc    h'0000F000'
         dc    h'000F0000'

         dc    h'00000F00'              ;<
         dc    h'0000F000'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'000F0000'
         dc    h'0000F000'
         dc    h'00000F00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;=
         dc    h'00000000'
         dc    h'FFFFFFF0'
         dc    h'00000000'
         dc    h'FFFFFFF0'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00F00000'              ;>
         dc    h'000F0000'
         dc    h'0000F000'
         dc    h'00000F00'
         dc    h'0000F000'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFFF00'              ;?
         dc    h'0F0000F0'
         dc    h'000000F0'
         dc    h'0000FF00'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFFF00'              ;@
         dc    h'0F0000F0'
         dc    h'000000F0'
         dc    h'000FF0F0'
         dc    h'00F0F0F0'
         dc    h'00F0F0F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'000F0000'              ;A
         dc    h'00F0F000'
         dc    h'0F000F00'
         dc    h'F00000F0'
         dc    h'FFFFFFF0'
         dc    h'F00000F0'
         dc    h'F00000F0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0FFFFF00'              ;B
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0FFFFF00'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0FFFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFFF00'              ;C
         dc    h'0F0000F0'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0FFFF000'              ;D
         dc    h'0F000F00'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F000F00'
         dc    h'0FFFF000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0FFFFFF0'              ;E
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0FFFFF00'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0FFFFFF0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0FFFFFF0'              ;F
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0FFFFF00'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFFF00'              ;G
         dc    h'0F0000F0'
         dc    h'0F000000'
         dc    h'0F00FFF0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0F0000F0'              ;H
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0FFFFFF0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFF000'              ;I
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'00FFF000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0000FFF0'              ;J
         dc    h'00000F00'
         dc    h'00000F00'
         dc    h'00000F00'
         dc    h'00000F00'
         dc    h'0F000F00'
         dc    h'00FFF000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0F0000F0'              ;K
         dc    h'0F000F00'
         dc    h'0F00F000'
         dc    h'0FFF0000'
         dc    h'0F00F000'
         dc    h'0F000F00'
         dc    h'0F0000F0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0F000000'              ;L
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0FFFFFF0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'F00000F0'              ;M
         dc    h'FF000FF0'
         dc    h'F0F0F0F0'
         dc    h'F00F00F0'
         dc    h'F00000F0'
         dc    h'F00000F0'
         dc    h'F00000F0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'F00000F0'              ;N
         dc    h'FF0000F0'
         dc    h'F0F000F0'
         dc    h'F00F00F0'
         dc    h'F000F0F0'
         dc    h'F0000FF0'
         dc    h'F00000F0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFFF00'              ;O
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0FFFFF00'              ;P
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0FFFFF00'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFFF00'              ;Q
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F00F0F0'
         dc    h'0F000F00'
         dc    h'00FFF0F0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0FFFFF00'              ;R
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0FFFFF00'
         dc    h'0F00F000'
         dc    h'0F000F00'
         dc    h'0F0000F0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFFF00'              ;S
         dc    h'0F0000F0'
         dc    h'0F000000'
         dc    h'00FFFF00'
         dc    h'000000F0'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'FFFFFFF0'              ;T
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0F0000F0'              ;U
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'F00000F0'              ;V
         dc    h'F00000F0'
         dc    h'F00000F0'
         dc    h'F00000F0'
         dc    h'0F000F00'
         dc    h'00F0F000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'F00000F0'              ;W
         dc    h'F00000F0'
         dc    h'F00000F0'
         dc    h'F00F00F0'
         dc    h'F00F00F0'
         dc    h'F0F0F0F0'
         dc    h'0F000F00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'F00000F0'              ;X
         dc    h'0F000F00'
         dc    h'00F0F000'
         dc    h'000F0000'
         dc    h'00F0F000'
         dc    h'0F000F00'
         dc    h'F00000F0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'F00000F0'              ;Y
         dc    h'0F000F00'
         dc    h'00F0F000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0FFFFF00'              ;Z
         dc    h'00000F00'
         dc    h'0000F000'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'0F000000'
         dc    h'0FFFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFF000'              ;[
         dc    h'00F00000'
         dc    h'00F00000'
         dc    h'00F00000'
         dc    h'00F00000'
         dc    h'00F00000'
         dc    h'00FFF000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0F000000'              ;\
         dc    h'00F00000'
         dc    h'000F0000'
         dc    h'0000F000'
         dc    h'00000F00'
         dc    h'000000F0'
         dc    h'0000000F'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FFF000'              ;]
         dc    h'0000F000'
         dc    h'0000F000'
         dc    h'0000F000'
         dc    h'0000F000'
         dc    h'0000F000'
         dc    h'00FFF000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'000F0000'              ;^
         dc    h'00F0F000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;_
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'FFFFFFFF'

         dc    h'00F00000'              ;`
         dc    h'000F0000'
         dc    h'0000F000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;a
         dc    h'00000000'
         dc    h'00FFF000'
         dc    h'00000F00'
         dc    h'00FFFF00'
         dc    h'0F000F00'
         dc    h'00FFF0F0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0F000000'              ;b
         dc    h'0F000000'
         dc    h'0FFFFF00'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0FFFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;c
         dc    h'00000000'
         dc    h'00FFFF00'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'000000F0'              ;d
         dc    h'000000F0'
         dc    h'00FFFFF0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'00FFFFF0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;e
         dc    h'00000000'
         dc    h'00FFF000'
         dc    h'0F000F00'
         dc    h'0FFFFF00'
         dc    h'0F000000'
         dc    h'00FFF000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0000FF00'              ;f
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'0FFFFF00'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;g
         dc    h'00000000'
         dc    h'00FFFF00'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'00FFFFF0'
         dc    h'000000F0'
         dc    h'00FFFF00'

         dc    h'0F000000'              ;h
         dc    h'0F000000'
         dc    h'0FFFF000'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'000F0000'              ;i
         dc    h'00000000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0000F000'              ;j
         dc    h'00000000'
         dc    h'0000F000'
         dc    h'0000F000'
         dc    h'0000F000'
         dc    h'0000F000'
         dc    h'0F00F000'
         dc    h'00FF0000'
         dc    h'00000000'

         dc    h'0F000000'              ;k
         dc    h'0F000F00'
         dc    h'0F00F000'
         dc    h'0F0F0000'
         dc    h'0FFF0000'
         dc    h'0F00F000'
         dc    h'0F000F00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FF0000'              ;l
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;m
         dc    h'00000000'
         dc    h'FFFFFF00'
         dc    h'F00F00F0'
         dc    h'F00F00F0'
         dc    h'F00F00F0'
         dc    h'F00F00F0'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;n
         dc    h'00000000'
         dc    h'0FFFF000'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;o
         dc    h'00000000'
         dc    h'00FFFF00'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'0F0000F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;p
         dc    h'00000000'
         dc    h'0FFFF000'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0FFFF000'
         dc    h'0F000000'
         dc    h'0F000000'

         dc    h'00000000'              ;q
         dc    h'00000000'
         dc    h'00FFFF00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'00FFFF00'
         dc    h'00000F00'
         dc    h'00000F00'

         dc    h'00000000'              ;r
         dc    h'00000000'
         dc    h'0FFFF000'
         dc    h'0F000F00'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'0F000000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;s
         dc    h'00000000'
         dc    h'00FFFF00'
         dc    h'0F000000'
         dc    h'00FFFF00'
         dc    h'000000F0'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'000F0000'              ;t
         dc    h'000F0000'
         dc    h'0FFFFF00'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'0000FF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;u
         dc    h'00000000'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'00FFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;v
         dc    h'00000000'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'0F000F00'
         dc    h'00F0F000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;w
         dc    h'00000000'
         dc    h'F00000F0'
         dc    h'F00F00F0'
         dc    h'F00F00F0'
         dc    h'F0F0F0F0'
         dc    h'0F000F00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;x
         dc    h'00000000'
         dc    h'0F000F00'
         dc    h'00F0F000'
         dc    h'000F0000'
         dc    h'00F0F000'
         dc    h'0F000F00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00000000'              ;y
         dc    h'00000000'
         dc    h'0F0000F0'
         dc    h'00F00F00'
         dc    h'000FF000'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'0F000000'
         dc    h'00000000'

         dc    h'00000000'              ;z
         dc    h'00000000'
         dc    h'0FFFFF00'
         dc    h'0000F000'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'0FFFFF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0000FF00'              ;{
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'00F00000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'0000FF00'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'000F0000'              ;|
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'000F0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'00FF0000'              ;}
         dc    h'0000F000'
         dc    h'0000F000'
         dc    h'00000F00'
         dc    h'0000F000'
         dc    h'0000F000'
         dc    h'00FF0000'
         dc    h'00000000'
         dc    h'00000000'

         dc    h'0FF00F00'              ;~
         dc    h'F00FF000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'
         dc    h'00000000'

         end
