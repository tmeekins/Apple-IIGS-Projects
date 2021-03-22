/*
 *  PWD Utility - Written by Brian Clark
 *
 *      This utility displays the current working directory.
 *      I place this program into the public domain.
 *
 *      4/1/93 - Fixed for loop to properly print the pathname. It was
 *               offset by one, which it shouldn't have. Tim Meekins
 *
 *  USAGE: pwd
 *
 *  NOTE:
 *
 *      This program should be placed in your 6/ prefix and in your command
 *      table as a utility. This program is restartable, so if you use it
 *      alot, you may wish to code an asterisk before the U in the command
 *      table. This will keep it memory resident for faster execution.
 */

#pragma memorymodel     0
#pragma stacksize       2048
#pragma lint            1+2
#pragma optimize	-1
#pragma keep "pwd"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <orca.h>
#include <types.h>
#include <gsos.h>

/* foward function declarations */
void error_routine (unsigned num, unsigned place);


void main (void)
{
    /* prints the present working directory as a header */

    ResultBuf255 prefix_name = { 257 };
    PrefixRecGS temp = { 2, 0, &prefix_name };
    unsigned i, len, error_num;
    char ch;

    putchar ('\n');

    GetPrefixGS (&temp);
    if ( error_num = toolerror () )
        error_routine (error_num,4);

    len = (temp.buffer.getPrefix) -> bufString.length;

    /* spit out the characters, substituting a slash for all the colons */

    for (i = 0 ; i < len ; i++) {
        if ( (ch = (temp.buffer.getPrefix) -> bufString.text[i]) == ':')
                putchar ('/');
        else
                putchar (ch = tolower(ch));
        }

    puts ("=\n");
}

void error_routine (unsigned num, unsigned place)
{
    /* a cheapo error routine */

    printf ("\nGS/OS Error Number $%X at %d\n",num,place);
    exit (-1);
}
