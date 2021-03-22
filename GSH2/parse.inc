***********************************************************************
* CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL CONFIDENTIAL *
***********************************************************************
                                                                       
**************************************************************************
*                            
* GNO/Shell 2.0
* constants and data structures for the command parser
*
* Written by Tim Meekins and Jawaid Bazyar
* Copyright (C) 1993 by Tim Meekins & Procyon Enterprises, Inc.
*
**************************************************************************

;
; redirection flags
;
RD_NONE	gequ	0
RD_PIPE	gequ	1
RD_FILE	gequ	2
RD_APP	gequ	3
;
; execution flags
;
FL_BACKGROUND	gequ	1
FL_SEQUENCE	gequ	2
;
; command data structure
;
CMD_argv	gequ	0	;(token) argv structure
CMD_stdin	gequ	CMD_argv+4	;(int) stdin flags
CMD_stdout	gequ	CMD_stdin+2	;(int) stdout flags
CMD_stderr	gequ	CMD_stdout+2	;(int) stderr flags
CMD_stdinfile	gequ	CMD_stderr+2	;(token) stdin file
CMD_stdoutfile	gequ	CMD_stdinfile+4	;(token) stdout file
CMD_stderrfile	gequ	CMD_stdoutfile+4	;(token) stderr file
CMD_next	gequ	CMD_stderrfile+4	;(CMD *) next command
CMD_flags	gequ	CMD_next+4	;(int) flags
CMD_sequence	gequ	CMD_flags+2	;(CMD *) command sequence
CMD_sizeof	gequ	CMD_sequence+4	;
