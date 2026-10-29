; RUN: split-file %s %t
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs \
; RUN:   -ppc-reg-with-percent-prefix < %t/stores.ll \
; RUN:   | FileCheck %s --check-prefix=STORE \
; RUN:   --implicit-check-not='{{^[ \t]+std}}' --implicit-check-not='(%r1)' \
; RUN:   --implicit-check-not='{{(lvlx|lvrx|stvlx|stvrx)}}'
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -stop-after=finalize-isel \
; RUN:   -verify-machineinstrs < %t/loads.ll | FileCheck %s --check-prefix=LOAD
;
; Widening sub-register vectors must not replace an align1/2/4 access with
; a packed, misaligned doubleword access. Widen only register values; keep
; every memory operation within the original region and its known alignment.
; Non-power-of-two sizes also cover incomplete word tails.

;--- stores.ll
define void @partial_store_v4i16_a1(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v4i16_a1:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-8: stvebx %v[[VALUE]],
; STORE-NOT: stvebx
; STORE: blr
  %full = load <8 x i16>, ptr %src, align 16
  %value = shufflevector <8 x i16> %full, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  store <4 x i16> %value, ptr %dst, align 1
  ret void
}

define void @partial_store_v4i16_a2(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v4i16_a2:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-4: stvehx %v[[VALUE]],
; STORE-NOT: stvehx
; STORE: blr
  %full = load <8 x i16>, ptr %src, align 16
  %value = shufflevector <8 x i16> %full, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  store <4 x i16> %value, ptr %dst, align 2
  ret void
}

define void @partial_store_v4i16_a4(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v4i16_a4:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-2: stvewx %v[[VALUE]],
; STORE-NOT: stvewx
; STORE: blr
  %full = load <8 x i16>, ptr %src, align 16
  %value = shufflevector <8 x i16> %full, <8 x i16> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  store <4 x i16> %value, ptr %dst, align 4
  ret void
}

define void @partial_store_v2i32_a1(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v2i32_a1:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-8: stvebx %v[[VALUE]],
; STORE-NOT: stvebx
; STORE: blr
  %full = load <4 x i32>, ptr %src, align 16
  %value = shufflevector <4 x i32> %full, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  store <2 x i32> %value, ptr %dst, align 1
  ret void
}

define void @partial_store_v2i32_a2(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v2i32_a2:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-4: stvehx %v[[VALUE]],
; STORE-NOT: stvehx
; STORE: blr
  %full = load <4 x i32>, ptr %src, align 16
  %value = shufflevector <4 x i32> %full, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  store <2 x i32> %value, ptr %dst, align 2
  ret void
}

define void @partial_store_v2i32_a4(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v2i32_a4:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-2: stvewx %v[[VALUE]],
; STORE-NOT: stvewx
; STORE: blr
  %full = load <4 x i32>, ptr %src, align 16
  %value = shufflevector <4 x i32> %full, <4 x i32> poison, <2 x i32> <i32 0, i32 1>
  store <2 x i32> %value, ptr %dst, align 4
  ret void
}

define void @partial_store_v3i16_a1(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v3i16_a1:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-6: stvebx %v[[VALUE]],
; STORE-NOT: stvebx
; STORE: blr
  %full = load <8 x i16>, ptr %src, align 16
  %value = shufflevector <8 x i16> %full, <8 x i16> poison, <3 x i32> <i32 0, i32 1, i32 2>
  store <3 x i16> %value, ptr %dst, align 1
  ret void
}

define void @partial_store_v3i16_a2(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v3i16_a2:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-3: stvehx %v[[VALUE]],
; STORE-NOT: stvehx
; STORE: blr
  %full = load <8 x i16>, ptr %src, align 16
  %value = shufflevector <8 x i16> %full, <8 x i16> poison, <3 x i32> <i32 0, i32 1, i32 2>
  store <3 x i16> %value, ptr %dst, align 2
  ret void
}

define void @partial_store_v3i16_a4(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v3i16_a4:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-3: stvehx %v[[VALUE]],
; STORE-NOT: stvehx
; STORE: blr
  %full = load <8 x i16>, ptr %src, align 16
  %value = shufflevector <8 x i16> %full, <8 x i16> poison, <3 x i32> <i32 0, i32 1, i32 2>
  store <3 x i16> %value, ptr %dst, align 4
  ret void
}

