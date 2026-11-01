; RUN: llc -mtriple=powerpc64-unknown-xbox360 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s --check-prefixes=CHECK,HV
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s --check-prefixes=CHECK,ILP32
; RUN: llc -mtriple=powerpc64-unknown-xbox360 -O0 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s --check-prefix=HV-O0
; RUN: llc -mtriple=powerpc64-unknown-xbox360 -filetype=obj < %s \
; RUN:   | llvm-readobj --file-headers -r - | FileCheck %s --check-prefix=HV-OBJ
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -filetype=obj < %s \
; RUN:   | llvm-readobj --file-headers -r - | FileCheck %s --check-prefix=ILP32-OBJ

; The hypervisor uses the console calling convention with 64-bit pointers:
; eight 8-byte argument slots after a 16-byte linkage area, LR stored below
; the incoming stack pointer, 64-bit back chain updates, and no TOC. Titles
; use 32-bit pointers in the same slots.

@g = global i32 0
@gp = global ptr @g

declare void @callee(ptr, i32, i64)
declare void @sink9(ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i32)
declare void @use(ptr)

; CHECK-LABEL: store_ptr:
; HV:          std 4, 0(3)
; ILP32:       stw 4, 0(3)
define void @store_ptr(ptr %p, ptr %q) {
  store ptr %q, ptr %p
  ret void
}

; CHECK-LABEL: load_gp:
; HV:          li 3, gp@l
; HV-NEXT:     lis 4, gp@ha
; HV-NEXT:     ldx 3, 4, 3
; ILP32:       lis 3, gp@ha
; ILP32-NEXT:  lwz 3, gp@l(3)
define ptr @load_gp() {
  %v = load ptr, ptr @gp
  ret ptr %v
}

; CHECK-LABEL: load_g:
; CHECK:       lis 3, g@ha
; CHECK-NEXT:  lwz 3, g@l(3)
define i32 @load_g() {
  %v = load i32, ptr @g
  ret i32 %v
}

; Calls branch directly with no TOC restore.
; CHECK-LABEL: call:
; CHECK:       mflr 0
; HV-NEXT:     std 0, -8(1)
; HV-NEXT:     stdu 1, -112(1)
; ILP32-NEXT:  stw 0, -8(1)
; ILP32-NEXT:  stwu 1, -112(1)
; CHECK:       std 30, 88(1)
; CHECK:       bl callee
; CHECK-NEXT:  mr 3, 30
; CHECK:       bl callee
; CHECK-NEXT:  ld 30, 88(1)
; CHECK-NEXT:  addi 1, 1, 112
; HV-NEXT:     ld 0, -8(1)
; ILP32-NEXT:  lwz 0, -8(1)
; CHECK-NEXT:  mtlr 0
; CHECK-NEXT:  blr
define void @call(ptr %p) {
  call void @callee(ptr %p, i32 1, i64 2)
  call void @callee(ptr %p, i32 1, i64 2)
  ret void
}

; The ninth argument is in the slot at caller SP+80. A pointer fills the
; slot, an int is right-justified in the next one.
; CHECK-LABEL: call9:
; HV-DAG:      std 3, 80(1)
; ILP32-DAG:   stw 3, 84(1)
; CHECK-DAG:   stw 4, 92(1)
; CHECK:       bl sink9
define void @call9(ptr %p) {
  call void @sink9(ptr %p, ptr %p, ptr %p, ptr %p, ptr %p, ptr %p, ptr %p,
                   ptr %p, ptr %p, i32 7)
  ret void
}

; CHECK-LABEL: ninth:
; HV:          ld 3, 80(1)
; ILP32:       lwz 3, 84(1)
; CHECK-NEXT:  blr
define ptr @ninth(ptr %a, ptr %b, ptr %c, ptr %d, ptr %e, ptr %f, ptr %g,
                  ptr %h, ptr %i) {
  ret ptr %i
}

; r31 and f31 keep their slots at -16 and -24. Titles store CR in the word
; at -4. The hypervisor LR doubleword covers that word, so CR goes to an
; 8-byte aligned frame slot below the register save areas.
; CHECK-LABEL: keep:
; HV:          std 0, -8(1)
; HV-NEXT:     stdu 1, -128(1)
; HV:          .cfi_offset cr2, -32
; HV-DAG:      mfcr 12
; HV-DAG:      std 31, 112(1)
; HV-DAG:      stfd 31, 104(1)
; HV-DAG:      stw 12, 96(1)
; HV:          bl callee
; HV-NEXT:     lwz 12, 96(1)
; HV-NEXT:     mtocrf 32, 12
; HV-NEXT:     lfd 31, 104(1)
; HV-NEXT:     ld 31, 112(1)
; HV-NEXT:     addi 1, 1, 128
; HV-NEXT:     ld 0, -8(1)
; ILP32:       stw 0, -8(1)
; ILP32-NEXT:  mfcr 12
; ILP32-NEXT:  stw 12, -4(1)
; ILP32-NEXT:  stwu 1, -112(1)
; ILP32-DAG:   std 31, 96(1)
; ILP32-DAG:   stfd 31, 88(1)
; ILP32:       bl callee
; ILP32:       lwz 12, -4(1)
define void @keep(ptr %p) {
  call void asm sideeffect "", "~{r31},~{f31},~{cr2}"()
  call void @callee(ptr %p, i32 1, i64 2)
  ret void
}

