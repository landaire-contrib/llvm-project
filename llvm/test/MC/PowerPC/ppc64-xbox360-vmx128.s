# RUN: llvm-mc -triple powerpc64-unknown-xbox360-ilp32 --show-encoding \
# RUN:   -ppc-reg-with-percent-prefix %s | FileCheck %s
# RUN: llvm-mc -triple powerpc-unknown-xbox360 -mattr=+vmx128 --show-encoding \
# RUN:   -ppc-reg-with-percent-prefix %s | FileCheck %s

# Every VMX128 instruction and Xenon vector X-form, with each split of the
# register number high bits and the immediate extremes. Loads and stores
# encode bit 30 as 1.

# CHECK: lvsl128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf0,0x0f]
         lvsl128 %v127, %r31, %r30
# CHECK: lvsl128 %v0, 0, %r1 # encoding: [0x10,0x00,0x08,0x03]
         lvsl128 %v0, 0, %r1
# CHECK: lvsl128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x60,0x07]
         lvsl128 %v33, %r3, %r12
# CHECK: lvsl128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xf8,0x0b]
         lvsl128 %v94, %r11, %r31
# CHECK: lvsr128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf0,0x4f]
         lvsr128 %v127, %r31, %r30
# CHECK: lvsr128 %v0, 0, %r1 # encoding: [0x10,0x00,0x08,0x43]
         lvsr128 %v0, 0, %r1
# CHECK: lvsr128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x60,0x47]
         lvsr128 %v33, %r3, %r12
# CHECK: lvsr128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xf8,0x4b]
         lvsr128 %v94, %r11, %r31
# CHECK: lvewx128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf0,0x8f]
         lvewx128 %v127, %r31, %r30
# CHECK: lvewx128 %v0, 0, %r1 # encoding: [0x10,0x00,0x08,0x83]
         lvewx128 %v0, 0, %r1
# CHECK: lvewx128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x60,0x87]
         lvewx128 %v33, %r3, %r12
# CHECK: lvewx128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xf8,0x8b]
         lvewx128 %v94, %r11, %r31
# CHECK: lvewx128 %v127, %r7, %r3 # encoding: [0x13,0xe7,0x18,0x8f]
         lvewx128 %v127, %r7, %r3
# CHECK: lvewx128 %v126, %r6, %r3 # encoding: [0x13,0xc6,0x18,0x8f]
         lvewx128 %v126, %r6, %r3
# CHECK: lvx128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf0,0xcf]
         lvx128 %v127, %r31, %r30
# CHECK: lvx128 %v0, 0, %r1 # encoding: [0x10,0x00,0x08,0xc3]
         lvx128 %v0, 0, %r1
# CHECK: lvx128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x60,0xc7]
         lvx128 %v33, %r3, %r12
# CHECK: lvx128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xf8,0xcb]
         lvx128 %v94, %r11, %r31
# CHECK: lvx128 %v127, %r7, %r3 # encoding: [0x13,0xe7,0x18,0xcf]
         lvx128 %v127, %r7, %r3
# CHECK: lvx128 %v126, %r6, %r3 # encoding: [0x13,0xc6,0x18,0xcf]
         lvx128 %v126, %r6, %r3
# CHECK: lvx128 %v12, 0, %r11 # encoding: [0x11,0x80,0x58,0xc3]
         lvx128 %v12, 0, %r11
# CHECK: lvx128 %v11, 0, %r11 # encoding: [0x11,0x60,0x58,0xc3]
         lvx128 %v11, 0, %r11
# CHECK: stvewx128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf1,0x8f]
         stvewx128 %v127, %r31, %r30
# CHECK: stvewx128 %v0, 0, %r1 # encoding: [0x10,0x00,0x09,0x83]
         stvewx128 %v0, 0, %r1
# CHECK: stvewx128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x61,0x87]
         stvewx128 %v33, %r3, %r12
# CHECK: stvewx128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xf9,0x8b]
         stvewx128 %v94, %r11, %r31
# CHECK: stvewx128 %v110, %r4, %r7 # encoding: [0x11,0xc4,0x39,0x8f]
         stvewx128 %v110, %r4, %r7
# CHECK: stvewx128 %v127, %r4, %r11 # encoding: [0x13,0xe4,0x59,0x8f]
         stvewx128 %v127, %r4, %r11
# CHECK: stvx128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf1,0xcf]
         stvx128 %v127, %r31, %r30
# CHECK: stvx128 %v0, 0, %r1 # encoding: [0x10,0x00,0x09,0xc3]
         stvx128 %v0, 0, %r1
# CHECK: stvx128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x61,0xc7]
         stvx128 %v33, %r3, %r12
# CHECK: stvx128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xf9,0xcb]
         stvx128 %v94, %r11, %r31
# CHECK: stvx128 %v127, %r5, %r11 # encoding: [0x13,0xe5,0x59,0xcf]
         stvx128 %v127, %r5, %r11
# CHECK: stvx128 %v126, %r5, %r10 # encoding: [0x13,0xc5,0x51,0xcf]
         stvx128 %v126, %r5, %r10
# CHECK: stvx128 %v127, %r1, %r12 # encoding: [0x13,0xe1,0x61,0xcf]
         stvx128 %v127, %r1, %r12
# CHECK: stvx128 %v127, 0, %r31 # encoding: [0x13,0xe0,0xf9,0xcf]
         stvx128 %v127, 0, %r31
# CHECK: lvxl128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf2,0xcf]
         lvxl128 %v127, %r31, %r30
# CHECK: lvxl128 %v0, 0, %r1 # encoding: [0x10,0x00,0x0a,0xc3]
         lvxl128 %v0, 0, %r1
# CHECK: lvxl128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x62,0xc7]
         lvxl128 %v33, %r3, %r12
# CHECK: lvxl128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xfa,0xcb]
         lvxl128 %v94, %r11, %r31
# CHECK: lvxl128 %v32, %r5, %r11 # encoding: [0x10,0x05,0x5a,0xc7]
         lvxl128 %v32, %r5, %r11
# CHECK: lvxl128 %v33, %r7, %r11 # encoding: [0x10,0x27,0x5a,0xc7]
         lvxl128 %v33, %r7, %r11
# CHECK: stvxl128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf3,0xcf]
         stvxl128 %v127, %r31, %r30
# CHECK: stvxl128 %v0, 0, %r1 # encoding: [0x10,0x00,0x0b,0xc3]
         stvxl128 %v0, 0, %r1
# CHECK: stvxl128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x63,0xc7]
         stvxl128 %v33, %r3, %r12
# CHECK: stvxl128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xfb,0xcb]
         stvxl128 %v94, %r11, %r31
# CHECK: lvlx128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf4,0x0f]
         lvlx128 %v127, %r31, %r30
# CHECK: lvlx128 %v0, 0, %r1 # encoding: [0x10,0x00,0x0c,0x03]
         lvlx128 %v0, 0, %r1
# CHECK: lvlx128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x64,0x07]
         lvlx128 %v33, %r3, %r12
# CHECK: lvlx128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xfc,0x0b]
         lvlx128 %v94, %r11, %r31
# CHECK: lvlx128 %v127, %r7, %r3 # encoding: [0x13,0xe7,0x1c,0x0f]
         lvlx128 %v127, %r7, %r3
# CHECK: lvlx128 %v126, %r6, %r3 # encoding: [0x13,0xc6,0x1c,0x0f]
         lvlx128 %v126, %r6, %r3
# CHECK: lvrx128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf4,0x4f]
         lvrx128 %v127, %r31, %r30
# CHECK: lvrx128 %v0, 0, %r1 # encoding: [0x10,0x00,0x0c,0x43]
         lvrx128 %v0, 0, %r1
# CHECK: lvrx128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x64,0x47]
         lvrx128 %v33, %r3, %r12
# CHECK: lvrx128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xfc,0x4b]
         lvrx128 %v94, %r11, %r31
# CHECK: lvrx128 %v127, %r7, %r3 # encoding: [0x13,0xe7,0x1c,0x4f]
         lvrx128 %v127, %r7, %r3
# CHECK: lvrx128 %v126, %r6, %r3 # encoding: [0x13,0xc6,0x1c,0x4f]
         lvrx128 %v126, %r6, %r3
# CHECK: stvlx128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf5,0x0f]
         stvlx128 %v127, %r31, %r30
# CHECK: stvlx128 %v0, 0, %r1 # encoding: [0x10,0x00,0x0d,0x03]
         stvlx128 %v0, 0, %r1
# CHECK: stvlx128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x65,0x07]
         stvlx128 %v33, %r3, %r12
# CHECK: stvlx128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xfd,0x0b]
         stvlx128 %v94, %r11, %r31
# CHECK: stvlx128 %v110, %r4, %r7 # encoding: [0x11,0xc4,0x3d,0x0f]
         stvlx128 %v110, %r4, %r7
# CHECK: stvlx128 %v127, %r4, %r11 # encoding: [0x13,0xe4,0x5d,0x0f]
         stvlx128 %v127, %r4, %r11
# CHECK: stvrx128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf5,0x4f]
         stvrx128 %v127, %r31, %r30
# CHECK: stvrx128 %v0, 0, %r1 # encoding: [0x10,0x00,0x0d,0x43]
         stvrx128 %v0, 0, %r1
# CHECK: stvrx128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x65,0x47]
         stvrx128 %v33, %r3, %r12
# CHECK: stvrx128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xfd,0x4b]
         stvrx128 %v94, %r11, %r31
# CHECK: stvrx128 %v110, %r4, %r7 # encoding: [0x11,0xc4,0x3d,0x4f]
         stvrx128 %v110, %r4, %r7
# CHECK: stvrx128 %v127, %r4, %r11 # encoding: [0x13,0xe4,0x5d,0x4f]
         stvrx128 %v127, %r4, %r11
# CHECK: lvlxl128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf6,0x0f]
         lvlxl128 %v127, %r31, %r30
# CHECK: lvlxl128 %v0, 0, %r1 # encoding: [0x10,0x00,0x0e,0x03]
         lvlxl128 %v0, 0, %r1
# CHECK: lvlxl128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x66,0x07]
         lvlxl128 %v33, %r3, %r12
# CHECK: lvlxl128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xfe,0x0b]
         lvlxl128 %v94, %r11, %r31
# CHECK: lvrxl128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf6,0x4f]
         lvrxl128 %v127, %r31, %r30
# CHECK: lvrxl128 %v0, 0, %r1 # encoding: [0x10,0x00,0x0e,0x43]
         lvrxl128 %v0, 0, %r1
