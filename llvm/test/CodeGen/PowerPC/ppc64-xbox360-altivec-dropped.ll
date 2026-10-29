; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=+altivec \
; RUN:   -verify-machineinstrs -ppc-reg-with-percent-prefix < %s \
; RUN:   | FileCheck %s --check-prefixes=CHECK,NODROP \
; RUN:     --implicit-check-not='{{^[[:space:]]+(vmul[eo]|vmsum|vsum|vmhr?addshs|vmladduhm|dst|dss)}}'
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=+altivec -O0 \
; RUN:   -verify-machineinstrs -ppc-reg-with-percent-prefix < %s \
; RUN:   | FileCheck %s --check-prefix=NODROP
; RUN: llc -mtriple=powerpc64-unknown-linux-gnu -mcpu=g5 -mattr=+altivec \
; RUN:   -verify-machineinstrs -ppc-reg-with-percent-prefix < %s \
; RUN:   | FileCheck %s --check-prefix=ALTIVEC

; Xenon lacks the AltiVec integer multiplies, multiply-sums, sum-across and
; data stream instructions. This ISA restriction is independent of vmx128:
; their intrinsics and vector integer multiplies are expanded (the multiplies
; are scalarized), and the data stream hints are dropped. Ordinary Linux
; AltiVec retains the native operations.

; NODROP-NOT: {{^[[:space:]]+(vmul[eo]|vmsum|vsum|vmhr?addshs|vmladduhm|dst|dss)}}

; CHECK-LABEL: mul_v4i32:
; CHECK: mullw
; ALTIVEC-LABEL: mul_v4i32:
; ALTIVEC: vmulouh
define void @mul_v4i32(ptr %pa, ptr %pb) {
  %a = load <4 x i32>, ptr %pa
  %b = load <4 x i32>, ptr %pb
  %r = mul <4 x i32> %a, %b
  store <4 x i32> %r, ptr %pa
  ret void
}

; CHECK-LABEL: mul_v8i16:
; CHECK: mullw
; ALTIVEC-LABEL: mul_v8i16:
; ALTIVEC: vmladduhm
define void @mul_v8i16(ptr %pa, ptr %pb) {
  %a = load <8 x i16>, ptr %pa
  %b = load <8 x i16>, ptr %pb
  %r = mul <8 x i16> %a, %b
  store <8 x i16> %r, ptr %pa
  ret void
}

; CHECK-LABEL: mul_v16i8:
; CHECK: mullw
; ALTIVEC-LABEL: mul_v16i8:
; ALTIVEC: vmuleub
define void @mul_v16i8(ptr %pa, ptr %pb) {
  %a = load <16 x i8>, ptr %pa
  %b = load <16 x i8>, ptr %pb
  %r = mul <16 x i8> %a, %b
  store <16 x i8> %r, ptr %pa
  ret void
}

