// Instructor-supplied I/O and test exits. Students do not need syscall code.
.text
.global write_stdout
.type write_stdout, %function
write_stdout:                    // x0=address, x1=byte count; returns write result
    mov x2, x1
    mov x1, x0
    mov x0, #1
    mov x8, #64
    svc #0
    ret
.size write_stdout, .-write_stdout

.macro EXIT_MESSAGE label, length, status
    ldr x0, =\label
    mov x1, #\length
    bl write_stdout
    mov x0, #\status
    mov x8, #93
    svc #0
.endm
.global not_implemented
.type not_implemented, %function
not_implemented:
    EXIT_MESSAGE todo_message, todo_length, 99
.global test_pass
test_pass:
    EXIT_MESSAGE pass_message, pass_length, 0
.global test_fail
test_fail:
    EXIT_MESSAGE fail_message, fail_length, 1
.section .rodata
todo_message: .ascii "TODO: implement the requested procedure in src/.\n"
.equ todo_length, .-todo_message
pass_message: .ascii "PASS\n"
.equ pass_length, .-pass_message
fail_message: .ascii "FAIL: result, memory guard, or preserved register check.\n"
.equ fail_length, .-fail_message
.section .note.GNU-stack,"",@progbits
