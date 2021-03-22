/*************************************************************************
 *
 * Merlin-16 to Orca/M translator v1.1
 * Written by Tim Meekins
 * January 21, 1993
 *
 * $10 Shareware
 *
 * Copyright (c) 1993 by Tim Meekins
 *
 *************************************************************************/

#pragma optimize -1
#pragma lint -1

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define MAXLABELS 100

char line[256],line2[256],label[80],operand[20];

char *labels[MAXLABELS];
unsigned labcnt[MAXLABELS];

unsigned numlab;

char *v = "v1.1";	/* Version # */

char *err1 = "\t; %% invalid character in position 0";

/* find a local label in the label table */

unsigned int findlabel(char *p)
{
    unsigned int i;

    if (numlab == 0) return MAXLABELS+1;

     for (i=0; i<numlab; i++)
         if(strcmp(p,labels[i])==0)
             return i;

     return MAXLABELS+1;
}

/* the main converter */

void main(int argc, char **argv)
{
    unsigned int ch;
    unsigned int pos;
    unsigned int i,j,k;
    unsigned int linelen,done,linenum;
    unsigned int didoperand;
    unsigned int aon,aoff,ion,ioff;
    unsigned int labinc;
    unsigned int sec;

    FILE *ifile,*ofile;

    if (argc < 2 || argc > 3)
    {
        fprintf(stderr,"Usage: %s merlin-file [orca-file]\n",argv[0]);
        exit(-1);
    }

    ifile = fopen(argv[1],"rb");
    if (ifile==NULL)
    {
        fprintf(stderr,"Could not open input file %s\n",argv[1]);
        exit(-1);
    }

    if (argc==3)
    {
        ofile = fopen(argv[2],"w");
        if (ofile==NULL)
        {
            fprintf(stderr,"Could not open outut file %s\n",argv[2]);
            exit(-1);
        }
    }
    else
        ofile = stdout;

    fprintf(stderr,"Merlin-2-Orca %s\n",v);
    fprintf(stderr,"Written by Tim Meekins\n");
    fprintf(stderr,"Shareware $10\n");

    fprintf(stderr,"\n%s",argv[1]);

    fprintf(ofile,"* %s\n",argv[1]);
    fprintf(ofile,"* Merlin 16 to Orca/M translation by m2o %s\n",v);
    fprintf(ofile,"* Written by Tim Meekins\n");
    fprintf(ofile,"* Shareware $10\n");

    fprintf(ofile,"\nMAIN\tSTART\n");

    done = 0;
    numlab = 0;
    linenum = 0;
    sec = 0;

    aon = aoff = ion = ioff = 0;

    while(!done)
    {
	/* read a single line of input */

        linenum++;

        if (argc==3 && linenum%10 == 0) fputc('.',stderr);

        linelen = 0;
        while(1)
        {
             if ((ch = fgetc(ifile)) == EOF) { done++; break; }
             if (ch & 0x80) ch ^= 0x80;

             if (ch==0x0d) break;

             line[linelen++] = ch;
        }

        line[linelen] = 0x00;
        pos = linelen = 0;
        labinc = MAXLABELS+1;

        /* if the line starts with a comment */

        if (line[pos] == '*' || line[pos] == ';')
	    while (line[pos])
                line2[linelen++] = line[pos++];

        /* if the line starts with a standard label */

        if (isalpha(line[pos]) || line[pos] == ':' || line[pos] == '_')
        {
           if (line[pos] == ':') line[pos] = '_';
           while (line[pos] && line[pos] != ' ')
               line2[linelen++] = line[pos++];
           if (!line[pos])   /* nothing followed the label */
           {
              line2[linelen++] = '\t';
              line2[linelen++] = 'a';
              line2[linelen++] = 'n';
              line2[linelen++] = 'o';
              line2[linelen++] = 'p';
           }
        }

        /* if the line starts with a local label */

        if (line[pos]==']')
        {
	    pos++; i = 0;
            while(line[pos] && line[pos] != ' ')
                label[i++] = tolower(line[pos++]);
            label[i] = '\0';
            i = findlabel(label);

            if (i==MAXLABELS+1)
            {
                i = numlab++;
                labcnt[i] = 0;
                labels[i] = (char *)malloc(strlen(label)+1);
                strcpy(labels[i],label);
            }

            labcnt[i]; labinc = i;

            line2[linelen++] = '~';

            k = labcnt[i]+1;
            j = 0; while (k > 99) { j++; k -= 100;} line2[linelen++] = '0'+j;
            j = 0; while (k > 9)  { j++; k -= 10;}  line2[linelen++] = '0'+j;
            line2[linelen++] = '0'+k;

            j = 0; while(label[j]) line2[linelen++] = label[j++];
        }

        /* if the first character is not a space, then it's invalid */

        if (line[pos] && line[pos] != ' ')
        {
           while(line[pos]) line2[linelen++] = line[pos++];
           i = 0; while(err1[i]) line2[linelen++] = err1[i++];
        }

        /* the first character is guaranteed to be a space, output a tab,
           skip the space, and then we're pointing at the opcode */

        if (line[pos] == ' ') { pos++; line2[linelen++] = '\t'; }

        /* copy opcode into buffer */

        i = 0;
        while (line[pos] && line[pos] != ' ')
            operand[i++] = tolower(line[pos++]);
        operand[i] = '\0';

        didoperand = 0; /* we didn't parse the operand yet */

        if (i != 0)
        {
            if (strcmp(operand,"xc")==0)
                ; /* if XC then just ignore it */
            else if (strcmp(operand,"lst")==0)
                {
                    line2[linelen++] = 'l';
                    line2[linelen++] = 'i';
                    line2[linelen++] = 's';
                    line2[linelen++] = 't';
                }
            else if (strcmp(operand,"equ")==0)
                {
                    line2[linelen++] = 'g';
                    line2[linelen++] = 'e';
                    line2[linelen++] = 'q';
                    line2[linelen++] = 'u';
                }
            else if (strcmp(operand,"=")==0)
                {
                    line2[linelen++] = 'e';
                    line2[linelen++] = 'q';
                    line2[linelen++] = 'u';
                }
            else if (strcmp(operand,"str")==0)
                {
                    line2[linelen++] = 'd';
                    line2[linelen++] = 'c';
                    line2[linelen++] = '\t';
                    line2[linelen++] = 'i';
                    line2[linelen++] = '1';
                    line2[linelen++] = '\'';
                    pos++; /* skip the space */
                    k = 0;
                    i = pos+1;
                    while(line[i] && line[i] != '\'') { i++; k++;}
                    j = 0;
                    while (k > 99) { j++; k -= 100;}
                    if (j) line2[linelen++] = '0'+j;
                    j = 0;
                    while (k > 9)  { j++; k -= 10;}
                    if (j) line2[linelen++] = '0'+j;
                    line2[linelen++] = '0'+k;
                    line2[linelen++] = '\'';
                    line2[linelen++] = ',';
                    line2[linelen++] = 'c';
                    if (line[pos]) line2[linelen++] = line[pos++];
                    while (line[pos] && line[pos] != '\'')
                        line2[linelen++] = line[pos++];
                    if (line[pos]) line2[linelen++] = line[pos++];
                    didoperand++; 
                }                           
            else if (strcmp(operand,"hex")==0)
                {
                    line2[linelen++] = 'd';
                    line2[linelen++] = 'c';
                    line2[linelen++] = '\t';
                    line2[linelen++] = 'h';
                    line2[linelen++] = '\'';
                    pos++; /* skip the space */
                    while (line[pos] && line[pos] != ' ')
                      line2[linelen++] = line[pos++];
                    line2[linelen++] = '\'';
                    didoperand++;
                }
            else if (strcmp(operand,"da")==0 ||
                     strcmp(operand,"db")==0 ||
                     strcmp(operand,"adr")==0 ||
                     strcmp(operand,"dfb")==0 ||
                     strcmp(operand,"adrl")==0)
                {
                    line2[linelen++] = 'd';
                    line2[linelen++] = 'c';
                }
            else if (strcmp(operand,"inc")==0 ||
                     strcmp(operand,"dec")==0 ||
                     strcmp(operand,"asl")==0 ||
                     strcmp(operand,"lsr")==0 ||
                     strcmp(operand,"rol")==0 ||
                     strcmp(operand,"ror")==0)
                {
                    line2[linelen++] = operand[0];
                    line2[linelen++] = operand[1];
                    line2[linelen++] = operand[2];
                    if (line[pos] == 0 ||
                        (line[pos] == ' ' &&
                         (line[pos+1]==' ' || line[pos+1] == 0 || line[pos+1] == ';')))
                    {
                      if (line[pos]) pos++;
                      line2[linelen++] = '\t';
                      line2[linelen++] = 'a';
                      didoperand++;
                      if (line[pos+1] == ';')
	                 line2[linelen++] = '\t';
                    }
                }                                
            else if (strcmp(operand,"ldal")==0 ||
                     strcmp(operand,"stal")==0 ||
                     strcmp(operand,"oral")==0 ||
                     strcmp(operand,"eorl")==0 ||
                     strcmp(operand,"andl")==0 ||
                     strcmp(operand,"adcl")==0 ||
                     strcmp(operand,"sbcl")==0 ||        
                     strcmp(operand,"cmpl")==0)          
                {
                    line2[linelen++] = operand[0];
                    line2[linelen++] = operand[1];
                    line2[linelen++] = operand[2];
                }
            else if (strcmp(operand,"mx")==0)
                {
                    if (line[pos] == ' ' && line[pos+1] == '%')
                    {
                        line2[linelen++] = 'l';
                        line2[linelen++] = 'o';
                        line2[linelen++] = 'n';
                        line2[linelen++] = 'g';
                        line2[linelen++] = 'a';
                        line2[linelen++] = '\t';
                        line2[linelen++] = 'o';
                        if (line[pos+2] == '0')   
                        {
                            line2[linelen++] = 'f';
                            line2[linelen++] = 'f';
                        }
                        else
                        {
                            line2[linelen++] = 'n';
                        }
                        if (line[pos+3] == '0')
                            ioff++;
                        else
                            ion++;
                        pos += 4;
                        didoperand++;
                    }
                }
            else if (strcmp(operand,"rep")==0)
                {
                    line2[linelen++] = 'r';
                    line2[linelen++] = 'e';
                    line2[linelen++] = 'p';
                    pos++; /* skip the space */
                    line2[linelen++] = '\t';
                    if (line[pos]=='#') pos++;
                    line2[linelen++] = '#';
                    if (line[pos]=='$')
                    {
                        line2[linelen++] = '$';
                        pos++;
                        if (line[pos]=='3') { aon = 1; ion = 1; }
                        if (line[pos]=='2') aon = 1;
                        if (line[pos]=='1') ion = 1;
                        line2[linelen++] = line[pos++];
                        line2[linelen++] = line[pos++];
                    }
                    else
                       while(line[pos] && line[pos] != ' ')
                           line2[linelen++] = line[pos++];
                    didoperand;
                }
            else if (strcmp(operand,"sep")==0)
                {
                    line2[linelen++] = 's';
                    line2[linelen++] = 'e';
                    line2[linelen++] = 'p';
                    pos++; /* skip the space */
                    line2[linelen++] = '\t';
                    if (line[pos]=='#') pos++;
                    line2[linelen++] = '#';
                    if (line[pos]=='$')
                    {
                        line2[linelen++] = '$';
                        pos++;
                        if (line[pos]=='3') { aoff = 1; ioff = 1; }
                        if (line[pos]=='2') aoff = 1;
                        if (line[pos]=='1') ioff = 1;
                        line2[linelen++] = line[pos++];
                        line2[linelen++] = line[pos++];
                    }
                    else
                       while(line[pos] && line[pos] != ' ')
                           line2[linelen++] = line[pos++];
                    didoperand++;
                }
            else if (strcmp(operand,"sec")==0)
                {
                    line2[linelen++] = 's';
                    line2[linelen++] = 'e';
                    line2[linelen++] = 'c';
                    sec++;
                }
            else if (strcmp(operand,"xce")==0)
               {
                   line2[linelen++] = 'x';
                   line2[linelen++] = 'c';
                   line2[linelen++] = 'e';
                   if (sec)
                   {
                        aoff = 1;
                        ioff = 1;
                   }
               }
            else if (strcmp(operand,"ds")==0)
                {
                    if (line[pos] && line[pos+1] == '\\')
                    {
                        line2[linelen++] = 'a';
                        line2[linelen++] = 'l';
                        line2[linelen++] = 'i';
                        line2[linelen++] = 'g';
                        line2[linelen++] = 'n';
                        line2[linelen++] = '\t';
                        line2[linelen++] = '2';
                        line2[linelen++] = '5';
                        line2[linelen++] = '6';
                        pos++;
                        pos++;
                        didoperand++;
                    }                        
                    else
                    {
                        line2[linelen++] = 'd';
                        line2[linelen++] = 's';
                    }
                }
            else if (strcmp(operand,"tr")==0)
                {
                    line2[linelen++] = 'e';
                    line2[linelen++] = 'x';
                    line2[linelen++] = 'p';
                    line2[linelen++] = 'a';
                    line2[linelen++] = 'n';
                    line2[linelen++] = 'd';
                }                        
            else if (strcmp(operand,"exp")==0)
                {
                    line2[linelen++] = 'g';
                    line2[linelen++] = 'e';
                    line2[linelen++] = 'n';
                }                        
            else if (strcmp(operand,"use")==0)
                {
                    line2[linelen++] = 'm';
                    line2[linelen++] = 'c';
                    line2[linelen++] = 'o';
                    line2[linelen++] = 'p';
                    line2[linelen++] = 'y';
                }                        
            else if (strcmp(operand,"put")==0)
                {
                    line2[linelen++] = 'c';
                    line2[linelen++] = 'o';
                    line2[linelen++] = 'p';
                    line2[linelen++] = 'y';
                }                        
            else if (strcmp(operand,"asc")==0)
                {
                    line2[linelen++] = 'd';
                    line2[linelen++] = 'c';
                    line2[linelen++] = '\t';
                    line2[linelen++] = 'c';
                    line2[linelen++] = '\'';
                    pos++; /* skip space */
                    pos++; /* skip quote */
                    while (line[pos] && line[pos] != '"')
                        line2[linelen++] = line[pos++];
                    pos++; /* skip end quote */
                    line2[linelen++] = '\'';
                    if (line[pos] == ',')
                    {
                        line2[linelen++] = line[pos++];
                        line2[linelen++] = 'i';
                        line2[linelen++] = '1';
                        line2[linelen++] = '\'';
                        while (line[pos] && line[pos] != ' ')
                            line2[linelen++] = line[pos++];
                        line2[linelen++] = '\'';
                    }                                    
                    didoperand++;
                }                        
            else /* default */                      
            {
                i = 0;
                while(operand[i]) line2[linelen++] = operand[i++];
            }

            if (sec)
                if (strcmp(operand,"sec")!=0)
		    sec = 0;
        }

        /* convert the space following the opcode into a tab */

        if (line[pos] == ' ') { pos++; line2[linelen++] = '\t'; }

        /* parse the operand */

        if (!didoperand)
        {
            if (strcmp(operand,"da")==0 ||
                strcmp(operand,"adr")==0)
            {
                line2[linelen++] = 'a';
                line2[linelen++] = '2';
                line2[linelen++] = '\'';
            }
            else if (strcmp(operand,"adrl")==0)
            {
                line2[linelen++] = 'a';
                line2[linelen++] = '4';
                line2[linelen++] = '\'';
            }
            else if (strcmp(operand,"dfb")==0 ||
                     strcmp(operand,"db")==0)
            {
                line2[linelen++] = 'i';
                line2[linelen++] = '1';
                line2[linelen++] = '\'';
            }
            else if (strcmp(operand,"ldal")==0 ||
                     strcmp(operand,"stal")==0 ||
                     strcmp(operand,"cmpl")==0)
            {
                line2[linelen++] = '>';
            }

            while(line[pos] && line[pos]!=' ')
            {
                if (line[pos]=='[')
                {
                    while(line[pos] && line[pos] != ']')
                        line2[linelen++] = line[pos++];
                    if (line[pos]) line2[linelen++] = line[pos++];
                }
                else if (line[pos]=='%')
                {
                    line2[linelen++] = line[pos++];
                    while (line[pos] == '0' || line[pos] == '1' || line[pos] == '_')
                       if (line[pos] == '_')
                          pos++;
                       else
                          line2[linelen++] = line[pos++];
                }                                  
                else if (line[pos]=='"')
                {
                    line2[linelen++] = '\''; pos++;
            	    while(line[pos] && line[pos] != '"')
                        line2[linelen++] = line[pos++];
                    line2[linelen++] = '\'';
                    if (line[pos]) pos++;
                }                                  
	        else if (line[pos]==']')
                {
                    pos++;
	            i = 0;
            	    while(line[pos] && line[pos] != ' ' && isalnum(line[pos]))
                	label[i++] = tolower(line[pos++]);
            	    label[i] = '\0';
            	    i = findlabel(label);

            	    if (i==MAXLABELS+1)
            	    {
                	i = numlab++;
                	labcnt[i] = 0;
                	labels[i] = (char *)malloc(strlen(label)+1);
                	strcpy(labels[i],label);
            	    }

            	    line2[linelen++] = '~';

            	    k = labcnt[i];
                    j = 0; while (k > 99) { j++; k -= 100;}
                    line2[linelen++] = '0'+j;
            	    j = 0; while (k > 9)  { j++; k -= 10;}
                    line2[linelen++] = '0'+j;
            	    line2[linelen++] = '0'+k;

            	    j = 0; while(label[j]) line2[linelen++] = label[j++];
                }
	        else if (line[pos]==':')
                  { line2[linelen++] = '_'; pos++; }
                
                line2[linelen++] = line[pos++];
            }

            if (strcmp(operand,"da")==0 ||
                strcmp(operand,"db")==0 ||
                strcmp(operand,"adr")==0 ||
                strcmp(operand,"dfb")==0 ||
                strcmp(operand,"adrl")==0)
                line2[linelen++] = '\'';
         }

        /* convert the space following the operand into a tab */

        if (line[pos] == ' ') { pos++; line2[linelen++] = '\t'; }

        /* parse the trailing comments */

        while(line[pos])
            line2[linelen++] = line[pos++];

        line2[linelen] = 0x00;

        fprintf(ofile,"%s\n",line2);

        if (labinc<MAXLABELS) labcnt[labinc]++;

        if (aon)  { aon  = 0; fprintf(ofile,"\tlonga\ton\n");  }
        if (aoff) { aoff = 0; fprintf(ofile,"\tlonga\toff\n"); }
        if (ion)  { ion  = 0; fprintf(ofile,"\tlongi\ton\n");  }
        if (ioff) { ioff = 0; fprintf(ofile,"\tlongi\toff\n"); }
    }                                                      

    fprintf(ofile,"\n\tEND\n");

    fclose(ifile);
    fclose(ofile);

    fputc('\n',stderr);

}                
