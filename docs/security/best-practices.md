<!-- ─────────────────────────────────────────────────────────────────────────────
     SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
     SPDX-License-Identifier: BSD-3-Clause OR Proprietary
     SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
     
     This file is part of the SAGE OS Project.
     
     ─────────────────────────────────────────────────────────────────────────────
     Licensing:
     -----------
     
     Licensed under the BSD 3-Clause License or a Commercial License.
     You may use this file under the terms of either license as specified in:
     
        - BSD 3-Clause License (see ./LICENSE)
        - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)
     
     Redistribution and use in source and binary forms, with or without
     modification, are permitted under the BSD license provided that the
     following conditions are met:
     
       * Redistributions of source code must retain the above copyright
         notice, this list of conditions and the following disclaimer.
       * Redistributions in binary form must reproduce the above copyright
         notice, this list of conditions and the following disclaimer in the
         documentation and/or other materials provided with the distribution.
       * Neither the name of the project nor the names of its contributors
         may be used to endorse or promote products derived from this
         software without specific prior written permission.
     
     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
     IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
     PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
     OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
     EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
     PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
     PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
     LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
     NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
     SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
     
     By using this software, you agree to be bound by the terms of either license.
     
     Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.
     
     ─────────────────────────────────────────────────────────────────────────────
     Contributor Guidelines:
     ------------------------
     Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
     All contributors must certify that they have the right to submit the code and agree to
     release it under the above license terms.
     
     Contributions must:
       - Be original or appropriately attributed
       - Include clear documentation and test cases where applicable
       - Respect the coding and security guidelines defined in CONTRIBUTING.md
     
     ─────────────────────────────────────────────────────────────────────────────
     Terms of Use and Disclaimer:
     -----------------------------
     This software is provided "as is", without any express or implied warranty.
     In no event shall the authors, contributors, or copyright holders
     be held liable for any damages arising from the use of this software.
     
     Use of this software in critical systems (e.g., medical, nuclear, safety)
     is entirely at your own risk unless specifically licensed for such purposes.
     
     ─────────────────────────────────────────────────────────────────────────────
 -->


# SAGE OS Security Best Practices

## Introduction

This document outlines security best practices for developing, deploying, and maintaining SAGE OS. These guidelines help ensure the security and integrity of the operating system and applications running on it.

## Secure Development Practices

### Code Security

#### String Handling
```c
// ❌ Unsafe - Buffer overflow risk
strcpy(dest, src);
sprintf(buffer, format, data);

// ✅ Safe - Bounds checking
strncpy(dest, src, sizeof(dest) - 1);
dest[sizeof(dest) - 1] = '\0';
snprintf(buffer, sizeof(buffer), format, data);

// ✅ Best - Use safe alternatives
strcpy_safe(dest, src, sizeof(dest));
```

#### Memory Management
```c
// ✅ Always check allocation success
void* ptr = malloc(size);
if (ptr == NULL) {
    // Handle allocation failure
    return ERROR_OUT_OF_MEMORY;
}

// ✅ Clear sensitive data before freeing
memset(sensitive_data, 0, sizeof(sensitive_data));
free(sensitive_data);
sensitive_data = NULL;

// ✅ Avoid double-free vulnerabilities
if (ptr != NULL) {
    free(ptr);
    ptr = NULL;
}
```

#### Input Validation
```c
// ✅ Validate all inputs
int validate_input(const char* input, size_t max_len) {
    if (input == NULL) return -1;
    if (strlen(input) >= max_len) return -1;
    
    // Check for malicious characters
    for (size_t i = 0; input[i]; i++) {
        if (!isprint(input[i]) && !isspace(input[i])) {
            return -1;
        }
    }
    return 0;
}
```

### Error Handling

#### Secure Error Messages
```c
// ❌ Information disclosure
printf("Login failed for user %s with password %s", user, pass);

// ✅ Generic error messages
printf("Authentication failed");
log_security_event("Failed login attempt for user: %s", user);
```

