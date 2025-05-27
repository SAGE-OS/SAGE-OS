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

#include "stdio.h"

// String length
size_t strlen(const char* str) {
    size_t len = 0;
    while (str[len]) {
        len++;
    }
    return len;
}

// String comparison
int strcmp(const char* str1, const char* str2) {
    while (*str1 && (*str1 == *str2)) {
        str1++;
        str2++;
    }
    return *(unsigned char*)str1 - *(unsigned char*)str2;
}

// String copy - DEPRECATED: Use strcpy_safe instead
char* strcpy(char* dest, const char* src) {
    char* original_dest = dest;
    while ((*dest++ = *src++));
    return original_dest;
}

// Safe string copy with bounds checking
char* strcpy_safe(char* dest, const char* src, size_t dest_size) {
    if (dest == NULL || src == NULL || dest_size == 0) {
        return NULL;
    }
    
    size_t i;
    for (i = 0; i < dest_size - 1 && src[i] != '\0'; i++) {
        dest[i] = src[i];
    }
    dest[i] = '\0';  // Ensure null termination
    return dest;
}

// String copy with limit
char* strncpy(char* dest, const char* src, size_t n) {
    size_t i;
    for (i = 0; i < n && src[i] != '\0'; i++) {
        dest[i] = src[i];
    }
    for (; i < n; i++) {
        dest[i] = '\0';
    }
    return dest;
}

// Memory set
void* memset(void* ptr, int value, size_t num) {
    unsigned char* p = (unsigned char*)ptr;
    while (num--) {
        *p++ = (unsigned char)value;
    }
    return ptr;
}

// Memory copy
void* memcpy(void* dest, const void* src, size_t n) {
    char* d = (char*)dest;
    const char* s = (const char*)src;
    
    for (size_t i = 0; i < n; i++) {
        d[i] = s[i];
    }
    
    return dest;
}

// Simple sprintf implementation
int sprintf(char* str, const char* format, ...) {
    // Very basic implementation - just copy format string for now
    // In a real implementation, this would handle format specifiers
    int i = 0;
    while (format[i]) {
        str[i] = format[i];
        i++;
    }
    str[i] = '\0';
    return i;
}

// Safe sprintf implementation with bounds checking
int snprintf(char* str, size_t size, const char* format, ...) {
    if (str == NULL || size == 0) {
        return 0;
    }
    
    // Very basic implementation - just copy format string for now
    // In a real implementation, this would handle format specifiers
    size_t i = 0;
    while (format[i] && i < size - 1) {
        str[i] = format[i];
        i++;
    }
    str[i] = '\0';
    return (int)i;
}