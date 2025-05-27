/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */
#include "shell.h"
#include "../drivers/uart.h"
#include "memory.h"
#include "types.h"
#include "stdio.h"
#include "ai/ai_subsystem.h"

#define MAX_COMMAND_LENGTH 256
#define MAX_ARGS 16

// Shell prompt
static const char* PROMPT = "sage> ";

// Command history
#define HISTORY_SIZE 10
static char history[HISTORY_SIZE][MAX_COMMAND_LENGTH];
static int history_count = 0;
static int history_index = 0;

// Built-in commands
typedef void (*command_func_t)(int argc, char* argv[]);

typedef struct {
    const char* name;
    const char* description;
    command_func_t func;
} command_t;

// Forward declarations of command functions
static void cmd_help(int argc, char* argv[]);
static void cmd_echo(int argc, char* argv[]);
static void cmd_clear(int argc, char* argv[]);
static void cmd_meminfo(int argc, char* argv[]);
static void cmd_reboot(int argc, char* argv[]);
static void cmd_version(int argc, char* argv[]);
static void cmd_ai(int argc, char* argv[]);

// Command table
static const command_t commands[] = {
    {"help",    "Display help information",           cmd_help},
    {"echo",    "Echo arguments to the console",      cmd_echo},
    {"clear",   "Clear the screen",                   cmd_clear},
    {"meminfo", "Display memory information",         cmd_meminfo},
    {"reboot",  "Reboot the system",                  cmd_reboot},
    {"version", "Display OS version information",     cmd_version},
    {"ai",      "AI subsystem commands",              cmd_ai},
    {NULL, NULL, NULL}  // Terminator
};

// Initialize the shell
void shell_init() {
    uart_puts("SAGE OS Shell initialized\n");
    
    // Initialize AI subsystem
    ai_subsystem_status_t status = ai_subsystem_init();
    if (status == AI_SUBSYSTEM_SUCCESS) {
        uart_puts("AI subsystem initialized\n");
    } else {
        uart_puts("AI subsystem initialization failed\n");
    }
}

// Split a command into arguments
static int split_args(char* command, char* argv[], int max_args) {
    int argc = 0;
    char* token = command;
    char* end = command + strlen(command);
    
    // Skip leading whitespace
    while (*token && (*token == ' ' || *token == '\t')) {
        token++;
    }
    
    while (token < end && argc < max_args) {
        // Mark the start of the argument
        argv[argc++] = token;
        
        // Find the end of the argument
        while (*token && *token != ' ' && *token != '\t') {
            token++;
        }
        
        // Null-terminate the argument
        if (*token) {
            *token++ = '\0';
        }
        
        // Skip whitespace to the next argument
        while (*token && (*token == ' ' || *token == '\t')) {
            token++;
        }
    }
    
    return argc;
}

// Add a command to history
static void add_to_history(const char* command) {
    if (strlen(command) == 0) {
        return;  // Don't add empty commands to history
    }
    
    // Check if this command is the same as the last one
    if (history_count > 0 && strcmp(command, history[(history_index - 1) % HISTORY_SIZE]) == 0) {
        return;  // Don't add duplicate commands consecutively
    }
    
    // Use safe string copy with bounds checking
    strncpy(history[history_index], command, MAX_COMMAND_LENGTH - 1);
    history[history_index][MAX_COMMAND_LENGTH - 1] = '\0';  // Ensure null termination
    history_index = (history_index + 1) % HISTORY_SIZE;
    if (history_count < HISTORY_SIZE) {
        history_count++;
    }
}

// Process a command
void shell_process_command(const char* command) {
    char cmd_copy[MAX_COMMAND_LENGTH];
    strncpy(cmd_copy, command, MAX_COMMAND_LENGTH - 1);
    cmd_copy[MAX_COMMAND_LENGTH - 1] = '\0';
    
    // Add to history
    add_to_history(cmd_copy);
    
    // Split into arguments
    char* argv[MAX_ARGS];
    int argc = split_args(cmd_copy, argv, MAX_ARGS);
    
    if (argc == 0) {
        return;  // Empty command
    }
    
    // Find and execute the command
    for (int i = 0; commands[i].name != NULL; i++) {
        if (strcmp(argv[0], commands[i].name) == 0) {
            commands[i].func(argc, argv);
            return;
        }
    }
    
    // Command not found
    uart_printf("Unknown command: %s\n", argv[0]);
    uart_puts("Type 'help' for a list of commands\n");
}

