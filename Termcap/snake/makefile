snake.root: snake.c snake.h pathnames.h
  compile snake.c keep=snake

move.root: move.c snake.h
  compile move.c keep=move

snake: snake.root move.root
  link snake move keep=snake
