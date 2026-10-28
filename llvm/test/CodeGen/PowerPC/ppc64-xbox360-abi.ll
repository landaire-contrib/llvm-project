; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=BE
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=-xbox360 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=BE
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -frame-pointer=all \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=FP
; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -stackrealign \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=BP
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -mattr=+altivec \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=VMX
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   -filetype=obj < %s | llvm-readobj --file-headers - | FileCheck %s --check-prefix=ELF
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   -stop-after=prolog-epilog < %s | FileCheck %s --check-prefix=LARGE-MIR

; The Xbox 360 uses an ILP32 ABI on a 64-bit PowerPC processor. Pointers and
; ELF container fields are 32-bit, while i64 values use 64-bit GPRs.

target triple = "powerpc64-unknown-xbox360-ilp32"

; BE-LABEL: add_i64:
; BE:       add %r3, %r3, %r4
; BE-NOT:   addc
; BE-NOT:   adde

define i64 @add_i64(i64 %a, i64 %b) {
  %sum = add i64 %a, %b
  ret i64 %sum
}

; BE-LABEL: load_i64:
; BE:       ld %r3, 0(%r3)

define i64 @load_i64(ptr %address) {
  %value = load i64, ptr %address, align 8
  ret i64 %value
}

; Pointer stack objects remain 4 bytes.
; BE-LABEL: spill_pointer:
; BE:       stw %r3,
; BE:       lwz %r3,

define ptr @spill_pointer(ptr %pointer) {
  %slot = alloca ptr, align 4
  store volatile ptr %pointer, ptr %slot, align 4
  %result = load volatile ptr, ptr %slot, align 4
  ret ptr %result
}

; LR is saved in the word 8 bytes below the incoming stack pointer before the
; frame is claimed, and is reloaded from there after the frame is released.
; BE-LABEL: call_loaded_i64:
; BE:       mflr %r0
; BE-NEXT:  stw %r0, -8(%r1)
; BE-NEXT:  stwu %r1, -96(%r1)
; BE-NEXT:  .cfi_def_cfa_offset 96
; BE-NEXT:  .cfi_offset lr, -8
; BE-NEXT:  ld %r3, 0(%r3)
; BE-NEXT:  bl callee
; BE-NEXT:  addi %r1, %r1, 96
; BE-NEXT:  lwz %r0, -8(%r1)
; BE-NEXT:  mtlr %r0
; BE-NEXT:  blr

declare i64 @callee(i64)

define i64 @call_loaded_i64(ptr %address) {
  %value = load i64, ptr %address, align 8
  %result = call i64 @callee(i64 %value)
  ret i64 %result
}

; Indirect calls use the PPC64 instruction definitions, whose BCTRL8 opcode
; defines LR8. The prologue must therefore save and restore the physical link
; register even though the ABI uses 32-bit pointers and DWARF register mappings.
; BE-LABEL: call_indirect:
; BE:       mflr %r0
; BE-NEXT:  stw %r0, -8(%r1)
; BE-NEXT:  stwu %r1, -96(%r1)
; BE-NEXT:  .cfi_def_cfa_offset 96
; BE-NEXT:  .cfi_offset lr, -8
; BE-NEXT:  mtctr %r3
; BE-NEXT:  mr %r3, %r4
; BE-NEXT:  bctrl
; BE-NEXT:  addi %r1, %r1, 96
; BE-NEXT:  lwz %r0, -8(%r1)
; BE-NEXT:  mtlr %r0
; BE-NEXT:  blr

define i32 @call_indirect(ptr %callee, i32 %value) {
  %result = call i32 %callee(i32 %value)
  ret i32 %result
}

; The i64 uses one 64-bit argument register after the preceding i32.
; BE-LABEL: aligned_i64:
; BE:       mr %r3, %r4

define i64 @aligned_i64(i32 %prefix, i64 %value) {
  ret i64 %value
}

; The ninth integer argument is passed on the stack.
; BE-LABEL: stacked_i64:
; BE:       ld %r3, 80(%r1)

define i64 @stacked_i64(i32 %a, i32 %b, i32 %c, i32 %d, i32 %e, i32 %f, i32 %g, i32 %h, i64 %value) {
  ret i64 %value
}

; Stack-passed i32 and pointer-sized arguments are right-justified in
; consecutive 8-byte slots.
; BE-LABEL: stacked_i32:
; BE-DAG:   lwz {{%r[0-9]+}}, 84(%r1)
; BE-DAG:   lwz {{%r[0-9]+}}, 92(%r1)

define i32 @stacked_i32(i32 %a, i32 %b, i32 %c, i32 %d, i32 %e, i32 %f,
                        i32 %g, i32 %h, i32 %i, i32 %j) {
  %sum = add i32 %i, %j
  ret i32 %sum
}

; BE-LABEL: call_stacked_i32:
; BE-DAG:   stw {{%r[0-9]+}}, 84(%r1)
; BE-DAG:   stw {{%r[0-9]+}}, 92(%r1)

declare void @callee_i32(i32, i32, i32, i32, i32, i32, i32, i32, i32, i32)

