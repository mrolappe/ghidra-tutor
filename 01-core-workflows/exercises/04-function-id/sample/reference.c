#include <stdio.h>
#include "lib.c"

int main(void) {
    unsigned char buf[4] = {10, 20, 30, 40};
    int sum = checksum(buf, 4);
    int c = clamp(sum, 0, 50);
    printf("sum=%d clamped=%d\n", sum, c);
    return 0;
}
