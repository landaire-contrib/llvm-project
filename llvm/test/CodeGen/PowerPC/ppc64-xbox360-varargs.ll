; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -O0 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=O0

declare i32 @sink(i32, ...)

; Variadic calls do not set or clear CR bit 6, even without optimization.
; O0-LABEL: call_i32_overflow:
; O0-NOT:   crxor
; O0-NOT:   creqv
; O0:       bl sink

; CHECK-LABEL: call_i32_overflow:
; CHECK-DAG:   stw {{%r[0-9]+}}, 84(%r1)
; CHECK-DAG:   stw {{%r[0-9]+}}, 92(%r1)
; CHECK-DAG:   stw {{%r[0-9]+}}, 100(%r1)
; CHECK-NOT:   crxor
; CHECK-NOT:   creqv
; CHECK:       bl sink

define i32 @call_i32_overflow() {
  %result = call i32 (i32, ...) @sink(
      i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8,
      i32 9, i32 10)
  ret i32 %result
}

; CHECK-LABEL: call_mixed_overflow:
; CHECK-DAG:   std {{%r[0-9]+}}, 80(%r1)
; CHECK-DAG:   stw {{%r[0-9]+}}, 92(%r1)
; CHECK:       bl sink

define i32 @call_mixed_overflow(ptr %pointer, i64 %value) {
  %result = call i32 (i32, ...) @sink(
      i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, ptr %pointer,
      i64 %value, i32 7)
  ret i32 %result
}

declare void @llvm.va_start(ptr)
declare void @llvm.va_end(ptr)
declare void @llvm.va_copy(ptr, ptr)

; CHECK-LABEL: take_i32:
; CHECK:       stwu %r1, -32(%r1)
; CHECK:       std %r4, 56(%r1)
; CHECK:       std %r5, 64(%r1)
; CHECK:       std %r6, 72(%r1)
; CHECK:       std %r7, 80(%r1)
; CHECK:       std %r8, 88(%r1)
; CHECK:       std %r9, 96(%r1)
; CHECK:       std %r10, 104(%r1)
; CHECK:       lwz %r3, 60(%r1)

define i32 @take_i32(i32 %tag, ...) {
  %args = alloca ptr, align 4
  call void @llvm.va_start(ptr %args)
  %result = va_arg ptr %args, i32
  call void @llvm.va_end(ptr %args)
  ret i32 %result
}

; CHECK-LABEL: take_i64_then_i32:
; CHECK:       std %r4, 56(%r1)
; CHECK:       lwa %r3, 4(%r3)
; CHECK:       add %r3, %r4, %r3

define i64 @take_i64_then_i32(i32 %tag, ...) {
  %args = alloca ptr, align 4
  call void @llvm.va_start(ptr %args)
  %wide = va_arg ptr %args, i64
  %narrow = va_arg ptr %args, i32
  %extended = sext i32 %narrow to i64
  %result = add i64 %wide, %extended
  call void @llvm.va_end(ptr %args)
  ret i64 %result
}

; CHECK-LABEL: take_pointer:
; CHECK:       lwz %r3, 60(%r1)

define ptr @take_pointer(i32 %tag, ...) {
  %args = alloca ptr, align 4
  call void @llvm.va_start(ptr %args)
  %result = va_arg ptr %args, ptr
  call void @llvm.va_end(ptr %args)
  ret ptr %result
}

; CHECK-LABEL: take_first_overflow:
; CHECK:       lwz %r3, 116(%r1)

define i32 @take_first_overflow(
    i32 %a, i32 %b, i32 %c, i32 %d, i32 %e, i32 %f, i32 %g, i32 %h, ...) {
  %args = alloca ptr, align 4
  call void @llvm.va_start(ptr %args)
  %result = va_arg ptr %args, i32
  call void @llvm.va_end(ptr %args)
  ret i32 %result
}

; CHECK-LABEL: copy_varargs:
; CHECK:       lwz %r3, 60(%r1)

define i32 @copy_varargs(i32 %tag, ...) {
  %args = alloca ptr, align 4
  %copy = alloca ptr, align 4
  call void @llvm.va_start(ptr %args)
  call void @llvm.va_copy(ptr %copy, ptr %args)
  %result = va_arg ptr %copy, i32
  call void @llvm.va_end(ptr %copy)
  call void @llvm.va_end(ptr %args)
  ret i32 %result
}
