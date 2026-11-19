.include "support/test.inc"
.text
.global _start
_start:
ldr x0, =array
mov x1, #6
ldr x2, =results
CALL analyze_array
EXPECT_ARRAY results, expected, 6
EXPECT_ARRAY array, original, 6
EXPECT_MEM before, 0, 0x12345678
EXPECT_MEM after, 0, 0x12345678

    b test_pass
.data
.balign 8
array: .quad -4, 0, 7, -2, 7, 0
original: .quad -4, 0, 7, -2, 7, 0
before: .quad 0x12345678
results: .quad 99, 99, 99, 99, 99, 99
after: .quad 0x12345678
expected: .quad -4, 7, 8, 2, 2, 2

.section .note.GNU-stack,"",@progbits
