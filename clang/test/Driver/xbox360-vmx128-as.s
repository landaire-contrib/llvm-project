# REQUIRES: powerpc-registered-target
# RUN: %clang --target=powerpc64-unknown-xbox360-ilp32 -c %s -o %t.o
# RUN: llvm-objdump -d --mattr=+vmx128 %t.o | FileCheck %s
# RUN: not %clang --target=powerpc64-unknown-xbox360-ilp32 -mno-vmx128 -c %s \
# RUN:   -o /dev/null 2>&1 | FileCheck --check-prefix=ERR %s

# The Xbox 360 assembler accepts VMX128 by default.

# CHECK: vaddfp128 3, 4, 100
# CHECK: vor 2, 3, 4
# ERR: error: instruction use requires an option to be enabled
vaddfp128 3, 4, 100
vor 2, 3, 4
