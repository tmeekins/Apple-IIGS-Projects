

gendata DATA myResource

LSTREF_00000005 equ	0

*****************************************************************
* Genesys created ASM65816 data structures
* Simple Software Systems International, Inc.
* ORCAM.SCG 1.2
*
*
* ICON DEFINITIONS
*

AlarmBoxIcon ANOP
           DC       I2'$0000' ; iconType
           DC       I2'88' ; iconSize
           DC       I2'11,16' ; iconHeight and Width
           DC       H'00000000000000000FFFFFFF'
           DC       H'FFFFFFF00FFFFFFFFFFFFFF0'
           DC       H'0FFFFFFFFFFFFFF00FFFFFFF'
           DC       H'FFFFFFF00FFFFFFFFFFFFFF0'
           DC       H'0FFFFFFFFFFFFFF00FFFFFFF'
           DC       H'FFFFFFF00FFFFFFFFFFFFFF0'
           DC       H'0FFFFFFFFFFFFFF000000000'
           DC       H'00000000'
* END AlarmBoxIcon IMAGE
           DC       H'FFFFFFFFFFFFFFFFF0000000'
           DC       H'0000000FF00000000000000F'
           DC       H'F00000000000000FF0000000'
           DC       H'0000000FF00000000000000F'
           DC       H'F00000000000000FF0000000'
           DC       H'0000000FF00000000000000F'
           DC       H'F00000000000000FFFFFFFFF'
           DC       H'FFFFFFFF'
* END AlarmBoxIcon MASK
*
* CONTROL LIST DEFINITIONS
*

PrefControls ANOP
           DC I4'PreTitleControl' ; control 1
           DC I4'FiftyHzButton' ; control 2
           DC I4'SixtyHzButton' ; control 3
           DC I4'HertzTitleControl' ; control 4
           DC I4'PlayArpBox' ; control 5
           DC I4'UseProBox' ; control 6
           DC I4'StereoMenuControl' ; control 7
           DC I4'PrefOKButton' ; control 8
           DC I4'CTLTMP_00000009' ; control 9
           DC I4'VolMenuControl' ; control 10
           DC I4'0' ; end of control list

InstControls ANOP
           DC I4'InstListCtl' ; control 1
           DC I4'InstLineEdCtl' ; control 2
           DC I4'InstLoadButCtl' ; control 3
           DC I4'InstSaveButCtl' ; control 4
           DC I4'InstCompButCtl' ; control 5
           DC I4'InstEditButCtl' ; control 6
           DC I4'0' ; end of control list

AlarmControls ANOP
           DC I4'AlarmHourScroll' ; control 1
           DC I4'AlarmMinuteScroll' ; control 2
           DC I4'AlarmAMPMScroll' ; control 3
           DC I4'AlarmHourTitleCtrl' ; control 4
           DC I4'AlarmMinuteTitleCtrl' ; control 5
           DC I4'AlarmAMPMTitleCtrl' ; control 6
           DC I4'AlarmActBox' ; control 7
           DC I4'AlarmSelButton' ; control 8
           DC I4'0' ; end of control list
*
* CONTROL TEMPLATES
*

PreTitleControl ANOP
           DC I2'8' ; pCount
           DC I4'$1' ; ID (1)
           DC I2'2,164,15,275' ; rect
           DC I4'$81000000' ; static text
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PrefTitleText' ; text reference
           DC I2'PrefTitleText_CNT' ; text size

FiftyHzButton ANOP
           DC I2'8' ; pCount
           DC I4'$2' ; ID (2)
           DC I2'41,28,50,148' ; rect
           DC I4'$84000000' ; radio control
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_00000001' ; title
           DC I2'1' ; initial value

SixtyHzButton ANOP
           DC I2'8' ; pCount
           DC I4'$3' ; ID (3)
           DC I2'55,28,64,148' ; rect
           DC I4'$84000000' ; radio control
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_00000002' ; title
           DC I2'0' ; initial value

