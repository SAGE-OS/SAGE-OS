ENTRY(_start)

SECTIONS
{
    /* Kernel starts at 1MB for x86 */
    . = 0x100000;
    
    __start = .;
    
    /* Text section with multiboot header at the beginning */
    .text ALIGN(4096) : {
        *(.multiboot)
        *(.text.boot)
        *(.text)
    }
    
    /* Read-only data section */
    .rodata ALIGN(4096) : {
        *(.rodata)
        *(.rodata.*)
    }
    
    /* Initialized data section */
    .data ALIGN(4096) : {
        *(.data)
        *(.data.*)
    }
    
    /* Uninitialized data section (zeroed at boot) */
    .bss ALIGN(4096) : {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        __bss_end = .;
    }
    
    /* End of kernel */
    __end = .;
}