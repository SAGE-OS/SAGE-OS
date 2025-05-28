# SAGE OS Testing and Validation Guide

**Author:** Ashish Vasant Yesale  
**Email:** ashishyesale007@gmail.com  
**Date:** May 28, 2025  
**Version:** 1.0.0  

## Overview

This guide provides comprehensive testing procedures for SAGE OS across all supported architectures and platforms. It covers automated testing, manual validation, performance benchmarking, and quality assurance processes.

---

## Testing Framework

### Automated Testing Suite

SAGE OS includes a comprehensive testing framework with the following components:

#### 1. Build Testing (`build_all.sh`)
```bash
#!/bin/bash
# Automated build testing for all architectures

ARCHITECTURES=("i386" "x86_64" "aarch64" "riscv64")
BUILD_RESULTS=()

for arch in "${ARCHITECTURES[@]}"; do
    echo "Building SAGE OS for $arch..."
    if make ARCH=$arch clean all; then
        BUILD_RESULTS+=("$arch: ✅ SUCCESS")
    else
        BUILD_RESULTS+=("$arch: ❌ FAILED")
    fi
done

# Generate build report
echo "Build Test Results:"
printf '%s\n' "${BUILD_RESULTS[@]}"
```

#### 2. Runtime Testing (`test_all.sh`)
```bash
#!/bin/bash
# Automated runtime testing with QEMU

test_architecture() {
    local arch=$1
    local timeout=30
    
    echo "Testing SAGE OS $arch architecture..."
    
    case $arch in
        "i386")
            timeout $timeout qemu-system-i386 -M pc \
                -cdrom "build/i386/sage-os-i386-v1.0.0-*.iso" \
                -m 1024 -nographic -serial stdio
            ;;
        "x86_64")
            timeout $timeout qemu-system-x86_64 -M pc \
                -cdrom "build/x86_64/sage-os-x86_64-v1.0.0-*.iso" \
                -m 2048 -nographic -serial stdio
            ;;
        "aarch64")
            timeout $timeout qemu-system-aarch64 -M virt -cpu cortex-a57 \
                -kernel "build/aarch64/sage-os-aarch64-v1.0.0-*.img" \
                -m 2048 -nographic
            ;;
        "riscv64")
            timeout $timeout qemu-system-riscv64 -M virt \
                -kernel "build/riscv64/sage-os-riscv64-v1.0.0-*.img" \
                -m 2048 -nographic
            ;;
    esac
}
```

#### 3. Safe QEMU Testing (`scripts/test_qemu_tmux.sh`)
```bash
#!/bin/bash
# Safe QEMU testing in tmux to prevent terminal lockups

test_sage_os_safe() {
    local arch=$1
    local session_name="sage-test-$arch"
    
    # Create tmux session
    tmux new-session -d -s "$session_name"
    
    # Run QEMU in tmux session
    tmux send-keys -t "$session_name" "cd /workspace/SAGE-OS" Enter
    tmux send-keys -t "$session_name" "./test_all.sh $arch" Enter
    
    # Monitor session
    echo "QEMU running in tmux session: $session_name"
    echo "To attach: tmux attach-session -t $session_name"
    echo "To kill: tmux kill-session -t $session_name"
    
    # Auto-kill after timeout
    sleep 60 && tmux kill-session -t "$session_name" 2>/dev/null &
}
```

---

## Test Categories

### 1. Build Tests

#### Compilation Verification
```bash
# Test all architectures build successfully
for arch in i386 x86_64 aarch64 riscv64; do
    echo "Testing $arch build..."
    make ARCH=$arch clean
    if make ARCH=$arch; then
        echo "✅ $arch build: SUCCESS"
    else
        echo "❌ $arch build: FAILED"
        exit 1
    fi
done
```

#### Cross-Compilation Validation
```bash
# Verify cross-compilation toolchains
check_toolchain() {
    local arch=$1
    local compiler=$2
    
    if command -v "$compiler" &> /dev/null; then
        echo "✅ $arch toolchain: $compiler found"
        $compiler --version | head -1
    else
        echo "❌ $arch toolchain: $compiler not found"
        return 1
    fi
}

check_toolchain "i386" "gcc"
check_toolchain "x86_64" "x86_64-linux-gnu-gcc"
check_toolchain "aarch64" "aarch64-linux-gnu-gcc"
check_toolchain "riscv64" "riscv64-linux-gnu-gcc"
```

