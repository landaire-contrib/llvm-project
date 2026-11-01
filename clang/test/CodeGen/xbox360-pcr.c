// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -Os -emit-llvm -o - %s | FileCheck %s --check-prefix=IR
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -Os -S -o - %s | FileCheck %s --check-prefix=ASM

// Each evaluation reads the current processor's r13. It is not a TLS value.
// IR-LABEL: define{{.*}} i32 @read_base(
// IR: call i32 @llvm.read_volatile_register.i32(metadata ![[R13:[0-9]+]])
unsigned int read_base(void) { return __builtin_ppc_get_pcr(); }

// IR-LABEL: define{{.*}} i8 @load_byte(
// IR: call i32 @llvm.read_volatile_register.i32(metadata ![[R13]])
// IR: load i8,
// ASM-LABEL: load_byte:
// ASM-NOT: mr
// ASM: lbz 3, 268(13)
// ASM-NEXT: blr
unsigned char load_byte(void) {
  return *(unsigned char *)(__builtin_ppc_get_pcr() + 0x10c);
}

void migrate(void);

// IR-LABEL: define{{.*}} i32 @across_call(
// IR: [[BEFORE:%.*]] = {{.*}}call i32 @llvm.read_volatile_register.i32(metadata ![[R13]])
// IR: call void @migrate()
// IR: [[AFTER:%.*]] = {{.*}}call i32 @llvm.read_volatile_register.i32(metadata ![[R13]])
// IR: icmp eq i32 [[BEFORE]], [[AFTER]]
int across_call(void) {
  unsigned int before = __builtin_ppc_get_pcr();
  migrate();
  return before == __builtin_ppc_get_pcr();
}

// Retain unused reads in IR; a physical register read has no hardware effects.
// IR-LABEL: define{{.*}} void @unused_read(
// IR: call i32 @llvm.read_volatile_register.i32(metadata ![[R13]])
// IR: ret void
void unused_read(void) { __builtin_ppc_get_pcr(); }

// IR evaluations remain distinct. This does not promise physical sampling
// across asynchronous preemption; callers must establish processor affinity.
// IR-LABEL: define{{.*}} i32 @two_reads(
// IR: [[FIRST:%.*]] = {{.*}}call i32 @llvm.read_volatile_register.i32(metadata ![[R13]])
// IR: [[SECOND:%.*]] = {{.*}}call i32 @llvm.read_volatile_register.i32(metadata ![[R13]])
// IR: xor i32
unsigned int two_reads(void) {
  unsigned int first = __builtin_ppc_get_pcr();
  return first ^ __builtin_ppc_get_pcr();
}

// IR: ![[R13]] = !{!"r13"}
