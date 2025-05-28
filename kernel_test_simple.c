/* Simple test kernel to isolate the hang issue */

// Direct hardware access functions
static inline void outb(unsigned short port, unsigned char data) {
    asm volatile("outb %0, %1" : : "a"(data), "Nd"(port));
}

static inline unsigned char inb(unsigned short port) {
    unsigned char data;
    asm volatile("inb %1, %0" : "=a"(data) : "Nd"(port));
    return data;
}

// Simple serial output
void simple_serial_init() {
    outb(0x3F8 + 1, 0x00);    // Disable all interrupts
    outb(0x3F8 + 3, 0x80);    // Enable DLAB (set baud rate divisor)
    outb(0x3F8 + 0, 0x03);    // Set divisor to 3 (lo byte) 38400 baud
    outb(0x3F8 + 1, 0x00);    //                  (hi byte)
    outb(0x3F8 + 3, 0x03);    // 8 bits, no parity, one stop bit
    outb(0x3F8 + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
    outb(0x3F8 + 4, 0x0B);    // IRQs enabled, RTS/DSR set
}

void simple_serial_putc(char c) {
    while ((inb(0x3F8 + 5) & 0x20) == 0);
    outb(0x3F8, c);
}

void simple_serial_puts(const char* str) {
    while (*str) {
        simple_serial_putc(*str++);
    }
}

// Kernel entry point
void kernel_main() {
    simple_serial_init();
    simple_serial_puts("SAGE OS: Simple test kernel starting...\n");
    
    simple_serial_puts("  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗\n");
    simple_serial_puts("  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝\n");
    simple_serial_puts("  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗\n");
    simple_serial_puts("  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║\n");
    simple_serial_puts("  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║\n");
    simple_serial_puts("  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝\n");
    simple_serial_puts("\n");
    simple_serial_puts("        Self-Aware General Environment Operating System\n");
    simple_serial_puts("                    Version 1.0.0\n");
    simple_serial_puts("                 Designed by Ashish Yesale\n");
    simple_serial_puts("\n");
    simple_serial_puts("================================================================\n");
    simple_serial_puts("  Welcome to SAGE OS - The Future of Self-Evolving Systems\n");
    simple_serial_puts("================================================================\n\n");
    
    simple_serial_puts("System ready! Entering infinite loop...\n");
    
    while (1) {
        asm volatile("hlt");
    }
}