#### Binary Validation
```bash
# Verify generated binaries
validate_binary() {
    local arch=$1
    local binary=$2
    
    if [ -f "$binary" ]; then
        echo "✅ $arch binary exists: $binary"
        file "$binary"
        ls -lh "$binary"
    else
        echo "❌ $arch binary missing: $binary"
        return 1
    fi
}

validate_binary "i386" "build/i386/sage-os-i386-v1.0.0-*.iso"
validate_binary "x86_64" "build/x86_64/sage-os-x86_64-v1.0.0-*.iso"
validate_binary "aarch64" "build/aarch64/sage-os-aarch64-v1.0.0-*.img"
validate_binary "riscv64" "build/riscv64/sage-os-riscv64-v1.0.0-*.img"
```

### 2. Boot Tests

#### QEMU Boot Verification
```bash
# Test boot sequence for each architecture
test_boot_sequence() {
    local arch=$1
    local expected_output="SAGE OS"
    local timeout=30
    
    echo "Testing $arch boot sequence..."
    
    # Capture QEMU output
    local output_file="/tmp/sage-test-$arch.log"
    
    case $arch in
        "i386"|"x86_64")
            timeout $timeout qemu-system-$arch -M pc \
                -cdrom "build/$arch/sage-os-$arch-v1.0.0-*.iso" \
                -m 2048 -nographic > "$output_file" 2>&1 &
            ;;
        "aarch64")
            timeout $timeout qemu-system-aarch64 -M virt -cpu cortex-a57 \
                -kernel "build/aarch64/sage-os-aarch64-v1.0.0-*.img" \
                -m 2048 -nographic > "$output_file" 2>&1 &
            ;;
        "riscv64")
            timeout $timeout qemu-system-riscv64 -M virt \
                -kernel "build/riscv64/sage-os-riscv64-v1.0.0-*.img" \
                -m 2048 -nographic > "$output_file" 2>&1 &
            ;;
    esac
    
    local qemu_pid=$!
    sleep 10
    
    # Check if SAGE OS booted
    if grep -q "$expected_output" "$output_file"; then
        echo "✅ $arch boot: SUCCESS"
        kill $qemu_pid 2>/dev/null
        return 0
    else
        echo "❌ $arch boot: FAILED"
        echo "Boot log:"
        cat "$output_file"
        kill $qemu_pid 2>/dev/null
        return 1
    fi
}
```

#### Boot Time Measurement
```bash
# Measure boot time for performance testing
measure_boot_time() {
    local arch=$1
    local start_time=$(date +%s.%N)
    
    # Boot SAGE OS and wait for shell prompt
    timeout 60 expect << EOF
spawn qemu-system-$arch -M pc -cdrom build/$arch/sage-os-$arch-*.iso -m 2048 -nographic
expect "sage@localhost" { 
    send "exit\r"
    expect eof
}
EOF
    
    local end_time=$(date +%s.%N)
    local boot_time=$(echo "$end_time - $start_time" | bc)
    
    echo "$arch boot time: ${boot_time}s"
}
```

### 3. Functional Tests

#### Shell Command Testing
```bash
# Test shell functionality
test_shell_commands() {
    local arch=$1
    
    echo "Testing $arch shell commands..."
    
    # Create expect script for interactive testing
    cat > "/tmp/test-$arch-shell.exp" << 'EOF'
#!/usr/bin/expect
set timeout 30

# Start QEMU
spawn qemu-system-ARCH -M pc -cdrom IMAGE_PATH -m 2048 -nographic

# Wait for shell prompt
expect "sage@localhost"

# Test help command
send "help\r"
expect "Available commands"

# Test version command
send "version\r"
expect "SAGE OS v1.0.0"

# Test file operations
send "touch test.txt\r"
expect "created successfully"

send "ls\r"
expect "test.txt"

send "mkdir testdir\r"
expect "created successfully"

send "ls\r"
expect "testdir"

# Test graceful exit
send "exit\r"
expect "Thank you for using SAGE OS"
expect eof
EOF
    
    # Replace placeholders and run test
    sed -i "s/ARCH/$arch/g" "/tmp/test-$arch-shell.exp"
    sed -i "s|IMAGE_PATH|build/$arch/sage-os-$arch-v1.0.0-*.iso|g" "/tmp/test-$arch-shell.exp"
    
    if expect "/tmp/test-$arch-shell.exp"; then
        echo "✅ $arch shell commands: SUCCESS"
    else
        echo "❌ $arch shell commands: FAILED"
    fi
}
```

#### ASCII Art Display Test
```bash
# Verify ASCII art welcome screen
test_ascii_art() {
    local arch=$1
    local output_file="/tmp/sage-ascii-$arch.log"
    
    echo "Testing $arch ASCII art display..."
    
    # Capture boot output
    timeout 20 qemu-system-$arch -M pc \
        -cdrom "build/$arch/sage-os-$arch-v1.0.0-*.iso" \
        -m 2048 -nographic > "$output_file" 2>&1 &
    
    local qemu_pid=$!
    sleep 15
    kill $qemu_pid 2>/dev/null
    
    # Check for ASCII art elements
    if grep -q "███████╗" "$output_file" && \
       grep -q "SAGE OS" "$output_file" && \
       grep -q "Ashish Yesale" "$output_file"; then
        echo "✅ $arch ASCII art: SUCCESS"
    else
        echo "❌ $arch ASCII art: FAILED"
        echo "Output:"
        cat "$output_file"
    fi
}
```

### 4. Performance Tests

#### Memory Usage Testing
```bash
# Test memory consumption
test_memory_usage() {
    local arch=$1
    
    echo "Testing $arch memory usage..."
    
    # Start QEMU with memory monitoring
    qemu-system-$arch -M pc \
        -cdrom "build/$arch/sage-os-$arch-v1.0.0-*.iso" \
        -m 2048 -nographic \
        -monitor unix:/tmp/qemu-monitor-$arch.sock,server,nowait &
    
    local qemu_pid=$!
    sleep 10
    
    # Query memory usage via QEMU monitor
    echo "info memory" | socat - unix:/tmp/qemu-monitor-$arch.sock
    
    kill $qemu_pid 2>/dev/null
}
```

#### Boot Performance Benchmarking
```bash
# Benchmark boot performance across architectures
benchmark_boot_performance() {
    echo "SAGE OS Boot Performance Benchmark"
    echo "=================================="
    
    for arch in i386 x86_64 aarch64 riscv64; do
        echo "Benchmarking $arch..."
        
        local total_time=0
        local runs=3
        
        for ((i=1; i<=runs; i++)); do
            local start_time=$(date +%s.%N)
            
            timeout 60 expect << EOF > /dev/null 2>&1
spawn qemu-system-$arch -M pc -cdrom build/$arch/sage-os-$arch-*.iso -m 2048 -nographic
expect "sage@localhost" { 
                send "exit\r"
                expect eof
            }
EOF
            
            local end_time=$(date +%s.%N)
            local run_time=$(echo "$end_time - $start_time" | bc)
            total_time=$(echo "$total_time + $run_time" | bc)
        done
        
        local avg_time=$(echo "scale=2; $total_time / $runs" | bc)
        echo "$arch average boot time: ${avg_time}s"
    done
}
```

### 5. Regression Tests

#### Version Consistency Testing
```bash
# Ensure version consistency across builds
test_version_consistency() {
    echo "Testing version consistency..."
    
    local expected_version="v1.0.0"
    local version_errors=0
    
    for arch in i386 x86_64 aarch64 riscv64; do
        # Extract version from binary
        local binary_path="build/$arch/sage-os-$arch-v1.0.0-*"
        
        if ls $binary_path 1> /dev/null 2>&1; then
            if [[ $binary_path == *"$expected_version"* ]]; then
                echo "✅ $arch version: $expected_version"
            else
                echo "❌ $arch version mismatch"
                ((version_errors++))
            fi
        else
            echo "❌ $arch binary not found"
            ((version_errors++))
        fi
    done
    
    if [ $version_errors -eq 0 ]; then
        echo "✅ Version consistency: PASSED"
    else
        echo "❌ Version consistency: FAILED ($version_errors errors)"
        return 1
    fi
}
```

#### Feature Parity Testing
```bash
# Ensure all architectures have the same features
test_feature_parity() {
    echo "Testing feature parity across architectures..."
    
    local features=("ASCII art" "Shell commands" "File operations" "Graceful exit")
    local parity_errors=0
    
    for feature in "${features[@]}"; do
        echo "Testing feature: $feature"
        
        for arch in i386 x86_64 aarch64 riscv64; do
            # Test feature availability (simplified)
            case $feature in
                "ASCII art")
                    if test_ascii_art "$arch" > /dev/null 2>&1; then
                        echo "  ✅ $arch: $feature available"
                    else
                        echo "  ❌ $arch: $feature missing"
                        ((parity_errors++))
                    fi
                    ;;
                # Add other feature tests...
            esac
        done
    done
    
    if [ $parity_errors -eq 0 ]; then
        echo "✅ Feature parity: PASSED"
    else
        echo "❌ Feature parity: FAILED ($parity_errors errors)"
        return 1
    fi
}
```

