#include <stdio.h>

main()
{
  int i,j,b;


  for (j=1; j<16; j++)
  {

  	printf("\nwavtab%02x anop\n",j);
  	for (i=0; i<256; i++)
  	{
          b = i-0x80;
    	  if (i%16 == 0) printf(" dc i1'");
    	  printf("$%x",((b*j)/16)+0x80);
    	  if (i%16 == 15) printf("'\n"); else printf(",");
  	}
  }

}
