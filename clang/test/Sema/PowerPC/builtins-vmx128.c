// REQUIRES: powerpc-registered-target
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -target-feature -vmx128 \
// RUN:   -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple powerpc64-unknown-linux-gnu -target-feature +altivec \
// RUN:   -fsyntax-only -verify %s

typedef float v4f __attribute__((vector_size(16)));
typedef int v4i __attribute__((vector_size(16)));
typedef float v2f __attribute__((vector_size(8)));

void ranges(v4f f, v4i i, int n) {
  __builtin_vmx128_vpermwi(f, -1);   // expected-error {{argument value -1 is outside the valid range [0, 255]}}
  __builtin_vmx128_vpermwi(f, 256);  // expected-error {{argument value 256 is outside the valid range [0, 255]}}
  __builtin_vmx128_vpermwi(f, n);    // expected-error {{argument to '__builtin_vmx128_vpermwi' must be a constant integer}}
  __builtin_vmx128_vrlimi(f, f, 16, 0); // expected-error {{argument value 16 is outside the valid range [0, 15]}}
  __builtin_vmx128_vrlimi(f, f, 0, 4);  // expected-error {{argument value 4 is outside the valid range [0, 3]}}
  __builtin_vmx128_vrlimi(f, f, n, 0);  // expected-error {{argument to '__builtin_vmx128_vrlimi' must be a constant integer}}
  __builtin_vmx128_vpkd3d(i, f, 7, 1, 0); // expected-error {{argument value 7 is outside the valid range [0, 6]}}
  __builtin_vmx128_vpkd3d(i, f, 0, 0, 0); // expected-error {{argument value 0 is outside the valid range [1, 3]}}
  __builtin_vmx128_vpkd3d(i, f, 0, 4, 0); // expected-error {{argument value 4 is outside the valid range [1, 3]}}
  __builtin_vmx128_vpkd3d(i, f, 0, 1, 4); // expected-error {{argument value 4 is outside the valid range [0, 3]}}
  __builtin_vmx128_vupkd3d(i, 7);         // expected-error {{argument value 7 is outside the valid range [0, 6]}}
  __builtin_vmx128_vupkd3d(i, n);         // expected-error {{argument to '__builtin_vmx128_vupkd3d' must be a constant integer}}
}

void types(v4f f, v4i i, v2f h, float s) {
  __builtin_vmx128_vpermwi(s, 0);        // expected-error {{argument 1 must be of type 16-byte vector}}
  __builtin_vmx128_vpermwi(h, 0);        // expected-error {{argument 1 must be of type 16-byte vector}}
  __builtin_vmx128_vpermwi(f);           // expected-error {{too few arguments to function call, expected 2, have 1}}
  __builtin_vmx128_vrlimi(f, i, 8, 0);   // expected-error {{first two arguments to '__builtin_vmx128_vrlimi' must have the same type}}
  __builtin_vmx128_vrlimi(f, h, 8, 0);   // expected-error {{argument 2 must be of type 16-byte vector}}
  __builtin_vmx128_vrlimi(f, f, 8, 0, 0); // expected-error {{too many arguments to function call, expected 4, have 5}}
}

v4f valid(v4f f, v4i i, const void *p, void *q) {
  v4i l = __builtin_vmx128_lvlx(0, p) | __builtin_vmx128_lvrx(16, p) |
          __builtin_vmx128_lvlxl(0, p) | __builtin_vmx128_lvrxl(16, p);
  __builtin_vmx128_stvlx(l, 0, q);
  __builtin_vmx128_stvrx(l, 16, q);
  __builtin_vmx128_stvlxl(l, 0, q);
  __builtin_vmx128_stvrxl(l, 16, q);
  i = __builtin_vmx128_vpkd3d(i, f, 6, 3, 3);
  f = __builtin_vmx128_vupkd3d(i, 0);
  f = __builtin_vmx128_vmsum3fp(f, f);
  f = __builtin_vmx128_vmsum4fp(f, f);
  i = __builtin_vmx128_vrlimi(i, i, 15, 3);
  return __builtin_vmx128_vpermwi(f, 255);
}
