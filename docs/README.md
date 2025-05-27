# SAGE OS Documentation

Welcome to the comprehensive documentation for SAGE OS - a next-generation operating system with built-in AI capabilities and multi-architecture support.

## 📚 Documentation Structure

### 🏗️ [Architecture](./architecture/)
- [System Overview](./architecture/system-overview.md)
- [Multi-Architecture Support](./architecture/multi-arch.md)
- [Boot Process](./architecture/boot-process.md)
- [Memory Management](./architecture/memory.md)

### 🔧 [Build System](./build/)
- [Build Guide](./build/build-guide.md)
- [Cross-Compilation](./build/cross-compilation.md)
- [Docker Build](./build/docker.md)
- [CI/CD Pipeline](./build/cicd.md)

### 🧠 [Kernel](./kernel/)
- [Kernel Architecture](./kernel/architecture.md)
- [System Calls](./kernel/syscalls.md)
- [Process Management](./kernel/processes.md)
- [File System](./kernel/filesystem.md)

### 🔌 [Drivers](./drivers/)
- [Driver Framework](./drivers/framework.md)
- [Hardware Abstraction Layer](./drivers/hal.md)
- [AI Hat Driver](./drivers/ai-hat.md)
- [UART Driver](./drivers/uart.md)

### 🤖 [AI Subsystem](./ai/)
- [AI Architecture](./ai/architecture.md)
- [Machine Learning Integration](./ai/ml-integration.md)
- [TensorFlow Lite](./ai/tensorflow-lite.md)
- [AI Hat Interface](./ai/ai-hat.md)

### 🔒 [Security](./security/)
- [Security Model](./security/model.md)
- [Cryptography](./security/crypto.md)
- [Vulnerability Management](./security/vulnerabilities.md)
- [CVE Scanning](./security/cve-scanning.md)

### 📡 [API Reference](./api/)
- [System Calls](./api/syscalls.md)
- [Driver APIs](./api/drivers.md)
- [AI APIs](./api/ai.md)
- [SDK Reference](./api/sdk.md)

### 📖 [Tutorials](./tutorials/)
- [Getting Started](./tutorials/getting-started.md)
- [Building Your First App](./tutorials/first-app.md)
- [AI Integration](./tutorials/ai-integration.md)
- [Driver Development](./tutorials/driver-development.md)

### 🔧 [Troubleshooting](./troubleshooting/)
- [Common Issues](./troubleshooting/common-issues.md)
- [Build Problems](./troubleshooting/build-problems.md)
- [Boot Issues](./troubleshooting/boot-issues.md)
- [FAQ](./troubleshooting/faq.md)

## 🚀 Quick Start

1. **Build the OS**: See [Build Guide](./build/build-guide.md)
2. **Run in QEMU**: See [Getting Started](./tutorials/getting-started.md)
3. **Develop Apps**: See [SDK Reference](./api/sdk.md)

## 🏛️ Project Structure

```
SAGE-OS/
├── boot/                   # Boot loaders and initialization
├── kernel/                 # Core kernel implementation
├── drivers/                # Hardware drivers
├── ai/                     # AI subsystem
├── security/               # Security components
├── sage-sdk/               # Software Development Kit
├── tests/                  # Test suites
├── docs/                   # This documentation
├── scripts/                # Build and utility scripts
└── .github/workflows/      # CI/CD workflows
```

## 📋 File Relationships

### Core Dependencies
- `boot/boot.S` → `kernel/kernel.c` (Boot sequence)
- `kernel/kernel.c` → `drivers/*.c` (Driver initialization)
- `kernel/ai/` → `drivers/ai_hat/` (AI hardware interface)
- `security/crypto.c` → `kernel/` (Security services)

### Build System
- `Makefile` → All source files (Main build orchestration)
- `scripts/` → Build automation and testing
- `.github/workflows/` → Continuous integration

## 🎯 Key Features

- **Multi-Architecture**: x86_64, AArch64, RISC-V
- **AI Integration**: Built-in machine learning capabilities
- **Security First**: Comprehensive security model
- **Modern Build**: Docker, CI/CD, automated testing
- **Extensible**: Plugin architecture for drivers and AI models

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/NMC-TechClub/SAGE-OS/issues)
- **Discussions**: [GitHub Discussions](https://github.com/NMC-TechClub/SAGE-OS/discussions)
- **Email**: ashishyesale007@gmail.com

## 📄 License

SAGE OS is dual-licensed under BSD-3-Clause and Commercial licenses.
See [LICENSE](../LICENSE) for details.