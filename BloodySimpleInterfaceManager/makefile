o/bsimain.root: bsimain.asm bsi.h m/bsimain.mac
  purge ; compile +x bsimain.asm keep=o/bsimain

o/bsievent.root: bsievent.asm bsi.h m/bsievent.mac
  purge ; compile +x bsievent.asm keep=o/bsievent

o/bsifont.root: bsifont.asm
  purge ; compile +x bsifont.asm keep=o/bsifont

o/bsisf.root: bsisf.asm m/bsisf.mac bsi.h
  purge ; compile +x bsisf.asm keep=o/bsisf

o/tvmm.root: tvmm.asm m/tvmm.mac tvmm.h bsi.h
  purge ; compile +x tvmm.asm keep=o/tvmm

o/iq.root: iq.asm bsi.h m/iq.mac
  purge ; compile +x iq.asm keep=o/iq

o/iqutil.root: iqutil.asm m/iqutil.mac
  purge ; compile +x iqutil.asm keep=o/iqutil

o/iqload.root: iqload.asm m/iqload.mac
  purge ; compile +x iqload.asm keep=o/iqload

o/iqgif.root: iqgif.asm m/iqgif.mac
  purge ; compile +x iqgif.asm keep=o/iqgif

o/iqjpeg.root: iqjpeg.asm m/iqjpeg.mac
  purge ; compile +x iqjpeg.asm keep=o/iqjpeg

o/iqlbm.root: iqlbm.asm m/iqlbm.mac
  purge ; compile +x iqlbm.asm keep=o/iqlbm

o/iqbmp.root: iqbmp.asm m/iqbmp.mac
  purge ; compile +x iqbmp.asm keep=o/iqbmp

o/iqbw.root: iqbw.asm m/iqbw.mac
  purge ; compile +x iqbw.asm keep=o/iqbw

o/iq16col.root: iq16col.asm m/iq16col.mac
  purge ; compile +x iq16col.asm keep=o/iq16col

o/iq3200.root: iq3200.asm m/iq3200.mac
  purge ; compile +x iq3200.asm keep=o/iq3200

o/iqtrucol.root: iqtrucol.asm m/iqtrucool.mac
  purge ; compile +x iqtrucol.asm keep=o/iqtrucol

o/iqoctree.root: iqoctree.asm m/iqoctree.mac
  purge ; compile +x iqoctree.asm keep=o/iqoctree

o/iqview.root: iqview.asm m/iqview.mac g3200.a.asm g3200.b.asm
  purge ; compile +x iqview.asm keep=o/iqview

o/iqtbls.root: iqtbls.asm
  purge ; compile +x iqtbls.asm keep=o/iqtbls

iq: o/iq.root \
    o/iqutil.root \
    o/iqload.root \
    o/iqgif.root \
    o/iqjpeg.root \
    o/iqlbm.root \
    o/iqbmp.root \
    o/iqbw.root \
    o/iq16col.root \
    o/iq3200.root \
    o/iqtrucol.root \
    o/iqoctree.root \
    o/iqview.root \
    o/iqtbls.root \
    o/bsimain.root \
    o/bsifont.root \
    o/bsievent.root \
    o/bsisf.root \
    o/tvmm.root
  purge ; compile link.script keep=iq
  chtyp -ts16 iq
