; RUN: llc -ppc-reg-with-percent-prefix -mtriple=powerpc64-unknown-xbox360-ilp32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s
; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -filetype=obj < %s \
; RUN:   | llvm-readobj -r - | FileCheck %s --check-prefix=RELOC

; The GOT holds 32-bit thread-pointer offsets, so the initial-exec load is a
; word load with the 32-bit relocation.
; CHECK-LABEL: load_tls:
; CHECK:       lwz [[OFF:%r[0-9]+]], tls@got@tprel([[OFF]])
; CHECK-NEXT:  add [[ADDR:%r[0-9]+]], [[OFF]], tls@tls
; CHECK-NEXT:  lwz %r3, 0([[ADDR]])

; RELOC:     R_PPC_GOT_TPREL16 tls
; RELOC-NOT: R_PPC_GOT_TPREL16_LO

@tls = thread_local global i32 0

define i32 @load_tls() {
  %value = load i32, ptr @tls, align 4
  ret i32 %value
}
