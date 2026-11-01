; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s

%S2 = type { [2 x i8] }
%S3 = type { [3 x i8] }
%S4 = type { [4 x i8] }
%S5 = type { [5 x i8] }
%S8 = type { i32, i32 }
%S12 = type { i32, i32, i32 }
%S16 = type { i64, i64 }
%S68 = type { [17 x i32] }

declare i32 @sink_s2(i32, ptr byval(%S2) align 1, i32)
declare i32 @sink_s3(i32, ptr byval(%S3) align 1, i32)
declare i32 @sink_s4_stack(i32, i32, i32, i32, i32, i32, i32, i32,
                          ptr byval(%S4) align 4)
declare i32 @sink_s5(i32, ptr byval(%S5) align 4, i32)
declare i32 @sink_s8(i32, ptr byval(%S8) align 4, i32)
declare i32 @sink_s12(i32, ptr byval(%S12) align 4, i32)
declare i32 @sink_s68(i32, ptr byval(%S68) align 4, i32)

; Aggregates of 1, 2 or 4 bytes are right-justified like integers.
; CHECK-LABEL: call_s2:
; CHECK:       lhz 4, 0(3)
; CHECK-NOT:   sldi
; CHECK:       bl sink_s2

define i32 @call_s2(ptr %value) {
  %result = call i32 @sink_s2(
      i32 1, ptr byval(%S2) align 1 %value, i32 2)
  ret i32 %result
}

; Other sizes up to 8 bytes are left-justified.
; CHECK-LABEL: call_s3:
; CHECK-DAG:   lhz [[HI:[0-9]+]], 0(3)
; CHECK-DAG:   lbz [[LO:[0-9]+]], 2(3)
; CHECK-DAG:   rldic 4, [[LO]], 40, 16
; CHECK:       rldimi 4, [[HI]], 48, 0
; CHECK:       bl sink_s3

define i32 @call_s3(ptr %value) {
  %result = call i32 @sink_s3(
      i32 1, ptr byval(%S3) align 1 %value, i32 2)
  ret i32 %result
}

; In memory a 4-byte aggregate occupies the low word of its slot.
; CHECK-LABEL: call_s4_stack:
; CHECK:       stw {{[0-9]+}}, 84(1)
; CHECK:       bl sink_s4_stack

define i32 @call_s4_stack(ptr %value) {
  %result = call i32 @sink_s4_stack(
      i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8,
      ptr byval(%S4) align 4 %value)
  ret i32 %result
}

; The callee finds the last byte of a 2-byte aggregate in the low byte of R4.
; CHECK-LABEL: receive_s2:
; CHECK:       extsb 3, 4

define i32 @receive_s2(i32 %tag, ptr byval(%S2) align 1 %value) {
  %p = getelementptr i8, ptr %value, i32 1
  %b = load i8, ptr %p, align 1
  %r = sext i8 %b to i32
  ret i32 %r
}

; In memory the aggregate occupies the low word of its slot.
; CHECK-LABEL: receive_s4_stack:
; CHECK:       lbz {{[0-9]+}}, 87(1)

define i32 @receive_s4_stack(i32, i32, i32, i32, i32, i32, i32, i32,
                             ptr byval(%S4) align 4 %value) {
  %p = getelementptr i8, ptr %value, i32 3
  %b = load i8, ptr %p, align 1
  %r = sext i8 %b to i32
  ret i32 %r
}

; Aggregate residue is left-justified in its 64-bit argument register.
; CHECK-LABEL: call_s5:
; CHECK-DAG:   lwz {{[0-9]+}}, 0(3)
; CHECK-DAG:   lbz {{[0-9]+}}, 4(3)
; CHECK:       bl sink_s5

define i32 @call_s5(ptr %value) {
  %result = call i32 @sink_s5(
      i32 1, ptr byval(%S5) align 4 %value, i32 2)
  ret i32 %result
}

; An 8-byte aggregate consumes one full-width GPR.
; CHECK-LABEL: call_s8:
; CHECK:       ld 4, 0(3)
; CHECK-DAG:   li 3, 1
; CHECK-DAG:   li 5, 2
; CHECK:       bl sink_s8

define i32 @call_s8(ptr %value) {
  %result = call i32 @sink_s8(
      i32 1, ptr byval(%S8) align 4 %value, i32 2)
  ret i32 %result
}

; The final four bytes of a 12-byte aggregate occupy the high word of the next
; full-width GPR.
; CHECK-LABEL: call_s12:
; CHECK-DAG:   ld 4, 0(3)
; CHECK-DAG:   lwz 5, 8(3)
; CHECK:       sldi 5, 5, 32
; CHECK:       bl sink_s12

define i32 @call_s12(ptr %value) {
  %result = call i32 @sink_s12(
      i32 1, ptr byval(%S12) align 4 %value, i32 2)
  ret i32 %result
}

; An aggregate spanning the register/stack boundary is reconstructed from
; X4-X10 and 16-byte-aligned stack storage. A following i32 uses the low word
; of the next 8-byte slot. The word-aligned stack portion is copied with word
; stores.
; CHECK-LABEL: call_s68:
; CHECK-DAG:   stw {{[0-9]+}}, 88(1)
; CHECK-DAG:   stw {{[0-9]+}}, 92(1)
; CHECK-DAG:   stw {{[0-9]+}}, 96(1)
; CHECK-DAG:   stw {{[0-9]+}}, 108(1)
; CHECK:       bl sink_s68

