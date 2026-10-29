; RUN: split-file %s %t
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs \
; RUN:   -ppc-reg-with-percent-prefix < %t/stores.ll \
; RUN:   | FileCheck %s --check-prefix=STORE \
; RUN:   --implicit-check-not='(%r1)' \
; RUN:   --implicit-check-not='{{[[:space:]]std[xu]*[[:space:]]}}' \
; RUN:   --implicit-check-not='{{(lvlx|lvrx|stvlx|stvrx)}}'
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -stop-after=finalize-isel \
; RUN:   -verify-machineinstrs < %t/loads.ll | FileCheck %s --check-prefix=LOAD
;
; A 24-byte vector has a native sixteen-byte chunk and an eight-byte tail.
; Splitting must retain the original alignment and offsets; generic vector
; legalization must not turn the tail into a misaligned packed doubleword.
; Native load intrinsics below provide register inputs without allowing source
; load narrowing to obscure the independent wide-store regression.

;--- stores.ll
define void @wide_store_a1(ptr %src, ptr %dst) {
; STORE-LABEL: wide_store_a1:
; STORE-COUNT-24: stvebx
; STORE-NOT: stvebx
; STORE: blr
  %low = call <4 x i32> @llvm.ppc.altivec.lvx(ptr %src)
  %upper = getelementptr i8, ptr %src, i32 16
  %high = call <4 x i32> @llvm.ppc.altivec.lvx(ptr %upper)
  %value = shufflevector <4 x i32> %low, <4 x i32> %high, <6 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5>
  store <6 x i32> %value, ptr %dst, align 1
  ret void
}

define void @wide_store_a2(ptr %src, ptr %dst) {
; STORE-LABEL: wide_store_a2:
; STORE-COUNT-12: stvehx
; STORE-NOT: stvehx
; STORE: blr
  %low = call <4 x i32> @llvm.ppc.altivec.lvx(ptr %src)
  %upper = getelementptr i8, ptr %src, i32 16
  %high = call <4 x i32> @llvm.ppc.altivec.lvx(ptr %upper)
  %value = shufflevector <4 x i32> %low, <4 x i32> %high, <6 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5>
  store <6 x i32> %value, ptr %dst, align 2
  ret void
}

define void @wide_store_a4(ptr %src, ptr %dst) {
; STORE-LABEL: wide_store_a4:
; STORE-COUNT-6: stvewx
; STORE-NOT: stvewx
; STORE: blr
  %low = call <4 x i32> @llvm.ppc.altivec.lvx(ptr %src)
  %upper = getelementptr i8, ptr %src, i32 16
  %high = call <4 x i32> @llvm.ppc.altivec.lvx(ptr %upper)
  %value = shufflevector <4 x i32> %low, <4 x i32> %high, <6 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5>
  store <6 x i32> %value, ptr %dst, align 4
  ret void
}

define void @wide_store_a8(ptr %src, ptr %dst) {
; STORE-LABEL: wide_store_a8:
; STORE-COUNT-6: stvewx
; STORE-NOT: stvewx
; STORE: blr
  %low = call <4 x i32> @llvm.ppc.altivec.lvx(ptr %src)
  %upper = getelementptr i8, ptr %src, i32 16
  %high = call <4 x i32> @llvm.ppc.altivec.lvx(ptr %upper)
  %value = shufflevector <4 x i32> %low, <4 x i32> %high, <6 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5>
  store <6 x i32> %value, ptr %dst, align 8
  ret void
}

define void @wide_volatile_store(ptr %src, ptr %dst, ptr %marker) {
; STORE-LABEL: wide_volatile_store:
; STORE-COUNT-6: stvewx
; STORE: stb {{.*}}, 0(%r5)
; STORE: blr
  %low = call <4 x i32> @llvm.ppc.altivec.lvx(ptr %src)
  %upper = getelementptr i8, ptr %src, i32 16
  %high = call <4 x i32> @llvm.ppc.altivec.lvx(ptr %upper)
  %value = shufflevector <4 x i32> %low, <4 x i32> %high, <6 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5>
  store volatile <6 x i32> %value, ptr %dst, align 4
  store volatile i8 7, ptr %marker
  ret void
}

declare <4 x i32> @llvm.ppc.altivec.lvx(ptr)

;--- loads.ll
define void @wide_load_a1(ptr %src, ptr %dst) {
; LOAD-LABEL: name: wide_load_a1
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 16{{.*}}, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 17{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 18{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 19{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 20{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 21{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 22{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 23{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <6 x i32>, ptr %src, align 1, !alias.scope !0, !noalias !3
  store <6 x i32> %value, ptr %dst, align 16
  ret void
}

define void @wide_load_a2(ptr %src, ptr %dst) {
; LOAD-LABEL: name: wide_load_a2
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 16{{.*}}, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 18{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 20{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 22{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <6 x i32>, ptr %src, align 2, !alias.scope !0, !noalias !3
  store <6 x i32> %value, ptr %dst, align 16
  ret void
}

define void @wide_load_a4(ptr %src, ptr %dst) {
; LOAD-LABEL: name: wide_load_a4
; LOAD: LWZ{{X?}} {{.*}} :: (load (s32) from %ir.src + 16{{.*}}, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LWZ{{X?}} {{.*}} :: (load (s32) from %ir.src + 20{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <6 x i32>, ptr %src, align 4, !alias.scope !0, !noalias !3
  store <6 x i32> %value, ptr %dst, align 16
  ret void
}

define void @wide_load_a8(ptr %src, ptr %dst) {
; LOAD-LABEL: name: wide_load_a8
; LOAD: LWZ{{X?}} {{.*}} :: (load (s32) from %ir.src + 16{{.*}}, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LWZ{{X?}} {{.*}} :: (load (s32) from %ir.src + 20{{.*}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <6 x i32>, ptr %src, align 8, !alias.scope !0, !noalias !3
  store <6 x i32> %value, ptr %dst, align 16
  ret void
}

define void @wide_volatile_load(ptr %src, ptr %dst) {
; LOAD-LABEL: name: wide_volatile_load
; LOAD: LWZ{{X?}} {{.*}} :: (volatile load (s32) from %ir.src, !alias.scope [[VSCOPE:![0-9]+]], !noalias [[VNOALIAS:![0-9]+]])
; LOAD: LWZ{{X?}} {{.*}} :: (volatile load (s32) from %ir.src + 4, !alias.scope [[VSCOPE]], !noalias [[VNOALIAS]])
; LOAD: LWZ{{X?}} {{.*}} :: (volatile load (s32) from %ir.src + 8, !alias.scope [[VSCOPE]], !noalias [[VNOALIAS]])
; LOAD: LWZ{{X?}} {{.*}} :: (volatile load (s32) from %ir.src + 12, !alias.scope [[VSCOPE]], !noalias [[VNOALIAS]])
; LOAD: LWZ{{X?}} {{.*}} :: (volatile load (s32) from %ir.src + 16, !alias.scope [[VSCOPE]], !noalias [[VNOALIAS]])
; LOAD: LWZ{{X?}} {{.*}} :: (volatile load (s32) from %ir.src + 20, !alias.scope [[VSCOPE]], !noalias [[VNOALIAS]])
  %value = load volatile <6 x i32>, ptr %src, align 4, !alias.scope !0, !noalias !3
  store <6 x i32> %value, ptr %dst, align 16
  ret void
}

!0 = !{!1}
!1 = distinct !{!1, !2, !"access"}
!2 = distinct !{!2, i1 false, !"domain"}
!3 = !{!4}
!4 = distinct !{!4, !2, !"other"}
