****************************************************************
*
* Data
* (& variables)
*
****************************************************************

Global   data

CH       equ   $FE
CV       equ   $FC

InvFlag  dc    i2'0'
UnderFlag dc   i2'0'
MouseTxt dc    i2'0'
CursFlag dc    i2'$FFFF'
UserID   ds    2
SaveHandle ds  4
CHSave   ds    2
CVSave   ds    2
DevName  dc    i1'3',c'.D1 '            ;The last space is required!!
Prefix   ds    96
PathName ds    16

         end
