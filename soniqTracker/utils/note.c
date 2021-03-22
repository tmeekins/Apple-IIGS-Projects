#include <stdio.h>

int notes[] = { 56, 60, 63, 67, 71, 75, 80, 85, 90, 95,101,107,
	       113,120,127,135,143,151,160,170,180,190,202,214,
               226,240,254,269,285,302,320,339,360,381,404,428,
               453,480,508,538,570,604,640,678,720,762,808,856,
               1024 };

main()
{

int period,note;

  printf("notetab anop\n");

  period = 0;
  note = 0;
  while (period < 1024)
  {
    if (period%16 == 0) printf(" dc i2'");
    if (period >= notes[note]) note++;
    printf("%d",note);
    if (period%16 == 15 || period==1024) printf("'\n"); else printf(",");
    period++;
  }
  printf("\n");
    
}
