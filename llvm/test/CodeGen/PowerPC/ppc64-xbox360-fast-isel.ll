; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -O0 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s

; FastISel assumes 64-bit pointers on a 64-bit processor, so the Xbox 360 uses
; SelectionDAG at -O0. Stack addresses are 32-bit.
; CHECK-LABEL: pass_alloca:
; CHECK:       addi 3, 1, {{[0-9]+}}
; CHECK:       bl use

declare void @use(ptr)

define void @pass_alloca() {
  %slot = alloca i8, align 1
  call void @use(ptr %slot)
  ret void
}
