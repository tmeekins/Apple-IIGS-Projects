o/omf.a: omf.c omf.h
  compile omf.c keep=o/omf

o/mkobj.root: mkobj.c omf.h
  compile mkobj.c keep=o/mkobj

mkobj: o/mkobj.root o/omf.a
  link o/mkobj o/omf keep=mkobj