# CHECK: lvrxl128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x66,0x47]
         lvrxl128 %v33, %r3, %r12
# CHECK: lvrxl128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xfe,0x4b]
         lvrxl128 %v94, %r11, %r31
# CHECK: stvlxl128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf7,0x0f]
         stvlxl128 %v127, %r31, %r30
# CHECK: stvlxl128 %v0, 0, %r1 # encoding: [0x10,0x00,0x0f,0x03]
         stvlxl128 %v0, 0, %r1
# CHECK: stvlxl128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x67,0x07]
         stvlxl128 %v33, %r3, %r12
# CHECK: stvlxl128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xff,0x0b]
         stvlxl128 %v94, %r11, %r31
# CHECK: stvlxl128 %v32, %r3, %r11 # encoding: [0x10,0x03,0x5f,0x07]
         stvlxl128 %v32, %r3, %r11
# CHECK: stvlxl128 %v33, %r7, %r11 # encoding: [0x10,0x27,0x5f,0x07]
         stvlxl128 %v33, %r7, %r11
# CHECK: stvrxl128 %v127, %r31, %r30 # encoding: [0x13,0xff,0xf7,0x4f]
         stvrxl128 %v127, %r31, %r30
# CHECK: stvrxl128 %v0, 0, %r1 # encoding: [0x10,0x00,0x0f,0x43]
         stvrxl128 %v0, 0, %r1
# CHECK: stvrxl128 %v33, %r3, %r12 # encoding: [0x10,0x23,0x67,0x47]
         stvrxl128 %v33, %r3, %r12
# CHECK: stvrxl128 %v94, %r11, %r31 # encoding: [0x13,0xcb,0xff,0x4b]
         stvrxl128 %v94, %r11, %r31
# CHECK: vsldoi128 %v127, %v126, %v65, 15 # encoding: [0x13,0xfe,0x0f,0xfe]
         vsldoi128 %v127, %v126, %v65, 15
# CHECK: vsldoi128 %v0, %v127, %v96, 1 # encoding: [0x10,0x1f,0x04,0x73]
         vsldoi128 %v0, %v127, %v96, 1
# CHECK: vsldoi128 %v33, %v64, %v31, 8 # encoding: [0x10,0x20,0xfe,0x14]
         vsldoi128 %v33, %v64, %v31, 8
# CHECK: vsldoi128 %v94, %v33, %v126, 4 # encoding: [0x13,0xc1,0xf1,0x3b]
         vsldoi128 %v94, %v33, %v126, 4
# CHECK: vsldoi128 %v109, %v63, %v5, 0 # encoding: [0x11,0xbf,0x28,0x3c]
         vsldoi128 %v109, %v63, %v5, 0
# CHECK: vsldoi128 %v108, %v37, %v4, 1 # encoding: [0x11,0x85,0x20,0x7c]
         vsldoi128 %v108, %v37, %v4, 1
# CHECK: vsldoi128 %v33, %v83, %v88, 3 # encoding: [0x10,0x33,0xc4,0xd6]
         vsldoi128 %v33, %v83, %v88, 3
# CHECK: vaddfp128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0c,0x3e]
         vaddfp128 %v127, %v126, %v65
# CHECK: vaddfp128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x04,0x33]
         vaddfp128 %v0, %v127, %v96
# CHECK: vaddfp128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfc,0x14]
         vaddfp128 %v33, %v64, %v31
# CHECK: vaddfp128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf0,0x3b]
         vaddfp128 %v94, %v33, %v126
# CHECK: vaddfp128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x28,0x3c]
         vaddfp128 %v109, %v63, %v5
# CHECK: vaddfp128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x20,0x3c]
         vaddfp128 %v108, %v37, %v4
# CHECK: vaddfp128 %v0, %v0, %v127 # encoding: [0x14,0x00,0xf8,0x13]
         vaddfp128 %v0, %v0, %v127
# CHECK: vsubfp128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0c,0x7e]
         vsubfp128 %v127, %v126, %v65
# CHECK: vsubfp128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x04,0x73]
         vsubfp128 %v0, %v127, %v96
# CHECK: vsubfp128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfc,0x54]
         vsubfp128 %v33, %v64, %v31
# CHECK: vsubfp128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf0,0x7b]
         vsubfp128 %v94, %v33, %v126
# CHECK: vsubfp128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x28,0x7c]
         vsubfp128 %v109, %v63, %v5
# CHECK: vsubfp128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x20,0x7c]
         vsubfp128 %v108, %v37, %v4
# CHECK: vmulfp128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0c,0xbe]
         vmulfp128 %v127, %v126, %v65
# CHECK: vmulfp128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x04,0xb3]
         vmulfp128 %v0, %v127, %v96
# CHECK: vmulfp128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfc,0x94]
         vmulfp128 %v33, %v64, %v31
# CHECK: vmulfp128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf0,0xbb]
         vmulfp128 %v94, %v33, %v126
# CHECK: vmulfp128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x28,0xbc]
         vmulfp128 %v109, %v63, %v5
# CHECK: vmulfp128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x20,0xbc]
         vmulfp128 %v108, %v37, %v4
# CHECK: vmulfp128 %v9, %v0, %v0 # encoding: [0x15,0x20,0x00,0x90]
         vmulfp128 %v9, %v0, %v0
# CHECK: vmulfp128 %v0, %v9, %v13 # encoding: [0x14,0x09,0x68,0x90]
         vmulfp128 %v0, %v9, %v13
# CHECK: vmsum3fp128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0d,0xbe]
         vmsum3fp128 %v127, %v126, %v65
# CHECK: vmsum3fp128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x05,0xb3]
         vmsum3fp128 %v0, %v127, %v96
# CHECK: vmsum3fp128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfd,0x94]
         vmsum3fp128 %v33, %v64, %v31
# CHECK: vmsum3fp128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf1,0xbb]
         vmsum3fp128 %v94, %v33, %v126
# CHECK: vmsum3fp128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x29,0xbc]
         vmsum3fp128 %v109, %v63, %v5
# CHECK: vmsum3fp128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x21,0xbc]
         vmsum3fp128 %v108, %v37, %v4
# CHECK: vmsum4fp128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0d,0xfe]
         vmsum4fp128 %v127, %v126, %v65
# CHECK: vmsum4fp128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x05,0xf3]
         vmsum4fp128 %v0, %v127, %v96
# CHECK: vmsum4fp128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfd,0xd4]
         vmsum4fp128 %v33, %v64, %v31
# CHECK: vmsum4fp128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf1,0xfb]
         vmsum4fp128 %v94, %v33, %v126
# CHECK: vmsum4fp128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x29,0xfc]
         vmsum4fp128 %v109, %v63, %v5
# CHECK: vmsum4fp128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x21,0xfc]
         vmsum4fp128 %v108, %v37, %v4
# CHECK: vmsum4fp128 %v10, %v0, %v10 # encoding: [0x15,0x40,0x51,0xd0]
         vmsum4fp128 %v10, %v0, %v10
# CHECK: vmsum4fp128 %v0, %v0, %v12 # encoding: [0x14,0x00,0x61,0xd0]
         vmsum4fp128 %v0, %v0, %v12
# CHECK: vpkshss128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0e,0x2e]
         vpkshss128 %v127, %v126, %v65
# CHECK: vpkshss128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x06,0x23]
         vpkshss128 %v0, %v127, %v96
# CHECK: vpkshss128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfe,0x04]
         vpkshss128 %v33, %v64, %v31
# CHECK: vpkshss128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf2,0x2b]
         vpkshss128 %v94, %v33, %v126
# CHECK: vpkshss128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2a,0x2c]
         vpkshss128 %v109, %v63, %v5
# CHECK: vpkshss128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x22,0x2c]
         vpkshss128 %v108, %v37, %v4
# CHECK: vand128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0e,0x3e]
         vand128 %v127, %v126, %v65
# CHECK: vand128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x06,0x33]
         vand128 %v0, %v127, %v96
# CHECK: vand128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfe,0x14]
         vand128 %v33, %v64, %v31
# CHECK: vand128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf2,0x3b]
         vand128 %v94, %v33, %v126
# CHECK: vand128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2a,0x3c]
         vand128 %v109, %v63, %v5
# CHECK: vand128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x22,0x3c]
         vand128 %v108, %v37, %v4
# CHECK: vand128 %v6, %v123, %v7 # encoding: [0x14,0xdb,0x3e,0x30]
         vand128 %v6, %v123, %v7
# CHECK: vand128 %v4, %v4, %v124 # encoding: [0x14,0x84,0xe2,0x13]
         vand128 %v4, %v4, %v124
# CHECK: vpkshus128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0e,0x6e]
         vpkshus128 %v127, %v126, %v65
# CHECK: vpkshus128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x06,0x63]
         vpkshus128 %v0, %v127, %v96
# CHECK: vpkshus128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfe,0x44]
         vpkshus128 %v33, %v64, %v31
# CHECK: vpkshus128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf2,0x6b]
         vpkshus128 %v94, %v33, %v126
# CHECK: vpkshus128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2a,0x6c]
         vpkshus128 %v109, %v63, %v5
# CHECK: vpkshus128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x22,0x6c]
         vpkshus128 %v108, %v37, %v4
# CHECK: vandc128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0e,0x7e]
         vandc128 %v127, %v126, %v65
# CHECK: vandc128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x06,0x73]
         vandc128 %v0, %v127, %v96
# CHECK: vandc128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfe,0x54]
         vandc128 %v33, %v64, %v31
# CHECK: vandc128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf2,0x7b]
         vandc128 %v94, %v33, %v126
# CHECK: vandc128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2a,0x7c]
         vandc128 %v109, %v63, %v5
# CHECK: vandc128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x22,0x7c]
         vandc128 %v108, %v37, %v4
# CHECK: vandc128 %v11, %v123, %v7 # encoding: [0x15,0x7b,0x3e,0x70]
         vandc128 %v11, %v123, %v7
# CHECK: vpkswss128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0e,0xae]
         vpkswss128 %v127, %v126, %v65
# CHECK: vpkswss128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x06,0xa3]
         vpkswss128 %v0, %v127, %v96
# CHECK: vpkswss128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfe,0x84]
         vpkswss128 %v33, %v64, %v31
# CHECK: vpkswss128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf2,0xab]
         vpkswss128 %v94, %v33, %v126
# CHECK: vpkswss128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2a,0xac]
         vpkswss128 %v109, %v63, %v5
# CHECK: vpkswss128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x22,0xac]
         vpkswss128 %v108, %v37, %v4
# CHECK: vnor128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0e,0xbe]
         vnor128 %v127, %v126, %v65
