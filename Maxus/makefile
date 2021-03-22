maxus.root: maxus.asm maxus.mac maxus.h
   compile maxus.asm keep=maxus

maxtext.root: maxtext.asm maxtext.mac maxus.h
   compile maxtext.asm keep=maxtext

maxch.root: maxch.asm
   compile maxch.asm keep=maxch

maxtbl.root: maxtbl.asm
   compile maxtbl.asm keep=maxtbl

maxstat.root: maxstat.asm
   compile maxstat.asm keep=maxstat

maxlogo.root: maxlogo.asm
   compile maxlogo.asm keep=maxlogo

maxship.root: maxship.asm
   compile maxship.asm keep=maxship

maxus: maxus.root maxtext.root maxtbl.root maxch.root maxstat.root \
       maxlogo.root maxship.root
   link maxus maxtext maxtbl maxch maxstat maxlogo maxship keep=maxus
   filetype maxus s16
