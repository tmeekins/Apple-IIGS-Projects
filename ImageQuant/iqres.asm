RGLOBAL DATA
*****************************************************************
* Genesys created ASM65816 data structures
* Simple Software Systems International, Inc.
* ORCAM.SCG 1.2
*
*
* ICON DEFINITIONS
*

ProIcon ANOP
           DC       I2'$8000' ; iconType
           DC       I2'169' ; iconSize
           DC       I2'13,26' ; iconHeight and Width
           DC       H'FEEEEEEEEEEEEEEEEEEEEEEE'
           DC       H'EFEEEEEEEEEEEEEEEEEEEEEE'
           DC       H'EEEEEEEEEEE1D1D1DEE44444'
           DC       H'EEEEEEEEEEEEEEEEEEEE4444'
           DC       H'4444EEEEEEEEEE1D1D1DEE44'
           DC       H'EEE444EEEEEEEEEEEEEEEEE4'
           DC       H'44EEE444EEEEEEEEE1D1D1DE'
           DC       H'E44EEE444EEEEEEEEEEEEEEE'
           DC       H'EE44444444EEEEEEEEEE1D1D'
           DC       H'1DEE444444EEEEEEEEEEEEEE'
           DC       H'EEEEE444EEEEEEEEEEEEEEEE'
           DC       H'EEEEEE444EEEEEEEEEEEEEEE'
           DC       H'EEEEEEEEEEEEEEEEEEEEEEEE'
           DC       H'FEEEEEEEEEEEEEEEEEEEEEEE'
           DC       H'EF'
* END ProIcon IMAGE
           DC       H'011111111111111111111111'
           DC       H'101111111111111111111111'
           DC       H'11111111111E2E2E211BBBBB'
           DC       H'11111111111111111111BBBB'
           DC       H'BBBB1111111111E2E2E211BB'
           DC       H'111BBB11111111111111111B'
           DC       H'BB111BBB111111111E2E2E21'
           DC       H'1BB111BBB111111111111111'
           DC       H'11BBBBBBBB1111111111E2E2'
           DC       H'E211BBBBBB11111111111111'
           DC       H'11111BBB1111111111111111'
           DC       H'111111BBB111111111111111'
           DC       H'111111111111111111111111'
           DC       H'011111111111111111111111'
           DC       H'10'
* END ProIcon MASK
*
* CONTROL LIST DEFINITIONS
*

ControlList ANOP
           DC I4'LoadControl' ; control 1
           DC I4'ConvertControl' ; control 2
           DC I4'QuantControl' ; control 3
           DC I4'DitherControl' ; control 4
           DC I4'SaveControl' ; control 5
           DC I4'LoadButton' ; control 6
           DC I4'ConvertButton' ; control 7
           DC I4'SaveButton' ; control 8
           DC I4'ViewButton' ; control 9
           DC I4'QuitButton' ; control 10
           DC I4'TitleControl' ; control 11
           DC I4'0' ; end of control list

IntroCtlList ANOP
           DC I4'IntroTextControl' ; control 1
           DC I4'IntroProButton' ; control 2
           DC I4'0' ; end of control list
*
* CONTROL TEMPLATES
*

LoadControl ANOP
           DC I2'10' ; pCount
           DC I4'$1' ; ID (1)
           DC I2'48,44,0,0' ; rect
           DC I4'$87000000' ; popup
           DC I2'$0042' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I2'0' ; title width
           DC I4'LoadMenu' ; menu ref
           DC I2'1' ; initial value
           DC I4'0' ; no ctlColorTable

ConvertControl ANOP
           DC I2'10' ; pCount
           DC I4'$2' ; ID (2)
           DC I2'66,36,0,0' ; rect
           DC I4'$87000000' ; popup
           DC I2'$0042' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I2'0' ; title width
           DC I4'ConvertMenu' ; menu ref
           DC I2'2' ; initial value
           DC I4'0' ; no ctlColorTable

