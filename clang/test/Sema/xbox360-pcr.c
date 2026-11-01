// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -fsyntax-only -verify=xbox %s
// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360 -fsyntax-only -verify=baseline %s
// RUN: %clang_cc1 -triple powerpc64-unknown-linux-gnu -fsyntax-only -verify=baseline %s
// RUN: %clang_cc1 -triple powerpc-unknown-linux-gnu -fsyntax-only -verify=baseline %s

unsigned int read_base(void) {
  return __builtin_ppc_get_pcr(); // baseline-error {{builtin is not supported on this target}}
}

#if defined(_XBOX_VER) && !defined(_WIN64)
void invalid_arguments(void) {
  __builtin_ppc_get_pcr(1); // xbox-error {{too many arguments to function call, expected 0, have 1}}
}
#endif
