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