QuantControl ANOP
           DC I2'10' ; pCount
           DC I4'$3' ; ID (3)
           DC I2'85,20,0,0' ; rect
           DC I4'$87000000' ; popup
           DC I2'$0042' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I2'0' ; title width
           DC I4'QuantMenu' ; menu ref
           DC I2'266' ; initial value
           DC I4'0' ; no ctlColorTable

DitherControl ANOP
           DC I2'10' ; pCount
           DC I4'$4' ; ID (4)
           DC I2'104,44,0,0' ; rect
           DC I4'$87000000' ; popup
           DC I2'$0042' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I2'0' ; title width
           DC I4'DitherMenu' ; menu ref
           DC I2'271' ; initial value
           DC I4'0' ; no ctlColorTable

SaveControl ANOP
           DC I2'10' ; pCount
           DC I4'$5' ; ID (5)
           DC I2'123,42,0,0' ; rect
           DC I4'$87000000' ; popup
           DC I2'$0042' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I2'0' ; title width
           DC I4'SaveMenu' ; menu ref
           DC I2'279' ; initial value
           DC I4'0' ; no ctlColorTable

LoadButton ANOP
           DC I2'9' ; pCount
           DC I4'$6' ; ID (6)
           DC I2'142,12,155,102' ; rect
           DC I4'$80000000' ; simple button
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_0000011D' ; title
           DC I4'0' ; no ctlColorTable
           DC H'4C6C',I2'$0000,$0000' ; keyEquivalent

ConvertButton ANOP
           DC I2'9' ; pCount
           DC I4'$7' ; ID (7)
           DC I2'142,124,155,214' ; rect
           DC I4'$80000000' ; simple button
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_0000011E' ; title
           DC I4'0' ; no ctlColorTable
           DC H'4363',I2'$0000,$0000' ; keyEquivalent

SaveButton ANOP
           DC I2'9' ; pCount
           DC I4'$8' ; ID (8)
           DC I2'142,240,155,330' ; rect
           DC I4'$80000000' ; simple button
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_0000011F' ; title
           DC I4'0' ; no ctlColorTable
           DC H'5373',I2'$0000,$0000' ; keyEquivalent

ViewButton ANOP
           DC I2'9' ; pCount
           DC I4'$9' ; ID (9)
           DC I2'142,356,155,446' ; rect
           DC I4'$80000000' ; simple button
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_00000120' ; title
           DC I4'0' ; no ctlColorTable
           DC H'5676',I2'$0000,$0000' ; keyEquivalent

QuitButton ANOP
           DC I2'9' ; pCount
           DC I4'$A' ; ID (10)
           DC I2'142,472,155,562' ; rect
           DC I4'$80000000' ; simple button
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_00000121' ; title
           DC I4'0' ; no ctlColorTable
           DC H'5171',I2'$0000,$0000' ; keyEquivalent

TitleControl ANOP
           DC I2'9' ; pCount
           DC I4'$B' ; ID (11)
           DC I2'2,6,44,307' ; rect
           DC I4'$81000000' ; static text
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'TitleLEBox' ; text reference
           DC I2'TitleLEBox_CNT' ; text size
           DC I2'0' ; justification

IntroTextControl ANOP
           DC I2'9' ; pCount
           DC I4'$C' ; ID (12)
           DC I2'2,20,131,517' ; rect
           DC I4'$81000000' ; static text
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'IntroLEBox' ; text reference
           DC I2'IntroLEBox_CNT' ; text size
           DC I2'0' ; justification

IntroProButton ANOP
           DC I2'10' ; pCount
           DC I4'$D' ; ID (13)
           DC I2'142,234,161,298' ; rect
           DC I4'$07FF0001' ; icon control
           DC I2'$0001' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'ProIcon' ; icon
           DC I4'0' ; title
           DC I4'0' ; no ctlColorTable
           DC I2'0' ; displayMode

PSTR_00000001 ANOP
           DC I1'11'
           DC C'Load Type: '

