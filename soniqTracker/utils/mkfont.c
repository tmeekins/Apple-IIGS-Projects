#include <stdio.h>

unsigned char table[128][8];
unsigned char widths[128];

unsigned char bittab[] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01 };

main()
{
  int i,j;
  FILE *fp;
  char ch;
  int width;

  for (i=0; i<128; i++)
    {
      widths[i] = 0;
      for (j=0; j<8; j++)
        table[i][j] = 0;
    }

  fp = fopen("font.def","r");

  while ((ch=fgetc(fp))!=EOF)
  {
    width = (int)(fgetc(fp)-'0');
    if (width<1) break;
    widths[ch]=width;
    while (fgetc(fp) != '\n'); /* eat cr */
    for (j=0; j<7; j++)
      {
        for (i=0; i<width; i++)
          if (fgetc(fp)=='#')
            table[ch][j] |= bittab[i];
        while (fgetc(fp) != '\n'); /* eat cr */
      }
  }

  printf("fonttab anop\n");

  for (i=0; i<128; i++)
    {
      printf(" dc h'");
      for (j=0; j<7; j++) printf("%02x",table[i][j]);
      printf("00'\n"); /* pad to 8 bytes */
    }


  printf("fontlen anop\n");
  for (i=0; i<128; i++)
    {
      if (i%16==0) printf(" dc h'");
      printf("%02x", widths[i]);
      if (i%16==15) printf("'\n");
    }

}
