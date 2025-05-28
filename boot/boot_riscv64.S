# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Boot Code for RISC-V 64-bit

.section ".text"
.global _start

_start:
    # Disable interrupts
    li t0, 0x8
    csrc mstatus, t0  # Clear MIE bit
    
    # Set up stack pointer
    la sp, stack_top
    
    # Clear BSS section
    la t0, __bss_start
    la t1, __bss_end
    li t2, 0
clear_bss:
    bge t0, t1, bss_cleared
    sd t2, 0(t0)
    addi t0, t0, 8
    j clear_bss
bss_cleared:

    # Call kernel main
    call kernel_main
    
    # If kernel_main returns, halt
halt_loop:
    wfi  // Wait for interrupt
    j halt_loop

# Stack space
.section ".bss"
.align 16
stack_bottom:
    .skip 16384  // 16KB stack
stack_top:

# BSS markers (will be defined by linker script)
.weak __bss_start
.weak __bss_end
__bss_start:
__bss_end: