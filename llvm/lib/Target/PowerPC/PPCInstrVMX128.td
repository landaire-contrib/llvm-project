//===-- PPCInstrVMX128.td - The Xenon VMX128 extension -----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the VMX128 vector extension of the Xbox 360 Xenon
// processor and the Xenon left/right vector loads and stores.
//
// VMX128 instructions use primary opcodes 4, 5 and 6 and name v0-v127 with
// 7-bit register numbers. Bits 4-0 of a number sit in the usual AltiVec field,
// bits 6-5 in low-order instruction bits. The encodings overlap POWER8 and
// later instructions, so they decode from their own table.
//
//===----------------------------------------------------------------------===//

class VMX128Form<bits<6> opcode, dag OOL, dag IOL, string asmstr,
                 InstrItinClass itin, list<dag> pattern>
    : I<opcode, OOL, IOL, asmstr, itin> {
  // Bits that decoders accept with either value. Indexed from the least
  // significant bit, unlike Inst.
  field bits<32> SoftFail = 0;

  let Pattern = pattern;
}

// Vector load/store: vD, rA, rB.
class VX128Form_1<bits<5> xo, dag OOL, dag IOL, string asmstr,
                  InstrItinClass itin, list<dag> pattern>
    : VMX128Form<4, OOL, IOL, asmstr, itin, pattern>, XFormMemOp {
  bits<7> VD;
  bits<5> RA;
  bits<5> RB;

  let Inst{6...10} = VD{4...0};
  let Inst{11...15} = RA;
  let Inst{16...20} = RB;
  let Inst{21...25} = xo;
  let Inst{26...27} = 0;
  let Inst{28} = VD{6};
  let Inst{29} = VD{5};
  // Decoders ignore bit 30. Microsoft tools always set it.
  let Inst{30} = 1;
  let SoftFail{1} = 1;
  let Inst{31} = 1;
}

// Three vector registers vD, vA, vB, with bits 22-25 left to the subclass.
class VX128Form_base<bits<6> opcode, dag OOL, dag IOL, string asmstr,
                     InstrItinClass itin, list<dag> pattern>
    : VMX128Form<opcode, OOL, IOL, asmstr, itin, pattern> {
  bits<7> VD;
  bits<7> VA;
  bits<7> VB;

  let Inst{6...10} = VD{4...0};
  let Inst{11...15} = VA{4...0};
  let Inst{16...20} = VB{4...0};
  let Inst{21} = VA{6};
  let Inst{26} = VA{5};
  let Inst{28} = VD{6};
  let Inst{29} = VD{5};
  let Inst{30} = VB{6};
  let Inst{31} = VB{5};
}

// xo holds bits 22-25 and, in its lowest bit, bit 27.
class VX128Form<bits<6> opcode, bits<5> xo, dag OOL, dag IOL, string asmstr,
                InstrItinClass itin, list<dag> pattern>
    : VX128Form_base<opcode, OOL, IOL, asmstr, itin, pattern> {
  let Inst{22...25} = xo{4...1};
  let Inst{27} = xo{0};
}

// vperm128: the permute control is a 3-bit register field.
class VX128Form_2<dag OOL, dag IOL, string asmstr, InstrItinClass itin,
                  list<dag> pattern>
    : VX128Form_base<5, OOL, IOL, asmstr, itin, pattern> {
  bits<3> VC;

  let Inst{22} = 0;
  let Inst{23...25} = VC;
  let Inst{27} = 0;
}

// vsldoi128.
class VX128Form_5<dag OOL, dag IOL, string asmstr, InstrItinClass itin,
                  list<dag> pattern>
    : VX128Form_base<4, OOL, IOL, asmstr, itin, pattern> {
  bits<4> SHB;

  let Inst{22...25} = SHB;
  let Inst{27} = 1;
}

