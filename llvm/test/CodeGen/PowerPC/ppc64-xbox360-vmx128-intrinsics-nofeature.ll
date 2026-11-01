; RUN: not --crash llc -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=+altivec,-vmx128 \
; RUN:   < %s 2>&1 | FileCheck %s

; The VMX128 intrinsics select only with vmx128.
; CHECK: LLVM ERROR: Cannot select: intrinsic %llvm.ppc.vmx128.vmsum4fp

define <4 x float> @vmsum4fp(<4 x float> %a, <4 x float> %b) {
  %r = call <4 x float> @llvm.ppc.vmx128.vmsum4fp(<4 x float> %a, <4 x float> %b)
  ret <4 x float> %r
}
