# RUN: llvm-mc -triple=powerpc64-unknown-xbox360 -filetype=obj %s | \
# RUN:   llvm-readobj -r - | FileCheck %s
# RUN: llvm-mc -triple=powerpc-unknown-linux-gnu -filetype=obj %s | \
# RUN:   llvm-readobj -r - | FileCheck %s
# RUN: llvm-mc -triple=powerpc64-unknown-xbox360 -filetype=obj %s | \
# RUN:   llvm-objdump -d --no-show-raw-insn - | FileCheck %s --check-prefix=INSN

## The 32-bit ELF ABI has no DS- or DQ-form relocations. As in GNU as, the
## displacement of a DS- or DQ-form instruction uses the D-form relocation, and
## the instruction keeps the low bits that belong to its opcode.

# CHECK:      Section ({{[0-9]+}}) .rela.text {
# CHECK-NEXT:   0x2 R_PPC_ADDR16_HA sym 0x0
# CHECK-NEXT:   0x6 R_PPC_ADDR16_LO sym 0x0
# CHECK-NEXT:   0xA R_PPC_ADDR16_LO sym 0x8
# CHECK-NEXT:   0xE R_PPC_ADDR16_LO sym 0x0
# CHECK-NEXT:   0x12 R_PPC_ADDR16_LO sym 0x0
# CHECK-NEXT:   0x16 R_PPC_ADDR16_LO sym 0x0
# CHECK-NEXT:   0x1A R_PPC_ADDR16_LO sym 0x0
# CHECK-NEXT:   0x1E R_PPC_ADDR16 sym 0x0
# CHECK-NEXT:   0x22 R_PPC_GOT16 sym 0x0
# CHECK-NEXT:   0x26 R_PPC_GOT16_LO sym 0x0
# CHECK-NEXT:   0x2A R_PPC_TPREL16 tls 0x0
# CHECK-NEXT:   0x2E R_PPC_TPREL16_LO tls 0x0
# CHECK-NEXT:   0x32 R_PPC_DTPREL16 tls 0x0
# CHECK-NEXT:   0x36 R_PPC_DTPREL16_LO tls 0x0
# CHECK-NEXT:   0x3A R_PPC_GOT_TPREL16 tls 0x0
# CHECK-NEXT:   0x3E R_PPC_GOT_TPREL16_LO tls 0x0
# CHECK-NEXT:   0x42 R_PPC_GOT_DTPREL16 tls 0x0
# CHECK-NEXT:   0x46 R_PPC_GOT_DTPREL16_LO tls 0x0
# CHECK-NEXT: }

# INSN:      lis 3, 0
# INSN-NEXT: ldu 4, 0(3)
# INSN-NEXT: ld 5, 0(3)
# INSN-NEXT: lwa 5, 0(3)
# INSN-NEXT: std 5, 0(3)
# INSN-NEXT: stdu 5, 0(3)
# INSN-NEXT: lq 6, 0(3)
# INSN-NEXT: ld 5, 0(0)

  lis 3, sym@ha
  ldu 4, sym@l(3)
  ld 5, (sym+8)@l(3)
  lwa 5, sym@l(3)
  std 5, sym@l(3)
  stdu 5, sym@l(3)
  lq 6, sym@l(3)
  ld 5, sym(0)
  ld 5, sym@got(30)
  ld 5, sym@got@l(30)
  ld 5, tls@tprel(2)
  ld 5, tls@tprel@l(3)
  ld 5, tls@dtprel(3)
  ld 5, tls@dtprel@l(3)
  ld 5, tls@got@tprel(30)
  ld 5, tls@got@tprel@l(30)
  ld 5, tls@got@dtprel(30)
  ld 5, tls@got@dtprel@l(30)

  .section .tbss,"awT",@nobits
tls:
  .space 8
