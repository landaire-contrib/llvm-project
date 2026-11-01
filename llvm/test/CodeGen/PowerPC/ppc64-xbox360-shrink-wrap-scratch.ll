; RUN: llc -mtriple=powerpc64-unknown-xbox360 -O1 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s

; Shrink wrapping must not pick a prologue block whose only free GPRs are
; callee-saved: the prologue inserter treats unsaved callee-saved registers as
; live, so they are not scratch registers there. The Xbox 360 saves 64-bit
; registers but takes its scratch registers from the 32-bit class, so every
; alias of a callee-saved register has to be excluded. Here r3-r12 are live
; into the block that reads the stack argument, and the stack probe requires
; two scratch registers. Reduced from ttf-parser.

target datalayout = "E-m:e-p:32:32-Fn32-i64:64-i128:128-n32:64"

define i1 @f(ptr %p, i32 %c, i32 %a, i1 %b0, i1 %b1, i1 %b2, i8 %shift, i1 %b3, i1 %b4) {
; CHECK-LABEL: f:
; CHECK-NOT:     stwu
; CHECK:         lwz 0, 84(1)
; CHECK:         ld 4, 8(3)
; CHECK:         ld 3, 0(3)
; CHECK:         blr
start:
  %low = and i32 %c, 1
  %cmp0 = icmp eq i32 %low, 67840
  %or0 = or i1 %cmp0, %b4
  %sel0 = select i1 %or0, i1 true, i1 %b0
  %sel1 = select i1 %sel0, i1 true, i1 %b1
  br i1 %sel1, label %load, label %check

check:
  %cmp1 = icmp eq i32 %low, 0
  %or1 = or i1 %b2, %cmp1
  %cmp2 = icmp eq i32 %a, 0
  %sel2 = select i1 %or1, i1 false, i1 %cmp2
  %or2 = or i1 %sel2, %b3
  %cmp3 = icmp eq i32 %c, 119808
  %sel3 = select i1 %or2, i1 false, i1 %cmp3
  br i1 %sel3, label %load, label %other

ret:
  %r = phi i1 [ %bit, %load ]
  ret i1 %r

other:
  %cmp4 = icmp eq i32 0, 66432
  ret i1 %cmp4

load:
  %v = load i128, ptr %p, align 16
  %amt = zext i8 %shift to i128
  %shr = lshr i128 %v, %amt
  %bit = trunc i128 %shr to i1
  br label %ret
}
