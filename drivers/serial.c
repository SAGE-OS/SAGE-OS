/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */

#include "serial.h"

#if defined(__x86_64__) || defined(__i386__)

// COM1 port base address
#define COM1_PORT 0x3F8

// Port offsets
#define DATA_PORT        0  // Data register
#define INT_ENABLE_PORT  1  // Interrupt enable register
#define FIFO_CTRL_PORT   2  // FIFO control register
#define LINE_CTRL_PORT   3  // Line control register
#define MODEM_CTRL_PORT  4  // Modem control register
#define LINE_STATUS_PORT 5  // Line status register

// I/O port functions
static inline void outb(uint16_t port, uint8_t value) {
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

void serial_init(void) {
    // Disable interrupts
    outb(COM1_PORT + INT_ENABLE_PORT, 0x00);
    
    // Enable DLAB (set baud rate divisor)
    outb(COM1_PORT + LINE_CTRL_PORT, 0x80);
    
    // Set divisor to 3 (38400 baud)
    outb(COM1_PORT + DATA_PORT, 0x03);
    outb(COM1_PORT + INT_ENABLE_PORT, 0x00);
    
    // 8 bits, no parity, one stop bit
    outb(COM1_PORT + LINE_CTRL_PORT, 0x03);
    
    // Enable FIFO, clear them, with 14-byte threshold
    outb(COM1_PORT + FIFO_CTRL_PORT, 0xC7);
    
    // IRQs enabled, RTS/DSR set
    outb(COM1_PORT + MODEM_CTRL_PORT, 0x0B);
}

static int is_transmit_empty(void) {
    return inb(COM1_PORT + LINE_STATUS_PORT) & 0x20;
}

void serial_putc(char c) {
    while (is_transmit_empty() == 0);
    outb(COM1_PORT + DATA_PORT, c);
}

void serial_puts(const char* str) {
    while (*str) {
        serial_putc(*str);
        if (*str == '\n') {
            serial_putc('\r');
        }
        str++;
    }
}

#endif // __x86_64__ || __i386__