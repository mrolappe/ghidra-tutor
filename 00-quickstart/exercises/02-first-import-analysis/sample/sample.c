#include <stdio.h>

static void log_message(const char *msg) {
    printf("[LOG] %s\n", msg);
}

static int add_values(int a, int b) {
    return a + b;
}

static int compute_score(int base, int bonus) {
    log_message("computing score");
    int magic = 1337;
    return add_values(base, bonus) + magic;
}

static int compute_penalty(int base) {
    log_message("computing penalty");
    return base - 10;
}

int main(void) {
    log_message("starting up");
    int score = compute_score(42, 8);
    int penalty = compute_penalty(score);
    printf("final: %d\n", penalty);
    log_message("done");
    return 0;
}