# CHECK: vnor128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x06,0xb3]
         vnor128 %v0, %v127, %v96
# CHECK: vnor128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfe,0x94]
         vnor128 %v33, %v64, %v31
# CHECK: vnor128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf2,0xbb]
         vnor128 %v94, %v33, %v126
# CHECK: vnor128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2a,0xbc]
         vnor128 %v109, %v63, %v5
# CHECK: vnor128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x22,0xbc]
         vnor128 %v108, %v37, %v4
# CHECK: vpkswus128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0e,0xee]
         vpkswus128 %v127, %v126, %v65
# CHECK: vpkswus128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x06,0xe3]
         vpkswus128 %v0, %v127, %v96
# CHECK: vpkswus128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfe,0xc4]
         vpkswus128 %v33, %v64, %v31
# CHECK: vpkswus128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf2,0xeb]
         vpkswus128 %v94, %v33, %v126
# CHECK: vpkswus128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2a,0xec]
         vpkswus128 %v109, %v63, %v5
# CHECK: vpkswus128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x22,0xec]
         vpkswus128 %v108, %v37, %v4
# CHECK: vor128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0e,0xfe]
         vor128 %v127, %v126, %v65
# CHECK: vor128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x06,0xf3]
         vor128 %v0, %v127, %v96
# CHECK: vor128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xfe,0xd4]
         vor128 %v33, %v64, %v31
# CHECK: vor128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf2,0xfb]
         vor128 %v94, %v33, %v126
# CHECK: vor128 %v127, %v14, %v14 # encoding: [0x17,0xee,0x72,0xdc]
         vor128 %v127, %v14, %v14
# CHECK: vor128 %v126, %v14, %v14 # encoding: [0x17,0xce,0x72,0xdc]
         vor128 %v126, %v14, %v14
# CHECK: vor128 %v122, %v0, %v13 # encoding: [0x17,0x40,0x6a,0xdc]
         vor128 %v122, %v0, %v13
# CHECK: vor128 %v123, %v0, %v13 # encoding: [0x17,0x60,0x6a,0xdc]
         vor128 %v123, %v0, %v13
# CHECK: vpkuhum128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0f,0x2e]
         vpkuhum128 %v127, %v126, %v65
# CHECK: vpkuhum128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x07,0x23]
         vpkuhum128 %v0, %v127, %v96
# CHECK: vpkuhum128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xff,0x04]
         vpkuhum128 %v33, %v64, %v31
# CHECK: vpkuhum128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf3,0x2b]
         vpkuhum128 %v94, %v33, %v126
# CHECK: vpkuhum128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2b,0x2c]
         vpkuhum128 %v109, %v63, %v5
# CHECK: vpkuhum128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x23,0x2c]
         vpkuhum128 %v108, %v37, %v4
# CHECK: vxor128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0f,0x3e]
         vxor128 %v127, %v126, %v65
# CHECK: vxor128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x07,0x33]
         vxor128 %v0, %v127, %v96
# CHECK: vxor128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xff,0x14]
         vxor128 %v33, %v64, %v31
# CHECK: vxor128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf3,0x3b]
         vxor128 %v94, %v33, %v126
# CHECK: vxor128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2b,0x3c]
         vxor128 %v109, %v63, %v5
# CHECK: vxor128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x23,0x3c]
         vxor128 %v108, %v37, %v4
# CHECK: vpkuhus128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0f,0x6e]
         vpkuhus128 %v127, %v126, %v65
# CHECK: vpkuhus128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x07,0x63]
         vpkuhus128 %v0, %v127, %v96
# CHECK: vpkuhus128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xff,0x44]
         vpkuhus128 %v33, %v64, %v31
# CHECK: vpkuhus128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf3,0x6b]
         vpkuhus128 %v94, %v33, %v126
# CHECK: vpkuhus128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2b,0x6c]
         vpkuhus128 %v109, %v63, %v5
# CHECK: vpkuhus128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x23,0x6c]
         vpkuhus128 %v108, %v37, %v4
# CHECK: vpkuwum128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0f,0xae]
         vpkuwum128 %v127, %v126, %v65
# CHECK: vpkuwum128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x07,0xa3]
         vpkuwum128 %v0, %v127, %v96
# CHECK: vpkuwum128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xff,0x84]
         vpkuwum128 %v33, %v64, %v31
# CHECK: vpkuwum128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf3,0xab]
         vpkuwum128 %v94, %v33, %v126
# CHECK: vpkuwum128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2b,0xac]
         vpkuwum128 %v109, %v63, %v5
# CHECK: vpkuwum128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x23,0xac]
         vpkuwum128 %v108, %v37, %v4
# CHECK: vslo128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0f,0xbe]
         vslo128 %v127, %v126, %v65
# CHECK: vslo128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x07,0xb3]
         vslo128 %v0, %v127, %v96
# CHECK: vslo128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xff,0x94]
         vslo128 %v33, %v64, %v31
# CHECK: vslo128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf3,0xbb]
         vslo128 %v94, %v33, %v126
# CHECK: vslo128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2b,0xbc]
         vslo128 %v109, %v63, %v5
# CHECK: vslo128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x23,0xbc]
         vslo128 %v108, %v37, %v4
# CHECK: vpkuwus128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0f,0xee]
         vpkuwus128 %v127, %v126, %v65
# CHECK: vpkuwus128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x07,0xe3]
         vpkuwus128 %v0, %v127, %v96
# CHECK: vpkuwus128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xff,0xc4]
         vpkuwus128 %v33, %v64, %v31
# CHECK: vpkuwus128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf3,0xeb]
         vpkuwus128 %v94, %v33, %v126
# CHECK: vpkuwus128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2b,0xec]
         vpkuwus128 %v109, %v63, %v5
# CHECK: vpkuwus128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x23,0xec]
         vpkuwus128 %v108, %v37, %v4
# CHECK: vsro128 %v127, %v126, %v65 # encoding: [0x17,0xfe,0x0f,0xfe]
         vsro128 %v127, %v126, %v65
# CHECK: vsro128 %v0, %v127, %v96 # encoding: [0x14,0x1f,0x07,0xf3]
         vsro128 %v0, %v127, %v96
# CHECK: vsro128 %v33, %v64, %v31 # encoding: [0x14,0x20,0xff,0xd4]
         vsro128 %v33, %v64, %v31
# CHECK: vsro128 %v94, %v33, %v126 # encoding: [0x17,0xc1,0xf3,0xfb]
         vsro128 %v94, %v33, %v126
# CHECK: vsro128 %v109, %v63, %v5 # encoding: [0x15,0xbf,0x2b,0xfc]
         vsro128 %v109, %v63, %v5
# CHECK: vsro128 %v108, %v37, %v4 # encoding: [0x15,0x85,0x23,0xfc]
         vsro128 %v108, %v37, %v4
# CHECK: vmaddfp128 %v127, %v126, %v65, %v127 # encoding: [0x17,0xfe,0x0c,0xfe]
         vmaddfp128 %v127, %v126, %v65, %v127
# CHECK: vmaddfp128 %v0, %v127, %v96, %v0 # encoding: [0x14,0x1f,0x04,0xf3]
         vmaddfp128 %v0, %v127, %v96, %v0
# CHECK: vmaddfp128 %v33, %v64, %v31, %v33 # encoding: [0x14,0x20,0xfc,0xd4]
         vmaddfp128 %v33, %v64, %v31, %v33
# CHECK: vmaddfp128 %v94, %v33, %v126, %v94 # encoding: [0x17,0xc1,0xf0,0xfb]
         vmaddfp128 %v94, %v33, %v126, %v94
# CHECK: vmaddfp128 %v70, %v10, %v50, %v70 # encoding: [0x14,0xca,0x90,0xd9]
         vmaddfp128 %v70, %v10, %v50, %v70
# CHECK: vmaddfp128 %v67, %v5, %v45, %v67 # encoding: [0x14,0x65,0x68,0xd9]
         vmaddfp128 %v67, %v5, %v45, %v67
# CHECK: vmaddfp128 %v63, %v31, %v0, %v63 # encoding: [0x17,0xff,0x00,0xd4]
         vmaddfp128 %v63, %v31, %v0, %v63
# CHECK: vmaddcfp128 %v127, %v126, %v127, %v65 # encoding: [0x17,0xfe,0x0d,0x3e]
         vmaddcfp128 %v127, %v126, %v127, %v65
# CHECK: vmaddcfp128 %v0, %v127, %v0, %v96 # encoding: [0x14,0x1f,0x05,0x33]
         vmaddcfp128 %v0, %v127, %v0, %v96
# CHECK: vmaddcfp128 %v33, %v64, %v33, %v31 # encoding: [0x14,0x20,0xfd,0x14]
         vmaddcfp128 %v33, %v64, %v33, %v31
# CHECK: vmaddcfp128 %v94, %v33, %v94, %v126 # encoding: [0x17,0xc1,0xf1,0x3b]
         vmaddcfp128 %v94, %v33, %v94, %v126
# CHECK: vmaddcfp128 %v71, %v0, %v71, %v109 # encoding: [0x14,0xe0,0x69,0x1b]
         vmaddcfp128 %v71, %v0, %v71, %v109
# CHECK: vmaddcfp128 %v65, %v12, %v65, %v107 # encoding: [0x14,0x2c,0x59,0x1b]
         vmaddcfp128 %v65, %v12, %v65, %v107
# CHECK: vnmsubfp128 %v127, %v126, %v65, %v127 # encoding: [0x17,0xfe,0x0d,0x7e]
         vnmsubfp128 %v127, %v126, %v65, %v127
# CHECK: vnmsubfp128 %v0, %v127, %v96, %v0 # encoding: [0x14,0x1f,0x05,0x73]
         vnmsubfp128 %v0, %v127, %v96, %v0
# CHECK: vnmsubfp128 %v33, %v64, %v31, %v33 # encoding: [0x14,0x20,0xfd,0x54]
         vnmsubfp128 %v33, %v64, %v31, %v33
# CHECK: vnmsubfp128 %v94, %v33, %v126, %v94 # encoding: [0x17,0xc1,0xf1,0x7b]
         vnmsubfp128 %v94, %v33, %v126, %v94
# CHECK: vnmsubfp128 %v83, %v88, %v87, %v83 # encoding: [0x16,0x78,0xbd,0x5a]
         vnmsubfp128 %v83, %v88, %v87, %v83
# CHECK: vnmsubfp128 %v64, %v72, %v69, %v64 # encoding: [0x14,0x08,0x2d,0x5a]
         vnmsubfp128 %v64, %v72, %v69, %v64
