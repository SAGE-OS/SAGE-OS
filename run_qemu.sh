#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
#
# This file is part of the SAGE OS Project.
#
# ─────────────────────────────────────────────────────────────────────────────
# Licensing:
# -----------
#
#
#   Licensed under the BSD 3-Clause License or a Commercial License.          
#   You may use this file under the terms of either license as specified in: 
#
#      - BSD 3-Clause License (see ./LICENSE)                           
#      - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
#
#   Redistribution and use in source and binary forms, with or without       
#   modification, are permitted under the BSD license provided that the      
#   following conditions are met:                                            
#
#     * Redistributions of source code must retain the above copyright       
#       notice, this list of conditions and the following disclaimer.       
#     * Redistributions in binary form must reproduce the above copyright    
#       notice, this list of conditions and the following disclaimer in the  
#       documentation and/or other materials provided with the distribution. 
#     * Neither the name of the project nor the names of its contributors    
#       may be used to endorse or promote products derived from this         
#       software without specific prior written permission.                  
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
#   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
#   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
#   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
#   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
#   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
#   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
#   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
#   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
#   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
#   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
#
# By using this software, you agree to be bound by the terms of either license.
#
# Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.
#
# ─────────────────────────────────────────────────────────────────────────────
# Contributor Guidelines:
# ------------------------
# Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
# All contributors must certify that they have the right to submit the code and agree to
# release it under the above license terms.
#
# Contributions must:
#   - Be original or appropriately attributed
#   - Include clear documentation and test cases where applicable
#   - Respect the coding and security guidelines defined in CONTRIBUTING.md
#
# ─────────────────────────────────────────────────────────────────────────────
# Terms of Use and Disclaimer:
# -----------------------------
# This software is provided "as is", without any express or implied warranty.
# In no event shall the authors, contributors, or copyright holders
# be held liable for any damages arising from the use of this software.
#
# Use of this software in critical systems (e.g., medical, nuclear, safety)
# is entirely at your own risk unless specifically licensed for such purposes.
#
# ─────────────────────────────────────────────────────────────────────────────
#

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