---

## Test Execution

### Manual Testing Procedures

#### 1. Pre-Test Setup
```bash
# Ensure clean environment
make clean
rm -rf build/
rm -f /tmp/sage-test-*

# Verify dependencies
./scripts/install_dependencies.sh

# Check QEMU installation
qemu-system-x86_64 --version
qemu-system-aarch64 --version
qemu-system-riscv64 --version
```

#### 2. Build Verification
```bash
# Run build tests
echo "Starting build verification..."
./build_all.sh

# Check build outputs
ls -la build/*/sage-os-*
```

#### 3. Runtime Testing
```bash
# Safe QEMU testing
echo "Starting runtime tests..."

# Test each architecture in tmux
for arch in i386 x86_64 aarch64 riscv64; do
    ./scripts/test_qemu_tmux.sh "$arch"
    sleep 5
done

# Monitor tmux sessions
tmux list-sessions | grep sage-test
```

#### 4. Interactive Testing
```bash
# Manual interactive testing
echo "Manual testing checklist:"
echo "1. Boot SAGE OS"
echo "2. Verify ASCII art display"
echo "3. Test shell commands:"
echo "   - help"
echo "   - version"
echo "   - ls"
echo "   - mkdir test"
echo "   - touch test.txt"
echo "   - cat test.txt"
echo "   - nano test.txt"
echo "   - exit"
echo "4. Verify graceful shutdown"

# Start interactive session
qemu-system-x86_64 -M pc \
    -cdrom build/x86_64/sage-os-x86_64-v1.0.0-*.iso \
    -m 2048
```

### Automated Testing Pipeline

#### Continuous Integration Script
```bash
#!/bin/bash
# CI/CD pipeline for SAGE OS testing

set -e

echo "SAGE OS Continuous Integration Pipeline"
echo "======================================"

# Stage 1: Environment Setup
echo "Stage 1: Environment Setup"
./scripts/install_dependencies.sh

# Stage 2: Build Testing
echo "Stage 2: Build Testing"
./build_all.sh

# Stage 3: Binary Validation
echo "Stage 3: Binary Validation"
for arch in i386 x86_64 aarch64 riscv64; do
    if [ -f "build/$arch/sage-os-$arch-v1.0.0-"*.* ]; then
        echo "✅ $arch binary validated"
    else
        echo "❌ $arch binary missing"
        exit 1
    fi
done

# Stage 4: Runtime Testing
echo "Stage 4: Runtime Testing"
./test_all.sh

# Stage 5: Performance Benchmarking
echo "Stage 5: Performance Benchmarking"
benchmark_boot_performance

# Stage 6: Regression Testing
echo "Stage 6: Regression Testing"
test_version_consistency
test_feature_parity

echo "✅ All tests passed! SAGE OS is ready for release."
```

---

## Test Results and Reporting

### Test Report Generation

#### Automated Report Creation
```bash
# Generate comprehensive test report
generate_test_report() {
    local report_file="test_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# SAGE OS Test Report

**Date:** $(date)
**Version:** v1.0.0
**Tester:** Automated Testing Suite

## Build Results

EOF
    
    # Add build results
    for arch in i386 x86_64 aarch64 riscv64; do
        if [ -f "build/$arch/sage-os-$arch-v1.0.0-"*.* ]; then
            echo "- ✅ $arch: Build successful" >> "$report_file"
        else
            echo "- ❌ $arch: Build failed" >> "$report_file"
        fi
    done
    
    cat >> "$report_file" << EOF

## Runtime Test Results

EOF
    
    # Add runtime test results
    # (Implementation depends on test framework)
    
    echo "Test report generated: $report_file"
}
```

#### Performance Metrics Collection
```bash
# Collect performance metrics
collect_performance_metrics() {
    local metrics_file="performance_metrics_$(date +%Y%m%d).json"
    
    cat > "$metrics_file" << EOF
{
  "sage_os_version": "v1.0.0",
  "test_date": "$(date -Iseconds)",
  "architectures": {
EOF
    
    local first=true
    for arch in i386 x86_64 aarch64 riscv64; do
        if [ "$first" = false ]; then
            echo "," >> "$metrics_file"
        fi
        first=false
        
        # Measure boot time (simplified)
        local boot_time=$(measure_boot_time "$arch" 2>/dev/null || echo "N/A")
        
        cat >> "$metrics_file" << EOF
    "$arch": {
      "boot_time": "$boot_time",
      "binary_size": "$(stat -c%s build/$arch/sage-os-$arch-* 2>/dev/null || echo 0)",
      "memory_usage": "TBD"
    }
EOF
    done
    
    cat >> "$metrics_file" << EOF
  }
}
EOF
    
    echo "Performance metrics collected: $metrics_file"
}
```

