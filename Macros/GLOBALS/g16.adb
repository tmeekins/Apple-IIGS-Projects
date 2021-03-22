**************************************************************************
*                                                                        *
* Apple Desktop Bus Tool Set                                             *
* Global constants, data structures and error codes                      *
* by Tim Meekins                                                         *
* November 4, 1988                                                       *
*                                                                        *
* v1.0  11/04/88 Original version. Using ADB Tool Set v1.1               *
* v1.1  11/11/88 Updated to ADB Tool Set v2.1                            *
*                                                                        *
**************************************************************************
*                                                                        *
*                    ZAVTRA MACRO UTILITIES DISK                         *
*                   Copyright 1990 by Tim Meekins                        *
*                        All Rights Reserved                             *
*                                                                        *
*                   THIS PRODUCT IS SHAREWARE!!                          *
*   If you find yourself using this product extensively, please take the *
*   time and send several dollars to the author to compensate for the    *
*   many hours spent developing this product for your use. Support of    *
*   this product will help in the development of future products.        *
*                                                                        *
**************************************************************************

*
* ReadKeyMicroData ADB commands
*
readModes      gequ  $a
readConfig     gequ  $b
readADBError   gequ  $c
readVersionNum gequ  $d
readAvailCharSet gequ $e
readAvailLayout gequ $f
*
* ReadKeyMicroMEM ADB command
*
readMicroMem   gequ  $9
*
* SendInfo ADB commands
*
abort          gequ  $01
resetKbd       gequ  $02
flushKbd       gequ  $03
setModes       gequ  $04
clearModes     gequ  $05
setConfig      gequ  $06
synch          gequ  $07
writeMicroMem  gequ  $08
resetSys       gequ  $10
keyCode        gequ  $11
resetADB       gequ  $40
transmitADBBytes gequ $47
enableSRQ      gequ  $50
flushADBDevBuf gequ  $60
disableSRQ     gequ  $70
transmit2ADBBytes gequ $80
listen         gequ  $80
talk           gequ  $c0
*
* ReadConfigRec
*  - configuration record for ReadKeyMicroData
*
oRCRepeatDelay gequ  0
oRCLayoutOrLang gequ  1
oRCADBAddr     gequ  2
*
* SetConfigRec
*  - configuration record for SendInfo
*
oSCADBAddr     gequ  0
oSCLayoutOrLang gequ  1
oSCRepeatDelay gequ  2
*
* SynchRec
*  - record for SendInfo
*
oSynchMode     gequ  0
oSynchKybdMouseAddr gequ 1
oSynchLayoutOrLang gequ 2
oSynchRepeatDelay gequ 3
*
* ScaleRec
*  - scale record
*
oXDivide       gequ  0
oYDivide       gequ  2
oXOffset       gequ  4
oYOffset       gequ  6
oXMultiply     gequ  8
oYMultiply     gequ  10
*
* Apple Desktop Bus Tool Set error codes
*
cmndIncomplete gequ  $0910
cantSync       gequ  $0911
adbBusy        gequ  $0982
devNotAtAddr   gequ  $0983
srqListFull    gequ  $0984
