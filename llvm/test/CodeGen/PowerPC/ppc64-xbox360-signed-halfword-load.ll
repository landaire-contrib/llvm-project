; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s | FileCheck %s --check-prefix=XBOX --implicit-check-not=lha --implicit-check-not=lwz --implicit-check-not=lbz
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=-altivec,-vmx128 -verify-machineinstrs < %s | FileCheck %s --check-prefix=XBOX --implicit-check-not=lha --implicit-check-not=lwz --implicit-check-not=lbz
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-linux-gnu -mcpu=970 -verify-machineinstrs < %s | FileCheck %s --check-prefix=OTHER
;
; Prefer a two-byte zero-extending load and register sign extension on Xenon.
; Keep the full signed result, including negative i16 values, for both GPR types.
; No widened access may read beyond a halfword at the end of a mapped page.

; XBOX-LABEL: signed_i32:
; XBOX: lhz [[W:%r[0-9]+]], 0(%r3)
; XBOX: extsh %r3, [[W]]
; XBOX: blr
; OTHER-LABEL: signed_i32:
; OTHER: lha %r3, 0(%r3)
; OTHER-NOT: extsh
; OTHER: blr
define i32 @signed_i32(ptr %p) {
  %v = load i16, ptr %p, align 2
  %s = sext i16 %v to i32
  ret i32 %s
}

; XBOX-LABEL: signed_i64:
; XBOX: lhz [[D:%r[0-9]+]], 0(%r3)
; XBOX: extsh %r3, [[D]]
; XBOX: blr
; OTHER-LABEL: signed_i64:
; OTHER: lha %r3, 0(%r3)
; OTHER-NOT: extsh
; OTHER: blr
define i64 @signed_i64(ptr %p) {
  %v = load i16, ptr %p, align 2
  %s = sext i16 %v to i64
  ret i64 %s
}

; Indexed addressing must not select LHAX after legalization either.
; XBOX-LABEL: indexed_i32:
; XBOX: lhzx [[I32:%r[0-9]+]], %r3, %r4
; XBOX: extsh %r3, [[I32]]
; XBOX: blr
; OTHER-LABEL: indexed_i32:
; OTHER: lhax %r3, %r3, %r4
; OTHER: blr
define i32 @indexed_i32(ptr %base, i32 %offset) {
  %p = getelementptr i8, ptr %base, i32 %offset
  %v = load i16, ptr %p, align 2
  %s = sext i16 %v to i32
  ret i32 %s
}

; XBOX-LABEL: indexed_i64:
; XBOX: lhzx [[I:%r[0-9]+]], %r3, %r4
; XBOX: extsh %r3, [[I]]
; XBOX: blr
; OTHER-LABEL: indexed_i64:
; OTHER: lhax %r3, %r3, %r4
; OTHER: blr
define i64 @indexed_i64(ptr %base, i32 %offset) {
  %p = getelementptr i8, ptr %base, i32 %offset
  %v = load i16, ptr %p, align 2
  %s = sext i16 %v to i64
  ret i64 %s
}

; Explicit alignment 1 must not widen the access or assume word alignment.
; XBOX-LABEL: unaligned_i32:
; XBOX: lhz [[U:%r[0-9]+]], 1(%r3)
; XBOX: extsh %r3, [[U]]
; XBOX: blr
define i32 @unaligned_i32(ptr %base) {
  %p = getelementptr i8, ptr %base, i32 1
  %v = load i16, ptr %p, align 1
  %s = sext i16 %v to i32
  ret i32 %s
}

; XBOX-LABEL: page_end_i64:
; XBOX: lhz [[E:%r[0-9]+]], 4094(%r3)
; XBOX: extsh %r3, [[E]]
; XBOX: blr
define i64 @page_end_i64(ptr %page) {
  %p = getelementptr i8, ptr %page, i32 4094
  %v = load i16, ptr %p, align 2
  %s = sext i16 %v to i64
  ret i64 %s
}

; Negative displacements still use exactly the addressed halfword.
; XBOX-LABEL: preceding_halfword_i32:
; XBOX: lhz [[N:%r[0-9]+]], -2(%r3)
; XBOX: extsh %r3, [[N]]
; XBOX: blr
define i32 @preceding_halfword_i32(ptr %end) {
  %p = getelementptr i16, ptr %end, i32 -1
  %v = load i16, ptr %p, align 2
  %s = sext i16 %v to i32
  ret i32 %s
}

; Each volatile access remains one two-byte load, ordered around the marker.
; XBOX-LABEL: volatile_i64:
; XBOX: lhz [[V0:%r[0-9]+]], 0(%r3)
; XBOX-NOT: lhz
; XBOX: stw {{%r[0-9]+}}, 0(%r4)
; XBOX-NOT: lhz
; XBOX: lhz [[V1:%r[0-9]+]], 0(%r3)
; XBOX-NOT: lhz
; XBOX: blr
define i64 @volatile_i64(ptr %p, ptr %marker) {
  %a = load volatile i16, ptr %p, align 1
  store volatile i32 1, ptr %marker, align 4
  %b = load volatile i16, ptr %p, align 1
  %sa = sext i16 %a to i64
  %sb = sext i16 %b to i64
  %sum = add i64 %sa, %sb
  ret i64 %sum
}

; Consumer-relevant signed i16 multiply, as in an integer dot product.
; XBOX-LABEL: dot_i16_term:
; XBOX-DAG: lhz [[L:%r[0-9]+]], 0(%r3)
; XBOX-DAG: lhz [[R:%r[0-9]+]], 0(%r4)
; XBOX-DAG: extsh [[LS:%r[0-9]+]], [[L]]
; XBOX-DAG: extsh [[RS:%r[0-9]+]], [[R]]
; XBOX: mullw %r3,
; XBOX: blr
define i32 @dot_i16_term(ptr %left, ptr %right) {
  %a = load i16, ptr %left, align 2
  %b = load i16, ptr %right, align 2
  %sa = sext i16 %a to i32
  %sb = sext i16 %b to i32
  %product = mul i32 %sa, %sb
  ret i32 %product
}

; Unsigned consumers must not acquire a sign extension (0xffff stays 65535).
; XBOX-LABEL: unsigned_i32:
; XBOX: lhz %r3, 0(%r3)
; XBOX-NOT: extsh
; XBOX: blr
define i32 @unsigned_i32(ptr %p) {
  %v = load i16, ptr %p, align 2
  %u = zext i16 %v to i32
  ret i32 %u
}

; XBOX-LABEL: unsigned_i64:
; XBOX: lhz %r3, 0(%r3)
; XBOX-NOT: extsh
; XBOX: blr
define i64 @unsigned_i64(ptr %p) {
  %v = load i16, ptr %p, align 2
  %u = zext i16 %v to i64
  ret i64 %u
}
