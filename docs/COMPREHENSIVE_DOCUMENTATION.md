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

# SAGE OS - Comprehensive Documentation

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [File Structure](#file-structure)
4. [Core Components](#core-components)
5. [Build System](#build-system)
6. [Security](#security)
7. [Development Guide](#development-guide)
8. [API Reference](#api-reference)
9. [Troubleshooting](#troubleshooting)
10. [FAQ](#faq)

## Project Overview

SAGE OS (Self-Aware General Environment Operating System) is an innovative, AI-driven operating system designed for multi-architecture support with advanced self-learning capabilities.

### Key Features

- **Multi-Architecture Support**: x86_64, ARM64, AArch64, RISC-V
- **AI Integration**: Built-in AI subsystem for self-optimization
- **Security-First Design**: Comprehensive security framework
- **Self-Evolving**: Adaptive learning and optimization
- **Cross-Platform**: Supports various hardware platforms

### Vision

SAGE OS aims to create an operating system that can adapt, learn, and evolve based on usage patterns, hardware capabilities, and user needs.

## Architecture

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Applications                        │
├─────────────────────────────────────────────────────────────┤
│                    SAGE SDK                                 │
├─────────────────────────────────────────────────────────────┤
│                    AI Subsystem                             │
├─────────────────────────────────────────────────────────────┤
│                    Kernel Core                              │
├─────────────────────────────────────────────────────────────┤
│                    Hardware Abstraction Layer              │
├─────────────────────────────────────────────────────────────┤
│                    Hardware                                 │
└─────────────────────────────────────────────────────────────┘
```

### Core Modules

1. **Boot System** (`/boot/`)
   - Multi-architecture boot support
   - Multiboot compliance for x86/x86_64
   - Platform-specific initialization

2. **Kernel Core** (`/kernel/`)
   - Memory management
   - Process scheduling
   - System calls
   - Shell interface

3. **Drivers** (`/drivers/`)
   - UART communication
   - I2C/SPI interfaces
   - AI HAT support
   - Platform-specific drivers

4. **AI Subsystem** (`/kernel/ai/`)
   - Machine learning integration
   - Self-optimization algorithms
   - Adaptive behavior

## File Structure

### Root Directory

```
SAGE-OS/
├── boot/                    # Boot system and bootloaders
├── kernel/                  # Core kernel implementation
├── drivers/                 # Hardware drivers
├── docs/                    # Documentation
├── scripts/                 # Build and utility scripts
├── prototype/               # Prototype implementations
├── sage-sdk/               # Software Development Kit
├── tests/                  # Test suites
├── build-output/           # Build artifacts
├── .github/                # GitHub workflows and templates
└── Theoretical Foundations/ # Research and theoretical work
```

### Key Files

| File | Purpose | Location |
|------|---------|----------|
| `kernel.c` | Main kernel entry point | `/kernel/kernel.c` |
| `boot.S` | Multi-arch boot assembly | `/boot/boot.S` |
| `Makefile` | Build configuration | `/Makefile` |
| `linker.ld` | Linker script | `/linker.ld` |
| `build.sh` | Build automation | `/build.sh` |

## Core Components

### 1. Boot System

#### Files:
- `/boot/boot.S` - Multi-architecture boot code
- `/boot/multiboot.S` - Multiboot header for x86/x86_64
- `/linker.ld` - Memory layout definition

#### Functionality:
- Platform detection and initialization
- Memory setup and BSS clearing
- Kernel entry point preparation

#### Code Snippet:
```assembly
_start:
    // Disable interrupts
    cli
    
    // Set up stack
    movq    $stack_top, %rsp
    
    // Clear BSS
    movq    $__bss_start, %rdi
    movq    $__bss_end, %rcx
    subq    %rdi, %rcx
    xorq    %rax, %rax
    shrq    $3, %rcx
    rep stosq
    
    // Call kernel_main
    call    kernel_main
```

### 2. Kernel Core

#### Files:
- `/kernel/kernel.c` - Main kernel implementation
- `/kernel/memory.c` - Memory management
- `/kernel/shell.c` - Interactive shell
- `/kernel/stdio.c` - Standard I/O operations

#### Memory Management:
```c
void memory_init() {
    // Initialize memory allocator
    heap_start = (void*)HEAP_START_ADDR;
    heap_end = (void*)HEAP_END_ADDR;
    free_list = NULL;
}

void* kmalloc(size_t size) {
    // Kernel memory allocation
    return allocate_from_heap(size);
}
```

#### Shell Interface:
```c
void shell_run() {
    char command[256];
    
    while (1) {
        uart_puts("sage> ");
        shell_read_line(command, sizeof(command));
        shell_execute_command(command);
    }
}
```

### 3. Driver System

#### UART Driver (`/drivers/uart.c`):
```c
void uart_init() {
    // Initialize UART for platform
    #ifdef RPI4
        uart_init_rpi4();
    #elif defined(RPI5)
        uart_init_rpi5();
    #endif
}

void uart_putc(char c) {
    // Platform-specific character output
    while (!(UART_FR & UART_FR_TXFE));
    UART_DR = c;
}
```

#### AI HAT Driver (`/drivers/ai_hat/ai_hat.c`):
```c
int ai_hat_init() {
    // Initialize AI HAT hardware
    if (!detect_ai_hat()) {
        return -1;
    }
    
    configure_ai_hat();
    return 0;
}
```

### 4. AI Subsystem

#### Files:
- `/kernel/ai/ai_subsystem.c` - Core AI functionality
- `/kernel/ai/ai_subsystem.h` - AI interface definitions

#### Functionality:
```c
void ai_subsystem_init() {
    // Initialize AI learning algorithms
    neural_network_init();
    behavior_analyzer_init();
    optimization_engine_init();
}

void ai_learn_from_usage(usage_pattern_t* pattern) {
    // Adaptive learning implementation
    update_neural_weights(pattern);
    optimize_system_behavior(pattern);
}
```

## Build System

### Multi-Architecture Build

The build system supports multiple architectures through conditional compilation:

```bash
# Build for x86_64
make ARCH=x86_64

# Build for ARM64
make ARCH=aarch64

# Build for RISC-V
make ARCH=riscv64

# Build all architectures
./build-all-architectures.sh
```

### Build Process

1. **Dependency Check**: Verify required toolchains
2. **Source Compilation**: Compile C/Assembly sources
3. **Linking**: Create kernel ELF binary
4. **Image Generation**: Create bootable images
5. **Testing**: Run QEMU tests

### Docker Build

```bash
# Build Docker image for specific architecture
docker build -f Dockerfile.x86_64 -t sage-os-x86_64 .

# Run build in container
docker run --rm -v $(pwd):/workspace sage-os-x86_64 make ARCH=x86_64
```

## Security

### CVE Scanning

SAGE OS includes automated vulnerability scanning using Intel's CVE Binary Tool:

```bash
# Run CVE scan on built binaries
python3 scripts/cve_scanner.py

# Scan specific binary
python3 scripts/cve_scanner.py --binary build/x86_64/kernel.elf

# Scan Docker images
python3 scripts/cve_scanner.py --no-docker
```

### Security Features

1. **Memory Protection**: Stack canaries and ASLR
2. **Secure Boot**: Verified boot process
3. **Encryption**: Built-in cryptographic support
4. **Access Control**: Role-based permissions

## Development Guide

### Setting Up Development Environment

1. **Install Dependencies**:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install build-essential gcc-multilib
   sudo apt-get install gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf
   sudo apt-get install gcc-riscv64-linux-gnu qemu-system
   ```

2. **Clone Repository**:
   ```bash
   git clone https://github.com/NMC-TechClub/SAGE-OS.git
   cd SAGE-OS
   ```

3. **Build and Test**:
   ```bash
   make clean
   make ARCH=x86_64
   ./run_qemu.sh
   ```

### Contributing

1. **Fork the Repository**
2. **Create Feature Branch**: `git checkout -b feature/new-feature`
3. **Add License Headers**: `python3 scripts/enhanced_license_tool.py . -r`
4. **Run Tests**: `make test`
5. **Submit Pull Request**

### Coding Standards

- Follow Linux kernel coding style
- Add comprehensive comments
- Include unit tests for new features
- Ensure multi-architecture compatibility

## API Reference

### Kernel API

#### Memory Management
```c
void* kmalloc(size_t size);
void kfree(void* ptr);
void* krealloc(void* ptr, size_t new_size);
```

#### I/O Operations
```c
void uart_puts(const char* str);
char uart_getc(void);
int uart_printf(const char* format, ...);
```

#### AI Interface
```c
int ai_subsystem_init(void);
void ai_learn_pattern(pattern_t* pattern);
prediction_t ai_predict_behavior(context_t* context);
```

### SDK API

#### Application Development
```c
#include <sage/syscalls.h>
#include <sage/memory.h>
#include <sage/ai_hat.h>

int main() {
    sage_init();
    
    // Your application code
    
    return 0;
}
```

## Troubleshooting

### Common Issues

#### Build Failures

**Problem**: Cross-compiler not found
```
Solution: Install appropriate cross-compilation toolchain
sudo apt-get install gcc-aarch64-linux-gnu
```

**Problem**: Linker errors
```
Solution: Check linker script and memory layout
Review linker.ld for correct memory addresses
```

#### Boot Issues

**Problem**: Kernel doesn't boot in QEMU
```
Solution: Verify multiboot header and entry point
Check boot.S for correct architecture-specific code
```

**Problem**: No output on serial console
```
Solution: Verify UART initialization
Check platform-specific UART configuration
```

#### Runtime Issues

**Problem**: Kernel panic on startup
```
Solution: Check memory initialization
Verify BSS clearing and stack setup
```

### Debug Techniques

1. **QEMU Debugging**:
   ```bash
   qemu-system-x86_64 -kernel kernel.elf -s -S
   gdb kernel.elf
   (gdb) target remote :1234
   ```

2. **Serial Debugging**:
   ```bash
   qemu-system-x86_64 -kernel kernel.elf -serial stdio
   ```

3. **Memory Analysis**:
   ```bash
   objdump -h kernel.elf
   readelf -l kernel.elf
   ```

## FAQ

### Q: What architectures does SAGE OS support?
A: SAGE OS supports x86_64, ARM64, AArch64, and RISC-V architectures.

### Q: How do I add support for a new hardware platform?
A: 1. Add platform-specific drivers in `/drivers/`
   2. Update boot code in `/boot/boot.S`
   3. Modify build system in `Makefile`
   4. Add platform detection logic

### Q: Can I run SAGE OS on real hardware?
A: Yes, SAGE OS is designed to run on real hardware. Currently tested on:
- Raspberry Pi 4/5
- x86_64 systems
- RISC-V development boards

### Q: How does the AI subsystem work?
A: The AI subsystem uses machine learning algorithms to:
- Analyze system usage patterns
- Optimize resource allocation
- Predict user behavior
- Adapt system configuration

### Q: Is SAGE OS production-ready?
A: SAGE OS is currently in active development. While functional, it's recommended for research and development purposes.

### Q: How can I contribute to SAGE OS?
A: See the [Contributing Guide](CONTRIBUTING.md) for detailed instructions on:
- Setting up development environment
- Coding standards
- Submission process
- Testing requirements

### Q: What license does SAGE OS use?
A: SAGE OS is dual-licensed under BSD 3-Clause and Commercial licenses. See [LICENSE](../LICENSE) for details.

---

For more information, visit the [SAGE OS GitHub repository](https://github.com/NMC-TechClub/SAGE-OS) or contact the development team.