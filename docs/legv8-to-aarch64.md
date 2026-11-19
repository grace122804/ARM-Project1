# From LEGv8 to real AArch64

These projects use ARMv8-A's 64-bit instruction set (A64/AArch64), GNU `as`,
ELF executables, and Linux under QEMU. LEGv8 is a teaching subset; its exact
assembler/simulator features vary. The algorithms and procedure concepts transfer.
This guide calls out syntax that changes and conventions we will follow.

## Critical incompatibilities

| In LEGv8 material | In this repository |
| --- | --- |
| `ADDI X0, X0, #1` | `add x0, x0, #1` |
| `SUBI X1, X1, #8` | `sub x1, x1, #8` |
| `ADDIS` / `SUBIS` | `adds` / `subs` with an immediate operand |
| `ANDI` / `ORRI` / `EORI` | `and` / `orr` / `eor` with an encodable immediate |
| X28 assigned the SP role in some textbook tables | Use the architectural `sp`. `x28` is a separate, callee-saved register. |
| A general-purpose `X31` | Spell `sp` or `xzr` as appropriate. Encoding 31 has instruction-dependent meaning. |
| `LDURB X9, [X0, #0]` | `ldurb w9, [x0, #0]`. Byte loads/stores use `w` data registers and `x` address registers. |
| Simulator `PRNT`, `PRNL`, `DUMP`, `HALT` (where supported) | Use GDB and supplied `write_stdout`; return from `main`. These are not A64 instructions. |
| Assumed memory at a fixed small address | Load the address of a label; Linux owns the address space. |

GNU accepts upper- or lowercase instruction names; lowercase is our style, not
a compatibility requirement. `br x30` is valid; use `ret` for ordinary returns.
`ldur`, `stur`, `ldurb`, and `sturb` remain real, useful instructions.

## Register width and data size

`x0` holds 64 bits. `w0` names its lower 32 bits; writing `w0` clears the upper
32 bits of `x0`. For signed 64-bit arrays, use `x` loads/stores and advance by
8 bytes. For ASCII strings, use byte loads and advance by 1 byte.
`ldurb` zero-extends the byte. A 32-bit `ldr w0, [...]` does not sign-extend
to 64 bits; use `ldrsw x0, [...]` when that is actually intended.

| GNU directive | Meaning |
| --- | --- |
| `.quad -7, 0, 12` | Three 64-bit integers |
| `.word 12` | One **32-bit** integer |
| `.byte 65` | One byte |
| `.asciz "hello"` | Bytes followed by a zero terminator |
| `.skip 48` in `.bss` | Reserve 48 zero-initialized bytes |
| `.balign 8` | Align the next item to an 8-byte boundary |

Use `.balign` to make alignment units explicit. Use `//` for comments.
Semicolons separate statements in GNU AArch64 assembly.

## Addresses, immediates, and aliases

```asm
ldr x0, =array       // GNU convenience: put array's ADDRESS into x0
ldur x1, [x0, #0]    // read the 64-bit VALUE stored there
add x0, x0, #8       // next 64-bit element
```

`ldr x0, =array` is an assembler pseudo-instruction, which may use a literal
pool. It is not the same as a load through an address already in a register.
For larger functions, place literal pools deliberately with `.ltorg` after
an unconditional branch/return, or use `adrp` plus `add` with GNU relocations.
The supplied programs are statically linked, non-PIE executables.

`mov`, `cmp`, and the shift spellings are normal assembler aliases; they are
welcome here. `mov` cannot encode every 64-bit constant in one instruction:
use `movz`/`movk` or a literal load. `add`/`sub` immediates and logical
immediates also have encoding limits; the assembler diagnoses them.
Offsets are measured in bytes; `ldur`/`stur` have signed, unscaled 9-bit
offsets (-256 through 255), while `ldr`/`str` offer other addressing forms.

## Calling convention: AAPCS64

| Registers | Rule for these labs |
| --- | --- |
| `x0`–`x7` | Arguments; caller must expect them to change. Scalar results use `x0`. |
| `x8` | Special ABI use for indirect aggregate results; avoid as a long-lived value across calls. |
| `x9`–`x15` | Caller-saved scratch registers. |
| `x16`, `x17` | Caller-saved scratch registers also usable by linker veneers. |
| `x18` | Platform-specific; leave unused for portability. |
| `x19`–`x28` | Preserve their incoming values if you use them. |
| `x29` | Callee-saved frame pointer; preserve it if used. |
| `x30` | Link register. `bl`/`blr` replace it. Save your incoming return address before making another call. |
| `sp` | Restore on return. Our course convention keeps it 16-byte aligned throughout every procedure. |

Do not expect condition flags to survive calls. Use `b.lt`, `b.le`, `b.gt`,
and `b.ge` for signed comparisons after `cmp`; use `b.lo`/`b.hs` for unsigned
comparisons such as indices. `cmp` sets flags without saving a subtraction
result. Ordinary `add`/`sub` do not set flags; `adds`/`subs` do.

A non-leaf procedure can start with this frame (adapt the frame if needed):

```asm
.global example
.type example, %function
example:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl helper
    ldp x29, x30, [sp], #16
    ret
.size example, .-example
```

Saving LR alone does not preserve arguments that a helper may overwrite.
Store live values in saved registers or stack slots, preserving those saved
registers in your own frame. See the [assembler directives guide](assembler-directives.md)
for the lines around the function body.

## Recommended instruction vocabulary (not a restriction)

| Purpose | Start with |
| --- | --- |
| Arithmetic / flags | `add`, `sub`, `adds`, `subs`, `cmp` |
| Logic / shifts | `and`, `orr`, `eor`, `lsl`, `lsr`, `asr` |
| Values / addresses | `mov`, `movz`, `movk`, `adr`, `adrp`, `ldr =symbol` |
| Memory | `ldur`, `stur`, `ldurb`, `sturb`, `ldr`, `str`, `ldrb`, `strb` |
| Flow | `b`, `b.eq`, `b.ne`, `b.lt`, `b.le`, `b.gt`, `b.ge`, `b.lo`, `b.hs`, `cbz`, `cbnz`, `bl`, `ret` |
| Frames | `stp`, `ldp`, `add`/`sub` on `sp` |

Additional A64 instructions, addressing forms, and standard aliases are allowed.
The autograder does not impose an opcode whitelist. Required helper calls and
calling conventions remain assignment requirements.

## Program startup

Linux enters `_start` in `support/start.s`; that code calls your `main` and
exits with its return value. `main` returns 0 on success. Returning from it is
different from branching to address zero or falling off the end of a file.
Tests have their own `_start` and can call your procedures directly.
There is no C runtime or `printf`; see the supplied `write_stdout` interface.

## References

- [Arm AAPCS64](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst)
- [GNU assembler AArch64 documentation](https://sourceware.org/binutils/docs/as/AArch64_002dDependent.html)
- [Arm instruction-set resources](https://developer.arm.com/Architectures/A-Profile%20Architecture)
