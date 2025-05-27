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


# Frequently Asked Questions (FAQ)

This document answers common questions about SAGE OS installation, usage, and development.

## 🚀 General Questions

### What is SAGE OS?

SAGE OS is a modern, secure operating system designed with multi-architecture support. It's built with Rust for memory safety and supports x86_64, ARM64, and RISC-V architectures.

### What makes SAGE OS different from other operating systems?

- **Security First**: Built with memory-safe Rust
- **Multi-Architecture**: Native support for x86_64, ARM64, and RISC-V
- **Modern Design**: Clean, modular architecture
- **CVE Scanning**: Automated vulnerability detection
- **Performance**: Optimized for modern hardware

### Is SAGE OS ready for production use?

SAGE OS is currently in active development. While it's functional for testing and development, we recommend thorough testing before production deployment.

## 🛠️ Installation and Setup

### Q: What are the minimum system requirements?

**A:** Minimum requirements:
- **RAM**: 2 GB (8 GB recommended)
- **Storage**: 10 GB (50 GB recommended)
- **CPU**: x86_64, ARM64, or RISC-V processor
- **Graphics**: VGA compatible display

### Q: Which architectures are supported?

**A:** SAGE OS supports:
- **x86_64**: Intel/AMD 64-bit processors ✅ Stable
- **ARM64**: ARM 64-bit processors (AArch64) ✅ Stable  
- **RISC-V**: RISC-V 64-bit processors 🚧 Beta

### Q: Can I install SAGE OS alongside another operating system?

**A:** Yes, SAGE OS supports dual-boot configurations. However, ensure you have proper backups before installation.

### Q: How do I create a bootable USB drive?

**A:** Use the following command (replace `/dev/sdX` with your USB device):
```bash
sudo dd if=dist/sage-os-x86_64.iso of=/dev/sdX bs=4M status=progress
```

### Q: The system won't boot from USB. What should I do?

**A:** Try these solutions:
1. Disable Secure Boot in BIOS/UEFI
2. Enable Legacy Boot mode
3. Check boot order in BIOS
4. Try a different USB port
5. Recreate the bootable USB drive

## 🏗️ Building and Development

### Q: How do I build SAGE OS from source?

**A:** Follow these steps:
```bash
# Clone repository
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS

# Install dependencies
./scripts/setup-dev.sh

# Build for x86_64
make build ARCH=x86_64

# Create ISO
make iso ARCH=x86_64
```

### Q: Build fails with "command not found" errors. What's wrong?

**A:** This usually means missing dependencies. Run:
```bash
# Check dependencies
./scripts/check-dependencies.sh

# Install missing dependencies
sudo apt install build-essential nasm grub-pc-bin xorriso mtools
```

### Q: How do I cross-compile for different architectures?

**A:** SAGE OS supports cross-compilation:
```bash
# Install cross-compilation tools
./scripts/setup-cross-compile.sh

# Build for ARM64
make build ARCH=aarch64

# Build for RISC-V
make build ARCH=riscv64
```

### Q: Can I contribute to SAGE OS development?

**A:** Absolutely! We welcome contributions:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request
5. See our [Contributing Guide](../development/contributing.md)

## 🖥️ Virtual Machine Issues

### Q: SAGE OS runs slowly in VirtualBox. How can I improve performance?

**A:** Try these optimizations:
1. Enable hardware acceleration (VT-x/AMD-V)
2. Increase allocated RAM to 4GB+
3. Enable 3D acceleration
4. Use VirtIO drivers
5. Allocate more CPU cores

### Q: QEMU shows a black screen. What's wrong?

**A:** Common solutions:
```bash
# Try different graphics options
qemu-system-x86_64 -cdrom sage-os.iso -m 2G -vga std

# Or use VNC display
qemu-system-x86_64 -cdrom sage-os.iso -m 2G -vnc :1
```

### Q: How do I enable KVM acceleration?

**A:** Ensure KVM is available and enabled:
```bash
# Check KVM support
lscpu | grep Virtualization

# Load KVM modules
sudo modprobe kvm
sudo modprobe kvm_intel  # or kvm_amd

# Run with KVM
qemu-system-x86_64 -enable-kvm -cdrom sage-os.iso -m 2G
```

## 🔒 Security Questions

### Q: How secure is SAGE OS?

**A:** SAGE OS implements multiple security layers:
- Memory-safe Rust implementation
- Automated CVE scanning
- Secure boot support
- Address Space Layout Randomization (ASLR)
- Data Execution Prevention (DEP)

### Q: Does SAGE OS support Secure Boot?

**A:** Yes, SAGE OS supports UEFI Secure Boot. However, you may need to disable it during development or add custom keys.

### Q: How are vulnerabilities handled?

**A:** We use automated CVE scanning and have a structured vulnerability management process:
1. Automated detection with CVE Binary Tool
2. Risk assessment and prioritization
3. Rapid patching for critical issues
4. Regular security updates

### Q: Can I audit the security of SAGE OS?

**A:** Yes! SAGE OS is open source, and we encourage security audits:
- Source code is available on GitHub
- Security documentation is comprehensive
- We welcome security researchers
- Responsible disclosure process in place

## 🐛 Common Errors and Solutions

### Q: "No bootable device found" error

**A:** This indicates boot configuration issues:
1. Check BIOS boot order
2. Ensure USB/CD is bootable
3. Try different boot modes (UEFI/Legacy)
4. Recreate installation media

