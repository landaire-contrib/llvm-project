; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s | FileCheck %s

; The zero-extension peephole promotes LHBRX and LWBRX to LHBRX8 and LWBRX8.
; Their address operands are 32-bit pointer registers on the Xbox 360 and must
; not be widened with sub_32.

; CHECK-LABEL: load_bswap16_zext:
; CHECK:       lhbrx 3, 0, 3
; CHECK-NEXT:  blr
define i64 @load_bswap16_zext(ptr %p) {
  %v = load i16, ptr %p, align 1
  %s = call i16 @llvm.bswap.i16(i16 %v)
  %z = zext i16 %s to i64
  ret i64 %z
}

; CHECK-LABEL: load_bswap32_zext:
; CHECK:       lwbrx 3, 3, 4
; CHECK-NEXT:  blr
define i64 @load_bswap32_zext(ptr %p, i32 %off) {
  %a = getelementptr i8, ptr %p, i32 %off
  %v = load i32, ptr %a, align 1
  %s = call i32 @llvm.bswap.i32(i32 %v)
  %z = zext i32 %s to i64
  ret i64 %z
}
