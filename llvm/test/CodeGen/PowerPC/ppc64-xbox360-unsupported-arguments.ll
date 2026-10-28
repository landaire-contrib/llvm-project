; RUN: split-file %s %t
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=+altivec \
; RUN:   < %t/vector.ll 2>&1 | FileCheck %s --check-prefix=ARGUMENT
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/f128.ll 2>&1 | FileCheck %s --check-prefix=ARGUMENT
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/variadic-f32.ll 2>&1 | FileCheck %s --check-prefix=ARGUMENT
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/variadic-byval.ll 2>&1 | FileCheck %s --check-prefix=ARGUMENT
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/f32-vaarg.ll 2>&1 | FileCheck %s --check-prefix=VAARG
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/f128-return.ll 2>&1 | FileCheck %s --check-prefix=RETURN
; RUN: not llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   < %t/i256-return.ll 2>&1 | FileCheck %s --check-prefix=RETURN

; ARGUMENT: unsupported xbox360 argument type
; VAARG: only i32, pointer, i64, and f64 va_arg types are supported by the xbox360 feature
; RETURN: unsupported xbox360 return type

;--- vector.ll
declare void @vector_sink(<4 x i32>)

define void @vector(<4 x i32> %value) {
  call void @vector_sink(<4 x i32> %value)
  ret void
}


;--- f128.ll
declare void @f128_sink(fp128)

define void @f128(fp128 %value) {
  call void @f128_sink(fp128 %value)
  ret void
}

;--- f128-return.ll
define fp128 @f128_return() {
  ret fp128 0xL00000000000000000000000000000000
}

;--- i256-return.ll
define i256 @i256_return() {
  ret i256 0
}

;--- variadic-f32.ll
declare void @variadic_sink(i32, ...)

define void @variadic_f32(float %value) {
  call void (i32, ...) @variadic_sink(i32 0, float %value)
  ret void
}

;--- f32-vaarg.ll
declare void @llvm.va_start(ptr)

define float @f32_vaarg(i32 %tag, ...) {
  %args = alloca ptr, align 4
  call void @llvm.va_start(ptr %args)
  %result = va_arg ptr %args, float
  ret float %result
}


;--- variadic-byval.ll
%struct.Value = type { i32, i32 }

declare void @variadic_byval_sink(i32, ...)

define void @variadic_byval(ptr %value) {
  call void (i32, ...) @variadic_byval_sink(
      i32 0, ptr byval(%struct.Value) align 4 %value)
  ret void
}
