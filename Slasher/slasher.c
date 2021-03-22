/***********************************************************************/
/* Slasher 1.0                                                         */
/* Written by Tim Meekins                                              */
/* Procyon Enterprises                                                 */
/*	                                                               */
/* This is a filter program that scans standard input searching for    */
/* C++ styled // comments and replacing them ANSI C styled comments    */
/*                                                                     */
/***********************************************************************/

#pragma stacksize 1024
#pragma lint -1
#pragma optimize -1

#include <stdio.h>
#include <stdlib.h>

/* the state we're in */

#define MODESCAN  0
#define MODESLASH 1
#define MODECONV  2

/* the code */

void main(int argc, char **argv)
{
	FILE *fp;
        unsigned int mode;
        char c;

	/* let's first check and see if there were any parameters*/

        if (argc != 1) {
	    fprintf(stderr,"Usage: slasher\n");
            exit(1);
        }

        mode = MODESCAN; /* start in the scanning mode */

	while(feof(stdin) == 0) {
	    c = getc(stdin);
            switch(c) {
                case '/':
	            if (mode == MODESCAN)
                        mode = MODESLASH;
                    else if (mode == MODESLASH) {
	                mode = MODECONV;
                        putchar('/'); putchar('*');
                    }
                    else
	                putchar('/');
                    break;
                case '\n':
	            if (mode == MODECONV)
	                putchar('*');
                    if (mode == MODECONV || mode == MODESLASH)
                        putchar('/');
                    mode = MODESCAN;
                    putchar('\n');
                    break;
		default:
	            if (mode == MODESLASH) {
	                putchar('/');
                        mode = MODESCAN;
                    }
                    putchar(c);
	    }
        }

	if (mode == MODECONV)
	    putchar('*');
        if (mode == MODECONV || mode == MODESLASH)
            putchar('/');
}
