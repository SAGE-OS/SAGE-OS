# SAGE OS UTM Setup Guide for macOS

**Author:** Ashish Vasant Yesale <ashishyesale007@gmail.com>  
**Date:** 2025-05-28  
**Target:** macOS UTM Virtualization  

## Overview

This guide provides detailed instructions for running SAGE OS images in UTM (Universal Turing Machine) on macOS, including optimal settings for different Mac architectures and SAGE OS image types.

---

## UTM Installation

### Install UTM on macOS

```bash
# Option 1: Mac App Store (Recommended)
# Search for "UTM Virtual Machines" in Mac App Store

# Option 2: Homebrew
brew install --cask utm

# Option 3: Direct Download
# Download from: https://mac.getutm.app/
```

---

## SAGE OS Image Compatibility Matrix

### For Intel Macs (x86_64)

| SAGE OS Image | UTM Architecture | Performance | Recommended |
|---------------|------------------|-------------|-------------|
| `SAGE-OS-0.1.0-x86_64-generic.img` | x86_64 | ⭐⭐⭐⭐⭐ Native | ✅ **Best Choice** |
| `SAGE-OS-0.1.0-i386-generic.img` | i386 | ⭐⭐⭐⭐ Native | ✅ Good |
| `SAGE-OS-0.1.0-aarch64-generic.img` | ARM64 | ⭐⭐ Emulated | ⚠️ Slow |
| `SAGE-OS-0.1.0-arm-generic.img` | ARM32 | ⭐⭐ Emulated | ⚠️ Slow |

### For Apple Silicon Macs (M1/M2/M3)

| SAGE OS Image | UTM Architecture | Performance | Recommended |
|---------------|------------------|-------------|-------------|
| `SAGE-OS-0.1.0-aarch64-generic.img` | ARM64 | ⭐⭐⭐⭐⭐ Native | ✅ **Best Choice** |
| `SAGE-OS-0.1.0-arm-generic.img` | ARM32 | ⭐⭐⭐⭐ Native | ✅ Good |
| `SAGE-OS-0.1.0-x86_64-generic.img` | x86_64 | ⭐⭐ Emulated | ⚠️ Slow |
| `SAGE-OS-0.1.0-i386-generic.img` | i386 | ⭐⭐ Emulated | ⚠️ Slow |

---

## UTM Configuration for SAGE OS

### 1. Intel Mac Setup (x86_64 SAGE OS)

#### Create New Virtual Machine
1. **Open UTM** → Click "Create a New Virtual Machine"
2. **Select "Emulate"** (for maximum compatibility)
3. **Operating System**: Select "Other"
4. **Architecture**: x86_64
5. **System**: Standard PC (Q35 + ICH9, 2009)

#### Hardware Configuration
```
CPU Cores: 2-4 cores (depending on your Mac)
Memory: 2048 MB (2GB) minimum, 4096 MB (4GB) recommended
Storage: 
  - Type: IDE
  - Interface: IDE
  - Size: 10GB (for development)
```

#### Boot Configuration
```
Boot Device: CD/DVD
Boot Image: SAGE-OS-0.1.0-x86_64-generic.iso (if available)
OR
Boot Device: Hard Disk
Boot Image: SAGE-OS-0.1.0-x86_64-generic.img
```

#### Advanced Settings
```
Machine: Standard PC (Q35 + ICH9, 2009)
CPU: Default (or Penryn for better compatibility)
Enable Hardware Acceleration: ✅ (if available)
```

### 2. Apple Silicon Mac Setup (ARM64 SAGE OS)

#### Create New Virtual Machine
1. **Open UTM** → Click "Create a New Virtual Machine"
2. **Select "Virtualize"** (for native ARM64 performance)
3. **Operating System**: Select "Other"
4. **Architecture**: ARM64 (aarch64)

#### Hardware Configuration
```
CPU Cores: 4-8 cores (Apple Silicon can handle more)
Memory: 4096 MB (4GB) minimum, 8192 MB (8GB) recommended
Storage:
  - Type: VirtIO
  - Interface: VirtIO
  - Size: 20GB (for development)
```

#### Boot Configuration
```
Boot Device: Hard Disk
Boot Image: SAGE-OS-0.1.0-aarch64-generic.img
UEFI Boot: ✅ Enabled
```

#### Advanced Settings
```
Machine: virt-7.2 (ARM64)
CPU: Default (Apple Silicon native)
Enable Hardware Acceleration: ✅ (Virtualization Framework)
```

---

## Detailed UTM Setup Steps

### Step 1: Download SAGE OS Images

