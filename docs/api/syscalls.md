# SAGE OS System Call API Reference

## 📡 System Call Interface

SAGE OS provides a comprehensive system call interface for user applications to interact with the kernel and hardware resources.

## 🏗️ System Call Architecture

### System Call Mechanism
```c
// System call invocation mechanism
#define SYSCALL_0(num) \
    asm volatile("int $0x80" : "=a"(ret) : "a"(num) : "memory")

#define SYSCALL_1(num, arg1) \
    asm volatile("int $0x80" : "=a"(ret) : "a"(num), "b"(arg1) : "memory")

#define SYSCALL_3(num, arg1, arg2, arg3) \
    asm volatile("int $0x80" : "=a"(ret) : "a"(num), "b"(arg1), "c"(arg2), "d"(arg3) : "memory")
```

### System Call Numbers
```c
// System call numbers (sage-sdk/include/syscalls.h)
#define SYS_EXIT        1
#define SYS_FORK        2
#define SYS_READ        3
#define SYS_WRITE       4
#define SYS_OPEN        5
#define SYS_CLOSE       6
#define SYS_GETPID      20
#define SYS_MMAP        90
#define SYS_MUNMAP      91

// AI-specific system calls
#define SYS_AI_LOAD_MODEL    200
#define SYS_AI_UNLOAD_MODEL  201
#define SYS_AI_INFERENCE     202
#define SYS_AI_GET_INFO      203

// Hardware-specific system calls
#define SYS_AI_HAT_INIT      210
#define SYS_AI_HAT_STATUS    211
#define SYS_UART_WRITE       220
#define SYS_UART_READ        221
```

## 📋 Core System Calls

### Process Management

#### sys_exit - Terminate Process
```c
void sys_exit(int status);
```
**Description**: Terminates the calling process with the specified exit status.

**Parameters**:
- `status`: Exit status code (0 = success, non-zero = error)

**Return Value**: Does not return

**Example**:
```c
#include <syscalls.h>

int main() {
    printf("Hello, SAGE OS!\n");
    sys_exit(0);  // Successful termination
}
```

#### sys_fork - Create New Process
```c
pid_t sys_fork(void);
```
**Description**: Creates a new process by duplicating the calling process.

**Return Value**:
- `0`: In child process
- `> 0`: Process ID of child (in parent)
- `< 0`: Error occurred

**Example**:
```c
#include <syscalls.h>

int main() {
    pid_t pid = sys_fork();
    
    if (pid == 0) {
        // Child process
        printf("I'm the child process\n");
    } else if (pid > 0) {
        // Parent process
        printf("Child PID: %d\n", pid);
    } else {
        // Error
        printf("Fork failed\n");
    }
    
    return 0;
}
```

#### sys_getpid - Get Process ID
```c
pid_t sys_getpid(void);
```
**Description**: Returns the process ID of the calling process.

**Return Value**: Process ID (always positive)

**Example**:
```c
#include <syscalls.h>

int main() {
    pid_t my_pid = sys_getpid();
    printf("My process ID is: %d\n", my_pid);
    return 0;
}
```

### File I/O Operations

#### sys_open - Open File
```c
int sys_open(const char* pathname, int flags);
```
**Description**: Opens a file and returns a file descriptor.

**Parameters**:
- `pathname`: Path to the file
- `flags`: Open flags (O_RDONLY, O_WRONLY, O_RDWR, O_CREAT, etc.)

**Return Value**:
- `>= 0`: File descriptor
- `< 0`: Error code

**Example**:
```c
#include <syscalls.h>

int main() {
    int fd = sys_open("/dev/uart0", O_RDWR);
    if (fd < 0) {
        printf("Failed to open UART\n");
        return -1;
    }
    
    // Use file descriptor...
    sys_close(fd);
    return 0;
}
```

#### sys_read - Read from File
```c
ssize_t sys_read(int fd, void* buf, size_t count);
```
**Description**: Reads data from a file descriptor.

**Parameters**:
- `fd`: File descriptor
- `buf`: Buffer to store read data
- `count`: Maximum number of bytes to read