#### Resource Cleanup
```c
// ✅ Always cleanup resources
int secure_function(void) {
    FILE* file = NULL;
    char* buffer = NULL;
    int result = -1;
    
    file = fopen("sensitive.dat", "r");
    if (!file) goto cleanup;
    
    buffer = malloc(BUFFER_SIZE);
    if (!buffer) goto cleanup;
    
    // Process data...
    result = 0;
    
cleanup:
    if (buffer) {
        memset(buffer, 0, BUFFER_SIZE);
        free(buffer);
    }
    if (file) fclose(file);
    return result;
}
```

## Cryptographic Security

### Key Management
```c
// ✅ Secure key generation
int generate_key(uint8_t* key, size_t key_len) {
    // Use hardware random number generator
    if (get_random_bytes(key, key_len) != 0) {
        return -1;
    }
    return 0;
}

// ✅ Secure key storage
typedef struct {
    uint8_t key[32];
    uint32_t usage_count;
    time_t created;
    time_t expires;
} secure_key_t;
```

### Encryption Best Practices
```c
// ✅ Use authenticated encryption
int encrypt_data(const uint8_t* plaintext, size_t len,
                 const uint8_t* key, uint8_t* ciphertext,
                 uint8_t* tag) {
    // Use AES-GCM or ChaCha20-Poly1305
    return aes_gcm_encrypt(plaintext, len, key, ciphertext, tag);
}
```

## Access Control

### Privilege Separation
```c
// ✅ Drop privileges after initialization
int drop_privileges(void) {
    if (setuid(getuid()) != 0) {
        return -1;
    }
    if (setgid(getgid()) != 0) {
        return -1;
    }
    return 0;
}
```

### Resource Limits
```c
// ✅ Set resource limits
int set_security_limits(void) {
    struct rlimit limit;
    
    // Limit memory usage
    limit.rlim_cur = MAX_MEMORY;
    limit.rlim_max = MAX_MEMORY;
    if (setrlimit(RLIMIT_AS, &limit) != 0) {
        return -1;
    }
    
    // Limit file descriptors
    limit.rlim_cur = MAX_FDS;
    limit.rlim_max = MAX_FDS;
    if (setrlimit(RLIMIT_NOFILE, &limit) != 0) {
        return -1;
    }
    
    return 0;
}
```

## Network Security

### Secure Communication
```c
// ✅ Use TLS for network communication
int secure_connect(const char* hostname, int port) {
    SSL_CTX* ctx = SSL_CTX_new(TLS_client_method());
    if (!ctx) return -1;
    
    // Set minimum TLS version
    SSL_CTX_set_min_proto_version(ctx, TLS1_2_VERSION);
    
    // Verify certificates
    SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, NULL);
    
    return establish_connection(ctx, hostname, port);
}
```

### Input Sanitization
```c
// ✅ Sanitize network input
int process_network_data(const uint8_t* data, size_t len) {
    if (len > MAX_PACKET_SIZE) {
        log_security_event("Oversized packet received");
        return -1;
    }
    
    // Validate packet structure
    if (!validate_packet_format(data, len)) {
        return -1;
    }
    
    return process_packet(data, len);
}
```

## Logging and Monitoring

### Security Logging
```c
// ✅ Comprehensive security logging
void log_security_event(const char* event, ...) {
    va_list args;
    char buffer[1024];
    time_t now = time(NULL);
    
    va_start(args, event);
    vsnprintf(buffer, sizeof(buffer), event, args);
    va_end(args);
    
    // Log to secure audit trail
    audit_log(LOG_SECURITY, now, buffer);
    
    // Alert on critical events
    if (is_critical_event(event)) {
        send_security_alert(buffer);
    }
}
```

### Anomaly Detection
```c
// ✅ Monitor for suspicious activity
int monitor_system_calls(void) {
    static uint32_t call_counts[MAX_SYSCALLS];
    static time_t last_reset = 0;
    time_t now = time(NULL);
    
    // Reset counters periodically
    if (now - last_reset > MONITOR_INTERVAL) {
        memset(call_counts, 0, sizeof(call_counts));
        last_reset = now;
    }
    
    // Check for anomalies
    for (int i = 0; i < MAX_SYSCALLS; i++) {
        if (call_counts[i] > THRESHOLD[i]) {
            log_security_event("Syscall %d threshold exceeded", i);
            return -1;
        }
    }
    
    return 0;
}
```

