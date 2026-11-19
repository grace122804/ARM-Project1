.include "support/test.inc"
.text
.global _start
_start:
ldr x0, =array
mov x1, #3
ldr x2, =results
CALL analyze_array
EXPECT_ARRAY results, expected, 6
EXPECT_ARRAY array, original, 3
EXPECT_MEM before, 0, 0x12345678
EXPECT_MEM after, 0, 0x12345678

    b test_pass
.data
.balign 8
array: .quad 1099511627776, -549755813888, 274877906944
original: .quad 1099511627776, -549755813888, 274877906944
before: .quad 0x12345678
results: .quad 99, 99, 99, 99, 99, 99
after: .quad 0x12345678
expected: .quad -549755813888, 1099511627776, 824633720832, 2, 1, 0

.section .note.GNU-stack,"",@progbits
