**************************************************************************
*                                                                        *
*                    ZAVTRA MACRO UTILITIES DISK                         *
*                  Copyright 1990,91 by Tim Meekins                      *
*                        All Rights Reserved                             *
*                                                                        *
*                   THIS PRODUCT IS SHAREWARE!!                          *
*   If you find yourself using this product extensively, please take the *
*   time and send several dollars to the author to compensate for the    *
*   many hours spent developing this product for your use. Support of    *
*   this product will help in the development of future products.        *
*                                                                        *
*                                                                        *
**************************************************************************

See Release 1.0 information for more information about the Zavtra Macros
Disk. If there are any macros which you need which don't appear here, please
let me know about them. Also, if you have any user tool sets you'd like
to see macros for, let me know.


                       ZAVTRA MACRO UTILITIES DISK
                       ===========================
                               Release 1.4

05/24/91  Wrote Jump branching instructions.

                       ZAVTRA MACRO UTILITIES DISK
                       ===========================
                               Release 1.3

01/23/91  Fixed typo in SoundSmith SoundTrack Tool.
01/24/91  Wrote macros for video overlay card.
03/01/91  Fixed typo in Tool Locator Macros. -> SetTSPtr
03/05 91  Added macros for ZPack.
04/27/91  Updated naming conventions of shell macros.
          Wrote UserTool macro
          Wrote macros for Jawaid Bazyar's Modem Manager tool set.
          Added G16.ZPack to the distribution.
          Wrote GSBug macros
          Wrote FMD macros for DTS's Fake Model Dialog Tools

                       ZAVTRA MACRO UTILITIES DISK
                       ===========================
                               Release 1.2

12/19/90  Save/Restore data bank in "subroutine" and "return"
12/20/90  Wrote a simple Deref macro
01/08/91  Pascal Macros documenation incorrectly stated that return values
          were returned in the Y-register. They are returned in the
          Accumulator.
02/15/91  Updated GSOS, Loader, and P16 Macros to GS/OS v3.0.
          Removed example.
02/16/91  Wrote Soundsmith Tool 219 macros. Tool219 (C) FTA
02/17/91  Added ConvSeconds to Misc Tool.

                       ZAVTRA MACRO UTILITIES DISK
                       ===========================
                               Release 1.1

 8/23/90  Fixed a major bug in LD4 macro.
 8/30/90  Set LONGA OFF and LONGI OFF in Emulate macro.
 8/31/90  Created OTHER directory and added my list of page $E1 vectors
          Fixed a HUGE(!!) error in macro P8. It was generating a JSL
            instead of a JSR!
          After much debate with myself, I finally decided to create SmartPort
            macros. These macros call the dispatcher at $C50D. But beware,
            this isn't an Apple supported entry point!! You should read the
            Firmware Reference and do it the correct the way.
 9/12/90  Fixed a typo in M16.TEXT; ReadLine was spelled incorrectly.
 9/19/90  Modified '@' operand for PL4 macro. If '@' followed by one reg, say
          'a', then generate a PLa, PLa. But, if '@' followed by two regs, say
          'xy', then generate a PLx, PLy.
 9/20/90  Added $E10104 to E1 vector table.
10/14/90  Placed my FileType list in Other directory
10/17/90  Added '@' support to PH4. Now works just like PL4.
11/14/90  Updated the tool documentation.
12/05/90  Wrote Neg2
12/06/90  Wrote IF2.
12/14/90  Because of IF2, removed CM2.
          Updated documentation.
12/15/90  Created example program. Borrowed from Apple Source Code Sampler
          I really didn't test it...so I'll trust it compiles and runs
          correctly..shoot me if it doesn't...

                       ZAVTRA MACRO UTILITIES DISK
                       ===========================
                               Release 1.0

This disk contains hundreds of macros for making your programming that more
easy and enjoyable. Additionally, the powerful tool macros allow for elegant
source code, which is much more readable than those using numerous pushes
and pulls. You'll also find that debugging the parameter passing will become
simpler since the chances of making a mistake will be decreased. This of course
assumes bug-free macros. Basically it is a sort of pseudo type-checking.

Like any program of massive proportions (??) such as this (!!), there are
bound to bugs and typos abound (and other creepy critters.) Please let me
know if any should "bite" you. I have tested as many as possible, but there
is always a chance that something has slipped through the cracks.

Due to the tremendous amount of time that I've spent developing these macros,
I am forced to make this a shareware product (instead of freeware.) So, if
you decide that you like these macros, please take a moment and send off
$10 to $20 so that I can continue to create future shareware and freeware
products for the GS community.

I hope these macros help some future GS'er develop great warez for our
"beloved" machines! My goal is to keep the II alive forever!

Signed,
   - Tim Meekins
