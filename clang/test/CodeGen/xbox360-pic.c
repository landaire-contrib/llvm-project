// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -mllvm -ppc-reg-with-percent-prefix -triple powerpc64-unknown-xbox360-ilp32 -mrelocation-model pic \
// RUN:   -pic-level 1 -O2 -S -o - %s | FileCheck --check-prefix=SMALL %s
// RUN: %clang_cc1 -mllvm -ppc-reg-with-percent-prefix -triple powerpc64-unknown-xbox360-ilp32 -mrelocation-model pic \
// RUN:   -pic-level 2 -O2 -S -o - %s | FileCheck --check-prefix=BIG %s
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -mrelocation-model pic \
// RUN:   -pic-level 2 -emit-llvm -o - %s | FileCheck --check-prefix=IR %s

extern int global;
extern void callee(void);

// SMALL-LABEL: use:
// SMALL:       bl _GLOBAL_OFFSET_TABLE_@local-4
// SMALL:       bl callee@PLT
// SMALL:       lwz %r3, global@GOT(%r30)

// BIG:         .LTOC = {{.*}}+32768
// BIG:         .L0$poff:
// BIG-NEXT:    .long .LTOC-.L0$pb
// BIG-LABEL:   use:
// BIG:         bl callee@PLT
// BIG:         lwz %r3, .LC0-.LTOC(%r30)

// IR: !{i32 8, !"PIC Level", i32 2}
int use(void) {
  callee();
  return global;
}
