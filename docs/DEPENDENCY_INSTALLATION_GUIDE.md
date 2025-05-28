# SAGE OS Dependency Installation Guide

**Version:** 1.0.0  
**Author:** Ashish Vasant Yesale <ashishyesale007@gmail.com>  
**Last Updated:** 2025-05-28  

## Table of Contents

1. [Overview](#overview)
2. [Ubuntu/Debian Installation](#ubuntudebian-installation)
3. [macOS Installation](#macos-installation)
4. [Fedora/RHEL Installation](#fedorarhel-installation)
5. [Arch Linux Installation](#arch-linux-installation)
6. [Manual Installation](#manual-installation)
7. [Verification](#verification)
8. [Troubleshooting](#troubleshooting)

---

## Overview

SAGE OS requires several dependencies for cross-compilation, emulation, testing, and security analysis. This guide provides comprehensive installation instructions for all supported platforms.

### Required Dependencies

#### Core Build Tools
- **GCC Cross-Compilers**: For multi-architecture compilation
- **Binutils**: For linking and object file manipulation
- **Make**: Build system automation
- **Git**: Version control

#### Emulation & Testing
- **QEMU**: Hardware emulation for testing
- **TMUX**: Terminal multiplexer for safe QEMU sessions

#### Image Creation
- **GRUB**: Bootloader for x86 architectures
- **Xorriso**: ISO image creation
- **Genisoimage**: Alternative ISO creation tool
- **Dosfstools**: FAT filesystem tools

#### Security & Analysis
- **Docker**: Container platform
- **Python 3**: Scripting and analysis tools
- **CVE-bin-tool**: Vulnerability scanning

---

## Ubuntu/Debian Installation

### Automated Installation Script

Create and run the complete installation script:

```bash
#!/bin/bash
# SAGE OS Ubuntu/Debian Dependency Installer
# Author: Ashish Vasant Yesale <ashishyesale007@gmail.com>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root"
   exit 1
fi

log_info "🔧 Installing SAGE OS dependencies for Ubuntu/Debian..."

# Update package lists
log_info "Updating package lists..."
sudo apt update

# Install core build tools
log_info "Installing core build tools..."
sudo apt install -y \
    build-essential \
    git \
    curl \
    wget \
    vim \
    tmux \
    screen

# Install cross-compilation toolchains
log_info "Installing cross-compilation toolchains..."
sudo apt install -y \
    gcc-multilib \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    gcc-riscv64-linux-gnu \
    binutils-aarch64-linux-gnu \
    binutils-arm-linux-gnueabihf \
    binutils-riscv64-linux-gnu \
    libc6-dev-i386

# Install QEMU emulation
log_info "Installing QEMU emulation tools..."
sudo apt install -y \
    qemu-system-x86 \
    qemu-system-arm \
    qemu-system-misc \
    qemu-utils

# Install image creation tools
log_info "Installing image creation tools..."
sudo apt install -y \
    genisoimage \
    xorriso \
    grub-common \
    grub-pc-bin \
    grub-efi-amd64-bin \
    dosfstools \
    mtools \
    syslinux \
    isolinux

# Install Docker
log_info "Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Set up the stable repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package lists and install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    # Enable and start Docker service
    sudo systemctl enable docker
    sudo systemctl start docker
else
    log_info "Docker already installed"
fi

# Install Python and security tools
log_info "Installing Python and security tools..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev

# Install Python packages
log_info "Installing Python security packages..."
pip3 install --user \
    cve-bin-tool \
    requests \
    beautifulsoup4 \
    lxml \
    pyyaml \
    jinja2

# Install additional development tools
log_info "Installing additional development tools..."
sudo apt install -y \
    clang \
    clang-format \
    cppcheck \
    valgrind \
    gdb \
    strace \
    ltrace

# Install documentation tools
log_info "Installing documentation tools..."
sudo apt install -y \
    doxygen \
    graphviz \
    pandoc \
    texlive-latex-base \
    texlive-latex-extra

# Optional: Install GitHub CLI
log_info "Installing GitHub CLI (optional)..."
if ! command -v gh &> /dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
fi

log_success "✅ All dependencies installed successfully!"
log_warning "⚠️  Please log out and back in for Docker group membership to take effect."

# Verify installation
log_info "Verifying installation..."
./VERIFY_BUILD_SYSTEM.sh 2>/dev/null || log_warning "Run ./VERIFY_BUILD_SYSTEM.sh to verify installation"

log_info "🎉 SAGE OS development environment is ready!"
```

### Manual Step-by-Step Installation

#### 1. Update System
```bash
sudo apt update && sudo apt upgrade -y
```

#### 2. Install Core Build Tools
```bash
sudo apt install -y \
    build-essential \
    git \
    curl \
    wget \
    vim \
    tmux \
    screen
```

#### 3. Install Cross-Compilation Toolchains
```bash
# Install GCC cross-compilers
sudo apt install -y \
    gcc-multilib \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    gcc-riscv64-linux-gnu

# Install binutils for cross-compilation
sudo apt install -y \
    binutils-aarch64-linux-gnu \
    binutils-arm-linux-gnueabihf \
    binutils-riscv64-linux-gnu

# Install 32-bit development libraries
sudo apt install -y libc6-dev-i386
```

#### 4. Install QEMU Emulation
```bash
sudo apt install -y \
    qemu-system-x86 \
    qemu-system-arm \
    qemu-system-misc \
    qemu-utils
```

#### 5. Install Image Creation Tools
```bash
sudo apt install -y \
    genisoimage \
    xorriso \
    grub-common \
    grub-pc-bin \
    grub-efi-amd64-bin \
    dosfstools \
    mtools \
    syslinux \
    isolinux
```

#### 6. Install Docker
```bash
# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker
```

#### 7. Install Python and Security Tools
```bash
# Install Python
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev

# Install Python packages
pip3 install --user \
    cve-bin-tool \
    requests \
    beautifulsoup4 \
    lxml \
    pyyaml \
    jinja2
```

---

## macOS Installation

### Automated Installation Script

```bash
#!/bin/bash
# SAGE OS macOS Dependency Installer
# Author: Ashish Vasant Yesale <ashishyesale007@gmail.com>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "🍎 Installing SAGE OS dependencies for macOS..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Update Homebrew
log_info "Updating Homebrew..."
brew update

# Install Xcode Command Line Tools
log_info "Installing Xcode Command Line Tools..."
xcode-select --install 2>/dev/null || log_info "Xcode Command Line Tools already installed"

# Install cross-compilation toolchains
log_info "Installing cross-compilation toolchains..."
brew install \
    aarch64-elf-gcc \
    arm-none-eabi-gcc \
    riscv64-elf-gcc \
    x86_64-elf-gcc

# Install QEMU
log_info "Installing QEMU..."
brew install qemu

# Install terminal multiplexer
log_info "Installing terminal tools..."
brew install tmux

# Install image creation tools
log_info "Installing image creation tools..."
brew install \
    cdrtools \
    grub \
    dosfstools

# Install Docker
log_info "Installing Docker..."
if ! command -v docker &> /dev/null; then
    brew install --cask docker
    log_warning "Please start Docker Desktop manually after installation"
fi

# Install Python
log_info "Installing Python..."
brew install python3

# Install Python packages
log_info "Installing Python security packages..."
pip3 install \
    cve-bin-tool \
    requests \
    beautifulsoup4 \
    lxml \
    pyyaml \
    jinja2

# Install development tools
log_info "Installing development tools..."
brew install \
    git \
    vim \
    curl \
    wget

# Install documentation tools
log_info "Installing documentation tools..."
brew install \
    doxygen \
    graphviz \
    pandoc

# Optional: Install GitHub CLI
log_info "Installing GitHub CLI..."
brew install gh

log_success "✅ All dependencies installed successfully!"
log_info "🎉 SAGE OS development environment is ready!"
```

### Manual macOS Installation

#### 1. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2. Install Xcode Command Line Tools
```bash
xcode-select --install
```

#### 3. Install Cross-Compilation Toolchains
```bash
brew install \
    aarch64-elf-gcc \
    arm-none-eabi-gcc \
    riscv64-elf-gcc \
    x86_64-elf-gcc
```

#### 4. Install QEMU and Tools
```bash
brew install \
    qemu \
    tmux \
    cdrtools \
    grub \
    dosfstools
```

#### 5. Install Docker
```bash
brew install --cask docker
```

#### 6. Install Python and Packages
```bash
brew install python3
pip3 install cve-bin-tool requests beautifulsoup4 lxml pyyaml jinja2
```

---

## Fedora/RHEL Installation

### Automated Installation Script

```bash
#!/bin/bash
# SAGE OS Fedora/RHEL Dependency Installer

set -euo pipefail

log_info() { echo "[INFO] $1"; }
log_success() { echo "[SUCCESS] $1"; }

log_info "🔴 Installing SAGE OS dependencies for Fedora/RHEL..."

# Update system
sudo dnf update -y

# Install development tools
sudo dnf groupinstall -y "Development Tools"

# Install cross-compilation toolchains
sudo dnf install -y \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnu \
    gcc-riscv64-linux-gnu \
    binutils-aarch64-linux-gnu \
    binutils-arm-linux-gnu \
    binutils-riscv64-linux-gnu

# Install QEMU
sudo dnf install -y \
    qemu-system-x86 \
    qemu-system-arm \
    qemu-system-riscv \
    tmux

# Install image creation tools
sudo dnf install -y \
    genisoimage \
    xorriso \
    grub2-tools \
    dosfstools \
    mtools

# Install Docker
sudo dnf install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# Install Python tools
sudo dnf install -y python3 python3-pip
pip3 install --user cve-bin-tool

log_success "✅ Fedora/RHEL dependencies installed!"
```

---

## Arch Linux Installation

### Automated Installation Script

```bash
#!/bin/bash
# SAGE OS Arch Linux Dependency Installer

set -euo pipefail

log_info() { echo "[INFO] $1"; }
log_success() { echo "[SUCCESS] $1"; }

log_info "🔵 Installing SAGE OS dependencies for Arch Linux..."

# Update system
sudo pacman -Syu --noconfirm

# Install base development tools
sudo pacman -S --noconfirm \
    base-devel \
    git \
    tmux

# Install cross-compilation toolchains
sudo pacman -S --noconfirm \
    aarch64-linux-gnu-gcc \
    arm-linux-gnueabihf-gcc \
    riscv64-linux-gnu-gcc

# Install QEMU
sudo pacman -S --noconfirm \
    qemu-system-x86 \
    qemu-system-arm \
    qemu-system-riscv

# Install image creation tools
sudo pacman -S --noconfirm \
    cdrtools \
    xorriso \
    grub \
    dosfstools \
    mtools

# Install Docker
sudo pacman -S --noconfirm docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# Install Python tools
sudo pacman -S --noconfirm python python-pip
pip install --user cve-bin-tool

log_success "✅ Arch Linux dependencies installed!"
```

---

## Manual Installation

### Building Custom Toolchains

If your distribution doesn't provide the required cross-compilers:

#### RISC-V Toolchain
```bash
# Create toolchain directory
mkdir -p ~/toolchains && cd ~/toolchains

# Clone RISC-V GNU toolchain
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain

# Configure and build
./configure --prefix=$HOME/toolchains/riscv64 --with-arch=rv64gc --with-abi=lp64d
make -j$(nproc)

# Add to PATH
echo 'export PATH=$HOME/toolchains/riscv64/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

#### ARM Toolchain
```bash
# Download ARM toolchain
cd ~/toolchains
wget https://developer.arm.com/-/media/Files/downloads/gnu-a/10.3-2021.07/binrel/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu.tar.xz

# Extract
tar -xf gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu.tar.xz

# Add to PATH
echo 'export PATH=$HOME/toolchains/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### Building QEMU from Source

```bash
# Install dependencies
sudo apt install -y libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev

# Clone QEMU
git clone https://github.com/qemu/qemu.git
cd qemu

# Configure
./configure --target-list=x86_64-softmmu,aarch64-softmmu,arm-softmmu,riscv64-softmmu

# Build and install
make -j$(nproc)
sudo make install
```

---

## Verification

### Automated Verification Script

```bash
#!/bin/bash
# SAGE OS Dependency Verification Script

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is NOT installed"
        return 1
    fi
}

check_compiler() {
    if command -v "$1" &> /dev/null; then
        version=$($1 --version | head -n1)
        echo -e "${GREEN}✓${NC} $1 is installed: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is NOT installed"
        return 1
    fi
}

echo "🔍 Verifying SAGE OS dependencies..."

# Check core tools
echo -e "\n📦 Core Tools:"
check_command git
check_command make
check_command tmux

# Check compilers
echo -e "\n🔨 Compilers:"
check_compiler gcc
check_compiler "aarch64-linux-gnu-gcc"
check_compiler "arm-linux-gnueabihf-gcc"
check_compiler "riscv64-linux-gnu-gcc"

# Check QEMU
echo -e "\n🖥️  QEMU Emulators:"
check_command "qemu-system-x86_64"
check_command "qemu-system-aarch64"
check_command "qemu-system-arm"
check_command "qemu-system-riscv64"

# Check image tools
echo -e "\n💿 Image Creation Tools:"
check_command genisoimage
check_command xorriso
check_command grub-mkrescue

# Check Docker
echo -e "\n🐳 Docker:"
check_command docker
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker daemon is running"
    else
        echo -e "${YELLOW}⚠${NC} Docker is installed but daemon is not running"
    fi
fi

# Check Python tools
echo -e "\n🐍 Python Tools:"
check_command python3
check_command pip3
if python3 -c "import cve_bin_tool" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} cve-bin-tool is installed"
else
    echo -e "${RED}✗${NC} cve-bin-tool is NOT installed"
fi

echo -e "\n✅ Verification complete!"
```

### Manual Verification Commands

```bash
# Check GCC compilers
gcc --version
aarch64-linux-gnu-gcc --version
arm-linux-gnueabihf-gcc --version
riscv64-linux-gnu-gcc --version

# Check QEMU versions
qemu-system-x86_64 --version
qemu-system-aarch64 --version
qemu-system-arm --version
qemu-system-riscv64 --version

# Check image tools
genisoimage --version
xorriso --version
grub-mkrescue --version

# Check Docker
docker --version
docker info

# Check Python tools
python3 --version
pip3 --version
cve-bin-tool --version

# Test basic compilation
echo 'int main(){return 0;}' | gcc -x c - -o test && ./test && echo "GCC works!"
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Missing Cross-Compilers

**Problem:** `aarch64-linux-gnu-gcc: command not found`

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install gcc-aarch64-linux-gnu

# Fedora/RHEL
sudo dnf install gcc-aarch64-linux-gnu

# macOS
brew install aarch64-elf-gcc
```

#### 2. QEMU Not Found

**Problem:** `qemu-system-x86_64: command not found`

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install qemu-system-x86

# macOS
brew install qemu

# Check installation
which qemu-system-x86_64
```

#### 3. Docker Permission Denied

**Problem:** `permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker

# Verify
docker run hello-world
```

#### 4. Python Package Installation Issues

**Problem:** `pip3 install cve-bin-tool` fails

**Solution:**
```bash
# Install with user flag
pip3 install --user cve-bin-tool

# Or use virtual environment
python3 -m venv venv
source venv/bin/activate
pip install cve-bin-tool
```

#### 5. GRUB Tools Missing

**Problem:** `grub-mkrescue: command not found`

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install grub-common grub-pc-bin

# macOS
brew install grub

# Fedora/RHEL
sudo dnf install grub2-tools
```

#### 6. 32-bit Compilation Issues

**Problem:** Cannot compile for i386 architecture

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install gcc-multilib libc6-dev-i386

# Test 32-bit compilation
echo 'int main(){return 0;}' | gcc -m32 -x c - -o test32
```

### Environment Setup Issues

#### PATH Configuration
```bash
# Add toolchains to PATH
echo 'export PATH=$HOME/toolchains/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Verify PATH
echo $PATH | tr ':' '\n' | grep toolchain
```

#### Library Path Issues
```bash
# Set library paths
export LD_LIBRARY_PATH=$HOME/toolchains/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$HOME/toolchains/lib/pkgconfig:$PKG_CONFIG_PATH
```

### Performance Optimization

#### Parallel Builds
```bash
# Use all CPU cores
export MAKEFLAGS="-j$(nproc)"

# Or specify number of jobs
export MAKEFLAGS="-j4"
```

#### Compiler Cache
```bash
# Install ccache
sudo apt install ccache  # Ubuntu/Debian
brew install ccache      # macOS

# Configure
export CC="ccache gcc"
export CXX="ccache g++"
```

---

## Platform-Specific Notes

### Ubuntu 20.04 LTS
- Default GCC version: 9.4.0
- QEMU version: 4.2.1
- Some newer cross-compilers may need manual installation

### Ubuntu 22.04 LTS
- Default GCC version: 11.2.0
- QEMU version: 6.2.0
- Full RISC-V support available

### macOS Big Sur/Monterey
- Requires Xcode Command Line Tools
- Some Linux-specific tools need alternatives
- Docker Desktop required for container support

### macOS Ventura/Sonoma
- Apple Silicon (M1/M2) native support
- Rosetta 2 for x86_64 emulation
- Enhanced cross-compilation support

---

**Last Updated:** 2025-05-28  
**Version:** 1.0.0  
**Maintainer:** Ashish Vasant Yesale <ashishyesale007@gmail.com>

For additional help, refer to the [Developer Implementation Guide](DEVELOPER_IMPLEMENTATION_GUIDE.md) or [Command Reference](COMMAND_REFERENCE.md).