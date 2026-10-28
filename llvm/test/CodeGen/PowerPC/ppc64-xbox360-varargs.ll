; RUN: split-file %s %t
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/definition.ll 2>&1 | FileCheck %s --check-prefix=DEFINITION
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/stack-call.ll 2>&1 | FileCheck %s --check-prefix=STACK
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/floating-call.ll 2>&1 | FileCheck %s --check-prefix=FLOAT
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/aggregate-call.ll 2>&1 | FileCheck %s --check-prefix=AGGREGATE
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/fixed-float-definition.ll 2>&1 | FileCheck %s --check-prefix=FIXED
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/fixed-float-call.ll 2>&1 | FileCheck %s --check-prefix=FIXED

; DEFINITION: variadic function definitions are not yet supported by the xbox360 feature
; STACK: stack-passed variadic arguments are not yet supported by the xbox360 feature
; FLOAT: only integer and pointer arguments are supported by the xbox360 feature
; AGGREGATE: only integer and pointer arguments are supported by the xbox360 feature
; FIXED: only integer and pointer arguments are supported by the xbox360 feature

;--- definition.ll
define void @definition(i32 %fixed, ...) {
  ret void
}

;--- stack-call.ll
declare i32 @sink(ptr, ...)

define i32 @stack_call(ptr %format) {
  %result = call i32 (ptr, ...) @sink(ptr %format, i32 1, i32 2, i32 3,
                                     i32 4, i32 5, i32 6, i32 7, i32 8)
  ret i32 %result
}

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
