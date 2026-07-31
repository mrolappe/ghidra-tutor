#include <stdio.h>
#include "lib.c"

static void report(int sum, int c) {
    printf("checksum=%d -> clamped=%d\n", sum, c);
}

int main(void) {
    unsigned char buf[6] = {1, 2, 3, 4, 5, 6};
    int sum = checksum(buf, 6);
    int c = clamp(sum, 0, 15);
    report(sum, c);
    return 0;
}
