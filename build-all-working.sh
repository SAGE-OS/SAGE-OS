#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS - Build All Architectures Script (Working Version)
# This script builds SAGE OS for all supported architectures using the working Makefile

# set -e  # Exit on any error (disabled for debugging)

echo "🏗️  SAGE OS Multi-Architecture Build (Working Version)"
echo "====================================================="

# Define architectures
ARCHITECTURES=("x86_64" "aarch64" "riscv64")

# Create output directory
OUTPUT_DIR="build-output"
mkdir -p "$OUTPUT_DIR"

# Build counter
TOTAL_BUILDS=0
SUCCESSFUL_BUILDS=0
FAILED_BUILDS=0

echo "📋 Build Plan:"
for arch in "${ARCHITECTURES[@]}"; do
    echo "   - $arch"
    ((TOTAL_BUILDS++))
done
echo ""

# Build each architecture
for arch in "${ARCHITECTURES[@]}"; do
    echo "🔨 Building $arch..."
    
    if make clean && make ARCH="$arch"; then
        echo "✅ $arch build successful"
        
        # Copy output files
        if [ -f "build/$arch/kernel.img" ]; then
            cp "build/$arch/kernel.img" "$OUTPUT_DIR/kernel-$arch.img"
            echo "   📦 Saved: $OUTPUT_DIR/kernel-$arch.img"
        fi
        
        if [ -f "build/$arch/kernel.elf" ]; then
            cp "build/$arch/kernel.elf" "$OUTPUT_DIR/kernel-$arch.elf"
            echo "   📦 Saved: $OUTPUT_DIR/kernel-$arch.elf"
        fi
        
        # For x86_64, also create ISO
        if [ "$arch" = "x86_64" ]; then
            if make iso ARCH="$arch"; then
                if [ -f "build/$arch/sageos.iso" ]; then
                    cp "build/$arch/sageos.iso" "$OUTPUT_DIR/sageos-$arch.iso"
                    echo "   📦 Saved: $OUTPUT_DIR/sageos-$arch.iso"
                fi
            fi
        fi
        
        ((SUCCESSFUL_BUILDS++))
    else
        echo "❌ $arch build failed"
        ((FAILED_BUILDS++))
    fi
    echo ""
done

# Summary
echo "📊 Build Summary:"
echo "=================="
echo "Total builds:      $TOTAL_BUILDS"
echo "Successful builds: $SUCCESSFUL_BUILDS"
echo "Failed builds:     $FAILED_BUILDS"
echo ""

if [ $SUCCESSFUL_BUILDS -gt 0 ]; then
    echo "📁 Output files saved in: $OUTPUT_DIR/"
    echo "📋 Available kernel images:"
    ls -lh "$OUTPUT_DIR"/*.img 2>/dev/null || echo "   No .img files found"
    echo ""
    echo "📋 Available ELF files:"
    ls -lh "$OUTPUT_DIR"/*.elf 2>/dev/null || echo "   No .elf files found"
    echo ""
    echo "📋 Available ISO files:"
    ls -lh "$OUTPUT_DIR"/*.iso 2>/dev/null || echo "   No .iso files found"
fi

if [ $FAILED_BUILDS -eq 0 ]; then
    echo "🎉 All builds completed successfully!"
    exit 0
else
    echo "⚠️  Some builds failed. Check the output above for details."
    exit 1
fi