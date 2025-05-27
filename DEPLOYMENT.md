<!--
─────────────────────────────────────────────────────────────────────────────
SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
SPDX-License-Identifier: BSD-3-Clause OR Proprietary
SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.

This file is part of the SAGE OS Project.
─────────────────────────────────────────────────────────────────────────────
-->

# SAGE OS Deployment Guide

## 🚀 Production Deployment

This guide covers deploying SAGE OS to various target platforms including Raspberry Pi, x86_64 systems, and embedded devices.

## 📋 Deployment Matrix

| Platform | Architecture | Deployment Method | Boot Media | Status |
|----------|-------------|-------------------|------------|--------|
| Raspberry Pi 4 | aarch64/arm | SD Card | MicroSD | ✅ Ready |
| Raspberry Pi 5 | aarch64 | SD Card | MicroSD | ✅ Ready |
| Generic ARM64 | aarch64 | Various | SD/eMMC/USB | ✅ Ready |
| x86_64 PC | x86_64 | USB/CD/PXE | USB/SATA/NVMe | ✅ Ready |
| RISC-V Boards | riscv64 | SD Card | MicroSD | ⚠️ Experimental |

## 🥧 Raspberry Pi Deployment

### Supported Models
- **Raspberry Pi 4 Model B** (1GB, 2GB, 4GB, 8GB)
- **Raspberry Pi 5** (4GB, 8GB)
- **Raspberry Pi 400** (4GB keyboard computer)
- **Raspberry Pi Compute Module 4**

### Prerequisites
- MicroSD card (8GB minimum, 32GB recommended)
- Class 10 or better SD card for optimal performance
- Appropriate power supply (USB-C for Pi 4/5)
- Optional: UART-to-USB adapter for debugging

### Quick Deployment

#### Method 1: Automated Script
```bash
# Download deployment script
curl -O https://raw.githubusercontent.com/AshishYesale7/SAGE-OS/main/deploy-pi.sh
chmod +x deploy-pi.sh

# Deploy to SD card (replace /dev/sdX with your SD card device)
sudo ./deploy-pi.sh /dev/sdX aarch64 rpi4

# For Raspberry Pi 5
sudo ./deploy-pi.sh /dev/sdX aarch64 rpi5
```

#### Method 2: Manual Deployment
```bash
# 1. Prepare SD card
sudo fdisk /dev/sdX
# Create single FAT32 partition

# 2. Format partition
sudo mkfs.vfat -F 32 /dev/sdX1

# 3. Mount partition
sudo mkdir -p /mnt/sage-deploy
sudo mount /dev/sdX1 /mnt/sage-deploy

# 4. Copy kernel image
sudo cp build-output/kernel-aarch64-rpi4.img /mnt/sage-deploy/kernel8.img

# 5. Create boot configuration
sudo tee /mnt/sage-deploy/config.txt << 'EOF'
# SAGE OS Boot Configuration
arm_64bit=1
kernel=kernel8.img

# UART Configuration
uart_2ndstage=1
enable_uart=1

# Memory Configuration
gpu_mem=16
arm_freq=1500

# Display Configuration
disable_splash=1
disable_overscan=1

# Boot Configuration
boot_delay=1
disable_commandline_tags=1

# AI HAT+ Configuration (Pi 5 only)
dtparam=i2c_arm=on
dtparam=spi=on
EOF

# 6. Create command line (optional)
sudo tee /mnt/sage-deploy/cmdline.txt << 'EOF'
console=serial0,115200 console=tty1 loglevel=7
EOF

# 7. Safely unmount
sudo umount /mnt/sage-deploy
```

### Advanced Configuration

#### Performance Optimization
```bash
# High-performance config.txt
sudo tee /mnt/sage-deploy/config.txt << 'EOF'
# SAGE OS High-Performance Configuration
arm_64bit=1
kernel=kernel8.img

# CPU Configuration
arm_freq=2000
over_voltage=6
force_turbo=1

# Memory Configuration
gpu_mem=16
gpu_mem_256=16
gpu_mem_512=16
gpu_mem_1024=16

# I/O Configuration
dtparam=sd_overclock=100
dtparam=audio=off
dtparam=i2c_arm=on,i2c_arm_baudrate=1000000
dtparam=spi=on

# Power Management
usb_max_current_enable=1

# Boot Optimization
disable_splash=1
boot_delay=0
initial_turbo=60
EOF
```

