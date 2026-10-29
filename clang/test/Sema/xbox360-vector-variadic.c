// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -target-feature +altivec \
// RUN:   -std=c17 -Wno-deprecated-non-prototype -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple powerpc64-unknown-linux-gnu -target-feature +altivec \
// RUN:   -std=c17 -Wno-deprecated-non-prototype -fsyntax-only \
// RUN:   -verify=other %s

// other-no-diagnostics

// The Xbox 360 ABI has no convention for vectors in variadic or unprototyped
// calls, so the console compiler rejects them, including fixed vector
// parameters of variadic functions. Structs that contain vectors are allowed.

typedef float V __attribute__((vector_size(16)));
typedef struct {
  V a;
} S1;

void variadic(int n, ...);
void variadic_vector(V a, int n, ...);
void unprototyped();
void (*variadic_pointer)(int, ...);
void fixed(V a, int n);

void variadic_definition(V a, int n, ...) {}

void calls(V v, S1 s) {
  variadic(1, v, 2); // expected-error {{vector arguments to variadic or unprototyped functions are not supported by the Xbox 360 ABI}}
  variadic_vector(v, 1); // expected-error {{vector arguments to variadic or unprototyped functions are not supported by the Xbox 360 ABI}}
  unprototyped(v); // expected-error {{vector arguments to variadic or unprototyped functions are not supported by the Xbox 360 ABI}}
  variadic_pointer(1, v); // expected-error {{vector arguments to variadic or unprototyped functions are not supported by the Xbox 360 ABI}}
  variadic(1, s, 2);
  fixed(v, 1);
}
