// Serial port functions
static inline void outb(unsigned short port, unsigned char val) {
    asm volatile("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline unsigned char inb(unsigned short port) {
    unsigned char ret;
    asm volatile("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

void serial_putchar(char c) {
    // Wait for transmit buffer to be empty
    while ((inb(0x3F8 + 5) & 0x20) == 0);
    outb(0x3F8, c);
}

void serial_print(const char *str) {
    while (*str) {
        serial_putchar(*str++);
    }
}

// Kernel entry point
void kernel_main(void) {
    // Initialize serial port (COM1)
    outb(0x3F8 + 1, 0x00);    // Disable all interrupts
    outb(0x3F8 + 3, 0x80);    // Enable DLAB (set baud rate divisor)
    outb(0x3F8 + 0, 0x03);    // Set divisor to 3 (lo byte) 38400 baud
    outb(0x3F8 + 1, 0x00);    //                  (hi byte)
    outb(0x3F8 + 3, 0x03);    // 8 bits, no parity, one stop bit
    outb(0x3F8 + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
    outb(0x3F8 + 4, 0x0B);    // IRQs enabled, RTS/DSR set
    
    // Write to serial port
    serial_print("SAGE OS Minimal Kernel Starting...\r\n");
    
    // Write directly to VGA text buffer
    volatile char *video = (volatile char*)0xB8000;
    const char *message = "SAGE OS Minimal Kernel";
    
    // Clear screen
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        video[i] = ' ';
        video[i + 1] = 0x07; // White on black
    }
    
    // Write message
    for (int i = 0; message[i] != '\0'; i++) {
        video[i * 2] = message[i];
        video[i * 2 + 1] = 0x07; // White on black
    }
    
    serial_print("Kernel initialized successfully!\r\n");
    serial_print("Entering infinite loop...\r\n");
    
    // Infinite loop
    while (1) {
        asm volatile("hlt");
    }
}