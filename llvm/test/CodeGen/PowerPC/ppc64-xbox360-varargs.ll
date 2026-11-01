; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -O0 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=O0

declare i32 @sink(i32, ...)

; Variadic calls do not set or clear CR bit 6, even without optimization.
; O0-LABEL: call_i32_overflow:
; O0-NOT:   crxor
; O0-NOT:   creqv
; O0:       bl sink

; CHECK-LABEL: call_i32_overflow:
; CHECK-DAG:   stw {{[0-9]+}}, 84(1)
; CHECK-DAG:   stw {{[0-9]+}}, 92(1)
; CHECK-DAG:   stw {{[0-9]+}}, 100(1)
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
; CHECK-DAG:   std {{[0-9]+}}, 80(1)
; CHECK-DAG:   stw {{[0-9]+}}, 92(1)
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
; CHECK:       stwu 1, -32(1)
; CHECK:       std 4, 56(1)
; CHECK:       std 5, 64(1)
; CHECK:       std 6, 72(1)
; CHECK:       std 7, 80(1)
; CHECK:       std 8, 88(1)
; CHECK:       std 9, 96(1)
; CHECK:       std 10, 104(1)
; CHECK:       lwz 3, 60(1)

define i32 @take_i32(i32 %tag, ...) {
  %args = alloca ptr, align 4
  call void @llvm.va_start(ptr %args)
  %result = va_arg ptr %args, i32
  call void @llvm.va_end(ptr %args)
  ret i32 %result
}

; CHECK-LABEL: take_i64_then_i32:
; CHECK:       std 4, 56(1)
; CHECK:       lwa 3, 4(3)
; CHECK:       add 3, 4, 3

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
; CHECK:       lwz 3, 60(1)

define ptr @take_pointer(i32 %tag, ...) {
  %args = alloca ptr, align 4
  call void @llvm.va_start(ptr %args)
  %result = va_arg ptr %args, ptr
  call void @llvm.va_end(ptr %args)
  ret ptr %result
}

; CHECK-LABEL: take_first_overflow:
; CHECK:       lwz 3, 116(1)

define i32 @take_first_overflow(
    i32 %a, i32 %b, i32 %c, i32 %d, i32 %e, i32 %f, i32 %g, i32 %h, ...) {
  %args = alloca ptr, align 4
  call void @llvm.va_start(ptr %args)
  %result = va_arg ptr %args, i32
  call void @llvm.va_end(ptr %args)
  ret i32 %result
}

; CHECK-LABEL: copy_varargs:
; CHECK:       lwz 3, 60(1)

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
