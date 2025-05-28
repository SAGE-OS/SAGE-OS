/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 *
 * ───────────────────────────────────────────────────────────────────────────── */
// Licensing:
// -----------
//                                 
//                                                                             
//   Licensed under the BSD 3-Clause License or a Commercial License.          
//   You may use this file under the terms of either license as specified in: 
//                                                                             
//      - BSD 3-Clause License (see ./LICENSE)                           
//      - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
//                                                                             
//   Redistribution and use in source and binary forms, with or without       
//   modification, are permitted under the BSD license provided that the      
//   following conditions are met:                                            
//                                                                             
//     * Redistributions of source code must retain the above copyright       
//       notice, this list of conditions and the following disclaimer.       
//     * Redistributions in binary form must reproduce the above copyright    
//       notice, this list of conditions and the following disclaimer in the  
//       documentation and/or other materials provided with the distribution. 
//     * Neither the name of the project nor the names of its contributors    
//       may be used to endorse or promote products derived from this         
//       software without specific prior written permission.                  
//                                                                             
//   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
//   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
//   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
//   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
//   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
//   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
//   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
//   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
//   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
//   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
//   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
//
// By using this software, you agree to be bound by the terms of either license.
//
// Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.
//
/* ─────────────────────────────────────────────────────────────────────────────
 * Contributor Guidelines:
 * ------------------------
 * Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
 * All contributors must certify that they have the right to submit the code and agree to
 * release it under the above license terms.
 *
 * Contributions must:
 *   - Be original or appropriately attributed
 *   - Include clear documentation and test cases where applicable
 *   - Respect the coding and security guidelines defined in CONTRIBUTING.md
 *
 * ───────────────────────────────────────────────────────────────────────────── */
// Terms of Use and Disclaimer:
// -----------------------------
// This software is provided "as is", without any express or implied warranty.
// In no event shall the authors, contributors, or copyright holders
// be held liable for any damages arising from the use of this software.
//
// Use of this software in critical systems (e.g., medical, nuclear, safety)
// is entirely at your own risk unless specifically licensed for such purposes.
//

#include "uart.h"

#ifdef ARCH_X86_64
#include "serial.h"
#include "vga.h"
#elif defined(ARCH_I386)
#include "serial.h"
#include "vga.h"
#endif
#include <stdarg.h>
#include <stdint.h>

#if defined(__x86_64__) || defined(__i386__)
// x86 I/O port functions
static inline void outb(uint16_t port, uint8_t value) {
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}
#endif

// Memory-Mapped I/O addresses for Raspberry Pi
#define MMIO_BASE       0x3F000000  // For Raspberry Pi 3/4
// #define MMIO_BASE     0xFE000000  // For Raspberry Pi 5

// UART registers
#define UART0_DR        ((volatile unsigned int*)(MMIO_BASE + 0x00201000))
#define UART0_FR        ((volatile unsigned int*)(MMIO_BASE + 0x00201018))
#define UART0_IBRD      ((volatile unsigned int*)(MMIO_BASE + 0x00201024))
#define UART0_FBRD      ((volatile unsigned int*)(MMIO_BASE + 0x00201028))
#define UART0_LCRH      ((volatile unsigned int*)(MMIO_BASE + 0x0020102C))
#define UART0_CR        ((volatile unsigned int*)(MMIO_BASE + 0x00201030))
#define UART0_IMSC      ((volatile unsigned int*)(MMIO_BASE + 0x00201038))
#define UART0_ICR       ((volatile unsigned int*)(MMIO_BASE + 0x00201044))

// GPIO registers
#define GPFSEL1         ((volatile unsigned int*)(MMIO_BASE + 0x00200004))
#define GPPUD           ((volatile unsigned int*)(MMIO_BASE + 0x00200094))
#define GPPUDCLK0       ((volatile unsigned int*)(MMIO_BASE + 0x00200098))

