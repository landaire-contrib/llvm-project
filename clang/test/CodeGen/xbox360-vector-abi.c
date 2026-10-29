// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -target-feature +altivec \
// RUN:   -emit-llvm -o - %s | FileCheck %s
// RUN: not %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 \
// RUN:   -target-feature +altivec -DVA_VECTOR -emit-llvm -o /dev/null %s 2>&1 \
// RUN:   | FileCheck --check-prefix=VAVEC %s

// 16-byte vectors of float or of integers up to 32 bits are passed and
// returned directly (v1-v13 and v1). Other vectors have no console equivalent
// and follow the aggregate rules, like structs that contain vectors.

typedef float V __attribute__((vector_size(16)));
typedef int VI __attribute__((vector_size(16)));
typedef float V2 __attribute__((vector_size(8)));
typedef float V8 __attribute__((vector_size(32)));
typedef double VD __attribute__((vector_size(16)));
typedef float V3 __attribute__((ext_vector_type(3)));
typedef struct {
  V a;
} S1;
typedef struct {
  float f;
  V v;
} SF;

// CHECK-LABEL: define{{.*}} <4 x float> @pass(<4 x float> noundef %a, <4 x float> noundef %b)
V pass(V a, V b) { return b; }

// CHECK-LABEL: define{{.*}} <4 x float> @altivec(<4 x float> noundef %a, <4 x i32> noundef %b, <16 x i8> noundef %c)
vector float altivec(vector float a, vector int b, vector unsigned char c) {
  return a;
}

// CHECK-LABEL: define{{.*}} <4 x i32> @pass_int(<4 x i32> noundef %a)
VI pass_int(VI a) { return a; }

// CHECK-LABEL: define{{.*}} <3 x float> @pass3(<3 x float> noundef %a)
V3 pass3(V3 a) { return a; }

// CHECK-LABEL: define{{.*}} i64 @pass2(i64 noundef %a.coerce)
V2 pass2(V2 a) { return a; }

// CHECK-LABEL: define{{.*}} void @pass8(ptr {{.*}}sret(<8 x float>) align 32 %{{.*}}, ptr noundef byval(<8 x float>) align 32 %0)
V8 pass8(V8 a) { return a; }

// CHECK-LABEL: define{{.*}} void @pass_double(ptr {{.*}}sret(<2 x double>) align 16 %{{.*}}, ptr noundef byval(<2 x double>) align 16 %0)
VD pass_double(VD a) { return a; }

// CHECK-LABEL: define{{.*}} void @pass_s1(ptr {{.*}}sret(%struct.S1) align 16 %{{.*}}, i32 noundef %i, ptr noundef byval(%struct.S1) align 16 %s)
S1 pass_s1(int i, S1 s) { return s; }

// CHECK-LABEL: define{{.*}} void @pass_sf(ptr noundef byval(%struct.SF) align 16 %s, <4 x float> noundef %v)
void pass_sf(SF s, V v) {}

// A fixed vector of a variadic function is passed directly.
// CHECK-LABEL: define{{.*}} void @variadic_fixed(<4 x float> noundef %a, i32 noundef %n, ...)
void variadic_fixed(V a, int n, ...) {}

// CHECK-LABEL: define{{.*}} <4 x float> @call_pass(
// CHECK:       call <4 x float> @pass(<4 x float> noundef %{{.*}}, <4 x float> noundef %{{.*}})
V call_pass(V a) { return pass(a, a); }

#ifdef VA_VECTOR
// VAVEC: error: cannot compile this xbox360 variadic vector yet
V va_vector(int n, ...) {
  __builtin_va_list ap;
  __builtin_va_start(ap, n);
  V value = __builtin_va_arg(ap, V);
  __builtin_va_end(ap);
  return value;
}
#endif
