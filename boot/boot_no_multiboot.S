# SAGE OS Boot Code (x86_64 without multiboot header)
# Copyright (c) 2025 Ashish Vasant Yesale

.section ".text"
.global _start

_start:
    // Disable interrupts
    cli
    
    // Set up stack
    mov $stack_top, %rsp
    
    // Clear direction flag
    cld
    
    // Call kernel main
    call kernel_main
    
    // If kernel_main returns, halt
halt_loop:
    hlt
    jmp halt_loop

// Stack space
.section ".bss"
.align 16
stack_bottom:
    .skip 16384  // 16KB stack
stack_top: