/* Tiny "library" whose two functions are byte-identical in both driver
   programs below, even though the surrounding binary differs — the point
   of the Function ID exercise. */
static int checksum(const unsigned char *data, int len) {
    int sum = 0;
    for (int i = 0; i < len; i++) {
        sum += data[i];
    }
    return sum;
}

static int clamp(int value, int lo, int hi) {
    if (value < lo) return lo;
    if (value > hi) return hi;
    return value;
}
