#
# GNO/Shell 2.0 makefile
# Written by Tim Meekins
#

o/bufpool.root: bufpool.asm lex.inc parse.inc m/bufpool.mac
  purge ; compile bufpool.asm keep=o/bufpool

o/edit.root: edit.asm
  purge ; compile edit.asm keep=o/edit

o/error.root: error.asm m/error.mac
  purge ; compile error.asm keep=o/error

o/lex.root: lex.asm lex.inc error.inc m/lex.mac
  purge ; compile lex.asm keep=o/lex

o/main.root: main.asm m/main.mac
  purge ; compile main.asm keep=o/main

o/parse.root: parse.asm lex.inc parse.inc error.inc m/parse.mac
  purge ; compile parse.asm keep=o/parse

o/shell.root: shell.asm m/shell.mac
  purge ; compile shell.asm keep=o/shell

o/shellutil.root: shellutil.asm m/shellutil.mac
  purge ; compile shellutil.asm keep=o/shellutil

o/stdio.root: stdio.asm m/stdio.mac
  purge ; compile stdio.asm keep=o/stdio

o/term.root: term.asm m/term.mac
  purge ; compile term.asm keep=o/term

gsh2: o/bufpool.root \
      o/edit.root \
      o/error.root \
      o/lex.root \
      o/main.root \
      o/parse.root \
      o/shell.root \
      o/shellutil.root \
      o/stdio.root \
      o/term.root
  purge ; compile link.script

                                   
