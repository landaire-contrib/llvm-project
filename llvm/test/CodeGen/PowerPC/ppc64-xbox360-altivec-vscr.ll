; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=+altivec,+vmx128 \
; RUN:   -verify-machineinstrs -ppc-reg-with-percent-prefix < %s \
; RUN:   | FileCheck %s
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=+altivec,+vmx128 -O0 \
; RUN:   -verify-machineinstrs -ppc-reg-with-percent-prefix < %s \
; RUN:   | FileCheck %s
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=+altivec,-vmx128 \
; RUN:   -verify-machineinstrs -ppc-reg-with-percent-prefix < %s \
; RUN:   | FileCheck %s --check-prefix=CLASSIC
; RUN: llc -mtriple=powerpc64-unknown-linux-gnu -mcpu=g5 -mattr=+altivec \
; RUN:   -verify-machineinstrs -ppc-reg-with-percent-prefix < %s \
; RUN:   | FileCheck %s --check-prefix=ALTIVEC

; The expansions of the saturating intrinsics Xenon lacks set VSCR[SAT] with a
; saturating pack, ordered between the surrounding mtvscr and mfvscr. With
; constant operands the pack input shows whether a word saturated.

; CLASSIC-LABEL: var_vmsumuhs:
; CLASSIC: mtvscr
; CLASSIC: vpkuwus
; CLASSIC: mfvscr

