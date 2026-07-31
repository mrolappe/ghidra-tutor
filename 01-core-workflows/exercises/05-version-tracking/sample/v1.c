#include <stdio.h>

static int validate(int x) {
    return x >= 0 && x < 100;
}

static int compute(int x) {
    return x * 2 + 1;
}

static int format_result(int x) {
    return x * 10;
}

int main(void) {
    int x = 7;
    if (validate(x)) {
        int r = compute(x);
        printf("result=%d\n", format_result(r));
    }
    return 0;
}
