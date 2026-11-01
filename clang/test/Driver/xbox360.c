// RUN: %clang -### -target powerpc64-unknown-xbox360-ilp32 -c %s 2>&1 | FileCheck %s
// RUN: %clang -### -target powerpc64-unknown-xbox360-ilp32 -fpic -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=PIC1 %s
// RUN: %clang -### -target powerpc64-unknown-xbox360-ilp32 -fPIC -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=PIC2 %s
// RUN: %clang -### -target powerpc64-unknown-xbox360 -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=HV %s
// RUN: %clang --target=powerpc64-unknown-xbox360-ilp32 -print-effective-triple \
// RUN:   | FileCheck --check-prefix=TRIPLE-ILP32 %s
// RUN: %clang --target=powerpc64-unknown-xbox360 -print-effective-triple \
// RUN:   | FileCheck --check-prefix=TRIPLE-HV %s

// CHECK: "-cc1"
// CHECK: "-triple" "powerpc64-unknown-xbox360-ilp32"
// CHECK: "-mrelocation-model" "static"
// CHECK-NOT: "-target-abi"

// PIC1: "-mrelocation-model" "pic" "-pic-level" "1"
// PIC2: "-mrelocation-model" "pic" "-pic-level" "2"

// HV: "-cc1"
// HV: "-triple" "powerpc64-unknown-xbox360"
// HV: "-mrelocation-model" "static"
// HV-NOT: "-target-abi"

// TRIPLE-ILP32: powerpc64-unknown-xbox360-ilp32
// TRIPLE-HV: powerpc64-unknown-xbox360{{$}}