#### AI HAT+ Configuration (Pi 5)
```bash
# AI-optimized config.txt for Pi 5
sudo tee /mnt/sage-deploy/config.txt << 'EOF'
# SAGE OS AI HAT+ Configuration
arm_64bit=1
kernel=kernel8.img

# AI HAT+ Support
dtoverlay=ai-hat-plus
dtparam=i2c_arm=on,i2c_arm_baudrate=400000
dtparam=spi=on

# PCIe Configuration (Pi 5)
dtparam=pciex1
dtparam=pciex1_gen=3

# Memory for AI workloads
gpu_mem=128
arm_freq=2400
gpu_freq=800

# Thermal management
temp_limit=80
EOF
```

### Deployment Verification
```bash
# 1. Insert SD card and power on Pi
# 2. Connect via serial console
sudo screen /dev/ttyUSB0 115200

# 3. Expected boot sequence:
# SAGE OS v0.1.0 - Self-Aware General Environment
# Booting on Raspberry Pi 4/5...
# Memory: XXX MB
# Shell> _

# 4. Test basic functionality
help
version
memory
gpio status
```

## 💻 x86_64 PC Deployment

### Supported Systems
- Desktop PCs (Intel/AMD)
- Laptops
- Embedded x86_64 systems
- Virtual machines
- Industrial PCs

### Boot Methods

#### USB Boot
```bash
# Create bootable USB drive
sudo dd if=build-output/kernel-x86_64-generic.img of=/dev/sdX bs=1M status=progress
sync

# Or use specialized tools
# Linux: Use 'dd' or 'Etcher'
# Windows: Use 'Rufus' or 'Win32DiskImager'
# macOS: Use 'dd' or 'Etcher'
```

#### CD/DVD Boot
```bash
# Create ISO image (if ISO creation is implemented)
make -f Makefile.multi-arch iso ARCH=x86_64

# Burn to CD/DVD
# Linux: brasero, k3b, or cdrecord
# Windows: ImgBurn, CDBurnerXP
# macOS: Disk Utility
```

#### PXE Network Boot
```bash
# Setup PXE server (example with dnsmasq)
sudo apt install dnsmasq tftpd-hpa

# Configure dnsmasq
sudo tee /etc/dnsmasq.conf << 'EOF'
interface=eth0
dhcp-range=192.168.1.100,192.168.1.200,12h
dhcp-boot=pxelinux.0
enable-tftp
tftp-root=/var/lib/tftpboot
EOF

# Copy kernel to TFTP root
sudo cp build-output/kernel-x86_64-generic.img /var/lib/tftpboot/sage-kernel.img

# Create PXE configuration
sudo mkdir -p /var/lib/tftpboot/pxelinux.cfg
sudo tee /var/lib/tftpboot/pxelinux.cfg/default << 'EOF'
DEFAULT sage
LABEL sage
    KERNEL sage-kernel.img
    APPEND console=ttyS0,115200 console=tty0
EOF

# Start services
sudo systemctl restart dnsmasq
sudo systemctl restart tftpd-hpa
```

### UEFI/BIOS Configuration

#### UEFI Systems
```bash
# Create UEFI-compatible boot structure
mkdir -p uefi-boot/EFI/BOOT
cp build-output/kernel-x86_64-generic.img uefi-boot/EFI/BOOT/BOOTX64.EFI

# Create startup.nsh
tee uefi-boot/startup.nsh << 'EOF'
@echo -off
EFI\BOOT\BOOTX64.EFI
EOF

# Copy to USB/CD
sudo cp -r uefi-boot/* /mnt/usb/
```

#### Legacy BIOS
```bash
# Use GRUB for legacy boot
sudo grub-install --target=i386-pc /dev/sdX
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Add SAGE OS entry to grub.cfg
menuentry "SAGE OS" {
    multiboot /sage-kernel.img
}
```

## 🔧 Embedded Systems Deployment

### ARM64 Generic Boards
- NVIDIA Jetson series
- Rockchip RK3399/RK3588
- Allwinner H6/H616
- Amlogic S922X/A311D

#### U-Boot Deployment
```bash
# Create U-Boot compatible image
mkimage -A arm64 -O linux -T kernel -C none \
    -a 0x80080000 -e 0x80080000 \
    -n "SAGE OS" -d build-output/kernel-aarch64-generic.img \
    sage-uImage

# Copy to boot partition
cp sage-uImage /boot/
cp device-tree.dtb /boot/

# Update U-Boot environment
setenv bootcmd 'fatload mmc 0:1 0x80080000 sage-uImage; bootm 0x80080000'
saveenv
```

