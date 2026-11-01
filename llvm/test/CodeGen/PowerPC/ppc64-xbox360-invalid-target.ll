; RUN: not llc -mtriple=powerpc64-unknown-linux-gnu -mattr=+xbox360 < %s 2>&1 | FileCheck %s
; RUN: not llc -mtriple=powerpc64le-unknown-xbox360 -mattr=+xbox360 < %s 2>&1 | FileCheck %s
; RUN: not llc -mtriple=powerpc-unknown-xbox360 -mattr=+xbox360 < %s 2>&1 | FileCheck %s

; CHECK: xbox360 requires a big-endian powerpc64-unknown-xbox360-ilp32 ELF target

define void @test() {
  ret void
}