# CHECK: vsel128 %v127, %v126, %v65, %v127 # encoding: [0x17,0xfe,0x0f,0x7e]
         vsel128 %v127, %v126, %v65, %v127
# CHECK: vsel128 %v0, %v127, %v96, %v0 # encoding: [0x14,0x1f,0x07,0x73]
         vsel128 %v0, %v127, %v96, %v0
# CHECK: vsel128 %v33, %v64, %v31, %v33 # encoding: [0x14,0x20,0xff,0x54]
         vsel128 %v33, %v64, %v31, %v33
# CHECK: vsel128 %v94, %v33, %v126, %v94 # encoding: [0x17,0xc1,0xf3,0x7b]
         vsel128 %v94, %v33, %v126, %v94
# CHECK: vsel128 %v76, %v106, %v105, %v76 # encoding: [0x15,0x8a,0x4f,0x7b]
         vsel128 %v76, %v106, %v105, %v76
# CHECK: vsel128 %v73, %v92, %v93, %v73 # encoding: [0x15,0x3c,0xef,0x5a]
         vsel128 %v73, %v92, %v93, %v73
# CHECK: vsel128 %v0, %v122, %v8, %v0 # encoding: [0x14,0x1a,0x47,0x70]
         vsel128 %v0, %v122, %v8, %v0
# CHECK: vperm128 %v127, %v126, %v65, %v7 # encoding: [0x17,0xfe,0x0d,0xee]
         vperm128 %v127, %v126, %v65, %v7
# CHECK: vperm128 %v0, %v127, %v96, %v0 # encoding: [0x14,0x1f,0x04,0x23]
         vperm128 %v0, %v127, %v96, %v0
# CHECK: vperm128 %v33, %v64, %v31, %v5 # encoding: [0x14,0x20,0xfd,0x44]
         vperm128 %v33, %v64, %v31, %v5
# CHECK: vperm128 %v94, %v33, %v126, %v3 # encoding: [0x17,0xc1,0xf0,0xeb]
         vperm128 %v94, %v33, %v126, %v3
# CHECK: vperm128 %v7, %v0, %v0, %v0 # encoding: [0x14,0xe0,0x00,0x00]
         vperm128 %v7, %v0, %v0, %v0
# CHECK: vperm128 %v6, %v0, %v0, %v0 # encoding: [0x14,0xc0,0x00,0x00]
         vperm128 %v6, %v0, %v0, %v0
# CHECK: vcmpeqfp128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0c,0x2e]
         vcmpeqfp128 %v127, %v126, %v65
# CHECK: vcmpeqfp128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x04,0x23]
         vcmpeqfp128 %v0, %v127, %v96
# CHECK: vcmpeqfp128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xfc,0x04]
         vcmpeqfp128 %v33, %v64, %v31
# CHECK: vcmpeqfp128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf0,0x2b]
         vcmpeqfp128 %v94, %v33, %v126
# CHECK: vcmpeqfp128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x28,0x2c]
         vcmpeqfp128 %v109, %v63, %v5
# CHECK: vcmpeqfp128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x20,0x2c]
         vcmpeqfp128 %v108, %v37, %v4
# CHECK: vcmpeqfp128 %v7, %v123, %v127 # encoding: [0x18,0xfb,0xfc,0x23]
         vcmpeqfp128 %v7, %v123, %v127
# CHECK: vcmpeqfp128 %v11, %v0, %v127 # encoding: [0x19,0x60,0xf8,0x03]
         vcmpeqfp128 %v11, %v0, %v127
# CHECK: vcmpeqfp128. %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0c,0x6e]
         vcmpeqfp128. %v127, %v126, %v65
# CHECK: vcmpeqfp128. %v0, %v127, %v96 # encoding: [0x18,0x1f,0x04,0x63]
         vcmpeqfp128. %v0, %v127, %v96
# CHECK: vcmpeqfp128. %v33, %v64, %v31 # encoding: [0x18,0x20,0xfc,0x44]
         vcmpeqfp128. %v33, %v64, %v31
# CHECK: vcmpeqfp128. %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf0,0x6b]
         vcmpeqfp128. %v94, %v33, %v126
# CHECK: vcmpeqfp128. %v109, %v63, %v62 # encoding: [0x19,0xbf,0xf0,0x6d]
         vcmpeqfp128. %v109, %v63, %v62
# CHECK: vcmpeqfp128. %v59, %v14, %v127 # encoding: [0x1b,0x6e,0xf8,0x47]
         vcmpeqfp128. %v59, %v14, %v127
# CHECK: vcmpgefp128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0c,0xae]
         vcmpgefp128 %v127, %v126, %v65
# CHECK: vcmpgefp128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x04,0xa3]
         vcmpgefp128 %v0, %v127, %v96
# CHECK: vcmpgefp128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xfc,0x84]
         vcmpgefp128 %v33, %v64, %v31
# CHECK: vcmpgefp128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf0,0xab]
         vcmpgefp128 %v94, %v33, %v126
# CHECK: vcmpgefp128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x28,0xac]
         vcmpgefp128 %v109, %v63, %v5
# CHECK: vcmpgefp128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x20,0xac]
         vcmpgefp128 %v108, %v37, %v4
# CHECK: vcmpgefp128. %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0c,0xee]
         vcmpgefp128. %v127, %v126, %v65
# CHECK: vcmpgefp128. %v0, %v127, %v96 # encoding: [0x18,0x1f,0x04,0xe3]
         vcmpgefp128. %v0, %v127, %v96
# CHECK: vcmpgefp128. %v33, %v64, %v31 # encoding: [0x18,0x20,0xfc,0xc4]
         vcmpgefp128. %v33, %v64, %v31
# CHECK: vcmpgefp128. %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf0,0xeb]
         vcmpgefp128. %v94, %v33, %v126
# CHECK: vcmpgefp128. %v109, %v63, %v62 # encoding: [0x19,0xbf,0xf0,0xed]
         vcmpgefp128. %v109, %v63, %v62
# CHECK: vcmpgefp128. %v59, %v14, %v127 # encoding: [0x1b,0x6e,0xf8,0xc7]
         vcmpgefp128. %v59, %v14, %v127
# CHECK: vcmpgtfp128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0d,0x2e]
         vcmpgtfp128 %v127, %v126, %v65
# CHECK: vcmpgtfp128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x05,0x23]
         vcmpgtfp128 %v0, %v127, %v96
# CHECK: vcmpgtfp128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xfd,0x04]
         vcmpgtfp128 %v33, %v64, %v31
# CHECK: vcmpgtfp128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf1,0x2b]
         vcmpgtfp128 %v94, %v33, %v126
# CHECK: vcmpgtfp128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x29,0x2c]
         vcmpgtfp128 %v109, %v63, %v5
# CHECK: vcmpgtfp128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x21,0x2c]
         vcmpgtfp128 %v108, %v37, %v4
# CHECK: vcmpgtfp128 %v31, %v127, %v123 # encoding: [0x1b,0xff,0xdd,0x23]
         vcmpgtfp128 %v31, %v127, %v123
# CHECK: vcmpgtfp128 %v1, %v127, %v0 # encoding: [0x18,0x3f,0x05,0x20]
         vcmpgtfp128 %v1, %v127, %v0
# CHECK: vcmpgtfp128. %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0d,0x6e]
         vcmpgtfp128. %v127, %v126, %v65
# CHECK: vcmpgtfp128. %v0, %v127, %v96 # encoding: [0x18,0x1f,0x05,0x63]
         vcmpgtfp128. %v0, %v127, %v96
# CHECK: vcmpgtfp128. %v33, %v64, %v31 # encoding: [0x18,0x20,0xfd,0x44]
         vcmpgtfp128. %v33, %v64, %v31
# CHECK: vcmpgtfp128. %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf1,0x6b]
         vcmpgtfp128. %v94, %v33, %v126
# CHECK: vcmpgtfp128. %v109, %v63, %v62 # encoding: [0x19,0xbf,0xf1,0x6d]
         vcmpgtfp128. %v109, %v63, %v62
# CHECK: vcmpgtfp128. %v59, %v14, %v127 # encoding: [0x1b,0x6e,0xf9,0x47]
         vcmpgtfp128. %v59, %v14, %v127
# CHECK: vcmpbfp128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0d,0xae]
         vcmpbfp128 %v127, %v126, %v65
# CHECK: vcmpbfp128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x05,0xa3]
         vcmpbfp128 %v0, %v127, %v96
# CHECK: vcmpbfp128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xfd,0x84]
         vcmpbfp128 %v33, %v64, %v31
# CHECK: vcmpbfp128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf1,0xab]
         vcmpbfp128 %v94, %v33, %v126
# CHECK: vcmpbfp128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x29,0xac]
         vcmpbfp128 %v109, %v63, %v5
# CHECK: vcmpbfp128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x21,0xac]
         vcmpbfp128 %v108, %v37, %v4
# CHECK: vcmpbfp128. %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0d,0xee]
         vcmpbfp128. %v127, %v126, %v65
# CHECK: vcmpbfp128. %v0, %v127, %v96 # encoding: [0x18,0x1f,0x05,0xe3]
         vcmpbfp128. %v0, %v127, %v96
# CHECK: vcmpbfp128. %v33, %v64, %v31 # encoding: [0x18,0x20,0xfd,0xc4]
         vcmpbfp128. %v33, %v64, %v31
# CHECK: vcmpbfp128. %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf1,0xeb]
         vcmpbfp128. %v94, %v33, %v126
# CHECK: vcmpbfp128. %v109, %v63, %v62 # encoding: [0x19,0xbf,0xf1,0xed]
         vcmpbfp128. %v109, %v63, %v62
# CHECK: vcmpbfp128. %v59, %v14, %v127 # encoding: [0x1b,0x6e,0xf9,0xc7]
         vcmpbfp128. %v59, %v14, %v127
# CHECK: vcmpequw128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0e,0x2e]
         vcmpequw128 %v127, %v126, %v65
# CHECK: vcmpequw128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x06,0x23]
         vcmpequw128 %v0, %v127, %v96
# CHECK: vcmpequw128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xfe,0x04]
         vcmpequw128 %v33, %v64, %v31
# CHECK: vcmpequw128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf2,0x2b]
         vcmpequw128 %v94, %v33, %v126
# CHECK: vcmpequw128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x2a,0x2c]
         vcmpequw128 %v109, %v63, %v5
# CHECK: vcmpequw128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x22,0x2c]
         vcmpequw128 %v108, %v37, %v4
# CHECK: vcmpequw128. %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0e,0x6e]
         vcmpequw128. %v127, %v126, %v65
# CHECK: vcmpequw128. %v0, %v127, %v96 # encoding: [0x18,0x1f,0x06,0x63]
         vcmpequw128. %v0, %v127, %v96
# CHECK: vcmpequw128. %v33, %v64, %v31 # encoding: [0x18,0x20,0xfe,0x44]
         vcmpequw128. %v33, %v64, %v31
# CHECK: vcmpequw128. %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf2,0x6b]
         vcmpequw128. %v94, %v33, %v126
# CHECK: vcmpequw128. %v109, %v63, %v62 # encoding: [0x19,0xbf,0xf2,0x6d]
         vcmpequw128. %v109, %v63, %v62
# CHECK: vcmpequw128. %v59, %v14, %v127 # encoding: [0x1b,0x6e,0xfa,0x47]
         vcmpequw128. %v59, %v14, %v127
# CHECK: vrlw128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0c,0x7e]
         vrlw128 %v127, %v126, %v65
# CHECK: vrlw128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x04,0x73]
         vrlw128 %v0, %v127, %v96
# CHECK: vrlw128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xfc,0x54]
         vrlw128 %v33, %v64, %v31
# CHECK: vrlw128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf0,0x7b]
         vrlw128 %v94, %v33, %v126
# CHECK: vrlw128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x28,0x7c]
         vrlw128 %v109, %v63, %v5
# CHECK: vrlw128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x20,0x7c]
         vrlw128 %v108, %v37, %v4
# CHECK: vslw128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0c,0xfe]
         vslw128 %v127, %v126, %v65
# CHECK: vslw128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x04,0xf3]
         vslw128 %v0, %v127, %v96
# CHECK: vslw128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xfc,0xd4]
         vslw128 %v33, %v64, %v31
# CHECK: vslw128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf0,0xfb]
         vslw128 %v94, %v33, %v126
# CHECK: vslw128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x28,0xfc]
         vslw128 %v109, %v63, %v5
# CHECK: vslw128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x20,0xfc]
         vslw128 %v108, %v37, %v4
# CHECK: vslw128 %v7, %v126, %v126 # encoding: [0x18,0xfe,0xf4,0xf3]
         vslw128 %v7, %v126, %v126
# CHECK: vslw128 %v12, %v126, %v125 # encoding: [0x19,0x9e,0xec,0xf3]
         vslw128 %v12, %v126, %v125
# CHECK: vsraw128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0d,0x7e]
         vsraw128 %v127, %v126, %v65
# CHECK: vsraw128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x05,0x73]
         vsraw128 %v0, %v127, %v96
# CHECK: vsraw128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xfd,0x54]
         vsraw128 %v33, %v64, %v31
# CHECK: vsraw128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf1,0x7b]
         vsraw128 %v94, %v33, %v126
# CHECK: vsraw128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x29,0x7c]
         vsraw128 %v109, %v63, %v5
# CHECK: vsraw128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x21,0x7c]
         vsraw128 %v108, %v37, %v4
# CHECK: vsrw128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0d,0xfe]
         vsrw128 %v127, %v126, %v65
# CHECK: vsrw128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x05,0xf3]
         vsrw128 %v0, %v127, %v96
# CHECK: vsrw128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xfd,0xd4]
         vsrw128 %v33, %v64, %v31
# CHECK: vsrw128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf1,0xfb]
         vsrw128 %v94, %v33, %v126
# CHECK: vsrw128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x29,0xfc]
         vsrw128 %v109, %v63, %v5
# CHECK: vsrw128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x21,0xfc]
         vsrw128 %v108, %v37, %v4
# CHECK: vsrw128 %v2, %v2, %v124 # encoding: [0x18,0x42,0xe1,0xd3]
         vsrw128 %v2, %v2, %v124
# CHECK: vsrw128 %v4, %v3, %v124 # encoding: [0x18,0x83,0xe1,0xd3]
         vsrw128 %v4, %v3, %v124
# CHECK: vmaxfp128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0e,0xae]
         vmaxfp128 %v127, %v126, %v65
# CHECK: vmaxfp128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x06,0xa3]
         vmaxfp128 %v0, %v127, %v96
# CHECK: vmaxfp128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xfe,0x84]
         vmaxfp128 %v33, %v64, %v31
# CHECK: vmaxfp128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf2,0xab]
         vmaxfp128 %v94, %v33, %v126
# CHECK: vmaxfp128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x2a,0xac]
         vmaxfp128 %v109, %v63, %v5
# CHECK: vmaxfp128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x22,0xac]
         vmaxfp128 %v108, %v37, %v4
# CHECK: vminfp128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0e,0xee]
         vminfp128 %v127, %v126, %v65
# CHECK: vminfp128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x06,0xe3]
         vminfp128 %v0, %v127, %v96
# CHECK: vminfp128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xfe,0xc4]
         vminfp128 %v33, %v64, %v31
# CHECK: vminfp128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf2,0xeb]
         vminfp128 %v94, %v33, %v126
# CHECK: vminfp128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x2a,0xec]
         vminfp128 %v109, %v63, %v5
# CHECK: vminfp128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x22,0xec]
         vminfp128 %v108, %v37, %v4
# CHECK: vmrghw128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0f,0x2e]
         vmrghw128 %v127, %v126, %v65
# CHECK: vmrghw128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x07,0x23]
         vmrghw128 %v0, %v127, %v96
# CHECK: vmrghw128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xff,0x04]
         vmrghw128 %v33, %v64, %v31
# CHECK: vmrghw128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf3,0x2b]
         vmrghw128 %v94, %v33, %v126
# CHECK: vmrghw128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x2b,0x2c]
         vmrghw128 %v109, %v63, %v5
# CHECK: vmrghw128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x23,0x2c]
         vmrghw128 %v108, %v37, %v4
# CHECK: vmrghw128 %v13, %v119, %v121 # encoding: [0x19,0xb7,0xcf,0x23]
         vmrghw128 %v13, %v119, %v121
# CHECK: vmrghw128 %v0, %v118, %v120 # encoding: [0x18,0x16,0xc7,0x23]
         vmrghw128 %v0, %v118, %v120
# CHECK: vmrglw128 %v127, %v126, %v65 # encoding: [0x1b,0xfe,0x0f,0x6e]
         vmrglw128 %v127, %v126, %v65
# CHECK: vmrglw128 %v0, %v127, %v96 # encoding: [0x18,0x1f,0x07,0x63]
         vmrglw128 %v0, %v127, %v96
# CHECK: vmrglw128 %v33, %v64, %v31 # encoding: [0x18,0x20,0xff,0x44]
         vmrglw128 %v33, %v64, %v31
# CHECK: vmrglw128 %v94, %v33, %v126 # encoding: [0x1b,0xc1,0xf3,0x6b]
         vmrglw128 %v94, %v33, %v126
# CHECK: vmrglw128 %v109, %v63, %v5 # encoding: [0x19,0xbf,0x2b,0x6c]
         vmrglw128 %v109, %v63, %v5
# CHECK: vmrglw128 %v108, %v37, %v4 # encoding: [0x19,0x85,0x23,0x6c]
         vmrglw128 %v108, %v37, %v4
# CHECK: vmrglw128 %v8, %v119, %v121 # encoding: [0x19,0x17,0xcf,0x63]
         vmrglw128 %v8, %v119, %v121
# CHECK: vmrglw128 %v12, %v118, %v120 # encoding: [0x19,0x96,0xc7,0x63]
         vmrglw128 %v12, %v118, %v120
# CHECK: vcfpsxws128 %v127, %v65, 31 # encoding: [0x1b,0xff,0x0a,0x3e]
         vcfpsxws128 %v127, %v65, 31
# CHECK: vcfpsxws128 %v0, %v96, 1 # encoding: [0x18,0x01,0x02,0x33]
         vcfpsxws128 %v0, %v96, 1
# CHECK: vcfpsxws128 %v33, %v31, 16 # encoding: [0x18,0x30,0xfa,0x34]
         vcfpsxws128 %v33, %v31, 16
# CHECK: vcfpsxws128 %v94, %v126, 7 # encoding: [0x1b,0xc7,0xf2,0x3b]
         vcfpsxws128 %v94, %v126, 7
# CHECK: vcfpsxws128 %v110, %v110, 0 # encoding: [0x19,0xc0,0x72,0x3f]
         vcfpsxws128 %v110, %v110, 0
# CHECK: vcfpsxws128 %v33, %v127, 1 # encoding: [0x18,0x21,0xfa,0x37]
         vcfpsxws128 %v33, %v127, 1
# CHECK: vcfpuxws128 %v127, %v65, 31 # encoding: [0x1b,0xff,0x0a,0x7e]
         vcfpuxws128 %v127, %v65, 31
# CHECK: vcfpuxws128 %v0, %v96, 1 # encoding: [0x18,0x01,0x02,0x73]
         vcfpuxws128 %v0, %v96, 1
# CHECK: vcfpuxws128 %v33, %v31, 16 # encoding: [0x18,0x30,0xfa,0x74]
         vcfpuxws128 %v33, %v31, 16
# CHECK: vcfpuxws128 %v94, %v126, 7 # encoding: [0x1b,0xc7,0xf2,0x7b]
         vcfpuxws128 %v94, %v126, 7
# CHECK: vcfpuxws128 %v110, %v110, 0 # encoding: [0x19,0xc0,0x72,0x7f]
         vcfpuxws128 %v110, %v110, 0
# CHECK: vcfpuxws128 %v33, %v127, 1 # encoding: [0x18,0x21,0xfa,0x77]
         vcfpuxws128 %v33, %v127, 1
# CHECK: vcsxwfp128 %v127, %v65, 31 # encoding: [0x1b,0xff,0x0a,0xbe]
         vcsxwfp128 %v127, %v65, 31
# CHECK: vcsxwfp128 %v0, %v96, 1 # encoding: [0x18,0x01,0x02,0xb3]
         vcsxwfp128 %v0, %v96, 1
# CHECK: vcsxwfp128 %v33, %v31, 16 # encoding: [0x18,0x30,0xfa,0xb4]
         vcsxwfp128 %v33, %v31, 16
# CHECK: vcsxwfp128 %v94, %v126, 7 # encoding: [0x1b,0xc7,0xf2,0xbb]
         vcsxwfp128 %v94, %v126, 7
# CHECK: vcsxwfp128 %v110, %v110, 0 # encoding: [0x19,0xc0,0x72,0xbf]
         vcsxwfp128 %v110, %v110, 0
