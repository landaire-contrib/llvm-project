// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -x c++ -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple powerpc64-unknown-linux-gnu -target-feature +altivec -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple powerpc-unknown-linux-gnu -target-feature +altivec -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple powerpc64le-unknown-linux-gnu -target-feature +altivec -fsyntax-only -verify %s

// The conversion scale is a five-bit unsigned instruction field on both
// AltiVec and VMX128. Constantness alone does not enforce its range.
typedef float v4f __attribute__((vector_size(16)));
typedef int v4i __attribute__((vector_size(16)));
typedef unsigned int v4u __attribute__((vector_size(16)));

void valid(v4f f, v4i i, v4u u) {
  (void)__builtin_altivec_vcfux(u, 0);
  (void)__builtin_altivec_vcfux(u, 31);
  (void)__builtin_altivec_vcfsx(i, 0);
  (void)__builtin_altivec_vcfsx(i, 31);
  (void)__builtin_altivec_vctsxs(f, 0);
  (void)__builtin_altivec_vctsxs(f, 31);
  (void)__builtin_altivec_vctuxs(f, 0);
  (void)__builtin_altivec_vctuxs(f, 31);
}

void invalid(v4f f, v4i i, v4u u, int n) {
  (void)__builtin_altivec_vcfux(u, -1); // expected-error {{argument value -1 is outside the valid range [0, 31]}}
  (void)__builtin_altivec_vcfux(u, 32); // expected-error {{argument value 32 is outside the valid range [0, 31]}}
  (void)__builtin_altivec_vcfux(u, n); // expected-error {{argument to '__builtin_altivec_vcfux' must be a constant integer}}
  (void)__builtin_altivec_vcfsx(i, -1); // expected-error {{argument value -1 is outside the valid range [0, 31]}}
  (void)__builtin_altivec_vcfsx(i, 32); // expected-error {{argument value 32 is outside the valid range [0, 31]}}
  (void)__builtin_altivec_vcfsx(i, n); // expected-error {{argument to '__builtin_altivec_vcfsx' must be a constant integer}}
  (void)__builtin_altivec_vctsxs(f, -1); // expected-error {{argument value -1 is outside the valid range [0, 31]}}
  (void)__builtin_altivec_vctsxs(f, 32); // expected-error {{argument value 32 is outside the valid range [0, 31]}}
  (void)__builtin_altivec_vctsxs(f, n); // expected-error {{argument to '__builtin_altivec_vctsxs' must be a constant integer}}
  (void)__builtin_altivec_vctuxs(f, -1); // expected-error {{argument value -1 is outside the valid range [0, 31]}}
  (void)__builtin_altivec_vctuxs(f, 32); // expected-error {{argument value 32 is outside the valid range [0, 31]}}
  (void)__builtin_altivec_vctuxs(f, n); // expected-error {{argument to '__builtin_altivec_vctuxs' must be a constant integer}}
}
