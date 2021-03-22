**************************************************************************
*                                                                        *
* ProDOS 8 macros                                                        *
* Written by Tim Meekins                                                 *
* June 30, 1990                                                          *
*                                                                        *
* Requires: M16.MACROS                                                   *
*                                                                        *
* v1.0  06/30/90 TLM Original Version.                                   *
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
&lab     P8Alloc_Interrupt &a1
&lab     p8 $40,&a1
         mend

         macro
&lab     P8Delloc_Interrupt &a1
&lab     p8 $41,&a1
         mend

         macro
&lab     P8Quit &a1
&lab     p8 $65,&a1
         mend

         macro
&lab     P8Read_Block &a1
&lab     p8 $80,&a1
         mend

         macro
&lab     P8Write_Block &a1
&lab     p8 $81,&a1
         mend

         macro
&lab     P8Get_Time &a1
&lab     p8 $82,&a1
         mend

         macro
&lab     P8Create &a1
&lab     p8 $C0,&a1
         mend

         macro
&lab     P8Destroy &a1
&lab     p8 $C1,&a1
         mend

         macro
&lab     P8Rename &a1
&lab     p8 $C2,&a1
         mend

         macro
&lab     P8Set_File_Info &a1
&lab     p8 $C3,&a1
         mend

         macro
&lab     P8Get_File_Info &a1
&lab     p8 $C4,&a1
         mend

         macro
&lab     P8On_Line &a1
&lab     p8 $C5,&a1
         mend

         macro
&lab     P8Set_Prefix &a1
&lab     p8 $C6,&a1
         mend

         macro
&lab     P8Get_Prefix &a1
&lab     p8 $C7,&a1
         mend

         macro
&lab     P8Open &a1
&lab     p8 $C8,&a1
         mend

         macro
&lab     P8Newline &a1
&lab     p8 $C9,&a1
         mend

         macro
&lab     P8Read &a1
&lab     p8 $CA,&a1
         mend

         macro
&lab     P8Write &a1
&lab     p8 $CB,&a1
         mend

         macro
&lab     P8Close &a1
&lab     p8 $CC,&a1
         mend

         macro
&lab     P8Flush &a1
&lab     p8 $CD,&a1
         mend

         macro
&lab     P8Set_Mark &a1
&lab     p8 $CE,&a1
         mend

         macro
&lab     P8Get_Mark &a1
&lab     p8 $CF,&a1
         mend

         macro
&lab     P8Set_EOF &a1
&lab     p8 $D0,&a1
         mend

         macro
&lab     P8Get_EOF &a1
&lab     p8 $D1,&a1
         mend

         macro
&lab     P8Set_Buf &a1
&lab     p8 $D2,&a1
         mend

         macro
&lab     P8Get_Buf &a1
&lab     p8 $D3,&a1
         mend


