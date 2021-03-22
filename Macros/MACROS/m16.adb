**************************************************************************
*                                                                        *
* Apple Desktop Bus Tool Set macros                                      *
* Written by Tim Meekins                                                 *
* November 4, 1988                                                       *
*                                                                        *
* Requires: M16.MACROS                                                   *
*                                                                        *
* V1.0  11/04/88 TLM Original version. Using ADB Tool Set v1.1           *
* v1.1  11/05/88 TLM Now uses Tool macro                                 *
* v1.2  11/11/88 TLM Updated to ADB Tool Set v2.1                        *
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

               macro
&lab           ADBBootInit
&lab           Tool  $0109
               mend

               macro
&lab           ADBStartUp
&lab           Tool  $0209
               mend

               macro
&lab           ADBShutDown
&lab           Tool  $0309
               mend

               macro
&lab           ADBVersion &a1
&lab           pha
               Tool  $0409
               pl2   &a1
               mend

               macro
&lab           ADBReset
&lab           Tool  $0509
               mend

               macro
&lab           ADBStatus &a1
&lab           pha
               Tool  $0609
               pl2   &a1
               mend

               macro
&lab           SendInfo &a1
&lab           ph2   &a1(1)
               ph4   &a1(2)
               ph2   &a1(3)
               Tool  $0909
               mend

               macro
&lab           ReadKeyMicroData &a1
&lab           ph2   &a1(1)
               ph4   &a1(2)
               ph2   &a1(3)
               Tool  $0a09
               mend

               macro
&lab           ReadKeyMicroMemory &a1
&lab           ph4   &a1(1)
               ph4   &a1(2)
               ph2   &a1(3)
               Tool  $0b09
               mend

               macro
&lab           AsyncADBReceive &a1
&lab           ph4   &a1(1)
               ph2   &a1(2)
               Tool  $0d09
               mend

               macro
&lab           SyncADBReceive &a1
&lab           ph2   &a1(1)
               ph4   &a1(2)
               ph2   &a1(3)
               Tool  $0e09
               mend

               macro
&lab           AbsOn
&lab           Tool  $0f09
               mend

               macro
&lab           AbsOff
&lab           Tool  $1009
               mend

               macro
&lab           ReadAbs &a1
&lab           pha
               Tool  $1109
               pl2   &a1
               mend

               macro
&lab           SetAbsScale &a1
&lab           ph4   &a1
               Tool  $1209
               mend

               macro
&lab           GetAbsScale &a1
&lab           ph4   &a1
               Tool  $1309
               mend

               macro
&lab           SRQPoll &a1
&lab           ph4   &a1(1)
               ph2   &a1(2)
               Tool  $1409
               mend

               macro
&lab           SRQRemove &a1
&lab           ph2   &a1
               Tool  $1509
               mend

               macro
&lab           ClearSRQTable
&lab           Tool  $1609
               mend
