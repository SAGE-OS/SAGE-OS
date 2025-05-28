# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Boot Code for ARM 32-bit

.section ".text"
.global _start

_start:
    # Disable interrupts
    cpsid if
    
    # Set up stack pointer
    ldr sp, =stack_top
    
    # Clear BSS section
    ldr r0, =__bss_start
    ldr r1, =__bss_end
    mov r2, #0
clear_bss:
    cmp r0, r1
    bge bss_cleared
    str r2, [r0], #4
    b clear_bss
bss_cleared:

    # Call kernel main
    bl kernel_main
    
    # If kernel_main returns, halt
halt_loop:
    wfi  // Wait for interrupt
    b halt_loop

# Stack space
.section ".bss"
.align 8
stack_bottom:
    .skip 16384  // 16KB stack
stack_top:

# BSS markers (will be defined by linker script)
.weak __bss_start
.weak __bss_end
__bss_start:
__bss_end: