<!--
─────────────────────────────────────────────────────────────────────────────
SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
SPDX-License-Identifier: BSD-3-Clause OR Proprietary
SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.

This file is part of the SAGE OS Project.

─────────────────────────────────────────────────────────────────────────────
Licensing:
-----------
                                
                                                                            
  Licensed under the BSD 3-Clause License or a Commercial License.          
  You may use this file under the terms of either license as specified in: 
                                                                            
     - BSD 3-Clause License (see ./LICENSE)                           
     - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
                                                                            
  Redistribution and use in source and binary forms, with or without       
  modification, are permitted under the BSD license provided that the      
  following conditions are met:                                            
                                                                            
    * Redistributions of source code must retain the above copyright       
      notice, this list of conditions and the following disclaimer.       
    * Redistributions in binary form must reproduce the above copyright    
      notice, this list of conditions and the following disclaimer in the  
      documentation and/or other materials provided with the distribution. 
    * Neither the name of the project nor the names of its contributors    
      may be used to endorse or promote products derived from this         
      software without specific prior written permission.                  
                                                                            
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  

By using this software, you agree to be bound by the terms of either license.

Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.

─────────────────────────────────────────────────────────────────────────────
Contributor Guidelines:
------------------------
Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
All contributors must certify that they have the right to submit the code and agree to
release it under the above license terms.

Contributions must:
  - Be original or appropriately attributed
  - Include clear documentation and test cases where applicable
  - Respect the coding and security guidelines defined in CONTRIBUTING.md

─────────────────────────────────────────────────────────────────────────────
Terms of Use and Disclaimer:
-----------------------------
This software is provided "as is", without any express or implied warranty.
In no event shall the authors, contributors, or copyright holders
be held liable for any damages arising from the use of this software.

Use of this software in critical systems (e.g., medical, nuclear, safety)
is entirely at your own risk unless specifically licensed for such purposes.

─────────────────────────────────────────────────────────────────────────────
-->

# SAGE OS Boot System Guide

## Overview

The SAGE OS boot system is designed to support multiple architectures with a unified boot process. This guide explains the boot sequence, architecture-specific implementations, and troubleshooting common boot issues.

## Boot Architecture

### Boot Flow

```
Power On/Reset
     ↓
Firmware (UEFI/BIOS/U-Boot)
     ↓
Bootloader Detection
     ↓
SAGE OS Boot Code
     ↓
Architecture Detection
     ↓
Hardware Initialization
     ↓
Kernel Main Entry
     ↓
System Initialization
     ↓
Shell/User Interface
```

## Architecture-Specific Boot

### x86_64 Boot Process

#### Multiboot Compliance
SAGE OS implements Multiboot specification for x86_64 systems:

```assembly
// Multiboot header
#define MULTIBOOT_MAGIC         0x1BADB002
#define MULTIBOOT_FLAGS         0x00000003
#define MULTIBOOT_CHECKSUM      -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

.section ".multiboot"
.align 4
multiboot_header:
    .long MULTIBOOT_MAGIC
    .long MULTIBOOT_FLAGS
    .long MULTIBOOT_CHECKSUM
```

#### Boot Sequence
1. **Multiboot Header**: Bootloader detects SAGE OS
2. **Protected Mode**: CPU in 32-bit protected mode
3. **Long Mode Transition**: Switch to 64-bit mode
4. **Stack Setup**: Initialize kernel stack
5. **BSS Clearing**: Zero uninitialized data
6. **Kernel Entry**: Jump to `kernel_main()`

### ARM64/AArch64 Boot Process

#### Boot Sequence
1. **CPU Core Check**: Only core 0 continues
2. **Exception Level**: Start in EL1 or EL2
3. **MMU Disabled**: Physical memory access
4. **Stack Setup**: Initialize stack pointer
5. **BSS Clearing**: Zero uninitialized data
6. **Kernel Entry**: Jump to `kernel_main()`

```assembly
_start:
    // Check processor ID, stop all but core 0
    mrs     x1, mpidr_el1
    and     x1, x1, #3
    cbz     x1, 2f
    // CPU ID > 0, stop
1:  wfe
    b       1b
2:  // CPU ID == 0
    
    // Set stack pointer
    ldr     x1, =stack_top
    mov     sp, x1
```

### RISC-V Boot Process

#### Boot Sequence
1. **Hart Selection**: Only hart 0 continues
2. **Machine Mode**: Start in M-mode
3. **Supervisor Mode**: Transition to S-mode
4. **Stack Setup**: Initialize stack pointer
5. **BSS Clearing**: Zero uninitialized data
6. **Kernel Entry**: Jump to `kernel_main()`

```assembly
_start:
    // Set up stack
    la      sp, stack_top
    
    // Clear BSS
    la      t0, __bss_start
    la      t1, __bss_end
    bgeu    t0, t1, 2f
1:
    sd      zero, 0(t0)
    addi    t0, t0, 8
    bltu    t0, t1, 1b
2:
    // Call kernel_main
    call    kernel_main
```

## Memory Layout

### Linker Scripts

#### Generic Layout (`linker.ld`)
```ld
SECTIONS
{
    . = 0x80000;  /* Raspberry Pi load address */
    
    __start = .;
    
    .multiboot : { *(.multiboot) }
    .text.boot : { *(.text.boot) }
    .text : { *(.text) }
    .rodata : { *(.rodata) *(.rodata.*) }
    .data : { *(.data) *(.data.*) }
    
    .bss : {
        __bss_start = .;
        *(.bss) *(.bss.*) *(COMMON)
        __bss_end = .;
    }
    
    __end = .;
}
```

#### x86_64 Layout (`linker_x86_64.ld`)
```ld
SECTIONS
{
    . = 0x100000;  /* 1MB load address for x86_64 */
    
    __start = .;
    
    .multiboot : { *(.multiboot) }
    .text.boot : { *(.text.boot) }
    /* ... rest of sections ... */
}
```

## Boot Configuration

### Raspberry Pi Configuration

#### config.txt
```ini
# Raspberry Pi 4 configuration
kernel=kernel8.img
arm_64bit=1
enable_uart=1
uart_2ndstage=1

# GPU memory split
gpu_mem=64

# Enable I2C and SPI
dtparam=i2c_arm=on
dtparam=spi=on
```

#### config_rpi5.txt
```ini
# Raspberry Pi 5 specific configuration
kernel=kernel_2712.img
arm_64bit=1
enable_uart=1

# AI HAT support
dtoverlay=ai-hat-plus

# Enhanced GPU memory for AI workloads
gpu_mem=128
```

## Boot Debugging

### QEMU Testing

#### x86_64 QEMU
```bash
qemu-system-x86_64 \
    -kernel build/x86_64/kernel.elf \
    -nographic \
    -monitor none \
    -serial stdio
```

#### ARM64 QEMU
```bash
qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a57 \
    -kernel build/aarch64/kernel.img \
    -nographic \
    -serial stdio
```

#### RISC-V QEMU
```bash
qemu-system-riscv64 \
    -M virt \
    -kernel build/riscv64/kernel.elf \
    -nographic \
    -serial stdio
```

### Debug Output

#### Early Boot Messages
```c
void early_boot_debug(const char* message) {
    // Platform-specific early debug output
    #ifdef DEBUG_EARLY_BOOT
        uart_puts("[BOOT] ");
        uart_puts(message);
        uart_puts("\n");
    #endif
}
```

#### Boot Status Indicators
```c
typedef enum {
    BOOT_STAGE_START,
    BOOT_STAGE_ARCH_DETECT,
    BOOT_STAGE_MEMORY_INIT,
    BOOT_STAGE_DRIVERS_INIT,
    BOOT_STAGE_AI_INIT,
    BOOT_STAGE_COMPLETE
} boot_stage_t;

void boot_stage_update(boot_stage_t stage) {
    early_boot_debug(boot_stage_names[stage]);
}
```

## Common Boot Issues