HertzTitleControl ANOP
           DC I2'9' ; pCount
           DC I4'$4' ; ID (4)
           DC I2'24,8,35,113' ; rect
           DC I4'$81000000' ; static text
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'SpeedTitleText' ; text reference
           DC I2'SpeedTitleText_CNT' ; text size
           DC I2'0' ; justification

PlayArpBox ANOP
           DC I2'8' ; pCount
           DC I4'$5' ; ID (5)
           DC I2'4,304,15,444' ; rect
           DC I4'$82000000' ; check control
           DC I2'$0080' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_00000003' ; title
           DC I2'1' ; initial value

UseProBox ANOP
           DC I2'8' ; pCount
           DC I4'$6' ; ID (6)
           DC I2'3,270,14,460' ; rect
           DC I4'$82000000' ; check control
           DC I2'$0080' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_00000004' ; title
           DC I2'1' ; initial value

StereoMenuControl ANOP
           DC I2'10' ; pCount
           DC I4'$7' ; ID (7)
           DC I2'22,206,0,0' ; rect
           DC I4'$87000000' ; popup
           DC I2'$0040' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I2'0' ; title width
           DC I4'StereoMenu' ; menu ref
           DC I2'1' ; initial value
           DC I4'0' ; no ctlColorTable

PrefOKButton ANOP
           DC I2'7' ; pCount
           DC I4'$8' ; ID (8)
           DC I2'72,314,85,404' ; rect
           DC I4'$80000000' ; simple button
           DC I2'$0001' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_0000010B' ; title

CTLTMP_00000009 ANOP
           DC I2'8' ; pCount
           DC I4'$9' ; ID (9)
           DC I2'77,26,88,162' ; rect
           DC I4'$82000000' ; check control
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_0000010C' ; title
           DC I2'1' ; initial value

VolMenuControl ANOP
           DC I2'10' ; pCount
           DC I4'$A' ; ID (10)
           DC I2'40,240,0,0' ; rect
           DC I4'$87000000' ; popup
           DC I2'$0040' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I2'0' ; title width
           DC I4'VolMenu' ; menu ref
           DC I2'267' ; initial value
           DC I4'0' ; no ctlColorTable

InstListCtl ANOP
           DC I2'14' ; pCount
           DC I4'$B' ; ID (11)
           DC I2'8,10,99,270' ; rect
           DC I4'$89000000' ; list control
           DC I2'$0000' ; flag
           DC I2'$1400' ; moreFlags
           DC I4'0' ; refCon
           DC I2'0' ; list size
           DC I2'5' ; list view
           DC I2'2' ; list type
           DC I2'0' ; list start
           DC I4'0' ; list draw
           DC I2'10' ; list mem height
           DC I2'5' ; list mem size
           DC I4'LSTREF_00000005' ; list ref

InstLineEdCtl ANOP
           DC I2'8' ; pCount
           DC I4'$C' ; ID (12)
           DC I2'108,10,121,294' ; rect
           DC I4'$83000000' ; line edit
           DC I2'$0000' ; flag
           DC I2'$7000' ; moreFlags
           DC I4'0' ; refCon
           DC I2'32' ; max size
           DC I4'PSTR_00010006' ; default

InstLoadButCtl ANOP
           DC I2'7' ; pCount
           DC I4'$D' ; ID (13)
           DC I2'9,314,22,426' ; rect
           DC I4'$80000000' ; simple button
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_00010007' ; title

InstSaveButCtl ANOP
           DC I2'7' ; pCount
           DC I4'$E' ; ID (14)
           DC I2'28,314,41,426' ; rect
           DC I4'$80000000' ; simple button
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_00010008' ; title

InstCompButCtl ANOP
           DC I2'7' ; pCount
           DC I4'$F' ; ID (15)
           DC I2'48,314,61,426' ; rect
           DC I4'$80000000' ; simple button
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_00010009' ; title

InstEditButCtl ANOP
           DC I2'7' ; pCount
           DC I4'$10' ; ID (16)
           DC I2'108,314,121,424' ; rect
           DC I4'$80000000' ; simple button
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_0001000A' ; title

AlarmHourScroll ANOP
           DC I2'10' ; pCount
           DC I4'$11' ; ID (17)
           DC I2'10,130,23,330' ; rect
           DC I4'$86000000' ; scroll bar
           DC I2'$001C' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I2'12' ; max size
           DC I2'1' ; view size
           DC I2'0' ; initial value
           DC I4'0' ; no ctlColorTable

AlarmMinuteScroll ANOP
           DC I2'10' ; pCount
           DC I4'$12' ; ID (18)
           DC I2'29,130,42,330' ; rect
           DC I4'$86000000' ; scroll bar
           DC I2'$001C' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I2'60' ; max size
           DC I2'1' ; view size
           DC I2'0' ; initial value
           DC I4'0' ; no ctlColorTable

AlarmAMPMScroll ANOP
           DC I2'10' ; pCount
           DC I4'$13' ; ID (19)
           DC I2'48,130,61,330' ; rect
           DC I4'$86000000' ; scroll bar
           DC I2'$001C' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I2'2' ; max size
           DC I2'1' ; view size
           DC I2'0' ; initial value
           DC I4'0' ; no ctlColorTable

AlarmHourTitleCtrl ANOP
           DC I2'9' ; pCount
           DC I4'$14' ; ID (20)
           DC I2'12,38,23,81' ; rect
           DC I4'$81000000' ; static text
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'HourTitleText' ; text reference
           DC I2'HourTitleText_CNT' ; text size
           DC I2'0' ; justification

AlarmMinuteTitleCtrl ANOP
           DC I2'9' ; pCount
           DC I4'$15' ; ID (21)
           DC I2'31,24,41,79' ; rect
           DC I4'$81000000' ; static text
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'MinuteTitleText' ; text reference
           DC I2'MinuteTitleText_CNT' ; text size
           DC I2'0' ; justification

AlarmAMPMTitleCtrl ANOP
           DC I2'9' ; pCount
           DC I4'$16' ; ID (22)
           DC I2'50,30,59,83' ; rect
           DC I4'$81000000' ; static text
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'AMPMTitleText' ; text reference
           DC I2'AMPMTitleText_CNT' ; text size
           DC I2'0' ; justification

AlarmActBox ANOP
           DC I2'10' ; pCount
           DC I4'$17' ; ID (23)
           DC I2'71,18,81,156' ; rect
           DC I4'$82000000' ; check control
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_0001000C' ; title
           DC I2'0' ; initial value
           DC I4'0' ; no ctlColorTable
           DC H'4161',I2'$0100,$0100' ; keyEquivalent

AlarmSelButton ANOP
           DC I2'9' ; pCount
           DC I4'$18' ; ID (24)
           DC I2'68,174,83,330' ; rect
           DC I4'$80000000' ; simple button
           DC I2'$0000' ; flag
           DC I2'$1000' ; moreFlags
           DC I4'0' ; refCon
           DC I4'PSTR_0001000D' ; title
           DC I4'0' ; no ctlColorTable
           DC H'5373',I2'$0100,$0100' ; keyEquivalent

PSTR_00000001 ANOP
           DC I1'5'
           DC C'50 Hz'

PSTR_00000002 ANOP
           DC I1'5'
           DC C'60 Hz'

PSTR_00000003 ANOP
           DC I1'14'
           DC C'Play Arpeggios'

PSTR_00000004 ANOP
           DC I1'22'
           DC C'Use ProTracker Effects'

PSTR_00000005 ANOP
           DC I1'13'
           DC C'Stereo Mode: '

PSTR_00000006 ANOP
           DC I1'11'
           DC C'Full Stereo'

PSTR_00000107 ANOP
           DC I1'10'
           DC C'75% Stereo'

PSTR_00000108 ANOP
           DC I1'10'
           DC C'50% Stereo'

PSTR_00000109 ANOP
           DC I1'10'
           DC C'25% Stereo'

PSTR_0000010A ANOP
           DC I1'4'
           DC C'Mono'

PSTR_0000010B ANOP
           DC I1'2'
           DC C'OK'

PSTR_0000010C ANOP
           DC I1'14'
           DC C'Dancing Lights'

PSTR_0000010D ANOP
           DC I1'8'
           DC C'Volume: '

PSTR_0000010E ANOP
           DC I1'1'
           DC C'2'

PSTR_0000010F ANOP
           DC I1'1'
           DC C'1'

PSTR_00000110 ANOP
           DC I1'2'
           DC C'10'

PSTR_00000111 ANOP
           DC I1'1'
           DC C'9'

PSTR_00000112 ANOP
           DC I1'1'
           DC C'8'

PSTR_00000113 ANOP
           DC I1'1'
           DC C'7'

PSTR_00000114 ANOP
           DC I1'1'
           DC C'6'

PSTR_00000115 ANOP
           DC I1'1'
           DC C'5'

PSTR_00000116 ANOP
           DC I1'1'
           DC C'4'

PSTR_00000117 ANOP
           DC I1'1'
           DC C'3'

PSTR_00010005 ANOP
           DC I1'13'
           DC C' Instruments '

PSTR_00010006 ANOP
           DC I1'0'
           DC I1'$20'

PSTR_00010007 ANOP
           DC I1'4'
           DC C'Load'

PSTR_00010008 ANOP
           DC I1'4'
           DC C'Save'

PSTR_00010009 ANOP
           DC I1'7'
           DC C'Compact'

PSTR_0001000A ANOP
           DC I1'4'
           DC C'Edit'

PSTR_0001000B ANOP
           DC I1'13'
           DC C' soniqAlarm'
           DC I1'$AA'
           DC C' '

PSTR_0001000C ANOP
           DC I1'14'
           DC C'Activate Alarm'

PSTR_0001000D ANOP
           DC I1'18'
           DC C'Select Alarm Music'
*
* MENU DEFINITIONS
*

StereoMenu ANOP
           DC I2'0' ; menu template version
           DC I2'1' ; menu ID
           DC I2'$0000' ; menu flag
           DC I4'PSTR_00000005' ; title
           DC I4'StereoMonoItem' ; menu 1
           DC I4'Stereo25Item' ; menu 2
           DC I4'Stereo50Item' ; menu 3
           DC I4'Stereo75Item' ; menu 4
           DC I4'StereoFullItem' ; menu 5
           DC I4'0' ; end of menuItem list

VolMenu ANOP
           DC I2'0' ; menu template version
           DC I2'2' ; menu ID
           DC I2'$0000' ; menu flag
           DC I4'PSTR_0000010D' ; title
           DC I4'Vol1Item' ; menu 1
           DC I4'Vol2Item' ; menu 2
           DC I4'Vol3Item' ; menu 3
           DC I4'Vol4Item' ; menu 4
           DC I4'Vol5Item' ; menu 5
           DC I4'Vol6Item' ; menu 6
           DC I4'Vol7Item' ; menu 7
           DC I4'Vol8Item' ; menu 8
           DC I4'Vol9Item' ; menu 9
           DC I4'Vol10Item' ; menu 10
           DC I4'0' ; end of menuItem list
*
* MENU ITEM DEFINITION
*

StereoFullItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'1' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000006' ; menu

Stereo75Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'263' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000107' ; menu

Stereo50Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'264' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000108' ; menu

Stereo25Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'265' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000109' ; menu

StereoMonoItem ANOP
           DC I2'0' ; menuitem template version
           DC I2'266' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_0000010A' ; menu

Vol2Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'267' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_0000010E' ; menu

Vol1Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'268' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_0000010F' ; menu

Vol10Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'269' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000110' ; menu

Vol9Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'270' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000111' ; menu

Vol8Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'271' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000112' ; menu

Vol7Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'272' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000113' ; menu

Vol6Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'273' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000114' ; menu

Vol5Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'274' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000115' ; menu

Vol4Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'275' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000116' ; menu

Vol3Item ANOP
           DC I2'0' ; menuitem template version
           DC I2'276' ; menuitem ID
           DC H'00' ; alternate characters
           DC H'00'
           DC H'0000' ; check character
           DC I2'$0000' ; menubar flag
           DC I4'PSTR_00000117' ; menu

PrefTitleText ANOP
           DC I1'$01'
           DC C'J'
           DC I1'$00'
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
           DC I1'$08'
           DC I1'$08'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'
           DC C'Preferences'

PrefTitleText_CNT GEQU 37

SpeedTitleText ANOP
           DC I1'$01'
           DC C'J'
           DC I1'$00'
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
           DC I1'$00'
           DC I1'$08'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'
           DC C'Default Speed:'

SpeedTitleText_CNT GEQU 40

HourTitleText ANOP
           DC I1'$01'
           DC C'J'
           DC I1'$00'
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
           DC I1'$00'
           DC I1'$08'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'
           DC C'Hour:'

HourTitleText_CNT GEQU 31

MinuteTitleText ANOP
           DC I1'$01'
           DC C'J'
           DC I1'$00'
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
           DC I1'$00'
           DC I1'$08'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'
           DC C'Minute:'

MinuteTitleText_CNT GEQU 33

AMPMTitleText ANOP
           DC I1'$01'
           DC C'J'
           DC I1'$00'
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
           DC I1'$00'
           DC I1'$08'
           DC I1'$01'
           DC C'C'
           DC I1'$00'
           DC I1'$00'
           DC I1'$01'
           DC C'B'
           DC I1'$FF'
           DC I1'$FF'
           DC C'AM/PM:'

AMPMTitleText_CNT GEQU 32
*
* WINDOW DEFINITION
*

AlarmWindow ANOP
           DC I2'$50' ; template size
           DC I2'$C088' ; frame bits
           DC I4'PSTR_0001000B' ; title reference
           DC I4'0' ; window refcon
           DC I2'0,0,0,0' ; zoom rectangle
           DC I4'alarmcolor' ; color table
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
           DC I2'68,144,156,496' ; position
           DC I4'-1' ; plane
           DC I4'AlarmControls' ; control reference
           DC I2'3' ; indescref

InstWindow ANOP
           DC I2'$50' ; template size
           DC I2'$C088' ; frame bits
           DC I4'PSTR_00010005' ; title reference
           DC I4'0' ; window refcon
           DC I2'0,0,0,0' ; zoom rectangle
           DC I4'instcolor' ; color table
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
           DC I2'48,98,177,540' ; position
           DC I4'-1' ; plane
           DC I4'InstControls' ; control reference
           DC I2'3' ; indescref

PrefWindow ANOP
           DC I2'$50' ; template size
           DC I2'$20A0' ; frame bits
           DC I4'0' ; no title
           DC I4'0' ; window refcon
           DC I2'0,0,0,0' ; zoom rectangle
           DC I4'prefcolor' ; color table
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
           DC I2'60,104,153,534' ; position
           DC I4'-1' ; plane
           DC I4'PrefControls' ; control reference
           DC I2'3' ; indescref
*
* WINDOW COLOR TABLE
*

prefcolor ANOP
           DC I2'$0000' ; frame color
           DC I2'$0F0F' ; title color
           DC I2'$0000' ; titlebar color
           DC I2'$F0FF' ; grow color
           DC I2'$00F0' ; info color

instcolor ANOP
           DC I2'$0000' ; frame color
           DC I2'$0F00' ; title color
           DC I2'$020F' ; titlebar color
           DC I2'$F0FF' ; grow color
           DC I2'$00F0' ; info color

alarmcolor ANOP
           DC I2'$0000' ; frame color
           DC I2'$0F00' ; title color
           DC I2'$020F' ; titlebar color
           DC I2'$F0FF' ; grow color
           DC I2'$00F0' ; info color

           END ; RGLOBAL data
**************
