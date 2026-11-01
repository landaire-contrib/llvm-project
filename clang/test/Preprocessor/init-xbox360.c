// RUN: %clang_cc1 -E -dM -ffreestanding -triple=powerpc64-unknown-xbox360-ilp32 < /dev/null \
// RUN:   | FileCheck -match-full-lines -check-prefixes=CHECK,ILP32 %s \
// RUN:     --implicit-check-not='#define _WIN64'
// RUN: %clang_cc1 -fsyntax-only -ffreestanding -triple=powerpc64-unknown-xbox360-ilp32 %s
// RUN: %clang_cc1 -E -dM -ffreestanding -triple=powerpc64-unknown-xbox360 < /dev/null \
// RUN:   | FileCheck -match-full-lines -check-prefixes=CHECK,HV %s \
// RUN:     --implicit-check-not='#define _ILP32' --implicit-check-not='#define __ILP32__' \
// RUN:     --implicit-check-not='#define _LP64' --implicit-check-not='#define __LP64__'
// RUN: %clang_cc1 -fsyntax-only -ffreestanding -triple=powerpc64-unknown-xbox360 %s

// CHECK-DAG: #define _M_PPC 5401
// CHECK-DAG: #define _M_PPCBE 1
// CHECK-DAG: #define _WIN32 1
// CHECK-DAG: #define _XBOX_VER 200

// CHECK-DAG: #define __ALTIVEC__ 1
// CHECK-DAG: #define __LDBL_MANT_DIG__ 53
// CHECK-DAG: #define __SIZEOF_LONG_DOUBLE__ 8
// CHECK-DAG: #define __SIZEOF_WCHAR_T__ 2
// CHECK-DAG: #define __VMX128__ 1
// CHECK-DAG: #define __WCHAR_TYPE__ unsigned short
// CHECK-DAG: #define __WCHAR_UNSIGNED__ 1
// CHECK-DAG: #define __SIZEOF_INT__ 4
// CHECK-DAG: #define __SIZEOF_LONG__ 4
// CHECK-DAG: #define __SIZEOF_LONG_LONG__ 8
// CHECK-DAG: #define __INT64_TYPE__ long long int
// CHECK-DAG: #define __INTMAX_TYPE__ long long int

// Titles use ILP32.
// ILP32-DAG: #define _ILP32 1
// ILP32-DAG: #define __ILP32__ 1
// ILP32-DAG: #define __SIZEOF_POINTER__ 4
// ILP32-DAG: #define __SIZEOF_SIZE_T__ 4
// ILP32-DAG: #define __SIZE_TYPE__ unsigned int
// ILP32-DAG: #define __PTRDIFF_TYPE__ long int
// ILP32-DAG: #define __INTPTR_TYPE__ long int

// The hypervisor uses LLP64 and defines _WIN64, as /Qhypervisor does.
// HV-DAG: #define _WIN64 1
// HV-DAG: #define _ARCH_PPC64 1
// HV-DAG: #define __powerpc64__ 1
// HV-DAG: #define __SIZEOF_POINTER__ 8
// HV-DAG: #define __SIZEOF_SIZE_T__ 8
// HV-DAG: #define __SIZE_TYPE__ long long unsigned int
// HV-DAG: #define __PTRDIFF_TYPE__ long long int
// HV-DAG: #define __INTPTR_TYPE__ long long int

_Static_assert(sizeof(long double) == 8, "");
_Static_assert(_Alignof(long double) == 8, "");
_Static_assert(sizeof(__WCHAR_TYPE__) == 2, "");
_Static_assert((__WCHAR_TYPE__)-1 > 0, "");
_Static_assert(sizeof(int) == 4, "");
_Static_assert(sizeof(long) == 4, "");
_Static_assert(sizeof(long long) == 8, "");
_Static_assert(_Alignof(long long) == 8, "");

#ifdef _WIN64
_Static_assert(sizeof(void *) == 8, "");
_Static_assert(_Alignof(void *) == 8, "");
_Static_assert(sizeof(void (*)(void)) == 8, "");
_Static_assert(sizeof(__SIZE_TYPE__) == 8, "");
_Static_assert(sizeof(__INTPTR_TYPE__) == 8, "");
struct PointerAfterInt {
  int a;
  void *p;
};
_Static_assert(sizeof(struct PointerAfterInt) == 16, "");
_Static_assert(__builtin_offsetof(struct PointerAfterInt, p) == 8, "");
#else
_Static_assert(sizeof(void *) == 4, "");
_Static_assert(_Alignof(void *) == 4, "");
_Static_assert(sizeof(void (*)(void)) == 4, "");
_Static_assert(sizeof(__SIZE_TYPE__) == 4, "");
_Static_assert(sizeof(__INTPTR_TYPE__) == 4, "");
struct PointerAfterInt {
  int a;
  void *p;
};
_Static_assert(sizeof(struct PointerAfterInt) == 8, "");
_Static_assert(__builtin_offsetof(struct PointerAfterInt, p) == 4, "");
#endif
