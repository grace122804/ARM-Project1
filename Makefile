.DEFAULT_GOAL := all
AS := aarch64-linux-gnu-as
LD := aarch64-linux-gnu-ld
ASFLAGS := -g -march=armv8-a -I .
QEMU := qemu-aarch64
GDB := gdb-multiarch
PORT ?= 1234
GROUP ?=
SOURCES := $(wildcard src/*.s)
OBJECTS := $(patsubst %.s,build/%.o,$(SOURCES))
TEST_SOURCES := $(wildcard tests/*.s)
TEST_BINS := $(patsubst tests/%.s,build/tests/%,$(TEST_SOURCES))
.SECONDARY:
.PHONY: all run debug gdb test test-binaries clean disassemble help
all: build/program
build/program: $(OBJECTS) build/support/start.o build/support/runtime.o
	$(LD) -o $@ $^
build/%.o: %.s $(wildcard support/*.inc)
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<
build/tests/%: build/tests/%.o $(OBJECTS) build/support/abi.o build/support/runtime.o
	$(LD) -o $@ $^
test-binaries: $(TEST_BINS)
run: build/program
	$(QEMU) $<
debug: build/program
	@echo 'QEMU is waiting. Open a second terminal and run: make gdb'
	$(QEMU) -g $(PORT) $<
gdb: build/program
	$(GDB) -q $< -ex 'target remote localhost:$(PORT)' -ex 'break main' -ex 'display/i $$pc'
test:
	+bash scripts/grade.sh "$(GROUP)"
disassemble: build/program
	aarch64-linux-gnu-objdump -d $<
clean:
	rm -rf build
help:
	@echo 'make | make run | make test [GROUP=name] | make debug | make gdb | make disassemble | make clean'