define void @call_stacked_i32() {
  call void @callee_i32(i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                        i32 8, i32 9, i32 10)
  ret void
}

; Nonvolatile GPRs preserve all 64 bits. r31 is saved 16 bytes below the
; incoming stack pointer.
; BE-LABEL: clobber_r31:
; BE:       stwu %r1, -32(%r1)
; BE-NEXT:  .cfi_def_cfa_offset 32
; BE-NEXT:  .cfi_offset r31, -16
; BE-NEXT:  std %r31, 16(%r1)
; BE:       ld %r31, 16(%r1)
; BE-NEXT:  addi %r1, %r1, 32
; BE-NEXT:  blr

define void @clobber_r31() {
  call void asm sideeffect "", "~{r31}"()
  ret void
}

; The full-width GPR save area starts 16 bytes below the incoming stack
; pointer, so r14 is saved at -152 as in observed kernel prologues.
; BE-LABEL: clobber_r14:
; BE:       stwu %r1, -176(%r1)
; BE-NEXT:  .cfi_def_cfa_offset 176
; BE-NEXT:  .cfi_offset r14, -152
; BE-NEXT:  std %r14, 24(%r1)
; BE:       ld %r14, 24(%r1)
; BE-NEXT:  addi %r1, %r1, 176
; BE-NEXT:  blr

define void @clobber_r14() {
  call void asm sideeffect "", "~{r14}"()
  ret void
}

; The Xbox save area below the incoming stack pointer is available before a
; frame is claimed. This matches observed kernel prologues.
; BE-LABEL: clobber_cr2:
; BE:       mfcr %r12
; BE-NEXT:  stw %r12, -4(%r1)
; BE-NEXT:  stwu %r1, -32(%r1)
; BE-NEXT:  .cfi_def_cfa_offset 32
; BE-NEXT:  .cfi_offset cr2, -4
; BE:       addi %r1, %r1, 32
; BE-NEXT:  lwz %r12, -4(%r1)
; BE-NEXT:  mtocrf 32, %r12
; BE-NEXT:  blr

define void @clobber_cr2() {
  call void asm sideeffect "", "~{cr2}"()
  ret void
}

; The CR save word does not overlap the r31 save slot.
; BE-LABEL: clobber_cr2_r31:
; BE:       mfcr %r12
; BE-NEXT:  stw %r12, -4(%r1)
; BE-NEXT:  stwu %r1, -32(%r1)
; BE-NEXT:  .cfi_def_cfa_offset 32
; BE-NEXT:  .cfi_offset r31, -16
; BE-NEXT:  .cfi_offset cr2, -4
; BE-NEXT:  std %r31, 16(%r1)
; BE:       ld %r31, 16(%r1)
; BE-NEXT:  addi %r1, %r1, 32
; BE-NEXT:  lwz %r12, -4(%r1)
; BE-NEXT:  mtocrf 32, %r12
; BE-NEXT:  blr

define void @clobber_cr2_r31() {
  call void asm sideeffect "", "~{cr2},~{r31}"()
  ret void
}

; The FPR save area is below the GPR save area: with r30 and r31 reserved,
; f31 is saved at -32.
; BE-LABEL: clobber_f31_r30:
; BE:       stwu %r1, -48(%r1)
; BE-NEXT:  .cfi_def_cfa_offset 48
; BE-NEXT:  .cfi_offset r30, -24
; BE-NEXT:  .cfi_offset f31, -32
; BE-NEXT:  std %r30, 24(%r1)
; BE-NEXT:  stfd %f31, 16(%r1)
; BE:       lfd %f31, 16(%r1)
; BE-NEXT:  ld %r30, 24(%r1)
; BE-NEXT:  addi %r1, %r1, 48
; BE-NEXT:  blr

define void @clobber_f31_r30() {
  call void asm sideeffect "", "~{f31},~{r30}"()
  ret void
}

; No local object overlaps the LR save word at -8.
; BE-LABEL: local_with_lr:
; BE:       mflr %r0
; BE-NEXT:  stw %r0, -8(%r1)
; BE-NEXT:  stwu %r1, -96(%r1)
; BE-NEXT:  .cfi_def_cfa_offset 96
; BE-NEXT:  .cfi_offset lr, -8
; BE-NEXT:  addi %r3, %r1, 80
; BE-NEXT:  bl use
; BE-NEXT:  addi %r1, %r1, 96
; BE-NEXT:  lwz %r0, -8(%r1)
; BE-NEXT:  mtlr %r0
; BE-NEXT:  blr

define void @local_with_lr() {
  %slot = alloca i64, align 8
  call void @use(ptr %slot)
  ret void
}

; The console compiler preserves only v64-v127, which LLVM does not model, so
; no vector register is callee-saved. A vector live across a call is spilled.
; VMX-LABEL: vector_live_across_call:
; VMX:       stvx %v2, %r1, %r3
; VMX-NEXT:  bl ext
; VMX-NEXT:  li %r3, 96
; VMX-NEXT:  lvx %v2, %r1, %r3
; VMX-LABEL: clobber_v20:
; VMX-NOT:   stvx
; VMX:       blr

