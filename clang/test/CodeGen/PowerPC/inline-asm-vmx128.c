// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -emit-llvm %s -o - \
// RUN:   | FileCheck %s
// RUN: %clang_cc1 -mllvm -ppc-reg-with-percent-prefix -triple powerpc64-unknown-xbox360-ilp32 -O2 -S %s -o - \
// RUN:   | FileCheck %s --check-prefix=ASM
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -target-feature -vmx128 \
// RUN:   -fsyntax-only -verify=novmx128 %s
// RUN: %clang_cc1 -triple powerpc64-unknown-linux-gnu -target-feature +altivec \
// RUN:   -fsyntax-only -verify=novmx128 %s

// v32-v127 can be named in inline asm with vmx128 only.

typedef float v4f __attribute__((vector_size(16)));

// CHECK-LABEL: @clobber(
// CHECK: call void asm sideeffect "vspltisw128 %v100, 0", "~{v100}"()
// ASM-LABEL: clobber:
// ASM: stvx128 %v100,
// ASM: #APP
// ASM-NEXT: vspltisw128 %v100, 0
// ASM-NEXT: #NO_APP
// ASM: lvx128 %v100,
// ASM: blr
void clobber(void) {
  __asm__ volatile("vspltisw128 %%v100, 0" ::: "v100"); // novmx128-error {{unknown register name 'v100' in asm}}
}

// CHECK-LABEL: @fixed(
// CHECK: call <4 x float> asm "vaddfp128 $0, $0, $0", "={v127},{v127}"(<4 x float>
// ASM-LABEL: fixed:
// ASM: vor128 %v127, %v1, %v1
// ASM: #APP
// ASM-NEXT: vaddfp128 %v127, %v127, %v127
// ASM-NEXT: #NO_APP
// ASM: vor128 %v1, %v127, %v127
v4f fixed(v4f a) {
  register v4f x __asm__("v127") = a; // novmx128-error {{unknown register name 'v127' in asm}}
  __asm__("vaddfp128 %0, %0, %0" : "+v"(x));
  return x;
}

// v31 stays valid without vmx128.
// CHECK-LABEL: @low(
// CHECK: "~{v31}"()
void low(void) { __asm__ volatile("" ::: "v31"); }