; Dynamic allocations probe and update the 64-bit back chain.
; CHECK-LABEL: dyn:
; CHECK:       std 31, -16(1)
; HV:          stdux 3, 1, 5
; HV:          stdu 3, -4096(1)
; HV:          ld 1, 0(1)
; ILP32:       stwux 3, 1, 5
; ILP32:       stwu 3, -4096(1)
; ILP32:       lwz 1, 0(1)
define void @dyn(i64 %n) {
  %a = alloca i8, i64 %n
  call void @callee(ptr %a, i32 0, i64 0)
  ret void
}

; An sret function returns its hidden result pointer in r3.
; CHECK-LABEL: sret:
; CHECK:       mr 30, 3
; HV:          std 4, 0(3)
; ILP32:       stw 4, 0(3)
; CHECK:       bl use
; CHECK-NEXT:  mr 3, 30
; HV-O0-LABEL: sret:
; HV-O0:       std 3, 0(4)
; HV-O0:       bl use
; HV-O0-NEXT:  ld 3, 96(1)
define void @sret(ptr sret({ ptr, i32 }) %r, ptr %p) {
  store ptr %p, ptr %r
  call void @use(ptr %p)
  ret void
}

; v64-v127 are saved relative to the incoming stack pointer before the frame
; is claimed.
; CHECK-LABEL: vec:
; CHECK:       li 12, -1040
; HV-NEXT:     std 0, -8(1)
; ILP32-NEXT:  stw 0, -8(1)
; CHECK-NEXT:  stvx128 64, 1, 12
; CHECK-NEXT:  .cfi_offset v64, -1040
; CHECK-NEXT:  li 12, -32
; CHECK-NEXT:  stvx128 127, 1, 12
; CHECK-NEXT:  .cfi_offset v127, -32
; HV-NEXT:     stdu 1, -1152(1)
; ILP32-NEXT:  stwu 1, -1152(1)
; CHECK:       bl use
; CHECK:       lvx128 127, 1, 3
; CHECK:       lvx128 64, 1, 3
define <4 x float> @vec(<4 x float> %a, ptr %p) {
  call void asm sideeffect "", "~{v64},~{v127}"()
  call void @use(ptr %p)
  ret <4 x float> %a
}

; The va_list is a pointer-sized cursor into the argument slots. A pointer
; argument fills its slot, and va_copy copies one pointer.
; CHECK-LABEL: va_ptr:
; HV:          stdu 1, -32(1)
; HV:          mr 3, 4
; HV-NEXT:     std 4, 56(1)
; HV-NEXT:     addi 4, 1, 56
; HV-NEXT:     std 4, 24(1)
; HV-NEXT:     addi 4, 1, 64
; HV:          std 10, 104(1)
; HV-NEXT:     std 4, 16(1)
; ILP32:       stwu 1, -32(1)
; ILP32:       addi 3, 1, 56
; ILP32-NEXT:  std 4, 56(1)
; ILP32-NEXT:  stw 3, 28(1)
; ILP32-NEXT:  addi 3, 1, 64
; ILP32:       std 10, 104(1)
; ILP32-NEXT:  stw 3, 24(1)
; ILP32-NEXT:  lwz 3, 60(1)
define ptr @va_ptr(i32 %n, ...) {
  %ap = alloca ptr
  %aq = alloca ptr
  call void @llvm.va_start.p0(ptr %ap)
  call void @llvm.va_copy.p0(ptr %aq, ptr %ap)
  %p = va_arg ptr %aq, ptr
  call void @llvm.va_end.p0(ptr %ap)
  ret ptr %p
}

declare void @llvm.va_start.p0(ptr)
declare void @llvm.va_copy.p0(ptr, ptr)
declare void @llvm.va_end.p0(ptr)

; Pointer data uses the pointer size.
; CHECK-LABEL: gp:
; HV-NEXT:     .quad g
; ILP32-NEXT:  .long g

; HV-OBJ:      Format: elf64-powerpc
; HV-OBJ:      Arch: powerpc64
; HV-OBJ:      Class: 64-bit
; HV-OBJ:      DataEncoding: BigEndian
; HV-OBJ:      Machine: EM_PPC64
; HV-OBJ:      Flags [ (0x0)
; HV-OBJ:      R_PPC64_ADDR16_LO gp
; HV-OBJ-NEXT: R_PPC64_ADDR16_HA gp
; HV-OBJ:      R_PPC64_REL24 callee
; HV-OBJ:      R_PPC64_ADDR64 g

; ILP32-OBJ:      Format: elf32-powerpc
; ILP32-OBJ:      Arch: powerpc
; ILP32-OBJ:      Class: 32-bit
; ILP32-OBJ:      DataEncoding: BigEndian
; ILP32-OBJ:      Machine: EM_PPC
; ILP32-OBJ:      R_PPC_ADDR16_HA gp
; ILP32-OBJ-NEXT: R_PPC_ADDR16_LO gp
; ILP32-OBJ:      R_PPC_REL24 callee
; ILP32-OBJ:      R_PPC_ADDR32 g
