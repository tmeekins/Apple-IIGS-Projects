#include <stdio.h>

int hex[24] = {0xff,0xe5,0xcc,0xbf,0xb2,
               0xac,0x99,0x85,0x7f,0x72,
               0x66,0x5f,0x59,0x4c,0x3f,
               0x39,0x33,0x2c,0x26,0x1f,
               0x19,0x13,0x0c,0x06};

main()
{
  int i,j;

  printf("voltab anop\n");
  for (i=0; i<0x40; i++)
  {
    if (i%16 == 0) printf(" dc i1'");
    printf("$%x",i*0xbf/0x3f);
    if (i%16 == 15) printf("'\n"); else printf(",");
  }

  printf("\nvoltab2 anop\n");
  for (i=0; i<0x40; i++)
  {
    if (i%16 == 0) printf(" dc i1'");
    printf("$%x",i*0xbf/0x3f);
    if (i%16 == 15) printf("'\n"); else printf(",");
  }

  for (j=0; j<24; j++)
  {

  	printf("\nvoltab%02x anop\n",hex[j]);
  	for (i=0; i<0x40; i++)
  	{
    	  if (i%16 == 0) printf(" dc i1'");
    	  printf("$%x",i*hex[j]/0x3f);
    	  if (i%16 == 15) printf("'\n"); else printf(",");
  	}
  }

}                     
