/*************************************************************************

 irc experience ground creation

 *************************************************************************/

#include <stdio.h>
#include <quickdraw.h>

int main(int argc, char *argv[])
{
  int i,bot,col;

  startgraph(320);

  SetPenMode(modeCopy);
  SetSolidPenPat(15);

  bot = 160-160*16;
  col = 7;

  for (i=0; i<320; i++)
  {
    SetSolidPenPat(col);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    MoveTo(i,112); LineTo(bot++,200);
    col++;             
    if (col==15) col=7;
  }                            

  getchar();

  endgraph();
  return 0;
}
