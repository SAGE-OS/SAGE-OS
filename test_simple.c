// Simple test kernel for debugging
static void serial_putc(char c) {
    // Wait for transmit buffer to be empty
    while (!(*(volatile unsigned char*)0x3FD & 0x20));
    // Send character
    *(volatile unsigned char*)0x3F8 = c;
}

static void serial_puts(const char* str) {
    while (*str) {
        serial_putc(*str++);
    }
}

void kernel_main(void) {
    // Initialize serial port (COM1)
    *(volatile unsigned char*)0x3F9 = 0x00;    // Disable all interrupts
    *(volatile unsigned char*)0x3FB = 0x80;    // Enable DLAB (set baud rate divisor)
    *(volatile unsigned char*)0x3F8 = 0x03;    // Set divisor to 3 (lo byte) 38400 baud
    *(volatile unsigned char*)0x3F9 = 0x00;    //                  (hi byte)
    *(volatile unsigned char*)0x3FB = 0x03;    // 8 bits, no parity, one stop bit
    *(volatile unsigned char*)0x3FC = 0x0B;    // IRQs enabled, RTS/DSR set
    *(volatile unsigned char*)0x3FE = 0x0F;    // Enable in loopback mode, test the serial chip
    
    // Test serial
    *(volatile unsigned char*)0x3F8 = 0xAE;    // Test serial chip (send byte 0xAE and check if serial returns same byte)
    if(*(volatile unsigned char*)0x3F8 != 0xAE) {
        // Serial is faulty
        while(1) asm volatile("hlt");
    }
    
    // Serial is not faulty set it in normal operation mode
    *(volatile unsigned char*)0x3FE = 0x0F;
    
    serial_puts("SAGE OS KERNEL STARTED!\r\n");
    serial_puts("Simple test kernel is running...\r\n");
    
    // Also write to VGA for good measure
    volatile char* video = (volatile char*)0xB8000;
    const char* message = "SAGE OS BOOTED!";
    
    // Clear screen first
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        video[i] = ' ';
        video[i + 1] = 0x07; // White on black
    }
    
    // Write message
    for (int i = 0; message[i] != '\0'; i++) {
        video[i * 2] = message[i];
        video[i * 2 + 1] = 0x07; // White on black
    }
    
    serial_puts("Entering halt loop...\r\n");
    
    // Halt
    while (1) {
        asm volatile("hlt");
    }
}