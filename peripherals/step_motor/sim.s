0: 30047073 : csrrci x8, x0, 768

4: 00000297 : auipc x5,  0x0
8: 5A428293 : addi x5, x5, 1444
C: 30729073 : csrrw x5, x7, 775

10: 00000297 : auipc x5,  0x0
14: 4F028293 : addi x5, x5, 1264
18: 7EC29073 : csrrw x5, x12, 2028

1C: 7EC0E073 : csrrsi x1, x12, 2028

20: 00000297 : auipc x5,  0x0
24: 41828293 : addi x5, x5, 1048
28: 30529073 : csrrw x5, x5, 773

2C: 02001137 : lui x2,  0x2001000
30: 80010113 : addi x2, x2, -2048
34: 020001B7 : lui x3,  0x2000000
38: 00018193 : addi x3, x3, 0
3C: FF010113 : addi x2, x2, -16
40: 00012023 : sw x0, 0(x2)
44: 00012223 : sw x0, 4(x2)
48: 00012423 : sw x0, 8(x2)
4C: 00012623 : sw x0, 12(x2)
50: 0FC000EF : jal x1, 252

14C: FF010113 : addi x2, x2, -16
150: 00112623 : sw x1, 12(x2)
154: 00100513 : addi x10, x0, 1
158: 160000EF : jal x1, 352

2B8: 040007B7 : lui x15,  0x4000000
2BC: 24A7A023 : sw x10, 576(x15)
2C0: 00008067 : jalr x0, 0(x1)

15C: 00000513 : addi x10, x0, 0
160: 158000EF : jal x1, 344

2B8: 040007B7 : lui x15,  0x4000000
2BC: 24A7A023 : sw x10, 576(x15)
2C0: 00008067 : jalr x0, 0(x1)

164: 00500513 : addi x10, x0, 5
168: 180000EF : jal x1, 384

2E8: 040007B7 : lui x15,  0x4000000
2EC: 24A7A823 : sw x10, 592(x15)
2F0: 00008067 : jalr x0, 0(x1)

16C: 00100513 : addi x10, x0, 1
170: 16C000EF : jal x1, 364

2DC: 040007B7 : lui x15,  0x4000000
2E0: 24A7A623 : sw x10, 588(x15)
2E4: 00008067 : jalr x0, 0(x1)

174: 00000513 : addi x10, x0, 0
178: 14C000EF : jal x1, 332

2C4: 040007B7 : lui x15,  0x4000000
2C8: 24A7A223 : sw x10, 580(x15)
2CC: 00008067 : jalr x0, 0(x1)

17C: 00000513 : addi x10, x0, 0
180: 150000EF : jal x1, 336

2D0: 040007B7 : lui x15,  0x4000000
2D4: 24A7A423 : sw x10, 584(x15)
2D8: 00008067 : jalr x0, 0(x1)

184: 00200513 : addi x10, x0, 2
188: 120000EF : jal x1, 288

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

18C: 00000513 : addi x10, x0, 0
190: 14C000EF : jal x1, 332

2DC: 040007B7 : lui x15,  0x4000000
2E0: 24A7A623 : sw x10, 588(x15)
2E4: 00008067 : jalr x0, 0(x1)

194: 00100513 : addi x10, x0, 1
198: 110000EF : jal x1, 272

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

19C: 00100513 : addi x10, x0, 1
1A0: 124000EF : jal x1, 292

2C4: 040007B7 : lui x15,  0x4000000
2C8: 24A7A223 : sw x10, 580(x15)
2CC: 00008067 : jalr x0, 0(x1)

1A4: 00300513 : addi x10, x0, 3
1A8: 100000EF : jal x1, 256

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1AC: 00100513 : addi x10, x0, 1
1B0: 120000EF : jal x1, 288

2D0: 040007B7 : lui x15,  0x4000000
2D4: 24A7A423 : sw x10, 584(x15)
2D8: 00008067 : jalr x0, 0(x1)

1B4: 00100513 : addi x10, x0, 1
1B8: 0F0000EF : jal x1, 240

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1BC: 00000513 : addi x10, x0, 0
1C0: 128000EF : jal x1, 296

2E8: 040007B7 : lui x15,  0x4000000
2EC: 24A7A823 : sw x10, 592(x15)
2F0: 00008067 : jalr x0, 0(x1)

