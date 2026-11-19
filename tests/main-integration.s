.include "support/test.inc"
.text
.global _start
_start:
CALL main
EXPECT x0, 0
EXPECT_ARRAY demo_results, expected, 6

    b test_pass
.data
.balign 8
expected: .quad -4, 7, 8, 2, 2, 2

.section .note.GNU-stack,"",@progbits
