# Installation Guide

This guide will help you install and set up SAGE OS on your system or in a virtual environment.

## 🎯 Prerequisites

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 2 GB | 8 GB |
| Storage | 10 GB | 50 GB |
| CPU | x86_64, ARM64, or RISC-V | Multi-core |
| Graphics | VGA compatible | Hardware acceleration |

### Supported Architectures

- **x86_64**: Intel/AMD 64-bit processors
- **ARM64**: ARM 64-bit processors (AArch64)
- **RISC-V**: RISC-V 64-bit processors

## 🛠️ Development Environment Setup

### Install Dependencies

=== "Ubuntu/Debian"
    ```bash
    sudo apt update
    sudo apt install -y \
        build-essential \
        nasm \
        grub-pc-bin \
        grub-efi-amd64-bin \
        xorriso \
        mtools \
        qemu-system-x86 \
        qemu-system-arm \
        qemu-system-misc \
        gcc-multilib \
        libc6-dev-i386
    ```

=== "Fedora/RHEL"
    ```bash
    sudo dnf install -y \
        gcc \
        nasm \
        grub2-pc \
        grub2-efi-x64 \
        xorriso \
        mtools \
        qemu-system-x86 \
        qemu-system-arm \
        qemu-system-riscv
    ```

=== "Arch Linux"
    ```bash
    sudo pacman -S \
        base-devel \
        nasm \
        grub \
        xorriso \
        mtools \
        qemu-system-x86 \
        qemu-system-arm \
        qemu-system-riscv
    ```

### Install Rust Toolchain

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# Add required targets
rustup target add x86_64-unknown-none
rustup target add aarch64-unknown-none
rustup target add riscv64gc-unknown-none-elf

# Install required components
rustup component add rust-src
rustup component add llvm-tools-preview
```

## 📥 Getting the Source Code

### Clone Repository

```bash
# Clone the main repository
git clone https://github.com/NMC-TechClub/SAGE-OS.git
cd SAGE-OS

# Switch to development branch
git checkout dev

# Initialize submodules (if any)
git submodule update --init --recursive
```

### Verify Setup

```bash
# Check build environment
make check-env

# Verify all dependencies
./scripts/verify-dependencies.sh
```

## 🏗️ Building SAGE OS

### Quick Build

```bash
# Build for x86_64 (default)
make build

# Build for specific architecture
make build ARCH=x86_64
make build ARCH=aarch64
make build ARCH=riscv64
```

### Detailed Build Process

```bash
# Clean previous builds
make clean

# Build bootloader
make bootloader ARCH=x86_64

# Build kernel
make kernel ARCH=x86_64

# Build user space
make userspace ARCH=x86_64

# Create ISO image
make iso ARCH=x86_64
```

### Build Configuration

Create a `.config` file to customize the build:

```bash
# .config
ARCH=x86_64
DEBUG=1
OPTIMIZATION=2
FEATURES=network,graphics,usb
TARGET_CPU=native
```

## 💿 Creating Installation Media

### ISO Image Creation

```bash
# Create bootable ISO
make iso ARCH=x86_64

# The ISO will be created at:
# dist/sage-os-x86_64.iso
```

### USB Drive Creation

```bash
# Create bootable USB drive (replace /dev/sdX with your USB device)
sudo dd if=dist/sage-os-x86_64.iso of=/dev/sdX bs=4M status=progress
sudo sync
```

### Virtual Machine Images

```bash
# Create QEMU disk image
make vm-image ARCH=x86_64

# Create VirtualBox image
make vbox-image ARCH=x86_64

# Create VMware image
make vmware-image ARCH=x86_64
```

## 🖥️ Installation Methods

### Method 1: Virtual Machine (Recommended for Testing)

#### QEMU

```bash
# Run in QEMU
make run ARCH=x86_64

# Or manually:
qemu-system-x86_64 \
    -cdrom dist/sage-os-x86_64.iso \
    -m 2G \
    -enable-kvm \
    -cpu host \
    -smp 2