### Issue 1: Kernel Not Loading

**Symptoms:**
- QEMU exits immediately
- No boot output
- "Error loading kernel" message

**Solutions:**
1. Check multiboot header alignment
2. Verify entry point in linker script
3. Ensure correct load address
4. Validate ELF format

**Debug Commands:**
```bash
# Check ELF headers
readelf -h build/x86_64/kernel.elf

# Verify multiboot header
hexdump -C build/x86_64/kernel.elf | head -20

# Check entry point
objdump -f build/x86_64/kernel.elf
```

### Issue 2: Boot Hang

**Symptoms:**
- System starts but hangs
- No output after initial messages
- CPU appears to be in infinite loop

**Solutions:**
1. Check stack initialization
2. Verify BSS clearing
3. Ensure proper architecture detection
4. Check interrupt handling

**Debug Techniques:**
```bash
# GDB debugging
qemu-system-x86_64 -kernel kernel.elf -s -S &
gdb kernel.elf
(gdb) target remote :1234
(gdb) break _start
(gdb) continue
```

### Issue 3: Memory Corruption

**Symptoms:**
- Random crashes
- Garbled output
- Unexpected behavior

**Solutions:**
1. Verify memory layout
2. Check stack overflow
3. Validate BSS clearing
4. Review memory allocator

**Memory Analysis:**
```bash
# Check memory sections
objdump -h kernel.elf

# Analyze memory usage
size kernel.elf

# Check for overlapping sections
readelf -S kernel.elf
```

## Boot Optimization

### Fast Boot Techniques

1. **Parallel Initialization**: Initialize independent subsystems in parallel
2. **Lazy Loading**: Defer non-critical initialization
3. **Cache Optimization**: Optimize memory access patterns
4. **Minimal Drivers**: Load only essential drivers at boot

### Boot Time Measurement

```c
typedef struct {
    uint64_t timestamp;
    const char* stage_name;
} boot_timing_t;

static boot_timing_t boot_timings[MAX_BOOT_STAGES];
static int timing_index = 0;

void boot_timing_mark(const char* stage) {
    if (timing_index < MAX_BOOT_STAGES) {
        boot_timings[timing_index].timestamp = get_timestamp();
        boot_timings[timing_index].stage_name = stage;
        timing_index++;
    }
}
```

## Advanced Boot Features

### Secure Boot

```c
int verify_kernel_signature(void* kernel_image, size_t size) {
    // Cryptographic signature verification
    return crypto_verify_signature(kernel_image, size, public_key);
}
```

### Multi-Boot Support

```c
void detect_boot_method(void) {
    if (multiboot_magic == MULTIBOOT_BOOTLOADER_MAGIC) {
        boot_method = BOOT_MULTIBOOT;
    } else if (device_tree_present()) {
        boot_method = BOOT_DEVICE_TREE;
    } else {
        boot_method = BOOT_LEGACY;
    }
}
```

### Recovery Mode

```c
void check_recovery_mode(void) {
    if (gpio_read(RECOVERY_PIN) == LOW) {
        enter_recovery_mode();
    }
}
```

## Platform-Specific Notes

### Raspberry Pi 4/5

- Load address: 0x80000
- Kernel image: kernel8.img (64-bit)
- Device tree support required
- GPU firmware interaction

### x86_64 Systems

- Load address: 0x100000 (1MB)
- Multiboot compliance required
- GRUB compatibility
- UEFI/BIOS support

### RISC-V Platforms

- Load address: varies by platform
- OpenSBI integration
- Hart management
- Platform-specific timers

## References

- [Multiboot Specification](https://www.gnu.org/software/grub/manual/multiboot/)
- [ARM64 Boot Protocol](https://www.kernel.org/doc/Documentation/arm64/booting.txt)
- [RISC-V Boot Protocol](https://github.com/riscv/riscv-sbi-doc)
- [Raspberry Pi Boot Process](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/)

---

For more information, see the [SAGE OS Documentation](COMPREHENSIVE_DOCUMENTATION.md).