; CHECK-LABEL: var_vmsumuhs:
; CHECK: mtvscr
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[M:%v[0-9]+]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: var_vmsumuhs:
; ALTIVEC: mtvscr
; ALTIVEC: vmsumuhs
; ALTIVEC: mfvscr
define void @var_vmsumuhs(ptr %p0, ptr %p1, ptr %p2, ptr %pr, ptr %ps) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %a2 = load <4 x i32>, ptr %p2
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vmsumuhs(<8 x i16> %a0, <8 x i16> %a1, <4 x i32> %a2)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: sat_vmsumuhs:
; CHECK: mtvscr
; CHECK: vspltisw128 [[M:%v[0-9]+]], -1
; CHECK-NEXT: vpkuwus128 {{%v[0-9]+}}, [[M]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: sat_vmsumuhs:
; ALTIVEC: mtvscr
; ALTIVEC: vmsumuhs
; ALTIVEC: mfvscr
define void @sat_vmsumuhs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vmsumuhs(<8 x i16> <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>, <8 x i16> <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>, <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: nosat_vmsumuhs:
; CHECK: vspltisw128 [[Z:%v[0-9]+]], 0
; CHECK: mtvscr [[Z]]
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[Z]], [[Z]]
; CHECK: mfvscr
; ALTIVEC-LABEL: nosat_vmsumuhs:
; ALTIVEC: mtvscr
; ALTIVEC: vmsumuhs
; ALTIVEC: mfvscr
define void @nosat_vmsumuhs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vmsumuhs(<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, <8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: var_vmsumshs:
; CHECK: mtvscr
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[M:%v[0-9]+]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: var_vmsumshs:
; ALTIVEC: mtvscr
; ALTIVEC: vmsumshs
; ALTIVEC: mfvscr
define void @var_vmsumshs(ptr %p0, ptr %p1, ptr %p2, ptr %pr, ptr %ps) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %a2 = load <4 x i32>, ptr %p2
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vmsumshs(<8 x i16> %a0, <8 x i16> %a1, <4 x i32> %a2)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: sat_vmsumshs:
; CHECK: mtvscr
; CHECK: vspltisw128 [[M:%v[0-9]+]], -1
; CHECK-NEXT: vpkuwus128 {{%v[0-9]+}}, [[M]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: sat_vmsumshs:
; ALTIVEC: mtvscr
; ALTIVEC: vmsumshs
; ALTIVEC: mfvscr
define void @sat_vmsumshs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vmsumshs(<8 x i16> <i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768>, <8 x i16> <i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: nosat_vmsumshs:
; CHECK: vspltisw128 [[Z:%v[0-9]+]], 0
; CHECK: mtvscr [[Z]]
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[Z]], [[Z]]
; CHECK: mfvscr
; ALTIVEC-LABEL: nosat_vmsumshs:
; ALTIVEC: mtvscr
; ALTIVEC: vmsumshs
; ALTIVEC: mfvscr
define void @nosat_vmsumshs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vmsumshs(<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, <8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: var_vsum4ubs:
; CHECK: mtvscr
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[M:%v[0-9]+]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: var_vsum4ubs:
; ALTIVEC: mtvscr
; ALTIVEC: vsum4ubs
; ALTIVEC: mfvscr
define void @var_vsum4ubs(ptr %p0, ptr %p1, ptr %pr, ptr %ps) {
  %a0 = load <16 x i8>, ptr %p0
  %a1 = load <4 x i32>, ptr %p1
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4ubs(<16 x i8> %a0, <4 x i32> %a1)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: sat_vsum4ubs:
; CHECK: mtvscr
; CHECK: vspltisw128 [[M:%v[0-9]+]], -1
; CHECK-NEXT: vpkuwus128 {{%v[0-9]+}}, [[M]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: sat_vsum4ubs:
; ALTIVEC: mtvscr
; ALTIVEC: vsum4ubs
; ALTIVEC: mfvscr
define void @sat_vsum4ubs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4ubs(<16 x i8> <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>, <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: nosat_vsum4ubs:
; CHECK: vspltisw128 [[Z:%v[0-9]+]], 0
; CHECK: mtvscr [[Z]]
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[Z]], [[Z]]
; CHECK: mfvscr
; ALTIVEC-LABEL: nosat_vsum4ubs:
; ALTIVEC: mtvscr
; ALTIVEC: vsum4ubs
; ALTIVEC: mfvscr
define void @nosat_vsum4ubs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4ubs(<16 x i8> <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: var_vsum4sbs:
; CHECK: mtvscr
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[M:%v[0-9]+]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: var_vsum4sbs:
; ALTIVEC: mtvscr
; ALTIVEC: vsum4sbs
; ALTIVEC: mfvscr
define void @var_vsum4sbs(ptr %p0, ptr %p1, ptr %pr, ptr %ps) {
  %a0 = load <16 x i8>, ptr %p0
  %a1 = load <4 x i32>, ptr %p1
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4sbs(<16 x i8> %a0, <4 x i32> %a1)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: sat_vsum4sbs:
; CHECK: mtvscr
; CHECK: vspltisw128 [[M:%v[0-9]+]], -1
; CHECK-NEXT: vpkuwus128 {{%v[0-9]+}}, [[M]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: sat_vsum4sbs:
; ALTIVEC: mtvscr
; ALTIVEC: vsum4sbs
; ALTIVEC: mfvscr
define void @sat_vsum4sbs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4sbs(<16 x i8> <i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127, i8 127>, <4 x i32> <i32 2147483647, i32 2147483647, i32 2147483647, i32 2147483647>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: nosat_vsum4sbs:
; CHECK: vspltisw128 [[Z:%v[0-9]+]], 0
; CHECK: mtvscr [[Z]]
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[Z]], [[Z]]
; CHECK: mfvscr
; ALTIVEC-LABEL: nosat_vsum4sbs:
; ALTIVEC: mtvscr
; ALTIVEC: vsum4sbs
; ALTIVEC: mfvscr
define void @nosat_vsum4sbs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4sbs(<16 x i8> <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: var_vsum4shs:
; CHECK: mtvscr
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[M:%v[0-9]+]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: var_vsum4shs:
; ALTIVEC: mtvscr
; ALTIVEC: vsum4shs
; ALTIVEC: mfvscr
define void @var_vsum4shs(ptr %p0, ptr %p1, ptr %pr, ptr %ps) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <4 x i32>, ptr %p1
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4shs(<8 x i16> %a0, <4 x i32> %a1)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: sat_vsum4shs:
; CHECK: mtvscr
; CHECK: vspltisw128 [[M:%v[0-9]+]], -1
; CHECK-NEXT: vpkuwus128 {{%v[0-9]+}}, [[M]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: sat_vsum4shs:
; ALTIVEC: mtvscr
; ALTIVEC: vsum4shs
; ALTIVEC: mfvscr
define void @sat_vsum4shs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4shs(<8 x i16> <i16 32767, i16 32767, i16 32767, i16 32767, i16 32767, i16 32767, i16 32767, i16 32767>, <4 x i32> <i32 2147483647, i32 2147483647, i32 2147483647, i32 2147483647>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: nosat_vsum4shs:
; CHECK: vspltisw128 [[Z:%v[0-9]+]], 0
; CHECK: mtvscr [[Z]]
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[Z]], [[Z]]
; CHECK: mfvscr
; ALTIVEC-LABEL: nosat_vsum4shs:
; ALTIVEC: mtvscr
; ALTIVEC: vsum4shs
; ALTIVEC: mfvscr
define void @nosat_vsum4shs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum4shs(<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: var_vsum2sws:
; CHECK: mtvscr
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[M:%v[0-9]+]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: var_vsum2sws:
; ALTIVEC: mtvscr
; ALTIVEC: vsum2sws
; ALTIVEC: mfvscr
define void @var_vsum2sws(ptr %p0, ptr %p1, ptr %pr, ptr %ps) {
  %a0 = load <4 x i32>, ptr %p0
  %a1 = load <4 x i32>, ptr %p1
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum2sws(<4 x i32> %a0, <4 x i32> %a1)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK: [[MASK:\.LCPI[0-9]+_[0-9]+]]:
; CHECK-NEXT: .long 0
; CHECK-NEXT: .long 4294967295
; CHECK-NEXT: .long 0
; CHECK-NEXT: .long 4294967295
; CHECK-LABEL: sat_vsum2sws:
; CHECK-DAG: mtvscr
; CHECK-DAG: li [[LO:%r[0-9]+]], [[MASK]]@l
; CHECK-DAG: lis [[HI:%r[0-9]+]], [[MASK]]@ha
; CHECK: lvx128 [[M:%v[0-9]+]], [[HI]], [[LO]]
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[M]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: sat_vsum2sws:
; ALTIVEC: mtvscr
; ALTIVEC: vsum2sws
; ALTIVEC: mfvscr
define void @sat_vsum2sws(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum2sws(<4 x i32> <i32 2147483647, i32 2147483647, i32 2147483647, i32 2147483647>, <4 x i32> <i32 2147483647, i32 2147483647, i32 2147483647, i32 2147483647>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: nosat_vsum2sws:
; CHECK: vspltisw128 [[Z:%v[0-9]+]], 0
; CHECK: mtvscr [[Z]]
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[Z]], [[Z]]
; CHECK: mfvscr
; ALTIVEC-LABEL: nosat_vsum2sws:
; ALTIVEC: mtvscr
; ALTIVEC: vsum2sws
; ALTIVEC: mfvscr
define void @nosat_vsum2sws(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsum2sws(<4 x i32> <i32 1, i32 1, i32 1, i32 1>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: var_vsumsws:
; CHECK: mtvscr
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[M:%v[0-9]+]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: var_vsumsws:
; ALTIVEC: mtvscr
; ALTIVEC: vsumsws
; ALTIVEC: mfvscr
define void @var_vsumsws(ptr %p0, ptr %p1, ptr %pr, ptr %ps) {
  %a0 = load <4 x i32>, ptr %p0
  %a1 = load <4 x i32>, ptr %p1
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsumsws(<4 x i32> %a0, <4 x i32> %a1)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK: [[MASK:\.LCPI[0-9]+_[0-9]+]]:
; CHECK-NEXT: .long 0
; CHECK-NEXT: .long 0
; CHECK-NEXT: .long 0
; CHECK-NEXT: .long 4294967295
; CHECK-LABEL: sat_vsumsws:
; CHECK-DAG: mtvscr
; CHECK-DAG: li [[LO:%r[0-9]+]], [[MASK]]@l
; CHECK-DAG: lis [[HI:%r[0-9]+]], [[MASK]]@ha
; CHECK: lvx128 [[M:%v[0-9]+]], [[HI]], [[LO]]
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[M]], [[M]]
; CHECK: mfvscr
; ALTIVEC-LABEL: sat_vsumsws:
; ALTIVEC: mtvscr
; ALTIVEC: vsumsws
; ALTIVEC: mfvscr
define void @sat_vsumsws(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsumsws(<4 x i32> <i32 2147483647, i32 2147483647, i32 2147483647, i32 2147483647>, <4 x i32> <i32 2147483647, i32 2147483647, i32 2147483647, i32 2147483647>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: nosat_vsumsws:
; CHECK: vspltisw128 [[Z:%v[0-9]+]], 0
; CHECK: mtvscr [[Z]]
; CHECK: vpkuwus128 {{%v[0-9]+}}, [[Z]], [[Z]]
; CHECK: mfvscr
; ALTIVEC-LABEL: nosat_vsumsws:
; ALTIVEC: mtvscr
; ALTIVEC: vsumsws
; ALTIVEC: mfvscr
define void @nosat_vsumsws(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <4 x i32> @llvm.ppc.altivec.vsumsws(<4 x i32> <i32 1, i32 1, i32 1, i32 1>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <4 x i32> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: var_vmhaddshs:
; CHECK: mtvscr
; CHECK: vpkswss128 {{%v[0-9]+}}, {{%v[0-9]+}}, {{%v[0-9]+}}
; CHECK: mfvscr
; ALTIVEC-LABEL: var_vmhaddshs:
; ALTIVEC: mtvscr
; ALTIVEC: vmhaddshs
; ALTIVEC: mfvscr
define void @var_vmhaddshs(ptr %p0, ptr %p1, ptr %p2, ptr %pr, ptr %ps) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %a2 = load <8 x i16>, ptr %p2
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <8 x i16> @llvm.ppc.altivec.vmhaddshs(<8 x i16> %a0, <8 x i16> %a1, <8 x i16> %a2)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <8 x i16> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: sat_vmhaddshs:
; CHECK: mtvscr
; CHECK: vspltisw128 [[A:%v[0-9]+]], -16
; CHECK-NEXT: vsrw128 [[P:%v[0-9]+]], [[A]], [[A]]
; CHECK-NEXT: vpkswss128 {{%v[0-9]+}}, [[P]], [[P]]
; CHECK: mfvscr
; ALTIVEC-LABEL: sat_vmhaddshs:
; ALTIVEC: mtvscr
; ALTIVEC: vmhaddshs
; ALTIVEC: mfvscr
define void @sat_vmhaddshs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <8 x i16> @llvm.ppc.altivec.vmhaddshs(<8 x i16> <i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768>, <8 x i16> <i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768>, <8 x i16> <i16 32767, i16 32767, i16 32767, i16 32767, i16 32767, i16 32767, i16 32767, i16 32767>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <8 x i16> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: nosat_vmhaddshs:
; CHECK: vspltisw128 [[Z:%v[0-9]+]], 0
; CHECK: mtvscr [[Z]]
; CHECK: vpkswss128 {{%v[0-9]+}}, [[Z]], [[Z]]
; CHECK: mfvscr
; ALTIVEC-LABEL: nosat_vmhaddshs:
; ALTIVEC: mtvscr
; ALTIVEC: vmhaddshs
; ALTIVEC: mfvscr
define void @nosat_vmhaddshs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <8 x i16> @llvm.ppc.altivec.vmhaddshs(<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, <8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, <8 x i16> <i16 0, i16 0, i16 0, i16 0, i16 0, i16 0, i16 0, i16 0>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <8 x i16> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: var_vmhraddshs:
; CHECK: mtvscr
; CHECK: vpkswss128 {{%v[0-9]+}}, {{%v[0-9]+}}, {{%v[0-9]+}}
; CHECK: mfvscr
; ALTIVEC-LABEL: var_vmhraddshs:
; ALTIVEC: mtvscr
; ALTIVEC: vmhraddshs
; ALTIVEC: mfvscr
define void @var_vmhraddshs(ptr %p0, ptr %p1, ptr %p2, ptr %pr, ptr %ps) {
  %a0 = load <8 x i16>, ptr %p0
  %a1 = load <8 x i16>, ptr %p1
  %a2 = load <8 x i16>, ptr %p2
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <8 x i16> @llvm.ppc.altivec.vmhraddshs(<8 x i16> %a0, <8 x i16> %a1, <8 x i16> %a2)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <8 x i16> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: sat_vmhraddshs:
; CHECK: mtvscr
; CHECK: vspltisw128 [[A:%v[0-9]+]], -16
; CHECK-NEXT: vsrw128 [[P:%v[0-9]+]], [[A]], [[A]]
; CHECK-NEXT: vpkswss128 {{%v[0-9]+}}, [[P]], [[P]]
; CHECK: mfvscr
; ALTIVEC-LABEL: sat_vmhraddshs:
; ALTIVEC: mtvscr
; ALTIVEC: vmhraddshs
; ALTIVEC: mfvscr
define void @sat_vmhraddshs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <8 x i16> @llvm.ppc.altivec.vmhraddshs(<8 x i16> <i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768>, <8 x i16> <i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768, i16 -32768>, <8 x i16> <i16 32767, i16 32767, i16 32767, i16 32767, i16 32767, i16 32767, i16 32767, i16 32767>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <8 x i16> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

; CHECK-LABEL: nosat_vmhraddshs:
; CHECK: vspltisw128 [[Z:%v[0-9]+]], 0
; CHECK: mtvscr [[Z]]
; CHECK: vpkswss128 {{%v[0-9]+}}, [[Z]], [[Z]]
; CHECK: mfvscr
; ALTIVEC-LABEL: nosat_vmhraddshs:
; ALTIVEC: mtvscr
; ALTIVEC: vmhraddshs
; ALTIVEC: mfvscr
define void @nosat_vmhraddshs(ptr %pr, ptr %ps) {
  call void @llvm.ppc.altivec.mtvscr(<4 x i32> zeroinitializer)
  %r = call <8 x i16> @llvm.ppc.altivec.vmhraddshs(<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, <8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, <8 x i16> <i16 0, i16 0, i16 0, i16 0, i16 0, i16 0, i16 0, i16 0>)
  %s = call <8 x i16> @llvm.ppc.altivec.mfvscr()
  store <8 x i16> %r, ptr %pr
  store <8 x i16> %s, ptr %ps
  ret void
}

declare void @llvm.ppc.altivec.mtvscr(<4 x i32>)
declare <8 x i16> @llvm.ppc.altivec.mfvscr()
declare <4 x i32> @llvm.ppc.altivec.vmsumuhs(<8 x i16>, <8 x i16>, <4 x i32>)
declare <4 x i32> @llvm.ppc.altivec.vmsumshs(<8 x i16>, <8 x i16>, <4 x i32>)
declare <4 x i32> @llvm.ppc.altivec.vsum4ubs(<16 x i8>, <4 x i32>)
declare <4 x i32> @llvm.ppc.altivec.vsum4sbs(<16 x i8>, <4 x i32>)
declare <4 x i32> @llvm.ppc.altivec.vsum4shs(<8 x i16>, <4 x i32>)
declare <4 x i32> @llvm.ppc.altivec.vsum2sws(<4 x i32>, <4 x i32>)
declare <4 x i32> @llvm.ppc.altivec.vsumsws(<4 x i32>, <4 x i32>)
declare <8 x i16> @llvm.ppc.altivec.vmhaddshs(<8 x i16>, <8 x i16>, <8 x i16>)
declare <8 x i16> @llvm.ppc.altivec.vmhraddshs(<8 x i16>, <8 x i16>, <8 x i16>)