1C4: 00100513 : addi x10, x0, 1
1C8: 0E0000EF : jal x1, 224

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1CC: F91FF06F : jal x0, -112

15C: 00000513 : addi x10, x0, 0
160: 158000EF : jal x1, 344

2B8: 040007B7 : lui x15,  0x4000000
2BC: 24A7A023 : sw x10, 576(x15)
2C0: 00008067 : jalr x0, 0(x1)

164: 00500513 : addi x10, x0, 5
168: 180000EF : jal x1, 384

2E8: 040007B7 : lui x15,  0x4000000
2EC: 24A7A823 : sw x10, 592(x15)
2F0: 00008067 : jalr x0, 0(x1)

16C: 00100513 : addi x10, x0, 1
170: 16C000EF : jal x1, 364

2DC: 040007B7 : lui x15,  0x4000000
2E0: 24A7A623 : sw x10, 588(x15)
2E4: 00008067 : jalr x0, 0(x1)

174: 00000513 : addi x10, x0, 0
178: 14C000EF : jal x1, 332

2C4: 040007B7 : lui x15,  0x4000000
2C8: 24A7A223 : sw x10, 580(x15)
2CC: 00008067 : jalr x0, 0(x1)

17C: 00000513 : addi x10, x0, 0
180: 150000EF : jal x1, 336

2D0: 040007B7 : lui x15,  0x4000000
2D4: 24A7A423 : sw x10, 584(x15)
2D8: 00008067 : jalr x0, 0(x1)

184: 00200513 : addi x10, x0, 2
188: 120000EF : jal x1, 288

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

18C: 00000513 : addi x10, x0, 0
190: 14C000EF : jal x1, 332

2DC: 040007B7 : lui x15,  0x4000000
2E0: 24A7A623 : sw x10, 588(x15)
2E4: 00008067 : jalr x0, 0(x1)

194: 00100513 : addi x10, x0, 1
198: 110000EF : jal x1, 272

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

19C: 00100513 : addi x10, x0, 1
1A0: 124000EF : jal x1, 292

2C4: 040007B7 : lui x15,  0x4000000
2C8: 24A7A223 : sw x10, 580(x15)
2CC: 00008067 : jalr x0, 0(x1)

1A4: 00300513 : addi x10, x0, 3
1A8: 100000EF : jal x1, 256

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1AC: 00100513 : addi x10, x0, 1
1B0: 120000EF : jal x1, 288

2D0: 040007B7 : lui x15,  0x4000000
2D4: 24A7A423 : sw x10, 584(x15)
2D8: 00008067 : jalr x0, 0(x1)

1B4: 00100513 : addi x10, x0, 1
1B8: 0F0000EF : jal x1, 240

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1BC: 00000513 : addi x10, x0, 0
1C0: 128000EF : jal x1, 296

2E8: 040007B7 : lui x15,  0x4000000
2EC: 24A7A823 : sw x10, 592(x15)
2F0: 00008067 : jalr x0, 0(x1)

1C4: 00100513 : addi x10, x0, 1
1C8: 0E0000EF : jal x1, 224

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1CC: F91FF06F : jal x0, -112

15C: 00000513 : addi x10, x0, 0
160: 158000EF : jal x1, 344

2B8: 040007B7 : lui x15,  0x4000000
2BC: 24A7A023 : sw x10, 576(x15)
2C0: 00008067 : jalr x0, 0(x1)

164: 00500513 : addi x10, x0, 5
168: 180000EF : jal x1, 384

2E8: 040007B7 : lui x15,  0x4000000
2EC: 24A7A823 : sw x10, 592(x15)
2F0: 00008067 : jalr x0, 0(x1)

16C: 00100513 : addi x10, x0, 1
170: 16C000EF : jal x1, 364

2DC: 040007B7 : lui x15,  0x4000000
2E0: 24A7A623 : sw x10, 588(x15)
2E4: 00008067 : jalr x0, 0(x1)

174: 00000513 : addi x10, x0, 0
178: 14C000EF : jal x1, 332

2C4: 040007B7 : lui x15,  0x4000000
2C8: 24A7A223 : sw x10, 580(x15)
2CC: 00008067 : jalr x0, 0(x1)

17C: 00000513 : addi x10, x0, 0
180: 150000EF : jal x1, 336

