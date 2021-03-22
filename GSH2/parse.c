/*
 *	parse.c
 *
 *	command line parsing
 *
 *	parse accepts a token list and rearranges the tokens into
 *	a list of command structures
 */

#ifdef __ORCAC__
#pragma noroot
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "lex.h"
#include "parse.h"
#include "error.h"

#pragma optimize -1
#pragma lint -1

void printCommands(command c)
{
    printf("Command list:\n");
    while (c != NULL) {
        printf("-------------------------------------------\n");
        if (c->flags & FL_BACKGROUND) printf("Background\n");
        printf("IN: ");
        switch (c->std_in) {
            case RD_NONE: printf("stdin\t"); break;
            case RD_PIPE: printf("PIPE\t"); break;
            case RD_APP:  printf("can't append to input!\t"); break;
            case RD_FILE: printToken(c->std_in_file); putchar('\t'); break;
            default: assert(0);
        }
        printf("OUT: ");
        switch (c->std_out) {
            case RD_NONE: printf("stdout\t"); break;
            case RD_PIPE: printf("PIPE\t"); break;
            case RD_APP:  printf(">> ");
            case RD_FILE: printToken(c->std_out_file); putchar('\t'); break;
            default: assert(0);
        }
        printf("ERR: ");
        switch (c->std_err) {
            case RD_NONE: printf("stderr\n"); break;
            case RD_PIPE: printf("PIPE\n"); break;
            case RD_APP:  printf(">>& ");
            case RD_FILE: printToken(c->std_err_file); putchar('\n');break;
            default: assert(0);
        }
        if (c->flags & FL_SEQUENCE) {
            printf("sequence\n");
            printCommands(c->sequence);
        } else {
            printf("argv: ");
            printTokenList(c->argv);
        }
        c = c->next;
    }
}

/*
 * parse() recursively calls itself to parse pipes, multiple commands,
 * etc.
 */

command parse(token *inp_ptr,int cl_paren)
{
token prev,inp = *inp_ptr;
command new,head = NULL,tail = NULL;
int error;
unsigned redir = 0;
command newChain;
int prev_type;

    new = malloc(sizeof(struct command));
    newChain = new;
    new->std_in = RD_NONE;
new_new:
    prev = inp;
    if (head == NULL) head = new;
    new->next = NULL;
    if (tail != NULL) tail->next = new;
    tail = new;
    new->argv = NULL;
    new->std_out = RD_NONE;
    new->std_err = RD_NONE;
    new->next = NULL;
    new->flags = 0;

    while (inp) {
        prev_type = inp->type;
        switch (inp->type) {
            case t_word:
            case t_singquote:
            case t_dblquote:
            case t_backquote:
	        prev = inp;
                if (new->argv == NULL) new->argv = prev;
                break;
            case t_lt:
                if (new->std_in) {
                    if (new->std_in == RD_PIPE)
                        shell_error(ERR_PIPE_LT_CONFLICTS);
                    else shell_error(ERR_EXTRA_LT);
                    return NULL;
                }
                if (inp->next == NULL) {
                    shell_error(ERR_NO_FILE_LT);
                    return NULL;
                }
                inp = inp->next;
                if (inp->type < t_backquote) {
                    new->std_in = RD_FILE;
                    new->std_in_file = inp;
                } else {
                    shell_error(ERR_NO_FILE_LT);
                    return NULL;
                }
                prev->next = inp->next;
                break;
            case t_gt:
            case t_gtgt:
                if (new->std_out) {
                    shell_error(ERR_EXTRA_GT);
                    return NULL;
                }
                if (inp->next == NULL) {
                    shell_error(ERR_NO_FILE_GT);
                    return NULL;
                }
                inp = inp->next;
                if (inp->type < t_backquote) {
                    new->std_out = (prev_type == t_gt) ? RD_FILE : RD_APP;
                    new->std_out_file = inp;
                } else {
                    shell_error(ERR_NO_FILE_GT);
                    return NULL;
                }
                prev->next = inp->next;
                break;
            case t_gtamp:
            case t_gtgtamp:
                if (new->std_err) {
                    shell_error(ERR_EXTRA_GTAMP);
                    return NULL;
                }
                if (inp->next == NULL) {
                    shell_error(ERR_NO_FILE_GT);
                    return NULL;
                }
                inp = inp->next;
                if (inp->type < t_backquote) {
                    new->std_err = (prev_type == t_gtamp) ? RD_FILE : RD_APP;
                    new->std_err_file = inp;
                } else {
                    shell_error(ERR_NO_FILE_GT);
                    return NULL;
                }
                prev->next = inp->next;
                break;
            case t_semi:
            case t_cr:
            case t_amp:
        	if ((new->argv == NULL) &&
                    (new->std_out || new->std_in || new->std_err)) {
                    shell_error(ERR_NULL_COMMAND);
                    return NULL;
                }
                if (inp->type == t_amp) new->flags |= FL_BACKGROUND;

                inp = inp->next;
                prev->next = NULL; /* end of this command */
                new->next = malloc(sizeof(struct command));
                new = new->next;
    		new->std_in = RD_NONE;
                goto new_new;
	        
            case t_pipeamp:
            case t_pipe:
	        if (new->std_out) {
                    shell_error(ERR_PIPE_CONFLICTS);
                    return NULL;
                }
                new->std_out = RD_PIPE;
                if (inp->type == t_pipeamp) {
                  if (new->std_err) {
                    shell_error(ERR_PIPE_ERR_CONFL);
                    return NULL;
                  }
                  new->std_err = RD_PIPE;
                }

                inp = inp->next;

                prev->next = NULL; /* end of this command */
		new->next = malloc(sizeof(struct command));
                new = new->next;
                new->std_in = RD_PIPE;
                goto new_new;
            case t_open:
                if (new->argv != NULL) {
                    if ((new->argv->type < t_backquote) &&
                        !strcmp(new->argv->text,"foreach")) {
	        	prev = inp;
                	break;
                    }
	    	    else if (new->argv->type != t_open) {
                	shell_error(ERR_BAD_USE_PARENS);
                	return NULL;
                    }
                }
        	prev = inp->next;
                new->flags |= FL_SEQUENCE;
                new->sequence = parse(&prev,1);
                inp = prev;
                break;
            case t_close:
                if (new->argv != NULL) {
                    if ((new->argv->type < t_backquote) &&
                        !strcmp(new->argv->text,"foreach")) {
                	/*printToken(inp);*/
                	prev = inp;
                	break;
                    } else if (!cl_paren) {
                	shell_error(ERR_NO_MATCHING_OP);
                	return NULL;
                    }
        	}
                /*inp = inp->next;*/
                prev->next = NULL; /* end of this command */
                *inp_ptr = inp;
                return newChain;
            default:
                printf("error in parse(): \n");
                printToken(inp);
                assert(0);
        }
        inp = inp->next;
    }
    if ((new->argv == NULL) &&
        (new->std_out | new->std_in | new->std_err)) {
        shell_error(ERR_NULL_COMMAND);
        return NULL;
    }
    /*printCommands(newChain);*/
    *inp_ptr = inp;
    return newChain;
}
