; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s --check-prefixes=CHECK,STATIC
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -tailcallopt \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,STATIC
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -ppc-sco=false \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=NOSCO
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -relocation-model=pic \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,PIC
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc-unknown-linux-gnu -verify-machineinstrs < %s \
; RUN:   | FileCheck %s --check-prefix=PPC32

; Xbox ordinary C siblings retain the incoming stack pointer and use the
; caller-provided linkage (16 bytes) and parameter area (at least 64 bytes).
; They do not require -tailcallopt or alter the guaranteed fastcc convention.

declare hidden void @local_sink(ptr)
declare void @external_sink(ptr)
declare hidden i64 @one_i64(i64)
declare hidden i64 @wide_sink(ptr, i64)
declare hidden double @float_sink(double, double, double, double, double, double, double, double)
declare hidden <4 x i32> @vector_sink(<4 x i32>)

; The shared return block needs tail-position return duplication. Neither a
; link-register spill nor a 96-byte call frame is necessary.
; CHECK-LABEL: conditional_tail:
; CHECK-NOT:   mflr
; CHECK-NOT:   stwu
; CHECK:       andi.
; CHECK-NOT:   mflr
; CHECK-NOT:   stwu
; CHECK:       b local_sink
; NOSCO-LABEL: conditional_tail:
; NOSCO:       bl local_sink
; PPC32-LABEL: conditional_tail:
; PPC32:       bl local_sink
define void @conditional_tail(i32 %type, ptr %device) {
entry:
  %mask = and i32 %type, 2
  %condition = icmp ne i32 %mask, 0
  br i1 %condition, label %call, label %return
call:
  tail call void @local_sink(ptr %device)
  br label %return
return:
  ret void
}

; The reduced kernel example calls a non-local declaration. Static calls can
; branch directly, but interposable PIC calls must retain ordinary PLT calls.
; STATIC-LABEL: conditional_external_tail:
; STATIC-NOT:   mflr
; STATIC-NOT:   stwu
; STATIC:       b external_sink
; PIC-LABEL:    conditional_external_tail:
; PIC:          bl external_sink@PLT
define void @conditional_external_tail(i32 %type, ptr %device) {
entry:
  %mask = and i32 %type, 2
  %condition = icmp ne i32 %mask, 0
  br i1 %condition, label %call, label %return
call:
  tail call void @external_sink(ptr %device)
  br label %return
return:
  ret void
}

; Pointers remain 32-bit, but the following i64 occupies one full-width GPR.
; CHECK-LABEL: conditional_i64:
; CHECK-NOT:   mflr
; CHECK-NOT:   stwu
; CHECK:       b wide_sink
define i64 @conditional_i64(i32 %condition, ptr %pointer, i64 %value) {
entry:
  %test = icmp ne i32 %condition, 0
  br i1 %test, label %call, label %return
call:
  %result = tail call i64 @wide_sink(ptr %pointer, i64 %value)
  br label %return
return:
  %value.out = phi i64 [ %result, %call ], [ 0, %entry ]
  ret i64 %value.out
}

; More incoming parameter space must not cause a positive tail-call SP delta
; or move LR/FP. Only the ninth incoming i64 is needed in r3.
; CHECK-LABEL: incoming_stack_to_register:
; CHECK-NOT:   mflr
; CHECK-NOT:   stwu
; CHECK:       ld %r3, 80(%r1)
; CHECK-NOT:   addi %r1,
; CHECK-NOT:   stw
; CHECK:       b one_i64
define i64 @incoming_stack_to_register(i64 %a, i64 %b, i64 %c, i64 %d,
                                        i64 %e, i64 %f, i64 %g, i64 %h, i64 %i) {
  %result = tail call i64 @one_i64(i64 %i)
  ret i64 %result
}

; Eligibility uses the real FPR and vector assignments, not an integer-only
; argument-count approximation.
; CHECK-LABEL: register_floats:
; CHECK-NOT:   stwu
; CHECK:       b float_sink
define double @register_floats(double %a, double %b, double %c, double %d,
                                double %e, double %f, double %g, double %h) {
  %result = tail call double @float_sink(double %h, double %g, double %f,
                                       double %e, double %d, double %c,
                                       double %b, double %a)
  ret double %result
}

; CHECK-LABEL: register_vector:
; CHECK-NOT:   stwu
; CHECK:       b vector_sink
define <4 x i32> @register_vector(<4 x i32> %value) {
  %result = tail call <4 x i32> @vector_sink(<4 x i32> %value)
  ret <4 x i32> %result
}

declare hidden i64 @nine_i64(i64, i64, i64, i64, i64, i64, i64, i64, i64)
declare hidden double @nine_floats(double, double, double, double, double, double, double, double, double)

; Outgoing stack arguments cannot grow or overwrite the caller's area.
; CHECK-LABEL: outgoing_stack_growth:
; CHECK:       std {{%r[0-9]+}}, 80(%r1)
; CHECK:       bl nine_i64
; CHECK:       blr
define i64 @outgoing_stack_growth() {
  %result = tail call i64 @nine_i64(i64 1, i64 2, i64 3, i64 4, i64 5,
                                   i64 6, i64 7, i64 8, i64 9)
  ret i64 %result
}

