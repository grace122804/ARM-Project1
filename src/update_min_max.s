// x0=value, x1=results pointer; update only fields at offsets 0 and 8.
.text
.global update_min_max
.type update_min_max, %function
update_min_max:
    ldr x2, [x1, #0]            // Load current minimum into x2
    cmp x0, x2                  // Compare new value to minimum
    b.ge .lcheckmax             // If greater or equal, skip minimum update
    str x0, [x1, #0]            // Store new minimum

.lcheckmax:
    ldr x2, [x1, #8]            // Load current maximum into x2
    cmp x0, x2                  // Compare new value to maximum
    b.le .ldone                 // If less or equal, skip maximum update
    str x0, [x1, #8]            // Store new maximum

.ldone:
    ret                         // Return to the calling function
.size update_min_max, .-update_min_max
.section .note.GNU-stack,"",@progbits