// vD, vB and a 5-bit immediate field in bits 11-15.
class VX128Form_3<bits<7> xo, dag OOL, dag IOL, string asmstr,
                  InstrItinClass itin, list<dag> pattern>
    : VMX128Form<6, OOL, IOL, asmstr, itin, pattern> {
  bits<7> VD;
  bits<7> VB;
  bits<5> IMM;

  let Inst{6...10} = VD{4...0};
  let Inst{11...15} = IMM;
  let Inst{16...20} = VB{4...0};
  let Inst{21...27} = xo;
  let Inst{28} = VD{6};
  let Inst{29} = VD{5};
  let Inst{30} = VB{6};
  let Inst{31} = VB{5};
}

// Unary vD, vB. Decoders ignore the immediate field.
class VX128Form_3_unary<bits<7> xo, string opc, InstrItinClass itin>
    : VX128Form_3<xo, (outs vrrc128:$VD), (ins vrrc128:$VB),
                  !strconcat(opc, " $VD, $VB"), itin, []> {
  let IMM = 0;
  let SoftFail{20...16} = 0b11111;
}

// vrlimi128 and vpkd3d128: the destination is also read; bits 11-15 hold the
// subclass immediates.
class VX128Form_4<bits<3> xo, dag OOL, dag IOL, string asmstr,
                  InstrItinClass itin, list<dag> pattern>
    : VMX128Form<6, OOL, IOL, asmstr, itin, pattern>,
      RegConstraint<"$VDi = $VD"> {
  bits<7> VD;
  bits<7> VB;
  bits<2> z;

  let Inst{6...10} = VD{4...0};
  let Inst{16...20} = VB{4...0};
  let Inst{21...23} = xo;
  let Inst{24...25} = z;
  let Inst{26...27} = 0b01;
  let Inst{28} = VD{6};
  let Inst{29} = VD{5};
  let Inst{30} = VB{6};
  let Inst{31} = VB{5};
}

// vpermwi128: an 8-bit immediate split across bits 11-15 and 23-25.
class VX128Form_P<dag OOL, dag IOL, string asmstr, InstrItinClass itin,
                  list<dag> pattern>
    : VMX128Form<6, OOL, IOL, asmstr, itin, pattern> {
  bits<7> VD;
  bits<7> VB;
  bits<8> PERM;

  let Inst{6...10} = VD{4...0};
  let Inst{11...15} = PERM{4...0};
  let Inst{16...20} = VB{4...0};
  let Inst{21...22} = 0b01;
  let Inst{23...25} = PERM{7...5};
  let Inst{26...27} = 0b01;
  let Inst{28} = VD{6};
  let Inst{29} = VD{5};
  let Inst{30} = VB{6};
  let Inst{31} = VB{5};
}

class VX128_VD_VA_VB<bits<6> opcode, bits<5> xo, string opc,
                     InstrItinClass itin>
    : VX128Form<opcode, xo, (outs vrrc128:$VD),
                (ins vrrc128:$VA, vrrc128:$VB),
                !strconcat(opc, " $VD, $VA, $VB"), itin, []>;

// Destructive forms that print the tied destination a second time, as the
// last operand.
class VX128_VD_VA_VB_VD<bits<5> xo, string opc, InstrItinClass itin>
    : VX128Form<5, xo, (outs vrrc128:$VD),
                (ins vrrc128:$VA, vrrc128:$VB, vrrc128:$VDi),
                !strconcat(opc, " $VD, $VA, $VB, $VDi"), itin, []>,
      RegConstraint<"$VDi = $VD">;

class VCMP128<bits<5> xo, string opc>
    : VX128_VD_VA_VB<6, xo, opc, IIC_VecFPCompare>;
class VCMP128_rec<bits<5> xo, string opc>
    : VX128_VD_VA_VB<6, xo, opc, IIC_VecFPCompare> {
  let Defs = [CR6];
  let Inst{25} = 1;
}

class VX128_VD_VB_UIMM<bits<7> xo, string opc, InstrItinClass itin>
    : VX128Form_3<xo, (outs vrrc128:$VD), (ins vrrc128:$VB, u5imm:$IMM),
                  !strconcat(opc, " $VD, $VB, $IMM"), itin, []>;

