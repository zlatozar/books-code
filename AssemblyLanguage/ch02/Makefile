PROGS = fp int
all: $(PROGS) 

.SUFFIXES:
.SUFFIXES: .o .asm
.SECONDARY:

DIR = `basename $(PWD)`
SCRIPTS = ../scripts

.o:
	$(SCRIPTS)/ygcc -g -o $@ $<

.asm.o:
	yasm -Worphan-labels -f elf64 -g dwarf2 -l $*.lst $<

fp: fp.o
	echo "fp.asm exists only to produce fl.lst"

int: int.o
	echo "int.asm exists only to produce int.lst"

clean:
	rm -f $(PROGS) *.o *.lst *~ .*.gdb

tgz: clean
	(cd ..; tar cvzf  $(DIR).tgz $(DIR))
