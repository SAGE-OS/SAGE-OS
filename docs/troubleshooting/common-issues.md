# SAGE OS Troubleshooting Guide

## 🔧 Common Issues and Solutions

This guide covers the most frequently encountered issues when building, running, and developing with SAGE OS.

## 🚀 Boot Issues

### Issue: GRUB Menu Not Appearing
**Symptoms:**
- Black screen after QEMU starts
- No GRUB menu displayed
- System appears to hang

**Diagnosis:**
```bash
# Check if ISO was created properly
ls -la build-output/x86_64/sageos.iso

# Verify GRUB configuration
cat test_iso/boot/grub/grub.cfg
```

**Solutions:**
1. **Rebuild ISO with proper GRUB config:**
   ```bash
   make clean
   make ARCH=x86_64 iso
   ```

2. **Check QEMU command:**
   ```bash
   # Correct QEMU command
   qemu-system-x86_64 -cdrom build-output/x86_64/sageos.iso -m 256M
   ```

3. **Verify multiboot header:**
   ```bash
   # Check multiboot header in kernel
   hexdump -C build-output/x86_64/kernel.elf | head -20
   # Should show multiboot magic: 0x1BADB002
   ```

### Issue: Kernel Panic on Boot
**Symptoms:**
- System boots but crashes immediately
- Error messages about invalid instructions
- CPU exception or triple fault

**Diagnosis:**
```bash
# Enable QEMU debugging
qemu-system-x86_64 -cdrom build-output/x86_64/sageos.iso -m 256M -d int,cpu_reset
```

**Solutions:**
1. **Check architecture compatibility:**
   ```bash
   # Verify kernel was built for correct architecture
   file build-output/x86_64/kernel.elf
   ```

2. **Debug with GDB:**
   ```bash
   # Start QEMU with GDB server
   qemu-system-x86_64 -cdrom build-output/x86_64/sageos.iso -s -S
   
   # In another terminal
   gdb build-output/x86_64/kernel.elf
   (gdb) target remote :1234
   (gdb) continue
   ```

3. **Check stack setup:**
   ```assembly
   # Verify stack pointer in boot.S
   mov $stack_top, %esp
   ```

### Issue: Multiboot Header Not Found
**Symptoms:**
- GRUB error: "Multiboot header not found"
- Kernel fails to load
- GRUB drops to rescue shell

**Diagnosis:**
```bash
# Check multiboot header location
objdump -h build-output/x86_64/kernel.elf | grep -A5 -B5 multiboot
```

**Solutions:**
1. **Use ELF wrapper approach:**
   ```bash
   # Rebuild with ELF wrapper
   make ARCH=x86_64 clean
   make ARCH=x86_64
   ```

2. **Verify linking order:**
   ```makefile
   # Ensure boot objects come first
   OBJECTS = $(BOOT_OBJ) $(KERNEL_OBJS) $(DRIVER_OBJS)
   ```

3. **Check multiboot header placement:**
   ```bash
   # Header should be within first 8KB
   python3 create_elf_wrapper.py kernel.img kernel.elf
   ```

## 🔨 Build Issues

### Issue: Cross-Compiler Not Found
**Symptoms:**
- `gcc-aarch64-linux-gnu: command not found`
- `gcc-riscv64-linux-gnu: command not found`
- Build fails for non-x86_64 architectures

