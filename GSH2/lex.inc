***********************************************************************
* CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL CONFIDENTIAL *
***********************************************************************
                                                                       
**************************************************************************
*                            
* GNO/Shell 2.0
* constants and data structures for the lexical analysis routines
*
* Written by Tim Meekins and Jawaid Bazyar
* Copyright (C) 1993 by Tim Meekins & Procyon Enterprises, Inc.
*
**************************************************************************

;
; token types
;
T_WORD	gequ	0
T_SINGQUOTE	gequ	2
T_DBLQUOTE	gequ	4
T_BACKQUOTE	gequ	6
T_PIPE	gequ	8
T_AMP	gequ	10
T_LT	gequ	12
T_GT	gequ	14
T_GTGT	gequ	16
T_GTAMP	gequ	18
T_GTGTAMP	gequ	20
T_CR	gequ	22
T_SEMI	gequ	24
T_OPEN	gequ	26
T_CLOSE	gequ	28
T_PIPEAMP	gequ	30
T_BREAK	gequ	32
T_BRKSW	gequ	34
T_CASE	gequ	36
T_ELSE	gequ	38
T_END	gequ	40
T_ENDIF	gequ	42
T_ENDSW	gequ	44
T_EXIT	gequ	46
T_FOREACH	gequ	48
T_GOTO	gequ	50
T_IF	gequ	52
T_SET	gequ	54
T_SWITCH	gequ	56
T_TEST	gequ	58
T_THEN	gequ	60
T_WHILE	gequ	62
;
; token data structure
;
TOK_type	gequ	0	;the token type
TOK_text	gequ	TOK_type+2	;ascii text of the token
TOK_next	gequ	TOK_text+4         ;the next token in the list
TOK_sizeof	gequ	TOK_next+4         ;number of bytes in this node
;
; bit flags for character types
;
CH_SINGQUOTE	gequ	%0000000000000001	;single quote
CH_DOUBQUOTE	gequ	%0000000000000010	;double quote
CH_BACKQUOTE	gequ	%0000000000000100	;back quote
CH_SPACE	gequ	%0000000000001000	;space or tab
CH_SEMICOLON	gequ	%0000000000010000	;semicolon
CH_AMPERSAND	gequ	%0000000000100000	;ampersand
CH_GREATER	gequ	%0000000001000000	;greater than
CH_LESS	gequ	%0000000010000000	;less than
CH_LEFTPAREN	gequ	%0000000100000000	;left parentheses
CH_RIGHTPAREN	gequ	%0000001000000000	;right parentheses
CH_PIPE	gequ	%0000010000000000	;pipe, vertical bar
CH_NEWLINE	gequ	%0000100000000000	;carriage return, newline
CH_EOF	gequ	%0001000000000000	;end-of-file
CH_BACKSLASH	gequ	%0010000000000000	;backslash
