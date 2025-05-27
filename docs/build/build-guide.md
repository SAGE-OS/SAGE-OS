# SAGE OS Build Guide

## 🚀 Quick Start

### Prerequisites
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install build-essential gcc-multilib qemu-system-x86 grub-pc-bin xorriso mtools

# Cross-compilation toolchains
sudo apt install gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu
```

### Build All Architectures
```bash
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS
./build-all-working.sh
```

## 🏗️ Build System Overview

SAGE OS uses a sophisticated build system supporting multiple architectures and build configurations.

### Key Build Files

| File | Purpose | Location |
|------|---------|----------|
| `Makefile` | Main build orchestration | `/` |
| `build-all-working.sh` | Multi-arch build script | `/` |
| `create_elf_wrapper.py` | ELF wrapper for x86_64 | `/` |
| `create_multiboot_header.py` | Multiboot header generator | `/` |

## 🎯 Architecture-Specific Builds

### x86_64 Build
```bash
make ARCH=x86_64
```

**Output Files:**
- `build-output/x86_64/kernel.img` - Binary kernel
- `build-output/x86_64/kernel.elf` - ELF kernel
- `build-output/x86_64/sageos.iso` - Bootable ISO

**Special Features:**
- Multiboot compliance
- GRUB bootloader integration
- ELF wrapper for proper loading

### AArch64 Build
```bash
make ARCH=aarch64
```

**Output Files:**
- `build-output/aarch64/kernel.img` - ARM64 kernel
- `build-output/aarch64/kernel.elf` - ELF format

**Cross-Compilation:**
- Uses `aarch64-linux-gnu-gcc`
- ARM64 assembly in `boot/boot.S`

### RISC-V Build
```bash
make ARCH=riscv64
```

**Output Files:**
- `build-output/riscv64/kernel.img` - RISC-V kernel
- `build-output/riscv64/kernel.elf` - ELF format

**Cross-Compilation:**
- Uses `riscv64-linux-gnu-gcc`
- RISC-V assembly in `boot/boot.S`

## 🔧 Build Process Details

### 1. Architecture Detection
```makefile
# Makefile automatically detects or uses specified architecture
ARCH ?= x86_64
ifeq ($(ARCH),x86_64)
    CC = gcc
    BOOT_FILE = boot/boot_no_multiboot.S
else ifeq ($(ARCH),aarch64)
    CC = aarch64-linux-gnu-gcc
    BOOT_FILE = boot/boot.S
else ifeq ($(ARCH),riscv64)
    CC = riscv64-linux-gnu-gcc
    BOOT_FILE = boot/boot.S
endif
```

### 2. Compilation Flags
```makefile
CFLAGS = -ffreestanding -nostdlib -nostartfiles -nodefaultlibs -fno-builtin -fno-stack-protector
LDFLAGS = -T linker.ld -nostdlib
```

### 3. Object Linking Order
```makefile
# Critical: Boot objects must come first for x86_64
OBJECTS = $(BOOT_OBJ) $(KERNEL_OBJS) $(DRIVER_OBJS) $(AI_OBJS)
```

### 4. x86_64 Special Handling
```bash
# Binary concatenation for multiboot compliance
cat multiboot_header.bin kernel_no_multiboot.bin > kernel.img

# ELF wrapper creation
python3 create_elf_wrapper.py kernel.img kernel.elf
```

## 🐳 Docker Build

### Using Docker
```bash
./docker-build.sh
```

**Dockerfile Features:**
- Multi-stage build
- All cross-compilation toolchains
- QEMU for testing
- Security scanning tools

### Docker Build Process
```dockerfile
FROM ubuntu:22.04
RUN apt update && apt install -y \
    build-essential \
    gcc-multilib \
    gcc-aarch64-linux-gnu \
    gcc-riscv64-linux-gnu \
    qemu-system-x86 \
    grub-pc-bin \
    xorriso \
    mtools
```

## 🔄 CI/CD Integration

### GitHub Actions Workflows

| Workflow | File | Purpose |
|----------|------|---------|
| SAGE OS CI | `.github/workflows/sageos-ci.yml` | Main CI pipeline |
| Multi-Arch Build | `.github/workflows/multi-arch-build.yml` | Cross-platform builds |
| Security Audit | `.github/workflows/security-license-audit.yml` | Security scanning |

### CI Build Matrix
```yaml
strategy:
  matrix:
    arch: [x86_64, aarch64, riscv64]
    include:
      - arch: x86_64
        cc: gcc
        test: qemu
      - arch: aarch64
        cc: aarch64-linux-gnu-gcc
        test: qemu-aarch64
      - arch: riscv64
        cc: riscv64-linux-gnu-gcc
        test: qemu-riscv64
```

## 🧪 Testing Builds

### QEMU Testing
```bash
# x86_64
./run_qemu.sh

# AArch64
qemu-system-aarch64 -M virt -cpu cortex-a57 -kernel build-output/aarch64/kernel.elf

# RISC-V
qemu-system-riscv64 -M virt -kernel build-output/riscv64/kernel.elf
```

### Automated Testing
```bash
./test-all-builds.sh
```

## 🔍 Build Troubleshooting

### Common Issues

#### 1. Multiboot Header Not Found
```
Error: Multiboot header not found
```
**Solution**: Ensure boot objects are linked first
```makefile
OBJECTS = $(BOOT_OBJ) $(OTHER_OBJS)
```

#### 2. Cross-Compiler Not Found
```
Error: aarch64-linux-gnu-gcc: command not found
```
**Solution**: Install cross-compilation toolchain
```bash
sudo apt install gcc-aarch64-linux-gnu
```

#### 3. ELF Format Issues
```
Error: invalid arch-dependent ELF magic
```
**Solution**: Use ELF wrapper for x86_64
```bash
python3 create_elf_wrapper.py kernel.img kernel.elf
```

### Debug Build
```bash
make ARCH=x86_64 DEBUG=1
```

**Debug Features:**
- Debug symbols included
- Verbose output
- Additional logging

## 📊 Build Performance

### Build Times (Approximate)

| Architecture | Clean Build | Incremental |
|--------------|-------------|-------------|
| x86_64 | 15 seconds | 3 seconds |
| aarch64 | 20 seconds | 4 seconds |
| riscv64 | 25 seconds | 5 seconds |
| All (parallel) | 45 seconds | 8 seconds |

### Optimization Flags
```makefile
# Release build
CFLAGS += -O2 -DNDEBUG

# Debug build
CFLAGS += -O0 -g -DDEBUG
```

## 🔧 Custom Builds

### Adding New Architecture
1. Add toolchain detection in `Makefile`
2. Create architecture-specific boot code
3. Update build scripts
4. Add CI/CD support

### Custom Kernel Modules
```makefile
# Add to Makefile
CUSTOM_OBJS = custom/module.o
OBJECTS += $(CUSTOM_OBJS)
```

## 📦 Build Artifacts

### Output Structure
```
build-output/
├── x86_64/
│   ├── kernel.img      # Binary kernel
│   ├── kernel.elf      # ELF kernel
│   └── sageos.iso      # Bootable ISO
├── aarch64/
│   ├── kernel.img
│   └── kernel.elf
└── riscv64/
    ├── kernel.img
    └── kernel.elf
```

### Artifact Sizes
- **x86_64 kernel**: ~50KB
- **AArch64 kernel**: ~45KB
- **RISC-V kernel**: ~48KB
- **ISO image**: ~2MB (includes GRUB)