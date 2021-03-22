**********************************************************************
*
* Various data tables.
*
**********************************************************************

Tables         data

*
* Palette definitions for 640 mode resolution.
*
Pal640         dc    h'00 00 00 0F F0 00 FF 0F 00 00 0F 00 F0 0F FF 0F'
               dc    h'00 00 00 0F F0 00 FF 0F 00 00 0F 00 F0 0F FF 0F'
*
* Scanline address for character vertical positions
*
CharYTable     anop
               lcla  &n1
&n1            seta  $2000
.loop1
               dc    i2'&n1'
&n1            seta  &n1+1280
               aif   &n1<$9D00,^loop1

               end

**********************************************************************
*
* Global variables.
*
**********************************************************************

Global         data

UserID         ds    2                  ;User ID
CurPrefix      ds    2                  ;Current prefix

CmdLen         ds    1
CmdLine        ds    255

               end
