; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s

declare double @mixed_sink(i32, float, i32, double, i32, float, i32, double, i32)
declare double @many_double_sink(i32, double, double, double, double, double,
                                 double, double, double, double, double, double,
                                 double, double, double, double)
declare i32 @variadic_sink(i32, ...)
declare void @llvm.va_start(ptr)

; Every fixed argument occupies an 8-byte positional slot. Floating arguments
; use FPRs while shadowing the corresponding GPR positions.
; CHECK-LABEL: call_mixed:
; CHECK-DAG:   li 3, 1
; CHECK-DAG:   li 5, 2
; CHECK-DAG:   li 7, 3
; CHECK-DAG:   li 9, 4
; CHECK-DAG:   stw {{[0-9]+}}, 84(1)
; CHECK:       bl mixed_sink

define double @call_mixed(float %b, double %d, float %f, double %h) {
  %result = call double @mixed_sink(
      i32 1, float %b, i32 2, double %d, i32 3, float %f, i32 4, double %h,
      i32 5)
  ret double %result
}

; F1-F13 carry the first thirteen floating arguments. The next doubles occupy
; the starts of their positional 8-byte stack slots.
; CHECK-LABEL: call_many_double:
; CHECK:       lfs 13,
; CHECK-DAG:   std {{[0-9]+}}, 128(1)
; CHECK-DAG:   std {{[0-9]+}}, 136(1)
; CHECK:       bl many_double_sink

define double @call_many_double() {
  %result = call double @many_double_sink(
      i32 0, double 1.0, double 2.0, double 3.0, double 4.0, double 5.0,
      double 6.0, double 7.0, double 8.0, double 9.0, double 10.0,
      double 11.0, double 12.0, double 13.0, double 14.0, double 15.0)
  ret double %result
}

; CHECK-LABEL: receive_many_double:
; CHECK-DAG:   lfd {{[0-9]+}}, 128(1)
; CHECK-DAG:   lfd {{[0-9]+}}, 136(1)

define double @receive_many_double(
    i32 %tag, double %a1, double %a2, double %a3, double %a4, double %a5,
    double %a6, double %a7, double %a8, double %a9, double %a10, double %a11,
    double %a12, double %a13, double %a14, double %a15) {
  %result = fadd double %a14, %a15
  ret double %result
}

; Stack-passed f32 values are right-justified in their 8-byte slots.
; CHECK-LABEL: receive_many_float:
; CHECK-DAG:   lfs {{[0-9]+}}, 132(1)
; CHECK-DAG:   lfs {{[0-9]+}}, 140(1)

define float @receive_many_float(
    i32 %tag, float %a1, float %a2, float %a3, float %a4, float %a5,
    float %a6, float %a7, float %a8, float %a9, float %a10, float %a11,
    float %a12, float %a13, float %a14, float %a15) {
  %result = fadd float %a14, %a15
  ret float %result
}

; Variable double arguments are duplicated into the positional GPR or stack
; slot and an FPR. The first stack values begin at offsets 80 and 88.
; CHECK-LABEL: call_variadic_fp:
; CHECK-NOT:   creqv
; CHECK-NOT:   crxor
; CHECK-DAG:   lfs 9,
; CHECK-DAG:   std {{[0-9]+}}, 80(1)
; CHECK-DAG:   std {{[0-9]+}}, 88(1)
; CHECK:       bl variadic_sink

define i32 @call_variadic_fp() {
  %result = call i32 (i32, ...) @variadic_sink(
      i32 10, double 1.0, double 2.0, double 3.0, double 4.0, double 5.0,
      double 6.0, double 7.0, double 8.0, double 9.0)
  ret i32 %result
}

; CHECK-LABEL: receive_fixed_fp:
; CHECK:       fadd 1, 1, 2

define double @receive_fixed_fp(i32 %tag, float %a, double %b) {
  %extended = fpext float %a to double
  %result = fadd double %extended, %b
  ret double %result
}

; CHECK-LABEL: take_double:
; CHECK:       std 4, 56(1)
; CHECK:       std 10, 104(1)
; CHECK:       lfd 1, 56(1)

define double @take_double(i32 %tag, ...) {
  %args = alloca ptr, align 4
  call void @llvm.va_start(ptr %args)
  %value = va_arg ptr %args, double
  ret double %value
}
