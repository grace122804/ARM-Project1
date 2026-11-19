.include "support/test.inc"
.text
.global _start
_start:
ldr x0, =1099511627776
CALL classify_value
EXPECT x0, 1

    b test_pass

.section .note.GNU-stack,"",@progbits