define void @partial_store_v3i32_a1(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v3i32_a1:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-12: stvebx %v[[VALUE]],
; STORE-NOT: stvebx
; STORE: blr
  %full = load <4 x i32>, ptr %src, align 16
  %value = shufflevector <4 x i32> %full, <4 x i32> poison, <3 x i32> <i32 0, i32 1, i32 2>
  store <3 x i32> %value, ptr %dst, align 1
  ret void
}

define void @partial_store_v3i32_a2(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v3i32_a2:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-6: stvehx %v[[VALUE]],
; STORE-NOT: stvehx
; STORE: blr
  %full = load <4 x i32>, ptr %src, align 16
  %value = shufflevector <4 x i32> %full, <4 x i32> poison, <3 x i32> <i32 0, i32 1, i32 2>
  store <3 x i32> %value, ptr %dst, align 2
  ret void
}

define void @partial_store_v3i32_a4(ptr %src, ptr %dst) {
; STORE-LABEL: partial_store_v3i32_a4:
; STORE: lvsr
; STORE: vperm{{(128)?}} %v[[VALUE:[0-9]+]],
; STORE-COUNT-3: stvewx %v[[VALUE]],
; STORE-NOT: stvewx
; STORE: blr
  %full = load <4 x i32>, ptr %src, align 16
  %value = shufflevector <4 x i32> %full, <4 x i32> poison, <3 x i32> <i32 0, i32 1, i32 2>
  store <3 x i32> %value, ptr %dst, align 4
  ret void
}

;--- loads.ll
define void @partial_load_v4i16_a1(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v4i16_a1
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 1, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 2, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 3, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 5, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 6, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 7, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <4 x i16>, ptr %src, align 1, !alias.scope !0, !noalias !3
  %added = add <4 x i16> %value, <i16 1, i16 1, i16 1, i16 1>
  %full = shufflevector <4 x i16> %added, <4 x i16> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 poison, i32 poison, i32 poison, i32 poison>
  store <8 x i16> %full, ptr %dst, align 16
  ret void
}

define void @partial_load_v4i16_a2(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v4i16_a2
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 2, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 6, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <4 x i16>, ptr %src, align 2, !alias.scope !0, !noalias !3
  %added = add <4 x i16> %value, <i16 1, i16 1, i16 1, i16 1>
  %full = shufflevector <4 x i16> %added, <4 x i16> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 poison, i32 poison, i32 poison, i32 poison>
  store <8 x i16> %full, ptr %dst, align 16
  ret void
}