; CHECK-LABEL: test_vmuleub:
; CHECK: mullw
; ALTIVEC-LABEL: test_vmuleub:
; ALTIVEC: vmuleub
define void @test_vmuleub(ptr %p0, ptr %p1) {
  %a0 = load <16 x i8>, ptr %p0
  %a1 = load <16 x i8>, ptr %p1
  %r = call <8 x i16> @llvm.ppc.altivec.vmuleub(<16 x i8> %a0, <16 x i8> %a1)
  store <8 x i16> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmuloub:
; CHECK: mullw
; ALTIVEC-LABEL: test_vmuloub:
; ALTIVEC: vmuloub
define void @test_vmuloub(ptr %p0, ptr %p1) {
  %a0 = load <16 x i8>, ptr %p0
  %a1 = load <16 x i8>, ptr %p1
  %r = call <8 x i16> @llvm.ppc.altivec.vmuloub(<16 x i8> %a0, <16 x i8> %a1)
  store <8 x i16> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmulesb:
; CHECK: mullw
; ALTIVEC-LABEL: test_vmulesb:
; ALTIVEC: vmulesb
define void @test_vmulesb(ptr %p0, ptr %p1) {
  %a0 = load <16 x i8>, ptr %p0
  %a1 = load <16 x i8>, ptr %p1
  %r = call <8 x i16> @llvm.ppc.altivec.vmulesb(<16 x i8> %a0, <16 x i8> %a1)
  store <8 x i16> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmulosb:
; CHECK: mullw
; ALTIVEC-LABEL: test_vmulosb:
; ALTIVEC: vmulosb
define void @test_vmulosb(ptr %p0, ptr %p1) {
  %a0 = load <16 x i8>, ptr %p0
  %a1 = load <16 x i8>, ptr %p1
  %r = call <8 x i16> @llvm.ppc.altivec.vmulosb(<16 x i8> %a0, <16 x i8> %a1)
  store <8 x i16> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmuleuh:
; CHECK: mullw
; ALTIVEC-LABEL: test_vmuleuh:
; ALTIVEC: vmuleuh
define void @test_vmuleuh(ptr %p0, ptr %p1) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %r = call <4 x i32> @llvm.ppc.altivec.vmuleuh(<8 x i16> %a0, <8 x i16> %a1)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmulouh:
; CHECK: mullw
; ALTIVEC-LABEL: test_vmulouh:
; ALTIVEC: vmulouh
define void @test_vmulouh(ptr %p0, ptr %p1) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %r = call <4 x i32> @llvm.ppc.altivec.vmulouh(<8 x i16> %a0, <8 x i16> %a1)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmulesh:
; CHECK: mullw
; ALTIVEC-LABEL: test_vmulesh:
; ALTIVEC: vmulesh
define void @test_vmulesh(ptr %p0, ptr %p1) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %r = call <4 x i32> @llvm.ppc.altivec.vmulesh(<8 x i16> %a0, <8 x i16> %a1)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmulosh:
; CHECK: mullw
; ALTIVEC-LABEL: test_vmulosh:
; ALTIVEC: vmulosh
define void @test_vmulosh(ptr %p0, ptr %p1) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %r = call <4 x i32> @llvm.ppc.altivec.vmulosh(<8 x i16> %a0, <8 x i16> %a1)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmladduhm:
; CHECK: vadduhm
; ALTIVEC-LABEL: test_vmladduhm:
; ALTIVEC: vmladduhm
define void @test_vmladduhm(ptr %p0, ptr %p1, ptr %p2) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %a2 = load <8 x i16>, ptr %p2
  %r = call <8 x i16> @llvm.ppc.altivec.vmladduhm(<8 x i16> %a0, <8 x i16> %a1, <8 x i16> %a2)
  store <8 x i16> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmsumubm:
; CHECK: vadduwm
; ALTIVEC-LABEL: test_vmsumubm:
; ALTIVEC: vmsumubm
define void @test_vmsumubm(ptr %p0, ptr %p1, ptr %p2) {
  %a0 = load <16 x i8>, ptr %p0
  %a1 = load <16 x i8>, ptr %p1
  %a2 = load <4 x i32>, ptr %p2
  %r = call <4 x i32> @llvm.ppc.altivec.vmsumubm(<16 x i8> %a0, <16 x i8> %a1, <4 x i32> %a2)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmsummbm:
; CHECK: vadduwm
; ALTIVEC-LABEL: test_vmsummbm:
; ALTIVEC: vmsummbm
define void @test_vmsummbm(ptr %p0, ptr %p1, ptr %p2) {
  %a0 = load <16 x i8>, ptr %p0
  %a1 = load <16 x i8>, ptr %p1
  %a2 = load <4 x i32>, ptr %p2
  %r = call <4 x i32> @llvm.ppc.altivec.vmsummbm(<16 x i8> %a0, <16 x i8> %a1, <4 x i32> %a2)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmsumuhm:
; CHECK: vadduwm
; ALTIVEC-LABEL: test_vmsumuhm:
; ALTIVEC: vmsumuhm
define void @test_vmsumuhm(ptr %p0, ptr %p1, ptr %p2) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %a2 = load <4 x i32>, ptr %p2
  %r = call <4 x i32> @llvm.ppc.altivec.vmsumuhm(<8 x i16> %a0, <8 x i16> %a1, <4 x i32> %a2)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmsumshm:
; CHECK: vadduwm
; ALTIVEC-LABEL: test_vmsumshm:
; ALTIVEC: vmsumshm
define void @test_vmsumshm(ptr %p0, ptr %p1, ptr %p2) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %a2 = load <4 x i32>, ptr %p2
  %r = call <4 x i32> @llvm.ppc.altivec.vmsumshm(<8 x i16> %a0, <8 x i16> %a1, <4 x i32> %a2)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmsumuhs:
; CHECK: vpkuwus{{(128)?}}
; ALTIVEC-LABEL: test_vmsumuhs:
; ALTIVEC: vmsumuhs
define void @test_vmsumuhs(ptr %p0, ptr %p1, ptr %p2) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %a2 = load <4 x i32>, ptr %p2
  %r = call <4 x i32> @llvm.ppc.altivec.vmsumuhs(<8 x i16> %a0, <8 x i16> %a1, <4 x i32> %a2)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmsumshs:
; CHECK: vcmpgtsw
; ALTIVEC-LABEL: test_vmsumshs:
; ALTIVEC: vmsumshs
define void @test_vmsumshs(ptr %p0, ptr %p1, ptr %p2) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %a2 = load <4 x i32>, ptr %p2
  %r = call <4 x i32> @llvm.ppc.altivec.vmsumshs(<8 x i16> %a0, <8 x i16> %a1, <4 x i32> %a2)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vsum4ubs:
; CHECK: vpkuwus{{(128)?}}
; ALTIVEC-LABEL: test_vsum4ubs:
; ALTIVEC: vsum4ubs
define void @test_vsum4ubs(ptr %p0, ptr %p1) {
  %a0 = load <16 x i8>, ptr %p0
  %a1 = load <4 x i32>, ptr %p1
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4ubs(<16 x i8> %a0, <4 x i32> %a1)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vsum4sbs:
; CHECK: vpkuwus{{(128)?}}
; ALTIVEC-LABEL: test_vsum4sbs:
; ALTIVEC: vsum4sbs
define void @test_vsum4sbs(ptr %p0, ptr %p1) {
  %a0 = load <16 x i8>, ptr %p0
  %a1 = load <4 x i32>, ptr %p1
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4sbs(<16 x i8> %a0, <4 x i32> %a1)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vsum4shs:
; CHECK: vpkuwus{{(128)?}}
; ALTIVEC-LABEL: test_vsum4shs:
; ALTIVEC: vsum4shs
define void @test_vsum4shs(ptr %p0, ptr %p1) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <4 x i32>, ptr %p1
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4shs(<8 x i16> %a0, <4 x i32> %a1)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vsum2sws:
; CHECK: vcmpgtsw
; ALTIVEC-LABEL: test_vsum2sws:
; ALTIVEC: vsum2sws
define void @test_vsum2sws(ptr %p0, ptr %p1) {
  %a0 = load <4 x i32>, ptr %p0
  %a1 = load <4 x i32>, ptr %p1
  %r = call <4 x i32> @llvm.ppc.altivec.vsum2sws(<4 x i32> %a0, <4 x i32> %a1)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vsumsws:
; CHECK: vcmpgtsw
; ALTIVEC-LABEL: test_vsumsws:
; ALTIVEC: vsumsws
define void @test_vsumsws(ptr %p0, ptr %p1) {
  %a0 = load <4 x i32>, ptr %p0
  %a1 = load <4 x i32>, ptr %p1
  %r = call <4 x i32> @llvm.ppc.altivec.vsumsws(<4 x i32> %a0, <4 x i32> %a1)
  store <4 x i32> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmhaddshs:
; CHECK: vpkswss{{(128)?}}
; ALTIVEC-LABEL: test_vmhaddshs:
; ALTIVEC: vmhaddshs
define void @test_vmhaddshs(ptr %p0, ptr %p1, ptr %p2) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %a2 = load <8 x i16>, ptr %p2
  %r = call <8 x i16> @llvm.ppc.altivec.vmhaddshs(<8 x i16> %a0, <8 x i16> %a1, <8 x i16> %a2)
  store <8 x i16> %r, ptr %p0
  ret void
}

; CHECK-LABEL: test_vmhraddshs:
; CHECK: vpkswss{{(128)?}}
; ALTIVEC-LABEL: test_vmhraddshs:
; ALTIVEC: vmhraddshs
define void @test_vmhraddshs(ptr %p0, ptr %p1, ptr %p2) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %a2 = load <8 x i16>, ptr %p2
  %r = call <8 x i16> @llvm.ppc.altivec.vmhraddshs(<8 x i16> %a0, <8 x i16> %a1, <8 x i16> %a2)
  store <8 x i16> %r, ptr %p0
  ret void
}

; CHECK-LABEL: data_stream:
; CHECK: # %bb.0:
; CHECK-NEXT: blr
; ALTIVEC-LABEL: data_stream:
; ALTIVEC: dst
; ALTIVEC: dststt
; ALTIVEC: dss
; ALTIVEC: dssall
define void @data_stream(ptr %p, i32 %c) {
  call void @llvm.ppc.altivec.dst(ptr %p, i32 %c, i32 0)
  call void @llvm.ppc.altivec.dstt(ptr %p, i32 %c, i32 1)
  call void @llvm.ppc.altivec.dstst(ptr %p, i32 %c, i32 2)
  call void @llvm.ppc.altivec.dststt(ptr %p, i32 %c, i32 3)
  call void @llvm.ppc.altivec.dss(i32 0)
  call void @llvm.ppc.altivec.dssall()
  ret void
}

declare <8 x i16> @llvm.ppc.altivec.vmuleub(<16 x i8>, <16 x i8>)

declare <8 x i16> @llvm.ppc.altivec.vmuloub(<16 x i8>, <16 x i8>)

declare <8 x i16> @llvm.ppc.altivec.vmulesb(<16 x i8>, <16 x i8>)

declare <8 x i16> @llvm.ppc.altivec.vmulosb(<16 x i8>, <16 x i8>)

declare <4 x i32> @llvm.ppc.altivec.vmuleuh(<8 x i16>, <8 x i16>)

declare <4 x i32> @llvm.ppc.altivec.vmulouh(<8 x i16>, <8 x i16>)

declare <4 x i32> @llvm.ppc.altivec.vmulesh(<8 x i16>, <8 x i16>)

declare <4 x i32> @llvm.ppc.altivec.vmulosh(<8 x i16>, <8 x i16>)

declare <8 x i16> @llvm.ppc.altivec.vmladduhm(<8 x i16>, <8 x i16>, <8 x i16>)

declare <4 x i32> @llvm.ppc.altivec.vmsumubm(<16 x i8>, <16 x i8>, <4 x i32>)

declare <4 x i32> @llvm.ppc.altivec.vmsummbm(<16 x i8>, <16 x i8>, <4 x i32>)

declare <4 x i32> @llvm.ppc.altivec.vmsumuhm(<8 x i16>, <8 x i16>, <4 x i32>)

declare <4 x i32> @llvm.ppc.altivec.vmsumshm(<8 x i16>, <8 x i16>, <4 x i32>)

declare <4 x i32> @llvm.ppc.altivec.vmsumuhs(<8 x i16>, <8 x i16>, <4 x i32>)

declare <4 x i32> @llvm.ppc.altivec.vmsumshs(<8 x i16>, <8 x i16>, <4 x i32>)

declare <4 x i32> @llvm.ppc.altivec.vsum4ubs(<16 x i8>, <4 x i32>)

declare <4 x i32> @llvm.ppc.altivec.vsum4sbs(<16 x i8>, <4 x i32>)

declare <4 x i32> @llvm.ppc.altivec.vsum4shs(<8 x i16>, <4 x i32>)

declare <4 x i32> @llvm.ppc.altivec.vsum2sws(<4 x i32>, <4 x i32>)

declare <4 x i32> @llvm.ppc.altivec.vsumsws(<4 x i32>, <4 x i32>)

declare <8 x i16> @llvm.ppc.altivec.vmhaddshs(<8 x i16>, <8 x i16>, <8 x i16>)

declare <8 x i16> @llvm.ppc.altivec.vmhraddshs(<8 x i16>, <8 x i16>, <8 x i16>)

declare void @llvm.ppc.altivec.dst(ptr, i32, i32)

declare void @llvm.ppc.altivec.dstt(ptr, i32, i32)

declare void @llvm.ppc.altivec.dstst(ptr, i32, i32)

declare void @llvm.ppc.altivec.dststt(ptr, i32, i32)

declare void @llvm.ppc.altivec.dss(i32)

declare void @llvm.ppc.altivec.dssall()

; CHECK-LABEL: partial_reduce
; CHECK: mullw
; ALTIVEC-LABEL: partial_reduce
; ALTIVEC: vmsumuhm
define i32 @partial_reduce(ptr %a, ptr %b) {
  %va = load <8 x i16>, ptr %a, align 2
  %za = zext <8 x i16> %va to <8 x i32>
  %vb = load <8 x i16>, ptr %b, align 2
  %zb = zext <8 x i16> %vb to <8 x i32>
  %mul = mul <8 x i32> %za, %zb
  %part = call <4 x i32> @llvm.vector.partial.reduce.add.v4i32.v8i32(<4 x i32> zeroinitializer, <8 x i32> %mul)
  %red = call i32 @llvm.vector.reduce.add.v4i32(<4 x i32> %part)
  ret i32 %red
}
