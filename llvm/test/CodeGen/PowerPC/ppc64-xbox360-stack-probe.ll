; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s

; Each Xbox 360 thread stack is guarded by a single unmapped 4 KiB page, so
; frames larger than 4096 bytes and dynamic allocations touch every page from
; the top down.

declare void @use(ptr)

; The back-chain store probes a frame of at most 4096 bytes.
; CHECK-LABEL: frame_4096:
; CHECK:       mflr %r0
; CHECK-NEXT:  stw %r0, -8(%r1)
; CHECK-NEXT:  stwu %r1, -4096(%r1)
; CHECK-NEXT:  .cfi_def_cfa_offset 4096

define void @frame_4096() {
  %slot = alloca [4000 x i8], align 16
  call void @use(ptr %slot)
  ret void
}

; CHECK-LABEL: frame_8k:
; CHECK:       mflr %r0
; CHECK-NEXT:  stw %r0, -8(%r1)
; CHECK-NEXT:  mr %r0, %r1
; CHECK-NEXT:  .cfi_def_cfa r0, 0
; CHECK-NEXT:  stwu %r0, -96(%r1)
; CHECK-NEXT:  stwu %r0, -4096(%r1)
; CHECK-NEXT:  stwu %r0, -4096(%r1)
; CHECK-NEXT:  .cfi_def_cfa_register r1
; CHECK-NEXT:  .cfi_def_cfa_offset 8288
; CHECK:       addi %r1, %r1, 8288
; CHECK-NEXT:  lwz %r0, -8(%r1)

define void @frame_8k() {
  %slot = alloca [8192 x i8], align 16
  call void @use(ptr %slot)
  ret void
}

; CHECK-LABEL: frame_64k:
; CHECK:       stwu %r0, -{{[0-9]+}}(%r1)
; CHECK-NEXT:  li %r12, 16
; CHECK-NEXT:  mtctr %r12
; CHECK-NEXT:  .LBB{{[0-9_]+}}:
; CHECK-NEXT:  stwu %r0, -4096(%r1)
; CHECK-NEXT:  bdnz .LBB
; CHECK:       lwz %r1, 0(%r1)

define void @frame_64k() {
  %slot = alloca [65536 x i8], align 16
  call void @use(ptr %slot)
  ret void
}

; Dynamic allocations probe each 4 KiB block with a 32-bit store-with-update.
; CHECK-LABEL: dynamic_alloca:
; CHECK:       stwux [[CHAIN:%r[0-9]+]], %r1, {{%r[0-9]+}}
; CHECK:       .LBB{{[0-9_]+}}:
; CHECK-NEXT:  stwu [[CHAIN]], -4096(%r1)
; CHECK-NEXT:  cmpw %r1, {{%r[0-9]+}}
; CHECK-NEXT:  bne %cr0, .LBB

define void @dynamic_alloca(i32 %size) {
  %slot = alloca i8, i32 %size, align 16
  call void @use(ptr %slot)
  ret void
}

; Realigned frames probe with 32-bit compares and stores.
; CHECK-LABEL: aligned_8k:
; CHECK:       clrlwi %r12, %r1, 26
; CHECK:       cmpwi %r12, -4096
; CHECK:       stwu %r30, -4096(%r1)
; CHECK:       stwux %r30, %r1, %r12
; CHECK:       mr %r1, %r30

define void @aligned_8k() {
  %slot = alloca [8192 x i8], align 64
  call void @use(ptr %slot)
  ret void
}

; An explicit probe-stack attribute overrides the default.
; CHECK-LABEL: no_probe:
; CHECK:       stwu %r1, -8288(%r1)

define void @no_probe() "probe-stack"="none" {
  %slot = alloca [8192 x i8], align 16
  call void @use(ptr %slot)
  ret void
}
