PROGS = testcorrc testcorrasm testcorravx
all: $(PROGS) 

.SUFFIXES:
.SUFFIXES: .o .asm .c
.SECONDARY:

DIR = `basename $(PWD)`
SCRIPTS = ../scripts

CCFLAGS = -g

.asm.o:
	yasm -Worphan-labels -f elf64 -g dwarf2 -l $*.lst $<

.o:
	$(SCRIPTS)/ygcc -o $@ $<

testcorrc: testcorr.c corr.c
	gcc -O3 -funroll-all-loops -o testcorrc testcorr.c corr.c -lm

testcorrasm: testcorr.c corr.asm
	yasm -Worphan-labels -f elf64 -g dwarf2 -l corr.lst corr.asm
	gcc -O3 -funroll-all-loops -o testcorrasm testcorr.c corr.o -lm

testcorravx: testcorr.c corravx.asm
	yasm -Worphan-labels -f elf64 -g dwarf2 -l corravx.lst corravx.asm
	gcc -O3 -funroll-all-loops -o testcorravx testcorr.c corravx.o -lm

clean:
	rm -f $(PROGS) *.o *.lst *~ .*.gdb

tgz: clean
	(cd ..; tar cvzf  $(DIR).tgz $(DIR))
