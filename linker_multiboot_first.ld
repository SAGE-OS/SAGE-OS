ENTRY(_start)

SECTIONS
{
    /* Start at 1MB */
    . = 0x100000;
    
    /* Multiboot header must be first and within first 8KB */
    .multiboot ALIGN(4) : {
        *(.multiboot)
    }
    
    /* Text section immediately after multiboot */
    .text ALIGN(4) : {
        *(.text)
    }
    
    /* Read-only data */
    .rodata ALIGN(4) : {
        *(.rodata)
        *(.rodata.*)
    }
    
    /* Data section */
    .data ALIGN(4) : {
        *(.data)
        *(.data.*)
    }
    
    /* BSS section */
    .bss ALIGN(4) : {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        __bss_end = .;
    }
}