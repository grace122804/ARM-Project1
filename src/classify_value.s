// x0=value -> x0=-1/0/1 for negative/zero/positive.
.text
.global classify_value
.type classify_value, %function
classify_value:
    cmp x0, #0                  // Compare the value to zero
    b.lt .lnegative             // If less than zero, go to negative
    b.eq .lzero                 // If equal to zero, go to zero
    mov x0, #1                  // Otherwise, return positive (1)
    ret                         // Return to the calling function

.lnegative:
    mov x0, #-1                 // Set result to negative (-1)
    ret                         // Return to the calling function

.lzero:
    mov x0, #0                  // Set result to zero (0)
    ret                         // Return to the calling function
.size classify_value, .-classify_value
.section .note.GNU-stack,"",@progbits
