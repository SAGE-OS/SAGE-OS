<!-- ─────────────────────────────────────────────────────────────────────────────
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

# SAGE OS 🌱🧠

**Self-Aware General Environment**  
An experimental, bare-metal operating system designed from scratch to learn, adapt, and evolve — starting on Raspberry Pi.

> For detailed usage instructions, see [USAGE_GUIDE.md](./USAGE_GUIDE.md)

![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)

## 🔭 Vision 

**SAGE OS** is not just another operating system. It is a living, evolving system designed to:

- Think autonomously
- Learn from usage patterns
- Optimize itself through artificial intelligence
- Rebuild and evolve its components as needed

This is an experiment at the intersection of **kernel engineering**, **embedded systems**, and **machine intelligence** — pushing the boundaries of what an operating system can become.

## 🚀 Features

- **Custom Bootloader**: Designed specifically for Raspberry Pi hardware
- **Bare-Metal Kernel**: Written in C and ARM assembly for maximum performance
- **AI Subsystem**: Integrated AI capabilities with the AI HAT+ accelerator
- **Memory Management**: Efficient memory allocation and management
- **Shell Interface**: Interactive command-line interface
- **Hardware Abstraction**: Support for Raspberry Pi 3, 4, and 5
- **Device Drivers**: UART, GPIO, I2C, SPI, and AI HAT+ drivers
- **Multi-Architecture Support**: x86_64, aarch64, riscv64, arm

## 🧠 AI & Machine Learning Integration

SAGE OS includes embedded, resource-efficient AI components that can:
- Perform local inference using the AI HAT+ with up to 26 TOPS
- Support multiple model formats and precisions (FP32, FP16, INT8, INT4)
- Observe usage and optimize scheduling
- Trigger self-diagnostics and reconfiguration
- Dynamically adjust power consumption based on workload
- Monitor system health and performance
- Eventually, enable modular regeneration of subsystems

The AI HAT+ provides hardware acceleration for neural networks with:
- Up to 26 TOPS of neural processing power
- 4GB of dedicated memory for AI models
- Support for various model types (classification, detection, segmentation, generation)
- Power-efficient operation with multiple power modes
- Temperature monitoring and thermal management
- High-speed data transfer using SPI and control via I2C

## 🧰 Tech Stack

- **Languages**: ARM Assembly, C (kernel), Rust (core components), Python (tools & ML prototyping)
- **Platform**: Raspberry Pi 4B/5 (64-bit ARMv8/ARMv9)
- **Toolchain**: `aarch64-linux-gnu-gcc`, `rustc`, `QEMU`, `CMake`, TinyML (TFLM, uTensor)
- **Build Environment**: Cross-compilation (Linux, macOS)
- **AI Acceleration**: AI HAT+ with up to 26 TOPS neural processing

## 📦 Project Structure

<details>
  <summary>📦 Folder Structure</summary>
  
- `boot/` - Architecture-specific boot code
- `kernel/` - Core kernel functionality
- `drivers/` - Hardware drivers
- `scripts/` - Utility scripts for building and testing

</details>

```
SAGE-OS/
├── boot/                  # Boot code
│   └── boot.S             # ARM64 boot assembly
├── kernel/                # Kernel components
│   ├── kernel.c           # Kernel main entry point
│   ├── memory.c           # Memory management
│   ├── shell.c            # Interactive shell
│   ├── stdio.c            # Standard I/O functions
│   └── ai/                # AI subsystem
│       └── ai_subsystem.c # AI subsystem implementation
├── drivers/               # Hardware drivers
│   ├── uart.c             # UART driver
│   ├── i2c.c              # I2C driver
│   ├── spi.c              # SPI driver
│   └── ai_hat/            # AI HAT+ driver
│       ├── ai_hat.c       # AI HAT+ implementation
│       └── ai_hat.h       # AI HAT+ interface
├── config.txt             # Raspberry Pi 3/4 configuration
├── config_rpi5.txt        # Raspberry Pi 5 configuration
├── linker.ld              # Linker script
├── Makefile               # Build system
└── run_qemu.sh            # QEMU runner script
```

## 🚀 Getting Started

<details>
  <summary>🚀 Building and Running SAGE OS</summary>

### Prerequisites

To build and run SAGE OS, you need the following tools:

- Raspberry Pi 3, 4, or 5
- SD card
- USB-to-TTL serial cable
- Cross-compilation toolchain (aarch64-linux-gnu-gcc)
- Rust toolchain (for core components)
- Optional: AI HAT+ for neural processing acceleration

- GCC cross-compilers for your target architectures:
  - `x86_64-linux-gnu-gcc` for x86_64
  - `aarch64-linux-gnu-gcc` for ARM64/AArch64
  - `riscv64-linux-gnu-gcc` for RISC-V 64-bit

