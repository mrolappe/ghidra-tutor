#include <stdio.h>
#include <string.h>

typedef struct {
    int  id;
    int  quantity;
    char name[16];
} Item;

static Item inventory[4];

static void init_item(Item *it, int id, const char *name, int qty) {
    it->id = id;
    it->quantity = qty;
    strncpy(it->name, name, sizeof(it->name) - 1);
    it->name[sizeof(it->name) - 1] = '\0';
}

static int total_quantity(Item *items, int count) {
    int total = 0;
    for (int i = 0; i < count; i++) {
        total += items[i].quantity;
    }
    return total;
}

static int op_add(int a, int b) { return a + b; }
static int op_sub(int a, int b) { return a - b; }

typedef int (*op_fn)(int, int);
static op_fn ops[2] = { op_add, op_sub };

static int apply_op(int index, int a, int b) {
    return ops[index](a, b);
}

int main(void) {
    init_item(&inventory[0], 1, "widget",   10);
    init_item(&inventory[1], 2, "gadget",    5);
    init_item(&inventory[2], 3, "gizmo",    20);
    init_item(&inventory[3], 4, "sprocket",  8);

    int total = total_quantity(inventory, 4);
    int sum  = apply_op(0, total, 3);
    int diff = apply_op(1, total, 3);

    printf("total=%d sum=%d diff=%d\n", total, sum, diff);
    return 0;
}