// The low-register partial memory instructions are also available when an
// Xbox 360 function uses only the classic AltiVec register file.
def HasXenonVectorISA
    : Predicate<"Subtarget->hasXenonVectorISA()">,
      AssemblerPredicate<(any_of FeatureVMX128,
                          (all_of FeatureXbox360, FeatureAltivec)),
                         "vmx128 or xbox360 altivec">;

let DecoderNamespace = "VMX128", Predicates = [HasVMX128],
    hasSideEffects = 0 in {

let PPC970_Unit = 2, mayLoad = 1, mayStore = 0 in {
def LVSL128   : VX128Form_1<0, (outs vrrc128:$VD), (ins (memrr $RA, $RB):$addr),
                            "lvsl128 $VD, $addr", IIC_LdStLoad, []>;
def LVSR128   : VX128Form_1<1, (outs vrrc128:$VD), (ins (memrr $RA, $RB):$addr),
                            "lvsr128 $VD, $addr", IIC_LdStLoad, []>;
def LVEWX128  : VX128Form_1<2, (outs vrrc128:$VD), (ins (memrr $RA, $RB):$addr),
                            "lvewx128 $VD, $addr", IIC_LdStLoad, []>;
def LVX128    : VX128Form_1<3, (outs vrrc128:$VD), (ins (memrr $RA, $RB):$addr),
                            "lvx128 $VD, $addr", IIC_LdStLoad, []>;
def LVXL128   : VX128Form_1<11, (outs vrrc128:$VD), (ins (memrr $RA, $RB):$addr),
                            "lvxl128 $VD, $addr", IIC_LdStLoad, []>;
def LVLX128   : VX128Form_1<16, (outs vrrc128:$VD), (ins (memrr $RA, $RB):$addr),
                            "lvlx128 $VD, $addr", IIC_LdStLoad, []>;
def LVRX128   : VX128Form_1<17, (outs vrrc128:$VD), (ins (memrr $RA, $RB):$addr),
                            "lvrx128 $VD, $addr", IIC_LdStLoad, []>;
def LVLXL128  : VX128Form_1<24, (outs vrrc128:$VD), (ins (memrr $RA, $RB):$addr),
                            "lvlxl128 $VD, $addr", IIC_LdStLoad, []>;
def LVRXL128  : VX128Form_1<25, (outs vrrc128:$VD), (ins (memrr $RA, $RB):$addr),
                            "lvrxl128 $VD, $addr", IIC_LdStLoad, []>;
}

let PPC970_Unit = 2, mayLoad = 0, mayStore = 1 in {
def STVEWX128 : VX128Form_1<6, (outs), (ins vrrc128:$VD, (memrr $RA, $RB):$addr),
                            "stvewx128 $VD, $addr", IIC_LdStStore, []>;
def STVX128   : VX128Form_1<7, (outs), (ins vrrc128:$VD, (memrr $RA, $RB):$addr),
                            "stvx128 $VD, $addr", IIC_LdStStore, []>;
def STVXL128  : VX128Form_1<15, (outs), (ins vrrc128:$VD, (memrr $RA, $RB):$addr),
                            "stvxl128 $VD, $addr", IIC_LdStStore, []>;
def STVLX128  : VX128Form_1<20, (outs), (ins vrrc128:$VD, (memrr $RA, $RB):$addr),
                            "stvlx128 $VD, $addr", IIC_LdStStore, []>;
def STVRX128  : VX128Form_1<21, (outs), (ins vrrc128:$VD, (memrr $RA, $RB):$addr),
                            "stvrx128 $VD, $addr", IIC_LdStStore, []>;
def STVLXL128 : VX128Form_1<28, (outs), (ins vrrc128:$VD, (memrr $RA, $RB):$addr),
                            "stvlxl128 $VD, $addr", IIC_LdStStore, []>;
def STVRXL128 : VX128Form_1<29, (outs), (ins vrrc128:$VD, (memrr $RA, $RB):$addr),
                            "stvrxl128 $VD, $addr", IIC_LdStStore, []>;
}

let PPC970_Unit = 5 in { // VALU operations.
let isCommutable = 1 in {
def VADDFP128   : VX128_VD_VA_VB<5, 1, "vaddfp128", IIC_VecFP>;
def VMULFP128   : VX128_VD_VA_VB<5, 5, "vmulfp128", IIC_VecFP>;
def VMSUM3FP128 : VX128_VD_VA_VB<5, 13, "vmsum3fp128", IIC_VecFP>;
def VMSUM4FP128 : VX128_VD_VA_VB<5, 15, "vmsum4fp128", IIC_VecFP>;
def VAND128     : VX128_VD_VA_VB<5, 17, "vand128", IIC_VecGeneral>;
def VNOR128     : VX128_VD_VA_VB<5, 21, "vnor128", IIC_VecGeneral>;
def VOR128      : VX128_VD_VA_VB<5, 23, "vor128", IIC_VecGeneral>;
def VXOR128     : VX128_VD_VA_VB<5, 25, "vxor128", IIC_VecGeneral>;
def VMAXFP128   : VX128_VD_VA_VB<6, 20, "vmaxfp128", IIC_VecFP>;
def VMINFP128   : VX128_VD_VA_VB<6, 22, "vminfp128", IIC_VecFP>;
// vD = vA * vB + vD and vD = -(vA * vB - vD).
def VMADDFP128  : VX128_VD_VA_VB_VD<7, "vmaddfp128", IIC_VecFP>;
def VNMSUBFP128 : VX128_VD_VA_VB_VD<11, "vnmsubfp128", IIC_VecFP>;
}
def VSUBFP128   : VX128_VD_VA_VB<5, 3, "vsubfp128", IIC_VecFP>;
def VANDC128    : VX128_VD_VA_VB<5, 19, "vandc128", IIC_VecGeneral>;
def VSLO128     : VX128_VD_VA_VB<5, 29, "vslo128", IIC_VecPerm>;
def VSRO128     : VX128_VD_VA_VB<5, 31, "vsro128", IIC_VecPerm>;
def VRLW128     : VX128_VD_VA_VB<6, 3, "vrlw128", IIC_VecGeneral>;
def VSLW128     : VX128_VD_VA_VB<6, 7, "vslw128", IIC_VecGeneral>;
def VSRAW128    : VX128_VD_VA_VB<6, 11, "vsraw128", IIC_VecGeneral>;
def VSRW128     : VX128_VD_VA_VB<6, 15, "vsrw128", IIC_VecGeneral>;

// vD = vA * vD + vB: the multiplicand is the tied destination.
def VMADDCFP128 : VX128Form<5, 9, (outs vrrc128:$VD),
                            (ins vrrc128:$VA, vrrc128:$VDi, vrrc128:$VB),
                            "vmaddcfp128 $VD, $VA, $VDi, $VB", IIC_VecFP, []>,
                  RegConstraint<"$VDi = $VD">;
// The select mask is the tied destination.
def VSEL128     : VX128_VD_VA_VB_VD<27, "vsel128", IIC_VecGeneral>;

def VCMPEQFP128     : VCMP128<0, "vcmpeqfp128">;
def VCMPEQFP128_rec : VCMP128_rec<0, "vcmpeqfp128.">;
def VCMPGEFP128     : VCMP128<4, "vcmpgefp128">;
def VCMPGEFP128_rec : VCMP128_rec<4, "vcmpgefp128.">;
def VCMPGTFP128     : VCMP128<8, "vcmpgtfp128">;
def VCMPGTFP128_rec : VCMP128_rec<8, "vcmpgtfp128.">;
def VCMPBFP128      : VCMP128<12, "vcmpbfp128">;
def VCMPBFP128_rec  : VCMP128_rec<12, "vcmpbfp128.">;
def VCMPEQUW128     : VCMP128<16, "vcmpequw128">;
def VCMPEQUW128_rec : VCMP128_rec<16, "vcmpequw128.">;

def VCFPSXWS128 : VX128_VD_VB_UIMM<0x23, "vcfpsxws128", IIC_VecFP>;
def VCFPUXWS128 : VX128_VD_VB_UIMM<0x27, "vcfpuxws128", IIC_VecFP>;
def VCSXWFP128  : VX128_VD_VB_UIMM<0x2B, "vcsxwfp128", IIC_VecFP>;
def VCUXWFP128  : VX128_VD_VB_UIMM<0x2F, "vcuxwfp128", IIC_VecFP>;

def VRFIM128     : VX128Form_3_unary<0x33, "vrfim128", IIC_VecFP>;
def VRFIN128     : VX128Form_3_unary<0x37, "vrfin128", IIC_VecFP>;
def VRFIP128     : VX128Form_3_unary<0x3B, "vrfip128", IIC_VecFP>;
def VRFIZ128     : VX128Form_3_unary<0x3F, "vrfiz128", IIC_VecFP>;
def VREFP128     : VX128Form_3_unary<0x63, "vrefp128", IIC_VecFP>;
def VRSQRTEFP128 : VX128Form_3_unary<0x67, "vrsqrtefp128", IIC_VecFP>;
def VEXPTEFP128  : VX128Form_3_unary<0x6B, "vexptefp128", IIC_VecFP>;
def VLOGEFP128   : VX128Form_3_unary<0x6F, "vlogefp128", IIC_VecFP>;
} // PPC970_Unit = 5

let PPC970_Unit = 6 in { // VPERM operations.
def VSLDOI128 : VX128Form_5<(outs vrrc128:$VD),
                            (ins vrrc128:$VA, vrrc128:$VB, u4imm:$SHB),
                            "vsldoi128 $VD, $VA, $VB, $SHB", IIC_VecPerm, []>;
def VPERM128  : VX128Form_2<(outs vrrc128:$VD),
                            (ins vrrc128:$VA, vrrc128:$VB, vrrc0_7:$VC),
                            "vperm128 $VD, $VA, $VB, $VC", IIC_VecPerm, []>;

def VPKSHSS128 : VX128_VD_VA_VB<5, 16, "vpkshss128", IIC_VecPerm>;
def VPKSHUS128 : VX128_VD_VA_VB<5, 18, "vpkshus128", IIC_VecPerm>;
def VPKSWSS128 : VX128_VD_VA_VB<5, 20, "vpkswss128", IIC_VecPerm>;
def VPKSWUS128 : VX128_VD_VA_VB<5, 22, "vpkswus128", IIC_VecPerm>;
def VPKUHUM128 : VX128_VD_VA_VB<5, 24, "vpkuhum128", IIC_VecPerm>;
def VPKUHUS128 : VX128_VD_VA_VB<5, 26, "vpkuhus128", IIC_VecPerm>;
def VPKUWUM128 : VX128_VD_VA_VB<5, 28, "vpkuwum128", IIC_VecPerm>;
def VPKUWUS128 : VX128_VD_VA_VB<5, 30, "vpkuwus128", IIC_VecPerm>;
def VMRGHW128  : VX128_VD_VA_VB<6, 24, "vmrghw128", IIC_VecPerm>;
def VMRGLW128  : VX128_VD_VA_VB<6, 26, "vmrglw128", IIC_VecPerm>;

def VUPKHSB128 : VX128Form_3_unary<0x38, "vupkhsb128", IIC_VecPerm>;
def VUPKLSB128 : VX128Form_3_unary<0x3C, "vupklsb128", IIC_VecPerm>;
def VUPKHSH128 : VX128Form_3_unary<0x7A, "vupkhsh128", IIC_VecPerm>;
def VUPKLSH128 : VX128Form_3_unary<0x7E, "vupklsh128", IIC_VecPerm>;

def VSPLTW128 : VX128_VD_VB_UIMM<0x73, "vspltw128", IIC_VecPerm>;
// Decoders ignore the vB field.
def VSPLTISW128 : VX128Form_3<0x77, (outs vrrc128:$VD), (ins s5imm:$IMM),
                              "vspltisw128 $VD, $IMM", IIC_VecPerm, []> {
  let VB = 0;
  let SoftFail{15...11} = 0b11111;
  let SoftFail{1...0} = 0b11;
}

def VPERMWI128 : VX128Form_P<(outs vrrc128:$VD), (ins vrrc128:$VB, u8imm:$PERM),
                             "vpermwi128 $VD, $VB, $PERM", IIC_VecPerm, []>;

// Rotate vB left by z words and insert the words selected by IMM into vD.
def VRLIMI128 : VX128Form_4<0b111, (outs vrrc128:$VD),
                            (ins vrrc128:$VDi, vrrc128:$VB, u4imm:$IMM,
                                 u2imm:$z),
                            "vrlimi128 $VD, $VB, $IMM, $z", IIC_VecPerm, []> {
  bits<4> IMM;

  // Decoders ignore bit 11.
  let Inst{11} = 0;
  let SoftFail{20} = 1;
  let Inst{12...15} = IMM;
}

// Pack vB as data type TYPE, rotate by z words and insert the words selected
// by MASK into vD.
def VPKD3D128 : VX128Form_4<0b110, (outs vrrc128:$VD),
                            (ins vrrc128:$VDi, vrrc128:$VB, u3imm:$TYPE,
                                 u2imm:$MASK, u2imm:$z),
                            "vpkd3d128 $VD, $VB, $TYPE, $MASK, $z",
                            IIC_VecPerm, []> {
  bits<3> TYPE;
  bits<2> MASK;

  let Inst{11...13} = TYPE;
  let Inst{14...15} = MASK;
}

// Unpack vB as data type TYPE. Decoders ignore bits 14-15.
def VUPKD3D128 : VX128Form_3<0x7F, (outs vrrc128:$VD),
                             (ins vrrc128:$VB, u3imm:$TYPE),
                             "vupkd3d128 $VD, $VB, $TYPE", IIC_VecPerm, []> {
  bits<3> TYPE;

  let IMM = {TYPE, 0b00};
  let SoftFail{17...16} = 0b11;
}
} // PPC970_Unit = 6

// Xenon left/right vector loads and stores. These name v0-v31 and also exist
// without the 128-register file.
let Predicates = [HasXenonVectorISA] in {
let PPC970_Unit = 2, mayLoad = 1, mayStore = 0 in {
def LVLX  : XForm_1_memOp<31, 519, (outs vrrc:$RST), (ins (memrr $RA, $RB):$addr),
                          "lvlx $RST, $addr", IIC_LdStLoad, []>;
def LVRX  : XForm_1_memOp<31, 551, (outs vrrc:$RST), (ins (memrr $RA, $RB):$addr),
                          "lvrx $RST, $addr", IIC_LdStLoad, []>;
def LVLXL : XForm_1_memOp<31, 775, (outs vrrc:$RST), (ins (memrr $RA, $RB):$addr),
                          "lvlxl $RST, $addr", IIC_LdStLoad, []>;
def LVRXL : XForm_1_memOp<31, 807, (outs vrrc:$RST), (ins (memrr $RA, $RB):$addr),
                          "lvrxl $RST, $addr", IIC_LdStLoad, []>;
}

let PPC970_Unit = 2, mayLoad = 0, mayStore = 1 in {
def STVLX  : XForm_8_memOp<31, 647, (outs), (ins vrrc:$RST, (memrr $RA, $RB):$addr),
                           "stvlx $RST, $addr", IIC_LdStStore, []>;
def STVRX  : XForm_8_memOp<31, 679, (outs), (ins vrrc:$RST, (memrr $RA, $RB):$addr),
                           "stvrx $RST, $addr", IIC_LdStStore, []>;
def STVLXL : XForm_8_memOp<31, 903, (outs), (ins vrrc:$RST, (memrr $RA, $RB):$addr),
                           "stvlxl $RST, $addr", IIC_LdStStore, []>;
def STVRXL : XForm_8_memOp<31, 935, (outs), (ins vrrc:$RST, (memrr $RA, $RB):$addr),
                           "stvrxl $RST, $addr", IIC_LdStStore, []>;
}
} // Predicates = [HasXenonVectorISA]
} // DecoderNamespace = "VMX128", Predicates = [HasVMX128], hasSideEffects = 0
