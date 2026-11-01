; RUN: sed -e 's/PIC_LEVEL/1/' %s | llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   -relocation-model=pic -verify-machineinstrs \
; RUN:   | FileCheck %s --check-prefixes=CHECK,SMALL
; RUN: sed -e 's/PIC_LEVEL/2/' %s | llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   -relocation-model=pic -verify-machineinstrs \
; RUN:   | FileCheck %s --check-prefixes=CHECK,BIG
; RUN: sed -e 's/PIC_LEVEL/1/' %s | llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   -relocation-model=pic -filetype=obj \
; RUN:   | llvm-readobj -r - | FileCheck %s --check-prefix=SMALL-RELOC
; RUN: sed -e 's/PIC_LEVEL/2/' %s | llc -mtriple=powerpc64-unknown-xbox360-ilp32 \
; RUN:   -relocation-model=pic -filetype=obj \
; RUN:   | llvm-readobj -r - | FileCheck %s --check-prefix=BIG-RELOC

; Position-independent Xbox 360 code uses the 32-bit ELF PIC model: r30 holds
; the GOT pointer, globals are loaded through the GOT, and calls go through
; the PLT. r30 is preserved at full width in its Xbox save slot at -24.

target triple = "powerpc64-unknown-xbox360-ilp32"

@global = external global i32
@tls_gd = external thread_local global i32
@tls_ld = internal thread_local global i32 0

declare void @callee()

; BIG:         .section .got2,"aw",@progbits
; BIG:         .LTOC = {{\.Ltmp[0-9]+}}+32768

; A leaf function still saves LR, which the GOT pointer setup clobbers.
; BIG:         .L0$poff:
; BIG-NEXT:    .long .LTOC-.L0$pb
; CHECK-LABEL: load_global:
; CHECK:       mflr 0
; CHECK-NEXT:  std 30, -24(1)
; CHECK-NEXT:  stw 0, -8(1)
; CHECK-NEXT:  stwu 1, -48(1)
; CHECK-NEXT:  .cfi_def_cfa_offset 48
; CHECK-NEXT:  .cfi_offset r30, -24
; CHECK-NEXT:  .cfi_offset lr, -8
; SMALL-NEXT:  bl _GLOBAL_OFFSET_TABLE_@local-4
; SMALL-NEXT:  mflr 30
; SMALL-NEXT:  lwz 3, global@GOT(30)
; BIG-NEXT:    bcl 20, 31, .L0$pb
; BIG-NEXT:  .L0$pb:
; BIG-NEXT:    mflr 30
; BIG-NEXT:    lwz 3, .L0$poff-.L0$pb(30)
; BIG-NEXT:    add 30, 3, 30
; BIG-NEXT:    lwz 3, .LC0-.LTOC(30)
; CHECK-NEXT:  lwz 3, 0(3)
; CHECK-NEXT:  addi 1, 1, 48
; CHECK-NEXT:  lwz 0, -8(1)
; CHECK-NEXT:  mtlr 0
; CHECK-NEXT:  ld 30, -24(1)
; CHECK-NEXT:  blr

define i32 @load_global() {
  %value = load i32, ptr @global, align 4
  ret i32 %value
}

; CHECK-LABEL: store_global:
; SMALL:       lwz 4, global@GOT(30)
; BIG:         lwz 4, .LC0-.LTOC(30)
; CHECK-NEXT:  stw 3, 0(4)

define void @store_global(i32 %value) {
  store i32 %value, ptr @global, align 4
  ret void
}

; CHECK-LABEL: global_address:
; SMALL:       lwz 3, global@GOT(30)
; BIG:         lwz 3, .LC0-.LTOC(30)
; CHECK-NEXT:  addi 1, 1, 48

define ptr @global_address() {
  ret ptr @global
}

; CHECK-LABEL: function_address:
; SMALL:       lwz 3, callee@GOT(30)
; BIG:         lwz 3, .LC1-.LTOC(30)
; CHECK-NEXT:  addi 1, 1, 48

define ptr @function_address() {
  ret ptr @callee
}

; A call through the PLT does not need the GOT pointer without secure PLT.
; CHECK-LABEL: call_external:
; CHECK-NOT:   {{std 30|mflr 30}}
; CHECK:       bl callee@PLT
; CHECK-NOT:   {{ld 30|mflr 30}}
; CHECK:       blr

define void @call_external() {
  call void @callee()
  ret void
}

; CHECK-LABEL: call_indirect:
; CHECK-NOT:   _GLOBAL_OFFSET_TABLE_
; CHECK-NOT:   $pb
; CHECK:       mtctr 3
; CHECK:       bctrl
; CHECK:       blr

define i32 @call_indirect(ptr %target, i32 %value) {
  %result = call i32 %target(i32 %value)
  ret i32 %result
}

