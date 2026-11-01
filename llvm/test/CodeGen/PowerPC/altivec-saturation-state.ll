; RUN: opt -O2 -S < %s | llc -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=+altivec,+vmx128 | FileCheck %s --check-prefixes=CHECK,XBOX
; RUN: opt -O2 -S < %s | llc -mtriple=powerpc-unknown-linux-gnu -mattr=+altivec | FileCheck %s --check-prefixes=CHECK,ALTIVEC
;
; The result may be unused, but the sticky VSCR[SAT] update must remain
; between the state write and read, on Xbox and baseline AltiVec.

; CHECK-LABEL: add_signed_halfwords:
; CHECK: mtvscr
; CHECK: vaddshs
; CHECK: mfvscr
; CHECK: blr
define <8 x i16> @add_signed_halfwords(<8 x i16> %a, <8 x i16> %b) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %unused = call <8 x i16> @llvm.ppc.altivec.vaddshs(<8 x i16> %a, <8 x i16> %b)
  %state = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  ret <8 x i16> %state
}

; CHECK-LABEL: add_unsigned_bytes:
; CHECK: mtvscr
; CHECK: vaddubs
; CHECK: mfvscr
; CHECK: blr
define <8 x i16> @add_unsigned_bytes(<16 x i8> %a, <16 x i8> %b) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %unused = call <16 x i8> @llvm.ppc.altivec.vaddubs(<16 x i8> %a, <16 x i8> %b)
  %state = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  ret <8 x i16> %state
}

; CHECK-LABEL: subtract_unsigned_halfwords:
; CHECK: mtvscr
; CHECK: vsubuhs
; CHECK: mfvscr
; CHECK: blr
define <8 x i16> @subtract_unsigned_halfwords(<8 x i16> %a, <8 x i16> %b) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %unused = call <8 x i16> @llvm.ppc.altivec.vsubuhs(<8 x i16> %a, <8 x i16> %b)
  %state = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  ret <8 x i16> %state
}

; CHECK-LABEL: convert_signed_words:
; CHECK: mtvscr
; XBOX: vcfpsxws128
; ALTIVEC: vctsxs
; CHECK: mfvscr
; CHECK: blr
define <8 x i16> @convert_signed_words(<4 x float> %a) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %unused = call <4 x i32> @llvm.ppc.altivec.vctsxs(<4 x float> %a, i32 31)
  %state = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  ret <8 x i16> %state
}

; CHECK-LABEL: convert_unsigned_words:
; CHECK: mtvscr
; XBOX: vcfpuxws128
; ALTIVEC: vctuxs
; CHECK: mfvscr
; CHECK: blr
define <8 x i16> @convert_unsigned_words(<4 x float> %a) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %unused = call <4 x i32> @llvm.ppc.altivec.vctuxs(<4 x float> %a, i32 0)
  %state = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  ret <8 x i16> %state
}

; CHECK-LABEL: pack_signed_words:
; CHECK: mtvscr
; CHECK: vpkswss
; CHECK: mfvscr
; CHECK: blr
define <8 x i16> @pack_signed_words(<4 x i32> %a, <4 x i32> %b) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %unused = call <8 x i16> @llvm.ppc.altivec.vpkswss(<4 x i32> %a, <4 x i32> %b)
  %state = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  ret <8 x i16> %state
}

; CHECK-LABEL: other_add_subtract:
; CHECK: mtvscr
; CHECK-DAG: vaddsbs
; CHECK-DAG: vadduhs
; CHECK-DAG: vadduws
; CHECK-DAG: vaddsws
; CHECK-DAG: vsububs
; CHECK-DAG: vsubsbs
; CHECK-DAG: vsubshs
; CHECK-DAG: vsubuws
; CHECK-DAG: vsubsws
; CHECK: mfvscr
; CHECK: blr
define <8 x i16> @other_add_subtract(<16 x i8> %vaddsbs, <8 x i16> %vadduhs, <4 x i32> %vadduws, <4 x i32> %vaddsws, <16 x i8> %vsububs, <16 x i8> %vsubsbs, <8 x i16> %vsubshs, <4 x i32> %vsubuws, <4 x i32> %vsubsws) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r.vaddsbs = call <16 x i8> @llvm.ppc.altivec.vaddsbs(<16 x i8> %vaddsbs, <16 x i8> %vaddsbs)
  %r.vadduhs = call <8 x i16> @llvm.ppc.altivec.vadduhs(<8 x i16> %vadduhs, <8 x i16> %vadduhs)
  %r.vadduws = call <4 x i32> @llvm.ppc.altivec.vadduws(<4 x i32> %vadduws, <4 x i32> %vadduws)
  %r.vaddsws = call <4 x i32> @llvm.ppc.altivec.vaddsws(<4 x i32> %vaddsws, <4 x i32> %vaddsws)
  %r.vsububs = call <16 x i8> @llvm.ppc.altivec.vsububs(<16 x i8> %vsububs, <16 x i8> %vsububs)
  %r.vsubsbs = call <16 x i8> @llvm.ppc.altivec.vsubsbs(<16 x i8> %vsubsbs, <16 x i8> %vsubsbs)
  %r.vsubshs = call <8 x i16> @llvm.ppc.altivec.vsubshs(<8 x i16> %vsubshs, <8 x i16> %vsubshs)
  %r.vsubuws = call <4 x i32> @llvm.ppc.altivec.vsubuws(<4 x i32> %vsubuws, <4 x i32> %vsubuws)
  %r.vsubsws = call <4 x i32> @llvm.ppc.altivec.vsubsws(<4 x i32> %vsubsws, <4 x i32> %vsubsws)
  %state = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  ret <8 x i16> %state
}

declare void @llvm.ppc.altivec.mtvscr(<4 x i32>)
declare <8 x i16> @llvm.ppc.altivec.mfvscr()
declare <8 x i16> @llvm.ppc.altivec.vaddshs(<8 x i16>, <8 x i16>)
declare <16 x i8> @llvm.ppc.altivec.vaddubs(<16 x i8>, <16 x i8>)
declare <8 x i16> @llvm.ppc.altivec.vsubuhs(<8 x i16>, <8 x i16>)
declare <4 x i32> @llvm.ppc.altivec.vctsxs(<4 x float>, i32 immarg)
declare <4 x i32> @llvm.ppc.altivec.vctuxs(<4 x float>, i32 immarg)
declare <8 x i16> @llvm.ppc.altivec.vpkswss(<4 x i32>, <4 x i32>)
declare <16 x i8> @llvm.ppc.altivec.vaddsbs(<16 x i8>, <16 x i8>)
declare <8 x i16> @llvm.ppc.altivec.vadduhs(<8 x i16>, <8 x i16>)
declare <4 x i32> @llvm.ppc.altivec.vadduws(<4 x i32>, <4 x i32>)
declare <4 x i32> @llvm.ppc.altivec.vaddsws(<4 x i32>, <4 x i32>)
declare <16 x i8> @llvm.ppc.altivec.vsububs(<16 x i8>, <16 x i8>)
declare <16 x i8> @llvm.ppc.altivec.vsubsbs(<16 x i8>, <16 x i8>)
declare <8 x i16> @llvm.ppc.altivec.vsubshs(<8 x i16>, <8 x i16>)
declare <4 x i32> @llvm.ppc.altivec.vsubuws(<4 x i32>, <4 x i32>)
declare <4 x i32> @llvm.ppc.altivec.vsubsws(<4 x i32>, <4 x i32>)
