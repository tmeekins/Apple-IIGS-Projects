**************************************************************************
*                                                                        *
* Resource Manager macros                                                *
* Written by Tim Meekins                                                 *
* July 27, 1990                                                          *
*                                                                        *
* Requires: M16.MACROS                                                   *
*                                                                        *
* v1.0  07/27/90 TLM Original Version. Using Resource Manager v1.0       *
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
&lab           ResourceBootInit
&lab           Tool  $011e
               mend

               macro
&lab           ResourceStartUp &a1
&lab           ph2   &a1
               Tool  $021e
               mend

               macro
&lab           ResourceShutDown
&lab           Tool  $031e
               mend

               macro
&lab           ResourceVersion &a1
&lab           pha
               Tool  $041e
               pl2   &a1
               mend

               macro
&lab           ResourceReset
&lab           Tool  $051e
               mend

               macro
&lab           ResourceStatus &a1
&lab           pha
               Tool  $061a
               pl2   &a1
               mend

               macro
&lab           CreateResourceFile &a1
&lab           ph4   &a1(1)
               ph2   &a1(2)
               ph2   &a1(3)
               ph4   &a1(4)
               Tool  $091e
               mend

               macro
&lab           OpenResourceFile &a1,&a2
&lab           pha
               ph2   &a1(1)
               ph4   &a1(2)
               ph4   &a1(3)
               Tool  $0a1e
               pl2   &a2
               mend

               macro
&lab           CloseResourceFile &a1
&lab           ph2   &a1
               Tool  $0b1e
               mend

               macro
&lab           AddResource &a1
&lab           ph4   &a1(1)
               ph2   &a1(2)
               ph2   &a1(3)
               ph4   &a1(4)
               Tool  $0c1e
               mend

               macro
&lab           UpdateResourceFile &a1
&lab           ph2   &a1
               Tool  $0d1e
               mend

               macro
&lab           LoadResource &a1,&a2
&lab           pha
               pha
               ph2   &a1(1)
               ph4   &a1(2)
               Tool  $0e1e
               pl4   &a2
               mend

               macro
&lab           RemoveResource &a1
&lab           ph2   &a1(1)
               ph4   &a1(2)
               Tool  $0f1e
               mend

               macro
&lab           MarkResourceChange &a1
&lab           ph2   &a1(1)
               ph2   &a1(2)
               ph4   &a1(3)
               Tool  $101e
               mend

               macro
&lab           SetCurResourceFile &a1
&lab           ph2   &a1
               Tool  $111e
               mend

               macro
&lab           GetCurResourceFile &a1
&lab           pha
               Tool  $121e
               pl2   &a1
               mend

               macro
&lab           SetCurResourceApp &a1
&lab           ph2   &a1
               Tool  $131e
               mend

               macro
&lab           GetCurResourceApp &a1
&lab           pha
               Tool  $141e
               pl2   &a1
               mend

               macro
&lab           HomeResourceFile &a1,&a2
&lab           pha
               ph2   &a1(1)
               ph4   &a1(2)
               Tool  $151e
               pl2   &a2
               mend

               macro
&lab           WroteResource &a1
&lab           ph2   &a1(1)
               ph4   &a1(2)
               Tool  $161e
               mend

               macro
&lab           ReleaseResource &a1
&lab           ph2   &a1(1)
               ph2   &a1(2)
               ph4   &a1(3)
               Tool  $171e
               mend

               macro
&lab           DetachResource &a1
&lab           ph2   &a1(1)
               ph4   &a1(2)
               Tool  $181e
               mend

               macro
&lab           UniqueResourceID &a1,&a2
&lab           pha
               pha
               ph2   &a1(1)
               ph2   &a1(2)
               Tool  $191e
               pl4   &a2
               mend

               macro
&lab           SetResourceID &a1
&lab           ph4   &a1(1)
               ph2   &a1(2)
               ph4   &a1(3)
               Tool  $1a1e
               mend

               macro
&lab           GetResourceAttr &a1,&a2
&lab           pha
               ph2   &a1(1)
               ph4   &a1(2)
               Tool  $1b1e
               pl2   &a2
               mend

               macro
&lab           SetResourceAttr &a1
&lab           ph2   &a1(1)
               ph2   &a1(2)
               ph4   &a1(3)
               Tool  $1c1e
               mend

               macro
&lab           GetResourceSize &a1,&a2
&lab           pha
               pha
               ph2   &a1(1)
               ph4   &a1(2)
               Tool  $1d1e
               pl4   &a2
               mend

               macro
&lab           MatchResourceHandlee &a1
&lab           ph4   &a1(1)
               ph4   &a1(2)
               Tool  $1e1e
               mend

               macro
&lab           GetOpenFileRefNum &a1,&a2
&lab           pha
               ph2   &a1
               Tool  $1f1e
               pl2   &a2
               mend

               macro
&lab           CountTypes &a1
&lab           pha
               Tool  $201e
               pl2   &a1
               mend

               macro
&lab           GetIndType &a1,&a2
&lab           pha
               ph2   &a1
               Tool  $211e
               pl2   &a2
               mend

               macro
&lab           CountResource &a1,&a2
&lab           pha
               pha
               ph2   &a1
               Tool  $221e
               pl4   &a2
               mend

               macro
&lab           GetIndResource &a1,&a2
&lab           pha
               pha
               ph2   &a1(1)
               ph4   &a1(2)
               Tool  $231e
               pl4   &a2
               mend

               macro
&lab           SetResourceLoad &a1,&a2
&lab           pha
               ph2   &a1
               Tool  $241e
               pl2   &a2
               mend

               macro
&lab           SetResourceFileDepth &a1,&a2
&lab           pha
               ph2   &a1
               Tool  $251e
               pl2   &a2
               mend

               macro
&lab           GetMapHandle &a1,&a2
&lab           pha
               pha
               ph2   &a1
               Tool  $261e
               pl4   &a2
               mend

               macro
&lab           LoadAbsResource &a1,&a2
&lab           pha
               pha
               ph4   &a1(1)
               ph4   &a1(2)
               ph2   &a1(3)
               ph4   &a1(4)
               Tool  $271e
               pl4   &a2
               mend

               macro
&lab           ResourceConverter &a1
&lab           ph4   &a1(1)
               ph2   &a1(2)
               ph2   &a1(3)
               Tool  $281e
               mend
