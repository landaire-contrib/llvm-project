; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -O2 -verify-machineinstrs < %s | FileCheck %s --check-prefix=XBOX
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-linux-gnu -O2 -verify-machineinstrs < %s | FileCheck %s --check-prefix=LINUX
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -O0 -verify-machineinstrs < %s | FileCheck %s --check-prefix=UCMP
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=-crbits -O2 -verify-machineinstrs < %s | FileCheck %s --check-prefix=UCMP

; XBOX-LABEL: add128:
; XBOX-NOT: addc
; XBOX-NOT: adde
; XBOX: cmpld
; XBOX-NOT: addc
; XBOX-NOT: adde
; XBOX: blr
; LINUX-LABEL: add128:
; LINUX: addc
; LINUX: adde
; LINUX: blr

define i128 @add128(i128 %a, i128 %b) {
  %r = add i128 %a, %b
  ret i128 %r
}

; XBOX-LABEL: sub128:
; XBOX-NOT: subc
; XBOX-NOT: subfe
; XBOX: cmpld
; XBOX-NOT: subc
; XBOX-NOT: subfe
; XBOX: blr
; LINUX-LABEL: sub128:
; LINUX: subc
; LINUX: subfe
; LINUX: blr

define i128 @sub128(i128 %a, i128 %b) {
  %r = sub i128 %a, %b
  ret i128 %r
}

; XBOX-LABEL: uaddo:
; XBOX-NOT: addc
; XBOX-NOT: adde
; XBOX: cmpld
; XBOX-NOT: addc
; XBOX-NOT: adde
; XBOX: blr

define i64 @uaddo(i64 %a, i64 %b, ptr %overflow) {
  %pair = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %a, i64 %b)
  %value = extractvalue { i64, i1 } %pair, 0
  %flag = extractvalue { i64, i1 } %pair, 1
  store i1 %flag, ptr %overflow
  ret i64 %value
}

; XBOX-LABEL: usubo:
; XBOX-NOT: subc
; XBOX-NOT: subfe
; XBOX: cmpld
; XBOX-NOT: subc
; XBOX-NOT: subfe
; XBOX: blr

define i64 @usubo(i64 %a, i64 %b, ptr %overflow) {
  %pair = call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %a, i64 %b)
  %value = extractvalue { i64, i1 } %pair, 0
  %flag = extractvalue { i64, i1 } %pair, 1
  store i1 %flag, ptr %overflow
  ret i64 %value
}

; XBOX-LABEL: eq64:
; XBOX-NOT: addic
; XBOX-NOT: subfe
; XBOX: cmpd
; XBOX-NOT: addic
; XBOX-NOT: subfe
; XBOX: blr

define i64 @eq64(i64 %a, i64 %b) {
  %cmp = icmp eq i64 %a, %b
  %value = zext i1 %cmp to i64
  ret i64 %value
}

; XBOX-LABEL: ult64:
; XBOX-NOT: subc
; XBOX-NOT: subfe
; XBOX: cmpld
; XBOX-NOT: subc
; XBOX-NOT: subfe
; XBOX: blr

define i64 @ult64(i64 %a, i64 %b) {
  %cmp = icmp ult i64 %a, %b
  %value = zext i1 %cmp to i64
  ret i64 %value
}

; XBOX-LABEL: branch_mask:
; XBOX: rldicl
; XBOX-NOT: rldicl.
; XBOX: cmpldi
; XBOX: blr

define i64 @branch_mask(i64 %value, ptr %p) {
  %masked = and i64 %value, 1095216660480
  %cmp = icmp eq i64 %masked, 0
  br i1 %cmp, label %yes, label %no

yes:
  store volatile i64 11, ptr %p
  ret i64 1

no:
  store volatile i64 22, ptr %p
  ret i64 2
}

; XBOX-LABEL: loop64:
; XBOX-NOT: mtctr
; XBOX-NOT: bdnz
; XBOX: cmpldi
; XBOX-NOT: mtctr
; XBOX-NOT: bdnz
; XBOX: blr
; LINUX-LABEL: loop64:
; LINUX: mtctr
; LINUX: bdnz
; LINUX: blr

define i64 @loop64(ptr %p, i64 %count) {
entry:
  br label %loop

loop:
  %index = phi i64 [ 0, %entry ], [ %next, %loop ]
  %sum = phi i64 [ 0, %entry ], [ %sum.next, %loop ]
  %element = getelementptr i64, ptr %p, i64 %index
  %value = load volatile i64, ptr %element, align 8
  %product = mul i64 %value, 17
  %sum.next = add i64 %sum, %product
  %next = add i64 %index, 1
  %done = icmp eq i64 %next, %count
  br i1 %done, label %exit, label %loop

exit:
  ret i64 %sum.next
}

; XBOX-LABEL: explicit_loop64:
; XBOX-NOT: mtctr
; XBOX-NOT: bdnz
; XBOX: cmpldi
; XBOX-NOT: bdnz
; XBOX: blr

define void @explicit_loop64(ptr %p, i64 %count) {
entry:
  call void @llvm.set.loop.iterations.i64(i64 %count)
  br label %loop

loop:
  store volatile i64 1, ptr %p
  %more = call i1 @llvm.loop.decrement.i64(i64 1)
  br i1 %more, label %loop, label %exit

exit:
  ret void
}

; XBOX-LABEL: ucmp64:
; XBOX: cmpld
; XBOX-NOT: subc
; XBOX-NOT: subfe
; XBOX: blr
; UCMP-LABEL: ucmp64:
; UCMP: cmpld
; UCMP-NOT: subc
; UCMP-NOT: subfe
; UCMP: blr

define i64 @ucmp64(i64 %a, i64 %b) {
  %result = call i64 @llvm.ucmp.i64.i64(i64 %a, i64 %b)
  ret i64 %result
}