declare void @ext()

define void @vector_live_across_call(ptr %p) {
  %v = load <4 x i32>, ptr %p, align 16
  call void @ext()
  store <4 x i32> %v, ptr %p, align 16
  ret void
}

define void @clobber_v20() {
  call void asm sideeffect "", "~{v20}"()
  ret void
}

; Dedicated frame-pointer saves also preserve all 64 bits.
; FP-LABEL: frame_pointer:
; FP:       std %r31, -16(%r1)
; FP-NEXT:  stwu %r1, -48(%r1)
; FP-NEXT:  .cfi_def_cfa_offset 48
; FP-NEXT:  .cfi_offset r31, -16
; FP-NEXT:  mr %r31, %r1
; FP:       addi %r1, %r1, 48
; FP-NEXT:  ld %r31, -16(%r1)
; FP-NEXT:  blr

define i64 @frame_pointer(i64 %value) {
  %slot = alloca i64, align 8
  store volatile i64 %value, ptr %slot, align 8
  %result = load volatile i64, ptr %slot, align 8
  ret i64 %result
}

declare void @use(ptr)

; Realigned frames preserve the full frame and base pointer registers.
; BP-LABEL: base_pointer:
; BP:       std %r31, -16(%r1)
; BP:       std %r30, -24(%r1)
; BP:       .cfi_offset r31, -16
; BP:       .cfi_offset r30, -24
; BP:       ld %r31, -16(%r1)
; BP:       ld %r30, -24(%r1)

define i64 @base_pointer(i64 %value, i32 %count) {
  %slot = alloca i64, i32 %count, align 32
  store volatile i64 %value, ptr %slot, align 32
  call void @use(ptr %slot)
  %result = load volatile i64, ptr %slot, align 32
  ret i64 %result
}

; Integer variadic arguments that fit in registers use the same 64-bit GPR
; slots observed in DbgPrint.
; BE-LABEL: call_vararg_i64:
; BE:       ld %r4, 0(%r4)
; BE:       bl variadic_sink

declare i32 @variadic_sink(ptr, ...)

define i32 @call_vararg_i64(ptr %format, ptr %address) {
  %value = load i64, ptr %address, align 8
  %result = call i32 (ptr, ...) @variadic_sink(ptr %format, i64 %value)
  ret i32 %result
}

; A 32-bit atomic value uses the 32-bit control-fence pseudo even though the
; processor supports 64-bit instructions.
; BE-LABEL: load_i32_acquire:
; BE:       lwz %r3, 0(%r3)
; BE-NEXT:  cmpw %cr7, %r3, %r3
; BE-NEXT:  bne- %cr7, .+4
; BE-NEXT:  isync

define i32 @load_i32_acquire(ptr %address) {
  %value = load atomic i32, ptr %address acquire, align 4
  ret i32 %value
}

; A 64-bit atomic value uses the 64-bit control-fence pseudo.
; BE-LABEL: load_i64_acquire:
; BE:       ld %r3, 0(%r3)
; BE-NEXT:  cmpd %cr7, %r3, %r3
; BE-NEXT:  bne- %cr7, .+4
; BE-NEXT:  isync

define i64 @load_i64_acquire(ptr %address) {
  %value = load atomic i64, ptr %address acquire, align 8
  ret i64 %value
}

; 128-bit atomic loads are library calls and need no control fence.
; BE-LABEL: load_i128_acquire:
; BE:       li %r4, 2
; BE-NEXT:  bl __atomic_load_16
; BE-NOT:   isync
; BE:       blr

define i128 @load_i128_acquire(ptr %address) {
  %value = load atomic i128, ptr %address acquire, align 16
  ret i128 %value
}

; Large frames restore the caller's 32-bit stack pointer from the back chain.
; LARGE-MIR-LABEL: name: large_frame_no_fp
; LARGE-MIR:       $r1 = LWZ 0, $r1

define void @large_frame_no_fp() {
  %slot = alloca [40000 x i8], align 16
  call void @use(ptr %slot)
  ret void
}

; Large frame-index offsets use a 64-bit scratch register so an emergency
; scavenger spill preserves the full aliased GPR.
; LARGE-MIR-LABEL: name: large_frame_far_slot
; LARGE-MIR:       $x{{[0-9]+}} = LIS8
; LARGE-MIR:       $x{{[0-9]+}} = ORI8

define i8 @large_frame_far_slot() {
  %slot = alloca [40000 x i8], align 16
  %far = getelementptr [40000 x i8], ptr %slot, i32 0, i32 39999
  store volatile i8 1, ptr %far, align 1
  %value = load volatile i8, ptr %far, align 1
  call void @use(ptr %slot)
  ret i8 %value
}

; ELF: Format: elf32-powerpc
; ELF: Arch: powerpc
; ELF: AddressSize: 32bit
; ELF: Class: 32-bit
; ELF: DataEncoding: BigEndian
; ELF: Machine: EM_PPC