### Q: Kernel panic during boot

**A:** Kernel panics can have various causes:
1. Check hardware compatibility
2. Try safe mode boot parameters
3. Verify installation media integrity
4. Check system logs for details

### Q: "Permission denied" when building

**A:** This is usually a file permissions issue:
```bash
# Fix permissions
chmod +x scripts/*.sh

# Or run with sudo if needed
sudo make build
```

### Q: Out of memory errors during compilation

**A:** Large builds require significant RAM:
1. Increase swap space
2. Use parallel build with fewer jobs: `make -j2`
3. Close other applications
4. Consider using a machine with more RAM

## 🌐 Network and Hardware

### Q: Network interface not detected

**A:** Try these solutions:
1. Check hardware compatibility list
2. Load appropriate drivers manually
3. Use USB-to-Ethernet adapter
4. Check BIOS network settings

### Q: Graphics not working properly

**A:** Graphics issues can be resolved by:
1. Using VESA/VGA fallback mode
2. Updating graphics drivers
3. Checking hardware compatibility
4. Using software rendering

### Q: USB devices not recognized

**A:** USB support troubleshooting:
1. Check USB controller compatibility
2. Try different USB ports
3. Use USB 2.0 instead of 3.0
4. Check power management settings

## 📦 Package Management

### Q: How do I install additional software?

**A:** SAGE OS includes a package manager:
```bash
# Update package database
sage-pkg update

# Search for packages
sage-pkg search <package-name>

# Install packages
sage-pkg install <package-name>

# Remove packages
sage-pkg remove <package-name>
```

### Q: Can I install packages from other distributions?

**A:** SAGE OS has its own package format, but we're working on compatibility layers for popular package formats.

## 🔧 Performance and Optimization

### Q: How can I improve system performance?

**A:** Performance optimization tips:
1. Enable hardware acceleration
2. Optimize kernel parameters
3. Use appropriate file systems
4. Configure CPU governor
5. Tune memory settings

### Q: System feels sluggish. What should I check?

**A:** Common performance issues:
1. Check available RAM: `free -h`
2. Monitor CPU usage: `top`
3. Check disk I/O: `iostat`
4. Review system logs
5. Disable unnecessary services

## 🔄 Updates and Maintenance

### Q: How do I update SAGE OS?

**A:** Update process:
```bash
# Check for updates
sage-update check

# Download and install updates
sage-update install

# Reboot if required
sudo reboot
```

### Q: Can I rollback updates?

**A:** Yes, SAGE OS supports update rollback:
```bash
# List available snapshots
sage-snapshot list

# Rollback to previous version
sage-snapshot rollback <snapshot-id>
```

### Q: How often should I update?

**A:** We recommend:
- Security updates: Immediately
- Regular updates: Weekly
- Major updates: Monthly (after testing)

## 🆘 Getting Help

### Q: Where can I get help with SAGE OS?

**A:** Multiple support channels available:
- **Documentation**: Comprehensive docs at [docs site]
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Community support
- **Email**: Direct contact at ashishyesale007@gmail.com

### Q: How do I report a bug?

**A:** To report bugs effectively:
1. Check existing issues first
2. Provide detailed reproduction steps
3. Include system information
4. Attach relevant logs
5. Use the bug report template

### Q: Can I get commercial support?

**A:** Commercial support options are available. Contact us for enterprise support packages.

## 🔮 Future Plans

### Q: What's the roadmap for SAGE OS?

**A:** Current development priorities:
- Improved hardware support
- Enhanced security features
- Better development tools
- Performance optimizations
- Expanded architecture support

### Q: Will SAGE OS support containers?

**A:** Yes, container support is planned with:
- Native container runtime
- Docker compatibility layer
- Kubernetes integration
- Security-focused containers

### Q: Are there plans for a GUI?

**A:** GUI development is in progress:
- Wayland-based compositor
- Modern UI framework
- Touch and gesture support
- Accessibility features

## 📚 Learning Resources

### Q: How can I learn more about SAGE OS internals?

**A:** Educational resources:
- [Architecture Documentation](../architecture/overview.md)
- [Kernel Development Guide](../development/contributing.md)
- [Security Documentation](../security/overview.md)
- Source code with extensive comments

### Q: Are there tutorials available?

**A:** Yes, we provide:
- [Getting Started Tutorial](../getting-started/quickstart.md)
- [Development Tutorials](../tutorials/first-module.md)
- Video tutorials (coming soon)
- Interactive examples

## 🤝 Community

### Q: How can I join the SAGE OS community?

**A:** Join our community:
- GitHub Discussions for questions
- Contribute code and documentation
- Join our mailing list
- Follow development updates
- Participate in design discussions

### Q: Can I use SAGE OS in my project?

**A:** Yes! SAGE OS is dual-licensed:
- **BSD 3-Clause**: For open source projects
- **Commercial License**: For proprietary applications
- See [License Documentation](../home/license.md)

---

## 📞 Still Need Help?

If you can't find the answer to your question:

1. **Search Documentation**: Use the search function
2. **Check GitHub Issues**: Someone might have asked already
3. **Ask in Discussions**: Community support
4. **Contact Us**: Direct email support

**Remember**: When asking for help, always include:
- SAGE OS version
- Architecture (x86_64, ARM64, RISC-V)
- Hardware specifications
- Error messages or logs
- Steps to reproduce the issue

We're here to help make your SAGE OS experience successful! 🚀