# CHECK: vcsxwfp128 %v33, %v127, 1 # encoding: [0x18,0x21,0xfa,0xb7]
         vcsxwfp128 %v33, %v127, 1
# CHECK: vcuxwfp128 %v127, %v65, 31 # encoding: [0x1b,0xff,0x0a,0xfe]
         vcuxwfp128 %v127, %v65, 31
# CHECK: vcuxwfp128 %v0, %v96, 1 # encoding: [0x18,0x01,0x02,0xf3]
         vcuxwfp128 %v0, %v96, 1
# CHECK: vcuxwfp128 %v33, %v31, 16 # encoding: [0x18,0x30,0xfa,0xf4]
         vcuxwfp128 %v33, %v31, 16
# CHECK: vcuxwfp128 %v94, %v126, 7 # encoding: [0x1b,0xc7,0xf2,0xfb]
         vcuxwfp128 %v94, %v126, 7
# CHECK: vcuxwfp128 %v110, %v110, 0 # encoding: [0x19,0xc0,0x72,0xff]
         vcuxwfp128 %v110, %v110, 0
# CHECK: vcuxwfp128 %v33, %v127, 1 # encoding: [0x18,0x21,0xfa,0xf7]
         vcuxwfp128 %v33, %v127, 1
# CHECK: vspltw128 %v127, %v65, 31 # encoding: [0x1b,0xff,0x0f,0x3e]
         vspltw128 %v127, %v65, 31
# CHECK: vspltw128 %v0, %v96, 1 # encoding: [0x18,0x01,0x07,0x33]
         vspltw128 %v0, %v96, 1
# CHECK: vspltw128 %v33, %v31, 16 # encoding: [0x18,0x30,0xff,0x34]
         vspltw128 %v33, %v31, 16
# CHECK: vspltw128 %v94, %v126, 7 # encoding: [0x1b,0xc7,0xf7,0x3b]
         vspltw128 %v94, %v126, 7
# CHECK: vspltw128 %v110, %v110, 0 # encoding: [0x19,0xc0,0x77,0x3f]
         vspltw128 %v110, %v110, 0
# CHECK: vspltw128 %v33, %v127, 1 # encoding: [0x18,0x21,0xff,0x37]
         vspltw128 %v33, %v127, 1
# CHECK: vrfim128 %v127, %v65 # encoding: [0x1b,0xe0,0x0b,0x3e]
         vrfim128 %v127, %v65
# CHECK: vrfim128 %v0, %v96 # encoding: [0x18,0x00,0x03,0x33]
         vrfim128 %v0, %v96
# CHECK: vrfim128 %v33, %v31 # encoding: [0x18,0x20,0xfb,0x34]
         vrfim128 %v33, %v31
# CHECK: vrfim128 %v94, %v126 # encoding: [0x1b,0xc0,0xf3,0x3b]
         vrfim128 %v94, %v126
# CHECK: vrfim128 %v110, %v110 # encoding: [0x19,0xc0,0x73,0x3f]
         vrfim128 %v110, %v110
# CHECK: vrfim128 %v33, %v127 # encoding: [0x18,0x20,0xfb,0x37]
         vrfim128 %v33, %v127
# CHECK: vrfin128 %v127, %v65 # encoding: [0x1b,0xe0,0x0b,0x7e]
         vrfin128 %v127, %v65
# CHECK: vrfin128 %v0, %v96 # encoding: [0x18,0x00,0x03,0x73]
         vrfin128 %v0, %v96
# CHECK: vrfin128 %v33, %v31 # encoding: [0x18,0x20,0xfb,0x74]
         vrfin128 %v33, %v31
# CHECK: vrfin128 %v94, %v126 # encoding: [0x1b,0xc0,0xf3,0x7b]
         vrfin128 %v94, %v126
# CHECK: vrfin128 %v110, %v110 # encoding: [0x19,0xc0,0x73,0x7f]
         vrfin128 %v110, %v110
# CHECK: vrfin128 %v33, %v127 # encoding: [0x18,0x20,0xfb,0x77]
         vrfin128 %v33, %v127
# CHECK: vrfip128 %v127, %v65 # encoding: [0x1b,0xe0,0x0b,0xbe]
         vrfip128 %v127, %v65
# CHECK: vrfip128 %v0, %v96 # encoding: [0x18,0x00,0x03,0xb3]
         vrfip128 %v0, %v96
# CHECK: vrfip128 %v33, %v31 # encoding: [0x18,0x20,0xfb,0xb4]
         vrfip128 %v33, %v31
# CHECK: vrfip128 %v94, %v126 # encoding: [0x1b,0xc0,0xf3,0xbb]
         vrfip128 %v94, %v126
# CHECK: vrfip128 %v110, %v110 # encoding: [0x19,0xc0,0x73,0xbf]
         vrfip128 %v110, %v110
# CHECK: vrfip128 %v33, %v127 # encoding: [0x18,0x20,0xfb,0xb7]
         vrfip128 %v33, %v127
# CHECK: vrfiz128 %v127, %v65 # encoding: [0x1b,0xe0,0x0b,0xfe]
         vrfiz128 %v127, %v65
# CHECK: vrfiz128 %v0, %v96 # encoding: [0x18,0x00,0x03,0xf3]
         vrfiz128 %v0, %v96
# CHECK: vrfiz128 %v33, %v31 # encoding: [0x18,0x20,0xfb,0xf4]
         vrfiz128 %v33, %v31
# CHECK: vrfiz128 %v94, %v126 # encoding: [0x1b,0xc0,0xf3,0xfb]
         vrfiz128 %v94, %v126
# CHECK: vrfiz128 %v110, %v110 # encoding: [0x19,0xc0,0x73,0xff]
         vrfiz128 %v110, %v110
# CHECK: vrfiz128 %v33, %v127 # encoding: [0x18,0x20,0xfb,0xf7]
         vrfiz128 %v33, %v127
# CHECK: vupkhsb128 %v127, %v65 # encoding: [0x1b,0xe0,0x0b,0x8e]
         vupkhsb128 %v127, %v65
# CHECK: vupkhsb128 %v0, %v96 # encoding: [0x18,0x00,0x03,0x83]
         vupkhsb128 %v0, %v96
# CHECK: vupkhsb128 %v33, %v31 # encoding: [0x18,0x20,0xfb,0x84]
         vupkhsb128 %v33, %v31
# CHECK: vupkhsb128 %v94, %v126 # encoding: [0x1b,0xc0,0xf3,0x8b]
         vupkhsb128 %v94, %v126
# CHECK: vupkhsb128 %v110, %v110 # encoding: [0x19,0xc0,0x73,0x8f]
         vupkhsb128 %v110, %v110
# CHECK: vupkhsb128 %v33, %v127 # encoding: [0x18,0x20,0xfb,0x87]
         vupkhsb128 %v33, %v127
# CHECK: vupklsb128 %v127, %v65 # encoding: [0x1b,0xe0,0x0b,0xce]
         vupklsb128 %v127, %v65
# CHECK: vupklsb128 %v0, %v96 # encoding: [0x18,0x00,0x03,0xc3]
         vupklsb128 %v0, %v96
# CHECK: vupklsb128 %v33, %v31 # encoding: [0x18,0x20,0xfb,0xc4]
         vupklsb128 %v33, %v31
# CHECK: vupklsb128 %v94, %v126 # encoding: [0x1b,0xc0,0xf3,0xcb]
         vupklsb128 %v94, %v126
# CHECK: vupklsb128 %v110, %v110 # encoding: [0x19,0xc0,0x73,0xcf]
         vupklsb128 %v110, %v110
# CHECK: vupklsb128 %v33, %v127 # encoding: [0x18,0x20,0xfb,0xc7]
         vupklsb128 %v33, %v127
# CHECK: vrefp128 %v127, %v65 # encoding: [0x1b,0xe0,0x0e,0x3e]
         vrefp128 %v127, %v65
# CHECK: vrefp128 %v0, %v96 # encoding: [0x18,0x00,0x06,0x33]
         vrefp128 %v0, %v96
# CHECK: vrefp128 %v33, %v31 # encoding: [0x18,0x20,0xfe,0x34]
         vrefp128 %v33, %v31
# CHECK: vrefp128 %v94, %v126 # encoding: [0x1b,0xc0,0xf6,0x3b]
         vrefp128 %v94, %v126
# CHECK: vrefp128 %v110, %v110 # encoding: [0x19,0xc0,0x76,0x3f]
         vrefp128 %v110, %v110
# CHECK: vrefp128 %v33, %v127 # encoding: [0x18,0x20,0xfe,0x37]
         vrefp128 %v33, %v127
# CHECK: vrsqrtefp128 %v127, %v65 # encoding: [0x1b,0xe0,0x0e,0x7e]
         vrsqrtefp128 %v127, %v65
# CHECK: vrsqrtefp128 %v0, %v96 # encoding: [0x18,0x00,0x06,0x73]
         vrsqrtefp128 %v0, %v96
# CHECK: vrsqrtefp128 %v33, %v31 # encoding: [0x18,0x20,0xfe,0x74]
         vrsqrtefp128 %v33, %v31
# CHECK: vrsqrtefp128 %v94, %v126 # encoding: [0x1b,0xc0,0xf6,0x7b]
         vrsqrtefp128 %v94, %v126
# CHECK: vrsqrtefp128 %v110, %v110 # encoding: [0x19,0xc0,0x76,0x7f]
         vrsqrtefp128 %v110, %v110
# CHECK: vrsqrtefp128 %v33, %v127 # encoding: [0x18,0x20,0xfe,0x77]
         vrsqrtefp128 %v33, %v127
# CHECK: vexptefp128 %v127, %v65 # encoding: [0x1b,0xe0,0x0e,0xbe]
         vexptefp128 %v127, %v65
# CHECK: vexptefp128 %v0, %v96 # encoding: [0x18,0x00,0x06,0xb3]
         vexptefp128 %v0, %v96
# CHECK: vexptefp128 %v33, %v31 # encoding: [0x18,0x20,0xfe,0xb4]
         vexptefp128 %v33, %v31
# CHECK: vexptefp128 %v94, %v126 # encoding: [0x1b,0xc0,0xf6,0xbb]
         vexptefp128 %v94, %v126
# CHECK: vexptefp128 %v110, %v110 # encoding: [0x19,0xc0,0x76,0xbf]
         vexptefp128 %v110, %v110
# CHECK: vexptefp128 %v33, %v127 # encoding: [0x18,0x20,0xfe,0xb7]
         vexptefp128 %v33, %v127