// Run the shell (main loop)
void shell_run() {
    char command[MAX_COMMAND_LENGTH];
    int pos = 0;
    
    while (1) {
        // Display prompt
        uart_puts(PROMPT);
        
        // Reset command buffer
        memset(command, 0, MAX_COMMAND_LENGTH);
        pos = 0;
        
        // Read command
        while (1) {
            char c = uart_getc();
            
            if (c == '\r' || c == '\n') {
                // End of command
                uart_puts("\n");
                break;
            } else if (c == 8 || c == 127) {
                // Backspace
                if (pos > 0) {
                    pos--;
                    uart_puts("\b \b");  // Erase character
                }
            } else if (c >= ' ' && c <= '~' && pos < MAX_COMMAND_LENGTH - 1) {
                // Printable character
                command[pos++] = c;
                uart_putc(c);  // Echo
            }
        }
        
        command[pos] = '\0';  // Null-terminate
        
        // Process the command
        shell_process_command(command);
    }
}

// Command implementations

static void cmd_help(int argc, char* argv[]) {
    uart_puts("Available commands:\n");
    
    for (int i = 0; commands[i].name != NULL; i++) {
        uart_printf("  %-10s - %s\n", commands[i].name, commands[i].description);
    }
    
    // If ai command help is requested, show subcommands
    if (argc > 1 && strcmp(argv[1], "ai") == 0) {
        uart_puts("\nAI subsystem commands:\n");
        uart_puts("  ai info     - Display AI subsystem information\n");
        uart_puts("  ai temp     - Show AI HAT+ temperature\n");
        uart_puts("  ai power    - Show AI HAT+ power consumption\n");
        uart_puts("  ai models   - List loaded AI models\n");
    }
}

static void cmd_echo(int argc, char* argv[]) {
    for (int i = 1; i < argc; i++) {
        uart_puts(argv[i]);
        if (i < argc - 1) {
            uart_putc(' ');
        }
    }
    uart_putc('\n');
}

static void cmd_clear(int argc, char* argv[]) {
    // Clear screen (ANSI escape sequence)
    uart_puts("\033[2J\033[H");
}

static void cmd_meminfo(int argc, char* argv[]) {
    memory_stats();
}

static void cmd_reboot(int argc, char* argv[]) {
    uart_puts("Rebooting...\n");
    
    // Reset the system using the PM (Power Management) registers
    // This is specific to Raspberry Pi
    volatile uint32_t* PM_RSTC = (uint32_t*)0x3F10001C;
    volatile uint32_t* PM_WDOG = (uint32_t*)0x3F100024;
    
    // PM password
    const uint32_t PM_PASSWORD = 0x5A000000;
    const uint32_t PM_RSTC_WRCFG_FULL_RESET = 0x00000020;
    
    // Set watchdog timer
    *PM_WDOG = PM_PASSWORD | 1;
    *PM_RSTC = PM_PASSWORD | PM_RSTC_WRCFG_FULL_RESET;
    
    while (1) {
        // Wait for reset
    }
}

static void cmd_version(int argc, char* argv[]) {
    uart_puts("SAGE OS v0.1.0\n");
    uart_puts("Self-Aware General Environment Operating System\n");
    uart_puts("Copyright (c) 2025 SAGE OS Team\n");
}

