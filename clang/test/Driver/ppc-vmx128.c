// RUN: %clang -### --target=powerpc64-unknown-xbox360-ilp32 -mvmx128 -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=ON %s
// RUN: %clang -### --target=powerpc-unknown-linux-gnu -mvmx128 -c %s 2>&1 \
// RUN:   | FileCheck --check-prefix=ON %s
// RUN: %clang -### --target=powerpc64-unknown-xbox360-ilp32 -mvmx128 -mno-vmx128 \
// RUN:   -c %s 2>&1 | FileCheck --check-prefix=OFF %s
// ON: "-target-feature" "+vmx128"
// OFF: "-target-feature" "-vmx128"

// VMX128 is on by default for the Xbox 360 only.
// RUN: %clang --target=powerpc64-unknown-xbox360-ilp32 -E -dM %s \
// RUN:   | FileCheck --check-prefixes=ALTIVEC,VMX128 %s
// RUN: %clang --target=powerpc-unknown-linux-gnu -mvmx128 -E -dM %s \
// RUN:   | FileCheck --check-prefixes=ALTIVEC,VMX128 %s
// RUN: %clang --target=powerpc64-unknown-xbox360-ilp32 -mno-vmx128 -E -dM %s \
// RUN:   | FileCheck --check-prefixes=ALTIVEC,NOVMX128 %s
// RUN: %clang --target=powerpc64-unknown-linux-gnu -E -dM %s \
// RUN:   | FileCheck --check-prefixes=ALTIVEC,NOVMX128 %s
// RUN: %clang --target=powerpc-unknown-linux-gnu -maltivec -E -dM %s \
// RUN:   | FileCheck --check-prefixes=ALTIVEC,NOVMX128 %s
// RUN: %clang --target=powerpc64-unknown-xbox360-ilp32 -mno-altivec -E -dM %s \
// RUN:   | FileCheck --check-prefixes=NOALTIVEC,NOVMX128 %s
// RUN: %clang --target=powerpc64-unknown-xbox360-ilp32 -mcpu=pwr7 -E -dM %s \
// RUN:   | FileCheck --check-prefixes=ALTIVEC,NOVMX128 %s
// RUN: %clang --target=powerpc64-unknown-xbox360-ilp32 -mcpu=pwr7 -mvmx128 -E -dM %s \
// RUN:   | FileCheck --check-prefixes=ALTIVEC,VMX128,NOVSX %s
// ALTIVEC: #define __ALTIVEC__ 1
// NOALTIVEC-NOT: #define __ALTIVEC__
// VMX128: #define __VMX128__ 1
// NOVMX128-NOT: #define __VMX128__
// NOVSX-NOT: #define __VSX__

// RUN: not %clang --target=powerpc64-unknown-xbox360-ilp32 -fsyntax-only -mvmx128 \
// RUN:   -mvsx %s 2>&1 | FileCheck --check-prefix=ERR-VSX %s
// RUN: not %clang --target=powerpc64-unknown-xbox360-ilp32 -fsyntax-only -mvmx128 \
// RUN:   -mno-altivec %s 2>&1 | FileCheck --check-prefix=ERR-ALTIVEC %s
// RUN: not %clang --target=powerpc64-unknown-xbox360-ilp32 -fsyntax-only -mvmx128 \
// RUN:   -msoft-float %s 2>&1 | FileCheck --check-prefix=ERR-SOFT %s
// ERR-VSX: error: option '-mvmx128' cannot be specified with '-mvsx'
// ERR-ALTIVEC: error: option '-mvmx128' cannot be specified with '-mno-altivec'
// ERR-SOFT: error: option '-mvmx128' cannot be specified with '-msoft-float'
