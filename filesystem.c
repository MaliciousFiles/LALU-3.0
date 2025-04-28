#define _XOPEN_SOURCE 1

#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include <fcntl.h>
#include <sys/stat.h>

#define SYSCALL_NOOP 0
#define SYSCALL_OPEN 1
#define SYSCALL_CLOSE 2
#define SYSCALL_RMFILE 3
#define SYSCALL_RENAME 4
#define SYSCALL_SIZE 5
#define SYSCALL_READ 6
#define SYSCALL_WRITE 7
#define SYSCALL_MKDIR 8
#define SYSCALL_RMDIR 9

// returns string ON HEAP (must be freed)
char* getString(int swapFd, uint32_t addr) {
    int i = 0;
    lseek(swapFd, addr >> 3, SEEK_SET);
    while (1) {
        char c;
        read(swapFd, &c, 1);
        if (c == '\0') break;
        i++;
    }

    char* str = malloc(i + 1);
    lseek(swapFd, addr >> 3, SEEK_SET);
    read(swapFd, str, i);
    str[i] = '\0';

    return str;
}

int swapFd, swapMetaFd;
void init(char* root) {
    chroot(root);
    chdir("/");
    umask(0);

    mkdir("/dev", 0777);
    swapFd = open("/dev/mem", (O_RDWR | O_SYNC | O_TRUNC | O_CREAT), 0777);
    swapMetaFd = open("/dev/memmeta", (O_RDWR | O_SYNC | O_TRUNC | O_CREAT), 0777);

    int bios = open("/bios", (O_RDONLY | O_SYNC));
    void* buf = malloc(4096); //arbitrary

    int r;
    while ((r = read(bios, buf, 4096)) != 0) write(swapFd, buf, r);

    close(bios);
    free(buf);
}

void cleanup() {
    close(swapFd);
    close(swapMetaFd);
}

void tick(bool* swapMeta, uint32_t* swapAddress, bool* swapRden, uint32_t* swapReadData,
          bool* swapWren, uint32_t* swapWriteData, uint8_t* syscallId,
          uint32_t* pathPtr, uint32_t* pathPtr2, uint32_t* fileDescriptor,
          uint32_t* fileAddress, uint8_t* fileBits, uint32_t* fileWriteData,
          uint32_t* dataOut) {
    // implement system calls
    char *path, *path2;

    switch(*syscallId) {
        case SYSCALL_OPEN:
            path = getString(swapFd, *pathPtr);
            *dataOut = open(path, (O_RDWR | O_SYNC | O_CREAT), 0777);

            free(path);
            break;
        case SYSCALL_CLOSE:
            close(*fileDescriptor);
            break;
        case SYSCALL_RMFILE:
            path = getString(swapFd, *pathPtr);
            remove(path);

            free(path);
            break;
        case SYSCALL_RENAME:
            path = getString(swapFd, *pathPtr);
            path2 = getString(swapFd, *pathPtr2);
            rename(path, path2);

            free(path);
            free(path2);
            break;
        case SYSCALL_SIZE:
            *dataOut = lseek(*fileDescriptor, 0, SEEK_END);
            break;
        case SYSCALL_READ:
            lseek(*fileDescriptor, (*fileAddress >> 5) * 4, SEEK_SET);
            read(*fileDescriptor, dataOut, 4); // read a 32-bit word
            *dataOut = (*dataOut >> (*fileAddress % 32)) & (*fileBits == 0 ? 0xFFFFFFFF : (1<<(*fileBits))-1);
            break;
        case SYSCALL_WRITE:
            lseek(*fileDescriptor, (*fileAddress >> 5) * 4, SEEK_SET);

            uint32_t readData;
            read(*fileDescriptor, &readData, 4);

            lseek(*fileDescriptor, (*fileAddress >> 5) * 4, SEEK_SET);

            uint32_t mask = *fileBits == 0 ? 0xFFFFFFFF : (1<<(*fileBits))-1;

            *fileWriteData = ((*fileWriteData & mask) << (*fileAddress % 32)) | (readData & ~(mask << (*fileAddress % 32)));
            write(*fileDescriptor, fileWriteData, 4); // write a 32-bit word
            break;
        case SYSCALL_MKDIR:
            path = getString(swapFd, *pathPtr);
            mkdir(path, 0777);

            free(path);
            break;
        case SYSCALL_RMDIR:
            path = getString(swapFd, *pathPtr);
            rmdir(path);

            free(path);
            break;
        case SYSCALL_NOOP:
        default: break;
    }

    // swap address is a word address
    // implement swap reading
    if (*swapRden) {
        int fd = *swapMeta ? swapMetaFd : swapFd;

        lseek(fd, *swapAddress << 2, SEEK_SET);
        read(fd, swapReadData, 4);
    }

    // implement swap writing
    if (*swapWren) {
        int fd = *swapMeta ? swapMetaFd : swapFd;

        lseek(fd, *swapAddress << 2, SEEK_SET);
        write(fd, swapWriteData, 4);
    }
}