// AI command handler
static void cmd_ai(int argc, char* argv[]) {
    if (argc < 2) {
        uart_puts("AI subsystem commands:\n");
        uart_puts("  info     - Display AI subsystem information\n");
        uart_puts("  temp     - Show AI HAT+ temperature\n");
        uart_puts("  power    - Show AI HAT+ power consumption\n");
        uart_puts("  models   - List loaded AI models\n");
        return;
    }
    
    if (strcmp(argv[1], "info") == 0) {
        ai_hat_info_t info;
        ai_subsystem_status_t status = ai_subsystem_get_info(&info);
        
        if (status == AI_SUBSYSTEM_SUCCESS) {
            uart_puts("AI Subsystem Information:\n");
            uart_printf("  Version: %d.%d\n", (info.version >> 8) & 0xFF, info.version & 0xFF);
            uart_printf("  Max TOPS: %d\n", info.max_tops);
            uart_printf("  Memory: %d MB\n", info.memory_size / (1024 * 1024));
            uart_printf("  Temperature: %d°C\n", info.temperature);
            uart_printf("  Power consumption: %d mW\n", info.power_consumption);
            
            const char* power_mode;
            switch (info.power_mode) {
                case AI_HAT_POWER_OFF:
                    power_mode = "Off";
                    break;
                case AI_HAT_POWER_LOW:
                    power_mode = "Low";
                    break;
                case AI_HAT_POWER_MEDIUM:
                    power_mode = "Medium";
                    break;
                case AI_HAT_POWER_HIGH:
                    power_mode = "High";
                    break;
                case AI_HAT_POWER_MAX:
                    power_mode = "Maximum";
                    break;
                default:
                    power_mode = "Unknown";
                    break;
            }
            uart_printf("  Power mode: %s\n", power_mode);
        } else {
            uart_puts("Failed to get AI subsystem information\n");
        }
    } else if (strcmp(argv[1], "temp") == 0) {
        uint32_t temperature;
        ai_subsystem_status_t status = ai_subsystem_get_temperature(&temperature);
        
        if (status == AI_SUBSYSTEM_SUCCESS) {
            uart_printf("AI HAT+ temperature: %d°C\n", temperature);
        } else {
            uart_puts("Failed to get AI HAT+ temperature\n");
        }
    } else if (strcmp(argv[1], "power") == 0) {
        uint32_t power;
        ai_subsystem_status_t status = ai_subsystem_get_power_consumption(&power);
        
        if (status == AI_SUBSYSTEM_SUCCESS) {
            uart_printf("AI HAT+ power consumption: %d mW\n", power);
        } else {
            uart_puts("Failed to get AI HAT+ power consumption\n");
        }
    } else if (strcmp(argv[1], "models") == 0) {
        ai_model_descriptor_t models[8];
        uint32_t num_models;
        ai_subsystem_status_t status = ai_subsystem_get_models(models, 8, &num_models);
        
        if (status == AI_SUBSYSTEM_SUCCESS) {
            if (num_models == 0) {
                uart_puts("No AI models loaded\n");
            } else {
                uart_printf("Loaded AI models (%d):\n", num_models);
                for (uint32_t i = 0; i < num_models; i++) {
                    uart_printf("  %d: %s (ID: %d)\n", i + 1, models[i].name, models[i].id);
                    
                    const char* type;
                    switch (models[i].type) {
                        case AI_MODEL_TYPE_CLASSIFICATION:
                            type = "Classification";
                            break;
                        case AI_MODEL_TYPE_DETECTION:
                            type = "Detection";
                            break;
                        case AI_MODEL_TYPE_SEGMENTATION:
                            type = "Segmentation";
                            break;
                        case AI_MODEL_TYPE_GENERATION:
                            type = "Generation";
                            break;
                        case AI_MODEL_TYPE_CUSTOM:
                            type = "Custom";
                            break;
                        default:
                            type = "Unknown";
                            break;
                    }
                    uart_printf("     Type: %s\n", type);
                    
                    const char* precision;
                    switch (models[i].precision) {
                        case AI_HAT_PRECISION_FP32:
                            precision = "FP32";
                            break;
                        case AI_HAT_PRECISION_FP16:
                            precision = "FP16";
                            break;
                        case AI_HAT_PRECISION_INT8:
                            precision = "INT8";
                            break;
                        case AI_HAT_PRECISION_INT4:
                            precision = "INT4";
                            break;
                        default:
                            precision = "Unknown";
                            break;
                    }
                    uart_printf("     Precision: %s\n", precision);
                    
                    uart_printf("     Input: [%d, %d, %d, %d]\n",
                               models[i].input_dims[0], models[i].input_dims[1],
                               models[i].input_dims[2], models[i].input_dims[3]);
                    uart_printf("     Output: [%d, %d, %d, %d]\n",
                               models[i].output_dims[0], models[i].output_dims[1],
                               models[i].output_dims[2], models[i].output_dims[3]);
                }
            }
        } else {
            uart_puts("Failed to get AI models\n");
        }
    } else {
        uart_printf("Unknown AI command: %s\n", argv[1]);
        uart_puts("Type 'ai' for a list of AI commands\n");
    }
}