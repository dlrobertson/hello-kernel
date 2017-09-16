TDIR := ./target
ARCH := x86

all: check-build $(TDIR)/kernel

check-build:
ifeq ($(BUILD), )
	@echo "Either run \"make [llvm|rust]\" or BUILD=[llvm|rust] make"
	@exit 1
else
	@echo "$(BUILD)"
endif

llvm:
	BUILD=llvm make all

rust:
	BUILD=rust make all

$(TDIR)/kernel-llvm.o: kernel.ll $(TDIR)
	llc -march=x86 -filetype=obj -o=$@ $<

$(TDIR)/kernel-rust.o: kernel.rs $(TDIR)
ifneq ($(shell which rustup),)
	rustup run stable-i686-unknown-linux-gnu rustc -O \
		--crate-type lib \
		-o $@ --emit obj $<
else ifneq ($(shell which rustc),)
	rustc -O \
		--target i686-unknown-linux-gnu \
		--crate-type lib \
		-o $@ --emit obj $<
else
	@echo "Install rustup or rustc and the i686 toolchain"
endif

$(TDIR)/kernel.o: $(TDIR)/kernel-$(BUILD).o
	cp $< $@

$(TDIR)/boot.o: boot/$(ARCH).s
	as --32 -o $@ $<

$(TDIR)/kernel: $(TDIR)/kernel.o $(TDIR)/boot.o link.ld
	ld -m elf_i386 -T link.ld -o $@ $(TDIR)/kernel.o $(TDIR)/boot.o

$(TDIR):
	mkdir -p $(TDIR)

install:
	cp $(TDIR)/kernel /boot/kernel

clean:
	rm -rf $(TDIR)

run: $(TDIR)/kernel
	qemu-system-i386 -kernel target/kernel -display curses
