; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s | FileCheck %s

; Copies use accesses no wider than their known alignment, as the console
; compiler does. Explicitly misaligned scalar accesses keep their width.

; CHECK-LABEL: copy_words:
; CHECK-NOT:   ld
; CHECK-NOT:   std
; CHECK:       lwz
; CHECK:       stw
; CHECK:       blr
define void @copy_words(ptr align 4 %d, ptr align 4 %s) {
  call void @llvm.memcpy.p0.p0.i32(ptr align 4 %d, ptr align 4 %s, i32 16, i1 false)
  ret void
}

; CHECK-LABEL: copy_bytes:
; CHECK-NOT:   lwz
; CHECK-NOT:   ld
; CHECK:       lbz
; CHECK:       stb
; CHECK:       blr
define void @copy_bytes(ptr %d, ptr %s) {
  call void @llvm.memcpy.p0.p0.i32(ptr %d, ptr %s, i32 8, i1 false)
  ret void
}

; CHECK-LABEL: copy_dwords:
; CHECK:       ld
; CHECK:       std
; CHECK:       blr
define void @copy_dwords(ptr align 8 %d, ptr align 8 %s) {
  call void @llvm.memcpy.p0.p0.i32(ptr align 8 %d, ptr align 8 %s, i32 16, i1 false)
  ret void
}

; Adjacent word copies are not merged into misaligned doubleword accesses.
; CHECK-LABEL: copy_word_pair:
; CHECK-NOT:   ld
; CHECK-NOT:   std
; CHECK:       stw
; CHECK:       stw
; CHECK:       blr
define void @copy_word_pair(ptr align 4 %d, ptr align 4 %s) {
  %s1 = getelementptr i8, ptr %s, i32 4
  %s2 = getelementptr i8, ptr %s, i32 8
  %a = load i32, ptr %s1, align 4
  %b = load i32, ptr %s2, align 4
  %d1 = getelementptr i8, ptr %d, i32 4
  %d2 = getelementptr i8, ptr %d, i32 8
  store i32 %a, ptr %d1, align 4
  store i32 %b, ptr %d2, align 4
  ret void
}

; CHECK-LABEL: load_i64_align4:
; CHECK:       ld 3, 0(3)
; CHECK-NEXT:  blr
define i64 @load_i64_align4(ptr %p) {
  %v = load i64, ptr %p, align 4
  ret i64 %v
}