2D0: 040007B7 : lui x15,  0x4000000
2D4: 24A7A423 : sw x10, 584(x15)
2D8: 00008067 : jalr x0, 0(x1)

184: 00200513 : addi x10, x0, 2
188: 120000EF : jal x1, 288

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

18C: 00000513 : addi x10, x0, 0
190: 14C000EF : jal x1, 332

2DC: 040007B7 : lui x15,  0x4000000
2E0: 24A7A623 : sw x10, 588(x15)
2E4: 00008067 : jalr x0, 0(x1)

194: 00100513 : addi x10, x0, 1
198: 110000EF : jal x1, 272

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

19C: 00100513 : addi x10, x0, 1
1A0: 124000EF : jal x1, 292

2C4: 040007B7 : lui x15,  0x4000000
2C8: 24A7A223 : sw x10, 580(x15)
2CC: 00008067 : jalr x0, 0(x1)

1A4: 00300513 : addi x10, x0, 3
1A8: 100000EF : jal x1, 256

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1AC: 00100513 : addi x10, x0, 1
1B0: 120000EF : jal x1, 288

2D0: 040007B7 : lui x15,  0x4000000
2D4: 24A7A423 : sw x10, 584(x15)
2D8: 00008067 : jalr x0, 0(x1)

1B4: 00100513 : addi x10, x0, 1
1B8: 0F0000EF : jal x1, 240

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1BC: 00000513 : addi x10, x0, 0
1C0: 128000EF : jal x1, 296

2E8: 040007B7 : lui x15,  0x4000000
2EC: 24A7A823 : sw x10, 592(x15)
2F0: 00008067 : jalr x0, 0(x1)

1C4: 00100513 : addi x10, x0, 1
1C8: 0E0000EF : jal x1, 224

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1CC: F91FF06F : jal x0, -112

15C: 00000513 : addi x10, x0, 0
160: 158000EF : jal x1, 344

2B8: 040007B7 : lui x15,  0x4000000
2BC: 24A7A023 : sw x10, 576(x15)
2C0: 00008067 : jalr x0, 0(x1)

164: 00500513 : addi x10, x0, 5
168: 180000EF : jal x1, 384

2E8: 040007B7 : lui x15,  0x4000000
2EC: 24A7A823 : sw x10, 592(x15)
2F0: 00008067 : jalr x0, 0(x1)

16C: 00100513 : addi x10, x0, 1
170: 16C000EF : jal x1, 364

2DC: 040007B7 : lui x15,  0x4000000
2E0: 24A7A623 : sw x10, 588(x15)
2E4: 00008067 : jalr x0, 0(x1)

174: 00000513 : addi x10, x0, 0
178: 14C000EF : jal x1, 332

2C4: 040007B7 : lui x15,  0x4000000
2C8: 24A7A223 : sw x10, 580(x15)
2CC: 00008067 : jalr x0, 0(x1)

17C: 00000513 : addi x10, x0, 0
180: 150000EF : jal x1, 336

2D0: 040007B7 : lui x15,  0x4000000
2D4: 24A7A423 : sw x10, 584(x15)
2D8: 00008067 : jalr x0, 0(x1)

184: 00200513 : addi x10, x0, 2
188: 120000EF : jal x1, 288

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

18C: 00000513 : addi x10, x0, 0
190: 14C000EF : jal x1, 332

2DC: 040007B7 : lui x15,  0x4000000
2E0: 24A7A623 : sw x10, 588(x15)
2E4: 00008067 : jalr x0, 0(x1)

194: 00100513 : addi x10, x0, 1
198: 110000EF : jal x1, 272

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

19C: 00100513 : addi x10, x0, 1
1A0: 124000EF : jal x1, 292

2C4: 040007B7 : lui x15,  0x4000000
2C8: 24A7A223 : sw x10, 580(x15)
2CC: 00008067 : jalr x0, 0(x1)

1A4: 00300513 : addi x10, x0, 3
1A8: 100000EF : jal x1, 256

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1AC: 00100513 : addi x10, x0, 1
1B0: 120000EF : jal x1, 288

2D0: 040007B7 : lui x15,  0x4000000
2D4: 24A7A423 : sw x10, 584(x15)
2D8: 00008067 : jalr x0, 0(x1)