- QEMU for emulation:
  - `qemu-system-x86_64` for x86_64
  - `qemu-system-aarch64` for ARM64/AArch64
  - `qemu-system-riscv64` for RISC-V 64-bit

### Installing Prerequisites

On Debian/Ubuntu:

```bash
# Install cross-compilers
sudo apt-get install gcc-x86-64-linux-gnu gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu

# Install QEMU
sudo apt-get install qemu-system-x86 qemu-system-arm qemu-system-misc

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add aarch64-unknown-none
```

### Building SAGE OS

To build SAGE OS for a specific architecture:

```bash
# Clean previous build artifacts
make clean

# Build for x86_64
make ARCH=x86_64

# Build for ARM64/AArch64 (default)
make ARCH=aarch64

# Build for RISC-V 64-bit
make ARCH=riscv64

# Build for Raspberry Pi 4
make

# Build for Raspberry Pi 5
make rpi5

# Build for Raspberry Pi 5 with AI HAT+ support
make rpi5_ai
```

The build process creates:
- Object files for each source file
- `kernel.elf` - The linked ELF executable
- `kernel8.img` - The raw binary image

### Running SAGE OS

#### Using QEMU

You can run SAGE OS in QEMU using the provided script:

```bash
# Run on x86_64
./scripts/test_emulated.sh x86_64

# Run on ARM64/AArch64
./scripts/test_emulated.sh aarch64

# Run on RISC-V 64-bit
./scripts/test_emulated.sh riscv64

# For Raspberry Pi 3/4
./run_qemu.sh

# For Raspberry Pi 5
./run_qemu.sh -p rpi5
```

#### Running on Real Hardware

For Raspberry Pi (ARM64):
1. Copy `kernel8.img` and the appropriate config file to an SD card:
   - For Raspberry Pi 3/4: Use `config.txt`
   - For Raspberry Pi 5: Use `config_rpi5.txt` (rename to `config.txt` on the SD card)
2. Insert the SD card into your Raspberry Pi
3. Connect a serial console
4. Power on the Raspberry Pi

### Development

#### Adding New Features

1. Add your source files to the appropriate directory
2. Update the Makefile if necessary
3. Build and test using the commands above

#### License Compliance

All source files must include the BSD 3-Clause License header. You can check for compliance using:

```bash
./license-checker.py
```

If you need to add license headers to new files:

```bash
./add_license_headers.py
```

### Troubleshooting

#### Build Errors

- **Missing compiler**: Make sure you have installed the appropriate cross-compiler for your target architecture
- **Linker errors**: Check that all required object files are being included in the link step

#### Runtime Errors

- **Kernel doesn't boot**: Verify that the boot code for your architecture is correctly implemented
- **QEMU crashes**: Make sure you're using the correct QEMU parameters for your architecture

</details>

See [BUILD.md](BUILD.md) for detailed build instructions.

### Shell Commands

Once booted, SAGE OS provides a shell with the following commands:

- `help` - Display available commands
- `echo [text]` - Echo text to the console
- `clear` - Clear the screen
- `meminfo` - Display memory information
- `reboot` - Reboot the system
- `version` - Display OS version information
- `ai info` - Display AI subsystem information (if enabled)
- `ai temp` - Show AI HAT+ temperature (if available)
- `ai power` - Show AI HAT+ power consumption (if available)
- `ai models` - List loaded AI models (if any)

## 🧑‍💻 Contributing

SAGE OS is open to contributions from developers, researchers, and hardware hackers.

- 📜 [License (BSD 3-Clause)](./LICENSE)
- ⚖️ [Commercial Use Terms](./COMMERCIAL_TERMS.md)
- 🧠 [AI Safety & Ethics Manifesto](./AI_Safety_And_Ethics.md)
- 🛠️ [How to Contribute](./CONTRIBUTING.md)

By contributing, you agree to the above terms.

## 🔍 Current Development Status

- [x] Custom bootloader for Raspberry Pi
- [x] Basic kernel with memory & process management
- [x] Custom command-line shell (SAGE Shell)
- [x] Memory management system
- [x] UART driver for console I/O
- [x] Raspberry Pi 5 support
- [x] AI HAT+ driver for neural processing
- [x] Multi-architecture build system
- [ ] Self-tuning task scheduler
- [ ] Support for minimal file system
- [ ] Ability to evolve through version-aware updates
- [ ] Full AI model loading and inference pipeline

## 📝 License

SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.

You may use this project under the terms of the BSD 3-Clause License as stated in the LICENSE file.  
Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.

See the [LICENSE](./LICENSE) file for details.