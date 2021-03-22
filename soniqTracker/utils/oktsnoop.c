#include <stdio.h>
#include <stdlib.h>

int quit = 0;

getstring(FILE *f, char *s, long len)
{
 long i;

 for (i=0; i<len; i++)
   if ((s[i] = fgetc(f))==EOF) quit = 1;
 s[len] = '\0';
}

char name[9];
char blockname[5];
char sizebuf[5];

main(int argc, char **argv)  
{
	FILE *fp;
	long  blocksize;
	char *block;
	int i,j;

	if (argc !=2)
	{
	  printf("whoops\n");
	  exit(1);
	}

	fp = fopen(argv[1],"r");
		
       getstring(fp,name,8);

	printf("id: %s\n\n",name);

	while (1)
	{
	  getstring(fp,blockname,4);
	  if (quit) break;
	  printf("Block: %s\n",blockname);
	  getstring(fp,sizebuf,4);
	  blocksize = (long)sizebuf[3] + (long)sizebuf[2]*256 +
                      (long)sizebuf[1]*256*256 + (long)sizebuf[0]*256*256*256;
	  printf("Size:  %ld\n",blocksize);
          if (blocksize < 65536) {
	    block = (char *)malloc(blocksize);
	    getstring(fp,block,blocksize);
          }

	  if (strcmp(blockname,"CMOD")==0)
	  {
	    printf("channel modes: ");
	    for (i=0; i<blocksize/2; i++)
	      printf("%d ",(int)block[i*2+1] + (int)block[i*2]);
           printf("\n\n");
	  }
	  else if (strcmp(blockname,"SAMP")==0)
	  {
	    for (i=0; i<blocksize/32; i++)
	    {
             printf("%20s ",&block[i*32]);
	      for (j=20; j<32; j++)
               printf("%2x ",block[i*32+j]);
             printf("\n");
           }
	    printf("\n");
	  }
	  else if (strcmp(blockname,"SPEE")==0)
	  {
	    printf("speed = %d\n\n",(int)block[1] + (int)block[0]*256);
	  }
	  else if (strcmp(blockname,"PLEN")==0)
	  {
	    printf("pattern length = %d\n\n",(int)block[1] + (int)block[0]*256);
	  }
	  else if (strcmp(blockname,"SLEN")==0)
	  {
	    printf("song length = %d\n\n",(int)block[1] + (int)block[0]*256);

      	  }
          else if (strcmp(blockname,"SBOD")==0)
          {
          }
	                          
	  free(block);
          getchar();
	}


	close(fp);
}
