# RUN: llvm-mc -triple powerpc64-unknown-xbox360-ilp32 -mattr=-vmx128,+altivec \
# RUN:   --show-encoding -ppc-reg-with-percent-prefix %s | FileCheck %s --check-prefix=ENC

# Classic partial memory instructions remain available with the Xbox AltiVec
# register file, independently of VMX128.
# ENC: lvlx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf4,0x0e]
lvlx %v31, %r31, %r30
# ENC: lvrx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf4,0x4e]
lvrx %v31, %r31, %r30
# ENC: stvlx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf5,0x0e]
stvlx %v31, %r31, %r30
# ENC: stvrx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf5,0x4e]
stvrx %v31, %r31, %r30
# ENC: lvlxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf6,0x0e]
lvlxl %v31, %r31, %r30
# ENC: lvrxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf6,0x4e]
lvrxl %v31, %r31, %r30
# ENC: stvlxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf7,0x0e]
stvlxl %v31, %r31, %r30
# ENC: stvrxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf7,0x4e]
stvrxl %v31, %r31, %r30