define void @partial_load_v4i16_a4(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v4i16_a4
; LOAD: LWZ{{X?}} {{.*}} :: (load (s32) from %ir.src, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LWZ{{X?}} {{.*}} :: (load (s32) from %ir.src + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <4 x i16>, ptr %src, align 4, !alias.scope !0, !noalias !3
  %added = add <4 x i16> %value, <i16 1, i16 1, i16 1, i16 1>
  %full = shufflevector <4 x i16> %added, <4 x i16> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 poison, i32 poison, i32 poison, i32 poison>
  store <8 x i16> %full, ptr %dst, align 16
  ret void
}

define void @partial_load_v2i32_a1(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v2i32_a1
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 1, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 2, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 3, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 5, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 6, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 7, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <2 x i32>, ptr %src, align 1, !alias.scope !0, !noalias !3
  %added = add <2 x i32> %value, <i32 1, i32 1>
  %full = shufflevector <2 x i32> %added, <2 x i32> poison, <4 x i32> <i32 0, i32 1, i32 poison, i32 poison>
  store <4 x i32> %full, ptr %dst, align 16
  ret void
}

define void @partial_load_v2i32_a2(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v2i32_a2
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 2, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 6, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <2 x i32>, ptr %src, align 2, !alias.scope !0, !noalias !3
  %added = add <2 x i32> %value, <i32 1, i32 1>
  %full = shufflevector <2 x i32> %added, <2 x i32> poison, <4 x i32> <i32 0, i32 1, i32 poison, i32 poison>
  store <4 x i32> %full, ptr %dst, align 16
  ret void
}

define void @partial_load_v2i32_a4(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v2i32_a4
; LOAD: LWZ{{X?}} {{.*}} :: (load (s32) from %ir.src, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LWZ{{X?}} {{.*}} :: (load (s32) from %ir.src + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <2 x i32>, ptr %src, align 4, !alias.scope !0, !noalias !3
  %added = add <2 x i32> %value, <i32 1, i32 1>
  %full = shufflevector <2 x i32> %added, <2 x i32> poison, <4 x i32> <i32 0, i32 1, i32 poison, i32 poison>
  store <4 x i32> %full, ptr %dst, align 16
  ret void
}

define void @partial_load_v3i16_a1(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v3i16_a1
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 1, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 2, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 3, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 5, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <3 x i16>, ptr %src, align 1, !alias.scope !0, !noalias !3
  %added = add <3 x i16> %value, <i16 1, i16 1, i16 1>
  %full = shufflevector <3 x i16> %added, <3 x i16> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison>
  store <8 x i16> %full, ptr %dst, align 16
  ret void
}

define void @partial_load_v3i16_a2(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v3i16_a2
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 2, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <3 x i16>, ptr %src, align 2, !alias.scope !0, !noalias !3
  %added = add <3 x i16> %value, <i16 1, i16 1, i16 1>
  %full = shufflevector <3 x i16> %added, <3 x i16> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison>
  store <8 x i16> %full, ptr %dst, align 16
  ret void
}

define void @partial_load_v3i16_a4(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v3i16_a4
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src{{(, (base)?align [0-9]+)?}}, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 2{{(, (base)?align [0-9]+)?}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 4{{(, (base)?align [0-9]+)?}}, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <3 x i16>, ptr %src, align 4, !alias.scope !0, !noalias !3
  %added = add <3 x i16> %value, <i16 1, i16 1, i16 1>
  %full = shufflevector <3 x i16> %added, <3 x i16> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison>
  store <8 x i16> %full, ptr %dst, align 16
  ret void
}

define void @partial_load_v3i32_a1(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v3i32_a1
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 1, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 2, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 3, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 5, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 6, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 7, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 8, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 9, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 10, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LBZ{{X?}} {{.*}} :: (load (s8) from %ir.src + 11, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <3 x i32>, ptr %src, align 1, !alias.scope !0, !noalias !3
  %added = add <3 x i32> %value, <i32 1, i32 1, i32 1>
  %full = shufflevector <3 x i32> %added, <3 x i32> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 poison>
  store <4 x i32> %full, ptr %dst, align 16
  ret void
}

define void @partial_load_v3i32_a2(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v3i32_a2
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 2, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 6, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 8, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LHZ{{X?}} {{.*}} :: (load (s16) from %ir.src + 10, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <3 x i32>, ptr %src, align 2, !alias.scope !0, !noalias !3
  %added = add <3 x i32> %value, <i32 1, i32 1, i32 1>
  %full = shufflevector <3 x i32> %added, <3 x i32> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 poison>
  store <4 x i32> %full, ptr %dst, align 16
  ret void
}

define void @partial_load_v3i32_a4(ptr %src, ptr %dst) {
; LOAD-LABEL: name: partial_load_v3i32_a4
; LOAD: LWZ{{X?}} {{.*}} :: (load (s32) from %ir.src, !alias.scope [[SCOPE:![0-9]+]], !noalias [[NOALIAS:![0-9]+]])
; LOAD: LWZ{{X?}} {{.*}} :: (load (s32) from %ir.src + 4, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
; LOAD: LWZ{{X?}} {{.*}} :: (load (s32) from %ir.src + 8, !alias.scope [[SCOPE]], !noalias [[NOALIAS]])
  %value = load <3 x i32>, ptr %src, align 4, !alias.scope !0, !noalias !3
  %added = add <3 x i32> %value, <i32 1, i32 1, i32 1>
  %full = shufflevector <3 x i32> %added, <3 x i32> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 poison>
  store <4 x i32> %full, ptr %dst, align 16
  ret void
}

!0 = !{!1}
!1 = distinct !{!1, !2, !"access"}
!2 = distinct !{!2, i1 false, !"domain"}
!3 = !{!4}
!4 = distinct !{!4, !2, !"other"}
