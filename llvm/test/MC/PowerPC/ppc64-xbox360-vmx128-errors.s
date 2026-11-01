# RUN: not llvm-mc -triple powerpc64-unknown-xbox360-ilp32 -mattr=+vmx128 %s 2>&1 \
# RUN:   | FileCheck %s
# RUN: not llvm-mc -triple powerpc-unknown-xbox360 -mattr=+vmx128 %s 2>&1 \
# RUN:   | FileCheck %s

# Classic AltiVec instructions and the Xenon X-forms name v0-v31 only.
# CHECK: [[@LINE+1]]:9: error: invalid operand for instruction
vaddubm %v32, %v1, %v2
# CHECK: [[@LINE+1]]:15: error: invalid operand for instruction
vaddubm %v31, %v32, %v2
# CHECK: [[@LINE+1]]:22: error: invalid operand for instruction
vperm %v1, %v2, %v3, %v100
# CHECK: [[@LINE+1]]:5: error: invalid operand for instruction
lvx %v32, 0, %r1
# CHECK: [[@LINE+1]]:6: error: invalid operand for instruction
lvlx %v32, 0, %r1
# CHECK: [[@LINE+1]]:8: error: invalid operand for instruction
stvrxl %v127, 0, %r1

# VMX128 instructions name v0-v127.
# CHECK: [[@LINE+1]]:11: error: invalid register name
vaddfp128 %v128, %v0, %v0
# CHECK: [[@LINE+1]]:21: error: invalid operand for instruction
lvx128 %v0, 0, %r1, %r2

# The vperm128 permute control names v0-v7.
# CHECK: [[@LINE+1]]:25: error: invalid operand for instruction
vperm128 %v0, %v1, %v2, %v8
# CHECK: [[@LINE+1]]:25: error: invalid operand for instruction
vperm128 %v0, %v1, %v2, %v31

# Immediates.
# CHECK: [[@LINE+1]]:26: error: invalid operand for instruction
vsldoi128 %v0, %v1, %v2, 16
# CHECK: [[@LINE+1]]:26: error: invalid operand for instruction
vsldoi128 %v0, %v1, %v2, -1
# CHECK: [[@LINE+1]]:18: error: invalid operand for instruction
vspltisw128 %v0, 16
# CHECK: [[@LINE+1]]:18: error: invalid operand for instruction
vspltisw128 %v0, -17
# CHECK: [[@LINE+1]]:23: error: invalid operand for instruction
vcfpsxws128 %v0, %v1, 32
# CHECK: [[@LINE+1]]:22: error: invalid operand for instruction
vcuxwfp128 %v0, %v1, -1
# CHECK: [[@LINE+1]]:21: error: invalid operand for instruction
vspltw128 %v0, %v1, 32
# CHECK: [[@LINE+1]]:22: error: invalid operand for instruction
vpermwi128 %v0, %v1, 256
# CHECK: [[@LINE+1]]:21: error: invalid operand for instruction
vrlimi128 %v0, %v1, 16, 0
# CHECK: [[@LINE+1]]:25: error: invalid operand for instruction
vrlimi128 %v0, %v1, 15, 4
# CHECK: [[@LINE+1]]:21: error: invalid operand for instruction
vpkd3d128 %v0, %v1, 8, 0, 0
# CHECK: [[@LINE+1]]:24: error: invalid operand for instruction
vpkd3d128 %v0, %v1, 7, 4, 0
# CHECK: [[@LINE+1]]:27: error: invalid operand for instruction
vpkd3d128 %v0, %v1, 7, 3, 4
# CHECK: [[@LINE+1]]:22: error: invalid operand for instruction
vupkd3d128 %v0, %v1, 8

# Tied destinations.
# CHECK: [[@LINE+1]]:27: error: operand must match destination register
vmaddfp128 %v1, %v2, %v3, %v4
# CHECK: [[@LINE+1]]:23: error: operand must match destination register
vmaddcfp128 %v1, %v2, %v3, %v4
# CHECK: [[@LINE+1]]:28: error: operand must match destination register
vnmsubfp128 %v1, %v2, %v3, %v100
# CHECK: [[@LINE+1]]:24: error: operand must match destination register
vsel128 %v1, %v2, %v3, %v65
# CHECK: [[@LINE+1]]:1: error: too few operands for instruction
vsel128 %v1, %v2, %v3
