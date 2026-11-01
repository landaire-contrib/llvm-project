; RUN: llc -mtriple=powerpc64-unknown-xbox360-ilp32 -filetype=obj < %s | \
; RUN:   llvm-readobj --sections - | FileCheck %s --check-prefix=XBOX
; RUN: llc -mtriple=powerpc64-unknown-lv2 -filetype=obj < %s | \
; RUN:   llvm-readobj --sections - | FileCheck %s --check-prefix=LV2

; Xbox 360 uses an ELF32 ABI and does not use the PPC64 ELF traceback table.
; In particular, fixed-size thunk sections must not gain twelve bytes after
; every function. LV2 remains a PPC64 ELF ABI despite its ILP32 data model.
target triple = "powerpc64-unknown-xbox360-ilp32"

; XBOX: Name: .xthunks
; XBOX: Size: 16
; LV2:  Name: .xthunks
; LV2:  Size: 28

define void @thunk() #0 section ".xthunks" {
  call void asm sideeffect ".long 0x01000003\0A\09.long 0x60000000\0A\09.long 0x60000000\0A\09.long 0x4e800020", ""()
  unreachable
}

attributes #0 = { naked noinline nounwind }
