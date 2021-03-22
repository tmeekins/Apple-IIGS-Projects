;
; Z3D Direct Page variables
;
linecachelen	gequ	$6B
linesave	gequ	$6D
curline	gequ	$6F
oldline	gequ	$71
ColorFFFF	gequ	$73
Color00F0	gequ	$75
Color00FF	gequ	$77
ColorF0FF	gequ	$79
Color000F	gequ	$7B
ColorF00F	gequ	$7D
ColorFF0F	gequ	$7F
matrix	gequ	$81
trbptr	gequ	$B1
Index1         gequ  $B5
Index2         gequ  $B6
Index3         gequ  $B7
Index4         gequ  $B8
Index5         gequ  $B9
Count          gequ  $BA
Divisor        gequ  $BC
cox            gequ  $BE
coy            gequ  $C0
Arg1           gequ  $C2
Arg2           gequ  $C6
ScaleX         gequ  $CA
ScaleY         gequ  $CE
ScaleZ         gequ  $D2
PerspD         gequ  $D6
Quotient       gequ  $D8
Result         gequ  $DA
EdgePtr        gequ  $E0
tptr           gequ  $E2
DX             gequ  $E4
DY             gequ  $E6
UT            	gequ  $E8
C1           	gequ  $EA
C2           	gequ  $EC
L1         	gequ  $EE
L2         	gequ  $F0
sin            gequ  $F2
cos            gequ  $F6
PntPtr         gequ  $FA
;MatPtr         gequ  $FC
ObjPtr         gequ  $FE

***************************************************************************
*                                                                         *
* Point data structure                                                    *
*                                                                         *
*  flag:     FF = end of list                                             *
*  ox,oy,oz: object space coordinate (2-byte integer)                     *
*  wx,wy,wz: world space coordinate                                       *
*                                                                         *
***************************************************************************

pntflag        gequ  0
pntox          gequ  1
pntoy          gequ  3
pntoz          gequ  5
pntwx          gequ  7
pntwy          gequ  10
pntwz          gequ  13
pntsize        gequ  16

***************************************************************************
*                                                                         *
* matrix indexing                                                         *
*                                                                         *
*  | m11 m12 m13 |                                                        *
*  | m21 m22 m23 |                                                        *
*  | m31 m32 m33 |                                                        *
*  | m41 m42 m43 |                                                        *
*                                                                         *
***************************************************************************

m11            gequ  0
m21            gequ  4
m31            gequ  8
m41            gequ  12
m12            gequ  16
m22            gequ  20
m32            gequ  24
m42            gequ  28
m13            gequ  32
m23            gequ  36
m33            gequ  40
m43            gequ  44
matsize        gequ  48