### RISC-V Boards
- SiFive HiFive boards
- StarFive VisionFive
- Canaan Kendryte K210

#### OpenSBI Deployment
```bash
# Combine with OpenSBI
riscv64-linux-gnu-objcopy -O binary \
    build-output/kernel-riscv64-generic.elf \
    kernel.bin

# Create FIT image
mkimage -f sage-riscv.its sage-riscv.itb

# Flash to board
dd if=opensbi-riscv64.bin of=/dev/sdX bs=1M seek=1
dd if=sage-riscv.itb of=/dev/sdX bs=1M seek=2
```

## 🌐 Network Deployment

### TFTP Boot Server Setup
```bash
# Install TFTP server
sudo apt install tftpd-hpa

# Configure TFTP
sudo tee /etc/default/tftpd-hpa << 'EOF'
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/var/lib/tftpboot"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
EOF

# Copy kernels
sudo cp build-output/kernel-*.img /var/lib/tftpboot/

# Start service
sudo systemctl enable tftpd-hpa
sudo systemctl start tftpd-hpa
```

### HTTP Boot Server
```bash
# Install HTTP server
sudo apt install nginx

# Create boot directory
sudo mkdir -p /var/www/html/sage-boot

# Copy kernel images
sudo cp build-output/* /var/www/html/sage-boot/

# Create index page
sudo tee /var/www/html/sage-boot/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>SAGE OS Boot Server</title></head>
<body>
<h1>SAGE OS Kernel Images</h1>
<ul>
<li><a href="kernel-aarch64-rpi4.img">Raspberry Pi 4 (ARM64)</a></li>
<li><a href="kernel-aarch64-rpi5.img">Raspberry Pi 5 (ARM64)</a></li>
<li><a href="kernel-x86_64-generic.img">x86_64 Generic</a></li>
<li><a href="kernel-riscv64-generic.img">RISC-V 64-bit</a></li>
</ul>
</body>
</html>
EOF

# Start nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

## 🐳 Container Deployment

### Docker Deployment
```bash
# Build Docker image
docker build -t sage-os:latest .

# Run container
docker run -it --rm sage-os:latest

# Multi-architecture build
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t sage-os:multi .
```

### Kubernetes Deployment
```yaml
# sage-os-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sage-os
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sage-os
  template:
    metadata:
      labels:
        app: sage-os
    spec:
      containers:
      - name: sage-os
        image: sage-os:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: sage-os-service
spec:
  selector:
    app: sage-os
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

## 🔧 Production Configuration

### Security Hardening
```bash
# Secure boot configuration
sudo tee /mnt/sage-deploy/config.txt << 'EOF'
# Security Configuration
arm_64bit=1
kernel=kernel8.img

# Disable unnecessary features
camera_auto_detect=0
display_auto_detect=0
dtoverlay=disable-wifi
dtoverlay=disable-bt

# Secure boot
secure_boot=1
signing_key=/boot/sage-signing.key

# Hardware security
random_seed_enable=1
EOF
```

### Performance Tuning
```bash
# Performance configuration
sudo tee /mnt/sage-deploy/config.txt << 'EOF'
# Performance Configuration
arm_64bit=1
kernel=kernel8.img

# CPU Performance
arm_freq=2000
gpu_freq=750
core_freq=500
sdram_freq=500

# Memory Performance
gpu_mem=16
disable_l2cache=0
disable_pvt=0

# I/O Performance
dtparam=sd_overclock=100
dtparam=spi=on
force_eeprom_read=0
EOF
```

### Monitoring Configuration
```bash
# Enable system monitoring
sudo tee /mnt/sage-deploy/config.txt << 'EOF'
# Monitoring Configuration
arm_64bit=1
kernel=kernel8.img

# Temperature monitoring
temp_limit=80
temp_soft_limit=70

# Voltage monitoring
over_voltage_avs=0x24000

# Performance monitoring
arm_pmu=on
EOF
```

## 📊 Deployment Automation

