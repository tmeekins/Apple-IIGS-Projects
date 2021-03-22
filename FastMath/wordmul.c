/* constant multiplication 65816 compiler */
/* used for performing strength reductions in compilers */
/* written by Tim Meekins */

/* this version does 16-bit multiplications */
/* works if mcand is positive or negative   */
/* the extra asl followed by a SBC does not cause overflow */
/* same code works for signed and unsigned multiplications */
/* if the constant multiplier is negative, then an inverter is used */

#include <stdio.h>

int mult,sign;
int flag,cnt,stkptr,stack[16],last_cnt,last_shift,ts;


/* WARNING: this is as fancy as we can get doing shifts. For example */
/* a shift by 7 cannot be done with an XBA/AND #$FF00/LSR as the upper-most */
/* bit(s) will be lost */

shiftleft(int count)
{
    int c;

    c = count;

    if (c > 7)
        { printf("  xba\n  and #$FF00\n"); c = c - 8; }
    while (c)
        { printf("  asl a\n"); c--; }
}

int trim_trailing(int one_zero)
{
    int c;
    for (c=0; ((mult & 1) == one_zero); c++, mult>>=1);
    return c;
}

multiply()
{
    stkptr = 0;
    if (mult < 0) { sign = 1; mult = -mult; } else sign = 0;
    if (mult > 0)
    {
        last_cnt = 0;
        last_shift = trim_trailing(0); /* cut trailing 0's */
        while (1)
        { /* decompose "mult", build stacked instructions */
            cnt = trim_trailing(1); /* count low-order 1's */
            if (cnt > 1)
            { /* more than 1 bit, use shift-subtract */
                flag = 0;
                if (last_cnt == 1)
                /* shift k, sub, shift 1, add --> shift k+1, sub */
                    /* overwrite last entry */
                    stack[stkptr = 1] = -(cnt+1);
                else
                    stack[stkptr++] = -cnt;
            }

            /* will need another shift - add */
            else flag = 1;

            /* "mult" fully decomposed, time to output */
            if (mult == 0) break;

            /* count low-order zeros */
            last_cnt = trim_trailing(0)+flag;
            stack[stkptr++] = last_cnt; /* shift-add */
        }

        /* now output code from stack */

        printf("\n  lda mcand\n"); /* load working register */
        while (stkptr > 0)
        {
            ts = stack[--stkptr]; /* get top of stack element */
            if (ts < 0) { shiftleft(-ts); printf("  sec\n  sbc mcand\n");}
            else        { shiftleft(ts);  printf("  adc mcand\n");       }
        }

        if (last_shift != 0) shiftleft(last_shift);

        if (sign) printf("  eor #$FFFF\n  inc a\n");
    }
    else
        printf("\n  lda #0\n"); /* special case for mult = 0 */
}

main(int argc, char **argv)
{
  int num;

  if (argc != 4)
  {
    printf("usage: %s mcand (*|/|%) const\n",argv[0]);
    exit(1);
  }

  sscanf(argv[3],"%d",&num);

  switch(*argv[2])
  {
    case '*':
      mult = num ; multiply();
      break;
    default:
      printf("unknown operater %c\n",*argv[2]);
  }

}
