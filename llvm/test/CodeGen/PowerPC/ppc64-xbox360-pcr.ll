; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -tailcallopt -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -tailcallopt -mattr=-vmx128 -verify-machineinstrs < %s | FileCheck %s
; RUN: opt -passes='default<O2>' -S %s | FileCheck %s --check-prefix=IR
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -tailcallopt -stop-after=finalize-isel < %s | FileCheck %s --check-prefix=MIR
; RUN: llc -mtriple=powerpc64-unknown-linux-gnu -tailcallopt -stop-after=finalize-isel < %s | FileCheck %s --check-prefix=BASE-MIR
; RUN: llc -mtriple=powerpc-unknown-linux-gnu -tailcallopt -stop-after=finalize-isel < %s | FileCheck %s --check-prefix=BASE-MIR

; The Xbox fastcc tail case requires guaranteed tail-call optimization.

; BASE-MIR-NOT: implicit-def $x13

; r13 is reserved, but not call-preserved: migration may replace the PCR.
; read_volatile_register keeps each evaluation on the DAG chain. Coalescing
; may use r13 directly only while its captured value does not cross a call.
target triple = "powerpc64-unknown-xbox360-ilp32"

declare i32 @llvm.read_volatile_register.i32(metadata)
declare void @migrate()

; CHECK-LABEL: load_byte:
; CHECK-NOT: mr
; CHECK: lbz 3, 268(13)
; CHECK-NEXT: blr
define i8 @load_byte() {
  %pcr = call i32 @llvm.read_volatile_register.i32(metadata !0)
  %base = inttoptr i32 %pcr to ptr
  %address = getelementptr i8, ptr %base, i32 268
  %number = load i8, ptr %address
  ret i8 %number
}

; A fresh read following a call uses the new r13, not the captured old value.
; CHECK-LABEL: fresh_after_call:
; CHECK: lbz {{[0-9]+}}, 268(13)
; CHECK: bl migrate
; CHECK: lbz {{[0-9]+}}, 268(13)
; MIR-LABEL: name: fresh_after_call
; MIR: BL @migrate, {{.*}}implicit-def $x13
; IR-LABEL: define i8 @fresh_after_call(
; IR: call i32 @llvm.read_volatile_register.i32(metadata !0)
; IR: call void @migrate()
; IR: call i32 @llvm.read_volatile_register.i32(metadata !0)
define i8 @fresh_after_call() {
  %old = call i32 @llvm.read_volatile_register.i32(metadata !0)
  %oldbase = inttoptr i32 %old to ptr
  %oldaddress = getelementptr i8, ptr %oldbase, i32 268
  %before = load volatile i8, ptr %oldaddress
  call void @migrate()
  %new = call i32 @llvm.read_volatile_register.i32(metadata !0)
  %newbase = inttoptr i32 %new to ptr
  %newaddress = getelementptr i8, ptr %newbase, i32 268
  %after = load volatile i8, ptr %newaddress
  %result = xor i8 %before, %after
  ret i8 %result
}

; A pointer captured before migration must still address the old PCR.
; The copy cannot coalesce with the reserved register across a call's
; explicit PCR definition, even though r13 remains unallocatable.
; CHECK-LABEL: captured_before_call:
; CHECK: mr [[SAVED:(1[4-9]|2[0-9]|3[01])]], 13
; CHECK: bl migrate
; CHECK: lbz 3, 268([[SAVED]])
define i8 @captured_before_call() {
  %pcr = call i32 @llvm.read_volatile_register.i32(metadata !0)
  call void @migrate()
  %base = inttoptr i32 %pcr to ptr
  %address = getelementptr i8, ptr %base, i32 268
  %number = load i8, ptr %address
  ret i8 %number
}

; Indirect calls have the same migration contract as direct calls.
; CHECK-LABEL: captured_before_indirect_call:
; CHECK: mr [[INDIRECT_SAVED:(1[4-9]|2[0-9]|3[01])]], 13
; CHECK: bctrl
; CHECK: lbz 3, 268([[INDIRECT_SAVED]])
; MIR-LABEL: name: captured_before_indirect_call
; MIR: BCTRL8 {{.*}}implicit-def $x13
define i8 @captured_before_indirect_call(ptr %callee) {
  %pcr = call i32 @llvm.read_volatile_register.i32(metadata !0)
  call void %callee()
  %base = inttoptr i32 %pcr to ptr
  %address = getelementptr i8, ptr %base, i32 268
  %number = load i8, ptr %address
  ret i8 %number
}

; Tail-call argument evaluation reads the PCR before the call's definition.
; Tail-call pseudos are calls too, regardless of their later branch expansion.
; CHECK-LABEL: tail_pcr:
; CHECK: mr 3, 13
; CHECK: b consume_pcr
; MIR-LABEL: name: tail_pcr
; MIR: TCRETURN{{.*}}implicit-def $x13
declare fastcc i32 @consume_pcr(i32)
define fastcc i32 @tail_pcr(i32 %unused) {
  %pcr = call i32 @llvm.read_volatile_register.i32(metadata !0)
  %result = tail call fastcc i32 @consume_pcr(i32 %pcr)
  ret i32 %result
}

; These are IR-side-effect checks, not physical sampling guarantees. Without
; processor affinity, asynchronous migration may occur between instructions.
; IR-LABEL: define i32 @two_reads(
; IR: [[FIRST:%.*]] = {{.*}}call i32 @llvm.read_volatile_register.i32(metadata !0)
; IR: [[SECOND:%.*]] = {{.*}}call i32 @llvm.read_volatile_register.i32(metadata !0)
; IR: xor i32
define i32 @two_reads() {
  %first = call i32 @llvm.read_volatile_register.i32(metadata !0)
  %second = call i32 @llvm.read_volatile_register.i32(metadata !0)
  %result = xor i32 %first, %second
  ret i32 %result
}

; IR-LABEL: define void @unused_read(
; IR: call i32 @llvm.read_volatile_register.i32(metadata !0)
; IR: ret void
define void @unused_read() {
  %unused = call i32 @llvm.read_volatile_register.i32(metadata !0)
  ret void
}

!0 = !{!"r13"}