```bash
# Navigate to SAGE OS build output
cd /path/to/SAGE-OS/build-output/

# Available images:
ls -la SAGE-OS-0.1.0-*.img

# For Intel Mac, use:
SAGE-OS-0.1.0-x86_64-generic.img

# For Apple Silicon Mac, use:
SAGE-OS-0.1.0-aarch64-generic.img
```

### Step 2: Create UTM Virtual Machine

#### For Intel Mac (x86_64):
1. **UTM Main Window** → "+" → "Create a New Virtual Machine"
2. **Virtualization Type**: "Emulate" 
3. **Operating System**: "Other"
4. **Hardware**:
   - Architecture: x86_64
   - System: Standard PC (Q35 + ICH9, 2009)
   - Memory: 2048 MB
   - CPU Cores: 2
5. **Storage**: 
   - Skip (we'll add SAGE OS image later)
6. **Shared Directory**: Skip
7. **Summary**: Review and "Save"

#### For Apple Silicon Mac (ARM64):
1. **UTM Main Window** → "+" → "Create a New Virtual Machine"
2. **Virtualization Type**: "Virtualize"
3. **Operating System**: "Other"
4. **Hardware**:
   - Memory: 4096 MB
   - CPU Cores: 4
5. **Storage**: 
   - Skip (we'll add SAGE OS image later)
6. **Shared Directory**: Skip
7. **Summary**: Review and "Save"

### Step 3: Configure SAGE OS Boot

#### Add SAGE OS Image as Boot Drive:
1. **Select VM** → Click "Edit" (pencil icon)
2. **Drives Tab** → "New Drive"
3. **Interface**: 
   - Intel Mac: IDE
   - Apple Silicon: VirtIO
4. **Image Type**: "Import"
5. **Browse**: Select your SAGE OS .img file
6. **Import**: Wait for import to complete

#### Configure Boot Order:
1. **QEMU Tab** → "Boot Device Order"
2. **Move your SAGE OS drive to top**
3. **Save Configuration**

### Step 4: Advanced UTM Settings

#### For Intel Mac (x86_64):
```
QEMU Settings:
- Machine: pc-q35-7.2
- CPU: Penryn (for compatibility)
- CPU Cores: 2-4
- Force Multicore: ✅
- Memory: 2048-4096 MB

Display Settings:
- Emulated Display Card: virtio-vga-gl
- Resolution: 1024x768

Network Settings:
- Network Mode: Emulated VLAN
- Emulated Network Card: virtio-net-pci

Input Settings:
- USB Support: ✅
- Tablet Mode: ✅
```

#### For Apple Silicon Mac (ARM64):
```
System Settings:
- Architecture: aarch64
- Machine: virt-7.2
- CPU: Default
- CPU Cores: 4-8
- Memory: 4096-8192 MB

Display Settings:
- Emulated Display Card: virtio-ramfb-gl
- Resolution: 1280x720

Network Settings:
- Network Mode: Shared Network
- Emulated Network Card: virtio-net-pci

Boot Settings:
- UEFI Boot: ✅
- Boot Device: Hard Disk
```

---

## SAGE OS Boot Process in UTM

### Expected Boot Sequence

#### 1. UEFI/BIOS Boot (Intel Mac)
```
SeaBIOS (version 1.16.0-1)
Booting from Hard Disk...
SAGE OS Bootloader v0.1.0
Loading kernel...
```

#### 2. UEFI Boot (Apple Silicon)
```
UEFI Interactive Shell v2.2
EDK II
Mapping table
BLK0: Alias(s):
PciRoot(0x0)/Pci(0x1,0x0)/Pci(0x0,0x0)
Shell> fs0:
FS0:\> SAGE-OS.efi
```

#### 3. SAGE OS Kernel Boot
```
SAGE OS v0.1.0 - Self-Aware General Evolution Operating System
Initializing kernel...
Memory: 2048 MB detected
CPU: x86_64/aarch64 detected
AI System Agent: Initializing...
Shell ready.
SAGE> 
```

---

## Performance Optimization

### Intel Mac Optimizations
```
UTM Settings:
- Enable Hardware Acceleration: ✅
- Use Host CPU: ✅ (if available)
- Memory: Allocate 25-50% of host RAM
- CPU Cores: Use 50-75% of host cores
- Display: Enable 3D acceleration
```

### Apple Silicon Optimizations
```
UTM Settings:
- Use Virtualization Framework: ✅
- Memory: Allocate 25-50% of host RAM
- CPU Cores: Use 50-75% of host cores
- Enable Rosetta: ❌ (not needed for ARM64)
- Display: Enable Metal acceleration
```

---

## Troubleshooting UTM Issues

### Common Problems and Solutions

#### 1. SAGE OS Won't Boot
```
Problem: Black screen or boot loop
Solution:
- Check boot device order in UTM
- Verify SAGE OS image integrity
- Try different machine type (Q35 vs i440fx)
- Enable/disable UEFI boot
```

#### 2. Poor Performance
```
Problem: Slow or laggy performance
Solution:
- Use native architecture (ARM64 on Apple Silicon)
- Increase allocated RAM and CPU cores
- Enable hardware acceleration
- Close other applications
```

#### 3. Display Issues
```
Problem: No display or corrupted graphics
Solution:
- Change display card type (virtio-vga vs cirrus)
- Adjust resolution settings
- Enable/disable 3D acceleration
- Try different color depth
```

#### 4. Network Not Working
```
Problem: No network connectivity
Solution:
- Check network mode (Shared vs Bridged)
- Verify network card type (virtio-net-pci)
- Restart UTM networking
- Check host firewall settings
```

---

## SAGE OS Development in UTM

### Development Workflow
1. **Build SAGE OS** on host macOS
2. **Copy image** to UTM VM directory
3. **Import image** into UTM
4. **Boot and test** SAGE OS
5. **Debug and iterate**

### File Sharing Between Host and VM
```bash
# Option 1: UTM Shared Folders
# Configure in UTM → Sharing → Shared Folders

# Option 2: Network File Transfer
# Use SCP/SFTP when SAGE OS networking is available

# Option 3: Image Mounting
# Mount SAGE OS image on host for direct file access
```

### Debugging SAGE OS in UTM
```bash
# Enable QEMU monitor in UTM
# UTM → Settings → QEMU → Arguments
-monitor stdio

# GDB debugging (when supported)
# UTM → Settings → QEMU → Arguments
-s -S

# Connect with GDB from host
gdb build-output/SAGE-OS-0.1.0-x86_64-generic.elf
(gdb) target remote localhost:1234
```

---

## UTM vs Other Virtualization

### UTM Advantages for SAGE OS
- **Native ARM64**: Best performance on Apple Silicon
- **QEMU Backend**: Full hardware emulation
- **Multiple Architectures**: Test all SAGE OS variants
- **macOS Integration**: Native macOS app
- **Free and Open Source**: No licensing costs

### Comparison with Alternatives

| Feature | UTM | Parallels | VMware Fusion | VirtualBox |
|---------|-----|-----------|---------------|------------|
| ARM64 Native | ✅ | ✅ | ❌ | ❌ |
| x86_64 Emulation | ✅ | ✅ | ✅ | ✅ |
| Custom OS Support | ✅ | ⚠️ | ⚠️ | ✅ |
| Free | ✅ | ❌ | ❌ | ✅ |
| SAGE OS Compatible | ✅ | ⚠️ | ⚠️ | ✅ |

---

## Recommended UTM Configurations

### Development Configuration (Intel Mac)
```
VM Name: SAGE-OS-Dev-x86_64
Architecture: x86_64
Machine: pc-q35-7.2
CPU: 4 cores
Memory: 4096 MB
Storage: 20GB VirtIO
Network: Shared Network
Display: virtio-vga-gl
Boot: SAGE-OS-0.1.0-x86_64-generic.img
```

### Development Configuration (Apple Silicon)
```
VM Name: SAGE-OS-Dev-ARM64
Architecture: aarch64
Machine: virt-7.2
CPU: 6 cores
Memory: 6144 MB
Storage: 30GB VirtIO
Network: Shared Network
Display: virtio-ramfb-gl
Boot: SAGE-OS-0.1.0-aarch64-generic.img
```

### Testing Configuration (Minimal)
```
VM Name: SAGE-OS-Test
CPU: 2 cores
Memory: 1024 MB
Storage: 5GB
Network: None
Display: Basic VGA
Boot: SAGE-OS kernel image
```

---

## Conclusion

UTM provides excellent support for running SAGE OS on macOS, with optimal performance when using native architectures:

- **Intel Macs**: Use x86_64 SAGE OS images for best performance
- **Apple Silicon Macs**: Use aarch64 SAGE OS images for native speed
- **Cross-Architecture Testing**: UTM can emulate other architectures for compatibility testing

For the best SAGE OS development experience on macOS, UTM is the recommended virtualization solution due to its native ARM64 support, comprehensive hardware emulation, and seamless macOS integration.

---

**Setup Time:** ~10 minutes  
**Recommended for:** Development, Testing, Demonstration  
**Performance:** Native architecture = Excellent, Emulated = Good  
**Support:** Full SAGE OS feature compatibility