**Return Value**:
- `> 0`: Number of bytes read
- `0`: End of file
- `< 0`: Error code

**Example**:
```c
#include <syscalls.h>

int main() {
    char buffer[256];
    ssize_t bytes_read = sys_read(0, buffer, sizeof(buffer) - 1);
    
    if (bytes_read > 0) {
        buffer[bytes_read] = '\0';
        printf("Read: %s\n", buffer);
    }
    
    return 0;
}
```

#### sys_write - Write to File
```c
ssize_t sys_write(int fd, const void* buf, size_t count);
```
**Description**: Writes data to a file descriptor.

**Parameters**:
- `fd`: File descriptor
- `buf`: Buffer containing data to write
- `count`: Number of bytes to write

**Return Value**:
- `>= 0`: Number of bytes written
- `< 0`: Error code

**Example**:
```c
#include <syscalls.h>

int main() {
    const char* message = "Hello, SAGE OS!\n";
    ssize_t bytes_written = sys_write(1, message, strlen(message));
    
    if (bytes_written < 0) {
        printf("Write failed\n");
        return -1;
    }
    
    return 0;
}
```

#### sys_close - Close File
```c
int sys_close(int fd);
```
**Description**: Closes a file descriptor.

**Parameters**:
- `fd`: File descriptor to close

**Return Value**:
- `0`: Success
- `< 0`: Error code

**Example**:
```c
#include <syscalls.h>

int main() {
    int fd = sys_open("/dev/uart0", O_RDWR);
    if (fd >= 0) {
        // Use file descriptor...
        
        int result = sys_close(fd);
        if (result < 0) {
            printf("Failed to close file\n");
        }
    }
    
    return 0;
}
```

### Memory Management

#### sys_mmap - Map Memory
```c
void* sys_mmap(void* addr, size_t length, int prot, int flags);
```
**Description**: Maps memory into the process address space.

**Parameters**:
- `addr`: Preferred address (can be NULL)
- `length`: Size of mapping in bytes
- `prot`: Protection flags (PROT_READ, PROT_WRITE, PROT_EXEC)
- `flags`: Mapping flags (MAP_PRIVATE, MAP_SHARED, MAP_ANONYMOUS)

**Return Value**:
- Valid pointer: Success
- `MAP_FAILED`: Error

**Example**:
```c
#include <syscalls.h>

int main() {
    size_t size = 4096;  // One page
    void* memory = sys_mmap(NULL, size, PROT_READ | PROT_WRITE, 
                           MAP_PRIVATE | MAP_ANONYMOUS);
    
    if (memory == MAP_FAILED) {
        printf("Memory mapping failed\n");
        return -1;
    }
    
    // Use memory...
    memset(memory, 0, size);
    
    // Unmap when done
    sys_munmap(memory, size);
    return 0;
}
```

#### sys_munmap - Unmap Memory
```c
int sys_munmap(void* addr, size_t length);
```
**Description**: Unmaps memory from the process address space.

**Parameters**:
- `addr`: Address to unmap
- `length`: Size of mapping to unmap

**Return Value**:
- `0`: Success
- `< 0`: Error code

## 🤖 AI System Calls

### AI Model Management

#### sys_ai_load_model - Load AI Model
```c
int sys_ai_load_model(const char* model_path);
```
**Description**: Loads an AI model from file into the kernel AI subsystem.

**Parameters**:
- `model_path`: Path to the model file (.tflite, .onnx, etc.)

**Return Value**:
- `>= 0`: Model handle/ID
- `< 0`: Error code

**Example**:
```c
#include <syscalls.h>

int main() {
    int model_id = sys_ai_load_model("/models/image_classifier.tflite");
    if (model_id < 0) {
        printf("Failed to load AI model\n");
        return -1;
    }
    
    printf("Model loaded with ID: %d\n", model_id);
    
    // Use model for inference...
    
    // Unload when done
    sys_ai_unload_model(model_id);
    return 0;
}
```

#### sys_ai_unload_model - Unload AI Model
```c
int sys_ai_unload_model(int model_id);
```
**Description**: Unloads an AI model from memory.

