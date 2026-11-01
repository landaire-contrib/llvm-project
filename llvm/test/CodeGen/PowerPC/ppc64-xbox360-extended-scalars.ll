; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s | FileCheck %s

; i128 is split across two consecutive 64-bit GPR slots. The intervening i32
; consumes one slot, so the second i128 arrives in r6 and r7.
; CHECK-LABEL: call_wide:
; CHECK-DAG:   mr 7, 6
; CHECK-DAG:   mr 6, 5
; CHECK-DAG:   li 5, 7
; CHECK:       bl wide_sink

declare i128 @wide_sink(i128, i32, i128)

define i128 @call_wide(i128 %a, i128 %b) {
  %result = call i128 @wide_sink(i128 %a, i32 7, i128 %b)
  ret i128 %result
}

; f16 is passed as its 16-bit representation in the argument's 64-bit GPR
; slot. The intervening i32 moves the second f16 from r4 to r5.
; CHECK-LABEL: call_half:
; CHECK-DAG:   mr 5, 4
; CHECK-DAG:   li 4, 7
; CHECK:       bl half_sink

declare half @half_sink(half, i32, half)

define half @call_half(half %a, half %b) {
  %result = call half @half_sink(half %a, i32 7, half %b)
  ret half %result
}
