# RUN: llvm-mc -triple powerpc64-unknown-xbox360-ilp32 -mattr=-vmx128,+altivec \
# RUN:   --show-encoding -ppc-reg-with-percent-prefix %s | FileCheck %s --check-prefix=ENC
# RUN: llvm-mc -triple powerpc64-unknown-xbox360-ilp32 -mattr=-vmx128,+altivec \
# RUN:   -filetype=obj %s | llvm-objdump -d --no-show-raw-insn \
# RUN:   --triple=powerpc64-unknown-xbox360-ilp32 --mattr=-vmx128,+altivec - \
# RUN:   | FileCheck %s --check-prefix=DIS

# Classic partial memory instructions remain available and decode correctly
# with the Xbox AltiVec register file, independently of VMX128.
# ENC: lvlx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf4,0x0e]
# DIS: lvlx 31, 31, 30
lvlx %v31, %r31, %r30
# ENC: lvrx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf4,0x4e]
# DIS: lvrx 31, 31, 30
lvrx %v31, %r31, %r30
# ENC: stvlx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf5,0x0e]
# DIS: stvlx 31, 31, 30
stvlx %v31, %r31, %r30
# ENC: stvrx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf5,0x4e]
# DIS: stvrx 31, 31, 30
stvrx %v31, %r31, %r30
# ENC: lvlxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf6,0x0e]
# DIS: lvlxl 31, 31, 30
lvlxl %v31, %r31, %r30
# ENC: lvrxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf6,0x4e]
# DIS: lvrxl 31, 31, 30
lvrxl %v31, %r31, %r30
# ENC: stvlxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf7,0x0e]
# DIS: stvlxl 31, 31, 30
stvlxl %v31, %r31, %r30
# ENC: stvrxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf7,0x4e]
# DIS: stvrxl 31, 31, 30
stvrxl %v31, %r31, %r30
