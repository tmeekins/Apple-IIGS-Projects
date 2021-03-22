**********************************************************************
*
* Get the name of directory we're in
*
**********************************************************************

GetCurDir      start

               longa on
               longi on

               GetPrefix GPParms

               sep   #$20
               longa off

               stz   Length
               ldx   PathName
               dex
Loop           lda   PathName+1,x
               cmp   #'.'
               beq   Good
               cmp   #'0'
               bcc   Done
               cmp   #'9'+1
               bcc   Good
               cmp   #'A'
               bcc   Done
               cmp   #'Z'+1
               bcc   Good
               cmp   #'a'
               bcc   Done
               cmp   #'z'+1
               bcs   Done
Good           inc   Length
               dex
               bne   Loop
Done           stx   Start
               lda   Length
               sta   PathName+1,x

               rep   #$20
               longa on

               clc
               lda   #PathName+1
               adc   Start

               rts

Length         ds    1
Start          ds    2

*
* GetPrefix parameters
*
GPParms        dc    i2'2'
               dc    i2'0'
               dc    i4'PathBuff'
*
* Buffer to hold the path name
*
               dc    c'Here it is'
PathBuff       dc    i2'78'
PathName       ds    78

               end
