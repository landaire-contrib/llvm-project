# REQUIRES: ppc
## The 32-bit ABI has no DS- or DQ-form relocations, so 64-bit loads and stores
## use D-form relocations. The linker keeps the low bits of a DS- or DQ-form
## instruction, which belong to its opcode, and rejects misaligned values.

# RUN: llvm-mc -filetype=obj -triple=powerpc %s -o %t.o
# RUN: ld.lld %t.o --defsym=a=0x10020010 --defsym=b=0x1234 -o %t
# RUN: llvm-objdump -d --no-show-raw-insn %t | FileCheck %s

# RUN: not ld.lld %t.o --defsym=a=0x10020016 --defsym=b=0x1236 -o /dev/null 2>&1 | \
# RUN:   FileCheck %s --check-prefix=ERR --implicit-check-not=error:

# CHECK-LABEL: <_start>:
# CHECK-NEXT:  lis 3, 4098
# CHECK-NEXT:  ldu 4, 16(3)
# CHECK-NEXT:  ld 4, 24(3)
# CHECK-NEXT:  lwa 4, 16(3)
# CHECK-NEXT:  std 4, 16(3)
# CHECK-NEXT:  stdu 4, 16(3)
# CHECK-NEXT:  lq 4, 16(3)
# CHECK-NEXT:  ld 4, 4660(0)
# CHECK-NEXT:  addi 4, 3, 16
# CHECK-NEXT:  lwz 4, 16(3)

# ERR:      error: {{.*}}:(.text+0x6): improper alignment for relocation R_PPC_ADDR16_LO: 0x16 is not aligned to 4 bytes
# ERR-NEXT: error: {{.*}}:(.text+0xa): improper alignment for relocation R_PPC_ADDR16_LO: 0x1E is not aligned to 4 bytes
# ERR-NEXT: error: {{.*}}:(.text+0xe): improper alignment for relocation R_PPC_ADDR16_LO: 0x16 is not aligned to 4 bytes
# ERR-NEXT: error: {{.*}}:(.text+0x12): improper alignment for relocation R_PPC_ADDR16_LO: 0x16 is not aligned to 4 bytes
# ERR-NEXT: error: {{.*}}:(.text+0x16): improper alignment for relocation R_PPC_ADDR16_LO: 0x16 is not aligned to 4 bytes
# ERR-NEXT: error: {{.*}}:(.text+0x1a): improper alignment for relocation R_PPC_ADDR16_LO: 0x16 is not aligned to 16 bytes
# ERR-NEXT: error: {{.*}}:(.text+0x1e): improper alignment for relocation R_PPC_ADDR16: 0x1236 is not aligned to 4 bytes

.globl _start
_start:
  lis 3, a@ha
  ldu 4, a@l(3)
  ld 4, (a+8)@l(3)
  lwa 4, a@l(3)
  std 4, a@l(3)
  stdu 4, a@l(3)
  lq 4, a@l(3)
  ld 4, b(0)
## D-form instructions use all 16 bits.
  addi 4, 3, a@l
  lwz 4, a@l(3)
