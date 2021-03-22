/*************************************************************************

 irc experience ground scroller calculator

 *************************************************************************/

#include <stdio.h>
#include <quickdraw.h>

FILE *fp;

byte scb[200] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		  0, 0, 1, 2, 1, 1, 2, 2, 2, 2,  /* 112 */
		  1, 1, 1, 1, 1, 1, 1, 1, 2, 2,
		  2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
		  2, 2, 2, 2, 1, 1, 1, 1, 1, 1,
		  1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
		  1, 1, 1, 1, 1, 1, 1, 1, 2, 2,
		  2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
		  2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
		  2, 2, 2, 2, 2, 2, 2, 2, 2, 2 };

int counter[9] = { 0, 1, 1, 2, 4, 8, 16, 24, 32 };
float offset[9] =  { 0, 0, 1, 2, 4, 8, 16, 32, 56 };
float inc[9] = { 0.0, 0.03125, 0.03125, 0.0625, 0.125, 0.25, 0.5, 0.75, 1.0 };

putscb()
{
  int i;

  for (i=0; i<200; i++)
    SetSCB(i,(int)scb[i]);
}

makescb()
{
  int i,j,c;

  c = 6;
  for (i=87; i!=0; i--)
  {
    for (j=0; j<9; j++)
      if (i==(int)offset[j])
        c++;
    scb[112+i] = c;
  }
}

writescb(int n)
{
  int i,c;

  c = 10;

  fprintf(fp,"scb%d ",n);
  for (i=0; i<88; i++)
  {
    if (c==10) { fprintf(fp," dc i1'"); c=0; }
    fprintf(fp,"%d",scb[112+i]);
    c++;
    if (c==10 || i==87)
      fprintf(fp,"'\n");
    else
      fprintf(fp,",");
  }
}

int main(int argc, char *argv[])
{
  int i,j;

  startgraph(320);

  SetColorEntry(6,0,0x0f00);
  SetColorEntry(7,0,0x0ff0);
  SetColorEntry(8,0,0x0e00);
  SetColorEntry(9,0,0x0ee0);
  SetColorEntry(10,0,0x0d00);
  SetColorEntry(11,0,0x0dd0);
  SetColorEntry(12,0,0x0c00);
  SetColorEntry(13,0,0x0cc0);
  SetColorEntry(14,0,0x0b00);
  SetColorEntry(15,0,0x0bb0);
                          
  fp = fopen("scroll.dat","w");

  makescb();
  putscb();
  writescb(0);
  for (i=0; i<32; i++)
  {
    for (j=0; j<9; j++)
      offset[j] += inc[j];
    makescb();
    putscb();
    writescb(i+1);
  }

  getchar();

  fclose(fp);
  endgraph();
  return 0;
}
