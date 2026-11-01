; RUN: opt -S -passes=loop-vectorize -mtriple=powerpc64-unknown-xbox360-ilp32 -mcpu=ppc64 -mattr=+altivec,+vmx128 < %s | FileCheck %s --check-prefixes=CHECK,XBOX
; RUN: opt -S -passes=loop-vectorize -mtriple=powerpc64-unknown-linux-gnu -mcpu=pwr8 -mattr=+vsx < %s | FileCheck %s --check-prefixes=CHECK,PPC
;
; Keep both vectorizers enabled, and do not force a VF or interleave count.
; The only input loop metadata is mustprogress: in particular there is no
; vectorize.enable, vectorize.width, or isvectorized hint hiding profitability.
;
; Updating short elements in a matrix must not grow text under optsize.
; A row spans two native vectors. Unaligned element stores and alignment
; permutations can cost more instructions than the scalar loop body.
; Generic PPC retains its existing throughput-based optsize policy. POWER8
; unaligned VSX accesses are profitable and must not inherit Xbox's costs.

; CHECK-LABEL: define void @subtract_rows_size(
; XBOX-NOT: vector.body
; XBOX-NOT: <{{[0-9]+}} x i16>
; XBOX: load i16, ptr {{.*}}, align 2
; XBOX: sub i16
; XBOX: store i16 {{.*}}, ptr {{.*}}, align 2
; XBOX-NOT: vector.body
; XBOX-NOT: <{{[0-9]+}} x i16>
; PPC: vector.body:
; PPC: load <8 x i16>, ptr {{.*}}, align 2
; PPC: sub <8 x i16>
; PPC: store <8 x i16> {{.*}}, ptr {{.*}}, align 2
; CHECK: ret void
define void @subtract_rows_size(ptr %matrix, i16 %amount) optsize {
entry:
  br label %row

row:
  %row.index = phi i32 [ 0, %entry ], [ %next.row, %row.end ]
  %row.ptr = getelementptr inbounds [16 x i16], ptr %matrix, i32 %row.index
  br label %column

column:
  %index = phi i32 [ 0, %row ], [ %next.column, %column ]
  %element = getelementptr inbounds i16, ptr %row.ptr, i32 %index
  %old = load i16, ptr %element, align 2
  %new = sub i16 %old, %amount
  store i16 %new, ptr %element, align 2
  %next.column = add nuw nsw i32 %index, 1
  %column.done = icmp eq i32 %next.column, 16
  br i1 %column.done, label %row.end, label %column, !llvm.loop !0

row.end:
  %next.row = add nuw nsw i32 %row.index, 1
  %row.done = icmp eq i32 %next.row, 8
  br i1 %row.done, label %exit, label %row, !llvm.loop !2

exit:
  ret void
}

; The same accesses are profitable for throughput. This guards against solving
; the size regression by disabling Xbox vectorization or all unaligned loops.
; CHECK-LABEL: define void @subtract_rows_throughput(
; CHECK: vector.body:
; CHECK: load <8 x i16>, ptr {{.*}}, align 2
; CHECK: sub <8 x i16>
; CHECK: store <8 x i16> {{.*}}, ptr {{.*}}, align 2
; CHECK: ret void
define void @subtract_rows_throughput(ptr %matrix, i16 %amount) {
entry:
  br label %row

row:
  %row.index = phi i32 [ 0, %entry ], [ %next.row, %row.end ]
  %row.ptr = getelementptr inbounds [16 x i16], ptr %matrix, i32 %row.index
  br label %column

column:
  %index = phi i32 [ 0, %row ], [ %next.column, %column ]
  %element = getelementptr inbounds i16, ptr %row.ptr, i32 %index
  %old = load i16, ptr %element, align 2
  %new = sub i16 %old, %amount
  store i16 %new, ptr %element, align 2
  %next.column = add nuw nsw i32 %index, 1
  %column.done = icmp eq i32 %next.column, 16
  br i1 %column.done, label %row.end, label %column, !llvm.loop !3

row.end:
  %next.row = add nuw nsw i32 %row.index, 1
  %row.done = icmp eq i32 %next.row, 8
  br i1 %row.done, label %exit, label %row, !llvm.loop !4

exit:
  ret void
}

; Size optimization must still admit profitable conversion-heavy arithmetic.
; All pointers are disjoint and the fixed trip count needs no scalar epilogue
; or alias checks. Scalar integer/FP conversions cross register banks, whereas
; their native vector counterparts stay in the vector bank. The rounding
; steps make vectorization profitable even with the conservative align-4
; memory costs inherited from the scalar accesses. The base pointers are
; genuinely aligned; do not falsely mark every scalar element align 16.
; CHECK-LABEL: define void @convert_values_size(
; CHECK: vector.body:
; CHECK: load <[[VF:[2-9][0-9]*]] x i32>, ptr {{.*}}, align 4
; CHECK: load <[[VF]] x i32>, ptr {{.*}}, align 4
; CHECK: sitofp <[[VF]] x i32>
; CHECK: sitofp <[[VF]] x i32>
; CHECK: fsub <[[VF]] x float>
; CHECK: fmul <[[VF]] x float>
; CHECK: fptosi <[[VF]] x float>
; CHECK: fptosi <[[VF]] x float>
; CHECK: sitofp <[[VF]] x i32>
; CHECK: sitofp <[[VF]] x i32>
; CHECK: fadd <[[VF]] x float>
; CHECK: store <[[VF]] x float> {{.*}}, ptr {{.*}}, align 4
; CHECK: ret void
define void @convert_values_size(ptr noalias align 16 %out, ptr noalias align 16 %a, ptr noalias align 16 %b) optsize {
entry:
  br label %loop

loop:
  %index = phi i32 [ 0, %entry ], [ %next, %loop ]
  %ap = getelementptr inbounds i32, ptr %a, i32 %index
  %bp = getelementptr inbounds i32, ptr %b, i32 %index
  %op = getelementptr inbounds float, ptr %out, i32 %index
  %ai = load i32, ptr %ap, align 4
  %bi = load i32, ptr %bp, align 4
  %av = sitofp i32 %ai to float
  %bv = sitofp i32 %bi to float
  %difference = fsub float %av, %bv
  %product = fmul float %difference, %av
  %rounded.a = fptosi float %difference to i32
  %rounded.b = fptosi float %product to i32
  %back.a = sitofp i32 %rounded.a to float
  %back.b = sitofp i32 %rounded.b to float
  %result = fadd float %back.a, %back.b
  store float %result, ptr %op, align 4
  %next = add nuw nsw i32 %index, 1
  %done = icmp eq i32 %next, 128
  br i1 %done, label %exit, label %loop, !llvm.loop !5

exit:
  ret void
}

!0 = distinct !{!0, !1}
!1 = !{!"llvm.loop.mustprogress"}
!2 = distinct !{!2, !1}
!3 = distinct !{!3, !1}
!4 = distinct !{!4, !1}
!5 = distinct !{!5, !1}
