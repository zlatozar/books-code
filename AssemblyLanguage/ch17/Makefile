PROGS = testpopcntc testpopcntlutc testpopcntasm testpopcntlutasm \
	testpopcntinst
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

testpopcntc: popcnt.c testpopcnt.c
	gcc -O3 -funroll-all-loops -o testpopcntc testpopcnt.c popcnt.c

testpopcntasm: popcnt.asm testpopcnt.c
	yasm -Worphan-labels -f elf64 -g dwarf2 -l popcnt.lst popcnt.asm
	gcc -O3 -funroll-all-loops -o testpopcntasm testpopcnt.c popcnt.o

testpopcntlutc: popcntlut.c testpopcnt.c
	gcc -O3 -funroll-all-loops -o testpopcntlutc testpopcnt.c popcntlut.c

testpopcntlutasm: popcntlut.asm testpopcnt.c
	yasm -Worphan-labels -f elf64 -g dwarf2 -l popcntlut.lst popcntlut.asm
	gcc -O3 -funroll-all-loops -o testpopcntlutasm testpopcnt.c popcntlut.o

testpopcntinst: popcntinst.asm testpopcnt.c
	yasm -Worphan-labels -f elf64 -g dwarf2 -l popcntinst.lst popcntinst.asm
	gcc -O3 -funroll-all-loops -o testpopcntinst testpopcnt.c popcntinst.o

clean:
	rm -f $(PROGS) *.o *.lst *~ .*.gdb

tgz: clean
	(cd ..; tar cvzf  $(DIR).tgz $(DIR))
