# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────
# Default architecture is aarch64
ARCH ?= aarch64

# Set up cross-compilation toolchain based on architecture
ifeq ($(ARCH),x86_64)
    CROSS_COMPILE=x86_64-linux-gnu-
else ifeq ($(ARCH),arm64)
    CROSS_COMPILE=aarch64-linux-gnu-
else ifeq ($(ARCH),aarch64)
    CROSS_COMPILE=aarch64-linux-gnu-
else ifeq ($(ARCH),riscv64)
    CROSS_COMPILE=riscv64-linux-gnu-
else
    $(error Unsupported architecture: $(ARCH))
endif

CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
OBJCOPY=$(CROSS_COMPILE)objcopy

# Include paths
INCLUDES=-I. -Ikernel -Idrivers

# Base CFLAGS
CFLAGS=-nostdlib -nostartfiles -ffreestanding -O2 -Wall -Wextra $(INCLUDES)

# Architecture-specific flags and defines
ifeq ($(ARCH),x86_64)
    CFLAGS += -m64 -D__x86_64__
else ifeq ($(ARCH),arm64)
    CFLAGS += -D__aarch64__
else ifeq ($(ARCH),aarch64)
    CFLAGS += -D__aarch64__
else ifeq ($(ARCH),riscv64)
    CFLAGS += -D__riscv -D__riscv_xlen=64
endif

# Architecture-specific linker script
ifeq ($(ARCH),x86_64)
    LDFLAGS=-T linker_x86_64.ld
else
    LDFLAGS=-T linker.ld
endif

# Create build directory for architecture
BUILD_DIR=build/$(ARCH)

# Source files
BOOT_SOURCES = $(wildcard boot/*.S)
KERNEL_SOURCES = $(wildcard kernel/*.c) $(wildcard kernel/*/*.c)
DRIVER_SOURCES = $(wildcard drivers/*.c) $(wildcard drivers/*/*.c)

SOURCES = $(BOOT_SOURCES) $(KERNEL_SOURCES) $(DRIVER_SOURCES)
OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(filter %.c,$(SOURCES)))
OBJECTS += $(patsubst %.S,$(BUILD_DIR)/%.o,$(filter %.S,$(SOURCES)))

all: $(BUILD_DIR)/kernel.img

# Create build directories
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.elf: $(OBJECTS)
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS)

$(BUILD_DIR)/kernel.img: $(BUILD_DIR)/kernel.elf
	$(OBJCOPY) -O binary $< $@
	@echo "Build completed for $(ARCH) architecture"
	@echo "Output: $@"

clean:
	rm -rf build/
	@echo "Cleaned build directories"

# Create all architecture builds
all-arch:
	$(MAKE) ARCH=x86_64
	$(MAKE) ARCH=aarch64
	$(MAKE) ARCH=riscv64

# Show build information
info:
	@echo "SAGE OS Build Information"
	@echo "------------------------"
	@echo "Compiler: $(CC)"
	@echo "Linker: $(LD)"
	@echo "Object Copy: $(OBJCOPY)"
	@echo "CFLAGS: $(CFLAGS)"
	@echo "LDFLAGS: $(LDFLAGS)"
	@echo "Source files: $(words $(SOURCES))"
	@echo "Object files: $(words $(OBJECTS))"

.PHONY: all clean all-arch info