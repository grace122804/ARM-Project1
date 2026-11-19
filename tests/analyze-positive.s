.include "support/test.inc"
.text
.global _start
_start:
ldr x0, =array
mov x1, #4
ldr x2, =results
CALL analyze_array
EXPECT_ARRAY results, expected, 6
EXPECT_ARRAY array, original, 4
EXPECT_MEM before, 0, 0x12345678
EXPECT_MEM after, 0, 0x12345678

    b test_pass
.data
.balign 8
array: .quad 1, 7, 3, 99
original: .quad 1, 7, 3, 99
before: .quad 0x12345678
results: .quad 99, 99, 99, 99, 99, 99
after: .quad 0x12345678
expected: .quad 1, 99, 110, 4, 0, 0

.section .note.GNU-stack,"",@progbits