**Solutions:**
1. **Install cross-compilation toolchains:**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu
   
   # Fedora/RHEL
   sudo dnf install gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu
   
   # macOS (using Homebrew)
   brew install aarch64-elf-gcc riscv64-elf-gcc
   ```

2. **Verify toolchain installation:**
   ```bash
   aarch64-linux-gnu-gcc --version
   riscv64-linux-gnu-gcc --version
   ```

3. **Use Docker build if toolchains unavailable:**
   ```bash
   ./docker-build.sh
   ```

### Issue: Linker Errors
**Symptoms:**
- Undefined reference errors
- Multiple definition errors
- Linking fails with symbol conflicts

**Diagnosis:**
```bash
# Check object files
nm build-output/x86_64/objects/*.o | grep -E "(U |T )"

# Verify linker script
cat linker.ld
```

**Solutions:**
1. **Check symbol definitions:**
   ```bash
   # Find undefined symbols
   nm -u build-output/x86_64/objects/*.o
   
   # Find multiple definitions
   nm build-output/x86_64/objects/*.o | sort | uniq -d
   ```

2. **Fix missing functions:**
   ```c
   // Add missing function implementations
   void missing_function(void) {
       // Implementation
   }
   ```

3. **Resolve symbol conflicts:**
   ```c
   // Use static for internal functions
   static void internal_function(void);
   
   // Or rename conflicting symbols
   void driver_init(void);  // Instead of init()
   ```

### Issue: Assembly Syntax Errors
**Symptoms:**
- Assembly compilation fails
- Syntax errors in boot.S
- Architecture-specific assembly issues

**Solutions:**
1. **Check architecture-specific sections:**
   ```assembly
   #ifdef __x86_64__
   // x86_64 specific code
   #elif defined(__aarch64__)
   // AArch64 specific code
   #elif defined(__riscv)
   // RISC-V specific code
   #endif
   ```

2. **Verify assembler syntax:**
   ```bash
   # Check which assembler is being used
   gcc -v -c boot/boot.S
   ```

3. **Fix syntax for target architecture:**
   ```assembly
   # x86_64 AT&T syntax
   movq %rax, %rbx
   
   # AArch64 syntax
   mov x0, x1
   
   # RISC-V syntax
   mv a0, a1
   ```

## 🐳 Docker Issues

### Issue: Docker Build Fails
**Symptoms:**
- Docker build process stops with errors
- Permission denied errors
- Package installation failures

**Solutions:**
1. **Update Docker and try again:**
   ```bash
   docker system prune -a
   ./docker-build.sh
   ```

2. **Check Docker daemon:**
   ```bash
   sudo systemctl status docker
   sudo systemctl start docker
   ```

3. **Build with verbose output:**
   ```bash
   docker build --no-cache --progress=plain -t sageos .
   ```

### Issue: Docker Permission Errors
**Symptoms:**
- Permission denied when accessing Docker
- Cannot connect to Docker daemon

**Solutions:**
1. **Add user to docker group:**
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

2. **Use sudo for Docker commands:**
   ```bash
   sudo docker build -t sageos .
   ```

3. **Check Docker socket permissions:**
   ```bash
   ls -la /var/run/docker.sock
   sudo chmod 666 /var/run/docker.sock
   ```

## 🧪 QEMU Issues

### Issue: QEMU Not Starting
**Symptoms:**
- QEMU command not found
- QEMU fails to start
- Graphics issues with QEMU

**Solutions:**
1. **Install QEMU:**
   ```bash
   # Ubuntu/Debian
   sudo apt install qemu-system-x86 qemu-system-arm qemu-system-misc
   
   # Fedora/RHEL
   sudo dnf install qemu-system-x86 qemu-system-aarch64 qemu-system-riscv
   
   # macOS
   brew install qemu
   ```

2. **Use correct QEMU binary:**
   ```bash
   # x86_64
   qemu-system-x86_64 -cdrom sageos.iso
   
   # AArch64
   qemu-system-aarch64 -M virt -cpu cortex-a57 -kernel kernel.elf
   
   # RISC-V
   qemu-system-riscv64 -M virt -kernel kernel.elf
   ```

3. **Run QEMU in headless mode:**
   ```bash
   qemu-system-x86_64 -cdrom sageos.iso -nographic -serial stdio
   ```

### Issue: QEMU Hangs or Freezes
**Symptoms:**
- QEMU window becomes unresponsive
- No output from kernel
- System appears to hang

**Solutions:**
1. **Enable debugging output:**
   ```bash
   qemu-system-x86_64 -cdrom sageos.iso -d int,cpu_reset -D qemu.log
   ```

2. **Check kernel output:**
   ```bash
   # Add debug prints to kernel
   printf("Kernel starting...\n");
   ```

3. **Use QEMU monitor:**
   ```bash
   # Press Ctrl+Alt+2 to access QEMU monitor
   # Type 'info registers' to see CPU state
   ```

## 🔧 Development Issues

### Issue: IDE/Editor Not Recognizing Code
**Symptoms:**
- Syntax highlighting not working
- IntelliSense/autocomplete not working
- Include paths not found

**Solutions:**
1. **Configure include paths:**
   ```json
   // VS Code c_cpp_properties.json
   {
       "configurations": [{
           "name": "SAGE OS",
           "includePath": [
               "${workspaceFolder}/kernel",
               "${workspaceFolder}/drivers",
               "${workspaceFolder}/sage-sdk/include"
           ],
           "defines": ["__SAGE_OS__"],
           "compilerPath": "/usr/bin/gcc"
       }]
   }
   ```

2. **Set up compile_commands.json:**
   ```bash
   # Generate compilation database
   bear -- make ARCH=x86_64
   ```

3. **Configure language server:**
   ```bash
   # Install clangd
   sudo apt install clangd
   
   # Or use ccls
   sudo apt install ccls
   ```

### Issue: Debugging Kernel Code
**Symptoms:**
- Cannot set breakpoints in kernel
- GDB not connecting properly
- Debug symbols not loaded

**Solutions:**
1. **Build with debug symbols:**
   ```bash
   make ARCH=x86_64 DEBUG=1
   ```

2. **Set up GDB properly:**
   ```bash
   # Start QEMU with GDB server
   qemu-system-x86_64 -cdrom sageos.iso -s -S
   
   # Connect GDB
   gdb build-output/x86_64/kernel.elf
   (gdb) target remote :1234
   (gdb) break kernel_main
   (gdb) continue
   ```

3. **Use QEMU built-in debugger:**
   ```bash
   # Press Ctrl+Alt+2 for QEMU monitor
   (qemu) info registers
   (qemu) x/10i $pc
   ```

## 📊 Performance Issues

### Issue: Slow Build Times
**Symptoms:**
- Builds take very long time
- CPU usage is low during build
- Incremental builds not working

**Solutions:**
1. **Enable parallel builds:**
   ```bash
   make -j$(nproc) ARCH=x86_64
   ```

2. **Use ccache for faster rebuilds:**
   ```bash
   sudo apt install ccache
   export CC="ccache gcc"
   make ARCH=x86_64
   ```

3. **Clean unnecessary files:**
   ```bash
   make clean
   # Or for deep clean
   git clean -fdx
   ```

### Issue: Large Binary Sizes
**Symptoms:**
- Kernel binary is unexpectedly large
- ISO image is too big
- Memory usage is high

**Solutions:**
1. **Enable optimization:**
   ```bash
   make ARCH=x86_64 RELEASE=1
   ```

2. **Strip debug symbols:**
   ```bash
   strip build-output/x86_64/kernel.elf
   ```

3. **Check for unused code:**
   ```bash
   # Use link-time optimization
   CFLAGS += -flto
   LDFLAGS += -flto
   ```

## 🔍 Diagnostic Commands

### System Information
```bash
# Check system architecture
uname -m

# Check available memory
free -h

# Check disk space
df -h

# Check CPU information
lscpu
```

### Build Diagnostics
```bash
# Check toolchain versions
gcc --version
make --version

# Check build dependencies
which qemu-system-x86_64
which grub-mkrescue

# Verify build output
ls -la build-output/
file build-output/x86_64/kernel.elf
```

### Runtime Diagnostics
```bash
# Check QEMU version
qemu-system-x86_64 --version

# Test QEMU functionality
qemu-system-x86_64 -version

# Check virtualization support
grep -E "(vmx|svm)" /proc/cpuinfo
```

## 📞 Getting Help

### Before Asking for Help
1. **Check this troubleshooting guide**
2. **Search existing GitHub issues**
3. **Try the suggested solutions**
4. **Gather diagnostic information**

### When Reporting Issues
Include the following information:
- **Operating system and version**
- **Build command used**
- **Complete error message**
- **Build output/logs**
- **Steps to reproduce**

### Support Channels
- **GitHub Issues**: [SAGE-OS Issues](https://github.com/NMC-TechClub/SAGE-OS/issues)
- **GitHub Discussions**: [SAGE-OS Discussions](https://github.com/NMC-TechClub/SAGE-OS/discussions)
- **Email**: ashishyesale007@gmail.com

### Useful Commands for Bug Reports
```bash
# Gather system information
uname -a > system-info.txt
gcc --version >> system-info.txt
make --version >> system-info.txt

# Capture build output
make ARCH=x86_64 2>&1 | tee build-log.txt

# Generate debug build
make ARCH=x86_64 DEBUG=1 2>&1 | tee debug-build.txt
```