```

#### VirtualBox

1. Create new VM with:
   - Type: Other
   - Version: Other/Unknown (64-bit)
   - Memory: 2048 MB
   - Hard disk: Create new (20 GB)

2. Mount the ISO and boot

#### VMware

1. Create new VM
2. Select "I will install the operating system later"
3. Choose "Other" as guest OS
4. Allocate resources
5. Mount ISO and boot

### Method 2: Physical Hardware

!!! warning "Hardware Installation"
    Installing on physical hardware will erase existing data. Ensure you have backups!

1. **Boot from USB/CD**
   - Insert installation media
   - Boot from USB/CD in BIOS/UEFI
   - Select SAGE OS from boot menu

2. **Installation Process**
   - Follow on-screen instructions
   - Select installation disk
   - Configure partitions
   - Set up user account
   - Complete installation

### Method 3: Network Boot (PXE)

```bash
# Set up PXE server
./scripts/setup-pxe-server.sh

# Configure DHCP for PXE boot
# Boot target machine from network
```

## ⚙️ Post-Installation Configuration

### First Boot

1. **System Configuration**
   - Set timezone
   - Configure network
   - Create user accounts
   - Set up SSH keys

2. **Package Management**
   ```bash
   # Update system
   sage-pkg update
   
   # Install additional packages
   sage-pkg install development-tools
   ```

3. **Security Setup**
   ```bash
   # Enable firewall
   sage-firewall enable
   
   # Configure secure boot
   sage-secureboot setup
   ```

### Development Setup

```bash
# Install development tools
sage-pkg install build-essential rust-toolchain

# Set up development environment
./scripts/setup-dev-env.sh

# Configure editor/IDE
sage-config editor vim  # or code, emacs, etc.
```

## 🔧 Troubleshooting

### Common Issues

#### Build Failures

```bash
# Check dependencies
./scripts/check-dependencies.sh

# Clean and rebuild
make clean && make build

# Verbose build output
make build V=1
```

#### Boot Issues

1. **UEFI Boot Problems**
   - Disable Secure Boot in BIOS
   - Enable Legacy Boot mode
   - Check boot order

2. **Hardware Compatibility**
   - Check supported hardware list
   - Update firmware/BIOS
   - Try different boot parameters

#### Virtual Machine Issues

1. **Performance Problems**
   - Enable hardware acceleration (KVM/VT-x)
   - Increase allocated memory
   - Use virtio drivers

2. **Graphics Issues**
   - Try different graphics modes
   - Disable 3D acceleration
   - Use software rendering

### Getting Help

- **Documentation**: Check the [troubleshooting guide](../troubleshooting/common-issues.md)
- **Issues**: Report bugs on [GitHub Issues](https://github.com/NMC-TechClub/SAGE-OS/issues)
- **Discussions**: Join [GitHub Discussions](https://github.com/NMC-TechClub/SAGE-OS/discussions)
- **Email**: Contact [ashishyesale007@gmail.com](mailto:ashishyesale007@gmail.com)

## 📊 Installation Verification

### System Check

```bash
# Check system information
sage-info system

# Verify installation
sage-verify --full

# Run system tests
sage-test --basic
```

### Performance Benchmarks

```bash
# Run performance tests
sage-benchmark --all

# Memory test
sage-test memory

# Storage test
sage-test storage

# Network test
sage-test network
```

## 🔄 Updates and Maintenance

### System Updates

```bash
# Check for updates
sage-update check

# Install updates
sage-update install

# Automatic updates
sage-update auto-enable
```

### Backup and Recovery

```bash
# Create system backup
sage-backup create --full

# Restore from backup
sage-backup restore --file backup.tar.gz

# Recovery mode
# Boot with 'recovery' kernel parameter
```

## 🔗 Next Steps

After successful installation:

1. **[Quick Start Guide](quickstart.md)** - Get familiar with SAGE OS
2. **[First Boot](first-boot.md)** - Initial system configuration
3. **[Development Setup](development-setup.md)** - Set up development environment
4. **[Architecture Overview](../architecture/overview.md)** - Understand the system

## 📚 Additional Resources

- [Build System Documentation](../components/build-system.md)
- [Multi-Architecture Support](../architecture/multi-arch.md)
- [Security Configuration](../security/best-practices.md)
- [Performance Tuning](../development/performance.md)