1B4: 00100513 : addi x10, x0, 1
1B8: 0F0000EF : jal x1, 240

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1BC: 00000513 : addi x10, x0, 0
1C0: 128000EF : jal x1, 296

2E8: 040007B7 : lui x15,  0x4000000
2EC: 24A7A823 : sw x10, 592(x15)
2F0: 00008067 : jalr x0, 0(x1)

1C4: 00100513 : addi x10, x0, 1
1C8: 0E0000EF : jal x1, 224

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1CC: F91FF06F : jal x0, -112

15C: 00000513 : addi x10, x0, 0
160: 158000EF : jal x1, 344

2B8: 040007B7 : lui x15,  0x4000000
2BC: 24A7A023 : sw x10, 576(x15)
2C0: 00008067 : jalr x0, 0(x1)

164: 00500513 : addi x10, x0, 5
168: 180000EF : jal x1, 384

2E8: 040007B7 : lui x15,  0x4000000
2EC: 24A7A823 : sw x10, 592(x15)
2F0: 00008067 : jalr x0, 0(x1)

16C: 00100513 : addi x10, x0, 1
170: 16C000EF : jal x1, 364

2DC: 040007B7 : lui x15,  0x4000000
2E0: 24A7A623 : sw x10, 588(x15)
2E4: 00008067 : jalr x0, 0(x1)

174: 00000513 : addi x10, x0, 0
178: 14C000EF : jal x1, 332

2C4: 040007B7 : lui x15,  0x4000000
2C8: 24A7A223 : sw x10, 580(x15)
2CC: 00008067 : jalr x0, 0(x1)

17C: 00000513 : addi x10, x0, 0
180: 150000EF : jal x1, 336

2D0: 040007B7 : lui x15,  0x4000000
2D4: 24A7A423 : sw x10, 584(x15)
2D8: 00008067 : jalr x0, 0(x1)

184: 00200513 : addi x10, x0, 2
188: 120000EF : jal x1, 288

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

18C: 00000513 : addi x10, x0, 0
190: 14C000EF : jal x1, 332

2DC: 040007B7 : lui x15,  0x4000000
2E0: 24A7A623 : sw x10, 588(x15)
2E4: 00008067 : jalr x0, 0(x1)

194: 00100513 : addi x10, x0, 1
198: 110000EF : jal x1, 272

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

19C: 00100513 : addi x10, x0, 1
1A0: 124000EF : jal x1, 292

2C4: 040007B7 : lui x15,  0x4000000
2C8: 24A7A223 : sw x10, 580(x15)
2CC: 00008067 : jalr x0, 0(x1)

1A4: 00300513 : addi x10, x0, 3
1A8: 100000EF : jal x1, 256

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1AC: 00100513 : addi x10, x0, 1
1B0: 120000EF : jal x1, 288

2D0: 040007B7 : lui x15,  0x4000000
2D4: 24A7A423 : sw x10, 584(x15)
2D8: 00008067 : jalr x0, 0(x1)

1B4: 00100513 : addi x10, x0, 1
1B8: 0F0000EF : jal x1, 240

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1BC: 00000513 : addi x10, x0, 0
1C0: 128000EF : jal x1, 296

2E8: 040007B7 : lui x15,  0x4000000
2EC: 24A7A823 : sw x10, 592(x15)
2F0: 00008067 : jalr x0, 0(x1)

1C4: 00100513 : addi x10, x0, 1
1C8: 0E0000EF : jal x1, 224

2A8: FFF00793 : addi x15, x0, -1
2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2AC: FFF50513 : addi x10, x10, -1
2B0: FEF51EE3 : bne x10, x15, -4

2B4: 00008067 : jalr x0, 0(x1)

1CC: F91FF06F : jal x0, -112

15C: 00000513 : addi x10, x0, 0
160: 158000EF : jal x1, 344

2B8: 040007B7 : lui x15,  0x4000000
2BC: 24A7A023 : sw x10, 576(x15)
2C0: 00008067 : jalr x0, 0(x1)

164: 00500513 : addi x10, x0, 5
168: 180000EF : jal x1, 384

2E8: 040007B7 : lui x15,  0x4000000
2EC: 24A7A823 : sw x10, 592(x15)
2F0: 00008067 : jalr x0, 0(x1)

16C: 00100513 : addi x10, x0, 1
170: 16C000EF : jal x1, 364

