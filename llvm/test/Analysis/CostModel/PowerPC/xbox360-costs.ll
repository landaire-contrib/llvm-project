; RUN: opt -passes='print<cost-model>' -disable-output -mtriple=powerpc64-unknown-xbox360-ilp32 -mcpu=ppc64 -mattr=+altivec,+vmx128 -cost-kind=throughput < %s 2>&1 | FileCheck %s --check-prefixes=XBOX-RT,XBOX
; RUN: opt -passes='print<cost-model>' -disable-output -mtriple=powerpc64-unknown-xbox360-ilp32 -mcpu=ppc64 -mattr=+altivec,+vmx128 -cost-kind=code-size < %s 2>&1 | FileCheck %s --check-prefixes=XBOX-SIZE,XBOX
; RUN: opt -passes='print<cost-model>' -disable-output -mtriple=powerpc64-unknown-linux-gnu -mcpu=ppc64 -mattr=+altivec,+vmx128 -cost-kind=throughput < %s 2>&1 | FileCheck %s --check-prefix=PPC-RT
; RUN: opt -passes='print<cost-model>' -disable-output -mtriple=powerpc64-unknown-linux-gnu -mcpu=ppc64 -mattr=+altivec,+vmx128 -cost-kind=code-size < %s 2>&1 | FileCheck %s --check-prefix=PPC-SIZE
;
; Generic memory accesses cannot assume cached memory. Xbox full unaligned
; loads use two aligned loads and a permutation; stores use scalar stores
; plus extracts. Aligned native memory operations remain one instruction.
; Keep throughput and text-size costs separate, including legalized chunks.
; The Linux runs deliberately retain +vmx128: the policy is Xbox-specific,
; not a global change to Altivec/VMX128 cost modeling.
; Consumer-level profitability is covered by LoopVectorize/PowerPC/
; xbox360-size-cost.ll without forcing or disabling vectorization.

; XBOX-LABEL: 'bytes'
define void @bytes(ptr %p, <16 x i8> %value) {
  ; XBOX-RT: cost of 1 for instruction: %load.a16 = load <16 x i8>, ptr %p, align 16
  ; XBOX-SIZE: cost of 1 for instruction: %load.a16 = load <16 x i8>, ptr %p, align 16
  %load.a16 = load <16 x i8>, ptr %p, align 16
  ; XBOX-RT: cost of 1 for instruction: store <16 x i8> %value, ptr %p, align 16
  ; XBOX-SIZE: cost of 1 for instruction: store <16 x i8> %value, ptr %p, align 16
  store <16 x i8> %value, ptr %p, align 16

  ; XBOX-RT: cost of 4 for instruction: %load.a1 = load <16 x i8>, ptr %p, align 1
  ; XBOX-SIZE: cost of 5 for instruction: %load.a1 = load <16 x i8>, ptr %p, align 1
  %load.a1 = load <16 x i8>, ptr %p, align 1
  ; XBOX-RT: cost of 18 for instruction: store <16 x i8> %value, ptr %p, align 1
  ; XBOX-SIZE: cost of 33 for instruction: store <16 x i8> %value, ptr %p, align 1
  store <16 x i8> %value, ptr %p, align 1

  ret void
}

