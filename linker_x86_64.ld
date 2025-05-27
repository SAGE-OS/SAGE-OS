ENTRY(_start)

PHDRS
{
    text PT_LOAD FLAGS(5); /* Read + Execute */
    data PT_LOAD FLAGS(6); /* Read + Write */
}

SECTIONS
{
    /* Kernel starts at 1MB for x86_64 */
    . = 0x100000;
    
    __start = .;
    
    /* Multiboot header must be at the very beginning */
    .multiboot : ALIGN(4) {
        *(.multiboot)
    } :text
    
    /* Boot section with startup code immediately after multiboot */
    .text.boot : ALIGN(4) {
        *(.text.boot)
    } :text
    
    /* Regular text section */
    .text : {
        *(.text)
    } :text
    
    /* Read-only data section */
    .rodata : {
        *(.rodata)
        *(.rodata.*)
    } :text
    
    /* Initialized data section */
    .data : {
        *(.data)
        *(.data.*)
    } :data
    
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