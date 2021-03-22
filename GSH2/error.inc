***********************************************************************
* CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL  CONFIDENTIAL CONFIDENTIAL *
***********************************************************************
                                                                       
**************************************************************************
*                            
* GNO/Shell 2.0
* Error constants for GNO/Shell
*
* Written by Tim Meekins
* Copyright (C) 1993 by Tim Meekins & Procyon Enterprises, Inc.
*
**************************************************************************

;
; error numbers
;
ERR_MISS_DBL 		gequ  1*2
ERR_MISS_SING 		gequ  2*2
ERR_MISS_BACK 		gequ  3*2
ERR_NO_FILE_GT 	gequ  4*2
ERR_EXTRA_LT 		gequ  5*2
ERR_NO_FILE_LT 	gequ  6*2
ERR_EXTRA_GT 		gequ  7*2
ERR_EXTRA_GTAMP 	gequ  8*2
ERR_PIPE_CONFLICTS 	gequ  9*2
ERR_PIPE_LT_CONFLICTS gequ 10*2
ERR_BAD_USE_PARENS 	gequ  11*2
ERR_NO_MATCHING_OP 	gequ  12*2
ERR_PIPE_ERR_CONFL 	gequ  13*2
ERR_NULL_COMMAND 	gequ  14*2
;
; application numbers
;
APP_GSH		gequ  0*2
