// RUN: %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -emit-llvm -o - %s | FileCheck %s
// RUN: not %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -target-abi elfv1 \
// RUN:   -emit-llvm -o /dev/null %s 2>&1 | FileCheck --check-prefix=INVALID %s
// RUN: not %clang_cc1 -triple powerpc64-unknown-xbox360-ilp32 -DVA_AGGREGATE \
// RUN:   -emit-llvm -o /dev/null %s 2>&1 | FileCheck --check-prefix=VAAGG %s

// INVALID: error: unknown target ABI 'elfv1'

struct S1 {
  char a;
};
struct S2 {
  char a[2];
};
struct S3 {
  char a[3];
};
struct S4 {
  int a;
};
struct F4 {
  float a;
};
struct S5 {
  char a[5];
};
struct S8 {
  int a;
  int b;
};
struct S12 {
  int a;
  int b;
  int c;
};

// Aggregates of 1, 2 and 4 bytes are passed and returned as integers of that
// size, right-justified. Other sizes up to 8 bytes are passed left-justified
// in an i64 and returned through a hidden pointer unless they are 8 bytes.
// CHECK-LABEL: define{{.*}} i8 @id1(i8 %value.coerce)
struct S1 id1(struct S1 value) { return value; }

// CHECK-LABEL: define{{.*}} i16 @id2(i16 %value.coerce)
struct S2 id2(struct S2 value) { return value; }

// CHECK-LABEL: define{{.*}} void @id3(ptr {{.*}}sret(%struct.S3){{.*}}, i64 %value.coerce)
struct S3 id3(struct S3 value) { return value; }

// CHECK-LABEL: define{{.*}} i32 @id4(i32 %value.coerce)
struct S4 id4(struct S4 value) { return value; }

// CHECK-LABEL: define{{.*}} i32 @idf4(i32 %value.coerce)
struct F4 idf4(struct F4 value) { return value; }

// CHECK-LABEL: define{{.*}} void @id5(ptr {{.*}}sret(%struct.S5){{.*}}, i64 %value.coerce)
struct S5 id5(struct S5 value) { return value; }

// CHECK-LABEL: define{{.*}} i64 @id8(i64 %value.coerce)
struct S8 id8(struct S8 value) { return value; }

// CHECK-LABEL: define{{.*}} void @id12(ptr {{.*}}sret(%struct.S12){{.*}}, ptr {{.*}}byval(%struct.S12)
struct S12 id12(struct S12 value) { return value; }

void va_sink(int, ...);

// CHECK-LABEL: define{{.*}} void @va_pass(
// CHECK:       call void (i32, ...) @va_sink(i32 noundef 1, i16 %{{.*}}, i64 %{{.*}})
void va_pass(struct S2 *a, struct S3 *b) { va_sink(1, *a, *b); }

// CHECK-LABEL: define{{.*}} i16 @va_s2(
// CHECK:       [[V:%.*]] = va_arg ptr %{{.*}}, i32
// CHECK:       trunc i32 [[V]] to i16
struct S2 va_s2(int tag, ...) {
  __builtin_va_list ap;
  __builtin_va_start(ap, tag);
  struct S2 value = __builtin_va_arg(ap, struct S2);
  __builtin_va_end(ap);
  return value;
}

// CHECK-LABEL: define{{.*}} void @va_s3(
// CHECK:       [[V:%.*]] = va_arg ptr %{{.*}}, i64
// CHECK:       store i64 [[V]], ptr %va.agg
struct S3 va_s3(int tag, ...) {
  __builtin_va_list ap;
  __builtin_va_start(ap, tag);
  struct S3 value = __builtin_va_arg(ap, struct S3);
  __builtin_va_end(ap);
  return value;
}

// The console compiler defines only the declared bits of char and short
// arguments and returns, so they carry no extension attribute. bool is always
// a clean 0 or 1.
// CHECK-LABEL: define{{( dso_local)?}} i8 @narrow_s8(i8 noundef %value)
signed char narrow_s8(signed char value) { return value; }

// CHECK-LABEL: define{{( dso_local)?}} i16 @narrow_u16(i16 noundef %value)
unsigned short narrow_u16(unsigned short value) { return value; }

// CHECK-LABEL: define{{( dso_local)?}} i32 @call_narrow(
// CHECK:       call i8 @narrow_s8(i8 noundef %{{.*}})
// CHECK:       call i16 @narrow_u16(i16 noundef %{{.*}})
int call_narrow(signed char a, unsigned short b) {
  return narrow_s8(a) + narrow_u16(b);
}

// CHECK-LABEL: define{{( dso_local)?}} zeroext i1 @pass_bool(i1 noundef zeroext %value)
_Bool pass_bool(_Bool value) { return value; }

#ifdef VA_AGGREGATE
// VAAGG: error: cannot compile this xbox360 variadic aggregate yet
struct S12 va_s12(int tag, ...) {
  __builtin_va_list ap;
  __builtin_va_start(ap, tag);
  struct S12 value = __builtin_va_arg(ap, struct S12);
  __builtin_va_end(ap);
  return value;
}
#endif

// CHECK-NOT: !"target-abi"