; The GOT pointer is preserved across calls in r30.
; CHECK-LABEL: call_and_load:
; CHECK:       mflr 0
; CHECK-NEXT:  std 30, -24(1)
; CHECK-NEXT:  stw 0, -8(1)
; CHECK-NEXT:  stwu 1, -112(1)
; CHECK-NEXT:  .cfi_def_cfa_offset 112
; CHECK-NEXT:  .cfi_offset r30, -24
; CHECK-NEXT:  .cfi_offset lr, -8
; CHECK:       bl callee@PLT
; SMALL-NEXT:  lwz 3, global@GOT(30)
; BIG-NEXT:    lwz 3, .LC0-.LTOC(30)
; CHECK-NEXT:  lwz 3, 0(3)
; CHECK-NEXT:  addi 1, 1, 112
; CHECK-NEXT:  lwz 0, -8(1)
; CHECK-NEXT:  mtlr 0
; CHECK-NEXT:  ld 30, -24(1)
; CHECK-NEXT:  blr

define i32 @call_and_load() {
  call void @callee()
  %value = load i32, ptr @global, align 4
  ret i32 %value
}

; CHECK-LABEL: load_tls_gd:
; SMALL:       addi 3, 30, tls_gd@got@tlsgd
; BIG:         lwz [[OFF:[0-9]+]], 0(3)
; BIG-NEXT:    add 3, [[OFF]], 3
; BIG-NEXT:    addi 3, 3, tls_gd@got@tlsgd
; CHECK-NEXT:  bl __tls_get_addr(tls_gd@tlsgd)@PLT
; CHECK-NEXT:  lwz 3, 0(3)

define i32 @load_tls_gd() {
  %value = load i32, ptr @tls_gd, align 4
  ret i32 %value
}

; CHECK-LABEL: load_tls_ld:
; SMALL:       addi 3, 30, tls_ld@got@tlsld
; BIG:         addi 3, 3, tls_ld@got@tlsld
; CHECK-NEXT:  bl __tls_get_addr(tls_ld@tlsld)@PLT
; CHECK-NEXT:  addis 3, 3, tls_ld@dtprel@ha
; CHECK-NEXT:  addi 3, 3, tls_ld@dtprel@l
; CHECK-NEXT:  lwz 3, 0(3)

define i32 @load_tls_ld() {
  %value = load i32, ptr @tls_ld, align 4
  ret i32 %value
}

; BIG:         .section .got2,"aw",@progbits
; BIG:         .LC0:
; BIG-NEXT:    .long global
; BIG-NEXT:    .LC1:
; BIG-NEXT:    .long callee

; SMALL-RELOC:     Section ({{[0-9]+}}) .rela.text {
; SMALL-RELOC-NEXT:  R_PPC_LOCAL24PC _GLOBAL_OFFSET_TABLE_ 0xFFFFFFFC
; SMALL-RELOC-NEXT:  R_PPC_GOT16 global 0x0
; SMALL-RELOC:       R_PPC_GOT16 callee 0x0
; SMALL-RELOC:       R_PPC_PLTREL24 callee 0x0
; SMALL-RELOC:       R_PPC_GOT_TLSGD16 tls_gd 0x0
; SMALL-RELOC-NEXT:  R_PPC_TLSGD tls_gd 0x0
; SMALL-RELOC-NEXT:  R_PPC_PLTREL24 __tls_get_addr 0x0
; SMALL-RELOC:       R_PPC_GOT_TLSLD16 tls_ld 0x0
; SMALL-RELOC-NEXT:  R_PPC_TLSLD tls_ld 0x0
; SMALL-RELOC-NEXT:  R_PPC_PLTREL24 __tls_get_addr 0x0
; SMALL-RELOC-NEXT:  R_PPC_DTPREL16_HA tls_ld 0x0
; SMALL-RELOC-NEXT:  R_PPC_DTPREL16_LO tls_ld 0x0
; SMALL-RELOC-NEXT: }

; The per-function $poff words resolve against .LTOC in .got2.
; BIG-RELOC:       Section ({{[0-9]+}}) .rela.text {
; BIG-RELOC-NEXT:    0x0 R_PPC_REL32 .got2 0x7FE8
; BIG-RELOC:         R_PPC_PLTREL24 callee 0x0
; BIG-RELOC:         R_PPC_REL32 _GLOBAL_OFFSET_TABLE_ 0x0
; BIG-RELOC-NEXT:    R_PPC_GOT_TLSGD16 tls_gd 0x0
; BIG-RELOC-NEXT:    R_PPC_TLSGD tls_gd 0x0
; BIG-RELOC-NEXT:    R_PPC_PLTREL24 __tls_get_addr 0x0
; BIG-RELOC:         R_PPC_GOT_TLSLD16 tls_ld 0x0
; BIG-RELOC:       Section ({{[0-9]+}}) .rela.got2 {
; BIG-RELOC-NEXT:    0x0 R_PPC_ADDR32 global 0x0
; BIG-RELOC-NEXT:    0x4 R_PPC_ADDR32 callee 0x0
; BIG-RELOC-NEXT:  }

!llvm.module.flags = !{!0}
!0 = !{i32 8, !"PIC Level", i32 PIC_LEVEL}
