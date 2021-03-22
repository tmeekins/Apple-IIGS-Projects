/*
 * chtyp.c
 *
 * A program to manipulate file, aux, and language types
 */

#pragma optimize -1
#pragma stacksize 768

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <ctype.h>
#include <gsos.h>
#include <signal.h>
#include <shell.h>

typedef struct langs {
    int typ;
	char *name;
} langInfo;

langInfo langTable[] = {
   {0, "prodos"},
   {1, "text"},
   {3, "asm65816"},
   {4, "ibasic"},
   {5, "pascal"},
   {6, "exec"},
   {8, "cc"},
   {9, "link"},
   {10, "apwc"},
   {11, "pascal"},
   {16, "modula2"},
   {21, "rez"},
   {0x1E, "tmlpascal"},
   {265, "linker"},
   {-1,""}};

typedef struct FileTypeConv {
   word type;
   char *rep;
} FileTypeConv;

FileTypeConv FTTable[] = {
        0xB0, "src", /* apw source file */
        0xb1, "obj", /* apw object file */
        0x04, "txt", /* ascii text file */
        0xb3, "s16", /* gs/os program file */
        0xb5, "exe", /* gs/os shell program file */
        0xb8, "nda",
        0xb9, "cda",
        0xba, "tol",
        0x00, "non", /* typeless file */
        0x01, "bad", /* bad block file */
        0x06, "bin", /* general binary file */
        0x08, "fon", /* graphics screen file */
        0x19, "adb", /* appleworks data base file */
        0x1a, "awp", /* appleworks word processor file */
        0x1b, "asp", /* appleworks spreadsheet */
        0xb2, "lib", /* apw library file */
        0xb4, "rtl", /* apw runtime library */
        0xef, "pas", /* pascal partition */
        0xf0, "cmd",
        0xfa, "int", /* integer basic program */
        0xfb, "var", /* int basic var file */
        0xfc, "bas", /* applesloth basic file */
        0xfd, "var", /* applesloth variable file */
        0xfe, "rel", /* EDASM relocatable code */
        0xff, "sys", /* prodos 8 system program file */
        -1, ""};

int verbose;

void usage(void)
{
	fprintf(stderr,"usage: chtyp {[-t type] [-a type]} | { -l lang }\n");
    exit(1);
}

void aborth(int sig, int code)
{
int x = 0;

	EndSession(&x);
    if (sig != -1) fprintf(stderr,"chtyp: terminated on signal %d\n",sig);
	exit(sig);
}

void doChType(char *filename, int t, unsigned a)
{
FileInfoRecGS f;
GSString255Ptr n;

	if (verbose) printf("chtyp: %s..\n",filename);
    n = malloc(strlen(filename)+2);
    n->length = strlen(filename);
    strncpy(n->text,filename,n->length);
    f.pathname = n;
    f.pCount = 4;
    GetFileInfoGS(&f);
    if (_toolErr) {
    	fprintf(stderr,"chtyp: %s",filename);
        ERROR(&_toolErr); aborth(-1,-1);
    }
    if (t != -1) f.fileType = t;
    if (a != -1) f.auxType = (unsigned long) a;
    SetFileInfoGS(&f);
    if (_toolErr) {
    	fprintf(stderr,"chtyp: %s",filename);
        ERROR(&_toolErr); aborth(-1,-1);
    }
    free(n);
}

int main(int argc, char **argv)
{
int ch,i;
int topt = -1;
unsigned aopt = -1;
int pb = 0;

    verbose = 0;
    if (argc == 1) usage();
    while ((ch = getopt(argc, argv, "vl:t:a:")) != EOF) {
	    switch (ch) {
	        case 'l':
            	if ((topt != -1) || (aopt != -1)) usage();
			    topt = 0xB0;
                for (i = 0; langTable[i].typ != -1; i++) {
	                if (!stricmp(optarg,langTable[i].name)) {
	                    aopt = langTable[i].typ; break; }
                }
                if (aopt == -1) {
                	fprintf(stderr,"chtyp: Invalid language type\n");
		            exit(1);
                }
                break;

            case 't':
            	if (topt != -1) usage();
	            if (isdigit(optarg[0]))
	                sscanf(optarg,"%d",&topt);
                else if (optarg[0] == '$')
	                sscanf(optarg+1,"%x",&topt);
                else {
                	for (i = 0; FTTable[i].type != -1; i++) {
	                	if (!strcmp(optarg,FTTable[i].rep)) {
	                    	topt = FTTable[i].type; break; }
                	}
	        		if (topt == -1) {
	                    fprintf(stderr,"chtyp: Invalid File Type\n");
                        exit(1);
                    }
                }
                break;

            case 'a':
            	if (aopt != -1) usage();
	            if (isdigit(optarg[0]))
	                sscanf(optarg,"%d",&aopt);
                else if (optarg[0] == '$')
	                sscanf(optarg+1,"%x",&aopt);
			    break;
            case 'v':
	            verbose = 1; break;

            default: usage();
        }
    }
    argv += optind;
    argc -= optind;

    BeginSession(&pb);
    signal(SIGTERM,aborth);
    signal(SIGINT, aborth);
    signal(SIGQUIT, aborth);
    signal(SIGTSTP, aborth);
    signal(SIGSTOP, aborth);
    while (argc--) doChType(*argv++,topt,aopt);
    EndSession(&pb);
    exit(0);
}
