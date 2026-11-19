.include "support/test.inc"
.text
.global _start
_start:
ldr x0, =array
mov x1, #3
ldr x2, =results
CALL analyze_array
mov x0, #0
mov x1, #0
ldr x2, =results
CALL analyze_array
EXPECT_ARRAY results, expected, 6

    b test_pass
.data
.balign 8
array: .quad -1, 0, 5
results: .quad 99, 99, 99, 99, 99, 99
expected: .quad 0, 0, 0, 0, 0, 0

.section .note.GNU-stack,"",@progbits
