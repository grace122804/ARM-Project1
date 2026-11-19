// x0=array, x1=length, x2=48-byte results; calls both helpers for each element.
.text
.global analyze_array
.type analyze_array, %function
analyze_array:
    stp x19, x20, [sp, #-48]!    // Save x19 and x20 on stack
    stp x21, x22, [sp, #16]      // Save x21 and x22 on stack
    stp x23, x30, [sp, #32]      // Save x23 and return address

    mov x19, x0                  // Save array address
    mov x20, x1                  // Save array length
    mov x21, x2                  // Save results address
    mov x22, #0                  // Set loop counter to zero

    str xzr, [x21, #0]           // Initialize minimum to zero
    str xzr, [x21, #8]           // Initialize maximum to zero
    str xzr, [x21, #16]          // Initialize sum to zero
    str xzr, [x21, #24]          // Initialize positive count to zero
    str xzr, [x21, #32]          // Initialize negative count to zero
    str xzr, [x21, #40]          // Initialize zero count to zero

    cbz x20, .ldone              // If array is empty, finish

    ldr x23, [x19]               // Load first array element
    str x23, [x21, #0]           // Set first element as minimum
    str x23, [x21, #8]           // Set first element as maximum

.lloop:
    cmp x22, x20                 // Compare counter to array length
    b.ge .ldone                 // If all elements processed, finish

    ldr x23, [x19, x22, lsl #3]  // Load current array element

    ldr x9, [x21, #16]           // Load current sum
    add x9, x9, x23              // Add current element to sum
    str x9, [x21, #16]           // Store updated sum

    mov x0, x23                  // Pass current element to classifier
    bl classify_value            // Call classify_value

    cmp x0, #0                   // Compare returned category to zero
    b.lt .lnegative              // If negative, update negative count
    b.eq .lzero                  // If zero, update zero count

    ldr x9, [x21, #24]           // Load positive count
    add x9, x9, #1               // Increase positive count by one
    str x9, [x21, #24]           // Store updated positive count
    b .lupdate                   // Skip to minimum/maximum update

.lnegative:
    ldr x9, [x21, #32]           // Load negative count
    add x9, x9, #1               // Increase negative count by one
    str x9, [x21, #32]           // Store updated negative count
    b .lupdate                   // Skip to minimum/maximum update

.lzero:
    ldr x9, [x21, #40]           // Load zero count
    add x9, x9, #1               // Increase zero count by one
    str x9, [x21, #40]           // Store updated zero count

.lupdate:
    mov x0, x23                  // Pass current element as first argument
    mov x1, x21                  // Pass results address as second argument
    bl update_min_max            // Call minimum/maximum helper

    add x22, x22, #1             // Increase loop counter by one
    b .lloop                     // Repeat loop for next element

.ldone:
    ldp x23, x30, [sp, #32]      // Restore x23 and return address
    ldp x21, x22, [sp, #16]      // Restore x21 and x22
    ldp x19, x20, [sp], #48      // Restore x19, x20 and stack pointer
    ret                          // Return to calling function
.size analyze_array, .-analyze_array
.section .note.GNU-stack,"",@progbits
