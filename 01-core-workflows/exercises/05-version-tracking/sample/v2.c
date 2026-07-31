#include <stdio.h>

static int validate(int x) {
    return x >= 0 && x < 100;
}

static int format_result(int x) {
    return x * 10;
}

static int compute(int x) {
    return x * 2 + 3;   /* changed constant vs v1 */
}

static int bonus(int x) {
    return x + 1000;    /* new in v2 */
}

int main(void) {
    int x = 7;
    if (validate(x)) {
        int r = compute(x);
        int b = bonus(r);
        printf("result=%d bonus=%d\n", format_result(r), b);
    }
    return 0;
}