define i32 @call_s68(ptr %value) {
  %result = call i32 @sink_s68(
      i32 1, ptr byval(%S68) align 4 %value, i32 2)
  ret i32 %result
}

; CHECK-LABEL: receive_s68:
; CHECK-DAG:   std 4, 32(1)
; CHECK-DAG:   std 5, 40(1)
; CHECK-DAG:   std 10, 80(1)
; CHECK-DAG:   lwz {{[0-9]+}}, 96(1)
; CHECK-DAG:   lwz {{[0-9]+}}, 108(1)

define i32 @receive_s68(
    i32 %tag, ptr byval(%S68) align 4 %value, i32 %end) {
  %first_ptr = getelementptr %S68, ptr %value, i32 0, i32 0, i32 0
  %first = load i32, ptr %first_ptr, align 4
  %last_ptr = getelementptr %S68, ptr %value, i32 0, i32 0, i32 16
  %last = load i32, ptr %last_ptr, align 4
  %sum0 = add i32 %tag, %first
  %sum1 = add i32 %sum0, %last
  %result = add i32 %sum1, %end
  ret i32 %result
}

; Frontends coerce 8-byte aggregate returns to i64 in X3.
; CHECK-LABEL: return_s8:
; CHECK:       rldimi {{[0-9]+}}, 3, 32, 0
; CHECK:       mr 3,

define i64 @return_s8(i32 %value) {
  %high = zext i32 %value to i64
  %shifted = shl i64 %high, 32
  %next = add i32 %value, 1
  %low = zext i32 %next to i64
  %result = or i64 %shifted, %low
  ret i64 %result
}

; Rust and other frontends may use direct aggregate returns for their internal
; calling convention. These have already been legalized when they reach target
; return lowering.
; CHECK-LABEL: return_s8_internal:
; CHECK:       addi 4, 3, 1
; CHECK-NEXT:  blr

define internal fastcc %S8 @return_s8_internal(i32 %value) {
  %first = insertvalue %S8 poison, i32 %value, 0
  %next = add i32 %value, 1
  %result = insertvalue %S8 %first, i32 %next, 1
  ret %S8 %result
}

; Frontends lower aggregate returns of other sizes to an sret pointer in
; R3, shifting the first source argument to R4.
; CHECK-LABEL: return_s12:
; CHECK:       stw 4, 0(3)
; CHECK:       stw {{[0-9]+}}, 4(3)
; CHECK:       stw {{[0-9]+}}, 8(3)

define void @return_s12(ptr sret(%S12) align 4 %out, i32 %value) {
  store i32 %value, ptr %out, align 4
  %field1 = getelementptr %S12, ptr %out, i32 0, i32 1
  %next = add i32 %value, 1
  store i32 %next, ptr %field1, align 4
  %field2 = getelementptr %S12, ptr %out, i32 0, i32 2
  %last = add i32 %value, 2
  store i32 %last, ptr %field2, align 4
  ret void
}

; The callee returns the hidden result pointer in r3, where callers built by
; the console compiler read the result.
; CHECK-LABEL: return_s16_after_call:
; CHECK:       mr [[OUT:[0-9]+]], 3
; CHECK:       bl ext_i32
; CHECK:       mr 3, [[OUT]]
; CHECK:       blr

declare i32 @ext_i32()

define void @return_s16_after_call(ptr sret(%S16) align 8 %out, i64 %value) {
  %result = call i32 @ext_i32()
  %wide = sext i32 %result to i64
  store i64 %value, ptr %out, align 8
  %field1 = getelementptr i8, ptr %out, i32 8
  store i64 %wide, ptr %field1, align 8
  ret void
}

; The address of a 1, 2 or 4-byte aggregate is the low end of its home slot.
; CHECK-LABEL: escape_s2:
; CHECK:       stwu 1, -96(1)
; CHECK-DAG:   std 4, 120(1)
; CHECK-DAG:   li [[OFF:[0-9]+]], 6
; CHECK-DAG:   addi 3, 1, 120
; CHECK:       rlwimi 3, [[OFF]], 0, 29, 30
; CHECK:       bl use

declare void @use(ptr)

define void @escape_s2(i32 %tag, ptr byval(%S2) align 1 %value) {
  call void @use(ptr %value)
  ret void
}

; Padding before a 16-byte aligned aggregate uses no GPR, so the slot of each
; aggregate follows from the stack size rather than from its first register.
; CHECK-LABEL: receive_two_s12:
; CHECK-DAG:   std 4, 128(1)
; CHECK-DAG:   std 5, 136(1)
; CHECK-DAG:   std 7, 160(1)
; CHECK-DAG:   std 8, 168(1)
; CHECK-DAG:   addi 3, 1, 160
; CHECK:       bl use

define void @receive_two_s12(i32 %a, ptr byval(%S12) align 4 %s, i32 %b,
                             ptr byval(%S12) align 4 %t) {
  call void @use(ptr %t)
  ret void
}

; The variadic save area starts at the slot after the padded aggregate.
; CHECK-LABEL: va_after_s12:
; CHECK-DAG:   addi [[AREA:[0-9]+]], 1, 144
; CHECK-DAG:   std 6, 144(1)
; CHECK-DAG:   std 10, 176(1)
; CHECK-DAG:   stw [[AREA]], 84(1)
; CHECK:       bl use

define void @va_after_s12(i32 %a, ptr byval(%S12) align 4 %s, ...) {
  %ap = alloca ptr, align 4
  call void @llvm.va_start(ptr %ap)
  call void @use(ptr %ap)
  ret void
}
