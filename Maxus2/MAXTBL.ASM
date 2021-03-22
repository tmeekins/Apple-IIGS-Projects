*********************************************************************
*
* MaXUS
* Commonly used data tables
*
*********************************************************************


*****************************************
*
* Palettes
*
*****************************************

PalDat   data

ShipPal  dc h'0000550577079909BB0BDD0DFF0F000C0009000FE000DF04AF0D55059909FF0F'
LogoPal  dc h'0000050041082C070F000006700F000D6106F00FE000DF04AF0D8F07CC0CFF0F'
StatPal  dc h'000022024404660688089909BB0BF00F000BF20BB20865054304000D0008FF0F'
BlackPal dc h'0000000000000000000000000000000000000000000000000000000000000000'

         end

******************************************
*
* Tables used by SmoothFade
*
******************************************

FadeDat        data

hue            dc    i'$001,$010,$100'  ;Hue value mask
addtbl         ds    16*16*2            ;proportion to add for each color
subtbl         ds    16*16*2            ;"   "         sub   "     "
prop0          dc    i'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'        ;init proportion
prop1          dc    i'0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0'        ;table
prop2          dc    i'0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0'
prop3          dc    i'0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0'
prop4          dc    i'0,0,1,0,0,1,0,0,0,1,0,0,1,0,0,0'
prop5          dc    i'0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0'
prop6          dc    i'0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0'
prop7          dc    i'0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0'
prop8          dc    i'1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0'
prop9          dc    i'1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,0'
prop10         dc    i'1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,0'
prop11         dc    i'1,1,0,1,1,0,1,1,1,0,1,1,0,1,1,0'
prop12         dc    i'1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0'
prop13         dc    i'1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,0'
prop14         dc    i'1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0'
prop15         dc    i'1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0'

               end

************************************************************************
*
* TEXTDATA
*  - Text messages
*
************************************************************************

TextData       data

StoryText      dc    i1'4,50'
               dc    i1'3,32',c'Welcome to MaXUS Demo II',i1'2'
               dc    i1'3,36',c'Written by Tim Meekins',i1'2'
               dc    i1'3,44',c'Copyright (c) 1990',i1'2,2,2'
               dc    i1'3,0',c'MaXUS Demo II  is  a  FREEWARE  product.',i1'2'
               dc    i1'3,0',c'This means that you may freely copy this',i1'2'
               dc    i1'3,0',c'but you  CANNOT use this  program or any',i1'2'
               dc    i1'3,0',c'part of it for any other use without the',i1'2'
               dc    i1'3,0',c'consent of the author.',i1'2,2'
               dc    i1'3,26',c'[PRESS ANY KEY TO CONTINUE]',i1'1'

               dc    i1'4,20'
               dc    i1'3,56',c'INTRODUCTION',i1'2,2'
               dc    i1'3,0',c'This series of MaXUS demos is the result',i1'2'
               dc    i1'3,0',c'of attempting to  write a graphics  game',i1'2'
               dc    i1'3,0',c'for the Apple IIgs.  I am  writing  each',i1'2'
               dc    i1'3,0',c'section  of the  game one at a time as a',i1'2'
               dc    i1'3,0',c'method of creating the game.  Even if no',i1'2'
               dc    i1'3,0',c'game is created  directly as a result of',i1'2'
               dc    i1'3,0',c'these  demos,  it  was  well  worth  the',i1'2'
               dc    i1'3,0',c'effort.',i1'2,2'
               dc    i1'3,26',c'[PRESS ANY KEY TO CONTINUE]',i1'1'

               dc    i1'4,20'
               dc    i1'3,50',c'ABOUT THIS DEMO',i1'2,2'
               dc    i1'3,0',c'The main goal of this  first demo was to',i1'2'
               dc    i1'3,0',c'create the  environment for the game and',i1'2'
               dc    i1'3,0',c'to generate an  interrupt  driven moving',i1'2'
               dc    i1'3,0',c'star field.  Other minor goals included:',i1'2,2'
               dc    i1'3,0',c' o Overlapping items on the screen.',i1'2'
               dc    i1'3,0',c' o Smooth fading of overlapping objects.',i1'2'
               dc    i1'3,0',c' o A simple text generator.',i1'2,2,2'
               dc    i1'3,26',c'[PRESS ANY KEY TO CONTINUE]',i1'1'

               dc    i1'4,20'
               dc    i1'3,60',c'THE FUTURE',i1'2,2'
               dc    i1'3,0',c'Watch for  future demos as I continue to',i1'2'
               dc    i1'3,0',c'learn and develop new algorithms. A full',i1'2'
               dc    i1'3,0',c'featured  game may even be released at a',i1'2'
               dc    i1'3,0',c'later date.',i1'2,2'
               dc    i1'3,0',c'For further information:',i1'2'
               dc    i1'3,0',c'   Tim Meekins',i1'2'
               dc    i1'3,0',c'   8372 Morris Rd.',i1'2'
               dc    i1'3,0',c'   Hilliard, OH 43026',i1'2,2'
               dc    i1'3,0',c'   meekins@ohio-state.edu',i1'1'

               dc    i1'0'

               end

************************************************************************
*
* SCANLINE
*  - Addresses for scanlines
*
************************************************************************

Scanline       data
;
; Scanline address table
;
SLTbl          anop
               lcla  &n1
&n1            seta  0
.loop
               dc    i'&n1*160'
&n1            seta  &n1+1
               aif   &n1<200,^loop

               end