**Parameters**:
- `model_id`: Model handle returned by sys_ai_load_model

**Return Value**:
- `0`: Success
- `< 0`: Error code

#### sys_ai_inference - Run AI Inference
```c
int sys_ai_inference(int model_id, const void* input, void* output, size_t input_size, size_t output_size);
```
**Description**: Runs inference on loaded AI model.

**Parameters**:
- `model_id`: Model handle
- `input`: Input data buffer
- `output`: Output data buffer
- `input_size`: Size of input data
- `output_size`: Size of output buffer

**Return Value**:
- `0`: Success
- `< 0`: Error code

**Example**:
```c
#include <syscalls.h>

int main() {
    int model_id = sys_ai_load_model("/models/classifier.tflite");
    if (model_id < 0) return -1;
    
    // Prepare input data (e.g., image pixels)
    float input_data[224 * 224 * 3];  // 224x224 RGB image
    load_image_data("test.jpg", input_data);
    
    // Prepare output buffer
    float output_data[1000];  // 1000 class probabilities
    
    // Run inference
    int result = sys_ai_inference(model_id, input_data, output_data,
                                 sizeof(input_data), sizeof(output_data));
    
    if (result == 0) {
        // Find highest probability class
        int best_class = 0;
        float best_prob = output_data[0];
        
        for (int i = 1; i < 1000; i++) {
            if (output_data[i] > best_prob) {
                best_prob = output_data[i];
                best_class = i;
            }
        }
        
        printf("Predicted class: %d (confidence: %.2f)\n", best_class, best_prob);
    }
    
    sys_ai_unload_model(model_id);
    return 0;
}
```

#### sys_ai_get_info - Get AI System Information
```c
int sys_ai_get_info(ai_system_info_t* info);
```
**Description**: Retrieves information about the AI subsystem.

**Parameters**:
- `info`: Pointer to structure to fill with AI system information

**Return Value**:
- `0`: Success
- `< 0`: Error code

**Example**:
```c
#include <syscalls.h>

int main() {
    ai_system_info_t ai_info;
    
    if (sys_ai_get_info(&ai_info) == 0) {
        printf("AI Hardware: %s\n", ai_info.hardware_available ? "Available" : "Not Available");
        printf("Max Models: %d\n", ai_info.max_models);
        printf("Memory Available: %zu MB\n", ai_info.memory_size / (1024 * 1024));
    }
    
    return 0;
}
```

## 🔧 Hardware System Calls

### AI Hat Operations

#### sys_ai_hat_init - Initialize AI Hat
```c
int sys_ai_hat_init(void);
```
**Description**: Initializes the AI Hat hardware accelerator.

**Return Value**:
- `0`: Success
- `< 0`: Error code (AI Hat not available)

#### sys_ai_hat_status - Get AI Hat Status
```c
int sys_ai_hat_status(ai_hat_status_t* status);
```
**Description**: Gets the current status of the AI Hat.

**Parameters**:
- `status`: Pointer to status structure

**Return Value**:
- `0`: Success
- `< 0`: Error code

### UART Operations

#### sys_uart_write - Write to UART
```c
ssize_t sys_uart_write(int uart_id, const void* data, size_t size);
```
**Description**: Writes data directly to UART hardware.

**Parameters**:
- `uart_id`: UART device ID (0, 1, 2, etc.)
- `data`: Data to write
- `size`: Number of bytes to write

**Return Value**:
- `>= 0`: Number of bytes written
- `< 0`: Error code

#### sys_uart_read - Read from UART
```c
ssize_t sys_uart_read(int uart_id, void* buffer, size_t size);
```
**Description**: Reads data directly from UART hardware.

**Parameters**:
- `uart_id`: UART device ID
- `buffer`: Buffer to store read data
- `size`: Maximum bytes to read

**Return Value**:
- `>= 0`: Number of bytes read
- `< 0`: Error code

## 📊 Error Codes

