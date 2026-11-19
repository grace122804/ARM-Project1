# Debugging AArch64 with gdb-multiarch

All commands below run **inside your Codespace**. No local ARM computer,
VS Code extension, port forwarding, or separate `gdbserver` is needed.
The Makefile assembles with debug information (`-g`) and keeps symbols.
For your first Lab 1 session, follow [Getting started](../ASSIGNMENT.md#getting-started)
to step through a test of `classify_value`.

## First session: two terminals

1. Open a terminal with **Terminal → New Terminal**. Run `make debug`.
   QEMU prints that it is waiting for a debugger. This is expected.
2. Open a second terminal using the terminal panel's **+** button. Run `make gdb`.
   You will see `(gdb)`. The target is initially paused at `_start`; the command
   has already connected, set a breakpoint at `main`, and enabled instruction display.
3. At the GDB prompt, type `continue`. It stops before `main` executes.
4. Type `list` to see source, then `disassemble main` to see instructions.
5. Use `si` to execute one instruction. Use `ni` to execute one instruction,
   stepping over a procedure call. Repeat the last command by pressing Enter.
6. Type `continue` to run to the next breakpoint or program exit. Type `quit`
   when finished.

Initially the lab procedures branch to `not_implemented` and exit with status 99.
Set breakpoints on your procedure names after implementing them.

Underneath, the targets run these commands (example port 1234):

```sh
qemu-aarch64 -g 1234 build/program
gdb-multiarch -q build/program
```

The corresponding manual GDB connection is `target remote localhost:1234`.
Use `continue` after connecting; `run` is not the startup command for this
remote session. To choose another port, use `make debug PORT=1235` and
`make gdb PORT=1235` in the two terminals.

## Small command reference

| GDB command | Purpose |
| --- | --- |
| `break main` | Stop at the start of `main` |
| `break src/main.s:20` | Stop at a source line containing an instruction |
| `info breakpoints` / `delete 2` | List breakpoints / delete breakpoint 2 |
| `continue` or `c` | Resume |
| `si` | Step one instruction, entering a call |
| `ni` | Step one instruction, stepping over a call |
| `info registers x0 x1 x2 x19 x29 x30 sp pc` | Inspect selected registers |
| `p/x $x0` / `p/d $x0` | Display a register in hexadecimal / signed decimal |
| `display/i $pc` | Show the next instruction each time execution stops |
| `x/6dg $x0` | Six signed 64-bit values at the address in `x0` |
| `x/8gx $sp` | Eight 64-bit hexadecimal values on the stack |
| `x/16bx $x0` | Sixteen individual bytes |
| `x/s $x0` | A null-terminated string |
| `disassemble main` | Decode the procedure |
| `bt` | Backtrace, when frame/unwind information permits |
| `finish` | Run until this function returns, when unwinding permits |

In `x/6dg`, `6` is the count, `d` is signed decimal, and `g` selects 8-byte
units. GDB's `w` means **4 bytes**. If you want to inspect an array after a
call, first save its address with `set $array_base = $x0`, then examine
`x/6dg $array_base`; `x0` may hold a result or scratch value after the call.
Likewise, `x/s $x0` only makes sense while `x0` contains a valid string address.

## Follow a nested call

The base template includes a complete `main → analyze_demo → classify_demo`
example. Project 1 will use `main → analyze_array → classify_value`.

1. Break at `analyze_demo` (or `analyze_array`) and continue there.
2. Inspect `x30`: it points back to the caller. Record it with
   `set $caller_return = $x30`.
3. Step through the prologue. Inspect `x/4gx $sp` to find the saved LR and
   any saved live registers. The provided example's first stack slots hold
   saved `x29` and `x30`.
4. Step to the `bl classify_demo` (or `bl classify_value`) instruction, then
   use `si`. Notice that `x30` now points inside the calling procedure.
5. Follow the helper's `ret`. Step through the caller's epilogue and check
   `p $x30 == $caller_return` before its final `ret`.

If LR was not saved and restored, the final return may jump back inside the
procedure instead of returning to its caller. `ni` can then appear to hang.

## Debug a failing test

`make test` prints each test's name. Its log is in `build/logs/NAME.log`.
To debug one test, use its executable instead of `build/program`:

```sh
# First terminal (substitute a name printed by make test):
qemu-aarch64 -g 1234 build/tests/NAME
# Second terminal:
gdb-multiarch -q build/tests/NAME
```

Then enter `target remote localhost:1234`, `break PROCEDURE`, and `continue`.
The procedure name is a label from your `src/` files. Tests also check
preserved registers and restored SP; correct-looking output alone may not pass.

## Rebuilds and common problems

- **Changed source:** end the old session, stop the old QEMU if it remains
  (Ctrl+C in terminal 1), rebuild, and start both commands again. An existing
  QEMU process still runs the old executable.
- **Connection refused:** start `make debug` first and use the same port.
- **Address already in use:** stop the previous QEMU or use another port.
- **QEMU DSO warning:** some bundled QEMU/GDB versions print a warning about a
  system-supplied DSO string table when connecting. You can proceed with
  breakpoints, instruction stepping, and register inspection.
- **No source lines:** use `make clean && make`, then load the matching executable.
- **`bt` or `finish` looks wrong:** your lab functions omit unwind annotations.
  GDB may have to infer saved register locations. Use `si` and breakpoints
  to follow calls, and inspect SP, LR, and stack memory directly.
- **Infinite loop:** interrupt from GDB with Ctrl+C; if it does not respond,
  stop QEMU from terminal 1 and restart the session. Automated tests time out.

References: [GDB stepping](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Continuing-and-Stepping.html),
[GDB memory examination](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Memory.html),
[QEMU user-mode debugger option](https://www.qemu.org/docs/master/user/main.html).
