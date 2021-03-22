**************************************************************************
*                                                                        *
* Pascal macros.   Macros for defining pascal-like procedures            *
* Written by Tim Meekins                                                 *
* April 1, 1988                                                          *
*                                                                        *
* v1.0  04/01/88 TLM Original Version.                                   *
* v1.1  12/19/90 Save and restore data bank.                             *
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
&lab           subroutine &parms,&work
&lab           anop
               aif   c:&work,.a
               lclc  &work
&work          setc  0
.a
               gbla  &totallen
               gbla  &worklen
&worklen       seta  &work
&totallen      seta 0
               aif   c:&parms=0,.e
               lclc  &len
               lclc  &p
               lcla  &i
&i             seta  c:&parms
.b
&p             setc  &parms(&i)
&len           amid  &p,2,1
               aif   "&len"=":",.c
&len           amid  &p,1,2
&p             amid  &p,4,l:&p-3
               ago   .d
.c
&len           amid  &p,1,1
&p             amid  &p,3,l:&p-2
.d
&p             equ   &totallen+3+&work
&totallen      seta &totallen+&len
&i             seta  &i-1
               aif   &i,^b
.e
               tsc
               sec
               sbc   #&work
               tcs
               inc   a
               phd
               tcd
               phb
               phk
               plb

               mend


               macro
&lab           return &r
&lab           anop
               lclc  &len
               aif   c:&r,.a
               lclc  &r
&r             setc  0
&len           setc  0
               ago   .h
.a
&len           amid  &r,2,1
               aif   "&len"=":",.b
&len           amid  &r,1,2
&r             amid  &r,4,l:&r-3
               ago   .c
.b
&len           amid  &r,1,1
&r             amid  &r,3,l:&r-2
.c
               aif   &len<>2,.d
               ldy   &r
               ago   .h
.d
               aif   &len<>4,.e
               ldx   &r+2
               ldy   &r
               ago   .h
.e
               aif   &len<>10,.g
               ldy   #&r
               ldx   #^&r
               ago   .h
.g
               mnote 'Not a valid return length',16
               mexit
.h
               aif   &totallen=0,.i
               lda   &worklen+1
               sta   &worklen+&totallen+1
               lda   &worklen
               sta   &worklen+&totallen
.i
               plb
               pld
               tsc
               clc
               adc   #&worklen+&totallen
               tcs
               aif   &len=0,.j
               tya
.j
               rtl
               mend