### Automated Deployment Script
```bash
#!/bin/bash
# deploy-sage.sh - Automated SAGE OS deployment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCH=""
PLATFORM=""
TARGET=""
DEVICE=""

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -a, --arch ARCH        Target architecture (aarch64, arm, x86_64, riscv64)"
    echo "  -p, --platform PLATFORM Target platform (rpi4, rpi5, generic)"
    echo "  -t, --target TARGET    Deployment target (sdcard, usb, network)"
    echo "  -d, --device DEVICE    Target device (e.g., /dev/sdX)"
    echo "  -h, --help            Show this help"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--arch)
            ARCH="$2"
            shift 2
            ;;
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -t|--target)
            TARGET="$2"
            shift 2
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate arguments
if [[ -z "$ARCH" || -z "$PLATFORM" || -z "$TARGET" ]]; then
    echo "Error: Missing required arguments"
    usage
fi

KERNEL_IMAGE="build-output/kernel-${ARCH}-${PLATFORM}.img"

if [[ ! -f "$KERNEL_IMAGE" ]]; then
    echo "Error: Kernel image not found: $KERNEL_IMAGE"
    echo "Run './build-all-architectures.sh' first"
    exit 1
fi

echo "🚀 SAGE OS Deployment"
echo "===================="
echo "Architecture: $ARCH"
echo "Platform: $PLATFORM"
echo "Target: $TARGET"
echo "Kernel: $KERNEL_IMAGE"

case $TARGET in
    "sdcard")
        if [[ -z "$DEVICE" ]]; then
            echo "Error: Device required for SD card deployment"
            exit 1
        fi
        deploy_sdcard "$DEVICE" "$KERNEL_IMAGE" "$ARCH" "$PLATFORM"
        ;;
    "usb")
        if [[ -z "$DEVICE" ]]; then
            echo "Error: Device required for USB deployment"
            exit 1
        fi
        deploy_usb "$DEVICE" "$KERNEL_IMAGE"
        ;;
    "network")
        deploy_network "$KERNEL_IMAGE"
        ;;
    *)
        echo "Error: Unknown target: $TARGET"
        usage
        ;;
esac

echo "✅ Deployment completed successfully!"
```

### CI/CD Pipeline Integration
```yaml
# .github/workflows/deploy.yml
name: Deploy SAGE OS
on:
  release:
    types: [published]

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        arch: [aarch64, arm, x86_64, riscv64]
        platform: [rpi4, rpi5, generic]
        exclude:
          - arch: x86_64
            platform: rpi4
          - arch: x86_64
            platform: rpi5
          - arch: riscv64
            platform: rpi4
          - arch: riscv64
            platform: rpi5
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Build kernel
      run: ./build-all-architectures.sh
    
    - name: Create deployment package
      run: |
        mkdir -p deploy-${{ matrix.arch }}-${{ matrix.platform }}
        cp build-output/kernel-${{ matrix.arch }}-${{ matrix.platform }}.* deploy-${{ matrix.arch }}-${{ matrix.platform }}/
        cp deploy-*.sh deploy-${{ matrix.arch }}-${{ matrix.platform }}/
        tar -czf sage-os-${{ matrix.arch }}-${{ matrix.platform }}.tar.gz deploy-${{ matrix.arch }}-${{ matrix.platform }}
    
    - name: Upload to release
      uses: actions/upload-release-asset@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        upload_url: ${{ github.event.release.upload_url }}
        asset_path: ./sage-os-${{ matrix.arch }}-${{ matrix.platform }}.tar.gz
        asset_name: sage-os-${{ matrix.arch }}-${{ matrix.platform }}.tar.gz
        asset_content_type: application/gzip
```

## 🔍 Deployment Verification

### Post-Deployment Checklist
```bash
# 1. Boot verification
echo "✓ System boots successfully"
echo "✓ Kernel version displayed"
echo "✓ Memory detection correct"
echo "✓ Shell prompt appears"

# 2. Hardware verification
echo "✓ UART communication working"
echo "✓ GPIO accessible"
echo "✓ I2C bus functional"
echo "✓ SPI interface working"

# 3. Performance verification
echo "✓ Boot time < 15 seconds"
echo "✓ Memory usage < 16 MB"
echo "✓ CPU utilization normal"

# 4. Feature verification
echo "✓ AI subsystem (if enabled)"
echo "✓ Crypto functions (if enabled)"
echo "✓ Network stack (if enabled)"
```

### Monitoring and Logging
```bash
# Setup remote logging
echo "Setting up remote syslog..."
# Configure rsyslog to send logs to central server

# Setup monitoring
echo "Setting up monitoring..."
# Configure SNMP or custom monitoring agent

# Setup alerting
echo "Setting up alerting..."
# Configure alerts for system failures
```

This comprehensive deployment guide ensures SAGE OS can be successfully deployed across all supported platforms with proper configuration and verification procedures.