// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -Os -ffreestanding \
// RUN:   -emit-llvm -o - %s | FileCheck %s --check-prefix=IR
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -Os -ffreestanding \
// RUN:   -mrelocation-model static -S -o - %s | FileCheck %s --check-prefix=ASM
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -Os -ffreestanding \
// RUN:   -fno-optimize-sibling-calls -S -o - %s | FileCheck %s --check-prefix=DISABLED
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -Os -ffreestanding \
// RUN:   -mrelocation-model pic -S -o - %s | FileCheck %s --check-prefix=PIC

extern void process_item(void *);

// A normal optimized C call is marked tail in IR even though it branches to
// a shared return block. Xbox call lowering must accept the C sibling without
// changing the ABI or requiring the guaranteed fastcc tail-call option.
// IR-LABEL: define{{.*}} void @conditional_call(i32{{.*}}, ptr{{.*}})
// IR:       and i32 {{.*}}, 2
// IR:       tail call void @process_item(ptr
// IR:       ret void
// ASM-LABEL: conditional_call:
// ASM-NOT:   mflr
// ASM-NOT:   stwu
// ASM:       andi.
// ASM-NOT:   mflr
// ASM-NOT:   stwu
// ASM:       b process_item
// DISABLED-LABEL: conditional_call:
// DISABLED:       bl process_item
// PIC-LABEL: conditional_call:
// PIC:       bl process_item@PLT
void conditional_call(unsigned long flags, void *item) {
  if (flags & 2UL)
    process_item(item);
}
