; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s | FileCheck %s --check-prefix=XBOX
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=-altivec,-vmx128 -verify-machineinstrs < %s | FileCheck %s --check-prefix=XBOX
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=-stfiwx -verify-machineinstrs < %s | FileCheck %s --check-prefix=NO-STFIWX
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-linux-gnu -mcpu=970 -verify-machineinstrs < %s | FileCheck %s --check-prefix=OTHER
;
; STFIWX writes exactly the destination word. No VSX, FPCVT, vector
; instructions, 64-bit addresses, or stack transfer are needed for this combine.

; XBOX-LABEL: f32_store:
; XBOX-NOT: stwu
; XBOX-NOT: stdu
; XBOX: fctiwz [[F:%f[0-9]+]], %f1
; XBOX-NOT: lwz
; XBOX-NOT: stw
; XBOX: stfiwx [[F]], 0, %r3
; XBOX-NEXT: blr
; NO-STFIWX-LABEL: f32_store:
; NO-STFIWX: fctiwz
; NO-STFIWX-NOT: stfiwx
; NO-STFIWX: stfd
; NO-STFIWX: lwz
; NO-STFIWX: stw {{%r[0-9]+}}, 0(%r3)
; OTHER-LABEL: f32_store:
; OTHER: fctiwz
; OTHER: stfiwx
; OTHER: lwz
; OTHER: stw {{%r[0-9]+}}, 0(%r3)
define void @f32_store(ptr %dst, float %x) {
  %i = fptosi float %x to i32
  store i32 %i, ptr %dst, align 4
  ret void
}

; XBOX-LABEL: f64_store:
; XBOX-NOT: stwu
; XBOX-NOT: stdu
; XBOX: fctiwz [[D:%f[0-9]+]], %f1
; XBOX-NOT: lwz
; XBOX-NOT: stw
; XBOX: stfiwx [[D]], 0, %r3
; XBOX-NEXT: blr
define void @f64_store(ptr %dst, double %x) {
  %i = fptosi double %x to i32
  store i32 %i, ptr %dst, align 4
  ret void
}

; XBOX-LABEL: f32_offset_store:
; XBOX-NOT: stwu
; XBOX-NOT: stdu
; XBOX-DAG: addi [[ADDR:%r[0-9]+]], %r3, 12
; XBOX-DAG: fctiwz [[O:%f[0-9]+]], %f1
; XBOX-NOT: lwz
; XBOX-NOT: stw
; XBOX: stfiwx [[O]], 0, [[ADDR]]
; XBOX-NEXT: blr
define void @f32_offset_store(ptr %dst, float %x) {
  %p = getelementptr i32, ptr %dst, i32 3
  %i = fptosi float %x to i32
  store i32 %i, ptr %p, align 4
  ret void
}

; Retain the original volatile store's ordering and destination.
; XBOX-LABEL: volatile_store:
; XBOX: stw {{%r[0-9]+}}, 0(%r4)
; XBOX: stfiwx {{%f[0-9]+}}, 0, %r3
; XBOX: stw {{%r[0-9]+}}, 4(%r4)
; XBOX: blr
define void @volatile_store(ptr %dst, ptr %order, double %x) {
  store volatile i32 1, ptr %order, align 4
  %i = fptosi double %x to i32
  store volatile i32 %i, ptr %dst, align 4
  %next = getelementptr i32, ptr %order, i32 1
  store volatile i32 2, ptr %next, align 4
  ret void
}

; Do not use a word-aligned-only instruction at a misaligned destination.
; XBOX-LABEL: byte_aligned_store:
; XBOX: fctiwz
; XBOX: stfiwx
; XBOX: lwz
; XBOX: stw {{%r[0-9]+}}, 0(%r3)
; XBOX: blr
define void @byte_aligned_store(ptr %dst, float %x) {
  %i = fptosi float %x to i32
  store i32 %i, ptr %dst, align 1
  ret void
}

; XBOX-LABEL: halfword_aligned_store:
; XBOX: fctiwz
; XBOX: stfiwx
; XBOX: lwz
; XBOX: stw {{%r[0-9]+}}, 0(%r3)
; XBOX: blr
define void @halfword_aligned_store(ptr %dst, double %x) {
  %i = fptosi double %x to i32
  store i32 %i, ptr %dst, align 2
  ret void
}

; A truncating store must not overwrite adjacent bytes.
; XBOX-LABEL: truncating_store:
; XBOX: fctiwz
; XBOX: stfiwx
; XBOX: lwz
; XBOX: sth {{%r[0-9]+}}, 0(%r3)
; XBOX: blr
define void @truncating_store(ptr %dst, double %x) {
  %i = fptosi double %x to i32
  %s = trunc i32 %i to i16
  store i16 %s, ptr %dst, align 4
  ret void
}

; Unsigned i32 conversion requires FCTIDZ on Xenon, not FCTIWZ/FCTIWUZ.
; XBOX-LABEL: unsigned_store:
; XBOX-NOT: fctiw
; XBOX: fctidz
; XBOX: stfd
; XBOX: lwz
; XBOX: stw {{%r[0-9]+}}, 0(%r3)
; XBOX: blr
define void @unsigned_store(ptr %dst, double %x) {
  %i = fptoui double %x to i32
  store i32 %i, ptr %dst, align 4
  ret void
}

; The new combine does not rewrite atomic stores or strict exception chains.
; XBOX-LABEL: atomic_store:
; XBOX: fctiwz
; XBOX: stfiwx
; XBOX: lwz
; XBOX: stw {{%r[0-9]+}}, 0(%r3)
; XBOX: blr
define void @atomic_store(ptr %dst, double %x) {
  %i = fptosi double %x to i32
  store atomic i32 %i, ptr %dst monotonic, align 4
  ret void
}

declare i32 @llvm.experimental.constrained.fptosi.i32.f32(float, metadata)
declare i32 @llvm.experimental.constrained.fptosi.i32.f64(double, metadata)

; XBOX-LABEL: strict_f32_store:
; XBOX: fctiwz
; XBOX: stfiwx
; XBOX: lwz
; XBOX: stw {{%r[0-9]+}}, 0(%r3)
; XBOX: blr
define void @strict_f32_store(ptr %dst, float %x) strictfp {
  %i = call i32 @llvm.experimental.constrained.fptosi.i32.f32(float %x, metadata !"fpexcept.strict")
  store i32 %i, ptr %dst, align 4
  ret void
}

; The first exception must precede the marker store, and the second must follow.
; XBOX-LABEL: strict_f64_ordered_store:
; XBOX: fctiwz
; XBOX: stw {{%r[0-9]+}}, 0(%r4)
; XBOX: fctiwz
; XBOX: stw {{%r[0-9]+}}, 4(%r3)
; XBOX: blr
define void @strict_f64_ordered_store(ptr %dst, ptr %marker, double %x, double %y) strictfp {
  %a = call i32 @llvm.experimental.constrained.fptosi.i32.f64(double %x, metadata !"fpexcept.strict")
  store i32 %a, ptr %dst, align 4
  store volatile i32 1, ptr %marker, align 4
  %b = call i32 @llvm.experimental.constrained.fptosi.i32.f64(double %y, metadata !"fpexcept.strict")
  %next = getelementptr i32, ptr %dst, i32 1
  store i32 %b, ptr %next, align 4
  ret void
}