// Initialize UART
void uart_init() {
#if defined(ARCH_X86_64) || defined(ARCH_I386)
    // Initialize VGA and serial for x86 platforms
    vga_init();
    serial_init();
#else
    // ARM/RISC-V initialization
    // Disable UART0
    *UART0_CR = 0;

    // Setup GPIO pins 14 and 15
    unsigned int selector = *GPFSEL1;
    selector &= ~((7 << 12) | (7 << 15)); // Clear bits 12-14 (GPIO14) and 15-17 (GPIO15)
    selector |= (4 << 12) | (4 << 15);    // Set bits 12-14 (GPIO14) and 15-17 (GPIO15) to alternative function 0 (UART)
    *GPFSEL1 = selector;

    // Disable pull-up/down
    *GPPUD = 0;
    
    // Wait 150 cycles
    for (volatile int i = 0; i < 150; i++) { }
    
    // Clock the control signal into the GPIO pads
    *GPPUDCLK0 = (1 << 14) | (1 << 15);
    
    // Wait 150 cycles
    for (volatile int i = 0; i < 150; i++) { }
    
    // Remove the clock
    *GPPUDCLK0 = 0;

    // Clear interrupts
    *UART0_ICR = 0x7FF;

    // Set baud rate to 115200
    // Baud rate divisor = UART clock / (16 * baud rate)
    // UART clock = 48MHz, baud rate = 115200
    // Divisor = 48000000 / (16 * 115200) = 26.0416...
    // Integer part = 26
    // Fractional part = 0.0416... * 64 = 2.66... ~ 3
    *UART0_IBRD = 26;
    *UART0_FBRD = 3;

    // Enable FIFO, 8-bit data, 1 stop bit, no parity
    *UART0_LCRH = (1 << 4) | (1 << 5) | (1 << 6);

    // Enable UART0, receive and transmit
    *UART0_CR = (1 << 0) | (1 << 8) | (1 << 9);
#endif
}

// Send a character
void uart_putc(unsigned char c) {
#if defined(ARCH_X86_64) || defined(ARCH_I386)
    // Output to both VGA and serial for x86 platforms
    vga_putc(c);
    serial_putc(c);
#else
    // ARM/RISC-V output
    // Wait until transmit FIFO is not full
    while (*UART0_FR & (1 << 5)) { }
    
    // Write the character to the data register
    *UART0_DR = c;
    
    // If it's a newline, also send a carriage return
    if (c == '\n') {
        uart_putc('\r');
    }
#endif
}

// Receive a character
unsigned char uart_getc() {
#if defined(__x86_64__) || defined(__i386__)
    // x86 serial port input (COM1 - 0x3F8)
    // Wait until data is available
    while (!(inb(0x3F8 + 5) & 1)) { }
    
    // Read the character from the data register
    return inb(0x3F8);
#else
    // ARM UART input
    // Wait until receive FIFO is not empty
    while (*UART0_FR & (1 << 4)) { }
    
    // Read the character from the data register
    return *UART0_DR;
#endif
}

// Send a string
void uart_puts(const char* str) {
    while (*str) {
        uart_putc(*str++);
    }
}

// Simple printf implementation
void uart_printf(const char* format, ...) {
    va_list args;
    va_start(args, format);
    
    char buffer[256];
    int len = 0;
    
    while (*format && len < 255) {
        if (*format == '%') {
            format++;
            switch (*format) {
                case 's': {
                    const char* str = va_arg(args, const char*);
                    while (*str && len < 255) {
                        buffer[len++] = *str++;
                    }
                    break;
                }
                case 'd': {
                    int num = va_arg(args, int);
                    if (num < 0) {
                        buffer[len++] = '-';
                        num = -num;
                    }
                    char temp[16];
                    int i = 0;
                    do {
                        temp[i++] = '0' + (num % 10);
                        num /= 10;
                    } while (num > 0);
                    while (i > 0 && len < 255) {
                        buffer[len++] = temp[--i];
                    }
                    break;
                }
                case 'c': {
                    char c = (char)va_arg(args, int);
                    buffer[len++] = c;
                    break;
                }
                default:
                    buffer[len++] = *format;
                    break;
            }
        } else {
            buffer[len++] = *format;
        }
        format++;
    }
    
    buffer[len] = '\0';
    uart_puts(buffer);
    
    va_end(args);
}