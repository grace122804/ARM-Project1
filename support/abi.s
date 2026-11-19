// Call a student procedure at x16, preserving its x0-x7 arguments/results.
// The wrapper checks x19-x29 and SP on return. This does not prove alignment
// during nested calls; that remains part of code review.
.text
.global checked_call
.type checked_call, %function
checked_call:
    sub sp, sp, #96
    stp x19, x20, [sp, #0]
    stp x21, x22, [sp, #16]
    stp x23, x24, [sp, #32]
    stp x25, x26, [sp, #48]
    stp x27, x28, [sp, #64]
    stp x29, x30, [sp, #80]
    ldr x9, =saved_sp
    mov x10, sp
    str x10, [x9]
    ldr x9, =abi_ok
    mov x10, #1
    str x10, [x9]
    mov x19, #0x1919
    mov x20, #0x2020
    mov x21, #0x2121
    mov x22, #0x2222
    mov x23, #0x2323
    mov x24, #0x2424
    mov x25, #0x2525
    mov x26, #0x2626
    mov x27, #0x2727
    mov x28, #0x2828
    mov x29, #0x2929
    blr x16
    ldr x9, =saved_sp
    ldr x10, [x9]
    mov x11, sp
    cmp x10, x11
    b.eq 1f
    mov sp, x10
    b .Labi_bad
1:
    mov x9, #0x1919
    cmp x19, x9
    b.ne .Labi_bad
    mov x9, #0x2020
    cmp x20, x9
    b.ne .Labi_bad
    mov x9, #0x2121
    cmp x21, x9
    b.ne .Labi_bad
    mov x9, #0x2222
    cmp x22, x9
    b.ne .Labi_bad
    mov x9, #0x2323
    cmp x23, x9
    b.ne .Labi_bad
    mov x9, #0x2424
    cmp x24, x9
    b.ne .Labi_bad
    mov x9, #0x2525
    cmp x25, x9
    b.ne .Labi_bad
    mov x9, #0x2626
    cmp x26, x9
    b.ne .Labi_bad
    mov x9, #0x2727
    cmp x27, x9
    b.ne .Labi_bad
    mov x9, #0x2828
    cmp x28, x9
    b.ne .Labi_bad
    mov x9, #0x2929
    cmp x29, x9
    b.ne .Labi_bad
    b .Labi_restore
.Labi_bad:
    ldr x9, =abi_ok
    str xzr, [x9]
.Labi_restore:
    ldp x19, x20, [sp, #0]
    ldp x21, x22, [sp, #16]
    ldp x23, x24, [sp, #32]
    ldp x25, x26, [sp, #48]
    ldp x27, x28, [sp, #64]
    ldp x29, x30, [sp, #80]
    add sp, sp, #96
    ret
.size checked_call, .-checked_call
.bss
.balign 8
saved_sp: .skip 8
.global abi_ok
abi_ok: .skip 8
.section .note.GNU-stack,"",@progbits
