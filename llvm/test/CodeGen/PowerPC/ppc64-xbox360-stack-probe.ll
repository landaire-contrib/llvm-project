; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s

; Each Xbox 360 thread stack is guarded by a single unmapped 4 KiB page, so
; frames larger than 4096 bytes and dynamic allocations touch every page from
; the top down.

declare void @use(ptr)

; The back-chain store probes a frame of at most 4096 bytes.
; CHECK-LABEL: frame_4096:
; CHECK:       mflr 0
; CHECK-NEXT:  stw 0, -8(1)
; CHECK-NEXT:  stwu 1, -4096(1)
; CHECK-NEXT:  .cfi_def_cfa_offset 4096

define void @frame_4096() {
  %slot = alloca [4000 x i8], align 16
  call void @use(ptr %slot)
  ret void
}

; CHECK-LABEL: frame_8k:
; CHECK:       mflr 0
; CHECK-NEXT:  stw 0, -8(1)
; CHECK-NEXT:  mr 0, 1
; CHECK-NEXT:  .cfi_def_cfa r0, 0
; CHECK-NEXT:  stwu 0, -96(1)
; CHECK-NEXT:  stwu 0, -4096(1)
; CHECK-NEXT:  stwu 0, -4096(1)
; CHECK-NEXT:  .cfi_def_cfa_register r1
; CHECK-NEXT:  .cfi_def_cfa_offset 8288
; CHECK:       addi 1, 1, 8288
; CHECK-NEXT:  lwz 0, -8(1)

define void @frame_8k() {
  %slot = alloca [8192 x i8], align 16
  call void @use(ptr %slot)
  ret void
}

; CHECK-LABEL: frame_64k:
; CHECK:       stwu 0, -{{[0-9]+}}(1)
; CHECK-NEXT:  li 12, 16
; CHECK-NEXT:  mtctr 12
; CHECK-NEXT:  .LBB{{[0-9_]+}}:
; CHECK-NEXT:  stwu 0, -4096(1)
; CHECK-NEXT:  bdnz .LBB
; CHECK:       lwz 1, 0(1)

define void @frame_64k() {
  %slot = alloca [65536 x i8], align 16
  call void @use(ptr %slot)
  ret void
}

; Dynamic allocations probe each 4 KiB block with a 32-bit store-with-update.
; CHECK-LABEL: dynamic_alloca:
; CHECK:       stwux [[CHAIN:[0-9]+]], 1, {{[0-9]+}}
; CHECK:       .LBB{{[0-9_]+}}:
; CHECK-NEXT:  stwu [[CHAIN]], -4096(1)
; CHECK-NEXT:  cmpw 1, {{[0-9]+}}
; CHECK-NEXT:  bne 0, .LBB

define void @dynamic_alloca(i32 %size) {
  %slot = alloca i8, i32 %size, align 16
  call void @use(ptr %slot)
  ret void
}

; Realigned frames probe with 32-bit compares and stores.
; CHECK-LABEL: aligned_8k:
; CHECK:       clrlwi 12, 1, 26
; CHECK:       cmpwi 12, -4096
; CHECK:       stwu 30, -4096(1)
; CHECK:       stwux 30, 1, 12
; CHECK:       mr 1, 30

define void @aligned_8k() {
  %slot = alloca [8192 x i8], align 64
  call void @use(ptr %slot)
  ret void
}

; An explicit probe-stack attribute overrides the default.
; CHECK-LABEL: no_probe:
; CHECK:       stwu 1, -8288(1)

define void @no_probe() "probe-stack"="none" {
  %slot = alloca [8192 x i8], align 16
  call void @use(ptr %slot)
  ret void
}
