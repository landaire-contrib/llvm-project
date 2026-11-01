; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s | FileCheck %s

; The EXTSW elimination promotes LBZ to LBZ8. The address operand of LBZ8 is
; a 32-bit pointer register on the Xbox 360 and must not be widened with
; sub_32.
; CHECK-LABEL: cmp_loaded_byte:
; CHECK:       lbz [[BYTE:[0-9]+]], 0(3)
; CHECK:       cmpwi [[BYTE]], 0
; CHECK:       blr

define i8 @cmp_loaded_byte(ptr %p) {
  %byte = load i8, ptr %p, align 1
  %wide = zext i8 %byte to i32
  %result = call i8 @llvm.scmp.i8.i32(i32 %wide, i32 0)
  ret i8 %result
}
