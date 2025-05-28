// Minimal multiboot boot code
.section ".multiboot"
.align 4

#define MULTIBOOT_MAGIC         0x1BADB002
#define MULTIBOOT_FLAGS         0x00000003
#define MULTIBOOT_CHECKSUM      -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

multiboot_header:
    .long MULTIBOOT_MAGIC
    .long MULTIBOOT_FLAGS
    .long MULTIBOOT_CHECKSUM

.section ".text"
.global _start

_start:
    // Disable interrupts
    cli
    
    // Set up stack
    mov $stack_top, %esp
    
    // Clear direction flag
    cld
    
    // Call kernel main
    call kernel_main
    
    // If kernel_main returns, halt
halt_loop:
    hlt
    jmp halt_loop

.section ".bss"
.align 16
stack_bottom:
    .skip 16384  // 16KB stack
stack_top: