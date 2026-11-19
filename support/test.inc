.macro CALL function
    ldr x16, =\function
    bl checked_call
    ldr x9, =abi_ok
    ldr x9, [x9]
    cbz x9, test_fail
.endm
.macro EXPECT reg, value
    ldr x9, =\value
    cmp \reg, x9
    b.ne test_fail
.endm
.macro EXPECT_MEM symbol, offset, value
    ldr x10, =\symbol
    ldr x10, [x10, #\offset]
    EXPECT x10, \value
.endm
.macro EXPECT_ARRAY actual, expected, count
    ldr x10, =\actual
    ldr x11, =\expected
    mov x12, #\count
    cbz x12, .Larray_done\@
.Larray_loop\@:
    ldr x13, [x10], #8
    ldr x14, [x11], #8
    cmp x13, x14
    b.ne test_fail
    subs x12, x12, #1
    b.ne .Larray_loop\@
.Larray_done\@:
.endm
