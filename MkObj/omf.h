/**
 ** OMF.H
 ** Written by Tim Meekins
 **
 ** Support for outputing code to an OMF file
 **
 **/

/* constants */

#define MAXSEGSIZE    65535	/* maximum segment size */
#define MAXCONSTSIZE  0xdf	/* maximum size of constant record */

/* Segment-body record types */

#define END		0x00
#define CONST		0x01
#define	ALIGN		0xe0
#define	ORG		0xe1
#define RELOC		0xe2
#define INTERSEG	0xe3
#define USING		0xe4
#define STRONG		0xe5
#define GLOBAL		0xe6
#define GEQU		0xe7
#define MEM		0xe8
#define EXPR		0xeb
#define	ZEXPR		0xec
#define	BEXPR		0xed
#define RELEXPR		0xee
#define	LOCAL		0xef
#define EQU		0xf0
#define DS		0xf1
#define	LCONST		0xf2
#define LEXPR		0xf3
#define ENTRY		0xf4
#define cRELOC		0xf5
#define	cINTERSEG	0xf6
#define SUPER		0xf7

/* prototypes */

void OMF_outbyte(byte val);
void OMF_outword(word val);
void OMF_outlong(long val);
void OMF_constpurge(void);
void OMF_constoutbyte(byte val);
void OMF_constoutword(word val);
void OMF_constoutlong(long val);
void OMF_outname(char *name, byte displace, byte count, byte shift);
void OMF_newseg(char *name, char *loadname);
void OMF_writeseg(FILE *fp);
                                          
