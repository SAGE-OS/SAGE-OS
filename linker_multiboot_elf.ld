ENTRY(_start)

SECTIONS
{
    . = 0x100000;
    
    /* Multiboot header must be at the very beginning of the file */
    .multiboot ALIGN(4) : AT(0x0)
    {
        *(.multiboot)
    }
    
    /* Text section immediately after multiboot */
    .text ALIGN(4) :
    {
        *(.text)
    }
    
    .rodata ALIGN(4096) :
    {
        *(.rodata)
    }
    
    .data ALIGN(4096) :
    {
        *(.data)
    }
    
    .bss ALIGN(4096) :
    {
        *(COMMON)
        *(.bss)
    }
}