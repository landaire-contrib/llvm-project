; RUN: split-file %s %t
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs \
; RUN:   -ppc-reg-with-percent-prefix < %t/normal.ll \
; RUN:   | FileCheck %s --check-prefix=VEC \
; RUN:   --implicit-check-not='{{(lvlx|lvrx|stvlx|stvrx)}}' \
; RUN:   --implicit-check-not='{{^[ \t]+std}}' --implicit-check-not='(%r1)' \
; RUN:   --implicit-check-not=', %r1{{([, ]|$)}}'
; RUN: llc -mtriple=powerpc64-unknown-linux-gnu -mcpu=970 \
; RUN:   -mattr=+altivec,-vsx -ppc-reg-with-percent-prefix < %t/normal.ll \
; RUN:   | FileCheck %s --check-prefix=OTHER \
; RUN:   --implicit-check-not='{{(stvebx|stvehx|stvewx)}}'
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -stop-after=finalize-isel \
; RUN:   -verify-machineinstrs < %t/normal.ll \
; RUN:   | FileCheck %s --check-prefix=MMO
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs \
; RUN:   -ppc-reg-with-percent-prefix < %t/volatile.ll \
; RUN:   | FileCheck %s --check-prefix=VOL \
; RUN:   --implicit-check-not='{{(lvlx|lvrx|stvlx|stvrx)}}'
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -stop-after=finalize-isel \
; RUN:   -verify-machineinstrs < %t/volatile.ll \
; RUN:   | FileCheck %s --check-prefix=VOL-MMO
;
; Native partial vector loads trap on write-combined memory at an unaligned
; address, even though guarded cached-memory accesses work. Generic pointers
; therefore cannot use those instructions. Stores instead rotate with LVSR
; and write exactly sixteen bytes with elements no wider than known alignment.
; Align8 still uses four word stores, not two potentially misaligned STD.

;--- normal.ll
define void @store_v4f32_a1(ptr %src, ptr %dst) {
; VEC-LABEL: store_v4f32_a1:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-16: stvebx %v[[ROTATED]],
; VEC-NOT: stvebx
; VEC: blr
; OTHER-LABEL: store_v4f32_a1:
; OTHER: blr
  %value = load <4 x float>, ptr %src, align 16
  store <4 x float> %value, ptr %dst, align 1
  ret void
}

define void @store_v4f32_a2(ptr %src, ptr %dst) {
; VEC-LABEL: store_v4f32_a2:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-8: stvehx %v[[ROTATED]],
; VEC-NOT: stvehx
; VEC: blr
  %value = load <4 x float>, ptr %src, align 16
  store <4 x float> %value, ptr %dst, align 2
  ret void
}

define void @store_v4f32_a4(ptr %src, ptr %dst) {
; VEC-LABEL: store_v4f32_a4:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-4: stvewx %v[[ROTATED]],
; VEC-NOT: stvewx
; VEC: blr
  %value = load <4 x float>, ptr %src, align 16
  store <4 x float> %value, ptr %dst, align 4
  ret void
}

define void @store_v4f32_a8(ptr %src, ptr %dst) {
; VEC-LABEL: store_v4f32_a8:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-4: stvewx %v[[ROTATED]],
; VEC-NOT: stvewx
; VEC: blr
  %value = load <4 x float>, ptr %src, align 16
  store <4 x float> %value, ptr %dst, align 8
  ret void
}

define void @store_v4i32_a1(ptr %src, ptr %dst) {
; VEC-LABEL: store_v4i32_a1:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-16: stvebx %v[[ROTATED]],
; VEC-NOT: stvebx
; VEC: blr
  %value = load <4 x i32>, ptr %src, align 16
  store <4 x i32> %value, ptr %dst, align 1
  ret void
}

define void @store_v4i32_a2(ptr %src, ptr %dst) {
; VEC-LABEL: store_v4i32_a2:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-8: stvehx %v[[ROTATED]],
; VEC-NOT: stvehx
; VEC: blr
  %value = load <4 x i32>, ptr %src, align 16
  store <4 x i32> %value, ptr %dst, align 2
  ret void
}

