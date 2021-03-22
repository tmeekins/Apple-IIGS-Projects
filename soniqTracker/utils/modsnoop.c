/* mod snooper 1.1, by Tim Meekins, 4/29/92 */


/* USAGE: modsnoop [-15 | -31] module       */

#include <stdio.h>
#pragma optimize -1

char *notenames[] = { "C-1", "C#1", "D-1", "D#1", "E-1", "F-1", "F#1", "G-1",
                      "G#1", "A-1", "A#1", "B-1",
                      "C-2", "C#2", "D-2", "D#2", "E-2", "F-2", "F#2", "G-2",
                      "G#2", "A-2", "A#2", "B-2",
                      "C-3", "C#3", "D-3", "D#3", "E-3", "F-3", "F#3", "G-3",
                      "G#3", "A-3", "A#3", "B-3",
                      "C-4", "C#4", "D-4", "D#4", "E-4", "F-4", "F#4", "G-4",
                      "G#4", "A-4", "A#4", "B-4" };
                                               
int periods[] = { 856, 808, 762, 720, 678, 640, 604, 570, 538, 508, 480, 453,
                  428, 404, 381, 360, 339, 320, 302, 285, 269, 254, 240, 226,
                  214, 202, 190, 180, 170, 160, 151, 143, 135, 127, 120, 113,
	          106, 100,  94,  89,  84,  79,  75,  71,  67,  63,  59,  56 };

void printnote(int note)
{
  int i;

  if (note==0)
  {
    printf("   ");
    return;
  }

  for (i=0; i<48; i++)
    if (note >= periods[i])
    {
      printf(notenames[i]);
      return;
    }
  printf("???");

}
                                                 
char *getstring(FILE *f, int len)
{
 char s[150];
 int i;

 for (i=0; i<len; i++)
   s[i] = fgetc(f);
 s[len] = '\0';
 return s;
}

main(int argc, char **argv)
{
  FILE *fp;
  int nvoices = 31;
  int loop;
  int num_patterns = 0;
  int temp;
  int pat_num;
  int notes;
  int channel;
  char note1,note2,note3,note4,temp0;
  int key;
  int songlen;

  temp = 2;
  if (argc!=2 && argc!=3)
  {
     fprintf(stderr,"Usage: %s [-15|-31] filename\n",argv[0]);
     exit(1);
  }

  if (strcmp(argv[1],"-15")==0)
    nvoices = 15;
  else if (strcmp(argv[1],"-31")==0)
    nvoices = 31;
  else
    temp--;

  fp = fopen(argv[temp], "r");
  if (fp==NULL)
  {
    fprintf(stderr,"whoops! can't seem to read the file %s\n",argv[temp]);
    exit(1);
  }

  asm { sta 0xe1c010 }

  printf("\nModule : %s\n\n",getstring(fp,20));

  for (loop = 1; loop <= nvoices; loop++)
  {
        asm { lda 0xe1c000
              sta key }
        if (key & 0x80)
        {
          asm { sta 0xe1c010 }
          if ((key & 0x7f) ==0x1b) exit(0);
          asm { lda 0xe1c000
                sta key }
          while (!(key & 0x80))
            {
              asm { lda 0xe1c000
                    sta key }
            }
          asm { sta 0xe1c010 }
        }
    printf("%6d : %s\n", loop, getstring(fp,22));
    printf("       : length = %u ",((fgetc(fp) << 8) | fgetc(fp)) * 2);
    printf("fintune = %u ",fgetc(fp));
    printf("volume = %u ",fgetc(fp));
    printf("rep_start = %u ",((fgetc(fp)<<8) | fgetc(fp)) * 2);
    printf("rep_end = %u\n",((fgetc(fp)<<8) | fgetc(fp)) * 2);
  }                                                         

  printf("\nLength : %d\n",songlen=fgetc(fp));
  printf("Sync Byte: %d\n\n",fgetc(fp));

  printf("Postition table:\n");
  for (loop = 0; loop < 128; loop++)
  {
    fread(&temp0,1,1,fp);
    if (loop < songlen)
    {
      printf("%2d ",(int)temp0);
      if ((loop+1) % 20 == 0) printf("\n");
    } 
    if (temp0 > num_patterns)
      num_patterns = temp0;
  }
  num_patterns++;
  printf("\n\n");

  if (nvoices==31)
    printf("   Sig : %s\n\n",getstring(fp,4));

  for (pat_num = 0; pat_num < num_patterns; pat_num++)
  {
     printf("Pattern: %d\n",pat_num);
     for (notes=0; notes<64; notes++)
     {
        asm { lda 0xe1c000
              sta key }
        if (key & 0x80)
        {
          asm { sta 0xe1c010 }
          if ((key & 0x7f) ==0x1b) exit(0);
          asm { lda 0xe1c000
                sta key }
          while (!(key & 0x80))
            {
              asm { lda 0xe1c000
                    sta key }
            }
          asm { sta 0xe1c010 }
        }
        printf("%6d : ",notes);
        for (channel = 0; channel < 4; channel++)
        {
           fread(&note1,1,1,fp);
           fread(&note2,1,1,fp);
           fread(&note3,1,1,fp);
           fread(&note4,1,1,fp);
           printnote(((note1 & 0x0F)<<8) | note2);
           temp = ((note3 & 0xF0)>>4) | (note1 & 0xF0);
           if (temp==0) printf("    ");
           else printf(" %02d ",temp);
           temp = ((note3 & 0x0F) << 8) | note4;
           if (temp==0) printf("    | ");
           else printf("%03x | ",temp);
        }
        printf("\n");
     }
     printf("\n");
  }

}
