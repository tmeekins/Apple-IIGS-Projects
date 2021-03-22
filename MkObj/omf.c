/**
 ** OMF.C
 ** Written by Tim Meekins
 **
 ** Support for outputing code to an OMF file
 **
 **/

#pragma lint -1
#pragma optimize -1
#pragma noroot

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <types.h>

#include "omf.h"

/* variables used by the OMF support routines */

static long segsize;		/* number of bytes in the current segment */
static word constsize;		/* number of bytes in the current const buffer */
long codesize;			/* number of code bytes in current segment */

static byte *segbuf;		/* the current segment we're working with */
static byte constbuf[MAXCONSTSIZE]; /* the constant buffer */

/**
 ** Output primitives
 ** segments are buffered internally, and written to disk upon completion.
 ** since constants are contained in a single record, they are buffered, and
 ** purge when reaching maximum capacity or a non-constant is output.
 **
 **/

/*--------------------------------------------*/
/* output a single byte to the segment buffer */
/*--------------------------------------------*/
                                                
void OMF_outbyte(byte val)
{
    if (constsize)
	OMF_constpurge();

    if (segsize == MAXSEGSIZE) {
	fprintf(stderr,"OMF Panic: Segment Buffer Overflow\n");
	exit(-1);
    }

    segbuf[segsize++] = val;

}  /* OMF_outbyte */

/*-------------------------------------*/
/* output a word to the segment buffer */
/*-------------------------------------*/
                                         
void OMF_outword(word val)
{

    OMF_outbyte((byte)(val & 0xff));
    OMF_outbyte((byte)(val >> 8));

} /* OMF_outword */

/*------------------------------------------*/
/* output a long word to the segment buffer */
/*------------------------------------------*/
                                              
void OMF_outlong(long val)
{

    OMF_outbyte((byte)(val & 0xff));
    OMF_outbyte((byte)(val >> 8));
    OMF_outbyte((byte)(val >> 16));
    OMF_outbyte((byte)(val >> 24));

} /* OMF_outlong */

/*--------------------------------------------------------------------------*/
/* purge the constant buffer by creating a CONST record and ouputting it to */
/* the current segment buffer 						    */
/*--------------------------------------------------------------------------*/
                                                                              
void OMF_constpurge(void)
{
    word len,i;

    if (constsize) {
	len = constsize;
        constsize = 0;			/* so outbyte doesn't become recursive */
        OMF_outbyte(CONST-1+len);	/* output record header */
        for (i=0; i<len; i++)
            OMF_outbyte(constbuf[i]);
    }

}  /* OMF_constpurge */

/*---------------------------------------------*/
/* output a single byte to the constant buffer */
/*---------------------------------------------*/

void OMF_constoutbyte(byte val)
{
    if (constsize == MAXCONSTSIZE)
	OMF_constpurge();

    constbuf[constsize++] = val;

}  /* OMF_constoutbyte */

/*--------------------------------------*/
/* output a word to the constant buffer */
/*--------------------------------------*/

void OMF_constoutword(word val)
{

    OMF_constoutbyte((byte)(val & 0xff));
    OMF_constoutbyte((byte)(val >> 8));

} /* OMF_constoutword */

/*-------------------------------------------*/
/* output a long word to the constant buffer */
/*-------------------------------------------*/

void OMF_constoutlong(long val)
{

    OMF_constoutbyte((byte)(val & 0xff));
    OMF_constoutbyte((byte)(val >> 8));
    OMF_constoutbyte((byte)(val >> 16));
    OMF_constoutbyte((byte)(val >> 24));

} /* OMF_constoutlong */

/*------------------------------------------------*/
/* output a name expression to the segment buffer */
/*------------------------------------------------*/

void OMF_outname(char *name, byte displace, byte count, byte shift)
{
    unsigned int len, i;

    OMF_outbyte(EXPR);			/* EXPR expression record header */
    OMF_outbyte(count);			/* count to evaluate to */
    OMF_outbyte(0x83);			/* label reference operand */
    OMF_outbyte(len=strlen(name));	/* output length of the name */

    for (i=0; i<len; i++)		/* output the name */
	OMF_outbyte(name[i]);

    if (displace) {			/* output the name displacement */
	OMF_outbyte(0x81);		/* constant operand */
        OMF_outlong((long)displace);	/* displacement constant */
        OMF_outbyte(0x01);		/* add displacement to the name */
    }

    if (shift) {			/* output the name shift */
        OMF_outbyte(0x81);		/* constant operand */
        OMF_outlong((long)shift);       /* shift constant */
        OMF_outbyte(shift);		/* shift name by 'shift' */
    }

}  /* OMF_outname */

/*-----------------------------------------------------------------*/
/* start a new segment - allocate memory and make a segment header */
/*-----------------------------------------------------------------*/

void OMF_newseg(char *name,char *loadname)
{
    unsigned int i, len = strlen(name);

    segbuf = (byte *)malloc(MAXSEGSIZE * sizeof(byte));

    segsize = 0;
    constsize = 0;
    codesize = 0;

    OMF_outlong(0);		/* block count (unknown) */
    OMF_outlong(0);		/* reserved */
    OMF_outlong(0);		/* segment code length (unknown */
    OMF_outbyte(0);		/* segment kind (static code) */
    OMF_outbyte(0);		/* label length (variable) */
    OMF_outbyte(4);		/* length of numbers */
    OMF_outbyte(1);		/* OMF version */
    OMF_outlong(0x010000);	/* bank size */
    OMF_outlong(0);		/* unused */
    OMF_outlong(0);		/* org */
    OMF_outlong(0);		/* alignment */
    OMF_outbyte(0);		/* endian */
    OMF_outbyte(0);		/* language card not used */
    OMF_outword(0);		/* segment number */
    OMF_outlong(0);		/* entry */
    OMF_outword(segsize+4);	/* displacement to name */
    OMF_outword(segsize+13+len); /* displacement to opcodes */
    if (loadname)
        for (i=0; i<10; i++)
           if (i<strlen(loadname))
               OMF_outbyte(loadname[i]);
           else
               OMF_outbyte(0x20);
    else
    {
        OMF_outlong(0x20202020);	/* load segment name */
        OMF_outlong(0x20202020);
        OMF_outword(0x2020);
    }
    OMF_outbyte(len);		/* code segment name */
    for (i=0; i<len; i++)
	OMF_outbyte(name[i]);

}  /* OMF_newseg */

/*-------------------------------------*/
/* write the current segment to a file */
/*-------------------------------------*/

void OMF_writeseg(FILE *fp)
{
    long temp;

    OMF_constpurge();			/* purge the constant buffer */
    OMF_outbyte(0);                     /* end of file marker */
    if (segsize % 512)                  /* calculate the block size */
        segsize += (512 - segsize % 512);
    temp = segsize;
    segsize = 0;
    OMF_outlong(temp>>9);	        /* output the number of blocks */
    segsize = 8;
    OMF_outlong(codesize);	        /* output the code size */
    fwrite(segbuf,1,temp,fp);	        /* write the segment to the file */
    free(segbuf);
}
