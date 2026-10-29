# REQUIRES: powerpc-registered-target
# RUN: %clang --target=powerpc64-unknown-xbox360-ilp32 -c %s -o %t.o
# RUN: not %clang --target=powerpc64-unknown-xbox360-ilp32 -mno-vmx128 -c %s \
# RUN:   -o /dev/null 2>&1 | FileCheck --check-prefix=ERR %s

# The Xbox 360 assembler accepts VMX128 by default.

# ERR: error: instruction use requires an option to be enabled
# ERR: error: invalid register name
vaddfp128 %v3, %v4, %v5
vaddfp128 %v3, %v4, %v100
vor %v2, %v3, %v4
