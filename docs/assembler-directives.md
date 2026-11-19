# Assembler directives in Lab 1

Directives tell GNU's assembler how to organize code and data and what
information to give the linker and debugger. The CPU executes instructions
such as `cmp` and `ret`. When you edit a starter function, keep the
surrounding directives and put your instructions under the function label.

## Around a function

This small example returns zero. It shows the same wrapper as the lab's
functions.

```asm
.text
.global return_zero
.type return_zero, %function
return_zero:
    mov x0, #0
    ret
.size return_zero, .-return_zero
.section .note.GNU-stack,"",@progbits
```

| Line | What it does |
| --- | --- |
| `.text` | Selects the code section, where instructions go. |
| `.global return_zero` | Makes the label visible to the linker from other files. The test harness uses global names to call your functions. |
| `.type return_zero, %function` | Marks the symbol as a function for tools such as GDB. |
| `.size return_zero, .-return_zero` | Records the function's length in bytes. The standalone dot means the assembler's current position. Subtracting the start label gives the size. |
| `.section .note.GNU-stack,"",@progbits` | Marks this file as needing no executable stack. Keep the supplied line as written. |

`return_zero:` is a **label**. It names the address of the next instruction.
Use plain labels such as `array_loop:` for branch targets within a source file.
They need no `.global` line. The `.L` prefix you may see in examples
marks a temporary label that GNU `as` normally leaves out of the symbol table.

## Around the demo data in `src/main.s`

| Line | What it does |
| --- | --- |
| `.data` | Selects the section for writable data with supplied starting values. |
| `.quad -4, 0, 7, -2, 7, 0` | Stores one 8-byte integer per value. This is why the pointer advances by 8 bytes per element. |
| `.bss` | Selects the section for storage that starts at zero when the program loads. |
| `.skip 48` | Reserves 48 bytes for the six 8-byte results. In this `.bss` block, they start at zero. |
| `.balign 8` | Adds padding if needed so the next item starts on an 8-byte boundary. |
| `.global demo_results` | Lets the integration test find your results buffer by name. |

`ldr x0, =demo_array` is a GNU assembler shorthand that loads the **address**
of the array into `x0`. An instruction such as `ldur x9, [x0]` reads the
first **value** at that address.

If you browse the supplied test and runtime files, `.include` reads another
assembly file, `.macro` and `.endm` define reusable blocks of assembly, and
`.equ` names a constant. The runtime uses `.section .rodata` for read-only
data and `.ascii` to store text bytes. You can complete Lab 1 using the
supplied wrappers and data declarations.
