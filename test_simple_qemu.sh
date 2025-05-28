#!/bin/bash

# Test simple QEMU boot with different approaches
echo "Testing QEMU boot approaches..."

# Test 1: Try with -machine pc
echo "Test 1: qemu-system-i386 with -machine pc"
timeout 5 qemu-system-i386 -machine pc -kernel build/i386/kernel.elf -nographic -serial stdio || echo "Failed"

echo ""
echo "Test 2: qemu-system-i386 with -machine isapc"
timeout 5 qemu-system-i386 -machine isapc -kernel build/i386/kernel.elf -nographic -serial stdio || echo "Failed"

echo ""
echo "Test 3: qemu-system-i386 with multiboot"
timeout 5 qemu-system-i386 -kernel build/i386/kernel.elf -nographic -serial stdio -append "console=ttyS0" || echo "Failed"

echo ""
echo "Test 4: qemu-system-i386 with binary kernel"
timeout 5 qemu-system-i386 -kernel build/i386/kernel_binary.img -nographic -serial stdio || echo "Failed"

echo ""
echo "Done testing"