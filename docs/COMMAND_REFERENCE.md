# SAGE OS Command Reference Guide

**Version:** 1.0.0  
**Author:** Ashish Vasant Yesale <ashishyesale007@gmail.com>  
**Last Updated:** 2025-05-28  

## Table of Contents

1. [Build Commands](#build-commands)
2. [Testing Commands](#testing-commands)
3. [Security Commands](#security-commands)
4. [Docker Commands](#docker-commands)
5. [Utility Commands](#utility-commands)
6. [Environment Variables](#environment-variables)
7. [Configuration Files](#configuration-files)

---

## Build Commands

### Core Build System

#### Single Architecture Build
```bash
# Build kernel for x86_64
make -f Makefile.multi-arch kernel ARCH=x86_64 PLATFORM=generic

# Build kernel for i386
make -f Makefile.multi-arch kernel ARCH=i386 PLATFORM=generic

# Build kernel for ARM64 (Raspberry Pi 4)
make -f Makefile.multi-arch kernel ARCH=aarch64 PLATFORM=rpi4

# Build kernel for ARM64 (Raspberry Pi 5)
make -f Makefile.multi-arch kernel ARCH=aarch64 PLATFORM=rpi5

# Build kernel for ARM32 (Raspberry Pi 4)
make -f Makefile.multi-arch kernel ARCH=arm PLATFORM=rpi4

# Build kernel for RISC-V 64-bit
make -f Makefile.multi-arch kernel ARCH=riscv64 PLATFORM=generic
```

#### Multi-Architecture Build
```bash
# Build all supported architectures
./build.sh --all

# Build specific architectures
./build.sh --arch i386,x86_64,aarch64

# Build with parallel jobs
./build.sh --all --jobs 4

# Build on macOS
./build-macos.sh

# Build all architectures on macOS
./build-macos.sh --all
```

#### Build Options
```bash
# Debug build with symbols
make -f Makefile.multi-arch kernel ARCH=x86_64 DEBUG=1

# Verbose build output
make -f Makefile.multi-arch kernel ARCH=x86_64 VERBOSE=1

# Optimized build
make -f Makefile.multi-arch kernel ARCH=x86_64 OPTIMIZE=1

# Size-optimized build
make -f Makefile.multi-arch kernel ARCH=x86_64 OPTIMIZE=size

# Parallel build
make -f Makefile.multi-arch kernel ARCH=x86_64 -j$(nproc)
```

#### Clean Operations
```bash
# Clean specific architecture
make -f Makefile.multi-arch clean ARCH=x86_64

# Clean all architectures
make -f Makefile.multi-arch clean-all

# Deep clean (remove all build artifacts)
make -f Makefile.multi-arch distclean

# Clean and rebuild
make -f Makefile.multi-arch clean ARCH=x86_64 && \
make -f Makefile.multi-arch kernel ARCH=x86_64
```

### Image Creation

#### ISO Creation
```bash
# Create bootable ISO for x86_64
make -f Makefile.multi-arch iso ARCH=x86_64 PLATFORM=generic

# Create ISO with GRUB bootloader
make -f Makefile.multi-arch iso ARCH=i386 PLATFORM=generic

# Create ISO with custom kernel
make -f Makefile.multi-arch iso ARCH=x86_64 KERNEL_IMG=custom-kernel.img

# Create ISO for all architectures
for arch in i386 x86_64; do
    make -f Makefile.multi-arch iso ARCH=$arch PLATFORM=generic
done
```

#### SD Card Images
```bash
# Create SD card image for Raspberry Pi 4
make -f Makefile.multi-arch sdcard ARCH=aarch64 PLATFORM=rpi4

# Create SD card image for Raspberry Pi 5
make -f Makefile.multi-arch sdcard ARCH=aarch64 PLATFORM=rpi5

# Create generic ARM SD card image
make -f Makefile.multi-arch sdcard ARCH=aarch64 PLATFORM=generic
```

#### Custom Image Creation
```bash
# Create custom ISO with scripts
./scripts/create_iso.sh --arch x86_64 --output custom.iso

# Create image with specific size
make -f Makefile.multi-arch iso ARCH=x86_64 IMAGE_SIZE=100M

# Create compressed image
make -f Makefile.multi-arch iso ARCH=x86_64 COMPRESS=1
```

---

## Testing Commands

### QEMU Testing

#### Basic QEMU Tests
```bash
# Test kernel in QEMU (30-second timeout)
make -f Makefile.multi-arch qemu-test ARCH=x86_64 PLATFORM=generic

# Test with custom timeout
make -f Makefile.multi-arch qemu-test ARCH=x86_64 TIMEOUT=60

# Test ISO in QEMU
make -f Makefile.multi-arch qemu-iso ARCH=x86_64 PLATFORM=generic

# Test with custom kernel
make -f Makefile.multi-arch qemu-test ARCH=x86_64 KERNEL_IMG=custom-kernel.img
```

#### Manual QEMU Commands
```bash
# x86_64 QEMU test
qemu-system-x86_64 \
    -kernel build-output/SAGE-OS-0.1.0-x86_64-generic.img \
    -m 256M \
    -nographic \
    -serial stdio

# i386 QEMU test
qemu-system-i386 \
    -kernel build-output/SAGE-OS-0.1.0-i386-generic.img \
    -m 256M \
    -nographic \
    -serial stdio

# ARM64 QEMU test (Raspberry Pi 4)
qemu-system-aarch64 \
    -machine virt \
    -cpu cortex-a57 \
    -kernel build-output/SAGE-OS-0.1.0-aarch64-rpi4.img \
    -m 256M \
    -nographic \
    -serial stdio

# ARM32 QEMU test
qemu-system-arm \
    -machine virt \
    -cpu cortex-a15 \
    -kernel build-output/SAGE-OS-0.1.0-arm-generic.img \
    -m 256M \
    -nographic \
    -serial stdio

# RISC-V QEMU test
qemu-system-riscv64 \
    -machine virt \
    -kernel build-output/SAGE-OS-0.1.0-riscv64-generic.img \
    -m 256M \
    -nographic \
    -serial stdio
```

#### TMUX-Based Testing (Recommended)
```bash
# Start QEMU in tmux session
tmux new-session -d -s sage-test-x86_64 \
    "qemu-system-x86_64 -kernel build-output/SAGE-OS-0.1.0-x86_64-generic.img -nographic"

# Attach to session
tmux attach-session -t sage-test-x86_64

# List active sessions
tmux list-sessions

# Kill session
tmux kill-session -t sage-test-x86_64

# Kill all SAGE OS test sessions
tmux list-sessions | grep sage-test | cut -d: -f1 | xargs -I {} tmux kill-session -t {}
```

#### ISO Testing
```bash
# Test ISO boot in QEMU
qemu-system-x86_64 \
    -cdrom dist/x86_64/SAGE-OS-0.1.0-x86_64-generic.iso \
    -boot d \
    -m 256M \
    -nographic \
    -serial stdio

# Test ISO with VGA output
qemu-system-x86_64 \
    -cdrom dist/x86_64/SAGE-OS-0.1.0-x86_64-generic.iso \
    -boot d \
    -m 256M \
    -vga std

# Test ISO with network
qemu-system-x86_64 \
    -cdrom dist/x86_64/SAGE-OS-0.1.0-x86_64-generic.iso \
    -boot d \
    -m 256M \
    -netdev user,id=net0 \
    -device e1000,netdev=net0
```

### Comprehensive Testing

#### Test All Builds
```bash
# Test all architectures
./test-all-builds.sh

# Test specific architectures
./test-all-builds.sh --arch x86_64,aarch64

# Test with verbose output
./test-all-builds.sh --verbose

# Test with custom timeout
./test-all-builds.sh --timeout 60
```

#### Benchmark Testing
```bash
# Run build benchmarks
./benchmark-builds.sh

# Benchmark specific architecture
./benchmark-builds.sh --arch x86_64

# Benchmark with multiple runs
./benchmark-builds.sh --runs 5

# Benchmark parallel builds
./benchmark-builds.sh --parallel
```

#### Integration Testing
```bash
# Run integration tests
cd tests && python3 -m pytest integration_tests/

# Run specific test suite
cd tests && python3 -m pytest integration_tests/test_boot.py

# Run tests with coverage
cd tests && python3 -m pytest --cov=../kernel integration_tests/

# Run performance tests
cd tests && python3 -m pytest integration_tests/test_performance.py
```

---

## Security Commands

### Enhanced CVE Scanner

#### Basic Security Scanning
```bash
# Run comprehensive security scan
./scripts/enhanced-cve-scanner.sh

# Scan specific architecture
./scripts/enhanced-cve-scanner.sh --arch x86_64

# Scan multiple architectures
./scripts/enhanced-cve-scanner.sh --arch i386,x86_64,aarch64

# Verbose scanning
./scripts/enhanced-cve-scanner.sh --verbose
```

#### Output Format Options
```bash
# Generate HTML report
./scripts/enhanced-cve-scanner.sh --format html

# Generate multiple formats
./scripts/enhanced-cve-scanner.sh --format json,html,pdf,csv

# Generate all supported formats
./scripts/enhanced-cve-scanner.sh --format console,json,html,pdf,csv,xml

# Custom output directory
./scripts/enhanced-cve-scanner.sh --output-dir my-security-scan --format html
```

#### Specific Scanning Options
```bash
# Scan specific binary
./scripts/enhanced-cve-scanner.sh --binary build-output/SAGE-OS-0.1.0-x86_64-generic.img

# Skip Docker scanning
./scripts/enhanced-cve-scanner.sh --no-docker

# Skip binary scanning
./scripts/enhanced-cve-scanner.sh --no-binaries

# Skip source code scanning
./scripts/enhanced-cve-scanner.sh --no-source

# Summary report only
./scripts/enhanced-cve-scanner.sh --summary-only --format html
```

#### Legacy CVE Scanner
```bash
# Run legacy Python CVE scanner
python3 scripts/cve_scanner.py

# Scan with custom project root
python3 scripts/cve_scanner.py --project-root /path/to/sage-os

# Skip Docker scanning
python3 scripts/cve_scanner.py --no-docker

# Scan specific binary
python3 scripts/cve_scanner.py --binary build/x86_64/kernel.img
```

### Security Analysis

#### Quick Security Check
```bash
# Run quick security scan
./scripts/security-scan.sh

# Security scan with verbose output
./scripts/security-scan.sh --verbose

# Security scan for specific architecture
./scripts/security-scan.sh --arch x86_64
```

#### Comprehensive Security Analysis
```bash
# Run comprehensive security analysis
python3 comprehensive-security-analysis.py

# Security analysis with custom output
python3 comprehensive-security-analysis.py --output security-report.json

# Analyze specific components
python3 comprehensive-security-analysis.py --component kernel,drivers
```

#### License Compliance
```bash
# Check license headers
python3 scripts/enhanced_license_tool.py --check

# Fix license headers
python3 scripts/enhanced_license_tool.py --fix

# Check specific file types
python3 scripts/enhanced_license_tool.py --check --file-types .c,.h,.S

# Generate license report
python3 scripts/enhanced_license_tool.py --report --output license-report.html
```

---

## Docker Commands

### Docker Builder

#### Basic Docker Operations
```bash
# Build Docker images for all architectures
./scripts/docker-builder.sh

# Build for specific architectures
./scripts/docker-builder.sh --arch x86_64,aarch64

# Build with verbose output
./scripts/docker-builder.sh --verbose

# Show help
./scripts/docker-builder.sh --help
```

#### Registry Operations
```bash
# Build with custom registry
./scripts/docker-builder.sh --registry docker.io/myusername

# Build and push to registry
./scripts/docker-builder.sh --registry docker.io/myusername --push

# Build with custom tag prefix
./scripts/docker-builder.sh --tag-prefix my-sage-os

# Build for specific registry and architecture
./scripts/docker-builder.sh --registry ghcr.io/myorg --arch x86_64 --push
```

#### Manual Docker Operations
```bash
# Build Docker image manually
docker build -t sage-os:0.1.0-x86_64-generic .

# Build for specific architecture
docker build --platform linux/amd64 -t sage-os:0.1.0-x86_64-generic .

# Build multi-architecture image
docker buildx build --platform linux/amd64,linux/arm64 -t sage-os:0.1.0-multi .

# Push to registry
docker push sage-os:0.1.0-x86_64-generic
```

### Running SAGE OS in Docker

#### Basic Container Operations
```bash
# Run SAGE OS container
docker run -it sage-os:0.1.0-x86_64-generic

# Run in background
docker run -d --name sage-os-instance sage-os:0.1.0-x86_64-generic

# Run with port forwarding
docker run -it -p 5900:5900 -p 8080:8080 sage-os:0.1.0-x86_64-generic

# Run with volume mounting
docker run -it -v $(pwd)/data:/opt/sage-os/data sage-os:0.1.0-x86_64-generic
```

#### Container Management
```bash
# List running containers
docker ps

# List all containers
docker ps -a

# Stop container
docker stop sage-os-instance

# Remove container
docker rm sage-os-instance

# View container logs
docker logs sage-os-instance

# Execute command in running container
docker exec -it sage-os-instance bash
```

#### Docker Image Management
```bash
# List SAGE OS images
docker images | grep sage-os

# Remove specific image
docker rmi sage-os:0.1.0-x86_64-generic

# Remove all SAGE OS images
docker images | grep sage-os | awk '{print $3}' | xargs docker rmi

# Prune unused images
docker image prune

# Show image details
docker inspect sage-os:0.1.0-x86_64-generic
```

---

## Utility Commands

### Project Management

#### Build System Verification
```bash
# Verify build system
./VERIFY_BUILD_SYSTEM.sh

# Check dependencies
./VERIFY_BUILD_SYSTEM.sh --check-deps

# Install missing dependencies
./VERIFY_BUILD_SYSTEM.sh --install-deps
```

#### File Management
```bash
# Create ELF wrapper
python3 create_elf_wrapper.py --input kernel.bin --output kernel.elf

# Create multiboot header
python3 create_multiboot_header.py --input kernel.bin --output kernel-mb.bin

# Update license templates
python3 update_license_templates.py

# Apply license headers
python3 apply-license-headers.py
```

#### Testing Utilities
```bash
# Test emulated environment
./scripts/test_emulated.sh

# Test specific emulation
./scripts/test_emulated.sh --arch x86_64

# Test with custom timeout
./scripts/test_emulated.sh --timeout 120
```

### Development Tools

#### Code Quality
```bash
# Check code formatting
clang-format -i kernel/*.c kernel/*.h

# Run static analysis
cppcheck --enable=all kernel/

# Check for memory leaks
valgrind --tool=memcheck ./build/x86_64/kernel.elf

# Profile performance
perf record -g ./build/x86_64/kernel.elf
perf report
```

#### Documentation
```bash
# Generate documentation
doxygen Doxyfile

# Build MkDocs documentation
mkdocs build

# Serve documentation locally
mkdocs serve

# Deploy documentation
mkdocs gh-deploy
```

#### Git Operations
```bash
# Check repository status
git status

# Show commit history
git log --oneline --graph

# Create feature branch
git checkout -b feature/new-feature

# Commit changes with proper message
git commit -m "feat(kernel): add new memory management"

# Push to remote
git push origin feature/new-feature

# Create pull request (GitHub CLI)
gh pr create --title "Add new feature" --body "Description of changes"
```

---

## Environment Variables

### Build Configuration
```bash
# Compiler settings
export CC_i386="gcc -m32"
export CC_x86_64="gcc -m64"
export CC_aarch64="aarch64-linux-gnu-gcc"
export CC_arm="arm-linux-gnueabihf-gcc"
export CC_riscv64="riscv64-linux-gnu-gcc"

# Build options
export DEBUG=1                    # Enable debug symbols
export VERBOSE=1                  # Verbose build output
export OPTIMIZE=1                 # Enable optimizations
export PARALLEL_JOBS=4            # Number of parallel jobs
export BUILD_DIR="custom-build"   # Custom build directory
export OUTPUT_DIR="custom-output" # Custom output directory
```

### Testing Configuration
```bash
# QEMU settings
export QEMU_TIMEOUT=30           # Default QEMU timeout
export QEMU_MEMORY=256M          # Default memory size
export QEMU_EXTRA_ARGS="-nographic" # Additional QEMU arguments

# Testing options
export TEST_ARCHITECTURES="x86_64,aarch64" # Architectures to test
export TEST_PLATFORMS="generic,rpi4"       # Platforms to test
export TEST_VERBOSE=1                       # Verbose test output
```

### Security Configuration
```bash
# CVE scanner settings
export CVE_OUTPUT_DIR="security-reports"   # CVE scan output directory
export CVE_FORMATS="json,html"             # Default output formats
export CVE_ARCHITECTURES="all"             # Architectures to scan
export CVE_VERBOSE=1                        # Verbose CVE scanning

# Docker settings
export DOCKER_REGISTRY="docker.io/myuser"  # Default Docker registry
export DOCKER_TAG_PREFIX="sage-os"         # Docker tag prefix
export DOCKER_PUSH=0                        # Auto-push to registry
```

### Development Configuration
```bash
# Git settings
export GIT_AUTHOR_NAME="Your Name"
export GIT_AUTHOR_EMAIL="your.email@example.com"
export GIT_COMMITTER_NAME="Your Name"
export GIT_COMMITTER_EMAIL="your.email@example.com"

# Editor settings
export EDITOR="vim"              # Default editor
export PAGER="less"              # Default pager

# Path settings
export PATH="$HOME/toolchains/bin:$PATH"  # Custom toolchain path
```

---

## Configuration Files

### Build Configuration

#### Makefile.multi-arch Variables
```makefile
# Architecture settings
ARCH ?= x86_64
PLATFORM ?= generic
DEBUG ?= 0
VERBOSE ?= 0
OPTIMIZE ?= 0

# Compiler settings
CC_i386 = gcc -m32
CC_x86_64 = gcc -m64
CC_aarch64 = aarch64-linux-gnu-gcc
CC_arm = arm-linux-gnueabihf-gcc
CC_riscv64 = riscv64-linux-gnu-gcc

# Build directories
BUILD_DIR = build/$(ARCH)
OUTPUT_DIR = build-output
DIST_DIR = dist/$(ARCH)

# Version information
PROJECT_VERSION = 0.1.0
PROJECT_NAME = SAGE-OS
```

#### build.sh Configuration
```bash
# Default settings in build.sh
DEFAULT_ARCHITECTURES="i386 x86_64 aarch64 arm riscv64"
DEFAULT_PLATFORMS="generic rpi4 rpi5"
DEFAULT_JOBS=1
DEFAULT_VERBOSE=0
DEFAULT_DEBUG=0

# Toolchain detection
TOOLCHAIN_PREFIXES=(
    "i386:i686-linux-gnu-"
    "x86_64:x86_64-linux-gnu-"
    "aarch64:aarch64-linux-gnu-"
    "arm:arm-linux-gnueabihf-"
    "riscv64:riscv64-linux-gnu-"
)
```

### QEMU Configuration

#### Default QEMU Settings
```bash
# QEMU memory settings
QEMU_MEMORY_i386="256M"
QEMU_MEMORY_x86_64="512M"
QEMU_MEMORY_aarch64="512M"
QEMU_MEMORY_arm="256M"
QEMU_MEMORY_riscv64="256M"

# QEMU machine settings
QEMU_MACHINE_i386="pc"
QEMU_MACHINE_x86_64="pc"
QEMU_MACHINE_aarch64="virt"
QEMU_MACHINE_arm="virt"
QEMU_MACHINE_riscv64="virt"

# QEMU CPU settings
QEMU_CPU_aarch64="cortex-a57"
QEMU_CPU_arm="cortex-a15"
```

### Security Configuration

#### CVE Scanner Configuration
```bash
# Default CVE scanner settings
DEFAULT_OUTPUT_FORMATS="console"
DEFAULT_ARCHITECTURES="all"
DEFAULT_SCAN_DOCKER=true
DEFAULT_SCAN_BINARIES=true
DEFAULT_SCAN_SOURCE=true
DEFAULT_VERBOSE=false

# Report structure
REPORT_STRUCTURE=(
    "summary"
    "architecture_reports"
    "docker_reports"
    "binary_reports"
    "source_reports"
)
```

#### Docker Configuration
```dockerfile
# Default Docker settings
DEFAULT_BASE_IMAGE_i386="i386/alpine:latest"
DEFAULT_BASE_IMAGE_x86_64="alpine:latest"
DEFAULT_BASE_IMAGE_aarch64="arm64v8/alpine:latest"
DEFAULT_BASE_IMAGE_arm="arm32v7/alpine:latest"
DEFAULT_BASE_IMAGE_riscv64="riscv64/alpine:edge"

# Container settings
DEFAULT_MEMORY="256M"
DEFAULT_USER="sage"
DEFAULT_WORKDIR="/opt/sage-os"
```

---

## Quick Reference Card

### Most Common Commands
```bash
# Build and test x86_64
make -f Makefile.multi-arch kernel ARCH=x86_64 PLATFORM=generic
make -f Makefile.multi-arch qemu-test ARCH=x86_64 PLATFORM=generic

# Build all architectures
./build.sh --all

# Create ISO
make -f Makefile.multi-arch iso ARCH=x86_64 PLATFORM=generic

# Security scan
./scripts/enhanced-cve-scanner.sh --arch x86_64 --format html

# Docker build
./scripts/docker-builder.sh --arch x86_64

# Clean build
make -f Makefile.multi-arch clean ARCH=x86_64

# Test all builds
./test-all-builds.sh
```

### Emergency Commands
```bash
# Kill stuck QEMU processes
pkill -f qemu-system
tmux kill-server

# Clean everything
make -f Makefile.multi-arch distclean
rm -rf build/ dist/ build-output/

# Reset git state
git reset --hard HEAD
git clean -fd

# Check system status
./VERIFY_BUILD_SYSTEM.sh
```

---

**Last Updated:** 2025-05-28  
**Version:** 1.0.0  
**Maintainer:** Ashish Vasant Yesale <ashishyesale007@gmail.com>

For additional help, run any command with `--help` or refer to the [Developer Implementation Guide](DEVELOPER_IMPLEMENTATION_GUIDE.md).