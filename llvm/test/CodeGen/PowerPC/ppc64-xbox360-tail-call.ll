; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -tailcallopt \
; RUN:   -verify-machineinstrs < %s | FileCheck %s

; Ten arguments need more parameter area than the caller's 80-byte minimum, so
; the guaranteed tail call grows the stack by 16 bytes.
; CHECK-LABEL: tail_ten_args:
; CHECK:       stw {{%r[0-9]+}}, 204(%r31)
; CHECK:       addi %r1, %r31, 112
; CHECK:       b sink

declare fastcc i32 @sink(i32, i32, i32, i32, i32, i32, i32, i32, i32, i32)

define fastcc i32 @tail_ten_args() {
  %result = tail call fastcc i32 @sink(i32 1, i32 2, i32 3, i32 4, i32 5,
                                       i32 6, i32 7, i32 8, i32 9, i32 10)
  ret i32 %result
}