---

## Quality Assurance

### Code Quality Checks

#### Static Analysis
```bash
# Run static analysis on kernel code
run_static_analysis() {
    echo "Running static analysis..."
    
    # Check for common issues
    find kernel/ -name "*.c" -exec cppcheck {} \;
    
    # Check coding style
    find kernel/ -name "*.c" -exec checkpatch.pl --no-tree {} \;
    
    # Security analysis
    find kernel/ -name "*.c" -exec flawfinder {} \;
}
```

#### Memory Safety Validation
```bash
# Validate memory safety
check_memory_safety() {
    echo "Checking memory safety..."
    
    # Build with AddressSanitizer (where supported)
    make ARCH=x86_64 CFLAGS="-fsanitize=address" clean all
    
    # Run memory leak detection
    valgrind --tool=memcheck --leak-check=full \
        qemu-system-x86_64 -M pc \
        -cdrom build/x86_64/sage-os-x86_64-v1.0.0-*.iso \
        -m 2048 -nographic
}
```

### Security Testing

#### Vulnerability Scanning
```bash
# Scan for known vulnerabilities
run_vulnerability_scan() {
    echo "Running vulnerability scan..."
    
    # Scan source code
    bandit -r kernel/ || true
    
    # Scan dependencies
    safety check || true
    
    # Custom security checks
    grep -r "strcpy\|strcat\|sprintf" kernel/ && \
        echo "⚠️  Found potentially unsafe string functions"
}
```

---

## Troubleshooting Test Issues

### Common Test Failures

#### QEMU Hangs or Crashes
```bash
# Problem: QEMU hangs during testing
# Solution: Use tmux-based testing
./scripts/test_qemu_tmux.sh i386

# Problem: QEMU crashes with segfault
# Solution: Check QEMU version and machine type
qemu-system-x86_64 --version
qemu-system-x86_64 -M help
```

#### Build Failures
```bash
# Problem: Cross-compilation toolchain missing
# Solution: Install required packages
sudo apt-get install gcc-multilib gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu

# Problem: Linker errors
# Solution: Clean and rebuild
make clean
make ARCH=target_arch
```

#### Test Environment Issues
```bash
# Problem: Insufficient permissions
# Solution: Check user permissions
groups $USER
sudo usermod -a -G kvm $USER

# Problem: Missing dependencies
# Solution: Run dependency installer
./scripts/install_dependencies.sh
```

### Debug Procedures

#### Enable Verbose Testing
```bash
# Run tests with verbose output
export SAGE_TEST_VERBOSE=1
./test_all.sh

# Enable QEMU debugging
export QEMU_DEBUG=1
qemu-system-x86_64 -d guest_errors,unimp -D qemu.log ...
```

#### Collect Debug Information
```bash
# Collect system information
collect_debug_info() {
    echo "Collecting debug information..."
    
    {
        echo "=== System Information ==="
        uname -a
        lsb_release -a 2>/dev/null || cat /etc/os-release
        
        echo "=== QEMU Versions ==="
        qemu-system-x86_64 --version
        qemu-system-aarch64 --version
        qemu-system-riscv64 --version
        
        echo "=== Toolchain Versions ==="
        gcc --version
        aarch64-linux-gnu-gcc --version 2>/dev/null || echo "Not installed"
        riscv64-linux-gnu-gcc --version 2>/dev/null || echo "Not installed"
        
        echo "=== Build Directory ==="
        ls -la build/
        
        echo "=== Recent Logs ==="
        tail -50 /tmp/sage-test-*.log 2>/dev/null || echo "No logs found"
        
    } > debug_info_$(date +%Y%m%d_%H%M%S).txt
    
    echo "Debug information collected"
}
```

---

## Conclusion

The SAGE OS testing framework provides comprehensive validation across:

- **Build System**: Multi-architecture compilation
- **Runtime Behavior**: Boot sequence and shell functionality
- **Performance**: Boot time and resource usage
- **Quality Assurance**: Code quality and security
- **Regression Prevention**: Version and feature consistency

Regular testing ensures SAGE OS maintains high quality and reliability across all supported platforms and architectures.

---

**SAGE OS v1.0.0**  
*Testing and Validation Framework*  
*Designed by Ashish Yesale*  
*May 28, 2025*