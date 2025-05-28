/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */

#include "vga.h"

#if defined(ARCH_X86_64) || defined(ARCH_I386)

// VGA text mode buffer
static volatile uint16_t* vga_buffer = (uint16_t*)0xB8000;
static int vga_row = 0;
static int vga_col = 0;
static uint8_t vga_color = VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4);



static inline uint16_t vga_entry(unsigned char uc, uint8_t color) {
    return (uint16_t) uc | (uint16_t) color << 8;
}

void vga_init(void) {
    vga_row = 0;
    vga_col = 0;
    vga_color = VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4);
    
    // Clear screen
    for (int y = 0; y < VGA_HEIGHT; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            const int index = y * VGA_WIDTH + x;
            vga_buffer[index] = vga_entry(' ', vga_color);
        }
    }
}

void vga_set_color(uint8_t color) {
    vga_color = color;
}

void vga_putc(char c) {
    if (c == '\n') {
        vga_col = 0;
        if (++vga_row == VGA_HEIGHT) {
            // Scroll up
            for (int y = 0; y < VGA_HEIGHT - 1; y++) {
                for (int x = 0; x < VGA_WIDTH; x++) {
                    vga_buffer[y * VGA_WIDTH + x] = vga_buffer[(y + 1) * VGA_WIDTH + x];
                }
            }
            // Clear last line
            for (int x = 0; x < VGA_WIDTH; x++) {
                vga_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = vga_entry(' ', vga_color);
            }
            vga_row = VGA_HEIGHT - 1;
        }
    } else if (c == '\r') {
        vga_col = 0;
    } else {
        const int index = vga_row * VGA_WIDTH + vga_col;
        vga_buffer[index] = vga_entry(c, vga_color);
        if (++vga_col == VGA_WIDTH) {
            vga_col = 0;
            if (++vga_row == VGA_HEIGHT) {
                // Scroll up
                for (int y = 0; y < VGA_HEIGHT - 1; y++) {
                    for (int x = 0; x < VGA_WIDTH; x++) {
                        vga_buffer[y * VGA_WIDTH + x] = vga_buffer[(y + 1) * VGA_WIDTH + x];
                    }
                }
                // Clear last line
                for (int x = 0; x < VGA_WIDTH; x++) {
                    vga_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = vga_entry(' ', vga_color);
                }
                vga_row = VGA_HEIGHT - 1;
            }
        }
    }
}

void vga_puts(const char* str) {
    while (*str) {
        vga_putc(*str++);
    }
}

#endif // ARCH_X86_64 || ARCH_I386