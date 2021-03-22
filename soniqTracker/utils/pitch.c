#include <stdio.h>

#define uS 125.0
#define SR 2631.985

main()
{
  int loop,key;
  float dummy1, dummy2,k;

  k = SR / (102.579);
  k = k * 2.0;

  printf("pitchtab dc i2'0'\n");

  for (loop = 1; loop < 1024; loop++)
  {
    dummy1 = 3575872.0 / (float)loop;
   if ((loop-1)%8 == 0) printf(" dc i2'");
   printf("$%lx",(long int)(dummy1/k));
   if ((loop-1)%8 == 7 || loop==1023) printf("'\n"); else printf(",");
  }
  printf("\n");

}
