#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS QEMU Runner Script
# ─────────────────────────────────────────────────────────────────────────────

if [ ! -f "build/aarch64/kernel.img" ]; then
    echo "Error: build/aarch64/kernel.img not found. Build the kernel first with 'make'."
    exit 1
fi

QEMU_CMD="qemu-system-aarch64"

# Default platform and options
RPI_MODEL="raspi3"
RPI_VERSION=3
DEBUG=0
GRAPHICS=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--debug)
            DEBUG=1
            shift
            ;;
        -g|--graphics)
            GRAPHICS=1
            shift
            ;;
        -p|--platform)
            if [[ $2 == "rpi3" ]]; then
                RPI_MODEL="raspi3"
                RPI_VERSION=3
            elif [[ $2 == "rpi4" ]]; then
                RPI_MODEL="raspi3"  # fallback since raspi4 unsupported in QEMU
                RPI_VERSION=4
            elif [[ $2 == "rpi5" ]]; then
                RPI_MODEL="raspi3"  # fallback
                RPI_VERSION=5
            elif [[ $2 == "virt" ]]; then
                RPI_MODEL="virt"
                RPI_VERSION=0
            else
                echo "Unknown platform: $2"
                echo "Supported platforms: rpi3, rpi4, rpi5, virt"
                exit 1
            fi
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -d, --debug             Run with GDB server enabled"
            echo "  -g, --graphics          Enable graphical output (not just serial)"
            echo "  -p, --platform PLATFORM Specify platform (rpi3, rpi4, rpi5, virt)"
            echo "  -h, --help              Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# On macOS, force virt platform if RPI_MODEL is raspi3 or others (except if explicitly virt)
if [[ "$OSTYPE" == "darwin"* ]] && [[ "$RPI_MODEL" != "virt" ]]; then
    echo "macOS detected, forcing platform to 'virt' for compatibility"
    RPI_MODEL="virt"
    RPI_VERSION=0
fi

# Base QEMU options
if [[ "$RPI_MODEL" == "virt" ]]; then
    QEMU_OPTS="-M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img"
else
    QEMU_OPTS="-M $RPI_MODEL -kernel build/aarch64/kernel.img"
fi

# Add serial and graphics options
if [[ $GRAPHICS -eq 1 ]]; then
    # Graphics enabled
    QEMU_OPTS="$QEMU_OPTS -serial mon:stdio"
    # No -nographic
    echo "Graphics mode enabled"
else
    # No graphics, use nographic and simple serial console
    # Avoid multiple stdio backends conflict by using -serial mon:stdio only for virt
    if [[ "$RPI_MODEL" == "virt" ]]; then
        QEMU_OPTS="$QEMU_OPTS -serial mon:stdio -nographic"
    else
        QEMU_OPTS="$QEMU_OPTS -serial stdio -nographic"
    fi
fi

# Add debug options if requested
if [[ $DEBUG -eq 1 ]]; then
    QEMU_OPTS="$QEMU_OPTS -s -S"
    echo "Debug mode enabled. Connect with:"
    echo "  aarch64-linux-gnu-gdb kernel.elf -ex 'target remote localhost:1234'"
fi

# Show platform info
if [[ "$RPI_MODEL" == "virt" ]]; then
    echo "Platform: virt (generic ARM virtual machine)"
else
    echo "Platform: Raspberry Pi $RPI_VERSION (emulated as $RPI_MODEL)"
    if [[ $RPI_VERSION -eq 5 ]]; then
        echo "Note: QEMU doesn't fully support Raspberry Pi 5; using Raspberry Pi 3 emulation"
    fi
fi

# Run QEMU
echo "Starting QEMU with options: $QEMU_OPTS"
echo "Press Ctrl+A, X to exit QEMU"
echo "-----------------------------------"
$QEMU_CMD $QEMU_OPTS
