#define _XOPEN_SOURCE 1

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>

#define BASE 0xFF200000
#define SPAN 0x00005000

#define NAME_STREAM 0x00000000
#define CLOCK 0x00000010
#define READ_ENABLE 0x00000020
#define ADDRESS 0x00000040
#define READ_DATA 0x00000030
#define WRITE_DATA 0x00000050
#define WRITE_ENABLE 0x00000060
#define DELETE_FILE 0x00000070

void mkdir_parents(const char *path) {
    char parent_path[strlen(path) + 1];
    strcpy(parent_path, path);

    char *last_slash = strrchr(parent_path, '/');
    if (last_slash == NULL) return; // it's the root directory
    *last_slash = '\0';

    if (strlen(parent_path) == 0) return; // it's the root directory

    mkdir_parents(parent_path);
    mkdir(path, 0777);
}

int main() {
    int fdm = open("/dev/mem", (O_RDWR | O_SYNC));
    void* bridge = mmap(NULL, SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fdm, BASE);

    bool* clock = bridge + CLOCK;

    uint16_t* address = bridge + ADDRESS;

    bool* readEnable = bridge + READ_ENABLE;
    uint32_t* readData = bridge + READ_DATA;

    bool* writeEnable = bridge + WRITE_ENABLE;
    uint32_t* writeData = bridge + WRITE_DATA;

    char* nameStream = bridge + NAME_STREAM;
    bool* deleteFile = bridge + DELETE_FILE;

	chroot("/home/root/LALU_fs");
	chdir("/");

    bool oldClock = false;

    char name[1024];
    int nameIdx = -1;
    FILE* fp = NULL;

    while (1) {
        // on clock rising edge
        if (!oldClock && *clock) {
            // check on the name stream
            for (int i = 0; i < 4; i++) {
                char c = *(nameStream + i);

                // end of the stream
                if (c == 0) {
                    if (nameIdx > -1) {
                        name[++nameIdx] = 0;

                        if (fp != NULL) fclose(fp);
                        fp = fopen(name, "rb+");

                        if (fp == NULL) { // the file doesn't exist, create it
                            mkdir_parents(name);
                            fp = fopen(name, "wb+");
                        }
                    }

                    nameIdx = -1;
                    break;
                }

                name[++nameIdx] = c;
            }

            if (*deleteFile) {
                if (fp != NULL) {
                    fclose(fp);
                    remove(name);
                }
            	fp = NULL;
            	*readData = 0;
            }

            if (fp != NULL) {
                fseek(fp, *address * 4, SEEK_SET);
                if (*readEnable) {
                    fread(readData, 4, 1, fp);
                    if (feof(fp)) *readData = 0;
                }
                if (*writeEnable) {
                	fwrite(writeData, 4, 1, fp);
                }
            }
        }

        oldClock = *clock;
    }

    munmap(bridge, SPAN);
    close(fdm);
    if (fp != NULL) fclose(fp);
    return 0;
}
