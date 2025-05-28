# SAGE OS v1.0.0 - Complete User Guide

**Author:** Ashish Vasant Yesale  
**Email:** ashishyesale007@gmail.com  
**Date:** May 28, 2025  
**Version:** 1.0.0  

## Table of Contents

1. [Introduction](#introduction)
2. [System Requirements](#system-requirements)
3. [Installation](#installation)
4. [First Boot](#first-boot)
5. [Shell Commands](#shell-commands)
6. [File Operations](#file-operations)
7. [System Features](#system-features)
8. [Troubleshooting](#troubleshooting)
9. [Advanced Usage](#advanced-usage)

---

## Introduction

SAGE OS (Self-Aware General Environment) is a modern operating system designed with AI integration and multi-architecture support. This guide covers everything you need to know to use SAGE OS effectively.

### Key Features
- **Multi-Architecture Support**: i386, x86_64, aarch64, riscv64
- **Interactive Shell**: Unix-like command interface
- **File System Operations**: Create, edit, and manage files
- **AI Integration**: Built-in AI subsystem
- **Beautiful Interface**: ASCII art welcome screen
- **Graceful Shutdown**: Proper system termination

---

## System Requirements

### Minimum Requirements
- **RAM**: 1GB (2GB recommended)
- **Storage**: 5GB free space
- **CPU**: Any supported architecture
- **Virtualization**: QEMU, UTM, VirtualBox, or VMware

### Supported Architectures
- **i386**: 32-bit x86 processors
- **x86_64**: 64-bit x86 processors
- **aarch64**: 64-bit ARM processors
- **riscv64**: 64-bit RISC-V processors

### Host Operating Systems
- **Linux**: All distributions with QEMU
- **macOS**: UTM, Parallels, VMware Fusion
- **Windows**: VirtualBox, VMware Workstation, WSL2

---

## Installation

### Download SAGE OS Images

SAGE OS is distributed as pre-built images:

```bash
# Available images (replace date with current version)
sage-os-i386-v1.0.0-20250528.iso      # 32-bit x86 bootable ISO
sage-os-x86_64-v1.0.0-20250528.iso    # 64-bit x86 bootable ISO
sage-os-aarch64-v1.0.0-20250528.img   # 64-bit ARM kernel image
sage-os-riscv64-v1.0.0-20250528.img   # 64-bit RISC-V kernel image
```

### Quick Start with QEMU

#### Intel/AMD Systems (x86_64)
```bash
# Boot from ISO
qemu-system-x86_64 -M pc -cdrom sage-os-x86_64-v1.0.0-20250528.iso -m 2048

# Boot from kernel image
qemu-system-x86_64 -M pc -kernel sage-os-x86_64-v1.0.0-20250528.img -m 2048
```

#### ARM64 Systems
```bash
qemu-system-aarch64 -M virt -cpu cortex-a57 \
  -kernel sage-os-aarch64-v1.0.0-20250528.img -m 2048 -nographic
```

#### RISC-V Systems
```bash
qemu-system-riscv64 -M virt \
  -kernel sage-os-riscv64-v1.0.0-20250528.img -m 2048 -nographic
```

---

## First Boot

### Boot Sequence

When SAGE OS starts, you'll see:

1. **Bootloader** (for ISO images)
2. **ASCII Art Welcome Screen**
3. **System Initialization**
4. **Shell Prompt**

### Welcome Screen
```
  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗
  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝
  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗
  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║
  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║
  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝

Welcome to SAGE OS - Self-Aware General Environment
Designed by Ashish Yesale

Starting shell in 3 seconds...
```

### Initial Shell
After the welcome screen, you'll see the shell prompt:
```
sage@localhost:~$ 
```

---

## Shell Commands

SAGE OS includes a comprehensive set of Unix-like commands:

### Basic Commands

#### `help` - Show Available Commands
```bash
sage@localhost:~$ help
Available commands:
  help     - Show this help message
  version  - Show SAGE OS version
  ls       - List files and directories
  pwd      - Show current directory
  mkdir    - Create a directory
  touch    - Create a file
  cat      - Display file contents
  nano     - Edit a file
  clear    - Clear the screen
  exit     - Shutdown SAGE OS
```

#### `version` - System Information
```bash
sage@localhost:~$ version
SAGE OS v1.0.0 - Self-Aware General Environment
Architecture: x86_64
Build Date: 2025-05-28
Designed by: Ashish Yesale
```

#### `pwd` - Current Directory
```bash
sage@localhost:~$ pwd
Current directory: /home/sage
```

#### `clear` - Clear Screen
```bash
sage@localhost:~$ clear
# Clears the terminal screen
```

### File System Commands

#### `ls` - List Files
```bash
sage@localhost:~$ ls
Files and directories:
  welcome.txt
  documents/
  projects/
```

#### `mkdir` - Create Directory
```bash
sage@localhost:~$ mkdir my_project
Directory 'my_project' created successfully.

sage@localhost:~$ ls
Files and directories:
  welcome.txt
  documents/
  projects/
  my_project/
```

#### `touch` - Create File
```bash
sage@localhost:~$ touch hello.txt
File 'hello.txt' created successfully.

sage@localhost:~$ ls
Files and directories:
  welcome.txt
  documents/
  projects/
  my_project/
  hello.txt
```

#### `cat` - Display File Contents
```bash
sage@localhost:~$ cat welcome.txt
Welcome to SAGE OS - Your AI-powered future!

This file contains important information about your system.
SAGE OS is designed to be intuitive and powerful.

Enjoy exploring your new operating system!
```

#### `nano` - Text Editor
```bash
sage@localhost:~$ nano hello.txt
GNU nano 6.2    hello.txt

Hello, SAGE OS!
This is my first file.
I'm learning to use the system.

^X Exit  ^O Write Out  ^R Read File  ^Y Prev Page
File saved successfully.
```

### System Commands

#### `meminfo` - Memory Information
```bash
sage@localhost:~$ meminfo
Memory Information:
Total Memory: 2048 MB
Used Memory: 256 MB
Free Memory: 1792 MB
```

#### `uptime` - System Uptime
```bash
sage@localhost:~$ uptime
System uptime: 5 minutes, 23 seconds
```

#### `whoami` - Current User
```bash
sage@localhost:~$ whoami
Current user: sage
```

#### `reboot` - Restart System
```bash
sage@localhost:~$ reboot
Rebooting SAGE OS...
System restart initiated.
```

#### `exit` - Shutdown System
```bash
sage@localhost:~$ exit
Shutting down SAGE OS...
Thank you for using SAGE OS!
System halted.
```

---

## File Operations

### Creating and Managing Files

SAGE OS provides a simulated file system for demonstration purposes:

#### Create a Project Structure
```bash
sage@localhost:~$ mkdir projects
Directory 'projects' created successfully.

sage@localhost:~$ mkdir projects/my_app
Directory 'projects/my_app' created successfully.

sage@localhost:~$ touch projects/my_app/main.c
File 'projects/my_app/main.c' created successfully.

sage@localhost:~$ touch projects/my_app/README.md
File 'projects/my_app/README.md' created successfully.
```

#### Edit Files with Nano
```bash
sage@localhost:~$ nano projects/my_app/main.c
GNU nano 6.2    projects/my_app/main.c

#include <stdio.h>

int main() {
    printf("Hello from SAGE OS!\n");
    return 0;
}

^X Exit  ^O Write Out  ^R Read File  ^Y Prev Page
File saved successfully.
```

#### View File Contents
```bash
sage@localhost:~$ cat projects/my_app/main.c
#include <stdio.h>

int main() {
    printf("Hello from SAGE OS!\n");
    return 0;
}
```

---

## System Features

### AI Integration

SAGE OS includes a built-in AI subsystem that provides:
- **Intelligent Command Suggestions**
- **System Optimization**
- **Predictive File Management**
- **Adaptive User Interface**

### Multi-Architecture Support

SAGE OS runs natively on multiple processor architectures:
- **x86**: Traditional PC compatibility
- **ARM**: Mobile and embedded systems
- **RISC-V**: Open-source processor architecture

### Security Features

- **Memory Protection**: Kernel-level memory management
- **Process Isolation**: Secure process execution
- **Safe Shutdown**: Graceful system termination

---

## Troubleshooting

### Common Issues

#### System Won't Boot
```
Problem: Black screen or boot failure
Solutions:
1. Check virtualization settings
2. Verify image file integrity
3. Increase allocated memory
4. Try different machine type
```

#### Commands Not Working
```
Problem: Shell commands don't respond
Solutions:
1. Type 'help' to see available commands
2. Check command syntax
3. Restart the system with 'reboot'
```

#### Performance Issues
```
Problem: System runs slowly
Solutions:
1. Increase allocated RAM
2. Use native architecture images
3. Enable hardware acceleration
4. Close other applications
```

### Getting Help

#### Built-in Help
```bash
sage@localhost:~$ help
# Shows all available commands

sage@localhost:~$ version
# Shows system information
```

#### System Information
```bash
sage@localhost:~$ meminfo
# Memory usage information

sage@localhost:~$ uptime
# System runtime information
```

---

## Advanced Usage

### Development Environment

SAGE OS can be used as a development platform:

#### Create Development Structure
```bash
sage@localhost:~$ mkdir development
sage@localhost:~$ mkdir development/src
sage@localhost:~$ mkdir development/docs
sage@localhost:~$ mkdir development/tests
```

#### Write Code
```bash
sage@localhost:~$ nano development/src/hello.c
# Write your C code

sage@localhost:~$ nano development/docs/README.md
# Document your project

sage@localhost:~$ nano development/tests/test.sh
# Create test scripts
```

### System Administration

#### Monitor System Resources
```bash
sage@localhost:~$ meminfo
sage@localhost:~$ uptime
sage@localhost:~$ whoami
```

#### Manage Files and Directories
```bash
sage@localhost:~$ ls
sage@localhost:~$ mkdir system_configs
sage@localhost:~$ touch system_configs/config.txt
sage@localhost:~$ cat system_configs/config.txt
```

### Graceful Shutdown

Always use the `exit` command to properly shutdown SAGE OS:

```bash
sage@localhost:~$ exit
Shutting down SAGE OS...
Thank you for using SAGE OS!
System halted.
```

This ensures:
- **Data Integrity**: All operations are completed
- **Clean Termination**: System resources are properly released
- **Safe Exit**: Virtual machine terminates correctly

---

## Conclusion

SAGE OS provides a modern, AI-integrated operating system experience with:
- **Intuitive Interface**: Easy-to-use shell commands
- **Multi-Architecture Support**: Runs on various processors
- **Development Ready**: Built-in tools for programming
- **Reliable Operation**: Stable and predictable behavior

For more information, visit the SAGE OS documentation or contact the development team.

---

**SAGE OS v1.0.0**  
*Self-Aware General Environment*  
*Designed by Ashish Yesale*  
*May 28, 2025*