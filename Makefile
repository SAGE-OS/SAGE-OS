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
KERNEL_SOURCES = $(wildcard kernel/*.c) $(wildcard kernel/*/*.c)
DRIVER_SOURCES = $(wildcard drivers/*.c) $(wildcard drivers/*/*.c)

# Architecture-specific boot files
ifeq ($(ARCH),x86_64)
    BOOT_SOURCES = boot/boot_no_multiboot.S
    BOOT_OBJECTS = $(BUILD_DIR)/boot/boot_no_multiboot.o
else
    BOOT_SOURCES = boot/boot.S
    BOOT_OBJECTS = $(BUILD_DIR)/boot/boot.o
endif

SOURCES = $(BOOT_SOURCES) $(KERNEL_SOURCES) $(DRIVER_SOURCES)

KERNEL_OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(filter %.c,$(KERNEL_SOURCES) $(DRIVER_SOURCES)))
OBJECTS = $(BOOT_OBJECTS) $(KERNEL_OBJECTS)

all: $(BUILD_DIR)/kernel.img

# Create build directories
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Special rule for x86_64 boot with multiboot
$(BUILD_DIR)/boot/boot_with_multiboot.o: boot/boot_with_multiboot.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Special rule for x86_64 boot without multiboot (legacy)
$(BUILD_DIR)/boot/boot_no_multiboot.o: boot/boot_no_multiboot.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.elf: $(OBJECTS)
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS)

$(BUILD_DIR)/kernel.img: $(BUILD_DIR)/kernel.elf
ifeq ($(ARCH),x86_64)
	# For x86_64, create multiboot header and concatenate with kernel binary, then wrap in ELF
	python3 create_multiboot_header.py
	$(OBJCOPY) -O binary $< $(BUILD_DIR)/kernel_no_multiboot.bin
	cat multiboot_header.bin $(BUILD_DIR)/kernel_no_multiboot.bin > $(BUILD_DIR)/kernel_binary.img
	python3 create_elf_wrapper.py $(BUILD_DIR)/kernel_binary.img $@
	@echo "Build completed for $(ARCH) architecture with ELF multiboot wrapper"
else
	$(OBJCOPY) -O binary $< $@
	@echo "Build completed for $(ARCH) architecture"
endif
	@echo "Output: $@"

clean:
	rm -rf build/
	@echo "Cleaned build directories"

# Create ISO image (x86_64 only)
iso: $(BUILD_DIR)/kernel.img
ifeq ($(ARCH),x86_64)
	@mkdir -p $(BUILD_DIR)/iso/boot/grub
	@cp $< $(BUILD_DIR)/iso/boot/kernel.img
	@echo 'set timeout=5' > $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo 'set default=0' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo 'menuentry "SAGE OS x86_64" {' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '    multiboot /boot/kernel.img' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '    boot' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '}' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(BUILD_DIR)/sageos.iso $(BUILD_DIR)/iso
	@echo "ISO created: $(BUILD_DIR)/sageos.iso"
else
	@echo "ISO creation only supported for x86_64 architecture"
endif

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

# Alias targets
kernel: $(BUILD_DIR)/kernel.elf
image: $(BUILD_DIR)/kernel.img

.PHONY: all clean all-arch info kernel image