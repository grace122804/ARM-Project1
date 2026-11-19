// Analyze demo_array using demo_length; store demo_results; return 0.
.text
.global main
.type main, %function
main:
    stp x29, x30, [sp, #-16]!    // Save frame pointer and return address
    mov x29, sp                  // Set frame pointer to stack pointer

    adrp x0, demo_array          // Load page address of demo array
    add x0, x0, :lo12:demo_array // Get full address of demo array

    adrp x9, demo_length         // Load page address of array length
    add x9, x9, :lo12:demo_length // Get full address of array length
    ldr x1, [x9]                // Load array length into x1

    adrp x2, demo_results        // Load page address of results
    add x2, x2, :lo12:demo_results // Get full results address

    bl analyze_array             // Call function to analyze array

    mov x0, #0                  // Set return value to zero

    ldp x29, x30, [sp], #16      // Restore frame pointer and return address
    ret                         // Return from main
.size main, .-main
.section .note.GNU-stack,"",@progbits

.data
.balign 8
.global demo_array, demo_length
demo_array: .quad -4, 0, 7, -2, 7, 0
demo_length: .quad 6
.bss
.balign 8
.global demo_results
demo_results: .skip 48
