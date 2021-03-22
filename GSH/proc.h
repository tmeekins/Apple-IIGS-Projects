/*
         Kernel Process table structure
         Copyright 1991 Procyon, Inc.
*/

#ifndef PROC_KERN
#define PROC_KERN

#include <types.h>
#include <gno/signal.h>

/* the various process states are defined here */

#define procUNUSED 0
#define procRUNNING 1
#define procREADY 2
#define procBLOCKED 3
#define procNEW 4
#define procSUSPENDED 5
#define procWAIT 6
#define procWAITSIGCH 7
#define procPAUSED 8

#define SYSERR -1
#define SYSOK 0

#define rtGSOS 0
#define rtPIPE 1
#define rtTTY 2

#define rfPIPEREAD 1    /* read end of the pipe */
#define rfPIPEWRITE 2   /* write end of the pipe */
#define rfCLOSEEXEC 4   /* close this file on an exec() */
#define rfP16NEWL 8     /* special prodos-16 newline mode */

typedef struct fdentry {
    word refNum;        /* refNum, pipeNum, or ttyID */
    word refType;       /* 0 = GS/OS refnum, 1 = pipe, 2 = tty */
    word refLevel;      /* "file level" of the refnum */
    word refFlags;      /* see flags above */
    word NLenableMask;  /* these three fields are for newline handling */
    word NLnumChars;
    void *NLtable;
} fdentry, *fdentryPtr;

typedef struct fdtable {
    word fdCount;
    word fdLevel;
    fdentry fds[32];
} fdtable, *fdtablePtr;

typedef struct quitStack {
  struct quitStack *next;
  char data[1];
} quitStack;

/* these flags are set by execve() and fork() during process creation. */
   
#define FL_RESOURCE 1      /* does the process have and use a resource fork? */
#define FL_FORKED 2        /* was the process started with fork() ? */
#define FL_COMPLIANT 4     /* is the process fully GNO compliant? */
#define FL_NORMTERM 8      /* did the program terminate via exit()? 1=yes */
#define FL_RESTART 16      /* is the program restartable? (set by QuitGS) */
#define FL_NORESTART 32    /* don't allow this code to restart */
#define FL_QDSTARTUP 64    /* flag set if QDStartUp was called */

struct pentry {
0   int parentpid;      /* pid of this process' parent */
2   int processState;
4   int userID;         /* a GS/OS UserID, used to keep track of memory */
6   int ttyID;          /* driver (not GS/OS) number of i/o port */
8   word irq_A;          /* context information for the process */
10   word irq_X;
12   word irq_Y;
14   word irq_S;
16   word irq_D;
18   byte irq_B;
19   byte irq_B1;
20   word irq_P;
22   word irq_state;
24   word irq_PC;
26   word irq_K;
28   int psem;           /* semaphoreID process is blocked on */
30   char **prefix;      /* cwd's (GS/OS prefixes 0,1, and 9 */
34   char *args;         /* the command line that invoked the process program */
38   char **env;         /* environment variables for the program */
42   struct sigrec *siginfo; /* global mask of which signals are blocked */
46   byte irq_SLTROM;
47   byte irq_STATEREG;
48   word lastTool;
50   longword ticks;
54   word flags;
56   fdtablePtr openFiles;
60   word pgrp;
62   word exitCode;
64   void *LInfo;
68   word stoppedState;  /* process state before stoppage */
70   longword alarmCount;
74   void *executeHook; /* for a good time call... */
78   word queueLink;
#ifdef KERNEL
80   chldInfoPtr waitq;   /* where waits wait to be processed */
#else
80   void *waitq;
#endif
84   int waitdone;
86   int flpid;
88   quitStack *returnStack;
92   word t2StackPtr;
94,96   word p_uid, p_gid;
98,100   word p_euid, p_egid;
   word unused4[13];
};
typedef struct pentry procState, *procStatePtr;

#ifdef KERNEL
struct kernelStruct {
    procState procTable[32];
    int curProcInd;
    int userID;
    int mutex;
    int timeleft;
    int numProcs;
    word truepid;
    word shutdown;
    word gsosDebug;
    int floatingPID;
};
typedef struct kernelStruct kernelStruct, *kernelStructPtr;

#endif /* KERNEL */
#endif /* PROC_KERN */
