; RUN: split-file %s %t
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/floating-call.ll 2>&1 | FileCheck %s --check-prefix=ARGUMENT
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/aggregate-call.ll 2>&1 | FileCheck %s --check-prefix=ARGUMENT
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/fixed-float-definition.ll 2>&1 | FileCheck %s --check-prefix=ARGUMENT
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/fixed-float-call.ll 2>&1 | FileCheck %s --check-prefix=ARGUMENT
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/floating-vaarg.ll 2>&1 | FileCheck %s --check-prefix=VAARG

; ARGUMENT: only integer and pointer arguments are supported by the xbox360 feature
; VAARG: only i32, pointer, and i64 va_arg types are supported by the xbox360 feature

;--- floating-call.ll
declare i32 @sink(ptr, ...)

define i32 @floating_call(ptr %format) {
  %result = call i32 (ptr, ...) @sink(ptr %format, double 1.0)
  ret i32 %result
}

;--- aggregate-call.ll
%struct.S = type { i32 }

declare i32 @sink(ptr, ...)

define i32 @aggregate_call(ptr %format, ptr %value) {
  %result = call i32 (ptr, ...) @sink(
      ptr %format, ptr byval(%struct.S) align 4 %value)
  ret i32 %result
}

;--- fixed-float-definition.ll
define void @fixed_float_definition(double %value) {
  ret void
}

;--- fixed-float-call.ll
declare void @fixed_float_sink(double)

define void @fixed_float_call() {
  call void @fixed_float_sink(double 1.0)
  ret void
}

;--- floating-vaarg.ll
declare void @llvm.va_start(ptr)

define double @floating_vaarg(i32 %tag, ...) {
  %args = alloca ptr, align 4
  call void @llvm.va_start(ptr %args)
  %result = va_arg ptr %args, double
  ret double %result
}
