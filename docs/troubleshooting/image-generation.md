# Image Generation Troubleshooting Guide

This guide helps resolve issues with generating bootable images (.iso, .img) for SAGE OS across different architectures.

## Table of Contents

- [Common Image Generation Issues](#common-image-generation-issues)
- [Architecture-Specific Problems](#architecture-specific-problems)
- [Image Format Issues](#image-format-issues)
- [Tools and Dependencies](#tools-and-dependencies)
- [Step-by-Step Debugging](#step-by-step-debugging)
- [Recovery and Workarounds](#recovery-and-workarounds)

## Common Image Generation Issues

### 1. ISO Generation Fails

**Symptoms:**
- `make iso` command fails
- Missing or corrupted ISO file
- "No space left on device" errors

**Common Causes:**
- Missing dependencies (genisoimage, xorriso)
- Insufficient disk space
- Corrupted build artifacts
- Invalid file permissions

**Solutions:**

```bash
# Install required tools
sudo apt-get install genisoimage xorriso mtools

# Check disk space
df -h .

# Clean and rebuild
make clean
make ARCH=x86_64
make iso ARCH=x86_64

# Verify ISO structure
isoinfo -l -i build/sage-os.iso
```

### 2. IMG File Generation Issues

**Symptoms:**
- Raw disk image creation fails
- Image file is too small or too large
- Cannot mount generated image

**Solutions:**

```bash
# Check image size calculation
ls -la build/*.img

# Verify image structure
file build/sage-os.img

# Test mounting (Linux)
sudo mount -o loop build/sage-os.img /mnt/test

# Check filesystem
fsck.fat build/sage-os.img
```

### 3. Bootloader Integration Problems

**Symptoms:**
- Image generates but won't boot
- "No operating system found" error
- Bootloader not properly embedded

**Solutions:**

```bash
# Verify bootloader is built
ls -la build/boot/

# Check boot sector
hexdump -C build/boot/stage1.bin | head -10

# Manually install bootloader
dd if=build/boot/stage1.bin of=build/sage-os.img bs=512 count=1 conv=notrunc

# Verify boot signature
tail -c 2 build/sage-os.img | hexdump -C  # Should show 55 aa
```

## Architecture-Specific Problems

### x86_64 Image Issues

#### UEFI Boot Problems

```bash
# Create UEFI-compatible image
make uefi-image ARCH=x86_64

# Check EFI system partition
mkdir -p /tmp/efi
sudo mount -o loop,offset=1048576 build/sage-os.img /tmp/efi
ls -la /tmp/efi/EFI/BOOT/
```

#### Legacy BIOS Issues

```bash
# Ensure MBR is properly written
dd if=build/boot/mbr.bin of=build/sage-os.img bs=446 count=1 conv=notrunc

# Check partition table
fdisk -l build/sage-os.img
```

### ARM64/AArch64 Image Issues

#### Device Tree Integration

```bash
# Verify device tree compilation
dtc -I dts -O dtb -o build/sage-os.dtb config/arm64/sage-os.dts

# Check device tree in image
binwalk build/sage-os.img | grep -i "device tree"
```

#### U-Boot Integration

```bash
# Create U-Boot compatible image
mkimage -A arm64 -O linux -T kernel -C none -a 0x80000 -e 0x80000 \
  -n "SAGE OS" -d build/kernel/kernel.bin build/uImage

# Verify U-Boot header
file build/uImage
```

### RISC-V Image Issues

#### OpenSBI Integration

```bash
# Build with OpenSBI
make ARCH=riscv64 OPENSBI=1

# Check OpenSBI payload
riscv64-linux-gnu-objdump -h build/opensbi/fw_payload.elf
```

#### Device Tree Setup

```bash
# Compile RISC-V device tree
dtc -I dts -O dtb -o build/riscv64.dtb config/riscv64/sage-os.dts

# Verify memory layout
grep -A 5 "memory@" config/riscv64/sage-os.dts
```

## Image Format Issues

### 1. ISO Format Problems

**El Torito Boot Issues:**

```bash
# Check El Torito boot record
isoinfo -d -i build/sage-os.iso | grep -i "el torito"

# Verify boot catalog
isoinfo -R -f -i build/sage-os.iso | grep -i boot

# Rebuild with proper El Torito
genisoimage -b boot/stage1.bin -no-emul-boot -boot-load-size 4 \
  -boot-info-table -o build/sage-os.iso build/iso/
```

**Hybrid ISO Issues:**

```bash
# Create hybrid ISO (bootable from USB)
isohybrid build/sage-os.iso

# Verify hybrid structure
file build/sage-os.iso
```

### 2. Raw Image Format Issues

**Partition Table Problems:**

```bash
# Create proper partition table
parted build/sage-os.img mklabel msdos
parted build/sage-os.img mkpart primary fat32 1MiB 100%
parted build/sage-os.img set 1 boot on

# Verify partition table
parted build/sage-os.img print
```

**Filesystem Issues:**

```bash
# Format partition
mkfs.fat -F32 -n "SAGE-OS" build/sage-os.img

# Check filesystem
fsck.fat -v build/sage-os.img
```

### 3. QEMU Image Format

**QCOW2 Conversion:**

```bash
# Convert raw image to QCOW2
qemu-img convert -f raw -O qcow2 build/sage-os.img build/sage-os.qcow2

# Verify QCOW2 image
qemu-img info build/sage-os.qcow2

# Test QCOW2 boot
qemu-system-x86_64 -m 512M -drive file=build/sage-os.qcow2,format=qcow2
```

## Tools and Dependencies

### Required Tools Installation

#### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y \
  genisoimage \
  xorriso \
  mtools \
  syslinux \
  syslinux-utils \
  parted \
  dosfstools \
  qemu-utils \
  device-tree-compiler
```

#### Fedora/RHEL:
```bash
sudo dnf install -y \
  genisoimage \
  xorriso \
  mtools \
  syslinux \
  parted \
  dosfstools \
  qemu-img \
  dtc
```

#### macOS:
```bash
brew install cdrtools xorriso mtools qemu dtc
```

### Tool Verification

```bash
# Check tool versions
genisoimage --version
xorriso -version
mtools --version
qemu-img --version

# Verify tool functionality
echo "test" | genisoimage -o test.iso -
rm test.iso
```

## Step-by-Step Debugging

### Phase 1: Environment Check

1. **Verify Dependencies**
   ```bash
   ./scripts/check-dependencies.sh
   ```

2. **Check Disk Space**
   ```bash
   df -h .
   # Ensure at least 1GB free space
   ```

3. **Verify Permissions**
   ```bash
   ls -la build/
   # Ensure write permissions
   ```

### Phase 2: Build Verification

1. **Clean Build**
   ```bash
   make clean
   make ARCH=x86_64 VERBOSE=1
   ```

2. **Check Build Artifacts**
   ```bash
   ls -la build/boot/
   ls -la build/kernel/
   file build/boot/stage1.bin
   file build/kernel/kernel.bin
   ```

3. **Verify Sizes**
   ```bash
   # Boot sector should be exactly 512 bytes
   stat -c%s build/boot/stage1.bin
   
   # Kernel should be reasonable size (< 10MB typically)
   stat -c%s build/kernel/kernel.bin
   ```

### Phase 3: Image Generation Debug

1. **Manual ISO Creation**
   ```bash
   mkdir -p build/iso/boot
   cp build/boot/stage1.bin build/iso/boot/
   cp build/kernel/kernel.bin build/iso/boot/
   
   genisoimage -b boot/stage1.bin -no-emul-boot \
     -boot-load-size 4 -boot-info-table \
     -o build/sage-os.iso build/iso/
   ```

2. **Manual IMG Creation**
   ```bash
   # Create 100MB image
   dd if=/dev/zero of=build/sage-os.img bs=1M count=100
   
   # Create partition table
   parted build/sage-os.img mklabel msdos
   parted build/sage-os.img mkpart primary fat32 1MiB 100%
   parted build/sage-os.img set 1 boot on
   
   # Format filesystem
   mkfs.fat -F32 build/sage-os.img
   ```

3. **Install Bootloader**
   ```bash
   # Install boot sector
   dd if=build/boot/stage1.bin of=build/sage-os.img \
     bs=512 count=1 conv=notrunc
   
   # Copy kernel
   mcopy -i build/sage-os.img build/kernel/kernel.bin ::kernel.bin
   ```

### Phase 4: Testing

1. **Test in QEMU**
   ```bash
   # Test ISO
   qemu-system-x86_64 -m 512M -cdrom build/sage-os.iso -boot d
   
   # Test IMG
   qemu-system-x86_64 -m 512M -drive file=build/sage-os.img,format=raw
   ```

2. **Verify Boot Process**
   ```bash
   # Enable serial output for debugging
   qemu-system-x86_64 -m 512M -cdrom build/sage-os.iso \
     -serial stdio -nographic
   ```

## Recovery and Workarounds

### 1. Dependency Issues

**Missing genisoimage:**
```bash
# Use xorriso as alternative
xorriso -as mkisofs -b boot/stage1.bin -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -o build/sage-os.iso build/iso/
```

**Missing mtools:**
```bash
# Manual file copying using loop mount
sudo mkdir -p /mnt/sage
sudo mount -o loop build/sage-os.img /mnt/sage
sudo cp build/kernel/kernel.bin /mnt/sage/
sudo umount /mnt/sage
```

### 2. Size Issues

**Image Too Large:**
```bash
# Compress kernel
gzip -9 build/kernel/kernel.bin
mv build/kernel/kernel.bin.gz build/kernel/kernel.bin

# Use smaller image size
dd if=/dev/zero of=build/sage-os.img bs=1M count=50
```

**Image Too Small:**
```bash
# Calculate required size
KERNEL_SIZE=$(stat -c%s build/kernel/kernel.bin)
BOOT_SIZE=$(stat -c%s build/boot/stage1.bin)
TOTAL_SIZE=$((KERNEL_SIZE + BOOT_SIZE + 1048576))  # Add 1MB padding

# Create appropriately sized image
dd if=/dev/zero of=build/sage-os.img bs=1 count=$TOTAL_SIZE
```

### 3. Boot Issues

**Boot Signature Missing:**
```bash
# Add boot signature manually
printf '\x55\xAA' | dd of=build/sage-os.img bs=1 seek=510 count=2 conv=notrunc
```

**Partition Table Corruption:**
```bash
# Recreate partition table
dd if=/dev/zero of=build/sage-os.img bs=512 count=1
parted build/sage-os.img mklabel msdos
parted build/sage-os.img mkpart primary fat32 1MiB 100%
parted build/sage-os.img set 1 boot on
```

## Advanced Techniques

### 1. Custom Image Scripts

```bash
#!/bin/bash
# scripts/create-image.sh

set -e

ARCH=${1:-x86_64}
IMAGE_SIZE=${2:-100M}
IMAGE_NAME="build/sage-os-${ARCH}.img"

echo "Creating ${IMAGE_SIZE} image for ${ARCH}..."

# Create image
dd if=/dev/zero of="${IMAGE_NAME}" bs=1 count=0 seek="${IMAGE_SIZE}"

# Setup partitions
parted "${IMAGE_NAME}" mklabel msdos
parted "${IMAGE_NAME}" mkpart primary fat32 1MiB 100%
parted "${IMAGE_NAME}" set 1 boot on

# Format filesystem
mkfs.fat -F32 -n "SAGE-OS" "${IMAGE_NAME}"

# Install bootloader
dd if="build/boot/stage1.bin" of="${IMAGE_NAME}" \
  bs=512 count=1 conv=notrunc

# Copy kernel
mcopy -i "${IMAGE_NAME}" "build/kernel/kernel.bin" ::kernel.bin

echo "Image created: ${IMAGE_NAME}"
```

### 2. Multi-Architecture Images

```bash
# Create combined image with multiple architectures
mkdir -p build/multi-arch/{x86_64,aarch64,riscv64}

for arch in x86_64 aarch64 riscv64; do
  make clean
  make ARCH=$arch
  cp build/kernel/kernel.bin build/multi-arch/$arch/
done

# Create ISO with all architectures
genisoimage -b boot/stage1.bin -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -o build/sage-os-multi.iso build/multi-arch/
```

### 3. Automated Testing

```bash
#!/bin/bash
# scripts/test-images.sh

for format in iso img; do
  echo "Testing $format image..."
  
  timeout 30 qemu-system-x86_64 -m 512M \
    -drive file=build/sage-os.$format,format=raw \
    -nographic -serial stdio || echo "$format test failed"
done
```

## Common Error Messages and Solutions

### "No space left on device"
- **Solution**: Clean build directory, check disk space
- **Command**: `df -h . && make clean`

### "Permission denied"
- **Solution**: Check file permissions, run with appropriate privileges
- **Command**: `chmod +x scripts/* && ls -la build/`

### "Command not found: genisoimage"
- **Solution**: Install missing dependencies
- **Command**: `sudo apt-get install genisoimage`

### "Invalid partition table"
- **Solution**: Recreate partition table
- **Command**: `parted build/sage-os.img mklabel msdos`

### "Boot signature not found"
- **Solution**: Add boot signature
- **Command**: `printf '\x55\xAA' | dd of=build/sage-os.img bs=1 seek=510 count=2 conv=notrunc`

## Prevention Best Practices

1. **Regular Testing**: Test image generation on clean builds
2. **Dependency Checks**: Verify all tools are installed and working
3. **Size Monitoring**: Monitor image sizes and adjust as needed
4. **Automated Builds**: Use CI/CD to catch issues early
5. **Documentation**: Keep build logs and document any manual steps

## Getting Help

If you continue to experience issues:

1. **Check Build Logs**: Review verbose build output
2. **Test Environment**: Try on different systems/containers
3. **Community Support**: Ask on forums or chat channels
4. **Bug Reports**: Submit detailed issue reports with logs

## Related Documentation

- [Boot Issues Guide](boot-issues.md)
- [Build System Documentation](../build/README.md)
- [Testing Guide](../testing/README.md)
- [Architecture Guides](../architecture/)