define void @store_v4i32_a4(ptr %src, ptr %dst) {
; VEC-LABEL: store_v4i32_a4:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-4: stvewx %v[[ROTATED]],
; VEC-NOT: stvewx
; VEC: blr
  %value = load <4 x i32>, ptr %src, align 16
  store <4 x i32> %value, ptr %dst, align 4
  ret void
}

define void @store_v4i32_a8(ptr %src, ptr %dst) {
; VEC-LABEL: store_v4i32_a8:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-4: stvewx %v[[ROTATED]],
; VEC-NOT: stvewx
; VEC: blr
  %value = load <4 x i32>, ptr %src, align 16
  store <4 x i32> %value, ptr %dst, align 8
  ret void
}

define void @store_v8i16_a1(ptr %src, ptr %dst) {
; VEC-LABEL: store_v8i16_a1:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-16: stvebx %v[[ROTATED]],
; VEC-NOT: stvebx
; VEC: blr
  %value = load <8 x i16>, ptr %src, align 16
  store <8 x i16> %value, ptr %dst, align 1
  ret void
}

define void @store_v8i16_a2(ptr %src, ptr %dst) {
; VEC-LABEL: store_v8i16_a2:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-8: stvehx %v[[ROTATED]],
; VEC-NOT: stvehx
; VEC: blr
  %value = load <8 x i16>, ptr %src, align 16
  store <8 x i16> %value, ptr %dst, align 2
  ret void
}

define void @store_v8i16_a4(ptr %src, ptr %dst) {
; VEC-LABEL: store_v8i16_a4:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-4: stvewx %v[[ROTATED]],
; VEC-NOT: stvewx
; VEC: blr
  %value = load <8 x i16>, ptr %src, align 16
  store <8 x i16> %value, ptr %dst, align 4
  ret void
}

define void @store_v8i16_a8(ptr %src, ptr %dst) {
; VEC-LABEL: store_v8i16_a8:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-4: stvewx %v[[ROTATED]],
; VEC-NOT: stvewx
; VEC: blr
  %value = load <8 x i16>, ptr %src, align 16
  store <8 x i16> %value, ptr %dst, align 8
  ret void
}

define void @store_v16i8_a1(ptr %src, ptr %dst) {
; VEC-LABEL: store_v16i8_a1:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-16: stvebx %v[[ROTATED]],
; VEC-NOT: stvebx
; VEC: blr
  %value = load <16 x i8>, ptr %src, align 16
  store <16 x i8> %value, ptr %dst, align 1
  ret void
}

define void @store_v16i8_a2(ptr %src, ptr %dst) {
; VEC-LABEL: store_v16i8_a2:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-8: stvehx %v[[ROTATED]],
; VEC-NOT: stvehx
; VEC: blr
  %value = load <16 x i8>, ptr %src, align 16
  store <16 x i8> %value, ptr %dst, align 2
  ret void
}

define void @store_v16i8_a4(ptr %src, ptr %dst) {
; VEC-LABEL: store_v16i8_a4:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-4: stvewx %v[[ROTATED]],
; VEC-NOT: stvewx
; VEC: blr
  %value = load <16 x i8>, ptr %src, align 16
  store <16 x i8> %value, ptr %dst, align 4
  ret void
}

define void @store_v16i8_a8(ptr %src, ptr %dst) {
; VEC-LABEL: store_v16i8_a8:
; VEC-DAG: lvx{{(128)?}} %v{{[0-9]+}}, 0, %r3
; VEC-DAG: lvsr %v{{[0-9]+}}, 0, %r4
; VEC: vperm{{(128)?}} %v[[ROTATED:[0-9]+]],
; VEC-COUNT-4: stvewx %v[[ROTATED]],
; VEC-NOT: stvewx
; VEC: blr
  %value = load <16 x i8>, ptr %src, align 16
  store <16 x i8> %value, ptr %dst, align 8
  ret void
}

