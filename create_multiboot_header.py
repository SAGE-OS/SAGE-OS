#!/usr/bin/env python3
"""
SAGE OS Multiboot Header Creator
Creates a proper multiboot header for x86_64 kernels
"""

import struct
import sys
import os

def create_multiboot_header():
    """Create a multiboot header for x86_64 kernel"""
    
    # Multiboot magic numbers
    MULTIBOOT_MAGIC = 0x1BADB002
    MULTIBOOT_FLAGS = 0x00000003  # ALIGN + MEMINFO
    
    # Calculate checksum
    checksum = -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS) & 0xFFFFFFFF
    
    # Create multiboot header (12 bytes)
    header = struct.pack('<III', MULTIBOOT_MAGIC, MULTIBOOT_FLAGS, checksum)
    
    # Pad to align to 16 bytes
    header += b'\x00' * 4
    
    return header

def main():
    """Main function"""
    try:
        # Create multiboot header
        header = create_multiboot_header()
        
        # Write to file
        with open('build/x86_64/multiboot_header.bin', 'wb') as f:
            f.write(header)
        
        print("✓ Multiboot header created successfully")
        return 0
        
    except Exception as e:
        print(f"✗ Error creating multiboot header: {e}")
        return 1

if __name__ == '__main__':
    sys.exit(main())