; XBOX-LABEL: 'halfwords'
define void @halfwords(ptr %p, <8 x i16> %value) {
  ; XBOX-RT: cost of 1 for instruction: %load.a16 = load <8 x i16>, ptr %p, align 16
  ; XBOX-SIZE: cost of 1 for instruction: %load.a16 = load <8 x i16>, ptr %p, align 16
  %load.a16 = load <8 x i16>, ptr %p, align 16
  ; XBOX-RT: cost of 1 for instruction: store <8 x i16> %value, ptr %p, align 16
  ; XBOX-SIZE: cost of 1 for instruction: store <8 x i16> %value, ptr %p, align 16
  store <8 x i16> %value, ptr %p, align 16

  ; XBOX-RT: cost of 4 for instruction: %load.a1 = load <8 x i16>, ptr %p, align 1
  ; XBOX-SIZE: cost of 5 for instruction: %load.a1 = load <8 x i16>, ptr %p, align 1
  %load.a1 = load <8 x i16>, ptr %p, align 1
  ; XBOX-RT: cost of 18 for instruction: store <8 x i16> %value, ptr %p, align 1
  ; XBOX-SIZE: cost of 33 for instruction: store <8 x i16> %value, ptr %p, align 1
  store <8 x i16> %value, ptr %p, align 1

  ; XBOX-RT: cost of 4 for instruction: %load.a2 = load <8 x i16>, ptr %p, align 2
  ; XBOX-SIZE: cost of 5 for instruction: %load.a2 = load <8 x i16>, ptr %p, align 2
  %load.a2 = load <8 x i16>, ptr %p, align 2
  ; XBOX-RT: cost of 10 for instruction: store <8 x i16> %value, ptr %p, align 2
  ; XBOX-SIZE: cost of 17 for instruction: store <8 x i16> %value, ptr %p, align 2
  store <8 x i16> %value, ptr %p, align 2

  ; XBOX-RT: cost of 4 for instruction: %load.a4 = load <8 x i16>, ptr %p, align 4
  ; XBOX-SIZE: cost of 5 for instruction: %load.a4 = load <8 x i16>, ptr %p, align 4
  %load.a4 = load <8 x i16>, ptr %p, align 4
  ; XBOX-RT: cost of 6 for instruction: store <8 x i16> %value, ptr %p, align 4
  ; XBOX-SIZE: cost of 9 for instruction: store <8 x i16> %value, ptr %p, align 4
  store <8 x i16> %value, ptr %p, align 4

  ; XBOX-RT: cost of 4 for instruction: %load.a8 = load <8 x i16>, ptr %p, align 8
  ; XBOX-SIZE: cost of 5 for instruction: %load.a8 = load <8 x i16>, ptr %p, align 8
  %load.a8 = load <8 x i16>, ptr %p, align 8
  ; XBOX-RT: cost of 6 for instruction: store <8 x i16> %value, ptr %p, align 8
  ; XBOX-SIZE: cost of 9 for instruction: store <8 x i16> %value, ptr %p, align 8
  store <8 x i16> %value, ptr %p, align 8

  ret void
}

; XBOX-LABEL: 'words'
; PPC-RT-LABEL: 'words'
; PPC-SIZE-LABEL: 'words'
define void @words(ptr %p, <4 x i32> %value) {
  ; XBOX-RT: cost of 1 for instruction: %load.a16 = load <4 x i32>, ptr %p, align 16
  ; XBOX-SIZE: cost of 1 for instruction: %load.a16 = load <4 x i32>, ptr %p, align 16
  ; PPC-RT: cost of 1 for instruction: %load.a16 = load <4 x i32>, ptr %p, align 16
  ; PPC-SIZE: cost of 1 for instruction: %load.a16 = load <4 x i32>, ptr %p, align 16
  %load.a16 = load <4 x i32>, ptr %p, align 16
  ; XBOX-RT: cost of 1 for instruction: store <4 x i32> %value, ptr %p, align 16
  ; XBOX-SIZE: cost of 1 for instruction: store <4 x i32> %value, ptr %p, align 16
  ; PPC-RT: cost of 1 for instruction: store <4 x i32> %value, ptr %p, align 16
  ; PPC-SIZE: cost of 1 for instruction: store <4 x i32> %value, ptr %p, align 16
  store <4 x i32> %value, ptr %p, align 16

  ; XBOX-RT: cost of 4 for instruction: %load.a4 = load <4 x i32>, ptr %p, align 4
  ; XBOX-SIZE: cost of 5 for instruction: %load.a4 = load <4 x i32>, ptr %p, align 4
  ; PPC-RT: cost of 2 for instruction: %load.a4 = load <4 x i32>, ptr %p, align 4
  ; PPC-SIZE: cost of 1 for instruction: %load.a4 = load <4 x i32>, ptr %p, align 4
  %load.a4 = load <4 x i32>, ptr %p, align 4
  ; XBOX-RT: cost of 6 for instruction: store <4 x i32> %value, ptr %p, align 4
  ; XBOX-SIZE: cost of 9 for instruction: store <4 x i32> %value, ptr %p, align 4
  ; PPC-RT: cost of 16 for instruction: store <4 x i32> %value, ptr %p, align 4
  ; PPC-SIZE: cost of 1 for instruction: store <4 x i32> %value, ptr %p, align 4
  store <4 x i32> %value, ptr %p, align 4

  ret void
}

; XBOX-LABEL: 'floats'
define void @floats(ptr %p, <4 x float> %value) {
  ; XBOX-RT: cost of 1 for instruction: %load.a16 = load <4 x float>, ptr %p, align 16
  ; XBOX-SIZE: cost of 1 for instruction: %load.a16 = load <4 x float>, ptr %p, align 16
  %load.a16 = load <4 x float>, ptr %p, align 16
  ; XBOX-RT: cost of 1 for instruction: store <4 x float> %value, ptr %p, align 16
  ; XBOX-SIZE: cost of 1 for instruction: store <4 x float> %value, ptr %p, align 16
  store <4 x float> %value, ptr %p, align 16

  ; XBOX-RT: cost of 4 for instruction: %load.a8 = load <4 x float>, ptr %p, align 8
  ; XBOX-SIZE: cost of 5 for instruction: %load.a8 = load <4 x float>, ptr %p, align 8
  %load.a8 = load <4 x float>, ptr %p, align 8
  ; XBOX-RT: cost of 6 for instruction: store <4 x float> %value, ptr %p, align 8
  ; XBOX-SIZE: cost of 9 for instruction: store <4 x float> %value, ptr %p, align 8
  store <4 x float> %value, ptr %p, align 8

  ret void
}

; XBOX-LABEL: 'split_halfwords'
define void @split_halfwords(ptr %p, <16 x i16> %value) {
  ; XBOX-RT: cost of 2 for instruction: %load.a16 = load <16 x i16>, ptr %p, align 16
  ; XBOX-SIZE: cost of 2 for instruction: %load.a16 = load <16 x i16>, ptr %p, align 16
  %load.a16 = load <16 x i16>, ptr %p, align 16
  ; XBOX-RT: cost of 2 for instruction: store <16 x i16> %value, ptr %p, align 16
  ; XBOX-SIZE: cost of 2 for instruction: store <16 x i16> %value, ptr %p, align 16
  store <16 x i16> %value, ptr %p, align 16

  ; XBOX-RT: cost of 8 for instruction: %load.a2 = load <16 x i16>, ptr %p, align 2
  ; XBOX-SIZE: cost of 10 for instruction: %load.a2 = load <16 x i16>, ptr %p, align 2
  %load.a2 = load <16 x i16>, ptr %p, align 2
  ; XBOX-RT: cost of 20 for instruction: store <16 x i16> %value, ptr %p, align 2
  ; XBOX-SIZE: cost of 34 for instruction: store <16 x i16> %value, ptr %p, align 2
  store <16 x i16> %value, ptr %p, align 2

  ret void
}

; Scalar conversions include GPR/FPR bank transfers. Native vector conversions
; stay in the vector bank. Do not charge vector element transfer penalties to
; either kind of cast. The result is returned so FP-to-int cannot fold into a
; destination store in these functions.

; XBOX-LABEL: 'signed_to_float'
; PPC-RT-LABEL: 'signed_to_float'
; PPC-SIZE-LABEL: 'signed_to_float'
define float @signed_to_float(i32 %value) {
  ; XBOX: cost of 5 for instruction: %converted = sitofp i32 %value to float
  ; PPC-RT: cost of 1 for instruction: %converted = sitofp i32 %value to float
  ; PPC-SIZE: cost of 1 for instruction: %converted = sitofp i32 %value to float
  %converted = sitofp i32 %value to float
  ret float %converted
}

; XBOX-LABEL: 'signed_to_double'
; PPC-RT-LABEL: 'signed_to_double'
; PPC-SIZE-LABEL: 'signed_to_double'
define double @signed_to_double(i32 %value) {
  ; XBOX: cost of 4 for instruction: %converted = sitofp i32 %value to double
  ; PPC-RT: cost of 1 for instruction: %converted = sitofp i32 %value to double
  ; PPC-SIZE: cost of 1 for instruction: %converted = sitofp i32 %value to double
  %converted = sitofp i32 %value to double
  ret double %converted
}

; XBOX-LABEL: 'unsigned_to_float'
; PPC-RT-LABEL: 'unsigned_to_float'
; PPC-SIZE-LABEL: 'unsigned_to_float'
define float @unsigned_to_float(i32 %value) {
  ; XBOX: cost of 8 for instruction: %converted = uitofp i32 %value to float
  ; PPC-RT: cost of 1 for instruction: %converted = uitofp i32 %value to float
  ; PPC-SIZE: cost of 1 for instruction: %converted = uitofp i32 %value to float
  %converted = uitofp i32 %value to float
  ret float %converted
}

; XBOX-LABEL: 'unsigned_to_double'
; PPC-RT-LABEL: 'unsigned_to_double'
; PPC-SIZE-LABEL: 'unsigned_to_double'
define double @unsigned_to_double(i32 %value) {
  ; XBOX: cost of 7 for instruction: %converted = uitofp i32 %value to double
  ; PPC-RT: cost of 1 for instruction: %converted = uitofp i32 %value to double
  ; PPC-SIZE: cost of 1 for instruction: %converted = uitofp i32 %value to double
  %converted = uitofp i32 %value to double
  ret double %converted
}

; XBOX-LABEL: 'float_to_signed'
; PPC-RT-LABEL: 'float_to_signed'
; PPC-SIZE-LABEL: 'float_to_signed'
define i32 @float_to_signed(float %value) {
  ; XBOX: cost of 3 for instruction: %converted = fptosi float %value to i32
  ; PPC-RT: cost of 1 for instruction: %converted = fptosi float %value to i32
  ; PPC-SIZE: cost of 1 for instruction: %converted = fptosi float %value to i32
  %converted = fptosi float %value to i32
  ret i32 %converted
}

; XBOX-LABEL: 'double_to_signed'
; PPC-RT-LABEL: 'double_to_signed'
; PPC-SIZE-LABEL: 'double_to_signed'
define i32 @double_to_signed(double %value) {
  ; XBOX: cost of 3 for instruction: %converted = fptosi double %value to i32
  ; PPC-RT: cost of 1 for instruction: %converted = fptosi double %value to i32
  ; PPC-SIZE: cost of 1 for instruction: %converted = fptosi double %value to i32
  %converted = fptosi double %value to i32
  ret i32 %converted
}

; XBOX-LABEL: 'float_to_unsigned'
; PPC-RT-LABEL: 'float_to_unsigned'
; PPC-SIZE-LABEL: 'float_to_unsigned'
define i32 @float_to_unsigned(float %value) {
  ; XBOX: cost of 3 for instruction: %converted = fptoui float %value to i32
  ; PPC-RT: cost of 1 for instruction: %converted = fptoui float %value to i32
  ; PPC-SIZE: cost of 1 for instruction: %converted = fptoui float %value to i32
  %converted = fptoui float %value to i32
  ret i32 %converted
}

; XBOX-LABEL: 'double_to_unsigned'
; PPC-RT-LABEL: 'double_to_unsigned'
; PPC-SIZE-LABEL: 'double_to_unsigned'
define i32 @double_to_unsigned(double %value) {
  ; XBOX: cost of 3 for instruction: %converted = fptoui double %value to i32
  ; PPC-RT: cost of 1 for instruction: %converted = fptoui double %value to i32
  ; PPC-SIZE: cost of 1 for instruction: %converted = fptoui double %value to i32
  %converted = fptoui double %value to i32
  ret i32 %converted
}

; XBOX-LABEL: 'v4_signed_to_float'
; PPC-RT-LABEL: 'v4_signed_to_float'
; PPC-SIZE-LABEL: 'v4_signed_to_float'
define <4 x float> @v4_signed_to_float(<4 x i32> %value) {
  ; XBOX: cost of 1 for instruction: %converted = sitofp <4 x i32> %value to <4 x float>
  ; PPC-RT: cost of 1 for instruction: %converted = sitofp <4 x i32> %value to <4 x float>
  ; PPC-SIZE: cost of 1 for instruction: %converted = sitofp <4 x i32> %value to <4 x float>
  %converted = sitofp <4 x i32> %value to <4 x float>
  ret <4 x float> %converted
}

; XBOX-LABEL: 'v4_unsigned_to_float'
; PPC-RT-LABEL: 'v4_unsigned_to_float'
; PPC-SIZE-LABEL: 'v4_unsigned_to_float'
define <4 x float> @v4_unsigned_to_float(<4 x i32> %value) {
  ; XBOX: cost of 1 for instruction: %converted = uitofp <4 x i32> %value to <4 x float>
  ; PPC-RT: cost of 1 for instruction: %converted = uitofp <4 x i32> %value to <4 x float>
  ; PPC-SIZE: cost of 1 for instruction: %converted = uitofp <4 x i32> %value to <4 x float>
  %converted = uitofp <4 x i32> %value to <4 x float>
  ret <4 x float> %converted
}