# CHECK: vlogefp128 %v127, %v65 # encoding: [0x1b,0xe0,0x0e,0xfe]
         vlogefp128 %v127, %v65
# CHECK: vlogefp128 %v0, %v96 # encoding: [0x18,0x00,0x06,0xf3]
         vlogefp128 %v0, %v96
# CHECK: vlogefp128 %v33, %v31 # encoding: [0x18,0x20,0xfe,0xf4]
         vlogefp128 %v33, %v31
# CHECK: vlogefp128 %v94, %v126 # encoding: [0x1b,0xc0,0xf6,0xfb]
         vlogefp128 %v94, %v126
# CHECK: vlogefp128 %v110, %v110 # encoding: [0x19,0xc0,0x76,0xff]
         vlogefp128 %v110, %v110
# CHECK: vlogefp128 %v33, %v127 # encoding: [0x18,0x20,0xfe,0xf7]
         vlogefp128 %v33, %v127
# CHECK: vupkhsh128 %v127, %v65 # encoding: [0x1b,0xe0,0x0f,0xae]
         vupkhsh128 %v127, %v65
# CHECK: vupkhsh128 %v0, %v96 # encoding: [0x18,0x00,0x07,0xa3]
         vupkhsh128 %v0, %v96
# CHECK: vupkhsh128 %v33, %v31 # encoding: [0x18,0x20,0xff,0xa4]
         vupkhsh128 %v33, %v31
# CHECK: vupkhsh128 %v94, %v126 # encoding: [0x1b,0xc0,0xf7,0xab]
         vupkhsh128 %v94, %v126
# CHECK: vupkhsh128 %v110, %v110 # encoding: [0x19,0xc0,0x77,0xaf]
         vupkhsh128 %v110, %v110
# CHECK: vupkhsh128 %v33, %v127 # encoding: [0x18,0x20,0xff,0xa7]
         vupkhsh128 %v33, %v127
# CHECK: vupklsh128 %v127, %v65 # encoding: [0x1b,0xe0,0x0f,0xee]
         vupklsh128 %v127, %v65
# CHECK: vupklsh128 %v0, %v96 # encoding: [0x18,0x00,0x07,0xe3]
         vupklsh128 %v0, %v96
# CHECK: vupklsh128 %v33, %v31 # encoding: [0x18,0x20,0xff,0xe4]
         vupklsh128 %v33, %v31
# CHECK: vupklsh128 %v94, %v126 # encoding: [0x1b,0xc0,0xf7,0xeb]
         vupklsh128 %v94, %v126
# CHECK: vupklsh128 %v110, %v110 # encoding: [0x19,0xc0,0x77,0xef]
         vupklsh128 %v110, %v110
# CHECK: vupklsh128 %v33, %v127 # encoding: [0x18,0x20,0xff,0xe7]
         vupklsh128 %v33, %v127
# CHECK: vspltisw128 %v127, -16 # encoding: [0x1b,0xf0,0x07,0x7c]
         vspltisw128 %v127, -16
# CHECK: vspltisw128 %v0, -1 # encoding: [0x18,0x1f,0x07,0x70]
         vspltisw128 %v0, -1
# CHECK: vspltisw128 %v33, 15 # encoding: [0x18,0x2f,0x07,0x74]
         vspltisw128 %v33, 15
# CHECK: vspltisw128 %v94, 0 # encoding: [0x1b,0xc0,0x07,0x78]
         vspltisw128 %v94, 0
# CHECK: vspltisw128 %v126, -1 # encoding: [0x1b,0xdf,0x07,0x7c]
         vspltisw128 %v126, -1
# CHECK: vspltisw128 %v127, 0 # encoding: [0x1b,0xe0,0x07,0x7c]
         vspltisw128 %v127, 0
# CHECK: vupkd3d128 %v127, %v65, 6 # encoding: [0x1b,0xf8,0x0f,0xfe]
         vupkd3d128 %v127, %v65, 6
# CHECK: vupkd3d128 %v0, %v96, 0 # encoding: [0x18,0x00,0x07,0xf3]
         vupkd3d128 %v0, %v96, 0
# CHECK: vupkd3d128 %v33, %v31, 5 # encoding: [0x18,0x34,0xff,0xf4]
         vupkd3d128 %v33, %v31, 5
# CHECK: vupkd3d128 %v94, %v126, 2 # encoding: [0x1b,0xc8,0xf7,0xfb]
         vupkd3d128 %v94, %v126, 2
# CHECK: vupkd3d128 %v110, %v110, 0 # encoding: [0x19,0xc0,0x77,0xff]
         vupkd3d128 %v110, %v110, 0
# CHECK: vupkd3d128 %v33, %v127, 2 # encoding: [0x18,0x28,0xff,0xf7]
         vupkd3d128 %v33, %v127, 2
# CHECK: vupkd3d128 %v10, %v127, 1 # encoding: [0x19,0x44,0xff,0xf3]
         vupkd3d128 %v10, %v127, 1
# CHECK: vupkd3d128 %v31, %v127, 1 # encoding: [0x1b,0xe4,0xff,0xf3]
         vupkd3d128 %v31, %v127, 1
# CHECK: vpermwi128 %v127, %v65, 228 # encoding: [0x1b,0xe4,0x0b,0xde]
         vpermwi128 %v127, %v65, 228
# CHECK: vpermwi128 %v0, %v96, 27 # encoding: [0x18,0x1b,0x02,0x13]
         vpermwi128 %v0, %v96, 27
# CHECK: vpermwi128 %v33, %v31, 255 # encoding: [0x18,0x3f,0xfb,0xd4]
         vpermwi128 %v33, %v31, 255
# CHECK: vpermwi128 %v94, %v126, 160 # encoding: [0x1b,0xc0,0xf3,0x5b]
         vpermwi128 %v94, %v126, 160
# CHECK: vpermwi128 %v110, %v110, 0 # encoding: [0x19,0xc0,0x72,0x1f]
         vpermwi128 %v110, %v110, 0
# CHECK: vpermwi128 %v33, %v127, 101 # encoding: [0x18,0x25,0xfa,0xd7]
         vpermwi128 %v33, %v127, 101
# CHECK: vpermwi128 %v8, %v30, 175 # encoding: [0x19,0x0f,0xf3,0x50]
         vpermwi128 %v8, %v30, 175
# CHECK: vpermwi128 %v9, %v29, 175 # encoding: [0x19,0x2f,0xeb,0x50]
         vpermwi128 %v9, %v29, 175
# CHECK: vpkd3d128 %v127, %v65, 6, 3, 3 # encoding: [0x1b,0xfb,0x0e,0xde]
         vpkd3d128 %v127, %v65, 6, 3, 3
# CHECK: vpkd3d128 %v0, %v96, 0, 1, 0 # encoding: [0x18,0x01,0x06,0x13]
         vpkd3d128 %v0, %v96, 0, 1, 0
# CHECK: vpkd3d128 %v33, %v31, 5, 2, 1 # encoding: [0x18,0x36,0xfe,0x54]
         vpkd3d128 %v33, %v31, 5, 2, 1
# CHECK: vpkd3d128 %v94, %v126, 2, 0, 2 # encoding: [0x1b,0xc8,0xf6,0x9b]
         vpkd3d128 %v94, %v126, 2, 0, 2
# CHECK: vpkd3d128 %v110, %v6, 0, 1, 0 # encoding: [0x19,0xc1,0x36,0x1c]
         vpkd3d128 %v110, %v6, 0, 1, 0
# CHECK: vpkd3d128 %v108, %v5, 1, 1, 0 # encoding: [0x19,0x85,0x2e,0x1c]
         vpkd3d128 %v108, %v5, 1, 1, 0
# CHECK: vrlimi128 %v127, %v65, 15, 3 # encoding: [0x1b,0xef,0x0f,0xde]
         vrlimi128 %v127, %v65, 15, 3
# CHECK: vrlimi128 %v0, %v96, 1, 0 # encoding: [0x18,0x01,0x07,0x13]
         vrlimi128 %v0, %v96, 1, 0
# CHECK: vrlimi128 %v33, %v31, 8, 1 # encoding: [0x18,0x28,0xff,0x54]
         vrlimi128 %v33, %v31, 8, 1
# CHECK: vrlimi128 %v94, %v126, 4, 2 # encoding: [0x1b,0xc4,0xf7,0x9b]
         vrlimi128 %v94, %v126, 4, 2
# CHECK: vrlimi128 %v109, %v5, 1, 0 # encoding: [0x19,0xa1,0x2f,0x1c]
         vrlimi128 %v109, %v5, 1, 0
# CHECK: vrlimi128 %v108, %v4, 2, 0 # encoding: [0x19,0x82,0x27,0x1c]
         vrlimi128 %v108, %v4, 2, 0
# CHECK: vrlimi128 %v0, %v12, 4, 3 # encoding: [0x18,0x04,0x67,0xd0]
         vrlimi128 %v0, %v12, 4, 3
# CHECK: vrlimi128 %v13, %v11, 4, 3 # encoding: [0x19,0xa4,0x5f,0xd0]
         vrlimi128 %v13, %v11, 4, 3
# CHECK: lvsl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf0,0x0c]
         lvsl %v31, %r31, %r30
# CHECK: lvsl %v0, 0, %r1 # encoding: [0x7c,0x00,0x08,0x0c]
         lvsl %v0, 0, %r1
# CHECK: lvsl %v17, %r3, %r12 # encoding: [0x7e,0x23,0x60,0x0c]
         lvsl %v17, %r3, %r12
# CHECK: lvsl %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xf8,0x0c]
         lvsl %v8, %r11, %r31
# CHECK: lvsr %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf0,0x4c]
         lvsr %v31, %r31, %r30
# CHECK: lvsr %v0, 0, %r1 # encoding: [0x7c,0x00,0x08,0x4c]
         lvsr %v0, 0, %r1
# CHECK: lvsr %v17, %r3, %r12 # encoding: [0x7e,0x23,0x60,0x4c]
         lvsr %v17, %r3, %r12
# CHECK: lvsr %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xf8,0x4c]
         lvsr %v8, %r11, %r31
# CHECK: lvsr %v9, 0, %r24 # encoding: [0x7d,0x20,0xc0,0x4c]
         lvsr %v9, 0, %r24
# CHECK: lvsr %v6, 0, %r31 # encoding: [0x7c,0xc0,0xf8,0x4c]
         lvsr %v6, 0, %r31
# CHECK: lvebx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf0,0x0e]
         lvebx %v31, %r31, %r30
