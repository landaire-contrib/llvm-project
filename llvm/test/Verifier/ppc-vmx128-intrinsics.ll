; RUN: not opt -S -passes=verify < %s 2>&1 | FileCheck %s

define <4 x i32> @vpermwi(<4 x i32> %a) {
  ; CHECK: immarg value 256 for arg 1 out of range [0,256)
  %r = call <4 x i32> @llvm.ppc.vmx128.vpermwi(<4 x i32> %a, i32 256)
  ret <4 x i32> %r
}

define <4 x i32> @vrlimi(<4 x i32> %d, <4 x i32> %b) {
  ; CHECK: immarg value 16 for arg 2 out of range [0,16)
  %r1 = call <4 x i32> @llvm.ppc.vmx128.vrlimi(<4 x i32> %d, <4 x i32> %b, i32 16, i32 0)
  ; CHECK: immarg value 4 for arg 3 out of range [0,4)
  %r2 = call <4 x i32> @llvm.ppc.vmx128.vrlimi(<4 x i32> %d, <4 x i32> %b, i32 0, i32 4)
  ret <4 x i32> %r2
}

define <4 x i32> @vpkd3d(<4 x i32> %d, <4 x float> %b) {
  ; CHECK: immarg value 7 for arg 2 out of range [0,7)
  %r1 = call <4 x i32> @llvm.ppc.vmx128.vpkd3d(<4 x i32> %d, <4 x float> %b, i32 7, i32 1, i32 0)
  ; CHECK: immarg value 0 for arg 3 out of range [1,4)
  %r2 = call <4 x i32> @llvm.ppc.vmx128.vpkd3d(<4 x i32> %d, <4 x float> %b, i32 0, i32 0, i32 0)
  ; CHECK: immarg value 4 for arg 3 out of range [1,4)
  %r3 = call <4 x i32> @llvm.ppc.vmx128.vpkd3d(<4 x i32> %d, <4 x float> %b, i32 0, i32 4, i32 0)
  ; CHECK: immarg value 4 for arg 4 out of range [0,4)
  %r4 = call <4 x i32> @llvm.ppc.vmx128.vpkd3d(<4 x i32> %d, <4 x float> %b, i32 0, i32 1, i32 4)
  ret <4 x i32> %r4
}

define <4 x float> @vupkd3d(<4 x i32> %a, i32 %t) {
  ; CHECK: immarg value 7 for arg 1 out of range [0,7)
  %r1 = call <4 x float> @llvm.ppc.vmx128.vupkd3d(<4 x i32> %a, i32 7)
  ; CHECK: immarg operand has non-immediate parameter
  %r2 = call <4 x float> @llvm.ppc.vmx128.vupkd3d(<4 x i32> %a, i32 %t)
  ret <4 x float> %r2
}
