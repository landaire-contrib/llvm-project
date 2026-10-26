// RUN: %clang -### -target powerpc64-unknown-xbox360-ilp32 -c %s 2>&1 | FileCheck %s

// CHECK: "-cc1"
// CHECK: "-triple" "powerpc64-unknown-xbox360-ilp32"
// CHECK-NOT: "-target-abi"
