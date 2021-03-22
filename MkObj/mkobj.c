/**
 ** MKOBJ.C 1.1
 ** Written by Tim Meekins
 **
 ** Creates an OMF file from a binary file.
 **
 **/

#pragma optimize -1
#pragma stacksize 1024

#include <stdio.h>
#include <stdlib.h>
#include <types.h>
#include <gsos.h>
#include "omf.h"

extern word codesize;		/* number of code bytes in current segment */

void main(int argc, char **argv)
{
    FILE *ifile,*ofile;
    int c;
    GSString255Ptr path;
    FileInfoRecGS parm;

    printf("MKOBJ 1.1 (c) 1993 T Meekins\n");

    if (argc < 4 || argc > 5)
    {
        printf("Usage: mkobj <segname> <infile> <outfile> [<loadname>]\n");
        exit(-1);
    }

    ifile = fopen(argv[2],"rb");
    if (ifile==NULL)
    {
        printf("Could not open file %s\n",argv[2]);
        exit(-1);
    }

    if (argc==4)
        OMF_newseg(argv[1],NULL);
    else
        OMF_newseg(argv[1],argv[4]);

    while((c=fgetc(ifile))!=EOF)
        { OMF_constoutbyte(c); codesize++; }

    fclose(ifile);

    ofile = fopen(argv[3],"wb");
    if (ofile==NULL)
    {
        printf("Could not open file %s\n",argv[3]);
        exit(-1);
    }

    OMF_writeseg(ofile);

    fclose(ofile);

    /* time to set the filetype to OBJ ($b1) */

    path = malloc((size_t) (strlen(argv[3]+2)));
    path->length = strlen(argv[3]);
    memcpy(path->text,argv[3],(size_t)strlen(argv[3]));

    parm.pCount = 3;
    parm.pathname = path;
    GetFileInfo(&parm);
    parm.fileType = 0xb1; /* OBJ */
    SetFileInfo(&parm);

    free(path);

    exit(0);
            
}
