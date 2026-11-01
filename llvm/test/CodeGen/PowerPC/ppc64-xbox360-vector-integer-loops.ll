; RUN: opt -passes='default<O3>' -mtriple=powerpc64-unknown-xbox360-ilp32 -mcpu=ppc64 -mattr=+altivec < %s \
; RUN:   | llc -O3 -mtriple=powerpc64-unknown-xbox360-ilp32 -mcpu=ppc64 -mattr=+altivec -verify-machineinstrs \
; RUN:   | FileCheck %s --check-prefix=XBOX --implicit-check-not='{{^[[:space:]]+(vmul[eo]|vmsum|vsum|vmhr?addshs|vmladduhm)}}'
; RUN: opt -passes='default<O3>' -mtriple=powerpc64-unknown-xbox360-ilp32 -mcpu=ppc64 -mattr=-vmx128,+altivec < %s \
; RUN:   | llc -O3 -mtriple=powerpc64-unknown-xbox360-ilp32 -mcpu=ppc64 -mattr=-vmx128,+altivec -verify-machineinstrs \
; RUN:   | FileCheck %s --check-prefix=XBOX --implicit-check-not='{{^[[:space:]]+(vmul[eo]|vmsum|vsum|vmhr?addshs|vmladduhm)}}'
; RUN: opt -passes='default<O3>' -mtriple=powerpc64-unknown-linux-gnu -mcpu=g5 -mattr=+altivec < %s \
; RUN:   | llc -O3 -mtriple=powerpc64-unknown-linux-gnu -mcpu=g5 -mattr=+altivec -verify-machineinstrs \
; RUN:   | FileCheck %s --check-prefix=LINUX
;
; Ordinary scalar source loops exercise the normal O3 pipeline, including its
; vectorization decisions: no vectorization metadata or forced vector widths.
; Xenon's missing integer vector instructions are a hardware restriction, not
; a consequence of enabling the VMX128 register file or instruction encodings.
; Classic Linux AltiVec must continue to use native integer vector multiplies.

; XBOX-LABEL: multiply_i16:
; XBOX: mullw
define void @multiply_i16(ptr noalias %output, ptr readonly %left, ptr readonly %right) {
entry:
  br label %loop

loop:
  %index = phi i32 [ 0, %entry ], [ %next, %loop ]
  %left.ptr = getelementptr inbounds i16, ptr %left, i32 %index
  %right.ptr = getelementptr inbounds i16, ptr %right, i32 %index
  %a = load i16, ptr %left.ptr, align 2
  %b = load i16, ptr %right.ptr, align 2
  %product = mul i16 %a, %b
  %output.ptr = getelementptr inbounds i16, ptr %output, i32 %index
  store i16 %product, ptr %output.ptr, align 2
  %next = add nuw nsw i32 %index, 1
  %done = icmp eq i32 %next, 256
  br i1 %done, label %exit, label %loop

exit:
  ret void
}

; XBOX-LABEL: multiply_i32:
; XBOX: mullw
define void @multiply_i32(ptr noalias %output, ptr readonly %left, ptr readonly %right) {
entry:
  br label %loop

loop:
  %index = phi i32 [ 0, %entry ], [ %next, %loop ]
  %left.ptr = getelementptr inbounds i32, ptr %left, i32 %index
  %right.ptr = getelementptr inbounds i32, ptr %right, i32 %index
  %a = load i32, ptr %left.ptr, align 4
  %b = load i32, ptr %right.ptr, align 4
  %product = mul i32 %a, %b
  %output.ptr = getelementptr inbounds i32, ptr %output, i32 %index
  store i32 %product, ptr %output.ptr, align 4
  %next = add nuw nsw i32 %index, 1
  %done = icmp eq i32 %next, 256
  br i1 %done, label %exit, label %loop

exit:
  ret void
}

; XBOX-LABEL: reduce_i16:
; XBOX: mullw
define i32 @reduce_i16(ptr readonly %left, ptr readonly %right) {
entry:
  br label %loop

loop:
  %index = phi i32 [ 0, %entry ], [ %next, %loop ]
  %sum = phi i32 [ 0, %entry ], [ %accumulate, %loop ]
  %left.ptr = getelementptr inbounds i16, ptr %left, i32 %index
  %right.ptr = getelementptr inbounds i16, ptr %right, i32 %index
  %a = load i16, ptr %left.ptr, align 2
  %b = load i16, ptr %right.ptr, align 2
  %wide.a = sext i16 %a to i32
  %wide.b = sext i16 %b to i32
  %product = mul nsw i32 %wide.a, %wide.b
  %accumulate = add i32 %sum, %product
  %next = add nuw nsw i32 %index, 1
  %done = icmp eq i32 %next, 256
  br i1 %done, label %exit, label %loop

exit:
  ret i32 %accumulate
}

; XBOX-LABEL: reduce_i32:
; XBOX: mullw
define i32 @reduce_i32(ptr readonly %left, ptr readonly %right) {
entry:
  br label %loop

loop:
  %index = phi i32 [ 0, %entry ], [ %next, %loop ]
  %sum = phi i32 [ 0, %entry ], [ %accumulate, %loop ]
  %left.ptr = getelementptr inbounds i32, ptr %left, i32 %index
  %right.ptr = getelementptr inbounds i32, ptr %right, i32 %index
  %a = load i32, ptr %left.ptr, align 4
  %b = load i32, ptr %right.ptr, align 4
  %product = mul i32 %a, %b
  %accumulate = add i32 %sum, %product
  %next = add nuw nsw i32 %index, 1
  %done = icmp eq i32 %next, 256
  br i1 %done, label %exit, label %loop

exit:
  ret i32 %accumulate
}

; Explicit vector input tests instruction availability independently of loop
; vectorization profitability.
; XBOX-LABEL: multiply_vector:
; XBOX: mullw
; LINUX-LABEL: multiply_vector:
; LINUX: vmulouh
; LINUX: vmsumuhm
define <4 x i32> @multiply_vector(<4 x i32> %left, <4 x i32> %right) {
  %product = mul <4 x i32> %left, %right
  ret <4 x i32> %product
}
