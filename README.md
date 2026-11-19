# Lab 1 — Array statistics and classification

Traverse signed 64-bit integers using nested procedures and explicit memory access.

## Start in GitHub Codespaces

1. Create your own repository using **Use this template → Create a new repository**,
   or open the private assignment repository your instructor provides.
2. Select **Code → Codespaces → Create codespace on main**. Wait for the container build.
3. In the terminal, run `make run`. For a lab, the initial TODO exit is expected.
4. Follow [Getting started](ASSIGNMENT.md#getting-started) to edit your first
   procedure, run its tests, and debug it in GDB.
5. Commit and push your work. Open **Actions → Autograding** to inspect feedback.

```sh
make                 # assemble and link
make run             # execute main under QEMU
make test            # full public test suite
make debug           # terminal 1: wait for GDB
make gdb             # terminal 2: connect to the waiting program
make disassemble     # inspect assembled instructions
```

[LEGv8 → AArch64 guide](docs/legv8-to-aarch64.md) ·
[Assembler directives](docs/assembler-directives.md) ·
[GDB walkthrough](docs/debugging.md) ·
[Grading and instructor setup](docs/grading.md)

## Environment

Ubuntu 24.04, GNU AArch64 binutils, QEMU user mode, Make, and
`gdb-multiarch`. Git and CA certificates support the Codespaces workflow.
The container supplies everything; there are no required editor extensions,
C compiler, C runtime, Python packages, or guest ARM operating system.
For an existing Ubuntu/Debian machine, use
`sudo bash scripts/install-tools.sh` once.

Code is real ARMv8-A AArch64 GNU assembly. The instruction list in the
transition guide is a recommendation, not a whitelist. Preserve the
documented interfaces and meaningful helper calls.

Edit `src/` for your submission. `support/`, `tests/`, and the build scripts
are supplied infrastructure. Generated files stay in ignored `build/`.
See [grading](docs/grading.md) for the automated/manual point split.
