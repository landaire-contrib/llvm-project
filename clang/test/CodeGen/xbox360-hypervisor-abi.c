// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360 -emit-llvm -o - %s \
// RUN:   | FileCheck %s --check-prefixes=CHECK,HV
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -emit-llvm -o - %s \
// RUN:   | FileCheck %s --check-prefixes=CHECK,ILP32
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360 -mrelocation-model static \
// RUN:   -O2 -S -o - %s | FileCheck %s --check-prefix=ASM

// The hypervisor follows the title calling convention with 64-bit pointers.
// long stays 32 bits, size_t is 64 bits, and an aggregate holding a pointer
// grows with it.

typedef __SIZE_TYPE__ size_t;

struct P {
  void *p;
};
struct PI {
  void *p;
  int i;
};

// CHECK-LABEL: define{{.*}} ptr @pass_ptr(ptr noundef %p)
void *pass_ptr(void *p) { return p; }

// CHECK-LABEL: define{{.*}} i32 @pass_long(i32 noundef %l)
long pass_long(long l) { return l; }

// HV-LABEL:    define{{.*}} i64 @pass_size(i64 noundef %n)
// ILP32-LABEL: define{{.*}} i32 @pass_size(i32 noundef %n)
size_t pass_size(size_t n) { return n; }

// HV-LABEL:    define{{.*}} i64 @pass_p(i64 %p.coerce)
// ILP32-LABEL: define{{.*}} i32 @pass_p(i32 %p.coerce)
struct P pass_p(struct P p) { return p; }

// HV-LABEL:    define{{.*}} void @pass_pi(ptr {{.*}}sret(%struct.PI) align 8 %agg.result, ptr noundef byval(%struct.PI) align 8 %pi)
// ILP32-LABEL: define{{.*}} i64 @pass_pi(i64 %pi.coerce)
struct PI pass_pi(struct PI pi) { return pi; }

// The 16-byte aggregate uses x4 and x5 and a 16-byte aligned image at
// caller SP+32. The hidden result pointer is returned in r3.
// ASM-LABEL: pass_pi:
// ASM-DAG:   std 4, 32(1)
// ASM-DAG:   std 5, 40(1)
// ASM-DAG:   std 4, 8(3)
// ASM-DAG:   std 5, 0(3)
// ASM:       blr

// CHECK-LABEL: define{{.*}} ptr @va_ptr(i32 noundef %n, ...)
// CHECK:       va_arg ptr %ap, ptr
void *va_ptr(int n, ...) {
  __builtin_va_list ap;
  __builtin_va_start(ap, n);
  void *p = __builtin_va_arg(ap, void *);
  __builtin_va_end(ap);
  return p;
}

extern void sink9(void *, void *, void *, void *, void *, void *, void *,
                  void *, void *, int);

// The ninth argument fills the slot at caller SP+80; the int after it is
// right-justified in the next slot.
// ASM-LABEL: call9:
// ASM:       std 0, -8(1)
// ASM-NEXT:  stdu 1, -112(1)
// ASM-DAG:   std 3, 80(1)
// ASM-DAG:   stw 4, 92(1)
// ASM:       bl sink9
// ASM:       ld 0, -8(1)
void call9(void *p) { sink9(p, p, p, p, p, p, p, p, p, 7); }
