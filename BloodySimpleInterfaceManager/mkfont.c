/*********************************************************
 *
 * Compiles fonts for BSI
 * Original version by Jawaid Bazyar for Telecom II
 * Rewritten by Tim Meekins for BSI
 *
 *********************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <types.h>

void usage(void)
{
    fprintf(stderr,"usage: mkfont screenname outname\n");
    exit(1);
}

FILE *f;
word c_ind = 0;
struct c_buf {
    word c_image;
    word c_addr;
};

struct c_buf c_arr[8];

void add_c(word im, word ad)
{
    c_arr[c_ind].c_image = im;
    c_arr[c_ind++].c_addr = ad;
}

void add_i(word im, word ad)
{
    word new;
    int i;

    new = 0;
    for (i=0; i<8; i++)
    {
        new = new << 2;
        if ((im>>((7-i)*2))&0x03)
            new |= 0x03;
        else
            new |= 0x02;
    }

    c_arr[c_ind].c_image = new;
    c_arr[c_ind++].c_addr = ad;
}

int compr(struct c_buf *a, struct c_buf *b)
{
    if (a->c_image > b->c_image) return 1;
    else if (a->c_image == b->c_image) return 0;
    else return -1;
}

void opt_c(void)
{
word last;
int i;
    qsort(c_arr, 8, sizeof(struct c_buf), compr);
    last = c_arr[0].c_image+1;
    for (i = 0; i < 8; i++) {
        if (last != c_arr[i].c_image)
	    fprintf(f,"\tlda #$%04X\n",c_arr[i].c_image);
        last = c_arr[i].c_image;
        fprintf(f,"\tsta $2000+%d,y\n",c_arr[i].c_addr);
    }
}

/* The font code accepts offset onto screen in Y register, and X is char to
   draw * 2 */

#define ADDR(base,ind) (*((word *)(base+ind)))

int main(int argc, char *argv[])
{
char *x;
word *x1;
int fd;
unsigned int row,col,addr,i;

    if (argc < 3) usage();
    x = malloc(32768l);
    x1 = (word *) x;
    fd = open(argv[1],O_RDONLY);
    read(fd,x,0x8000);
    close(fd);
    printf("x: %06lX\n",x);

    f = fopen(argv[2],"w");
    fprintf(f,"DEF_FONT\tSTART bsi\n");
    /* output the jump table */
    for (i = 0; i < 256; i++) {
        fprintf(f,"\tdc a2'char%02X'\t; ascii %d\n",i,i);
    }
    for (i = 0; i < 128; i++) {
        col = (i % 32);
        row = (i / 32) - 1;
        if (i <32) row = (129/32)-1;
        addr = row * 640 + col;
        c_ind = 0;
        add_c(ADDR(x1,addr+0),0);
        add_c(ADDR(x1,addr+80),160);
        add_c(ADDR(x1,addr+160),320);
        add_c(ADDR(x1,addr+240),480);
        add_c(ADDR(x1,addr+320),640);
        add_c(ADDR(x1,addr+400),800);
        add_c(ADDR(x1,addr+480),960);
        add_c(ADDR(x1,addr+560),1120);  
                                   
        fprintf(f,"char%02X\tanop\t; %04X\n",i,addr);
	opt_c();
        fprintf(f,"\tplb\n");
        fprintf(f,"\trts\n");
    }
    for (i = 0; i < 128; i++) {
        col = (i % 32);
        row = (i / 32) - 1;
        if (i <32) row = (129/32)-1;
        addr = row * 640 + col;     
        c_ind = 0;
        add_i(ADDR(x1,addr+0),0);
        add_i(ADDR(x1,addr+80),160);
        add_i(ADDR(x1,addr+160),320);
        add_i(ADDR(x1,addr+240),480);
        add_i(ADDR(x1,addr+320),640);
        add_i(ADDR(x1,addr+400),800);
        add_i(ADDR(x1,addr+480),960);
        add_i(ADDR(x1,addr+560),1120);  
                                   
        fprintf(f,"char%02X\tanop\t; %04X\n",i+128,addr);
	opt_c();
        fprintf(f,"\tplb\n");
        fprintf(f,"\trts\n");
    }
    fprintf(f,"\tEND\n");
    fclose(f);
}
                                           
