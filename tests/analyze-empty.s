.include "support/test.inc"
.text
.global _start
_start:
mov x0, #0
mov x1, #0
ldr x2, =results
CALL analyze_array
EXPECT_ARRAY results, expected, 6
EXPECT_ARRAY array, original, 0
EXPECT_MEM before, 0, 0x12345678
EXPECT_MEM after, 0, 0x12345678

    b test_pass
.data
.balign 8
array: .skip 8
original: .skip 8
before: .quad 0x12345678
results: .quad 99, 99, 99, 99, 99, 99
after: .quad 0x12345678
expected: .quad 0, 0, 0, 0, 0, 0

.section .note.GNU-stack,"",@progbits
