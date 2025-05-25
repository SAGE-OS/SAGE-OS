#!/bin/bash

DTB_FILE="virt.dtb"
DTB_URL=" "


# Function to check if the DTB file is valid
function check_dtb() {
    if [ ! -f "$DTB_FILE" ]; then
        return 1
    fi
    # Check file type to confirm it's a flattened device tree blob
    filetype=$(file "$DTB_FILE")
    if [[ "$filetype" == *"Flattened device tree data"* ]]; then
        return 0
    else
        return 1
    fi
}

# Download DTB if missing or invalid
if ! check_dtb; then
    echo "Downloading valid virt.dtb from kernel.org..."
    curl -L -o "$DTB_FILE" "$DTB_URL"
    
    if ! check_dtb; then
        echo "Error: Downloaded DTB file is invalid or corrupted."
        exit 1
    fi
fi

echo "Using device tree blob: $DTB_FILE"

# Run QEMU with virt machine and downloaded DTB
qemu-system-aarch64 -machine virt -cpu cortex-a72 -m 1024 \
-kernel build/aarch64/kernel.img -dtb "$DTB_FILE" -serial mon:stdio -nographic