# CHECK: lvebx %v0, 0, %r1 # encoding: [0x7c,0x00,0x08,0x0e]
         lvebx %v0, 0, %r1
# CHECK: lvebx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x60,0x0e]
         lvebx %v17, %r3, %r12
# CHECK: lvebx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xf8,0x0e]
         lvebx %v8, %r11, %r31
# CHECK: lvehx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf0,0x4e]
         lvehx %v31, %r31, %r30
# CHECK: lvehx %v0, 0, %r1 # encoding: [0x7c,0x00,0x08,0x4e]
         lvehx %v0, 0, %r1
# CHECK: lvehx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x60,0x4e]
         lvehx %v17, %r3, %r12
# CHECK: lvehx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xf8,0x4e]
         lvehx %v8, %r11, %r31
# CHECK: lvewx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf0,0x8e]
         lvewx %v31, %r31, %r30
# CHECK: lvewx %v0, 0, %r1 # encoding: [0x7c,0x00,0x08,0x8e]
         lvewx %v0, 0, %r1
# CHECK: lvewx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x60,0x8e]
         lvewx %v17, %r3, %r12
# CHECK: lvewx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xf8,0x8e]
         lvewx %v8, %r11, %r31
# CHECK: lvx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf0,0xce]
         lvx %v31, %r31, %r30
# CHECK: lvx %v0, 0, %r1 # encoding: [0x7c,0x00,0x08,0xce]
         lvx %v0, 0, %r1
# CHECK: lvx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x60,0xce]
         lvx %v17, %r3, %r12
# CHECK: lvx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xf8,0xce]
         lvx %v8, %r11, %r31
# CHECK: lvx %v14, %r11, %r12 # encoding: [0x7d,0xcb,0x60,0xce]
         lvx %v14, %r11, %r12
# CHECK: lvx %v15, %r11, %r12 # encoding: [0x7d,0xeb,0x60,0xce]
         lvx %v15, %r11, %r12
# CHECK: stvebx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf1,0x0e]
         stvebx %v31, %r31, %r30
# CHECK: stvebx %v0, 0, %r1 # encoding: [0x7c,0x00,0x09,0x0e]
         stvebx %v0, 0, %r1
# CHECK: stvebx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x61,0x0e]
         stvebx %v17, %r3, %r12
# CHECK: stvebx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xf9,0x0e]
         stvebx %v8, %r11, %r31
# CHECK: stvehx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf1,0x4e]
         stvehx %v31, %r31, %r30
# CHECK: stvehx %v0, 0, %r1 # encoding: [0x7c,0x00,0x09,0x4e]
         stvehx %v0, 0, %r1
# CHECK: stvehx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x61,0x4e]
         stvehx %v17, %r3, %r12
# CHECK: stvehx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xf9,0x4e]
         stvehx %v8, %r11, %r31
# CHECK: stvehx %v0, 0, %r9 # encoding: [0x7c,0x00,0x49,0x4e]
         stvehx %v0, 0, %r9
# CHECK: stvewx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf1,0x8e]
         stvewx %v31, %r31, %r30
# CHECK: stvewx %v0, 0, %r1 # encoding: [0x7c,0x00,0x09,0x8e]
         stvewx %v0, 0, %r1
# CHECK: stvewx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x61,0x8e]
         stvewx %v17, %r3, %r12
# CHECK: stvewx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xf9,0x8e]
         stvewx %v8, %r11, %r31
# CHECK: stvewx %v0, 0, %r11 # encoding: [0x7c,0x00,0x59,0x8e]
         stvewx %v0, 0, %r11
# CHECK: stvewx %v0, 0, %r3 # encoding: [0x7c,0x00,0x19,0x8e]
         stvewx %v0, 0, %r3
# CHECK: stvx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf1,0xce]
         stvx %v31, %r31, %r30
# CHECK: stvx %v0, 0, %r1 # encoding: [0x7c,0x00,0x09,0xce]
         stvx %v0, 0, %r1
# CHECK: stvx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x61,0xce]
         stvx %v17, %r3, %r12
# CHECK: stvx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xf9,0xce]
         stvx %v8, %r11, %r31
# CHECK: stvx %v10, 0, %r11 # encoding: [0x7d,0x40,0x59,0xce]
         stvx %v10, 0, %r11
# CHECK: stvx %v0, 0, %r11 # encoding: [0x7c,0x00,0x59,0xce]
         stvx %v0, 0, %r11
# CHECK: lvxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf2,0xce]
         lvxl %v31, %r31, %r30
# CHECK: lvxl %v0, 0, %r1 # encoding: [0x7c,0x00,0x0a,0xce]
         lvxl %v0, 0, %r1
# CHECK: lvxl %v17, %r3, %r12 # encoding: [0x7e,0x23,0x62,0xce]
         lvxl %v17, %r3, %r12
# CHECK: lvxl %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xfa,0xce]
         lvxl %v8, %r11, %r31
# CHECK: lvxl %v0, 0, %r9 # encoding: [0x7c,0x00,0x4a,0xce]
         lvxl %v0, 0, %r9
# CHECK: lvxl %v31, %r5, %r11 # encoding: [0x7f,0xe5,0x5a,0xce]
         lvxl %v31, %r5, %r11
# CHECK: stvxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf3,0xce]
         stvxl %v31, %r31, %r30
# CHECK: stvxl %v0, 0, %r1 # encoding: [0x7c,0x00,0x0b,0xce]
         stvxl %v0, 0, %r1
# CHECK: stvxl %v17, %r3, %r12 # encoding: [0x7e,0x23,0x63,0xce]
         stvxl %v17, %r3, %r12
# CHECK: stvxl %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xfb,0xce]
         stvxl %v8, %r11, %r31
# CHECK: stvxl %v0, %r3, %r11 # encoding: [0x7c,0x03,0x5b,0xce]
         stvxl %v0, %r3, %r11
# CHECK: stvxl %v1, %r7, %r11 # encoding: [0x7c,0x27,0x5b,0xce]
         stvxl %v1, %r7, %r11
# CHECK: lvlx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf4,0x0e]
         lvlx %v31, %r31, %r30
# CHECK: lvlx %v0, 0, %r1 # encoding: [0x7c,0x00,0x0c,0x0e]
         lvlx %v0, 0, %r1
# CHECK: lvlx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x64,0x0e]
         lvlx %v17, %r3, %r12
# CHECK: lvlx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xfc,0x0e]
         lvlx %v8, %r11, %r31
# CHECK: lvlx %v0, 0, %r30 # encoding: [0x7c,0x00,0xf4,0x0e]
         lvlx %v0, 0, %r30
# CHECK: lvlx %v0, 0, %r28 # encoding: [0x7c,0x00,0xe4,0x0e]
         lvlx %v0, 0, %r28
# CHECK: lvrx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf4,0x4e]
         lvrx %v31, %r31, %r30
# CHECK: lvrx %v0, 0, %r1 # encoding: [0x7c,0x00,0x0c,0x4e]
         lvrx %v0, 0, %r1
# CHECK: lvrx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x64,0x4e]
         lvrx %v17, %r3, %r12
# CHECK: lvrx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xfc,0x4e]
         lvrx %v8, %r11, %r31
# CHECK: lvrx %v13, %r30, %r11 # encoding: [0x7d,0xbe,0x5c,0x4e]
         lvrx %v13, %r30, %r11
# CHECK: lvrx %v13, %r28, %r11 # encoding: [0x7d,0xbc,0x5c,0x4e]
         lvrx %v13, %r28, %r11
# CHECK: lvlxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf6,0x0e]
         lvlxl %v31, %r31, %r30
# CHECK: lvlxl %v0, 0, %r1 # encoding: [0x7c,0x00,0x0e,0x0e]
         lvlxl %v0, 0, %r1
# CHECK: lvlxl %v17, %r3, %r12 # encoding: [0x7e,0x23,0x66,0x0e]
         lvlxl %v17, %r3, %r12
# CHECK: lvlxl %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xfe,0x0e]
         lvlxl %v8, %r11, %r31
# CHECK: lvrxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf6,0x4e]
         lvrxl %v31, %r31, %r30
# CHECK: lvrxl %v0, 0, %r1 # encoding: [0x7c,0x00,0x0e,0x4e]
         lvrxl %v0, 0, %r1
# CHECK: lvrxl %v17, %r3, %r12 # encoding: [0x7e,0x23,0x66,0x4e]
         lvrxl %v17, %r3, %r12
# CHECK: lvrxl %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xfe,0x4e]
         lvrxl %v8, %r11, %r31
# CHECK: stvlx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf5,0x0e]
         stvlx %v31, %r31, %r30
# CHECK: stvlx %v0, 0, %r1 # encoding: [0x7c,0x00,0x0d,0x0e]
         stvlx %v0, 0, %r1
# CHECK: stvlx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x65,0x0e]
         stvlx %v17, %r3, %r12
# CHECK: stvlx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xfd,0x0e]
         stvlx %v8, %r11, %r31
# CHECK: stvrx %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf5,0x4e]
         stvrx %v31, %r31, %r30
# CHECK: stvrx %v0, 0, %r1 # encoding: [0x7c,0x00,0x0d,0x4e]
         stvrx %v0, 0, %r1
# CHECK: stvrx %v17, %r3, %r12 # encoding: [0x7e,0x23,0x65,0x4e]
         stvrx %v17, %r3, %r12
# CHECK: stvrx %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xfd,0x4e]
         stvrx %v8, %r11, %r31
# CHECK: stvlxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf7,0x0e]
         stvlxl %v31, %r31, %r30
# CHECK: stvlxl %v0, 0, %r1 # encoding: [0x7c,0x00,0x0f,0x0e]
         stvlxl %v0, 0, %r1
# CHECK: stvlxl %v17, %r3, %r12 # encoding: [0x7e,0x23,0x67,0x0e]
         stvlxl %v17, %r3, %r12
# CHECK: stvlxl %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xff,0x0e]
         stvlxl %v8, %r11, %r31
# CHECK: stvrxl %v31, %r31, %r30 # encoding: [0x7f,0xff,0xf7,0x4e]
         stvrxl %v31, %r31, %r30
# CHECK: stvrxl %v0, 0, %r1 # encoding: [0x7c,0x00,0x0f,0x4e]
         stvrxl %v0, 0, %r1
# CHECK: stvrxl %v17, %r3, %r12 # encoding: [0x7e,0x23,0x67,0x4e]
         stvrxl %v17, %r3, %r12
# CHECK: stvrxl %v8, %r11, %r31 # encoding: [0x7d,0x0b,0xff,0x4e]
         stvrxl %v8, %r11, %r31
