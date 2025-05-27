ENTRY(_start)

SECTIONS
{
    /* Start at 1MB */
    . = 0x100000;
    
    /* Multiboot header at fixed file offset within first 8KB */
    .multiboot . : AT(0x1000) {
        *(.multiboot)
    }
    
    /* Text section */
    .text . : {
        *(.text)
    }
    
    /* Read-only data */
    .rodata . : {
        *(.rodata)
        *(.rodata.*)
    }
    
    /* Data section */
    .data . : {
        *(.data)
        *(.data.*)
    }
    
    /* BSS section */
    .bss . : {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        __bss_end = .;
    }
}