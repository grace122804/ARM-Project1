.include "support/test.inc"
.text
.global _start
_start:
ldr x0, =9223372036854775807
ldr x1, =results
CALL update_min_max
EXPECT_ARRAY results, expected, 6
EXPECT_MEM before, 0, 0x12345678
EXPECT_MEM after, 0, 0x12345678

    b test_pass
.data
.balign 8
before: .quad 0x12345678
results: .quad 0, 0, 55, 66, 77, 88
after: .quad 0x12345678
expected: .quad 0, 9223372036854775807, 55, 66, 77, 88

.section .note.GNU-stack,"",@progbits
