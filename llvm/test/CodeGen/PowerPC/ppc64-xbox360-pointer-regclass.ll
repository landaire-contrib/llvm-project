; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s | FileCheck %s

; Pointers are 32 bits wide in 64-bit registers. Inline assembly memory
; operands and frame base registers use the 32-bit pointer register class.

; CHECK-LABEL: asm_memory_operand:
; CHECK:       lwz %r3, 0(%r3)
; CHECK:       blr
define i32 @asm_memory_operand(ptr %p) {
  %v = call i32 asm sideeffect "lwz $0, $1", "=r,*m"(ptr elementtype(i32) %p)
  ret i32 %v
}

; The frame exceeds the 16-bit displacement range, so local stack slot
; allocation materializes a frame base register.
; CHECK-LABEL: large_frame_copy:
; CHECK:       stwu %r0, -4096(%r1)
; CHECK:       add [[BASE:%r[0-9]+]], %r1, [[BASE]]
; CHECK:       ld [[WORD:%r[0-9]+]], 24([[BASE]])
; CHECK:       std [[WORD]], 24(%r3)
; CHECK:       lwz %r1, 0(%r1)
; CHECK:       blr
define void @large_frame_copy(ptr align 8 %dst) {
  %small = alloca [32 x i8], align 8
  %big0 = alloca [29208 x i8], align 8
  %big1 = alloca [29208 x i8], align 8
  call void @llvm.memcpy.p0.p0.i32(ptr align 8 %dst, ptr %small, i32 32, i1 false)
  call void @llvm.memcpy.p0.p0.i32(ptr %big0, ptr %big1, i32 0, i1 false)
  ret void
}

; A probed dynamic allocation keeps the stack pointer updates 32 bits wide.
; CHECK-LABEL: probed_alloca:
; CHECK:       stwux %r3, %r1, %r5
; CHECK:       stwu %r3, -4096(%r1)
; CHECK:       blr
define void @probed_alloca(i32 %n) "probe-stack"="inline-asm" {
  %p = alloca i8, i32 %n, align 16
  call void @use(ptr %p)
  ret void
}

declare void @use(ptr)
