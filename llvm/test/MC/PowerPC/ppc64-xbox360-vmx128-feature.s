# RUN: not llvm-mc -triple powerpc64-unknown-xbox360-ilp32 -mattr=-vmx128 %s 2>&1 | FileCheck %s
# RUN: not llvm-mc -triple powerpc64-unknown-linux-gnu -mattr=-vmx128,-xbox360 %s 2>&1 | FileCheck %s --check-prefixes=CHECK,NONXBOX

# VMX128 instructions need vmx128; Xenon X-forms also accept Xbox AltiVec.
# The Xbox triple pins its ABI feature, so use a non-Xbox triple for rejection.
# CHECK: [[@LINE+1]]:1: error: instruction use requires an option to be enabled
lvx128 %v31, %r31, %r30
# CHECK: [[@LINE+1]]:1: error: instruction use requires an option to be enabled
vaddfp128 %v31, %v30, %v1
# CHECK: [[@LINE+1]]:1: error: instruction use requires an option to be enabled
vmaddfp128 %v31, %v30, %v1, %v31
# CHECK: [[@LINE+1]]:1: error: instruction use requires an option to be enabled
vperm128 %v31, %v30, %v1, %v7
# CHECK: [[@LINE+1]]:1: error: instruction use requires an option to be enabled
vsldoi128 %v31, %v30, %v1, 15
# CHECK: [[@LINE+1]]:1: error: instruction use requires an option to be enabled
vcmpeqfp128. %v31, %v30, %v1
# CHECK: [[@LINE+1]]:1: error: instruction use requires an option to be enabled
vspltisw128 %v31, -16
# CHECK: [[@LINE+1]]:1: error: instruction use requires an option to be enabled
vrlimi128 %v31, %v1, 15, 3
# CHECK: [[@LINE+1]]:1: error: instruction use requires an option to be enabled
vpermwi128 %v31, %v1, 228
# NONXBOX: [[@LINE+1]]:1: error: instruction use requires an option to be enabled
lvlx %v31, %r31, %r30
# NONXBOX: [[@LINE+1]]:1: error: instruction use requires an option to be enabled
stvrxl %v31, %r31, %r30

# v32-v127 are not registers without vmx128.
# CHECK: [[@LINE+1]]:15: error: invalid register name
vaddubm %v31, %v32, %v2
# CHECK: [[@LINE+1]]:8: error: invalid register name
lvx128 %v127, %r31, %r30
