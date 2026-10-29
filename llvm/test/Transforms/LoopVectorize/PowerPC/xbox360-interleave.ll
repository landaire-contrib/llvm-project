; RUN: opt -S -passes=loop-vectorize -mtriple=powerpc64-unknown-xbox360-ilp32 -mcpu=ppc64 -mattr=+altivec,+vmx128 < %s | FileCheck %s --check-prefix=XBOX
; RUN: opt -S -passes=loop-vectorize -mtriple=powerpc64-unknown-xbox360-ilp32 -mcpu=ppc64 -mattr=+altivec,-vmx128 < %s | FileCheck %s --check-prefix=XBOX
; RUN: opt -S -passes=loop-vectorize -mtriple=powerpc64-unknown-linux-gnu -mcpu=ppc64 -mattr=+altivec < %s | FileCheck %s --check-prefix=PPC

; Xenon vector arithmetic has a long latency, so loops are interleaved more
; on the Xbox 360, with or without VMX128.

; XBOX-LABEL: @add(
; XBOX-COUNT-9: fadd fast <4 x float>
; XBOX-NOT: fadd fast <4 x float>
; PPC-LABEL: @add(
; PPC: fadd fast <4 x float>
; PPC-NOT: fadd fast <4 x float>

define void @add(ptr noalias %a, ptr noalias %b, ptr noalias %c, i32 %n) {
entry:
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %loop, label %exit
loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
  %pb = getelementptr inbounds float, ptr %b, i32 %i
  %pc = getelementptr inbounds float, ptr %c, i32 %i
  %vb = load float, ptr %pb, align 4
  %vc = load float, ptr %pc, align 4
  %s = fadd fast float %vb, %vc
  %pa = getelementptr inbounds float, ptr %a, i32 %i
  store float %s, ptr %pa, align 4
  %i.next = add nuw nsw i32 %i, 1
  %done = icmp eq i32 %i.next, %n
  br i1 %done, label %exit, label %loop
exit:
  ret void
}
