/// Check that char is signed by default.
// RUN: %clang -### %s --target=powerpc64-unknown-xbox360-ilp32 -c 2>&1 | FileCheck %s
// RUN: %clang -E -dM -x c /dev/null --target=powerpc64-unknown-xbox360-ilp32 \
// RUN:   | FileCheck --check-prefix=MACRO --implicit-check-not=__CHAR_UNSIGNED__ %s
// RUN: %clang -S -emit-llvm -o - %s --target=powerpc64-unknown-xbox360-ilp32 \
// RUN:   | FileCheck --check-prefix=IR %s

// CHECK: "-cc1" "-triple" "powerpc64-unknown-xbox360-ilp32"
// CHECK-NOT: "-fno-signed-char"

// MACRO: #define _XBOX_VER 200

// IR-LABEL: @load_char(
// IR: sext i8
int load_char(char *p) { return *p; }
