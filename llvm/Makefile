TDIR=./target
all: build
	llc -march=x86 -filetype=asm -o=$(TDIR)/kernel.s kernel.ll
	as --32 -o $(TDIR)/kernel.o $(TDIR)/kernel.s
	as --32 -o $(TDIR)/boot.o boot.s
	ld -m elf_i386 -T link.ld -o $(TDIR)/myfirstkernel.bin \
		$(TDIR)/boot.o $(TDIR)/kernel.o

build:
	mkdir -p $(TDIR)

install:
	cp $(TDIR)/myfirstkernel.bin /boot/myfirstkernel.bin

clean:
	rm -rf $(TDIR)

run:
	qemu-system-i386 -kernel target/myfirstkernel.bin &