; XBOX-LABEL: 'v4_float_to_signed'
; PPC-RT-LABEL: 'v4_float_to_signed'
; PPC-SIZE-LABEL: 'v4_float_to_signed'
define <4 x i32> @v4_float_to_signed(<4 x float> %value) {
  ; XBOX: cost of 1 for instruction: %converted = fptosi <4 x float> %value to <4 x i32>
  ; PPC-RT: cost of 1 for instruction: %converted = fptosi <4 x float> %value to <4 x i32>
  ; PPC-SIZE: cost of 1 for instruction: %converted = fptosi <4 x float> %value to <4 x i32>
  %converted = fptosi <4 x float> %value to <4 x i32>
  ret <4 x i32> %converted
}

; XBOX-LABEL: 'v4_float_to_unsigned'
; PPC-RT-LABEL: 'v4_float_to_unsigned'
; PPC-SIZE-LABEL: 'v4_float_to_unsigned'
define <4 x i32> @v4_float_to_unsigned(<4 x float> %value) {
  ; XBOX: cost of 1 for instruction: %converted = fptoui <4 x float> %value to <4 x i32>
  ; PPC-RT: cost of 1 for instruction: %converted = fptoui <4 x float> %value to <4 x i32>
  ; PPC-SIZE: cost of 1 for instruction: %converted = fptoui <4 x float> %value to <4 x i32>
  %converted = fptoui <4 x float> %value to <4 x i32>
  ret <4 x i32> %converted
}

; XBOX-LABEL: 'v8_signed_to_float'
define <8 x float> @v8_signed_to_float(<8 x i32> %value) {
  ; XBOX: cost of 2 for instruction: %converted = sitofp <8 x i32> %value to <8 x float>
  %converted = sitofp <8 x i32> %value to <8 x float>
  ret <8 x float> %converted
}

; XBOX-LABEL: 'v8_unsigned_to_float'
define <8 x float> @v8_unsigned_to_float(<8 x i32> %value) {
  ; XBOX: cost of 2 for instruction: %converted = uitofp <8 x i32> %value to <8 x float>
  %converted = uitofp <8 x i32> %value to <8 x float>
  ret <8 x float> %converted
}

; XBOX-LABEL: 'v8_float_to_signed'
define <8 x i32> @v8_float_to_signed(<8 x float> %value) {
  ; XBOX: cost of 2 for instruction: %converted = fptosi <8 x float> %value to <8 x i32>
  %converted = fptosi <8 x float> %value to <8 x i32>
  ret <8 x i32> %converted
}

; XBOX-LABEL: 'v8_float_to_unsigned'
define <8 x i32> @v8_float_to_unsigned(<8 x float> %value) {
  ; XBOX: cost of 2 for instruction: %converted = fptoui <8 x float> %value to <8 x i32>
  %converted = fptoui <8 x float> %value to <8 x i32>
  ret <8 x i32> %converted
}

; A signed conversion whose only user is an aligned integer store can keep
; the result in the FPR bank and use STFIWX. The store has its own memory cost.
; Neither an insufficiently aligned store nor a second use permits that fold.

; XBOX-LABEL: 'signed_store'
define void @signed_store(float %value, ptr %out) {
  ; XBOX: cost of 1 for instruction: %converted = fptosi float %value to i32
  %converted = fptosi float %value to i32
  store i32 %converted, ptr %out, align 4
  ret void
}

; XBOX-LABEL: 'signed_unaligned_store'
define void @signed_unaligned_store(float %value, ptr %out) {
  ; XBOX: cost of 3 for instruction: %converted = fptosi float %value to i32
  %converted = fptosi float %value to i32
  store i32 %converted, ptr %out, align 2
  ret void
}

; XBOX-LABEL: 'signed_store_and_return'
define i32 @signed_store_and_return(float %value, ptr %out) {
  ; XBOX: cost of 3 for instruction: %converted = fptosi float %value to i32
  %converted = fptosi float %value to i32
  store i32 %converted, ptr %out, align 4
  ret i32 %converted
}

