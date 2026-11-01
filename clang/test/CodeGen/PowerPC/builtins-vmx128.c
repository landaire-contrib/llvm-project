// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -O1 -emit-llvm %s -o - \
// RUN:   | FileCheck %s
// RUN: %clang_cc1 -triple powerpc-unknown-unknown -target-feature +altivec \
// RUN:   -target-feature +vmx128 -O1 -emit-llvm %s -o - | FileCheck %s
// RUN: not %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 \
// RUN:   -target-feature -vmx128 -emit-llvm-only %s 2>&1 \
// RUN:   | FileCheck %s --check-prefix=NOVMX128
// RUN: not %clang_cc1 -triple powerpc64-unknown-linux-gnu \
// RUN:   -target-feature +altivec -emit-llvm-only %s 2>&1 \
// RUN:   | FileCheck %s --check-prefix=NOVMX128

// NOVMX128: error: '__builtin_vmx128_vmsum3fp' needs target feature vmx128

typedef float v4f __attribute__((vector_size(16)));
typedef int v4i __attribute__((vector_size(16)));
typedef unsigned char v16u8 __attribute__((vector_size(16)));

// CHECK-LABEL: @dot3(
// CHECK: call <4 x float> @llvm.ppc.vmx128.vmsum3fp(<4 x float> %a, <4 x float> %b)
v4f dot3(v4f a, v4f b) { return __builtin_vmx128_vmsum3fp(a, b); }

// CHECK-LABEL: @dot4(
// CHECK: call <4 x float> @llvm.ppc.vmx128.vmsum4fp(<4 x float> %a, <4 x float> %b)
v4f dot4(v4f a, v4f b) { return __builtin_vmx128_vmsum4fp(a, b); }

// CHECK-LABEL: @permwi_f(
// CHECK: [[A:%.*]] = bitcast <4 x float> %a to <4 x i32>
// CHECK: [[R:%.*]] = tail call <4 x i32> @llvm.ppc.vmx128.vpermwi(<4 x i32> [[A]], i32 27)
// CHECK: bitcast <4 x i32> [[R]] to <4 x float>
v4f permwi_f(v4f a) { return __builtin_vmx128_vpermwi(a, 0x1B); }

// CHECK-LABEL: @permwi_i(
// CHECK: call <4 x i32> @llvm.ppc.vmx128.vpermwi(<4 x i32> %a, i32 0)
v4i permwi_i(v4i a) { return __builtin_vmx128_vpermwi(a, 0); }

// CHECK-LABEL: @permwi_b(
// CHECK: [[A:%.*]] = bitcast <16 x i8> %a to <4 x i32>
// CHECK: [[R:%.*]] = tail call <4 x i32> @llvm.ppc.vmx128.vpermwi(<4 x i32> [[A]], i32 255)
// CHECK: bitcast <4 x i32> [[R]] to <16 x i8>
v16u8 permwi_b(v16u8 a) { return __builtin_vmx128_vpermwi(a, 255); }

// CHECK-LABEL: @rlimi_f(
// CHECK: [[D:%.*]] = bitcast <4 x float> %d to <4 x i32>
// CHECK: [[B:%.*]] = bitcast <4 x float> %b to <4 x i32>
// CHECK: [[R:%.*]] = tail call <4 x i32> @llvm.ppc.vmx128.vrlimi(<4 x i32> [[D]], <4 x i32> [[B]], i32 15, i32 3)
// CHECK: bitcast <4 x i32> [[R]] to <4 x float>
v4f rlimi_f(v4f d, v4f b) { return __builtin_vmx128_vrlimi(d, b, 15, 3); }

// CHECK-LABEL: @rlimi_i(
// CHECK: call <4 x i32> @llvm.ppc.vmx128.vrlimi(<4 x i32> %d, <4 x i32> %b, i32 0, i32 0)
v4i rlimi_i(v4i d, v4i b) { return __builtin_vmx128_vrlimi(d, b, 0, 0L); }

// CHECK-LABEL: @pkd3d(
// CHECK: call <4 x i32> @llvm.ppc.vmx128.vpkd3d(<4 x i32> %d, <4 x float> %b, i32 6, i32 3, i32 3)
v4i pkd3d(v4i d, v4f b) { return __builtin_vmx128_vpkd3d(d, b, 6, 3, 3); }

// CHECK-LABEL: @pkd3d_min(
// CHECK: call <4 x i32> @llvm.ppc.vmx128.vpkd3d(<4 x i32> %d, <4 x float> %b, i32 0, i32 1, i32 0)
v4i pkd3d_min(v4i d, v4f b) { return __builtin_vmx128_vpkd3d(d, b, 0, 1, 0); }

// CHECK-LABEL: @upkd3d(
// CHECK: call <4 x float> @llvm.ppc.vmx128.vupkd3d(<4 x i32> %a, i32 6)
v4f upkd3d(v4i a) { return __builtin_vmx128_vupkd3d(a, 6); }

// CHECK-LABEL: @upkd3d_min(
// CHECK: call <4 x float> @llvm.ppc.vmx128.vupkd3d(<4 x i32> %a, i32 0)
v4f upkd3d_min(v4i a) { return __builtin_vmx128_vupkd3d(a, 0); }

// CHECK-LABEL: @loads(
// CHECK: call <4 x i32> @llvm.ppc.vmx128.lvlx(ptr %p)
// CHECK: [[Q:%.*]] = getelementptr i8, ptr %p, i32 16
// CHECK: call <4 x i32> @llvm.ppc.vmx128.lvrx(ptr [[Q]])
// CHECK: call <4 x i32> @llvm.ppc.vmx128.lvlxl(ptr %p)
// CHECK: call <4 x i32> @llvm.ppc.vmx128.lvrxl(ptr [[Q]])
v4i loads(const void *p) {
  return (__builtin_vmx128_lvlx(0, p) | __builtin_vmx128_lvrx(16, p)) +
         (__builtin_vmx128_lvlxl(0, p) | __builtin_vmx128_lvrxl(16, p));
}

// CHECK-LABEL: @stores(
// CHECK: call void @llvm.ppc.vmx128.stvlx(<4 x i32> %v, ptr %p)
// CHECK: [[Q:%.*]] = getelementptr i8, ptr %p, i32 16
// CHECK: call void @llvm.ppc.vmx128.stvrx(<4 x i32> %v, ptr [[Q]])
// CHECK: call void @llvm.ppc.vmx128.stvlxl(<4 x i32> %v, ptr %p)
// CHECK: call void @llvm.ppc.vmx128.stvrxl(<4 x i32> %v, ptr [[Q]])
void stores(v4i v, void *p) {
  __builtin_vmx128_stvlx(v, 0, p);
  __builtin_vmx128_stvrx(v, 16, p);
  __builtin_vmx128_stvlxl(v, 0, p);
  __builtin_vmx128_stvrxl(v, 16, p);
}