PSTR_00000002 ANOP
           DC I1'13'
           DC C'Raw 24 (word)'

PSTR_00000003 ANOP
           DC I1'12'
           DC C'Convert To: '

PSTR_00000004 ANOP
           DC I1'10'
           DC C'3200 Color'

PSTR_00000107 ANOP
           DC I1'3'
           DC C'GIF'

PSTR_00000108 ANOP
           DC I1'7'
           DC C'320 B/W'

PSTR_00000109 ANOP
           DC I1'9'
           DC C'320 Color'

PSTR_0000010A ANOP
           DC I1'14'
           DC C'Quantization: '

PSTR_0000010B ANOP
           DC I1'7'
           DC C'OctTree'

PSTR_0000010C ANOP
           DC I1'14'
           DC C'Variance-Based'

PSTR_0000010D ANOP
           DC I1'15'
           DC C'Sierchio Method'

PSTR_0000010E ANOP
           DC I1'9'
           DC C'Wu Method'

PSTR_0000010F ANOP
           DC I1'10'
           DC C'Median-Cut'

PSTR_00000110 ANOP
           DC I1'11'
           DC C'Dithering: '

PSTR_00000111 ANOP
           DC I1'4'
           DC C'None'

PSTR_00000112 ANOP
           DC I1'9'
           DC C'Ordered-2'

PSTR_00000113 ANOP
           DC I1'9'
           DC C'Ordered-4'

PSTR_00000114 ANOP
           DC I1'17'
           DC C'Error Diffusion 1'

PSTR_00000115 ANOP
           DC I1'17'
           DC C'Error Diffusion 2'

PSTR_00000116 ANOP
           DC I1'13'
           DC C'Dot Diffusion'

PSTR_00000117 ANOP
           DC I1'13'
           DC C'Hilbert Space'

PSTR_00000118 ANOP
           DC I1'11'
           DC C'Peano Space'

PSTR_00000119 ANOP
           DC I1'11'
           DC C'Save Type: '

PSTR_0000011A ANOP
           DC I1'20'
           DC C'$C1/0000 Raw 320 SHR'

PSTR_0000011B ANOP
           DC I1'17'
           DC C'$C1/0002 Raw 3200'

PSTR_0000011C ANOP
           DC I1'24'
           DC C'$C0/0002 Apple Preferred'

PSTR_0000011D ANOP
           DC I1'4'
           DC C'Load'

PSTR_0000011E ANOP
           DC I1'7'
           DC C'Convert'

PSTR_0000011F ANOP
           DC I1'4'
           DC C'Save'

PSTR_00000120 ANOP
           DC I1'4'
           DC C'View'

PSTR_00000121 ANOP
           DC I1'4'
           DC C'Quit'

PSTR_00000122 ANOP
           DC I1'10'
           DC C'PPM Format'

PSTR_00000123 ANOP
           DC I1'13'
           DC C'AST/Visionary'
*
* MENU DEFINITIONS
*

LoadMenu ANOP
           DC I2'0' ; menu template version
           DC I2'1' ; menu ID
           DC I2'$0000' ; menu flag
           DC I4'PSTR_00000001' ; title
           DC I4'Row24wItem' ; menu 1
           DC I4'Row24LItem' ; menu 2
           DC I4'PPMItem' ; menu 3
           DC I4'ASTItem' ; menu 4
           DC I4'0' ; end of menuItem list

ConvertMenu ANOP
           DC I2'0' ; menu template version
           DC I2'2' ; menu ID
           DC I2'$0000' ; menu flag
           DC I4'PSTR_00000003' ; title
           DC I4'BW320Item' ; menu 1
           DC I4'Color320Item' ; menu 2
           DC I4'Item3200' ; menu 3
           DC I4'0' ; end of menuItem list

QuantMenu ANOP
           DC I2'0' ; menu template version
           DC I2'3' ; menu ID
           DC I2'$0000' ; menu flag
           DC I4'PSTR_0000010A' ; title
           DC I4'OctreeItem' ; menu 1
           DC I4'VarQuantItem' ; menu 2
           DC I4'SierchioItem' ; menu 3
           DC I4'WuItem' ; menu 4
           DC I4'MedianCutItem' ; menu 5
           DC I4'0' ; end of menuItem list

DitherMenu ANOP
           DC I2'0' ; menu template version
           DC I2'4' ; menu ID
           DC I2'$0000' ; menu flag
           DC I4'PSTR_00000110' ; title
           DC I4'NoneItem' ; menu 1
           DC I4'Order2Item' ; menu 2
           DC I4'Order4Item' ; menu 3
           DC I4'Floyd1Item' ; menu 4
           DC I4'Floyd2Item' ; menu 5
           DC I4'DotDiffItem' ; menu 6
           DC I4'HilbertItem' ; menu 7
           DC I4'PeanoItem' ; menu 8
           DC I4'0' ; end of menuItem list

SaveMenu ANOP
           DC I2'0' ; menu template version
           DC I2'5' ; menu ID
           DC I2'$0000' ; menu flag
           DC I4'PSTR_00000119' ; title
           DC I4'c10000Item' ; menu 1
           DC I4'c10002Item' ; menu 2
           DC I4'c00002Item' ; menu 3
           DC I4'0' ; end of menuItem list
*
* MENU ITEM DEFINITION
*

Row24wItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'1' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000002' ; menu

Item3200 ANOP
           DC I2'0' ; menuitem template version
           DC I2'2' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000004' ; menu

Row24LItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'263' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000107' ; menu

BW320Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'264' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000108' ; menu

Color320Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'265' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000109' ; menu

OctreeItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'266' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_0000010B' ; menu

VarQuantItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'267' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_0000010C' ; menu

SierchioItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'268' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_0000010D' ; menu

WuItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'269' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_0000010E' ; menu

MedianCutItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'270' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_0000010F' ; menu

NoneItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'271' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000111' ; menu

Order2Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'272' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000112' ; menu

Order4Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'273' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000113' ; menu

Floyd1Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'274' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000114' ; menu

Floyd2Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'275' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000115' ; menu

DotDiffItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'276' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000116' ; menu

HilbertItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'277' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000117' ; menu

PeanoItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'278' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000118' ; menu

c10000Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'279' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_0000011A' ; menu

c10002Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'280' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_0000011B' ; menu

c00002Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'281' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_0000011C' ; menu

PPMItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'282' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000122' ; menu

ASTItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'283' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000123' ; menu

TitleLEBox ANOP
           DC I1'$01'
           DC C'J'
           DC I1'$01'
           DC I1'$00'
           DC I1'$01'
           DC C'L'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'R'
           DC I1'$04'
           DC I1'$00'
           DC I1'$01'
           DC C'F'
           DC I1'$16'
           DC I1'$00'
           DC I1'$05'
           DC I1'$18'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'
           DC C'ImageQuant'
           DC I1'$01'
           DC C'F'
           DC I1'$14'
           DC I1'$00'
           DC I1'$02'
           DC I1'$0C'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'
           DC I1'$0D'
           DC C'by Tim Meekins'

TitleLEBox_CNT GEQU 65

IntroLEBox ANOP
           DC I1'$01'
           DC C'J'
           DC I1'$01'
           DC I1'$00'
           DC I1'$01'
           DC C'L'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'R'
           DC I1'$04'
           DC I1'$00'
           DC I1'$01'
           DC C'F'
           DC I1'$FE'
           DC I1'$FF'
           DC I1'$01'
           DC I1'$10'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'
           DC C'ImageQuant'
           DC I1'$AA'
           DC C' 1.0d'
           DC I1'$0D'
           DC I1'$01'
           DC C'F'
           DC I1'$16'
           DC I1'$00'
           DC I1'$00'
           DC I1'$0C'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'
           DC C'version 2/23/93'
           DC I1'$0D'
           DC I1'$01'
           DC C'F'
           DC I1'$14'
           DC I1'$00'
           DC I1'$02'
           DC I1'$0C'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'
           DC C'Written by Tim Meekins'
           DC I1'$0D'
           DC C'Copyright '
           DC I1'$A9'
           DC C' 1993 by Tim Meekins'
           DC I1'$0D'
           DC I1'$0D'
           DC I1'$01'
           DC C'F'
           DC I1'$16'
           DC I1'$00'
           DC I1'$00'
           DC I1'$0C'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'
           DC C'This is a development version of ImageQuant and '
           DC C'is not Guaranteed in any way. This is a fully co'
           DC C'pyrighted work and cannot be duplicated, copied,'
           DC C' or given out without permission of the author o'
           DC C'r Procyon, Inc. All rights reserved.'
           DC I1'$01'
           DC C'F'
           DC I1'$FE'
           DC I1'$FF'
           DC I1'$01'
           DC I1'$10'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'

IntroLEBox_CNT GEQU 403
*
* WINDOW DEFINITION
*

IntroWindow ANOP
           DC I2'$50' ; template size
           DC I2'$00A0' ; frame bits
           DC I4'0' ; no title
           DC I4'0' ; window refcon
           DC I2'0,0,0,0' ; zoom rectangle
           DC I4'0' ; standard colors
           DC I2'0,0' ; origin y/x
           DC I2'0,0' ; data height/width
           DC I2'0,0' ; max height/width
           DC I2'0,0' ; scroll vert/horiz
           DC I2'0,0' ; page vert/horiz
           DC I4'0' ; info refcon
           DC I2'0' ; info height
           DC I4'0' ; frame defproc
           DC I4'0' ; info defproc
           DC I4'0' ; content defproc
           DC I2'25,52,188,586' ; position
           DC I4'-1' ; plane
           DC I4'IntroCtlList' ; control reference
           DC I2'3' ; indescref

IQWindow ANOP
           DC I2'$50' ; template size
           DC I2'$20A0' ; frame bits
           DC I4'0' ; no title
           DC I4'0' ; window refcon
           DC I2'0,0,0,0' ; zoom rectangle
           DC I4'0' ; standard colors
           DC I2'0,0' ; origin y/x
           DC I2'0,0' ; data height/width
           DC I2'0,0' ; max height/width
           DC I2'0,0' ; scroll vert/horiz
           DC I2'0,0' ; page vert/horiz
           DC I4'0' ; info refcon
           DC I2'0' ; info height
           DC I4'0' ; frame defproc
           DC I4'0' ; info defproc
           DC I4'0' ; content defproc
           DC I2'27,30,186,608' ; position
           DC I4'-1' ; plane
           DC I4'ControlList' ; control reference
           DC I2'3' ; indescref
*
* TOOL STARTUP
*
ToolTable ANOP
           DC I2'$0000' ; flags
           DC I2'$C080' ; videoMode
           DS 6 ; resFileID & dPageHandle are set by the StartUpTools call
           DC I2'17' ; numTools
           DC I2'2,$0300' ; Memory Manager
           DC I2'3,$0300' ; Miscellaneous Tools
           DC I2'4,$0301' ; QuickDraw II
           DC I2'5,$0302' ; Desk Manager
           DC I2'6,$0300' ; Event Manager
           DC I2'11,$0200' ; Integer Math
           DC I2'14,$0301' ; Window Manager
           DC I2'15,$0301' ; Menu Manager
           DC I2'16,$0301' ; Control Manager
           DC I2'18,$0301' ; QuickDraw II Aux.
           DC I2'20,$0301' ; LineEdit Tools
           DC I2'21,$0301' ; Dialog Manager
           DC I2'22,$0300' ; Scrap Manager
           DC I2'23,$0301' ; Standard File Tools
           DC I2'27,$0301' ; Font Manager
           DC I2'28,$0301' ; List Manager
           DC I2'30,$0100' ; Resource Manager

           END ; RGLOBAL data
**************
