#include "filesystem.c"
#include <sys/mman.h>

#define BASE 0xFF200000
#define SPAN 0x00005000



int main() {
    int fdm = open("/dev/mem", (O_RDWR | O_SYNC));
    void* bridge = mmap(NULL, SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fdm, BASE);

    bool* clock = bridge + CLOCK;

    bool* swapMeta = bridge + SWAP_META;
    uint32_t* swapAddress = bridge + SWAP_ADDRESS;

    bool* swapRden = bridge + SWAP_RDEN;
    uint32_t* swapReadData = bridge + SWAP_READ_DATA;

    bool* swapWren = bridge + SWAP_WREN;
    uint32_t* swapWriteData = bridge + SWAP_WRITE_DATA;

    uint4_t* syscallId = bridge + SYSCALL_ID;

    uint32_t* pathPtr = bridge + PATH_PTR_1;
    char** pathPtr2 = bridge + PATH_PTR_2;

    uint32_t* fileDescriptor = bridge + FILE_DESCRIPTOR;
    uint32_t* fileAddress = bridge + FILE_ADDRESS;

    uint8_t* fileBits = bridge + FILE_BITS; // 5 bits
    uint32_t* fileWriteData = bridge + FILE_WRITE_DATA;

    uint32_t* dataOut = bridge + DATA_OUT;

    init("/home/root/LALU_fs");

    bool oldClock = false;
    while (1) {
        // on clock rising edge
        if (!oldClock && *clock) tick(swapMeta, swapAddress, swapRden, swapReadData,
                                     swapWren, swapWriteData, syscallId,
                                     pathPtr, pathPtr2, fileDescriptor,
                                     fileAddress, fileBits, fileWriteData,
                                     dataOut);
        oldClock = *clock;
    }

    cleanup();

    munmap(bridge, SPAN);
    close(fdm);
    return 0;
}