### Standard Error Codes
```c
#define EPERM           1   // Operation not permitted
#define ENOENT          2   // No such file or directory
#define ESRCH           3   // No such process
#define EINTR           4   // Interrupted system call
#define EIO             5   // I/O error
#define ENXIO           6   // No such device or address
#define E2BIG           7   // Argument list too long
#define ENOEXEC         8   // Exec format error
#define EBADF           9   // Bad file number
#define ECHILD          10  // No child processes
#define EAGAIN          11  // Try again
#define ENOMEM          12  // Out of memory
#define EACCES          13  // Permission denied
#define EFAULT          14  // Bad address
#define EBUSY           16  // Device or resource busy
#define EEXIST          17  // File exists
#define ENODEV          19  // No such device
#define ENOTDIR         20  // Not a directory
#define EISDIR          21  // Is a directory
#define EINVAL          22  // Invalid argument
#define EMFILE          24  // Too many open files
#define ENOSPC          28  // No space left on device
```

### AI-Specific Error Codes
```c
#define EAI_MODEL_NOT_FOUND     100  // AI model file not found
#define EAI_MODEL_INVALID       101  // Invalid model format
#define EAI_MODEL_TOO_LARGE     102  // Model too large for memory
#define EAI_INFERENCE_FAILED    103  // Inference execution failed
#define EAI_HARDWARE_ERROR      104  // AI hardware error
#define EAI_NO_HARDWARE         105  // No AI hardware available
#define EAI_MODEL_NOT_LOADED    106  // Model not loaded
#define EAI_INVALID_INPUT       107  // Invalid input data
#define EAI_INVALID_OUTPUT      108  // Invalid output buffer
```

## 🔧 System Call Wrapper Functions

### Convenience Wrappers (sage-sdk/include/syscalls.h)
```c
// Process management wrappers
static inline void exit(int status) {
    sys_exit(status);
}

static inline pid_t getpid(void) {
    return sys_getpid();
}

// File I/O wrappers
static inline int open(const char* pathname, int flags) {
    return sys_open(pathname, flags);
}

static inline ssize_t read(int fd, void* buf, size_t count) {
    return sys_read(fd, buf, count);
}

static inline ssize_t write(int fd, const void* buf, size_t count) {
    return sys_write(fd, buf, count);
}

static inline int close(int fd) {
    return sys_close(fd);
}

// AI wrappers
static inline int ai_load_model(const char* path) {
    return sys_ai_load_model(path);
}

static inline int ai_inference(int model_id, const void* input, void* output,
                              size_t input_size, size_t output_size) {
    return sys_ai_inference(model_id, input, output, input_size, output_size);
}
```

## 📚 Usage Examples

### Complete AI Application Example
```c
#include <syscalls.h>
#include <stdio.h>
#include <string.h>

int main() {
    printf("SAGE OS AI Demo Application\n");
    
    // Load AI model
    int model_id = ai_load_model("/models/digit_classifier.tflite");
    if (model_id < 0) {
        printf("Failed to load model: %d\n", model_id);
        return 1;
    }
    
    // Prepare input (28x28 grayscale image)
    float input_image[28 * 28];
    memset(input_image, 0, sizeof(input_image));
    
    // Load test image (simplified)
    for (int i = 0; i < 28 * 28; i++) {
        input_image[i] = (float)(i % 256) / 255.0f;
    }
    
    // Run inference
    float output_probs[10];  // 10 digit classes
    int result = ai_inference(model_id, input_image, output_probs,
                             sizeof(input_image), sizeof(output_probs));
    
    if (result == 0) {
        // Find predicted digit
        int predicted_digit = 0;
        float max_prob = output_probs[0];
        
        for (int i = 1; i < 10; i++) {
            if (output_probs[i] > max_prob) {
                max_prob = output_probs[i];
                predicted_digit = i;
            }
        }
        
        printf("Predicted digit: %d (confidence: %.2f%%)\n", 
               predicted_digit, max_prob * 100.0f);
    } else {
        printf("Inference failed: %d\n", result);
    }
    
    // Cleanup
    sys_ai_unload_model(model_id);
    return 0;
}
```

This comprehensive system call API provides the foundation for building sophisticated applications on SAGE OS, with particular emphasis on AI and machine learning capabilities.