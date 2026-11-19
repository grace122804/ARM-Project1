.include "support/test.inc"
.text
.global _start
_start:
ldr x0, =0
CALL classify_value
EXPECT x0, 0

    b test_pass

.section .note.GNU-stack,"",@progbits
