o/main.root: main.asm m/main.mac text.equ
  purge ; compile main.asm keep=o/main

o/st.root: st.asm m/st.mac
  purge ; compile st.asm keep=o/st

o/soundtool.root: soundtool.asm m/soundtool.mac
  purge ; compile soundtool.asm keep=o/soundtool

o/pitchtab.root: pitchtab.asm
  purge ; compile pitchtab.asm keep=o/pitchtab

o/thermo.root: thermo.asm m/thermo.mac
  purge ; compile thermo.asm keep=o/thermo

o/unlzss.root: unlzss.asm m/unlzss.mac
  purge ; compile unlzss.asm keep=o/unlzss

o/gen.root: gen.asm
  purge ; compile gen.asm keep=o/gen

o/text.root: text.asm m/text.mac text.equ
  purge ; compile text.asm keep=o/text

o/instutil.root: instutil.asm m/instutil.mac
  purge ; compile instutil.asm keep=o/instutil

o/loader.root: loader.asm m/loader.mac
  purge ; compile loader.asm keep=o/loader

o/loadokta.root: loadokta.asm m/loadokta.mac
  purge ; compile loadokta.asm keep=o/loadokta

st: o/main.root \
    o/st.root \
    o/soundtool.root \
    o/pitchtab.root \
    o/thermo.root \
    o/unlzss.root \
    o/gen.root \
    o/instutil.root \
    o/loader.root \
    o/loadokta.root \
    o/text.root
  purge ; compile -x link.script keep=st
