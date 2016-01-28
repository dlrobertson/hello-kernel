    .set ALIGN,    1 << 0
    .set MEMINFO,  1 << 1
    .set FLAGS,    ALIGN | MEMINFO
    .set MAGIC,    0x1BADB002
    .set CHECKSUM, -(MAGIC + FLAGS)

.section .multiboot
    .align 4
    .long MAGIC
    .long FLAGS
    .long CHECKSUM

.section .kern_stack, "aw", @nobits
stack_bp:
    .skip 16384
stack_sp:

.section .text
.global _start
.type _start, @function
_start:
    movl $stack_sp, %esp
    call kernel_main
    cli
    hlt
.hangout:
    jmp .hangout
.size _start, . - _start
