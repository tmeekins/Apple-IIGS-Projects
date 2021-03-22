mkmac.root: mkmac.asm mkmac.mac
  compile mkmac.asm keep=mkmac

opcode.root: opcode.asm opcode.mac
  compile opcode.asm keep=opcode

mkmac: mkmac.root opcode.root
  link mkmac opcode keep=mkmac
