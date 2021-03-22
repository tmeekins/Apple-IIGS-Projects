/* utility for making look-up tables for imagequant */

#include <stdio.h>
main()
{
int i;
int r,g,b;

printf("tables data\n");

printf("redtbl anop\n");
for (i=0;i<256;i++)
{
  r = (int)((float)i * 0.299 * (240.0/255.0));
  g = (int)((float)i * 0.587 * (240.0/255.0));
  b = (int)((float)i * (240.0/255.0)) - (r+g);
  if (i%8 == 0) printf(" dc i1'");
  printf("%d",r);
  if (i%8 == 7) printf("'\n"); else printf(",");
}
printf("\n");

printf("greentbl anop\n");
for (i=0;i<256;i++)
{
  r = (int)((float)i * 0.299 * (240.0/255.0));
  g = (int)((float)i * 0.587 * (240.0/255.0));
  b = (int)((float)i * (240.0/255.0)) - (r+g);
  if (i%8 == 0) printf(" dc i1'");
  printf("%d",g);
  if (i%8 == 7) printf("'\n"); else printf(",");
}
printf("\n");

printf("bluetbl anop\n");
for (i=0;i<256;i++)
{
  r = (int)((float)i * 0.299 * (240.0/255.0));
  g = (int)((float)i * 0.587 * (240.0/255.0));
  b = (int)((float)i * (240.0/255.0)) - (r+g);
  if (i%8 == 0) printf(" dc i1'");
  printf("%d",b);
  if (i%8 == 7) printf("'\n"); else printf(",");
}
printf("\n");

printf("cliptbl anop\n");
for (i=0;i<256;i++)
{
  b = (int)((float)i * (16.0/255.0));
  if (i%8 == 0) printf(" dc i1'");
  printf("%d",b);
  if (i%8 == 7) printf("'\n"); else printf(",");
}
printf("\n");

printf("three8tbl1 anop\n");
for (i=0;i<256;i++)
{
  b = (int)((float)i * (3.0/8.0));
  if (i%8 == 0) printf(" dc i1'");
  printf("%d",b);
  if (i%8 == 7) printf("'\n"); else printf(",");
}
printf("\n");

printf("three8tbl2 anop\n");
for (i=0;i<256;i++)
{
  b = (int)((float)i * (3.0/8.0));
  g = (int)((float)i * (1.0/4.0));
  b = i - (b+g);
  if (i%8 == 0) printf(" dc i1'");
  printf("%d",b);
  if (i%8 == 7) printf("'\n"); else printf(",");
}
printf("\n");

printf("one4tbl anop\n");
for (i=0;i<256;i++)
{
  b = (int)((float)i * (1.0/4.0));
  if (i%8 == 0) printf(" dc i1'");
  printf("%d",b);
  if (i%8 == 7) printf("'\n"); else printf(",");
}
printf("\n");

printf("squaretbl anop\n");
for (i=0;i<256;i++)
{
  if (i%8==0) printf(" dc i2'");
  printf("%ld",(255-(long)i)*(255-(long)i));
  if (i%8 == 7) printf("'\n"); else printf(",");
}
for (i=0;i<256;i++)
{
  if (i%8==0) printf(" dc i2'");
  printf("%ld",(long)i*(long)i);
  if (i%8 == 7) printf("'\n"); else printf(",");
}
printf("\n");

printf(" end\n");

}              
