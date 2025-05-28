ENTRY(_start)

SECTIONS
{
    /* Kernel starts at 1MB for i386 multiboot */
    . = 0x100000;
    
    __start = .;
    
    /* Regular text section (includes multiboot header and boot code) */
    .text : {
        *(.multiboot)
        *(.text.boot)
        *(.text)
    }
    
    /* Read-only data section */
    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }
    
    /* Initialized data section */
    .data : {
        *(.data)
        *(.data.*)
    }
    
    /* Uninitialized data section (zeroed at boot) */
    .bss : {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        __bss_end = .;
    }
    
    /* End of kernel */
    __end = .;
}