## Build Security

### Compiler Security Flags
```makefile
# Enable security features
SECURITY_FLAGS = -fstack-protector-strong \
                 -D_FORTIFY_SOURCE=2 \
                 -fPIE \
                 -Wformat-security \
                 -Werror=format-security

# Enable all warnings
WARNING_FLAGS = -Wall -Wextra -Werror \
                -Wno-unused-parameter \
                -Wno-unused-variable

CFLAGS += $(SECURITY_FLAGS) $(WARNING_FLAGS)
```

### Static Analysis
```bash
#!/bin/bash
# Run static analysis tools

# Clang Static Analyzer
scan-build make

# Cppcheck
cppcheck --enable=all --error-exitcode=1 src/

# Custom security scanner
python3 security-scanner.py src/
```

## Testing Security

### Unit Tests
```c
// ✅ Test security functions
void test_strcpy_safe(void) {
    char dest[10];
    const char* src = "Hello, World!";  // Longer than dest
    
    // Should truncate and null-terminate
    char* result = strcpy_safe(dest, src, sizeof(dest));
    assert(result != NULL);
    assert(strlen(dest) == sizeof(dest) - 1);
    assert(dest[sizeof(dest) - 1] == '\0');
}
```

### Fuzzing
```c
// ✅ Fuzz test critical functions
void fuzz_input_parser(void) {
    for (int i = 0; i < 10000; i++) {
        uint8_t* random_data = generate_random_data(1024);
        
        // Should not crash or leak memory
        int result = parse_input(random_data, 1024);
        
        free(random_data);
    }
}
```

## Deployment Security

### System Hardening
```bash
#!/bin/bash
# System hardening script

# Disable unnecessary services
systemctl disable telnet
systemctl disable ftp

# Set secure permissions
chmod 600 /etc/shadow
chmod 644 /etc/passwd

# Configure firewall
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
```

### Configuration Management
```yaml
# Secure configuration template
security:
  authentication:
    min_password_length: 12
    require_special_chars: true
    max_login_attempts: 3
    lockout_duration: 300
  
  encryption:
    algorithm: "AES-256-GCM"
    key_rotation_interval: 86400
    
  logging:
    level: "INFO"
    audit_enabled: true
    retention_days: 90
```

## Incident Response

### Detection
```c
// ✅ Automated threat detection
int detect_intrusion(void) {
    // Check for suspicious patterns
    if (check_failed_logins() > MAX_FAILED_LOGINS) {
        trigger_security_alert("Multiple failed logins detected");
        return 1;
    }
    
    if (check_unusual_network_activity()) {
        trigger_security_alert("Unusual network activity detected");
        return 1;
    }
    
    return 0;
}
```

### Response
```c
// ✅ Automated response actions
void respond_to_threat(threat_type_t threat) {
    switch (threat) {
        case THREAT_BRUTE_FORCE:
            block_source_ip();
            increase_monitoring();
            break;
            
        case THREAT_MALWARE:
            isolate_system();
            scan_for_malware();
            break;
            
        case THREAT_DATA_BREACH:
            revoke_access_tokens();
            notify_security_team();
            break;
    }
}
```

## Security Checklist

### Development Phase
- [ ] Input validation implemented
- [ ] Safe string functions used
- [ ] Memory management secure
- [ ] Error handling comprehensive
- [ ] Cryptography properly implemented
- [ ] Access controls enforced

### Testing Phase
- [ ] Unit tests for security functions
- [ ] Integration tests completed
- [ ] Penetration testing performed
- [ ] Fuzzing tests executed
- [ ] Static analysis clean
- [ ] Dynamic analysis clean

### Deployment Phase
- [ ] System hardened
- [ ] Monitoring configured
- [ ] Logging enabled
- [ ] Backup procedures tested
- [ ] Incident response plan ready
- [ ] Security training completed

## References

- [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)
- [CERT C Coding Standard](https://wiki.sei.cmu.edu/confluence/display/c/SEI+CERT+C+Coding+Standard)

---

**Last Updated**: 2025-05-27  
**Version**: 1.0.0  
**Approved By**: Security Team