; Known-aligned memory retains the single native load/store path.
define void @copy_aligned(ptr %src, ptr %dst) {
; VEC-LABEL: copy_aligned:
; VEC: lvx{{(128)?}} %v[[ALIGNED:[0-9]+]], 0, %r3
; VEC-NOT: lvsr
; VEC-NOT: vperm
; VEC: stvx{{(128)?}} %v[[ALIGNED]], 0, %r4
; VEC: blr
  %value = load <4 x i32>, ptr %src, align 16
  store <4 x i32> %value, ptr %dst, align 16
  ret void
}

; Nonvolatile loads keep the established aligned-load/permutation lowering.
define void @load_unaligned(ptr %src, ptr %dst) {
; VEC-LABEL: load_unaligned:
; VEC: lvsl
; VEC: vperm{{(128)?}}
; VEC: stvx{{(128)?}}
; VEC: blr
  %value = load <4 x i32>, ptr %src, align 1
  store <4 x i32> %value, ptr %dst, align 16
  ret void
}

; Original pointer offsets and alias metadata survive the exact subaccesses.
define void @store_offsets(ptr %src, ptr %dst) {
; VEC-LABEL: store_offsets:
; VEC: lvsr
; VEC: vperm{{(128)?}}
; VEC-COUNT-4: stvewx
; VEC: blr
; MMO-LABEL: name: store_offsets
; MMO-DAG: STVEWX {{.*}} :: (store (s32) into %ir.destination, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; MMO-DAG: STVEWX {{.*}} :: (store (s32) into %ir.destination + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; MMO-DAG: STVEWX {{.*}} :: (store (s32) into %ir.destination + 8, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; MMO-DAG: STVEWX {{.*}} :: (store (s32) into %ir.destination + 12, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %destination = getelementptr i8, ptr %dst, i32 -12
  %value = load <4 x i32>, ptr %src, align 16
  store <4 x i32> %value, ptr %destination, align 4, !alias.scope !0, !noalias !3
  ret void
}

!0 = !{!1}
!1 = distinct !{!1, !2, !"access"}
!2 = distinct !{!2, i1 false, !"domain"}
!3 = !{!4}
!4 = distinct !{!4, !2, !"other"}

;--- volatile.ll
; Volatile loads use exact, naturally aligned scalar accesses. On non-VSX
; hardware assembling their vector value may require an aligned stack slot;
; that must not widen or add observable accesses to the original source.
define void @volatile_load_a1(ptr %src, ptr %dst, ptr %marker) {
; VOL-LABEL: volatile_load_a1:
; VOL-COUNT-16: lbz 
; VOL: stb {{.*}}, 0(%r5)
; VOL: stvx{{(128)?}}
; VOL: blr
  %value = load volatile <4 x i32>, ptr %src, align 1, !alias.scope !0, !noalias !3
  store volatile i8 7, ptr %marker
  store <4 x i32> %value, ptr %dst, align 16
  ret void
}

define void @volatile_store_a1(ptr %src, ptr %dst, ptr %marker) {
; VOL-LABEL: volatile_store_a1:
; VOL: lvsr
; VOL: vperm{{(128)?}}
; VOL-COUNT-16: stvebx
; VOL: stb {{.*}}, 0(%r5)
; VOL: blr
  %value = load <4 x i32>, ptr %src, align 16
  store volatile <4 x i32> %value, ptr %dst, align 1, !alias.scope !0, !noalias !3
  store volatile i8 7, ptr %marker
  ret void
}

define void @volatile_load_a2(ptr %src, ptr %dst, ptr %marker) {
; VOL-LABEL: volatile_load_a2:
; VOL-COUNT-8: lhz 
; VOL: stb {{.*}}, 0(%r5)
; VOL: stvx{{(128)?}}
; VOL: blr
  %value = load volatile <4 x i32>, ptr %src, align 2, !alias.scope !0, !noalias !3
  store volatile i8 7, ptr %marker
  store <4 x i32> %value, ptr %dst, align 16
  ret void
}

define void @volatile_store_a2(ptr %src, ptr %dst, ptr %marker) {
; VOL-LABEL: volatile_store_a2:
; VOL: lvsr
; VOL: vperm{{(128)?}}
; VOL-COUNT-8: stvehx
; VOL: stb {{.*}}, 0(%r5)
; VOL: blr
  %value = load <4 x i32>, ptr %src, align 16
  store volatile <4 x i32> %value, ptr %dst, align 2, !alias.scope !0, !noalias !3
  store volatile i8 7, ptr %marker
  ret void
}

define void @volatile_load_a4(ptr %src, ptr %dst, ptr %marker) {
; VOL-LABEL: volatile_load_a4:
; VOL-COUNT-4: lwz 
; VOL: stb {{.*}}, 0(%r5)
; VOL: stvx{{(128)?}}
; VOL: blr
; VOL-MMO-LABEL: name: volatile_load_a4
; VOL-MMO: LWZ{{.*}} :: (volatile load (s32) from %ir.src, !alias.scope [[LSCOPE:![0-9]+]], !noalias [[LNOALIAS:![0-9]+]])
; VOL-MMO: LWZ{{.*}} :: (volatile load (s32) from %ir.src + 4, !alias.scope [[LSCOPE]], !noalias [[LNOALIAS]])
; VOL-MMO: LWZ{{.*}} :: (volatile load (s32) from %ir.src + 8, !alias.scope [[LSCOPE]], !noalias [[LNOALIAS]])
; VOL-MMO: LWZ{{.*}} :: (volatile load (s32) from %ir.src + 12, !alias.scope [[LSCOPE]], !noalias [[LNOALIAS]])
  %value = load volatile <4 x i32>, ptr %src, align 4, !alias.scope !0, !noalias !3
  store volatile i8 7, ptr %marker
  store <4 x i32> %value, ptr %dst, align 16
  ret void
}

define void @volatile_store_a4(ptr %src, ptr %dst, ptr %marker) {
; VOL-LABEL: volatile_store_a4:
; VOL: lvsr
; VOL: vperm{{(128)?}}
; VOL-COUNT-4: stvewx
; VOL: stb {{.*}}, 0(%r5)
; VOL: blr
; VOL-MMO-LABEL: name: volatile_store_a4
; VOL-MMO: STVEWX {{.*}} :: (volatile store (s32) into %ir.dst, !alias.scope [[SSCOPE:![0-9]+]], !noalias [[SNOALIAS:![0-9]+]])
; VOL-MMO: STVEWX {{.*}} :: (volatile store (s32) into %ir.dst + 4, !alias.scope [[SSCOPE]], !noalias [[SNOALIAS]])
; VOL-MMO: STVEWX {{.*}} :: (volatile store (s32) into %ir.dst + 8, !alias.scope [[SSCOPE]], !noalias [[SNOALIAS]])
; VOL-MMO: STVEWX {{.*}} :: (volatile store (s32) into %ir.dst + 12, !alias.scope [[SSCOPE]], !noalias [[SNOALIAS]])
  %value = load <4 x i32>, ptr %src, align 16
  store volatile <4 x i32> %value, ptr %dst, align 4, !alias.scope !0, !noalias !3
  store volatile i8 7, ptr %marker
  ret void
}

define void @volatile_load_a8(ptr %src, ptr %dst, ptr %marker) {
; VOL-LABEL: volatile_load_a8:
; VOL-COUNT-4: lwz 
; VOL: stb {{.*}}, 0(%r5)
; VOL: stvx{{(128)?}}
; VOL: blr
  %value = load volatile <4 x i32>, ptr %src, align 8, !alias.scope !0, !noalias !3
  store volatile i8 7, ptr %marker
  store <4 x i32> %value, ptr %dst, align 16
  ret void
}

define void @volatile_store_a8(ptr %src, ptr %dst, ptr %marker) {
; VOL-LABEL: volatile_store_a8:
; VOL: lvsr
; VOL: vperm{{(128)?}}
; VOL-COUNT-4: stvewx
; VOL: stb {{.*}}, 0(%r5)
; VOL: blr
  %value = load <4 x i32>, ptr %src, align 16
  store volatile <4 x i32> %value, ptr %dst, align 8, !alias.scope !0, !noalias !3
  store volatile i8 7, ptr %marker
  ret void
}

!0 = !{!1}
!1 = distinct !{!1, !2, !"access"}
!2 = distinct !{!2, i1 false, !"domain"}
!3 = !{!4}
!4 = distinct !{!4, !2, !"other"}
