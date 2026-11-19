.text
.global _start
.type _start, %function
_start:
    bl main
    mov x8, #93                 // Linux exit(main return value)
    svc #0
.size _start, .-_start
.section .note.GNU-stack,"",@progbits
