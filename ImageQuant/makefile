o/iq.root: iq.asm iq.mac iq.h
  compile iq.asm keep=o/iq

o/iqres.root: iqres.asm
  compile iqres.asm keep=o/iqres

o/load.root: load.asm load.mac iq.h
  compile load.asm keep=o/load

o/bw.root: bw.asm bw.mac iq.h
  compile bw.asm keep=o/bw

o/c320.root: c320.asm c320.mac iq.h
  compile c320.asm keep=o/c320

o/c3200.root: c3200.asm c3200.mac iq.h
  compile c3200.asm keep=o/c3200

o/octree.root: octree.asm octree.mac
  compile octree.asm keep=o/octree

o/tables.root: tables.asm
  compile tables.asm keep=o/tables

o/thermo.root: thermo.asm thermo.mac
  compile thermo.asm keep=o/thermo

o/util.root: util.asm util.mac
  compile util.asm keep=o/util

o/gif.root: gif.asm gif.mac
  compile gif.asm keep=o/gif

iq: o/iq.root o/iqres.root o/load.root o/bw.root o/c320.root o/c3200.root \
    o/octree.root o/tables.root o/thermo.root o/util.root o/gif.root
  link o/iq o/load o/bw o/c320 o/c3200 o/iqres o/octree o/tables o/thermo o/util o/gif keep=iq
  chtyp -t s16 iq
