# Lab 1: Array statistics and classification

Implement `main`, `analyze_array`, `classify_value`, and `update_min_max`
in their corresponding `src/*.s` files. Use AAPCS64 and preserve live values
across calls. Recommended concepts: `ldur`, pointer arithmetic, loops,
conditional branches, `bl`, stack frames, and `ret`.

## Getting started

### 1. Build the starter in your Codespace

Open **Terminal → New Terminal** and run these commands in the repository
folder. You should see the `Makefile` in the file explorer.

```sh
make
make run
```

`make` assembles and links the starter. `make run` prints a TODO message
because `main` is still a stub. The program exits with status 99 at this stage.

### 2. Get your first tests to pass

Open `src/classify_value.s`. The input arrives in `x0`, and you return the
category in the same register. Replace the TODO comment and the
`b not_implemented` instruction under `classify_value:` with these two
temporary instructions:

```asm
    mov x0, #-1
    ret
```

Leave the lines around the function in place. The
[assembler directives guide](docs/assembler-directives.md) explains them.
Save the file and run:

```sh
make test GROUP=classify
```

Two of the six tests pass because their inputs are negative. The other four
fail because this first attempt returns `-1` for every input. The tests call
`classify_value` directly, so you can work on it while `main` is still a stub.

### 3. Watch one failing test in GDB

In **terminal 1**, start the positive-input test and have QEMU pause for GDB:

```sh
qemu-aarch64 -g 1234 build/tests/classify-positive
```

The terminal will look idle while QEMU waits. Use the **+** button in the
terminal panel to open **terminal 2**, then run:

```sh
gdb-multiarch -q build/tests/classify-positive
```

At the `(gdb)` prompt, enter these commands one at a time:

```gdb
target remote localhost:1234
break classify_value
continue
p/d $x0
x/i $pc
si
p/d $x0
```

The first `p/d $x0` shows the input, **9**. `x/i $pc` shows the next
instruction. `si` executes that one instruction, and the second
`p/d $x0` shows the result, **-1**. This input should return **1**.
Type `continue` to let the test report its failure, then `quit` to exit GDB.
For help with the two terminals or restarting a session, see the
[GDB walkthrough](docs/debugging.md).

### 4. Finish the classifier

Use `cmp x0, #0` and conditional branches to decide which result goes into
`x0`. Make sure each path returns with `ret`. Save and rerun
`make test GROUP=classify`. Aim for **6/6 passed** before moving on to
`update_min_max`.

## Procedure interfaces

| Procedure | Arguments | Result / writes |
| --- | --- | --- |
| `classify_value` | `x0`: signed 64-bit value | `x0`: -1 negative, 0 zero, 1 positive |
| `update_min_max` | `x0`: value; `x1`: results address | Update only the minimum/maximum fields; no return value required |
| `analyze_array` | `x0`: array address; `x1`: element count; `x2`: results address | Write all six result fields; no return value required |
| `main` | None | Analyze the supplied demo array, store in `demo_results`, return 0 |

Results are six consecutive 64-bit fields:

| Byte offset | Field |
| --- | --- |
| 0 | Minimum, signed |
| 8 | Maximum, signed |
| 16 | Sum, signed |
| 24 | Positive count |
| 32 | Negative count |
| 40 | Zero count |

`analyze_array` initializes every result field on each call. For an empty
array it writes six zeros and must not dereference the array pointer (which
may be zero). For nonempty input, initialize minimum and maximum from the
first element, then process all elements. Sums and intermediate running sums
in the test inputs fit signed 64 bits; overflow handling is outside scope.
Counts and lengths are nonnegative 64-bit values.

For every element, `analyze_array` must call `classify_value` and use its
returned category to update the count. It must also call `update_min_max`
and use that procedure to maintain the extrema. Do not duplicate those
helpers' decisions in the caller. `update_min_max` assumes its two fields
already contain valid current extrema and leaves the other four fields alone.
The input array is read-only; output storage is valid, separate, and 48 bytes.

## Main integration

Keep the supplied global data labels. `demo_array` contains
`[-4, 0, 7, -2, 7, 0]`; `demo_length` holds 6. `main` loads their address/count,
calls `analyze_array`, and writes `demo_results`. Expected results:
`[-4, 7, 8, 2, 2, 2]`. Output printing is optional; GDB can inspect the buffer.

## Work and checks

After the classifier passes, build up the rest of the program in this order:

1. Implement `update_min_max` and run `make test GROUP=minmax`.
2. Implement `analyze_array`, using both helpers, and run `make test GROUP=analyze`.
3. Implement `main` and run `make test GROUP=main`.
4. Run `make test` for the full suite before submitting.

See [grading](docs/grading.md) for the 80 automated and 20 manual points.
The recommended instruction subset is advisory. The assignment requires
meaningful helper calls, correct interfaces, and stack and register discipline.
