ENTRY(_start)

SECTIONS
{
    /* Kernel starts at 1MB for x86_64 */
    . = 0x100000;
    
    __start = .;
    
    /* Multiboot header must be at the very beginning */
    .multiboot : ALIGN(4) {
        build/x86_64/boot/boot.o(.multiboot)
    }
    
    /* Boot section with startup code immediately after multiboot */
    .text.boot : {
        build/x86_64/boot/boot.o(.text.boot)
    }
    
    /* Regular text section */
    .text : {
        *(.text)
    }
    
    /* Read-only data section */
    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }
    
    /* Data section */
    .data : {
        *(.data)
        *(.data.*)
    }
    
    /* BSS section */
    .bss : {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        __bss_end = .;
    }
    
    __end = .;
}