; Matching total area does not make overlapping stack-argument shuffles safe.
; CHECK-LABEL: outgoing_stack_overlap:
; CHECK:       std {{%r[0-9]+}}, 80(%r1)
; CHECK:       bl nine_i64
; CHECK:       blr
define i64 @outgoing_stack_overlap(i64 %a, i64 %b, i64 %c, i64 %d, i64 %e,
                                    i64 %f, i64 %g, i64 %h, i64 %i) {
  %result = tail call i64 @nine_i64(i64 %a, i64 %b, i64 %c, i64 %d, i64 %e,
                                   i64 %f, i64 %g, i64 %i, i64 %h)
  ret i64 %result
}

; Although all nine values use FPRs, their positional backing slots exceed the
; 64-byte incoming parameter area and cannot be supplied by an ordinary tail.
; CHECK-LABEL: outgoing_float_area_growth:
; CHECK:       bl nine_floats
; CHECK:       blr
define double @outgoing_float_area_growth() {
  %result = tail call double @nine_floats(double 0.0, double 0.0, double 0.0,
                                         double 0.0, double 0.0, double 0.0,
                                         double 0.0, double 0.0, double 0.0)
  ret double %result
}

declare hidden void @byval_sink(ptr byval([16 x i8]) align 16)
declare hidden void @sret_sink(ptr sret([16 x i8]) align 16)
declare hidden void @variadic_sink(i32, ...)
declare hidden fastcc void @fast_sink(ptr)

; CHECK-LABEL: outgoing_byval:
; CHECK:       bl byval_sink
; CHECK:       blr
define void @outgoing_byval(ptr %value) {
  tail call void @byval_sink(ptr byval([16 x i8]) align 16 %value)
  ret void
}

; CHECK-LABEL: incoming_byval:
; CHECK:       bl local_sink
; CHECK:       blr
define void @incoming_byval(ptr byval([16 x i8]) align 16 %value) {
  tail call void @local_sink(ptr %value)
  ret void
}

; CHECK-LABEL: outgoing_sret:
; CHECK:       bl sret_sink
; CHECK:       blr
define void @outgoing_sret(ptr %value) {
  tail call void @sret_sink(ptr sret([16 x i8]) align 16 %value)
  ret void
}

; The caller must return its own hidden result pointer, not the callee's r3.
; CHECK-LABEL: incoming_sret:
; CHECK:       bl local_sink
; CHECK:       blr
define void @incoming_sret(ptr sret([16 x i8]) align 16 %value) {
  tail call void @local_sink(ptr %value)
  ret void
}

; CHECK-LABEL: outgoing_varargs:
; CHECK:       bl variadic_sink
; CHECK:       blr
define void @outgoing_varargs(i32 %value) {
  tail call void (i32, ...) @variadic_sink(i32 %value)
  ret void
}

; CHECK-LABEL: incoming_varargs:
; CHECK:       bl local_sink
; CHECK:       blr
define void @incoming_varargs(i32 %tag, ...) {
  tail call void @local_sink(ptr null)
  ret void
}

; C and fastcc cannot be mixed merely because the arguments fit in registers.
; CHECK-LABEL: different_callee_cc:
; CHECK:       bl fast_sink
; CHECK:       blr
define void @different_callee_cc(ptr %value) {
  tail call fastcc void @fast_sink(ptr %value)
  ret void
}

; CHECK-LABEL: different_caller_cc:
; CHECK:       bl local_sink
; CHECK:       blr
define fastcc void @different_caller_cc(ptr %value) {
  tail call void @local_sink(ptr %value)
  ret void
}

; CHECK-LABEL: indirect_tail:
; CHECK:       bctrl
; CHECK:       blr
define void @indirect_tail(ptr %callee, ptr %value) {
  tail call void %callee(ptr %value)
  ret void
}

; CHECK-LABEL: explicit_notail:
; CHECK:       bl local_sink
; CHECK:       blr
define void @explicit_notail(ptr %value) {
  notail call void @local_sink(ptr %value)
  ret void
}

; CHECK-LABEL: disabled_tail:
; CHECK:       bl local_sink
; CHECK:       blr
define void @disabled_tail(ptr %value) "disable-tail-calls"="true" {
  tail call void @local_sink(ptr %value)
  ret void
}

@global_value = external global i64

; PIC tail epilogues still restore the full-width callee-saved r30 and the
; Xbox LR word below the incoming SP before branching to a local callee.
; PIC-LABEL: pic_local_tail:
; PIC:       std %r30, -24(%r1)
; PIC:       stw %r0, -8(%r1)
; PIC:       lwz %r0, -8(%r1)
; PIC:       ld %r30, -24(%r1)
; PIC:       b one_i64
define i64 @pic_local_tail() {
  %value = load i64, ptr @global_value, align 8
  %result = tail call i64 @one_i64(i64 %value)
  ret i64 %result
}
