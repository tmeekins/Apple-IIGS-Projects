#include <stdio.h>
#include <stdlib.h>

#define MAXJSAMPLE	255L
#define SCALEBITS	16
#define ONE_HALF	((long) 1 << (SCALEBITS-1))
#define FIX(x)		((long) ((x) * (float)(1<<SCALEBITS) + 0.5))
#define RIGHT_SHIFT(x,shft)	((x) >> (shft))
                          
void main(void)
{
  int i;
  long x2;
  float val;

  printf("JPEGTBL\tDATA\tiqjpeg\n\n");

  printf("Cr_r_tab\tanop\n");

  for (i=0; i<=MAXJSAMPLE; i++) {
     x2 = 2L*(long)i - MAXJSAMPLE;
     val = ((1.40200/2.0)*(65536.0))*(float)x2 + (float)ONE_HALF;
     printf("\tdc\ti2'$%x'\n",RIGHT_SHIFT((long)val, SCALEBITS));
  }

  printf("Cr_b_tab\tanop\n");

  for (i=0; i<=MAXJSAMPLE; i++) {
     x2 = 2L*(long)i - MAXJSAMPLE;
     val = ((1.77200/2.0)*(65536.0))*(float)x2 + (float)ONE_HALF;
     printf("\tdc\ti2'$%x'\n",RIGHT_SHIFT((long)val, SCALEBITS));
  }

  printf("Cr_g_tab\tanop\n");

  for (i=0; i<=MAXJSAMPLE; i++) {
     x2 = 2L*(long)i - MAXJSAMPLE;
     val = -((0.71414/2.0)*(65536.0))*(float)x2;
     printf("\tdc\ti4'$%lx'\n",(long)val);
  }

  printf("Cb_g_tab\tanop\n");

  for (i=0; i<=MAXJSAMPLE; i++) {
     x2 = 2L*(long)i - MAXJSAMPLE;
     val = -((0.34414/2.0)*(65536.0))*(float)x2 + (float)ONE_HALF;
     printf("\tdc\ti4'$%lx'\n",(long)val);
  }

  printf("\tEND\n");

}
