#include <stdio.h>

int vib[32] = {0, 25, 49, 71, 90, 106, 117, 125, 127, 125, 117, 106, 90,
               71, 49, 25, 0, -25, -49, -71, -90, -106, -117, -125, -127, -125,
               -117,-106, -90, -71, -49, -25 };

main()
{
  int depth,i;

  for (depth = 0; depth < 16; depth++)
  {
    printf("vibtbl%d dc c'",depth);
    for (i=0; i<32; i++)
      printf("%d, ",(vib[i] * depth)/64);
    printf("'\n");
  }

}
