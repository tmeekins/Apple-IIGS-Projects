****************************************************************
*
* Graphics Tables and data
*
****************************************************************

Tables   DATA
*
* Address of scan lines
*
SLAdr    anop
         lcla  &n1
&n1      seta  8192
.loop1
         dc    i'&n1'
&n1      seta  &n1+160
         aif   &n1<40448,^loop1
*
* Color table
*
Pal640   dc    h'00 00 00 0F F0 00 FF 0F 00 00 0F 00 F0 0F FF 0F'
         dc    h'00 00 00 0F F0 00 FF 0F 00 00 0F 00 F0 0F FF 0F'


         END
