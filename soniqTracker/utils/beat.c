#include <stdio.h>

main()
{
  int i;

  printf("beattab anop\n");

  for (i=0; i<255; i++)
  {
    if (i%16 == 0) printf(" dc i2'");
/*    printf("%u",(int)(2350000.0/((float)i*60.0))); */
    printf("%u",(int)((float)i*500.0*1.05/255.0));
    if (i%16 == 15 || i==254) printf("'\n"); else printf(",");
  }
  printf("\n");

}
