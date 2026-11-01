// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -O2 -S -o - %s \
// RUN:   | FileCheck %s
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360 -mrelocation-model static \
// RUN:   -O2 -S -o - %s | FileCheck %s

// Atomics compile to reservations in the protected form the Xbox 360 kernel
// loader accepts: the MSR is read once before the loop, "mtmsrd 13, 1"
// directly precedes each l[wd]arx, and "mtmsrd rS, 1" with the saved MSR
// directly follows each st[wd]cx., including the store that ends the
// reservation when the comparison fails.

// CHECK-LABEL: fetch_add:
// CHECK:         sync
// CHECK-NEXT:    mfmsr [[MSR:[0-9]+]]
// CHECK-NEXT:  .LBB0_1:
// CHECK:         mtmsrd 13, 1
// CHECK-NEXT:    lwarx [[OLD:[0-9]+]], 0, 3
// CHECK-NEXT:    add [[NEW:[0-9]+]], 4, [[OLD]]
// CHECK-NEXT:    stwcx. [[NEW]], 0, 3
// CHECK-NEXT:    mtmsrd [[MSR]], 1
// CHECK-NEXT:    bne- 0, .LBB0_1
// CHECK:         lwsync
// CHECK-NEXT:    blr
int fetch_add(int *p, int v) {
  return __atomic_fetch_add(p, v, __ATOMIC_SEQ_CST);
}

// CHECK-LABEL: compare_exchange:
// CHECK:         lwsync
// CHECK-NEXT:    mfmsr [[MSR:[0-9]+]]
// CHECK-NEXT:  .LBB1_1:
// CHECK:         mtmsrd 13, 1
// CHECK-NEXT:    lwarx [[SEEN:[0-9]+]], 0, 3
// CHECK-NEXT:    cmpw [[CR:[0-9]]], [[SEEN]], [[EXPECTED:[0-9]+]]
// CHECK-NEXT:    bne- [[CR]], .LBB1_3
// CHECK:         stwcx. 5, 0, 3
// CHECK-NEXT:    mtmsrd [[MSR]], 1
// CHECK-NEXT:    bne- 0, .LBB1_1
// CHECK-NEXT:    b .LBB1_4
// CHECK-NEXT:  .LBB1_3:
// CHECK-NEXT:    stwcx. [[SEEN]], 0, 3
// CHECK-NEXT:    mtmsrd [[MSR]], 1
// CHECK-NEXT:  .LBB1_4:
// CHECK-NEXT:    cmplw [[SEEN]], [[EXPECTED]]
// CHECK-NEXT:    lwsync
int compare_exchange(int *p, int *expected, int desired) {
  return __atomic_compare_exchange(p, expected, &desired, 0, __ATOMIC_ACQ_REL,
                                   __ATOMIC_ACQUIRE);
}

// CHECK-LABEL: fetch_add_8:
// CHECK:         mfmsr [[MSR:[0-9]+]]
// CHECK-NEXT:  .LBB2_1:
// CHECK:         mtmsrd 13, 1
// CHECK-NEXT:    ldarx [[OLD:[0-9]+]], 0, 3
// CHECK-NEXT:    add [[NEW:[0-9]+]], 4, [[OLD]]
// CHECK-NEXT:    stdcx. [[NEW]], 0, 3
// CHECK-NEXT:    mtmsrd [[MSR]], 1
// CHECK-NEXT:    bne- 0, .LBB2_1
long long fetch_add_8(long long *p, long long v) {
  return __atomic_fetch_add(p, v, __ATOMIC_RELAXED);
}

// CHECK-LABEL: fetch_or_1:
// CHECK:         mfmsr [[MSR:[0-9]+]]
// CHECK:       .LBB3_1:
// CHECK:         mtmsrd 13, 1
// CHECK-NEXT:    lwarx {{[0-9]+}}, 0, [[WORD:[0-9]+]]
// CHECK:         stwcx. {{[0-9]+}}, 0, [[WORD]]
// CHECK-NEXT:    mtmsrd [[MSR]], 1
// CHECK-NEXT:    bne- 0, .LBB3_1
unsigned char fetch_or_1(unsigned char *p, unsigned char v) {
  return __atomic_fetch_or(p, v, __ATOMIC_RELAXED);
}
