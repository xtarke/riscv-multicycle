0: 30047073 : csrrci x8, x0, 768

4: 00000297 : auipc x5,  0x0
8: 61828293 : addi x5, x5, 1560
C: 30729073 : csrrw x5, x7, 775

10: 00000297 : auipc x5,  0x0
14: 56828293 : addi x5, x5, 1384
18: 7EC29073 : csrrw x5, x12, 2028

1C: 7EC0E073 : csrrsi x1, x12, 2028

20: 00000297 : auipc x5,  0x0
24: 49428293 : addi x5, x5, 1172
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
50: 12C000EF : jal x1, 300

17C: FF010113 : addi x2, x2, -16
180: 00112623 : sw x1, 12(x2)
184: 00000593 : addi x11, x0, 0
188: 00000513 : addi x10, x0, 0
18C: 11C000EF : jal x1, 284

2A8: 00259593 : slli x11, x11, 2
2AC: 00C5F593 : andi x11, x11, 12
2B0: 00357513 : andi x10, x10, 3
2B4: 00A5E5B3 : or x11, x11, x10
2B4: 00A5E5B3 : or x11, x11, x10
2B8: 040007B7 : lui x15,  0x4000000
2BC: 08B7A423 : sw x11, 136(x15)
2C0: 00008067 : jalr x0, 0(x1)

190: 134000EF : jal x1, 308

2C4: 04000737 : lui x14,  0x4000000
2C8: 08872783 : lw x14, 136(x15)
2CC: 0107E793 : oir x15, x15, 16
2D0: 08F72423 : sw x15, 136(x14)
2D4: 00008067 : jalr x0, 0(x1)

194: 00100513 : addi x10, x0, 1
198: 1A4000EF : jal x1, 420

33C: 000012B7 : lui x5,  0x1000
340: 80028293 : addi x5, x5, -2048
344: 00050663 : beq x10, x0, 12

348: 3042A073 : csrrs x5, x4, 772

34C: 00008067 : jalr x0, 0(x1)

19C: 00100513 : addi x10, x0, 1
1A0: 188000EF : jal x1, 392

328: 00050663 : beq x10, x0, 12

32C: 30046073 : csrrsi x8, x0, 768

330: 00008067 : jalr x0, 0(x1)

1A4: 06400513 : addi x10, x0, 100
1A8: 0E0000EF : jal x1, 224

288: FFF00793 : addi x15, x0, -1
28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

578: 00112023 : sw x1, 0(x2)
57C: 00412223 : sw x4, 4(x2)
580: 00512423 : sw x5, 8(x2)
584: 00612623 : sw x6, 12(x2)
588: 00712823 : sw x7, 16(x2)
58C: 00A12A23 : sw x10, 20(x2)
590: 00B12C23 : sw x11, 24(x2)
594: 00C12E23 : sw x12, 28(x2)
598: 02D12023 : sw x13, 32(x2)
59C: 02E12223 : sw x14, 36(x2)
5A0: 02F12423 : sw x15, 40(x2)
5A4: 03012623 : sw x16, 44(x2)
5A8: 03112823 : sw x17, 48(x2)
5AC: 03C12A23 : sw x28, 52(x2)
5B0: 03D12C23 : sw x29, 56(x2)
5B4: 03E12E23 : sw x30, 60(x2)
5B8: 05F12023 : sw x31, 64(x2)
5BC: 34202673 : csrrs x0, x2, 834

5C0: 30702773 : csrrs x0, x7, 775

5C4: 00261613 : slli x12, x12, 2
5C8: 00C70733 : add x14, x14, x12
5C8: 00C70733 : add x14, x14, x12
5CC: 00072703 : lw x14, 0(x14)
5D0: 000700E7 : jalr x1, 0(x14)

14C: FF010113 : addi x2, x2, -16
150: 00112623 : sw x1, 12(x2)
154: 184000EF : jal x1, 388

2D8: 040007B7 : lui x15,  0x4000000
2DC: 0847A503 : lw x15, 132(x10)
2E0: 0FF57513 : andi x10, x10, 255
2E4: 00008067 : jalr x0, 0(x1)

158: 040007B7 : lui x15,  0x4000000
15C: 00A7A223 : sw x10, 4(x15)
160: 04A7A023 : sw x10, 64(x15)
164: 00455513 : srli x10, x10, 4
168: 0FF57513 : andi x10, x10, 255
16C: 04A7A223 : sw x10, 68(x15)
170: 00C12083 : lw x2, 12(x1)
174: 01010113 : addi x2, x2, 16
178: 00008067 : jalr x0, 0(x1)

5D4: 00012083 : lw x2, 0(x1)
5D8: 00412203 : lw x2, 4(x4)
5DC: 00812283 : lw x2, 8(x5)
5E0: 00C12303 : lw x2, 12(x6)
5E4: 01012383 : lw x2, 16(x7)
5E8: 01412503 : lw x2, 20(x10)
5EC: 01812583 : lw x2, 24(x11)
5F0: 01C12603 : lw x2, 28(x12)
5F4: 02012683 : lw x2, 32(x13)
5F8: 02412703 : lw x2, 36(x14)
5FC: 02812783 : lw x2, 40(x15)
600: 02C12803 : lw x2, 44(x16)
604: 03012883 : lw x2, 48(x17)
608: 03412E03 : lw x2, 52(x28)
60C: 03812E83 : lw x2, 56(x29)
610: 03C12F03 : lw x2, 60(x30)
614: 05010113 : addi x2, x2, 80
mret

294: 00008067 : jalr x0, 0(x1)

1AC: FF9FF06F : jal x0, -8

1A4: 06400513 : addi x10, x0, 100
1A8: 0E0000EF : jal x1, 224

288: FFF00793 : addi x15, x0, -1
28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

294: 00008067 : jalr x0, 0(x1)

1AC: FF9FF06F : jal x0, -8

1A4: 06400513 : addi x10, x0, 100
1A8: 0E0000EF : jal x1, 224

288: FFF00793 : addi x15, x0, -1
28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

294: 00008067 : jalr x0, 0(x1)

1AC: FF9FF06F : jal x0, -8

1A4: 06400513 : addi x10, x0, 100
1A8: 0E0000EF : jal x1, 224

288: FFF00793 : addi x15, x0, -1
28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

578: 00112023 : sw x1, 0(x2)
57C: 00412223 : sw x4, 4(x2)
580: 00512423 : sw x5, 8(x2)
584: 00612623 : sw x6, 12(x2)
588: 00712823 : sw x7, 16(x2)
58C: 00A12A23 : sw x10, 20(x2)
590: 00B12C23 : sw x11, 24(x2)
594: 00C12E23 : sw x12, 28(x2)
598: 02D12023 : sw x13, 32(x2)
59C: 02E12223 : sw x14, 36(x2)
5A0: 02F12423 : sw x15, 40(x2)
5A4: 03012623 : sw x16, 44(x2)
5A8: 03112823 : sw x17, 48(x2)
5AC: 03C12A23 : sw x28, 52(x2)
5B0: 03D12C23 : sw x29, 56(x2)
5B4: 03E12E23 : sw x30, 60(x2)
5B8: 05F12023 : sw x31, 64(x2)
5BC: 34202673 : csrrs x0, x2, 834

5C0: 30702773 : csrrs x0, x7, 775

5C4: 00261613 : slli x12, x12, 2
5C8: 00C70733 : add x14, x14, x12
5C8: 00C70733 : add x14, x14, x12
5CC: 00072703 : lw x14, 0(x14)
5D0: 000700E7 : jalr x1, 0(x14)

14C: FF010113 : addi x2, x2, -16
150: 00112623 : sw x1, 12(x2)
154: 184000EF : jal x1, 388

2D8: 040007B7 : lui x15,  0x4000000
2DC: 0847A503 : lw x15, 132(x10)
2E0: 0FF57513 : andi x10, x10, 255
2E4: 00008067 : jalr x0, 0(x1)

158: 040007B7 : lui x15,  0x4000000
15C: 00A7A223 : sw x10, 4(x15)
160: 04A7A023 : sw x10, 64(x15)
164: 00455513 : srli x10, x10, 4
168: 0FF57513 : andi x10, x10, 255
16C: 04A7A223 : sw x10, 68(x15)
170: 00C12083 : lw x2, 12(x1)
174: 01010113 : addi x2, x2, 16
178: 00008067 : jalr x0, 0(x1)

5D4: 00012083 : lw x2, 0(x1)
5D8: 00412203 : lw x2, 4(x4)
5DC: 00812283 : lw x2, 8(x5)
5E0: 00C12303 : lw x2, 12(x6)
5E4: 01012383 : lw x2, 16(x7)
5E8: 01412503 : lw x2, 20(x10)
5EC: 01812583 : lw x2, 24(x11)
5F0: 01C12603 : lw x2, 28(x12)
5F4: 02012683 : lw x2, 32(x13)
5F8: 02412703 : lw x2, 36(x14)
5FC: 02812783 : lw x2, 40(x15)
600: 02C12803 : lw x2, 44(x16)
604: 03012883 : lw x2, 48(x17)
608: 03412E03 : lw x2, 52(x28)
60C: 03812E83 : lw x2, 56(x29)
610: 03C12F03 : lw x2, 60(x30)
614: 05010113 : addi x2, x2, 80
mret

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

294: 00008067 : jalr x0, 0(x1)

1AC: FF9FF06F : jal x0, -8

1A4: 06400513 : addi x10, x0, 100
1A8: 0E0000EF : jal x1, 224

288: FFF00793 : addi x15, x0, -1
28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

294: 00008067 : jalr x0, 0(x1)

1AC: FF9FF06F : jal x0, -8

1A4: 06400513 : addi x10, x0, 100
1A8: 0E0000EF : jal x1, 224

288: FFF00793 : addi x15, x0, -1
28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
578: 00112023 : sw x1, 0(x2)
57C: 00412223 : sw x4, 4(x2)
580: 00512423 : sw x5, 8(x2)
584: 00612623 : sw x6, 12(x2)
588: 00712823 : sw x7, 16(x2)
58C: 00A12A23 : sw x10, 20(x2)
590: 00B12C23 : sw x11, 24(x2)
594: 00C12E23 : sw x12, 28(x2)
598: 02D12023 : sw x13, 32(x2)
59C: 02E12223 : sw x14, 36(x2)
5A0: 02F12423 : sw x15, 40(x2)
5A4: 03012623 : sw x16, 44(x2)
5A8: 03112823 : sw x17, 48(x2)
5AC: 03C12A23 : sw x28, 52(x2)
5B0: 03D12C23 : sw x29, 56(x2)
5B4: 03E12E23 : sw x30, 60(x2)
5B8: 05F12023 : sw x31, 64(x2)
5BC: 34202673 : csrrs x0, x2, 834

5C0: 30702773 : csrrs x0, x7, 775

5C4: 00261613 : slli x12, x12, 2
5C8: 00C70733 : add x14, x14, x12
5C8: 00C70733 : add x14, x14, x12
5CC: 00072703 : lw x14, 0(x14)
5D0: 000700E7 : jalr x1, 0(x14)

14C: FF010113 : addi x2, x2, -16
150: 00112623 : sw x1, 12(x2)
154: 184000EF : jal x1, 388

2D8: 040007B7 : lui x15,  0x4000000
2DC: 0847A503 : lw x15, 132(x10)
2E0: 0FF57513 : andi x10, x10, 255
2E4: 00008067 : jalr x0, 0(x1)

158: 040007B7 : lui x15,  0x4000000
15C: 00A7A223 : sw x10, 4(x15)
160: 04A7A023 : sw x10, 64(x15)
164: 00455513 : srli x10, x10, 4
168: 0FF57513 : andi x10, x10, 255
16C: 04A7A223 : sw x10, 68(x15)
170: 00C12083 : lw x2, 12(x1)
174: 01010113 : addi x2, x2, 16
178: 00008067 : jalr x0, 0(x1)

5D4: 00012083 : lw x2, 0(x1)
5D8: 00412203 : lw x2, 4(x4)
5DC: 00812283 : lw x2, 8(x5)
5E0: 00C12303 : lw x2, 12(x6)
5E4: 01012383 : lw x2, 16(x7)
5E8: 01412503 : lw x2, 20(x10)
5EC: 01812583 : lw x2, 24(x11)
5F0: 01C12603 : lw x2, 28(x12)
5F4: 02012683 : lw x2, 32(x13)
5F8: 02412703 : lw x2, 36(x14)
5FC: 02812783 : lw x2, 40(x15)
600: 02C12803 : lw x2, 44(x16)
604: 03012883 : lw x2, 48(x17)
608: 03412E03 : lw x2, 52(x28)
60C: 03812E83 : lw x2, 56(x29)
610: 03C12F03 : lw x2, 60(x30)
614: 05010113 : addi x2, x2, 80
mret

290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

294: 00008067 : jalr x0, 0(x1)

1AC: FF9FF06F : jal x0, -8

1A4: 06400513 : addi x10, x0, 100
1A8: 0E0000EF : jal x1, 224

288: FFF00793 : addi x15, x0, -1
28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

294: 00008067 : jalr x0, 0(x1)

1AC: FF9FF06F : jal x0, -8

1A4: 06400513 : addi x10, x0, 100
1A8: 0E0000EF : jal x1, 224

288: FFF00793 : addi x15, x0, -1
28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

578: 00112023 : sw x1, 0(x2)
57C: 00412223 : sw x4, 4(x2)
580: 00512423 : sw x5, 8(x2)
584: 00612623 : sw x6, 12(x2)
588: 00712823 : sw x7, 16(x2)
58C: 00A12A23 : sw x10, 20(x2)
590: 00B12C23 : sw x11, 24(x2)
594: 00C12E23 : sw x12, 28(x2)
598: 02D12023 : sw x13, 32(x2)
59C: 02E12223 : sw x14, 36(x2)
5A0: 02F12423 : sw x15, 40(x2)
5A4: 03012623 : sw x16, 44(x2)
5A8: 03112823 : sw x17, 48(x2)
5AC: 03C12A23 : sw x28, 52(x2)
5B0: 03D12C23 : sw x29, 56(x2)
5B4: 03E12E23 : sw x30, 60(x2)
5B8: 05F12023 : sw x31, 64(x2)
5BC: 34202673 : csrrs x0, x2, 834

5C0: 30702773 : csrrs x0, x7, 775

5C4: 00261613 : slli x12, x12, 2
5C8: 00C70733 : add x14, x14, x12
5C8: 00C70733 : add x14, x14, x12
5CC: 00072703 : lw x14, 0(x14)
5D0: 000700E7 : jalr x1, 0(x14)

14C: FF010113 : addi x2, x2, -16
150: 00112623 : sw x1, 12(x2)
154: 184000EF : jal x1, 388

2D8: 040007B7 : lui x15,  0x4000000
2DC: 0847A503 : lw x15, 132(x10)
2E0: 0FF57513 : andi x10, x10, 255
2E4: 00008067 : jalr x0, 0(x1)

158: 040007B7 : lui x15,  0x4000000
15C: 00A7A223 : sw x10, 4(x15)
160: 04A7A023 : sw x10, 64(x15)
164: 00455513 : srli x10, x10, 4
168: 0FF57513 : andi x10, x10, 255
16C: 04A7A223 : sw x10, 68(x15)
170: 00C12083 : lw x2, 12(x1)
174: 01010113 : addi x2, x2, 16
178: 00008067 : jalr x0, 0(x1)

5D4: 00012083 : lw x2, 0(x1)
5D8: 00412203 : lw x2, 4(x4)
5DC: 00812283 : lw x2, 8(x5)
5E0: 00C12303 : lw x2, 12(x6)
5E4: 01012383 : lw x2, 16(x7)
5E8: 01412503 : lw x2, 20(x10)
5EC: 01812583 : lw x2, 24(x11)
5F0: 01C12603 : lw x2, 28(x12)
5F4: 02012683 : lw x2, 32(x13)
5F8: 02412703 : lw x2, 36(x14)
5FC: 02812783 : lw x2, 40(x15)
600: 02C12803 : lw x2, 44(x16)
604: 03012883 : lw x2, 48(x17)
608: 03412E03 : lw x2, 52(x28)
60C: 03812E83 : lw x2, 56(x29)
610: 03C12F03 : lw x2, 60(x30)
614: 05010113 : addi x2, x2, 80
mret

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

294: 00008067 : jalr x0, 0(x1)

1AC: FF9FF06F : jal x0, -8

1A4: 06400513 : addi x10, x0, 100
1A8: 0E0000EF : jal x1, 224

288: FFF00793 : addi x15, x0, -1
28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

294: 00008067 : jalr x0, 0(x1)

1AC: FF9FF06F : jal x0, -8

1A4: 06400513 : addi x10, x0, 100
1A8: 0E0000EF : jal x1, 224

288: FFF00793 : addi x15, x0, -1
28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
578: 00112023 : sw x1, 0(x2)
57C: 00412223 : sw x4, 4(x2)
580: 00512423 : sw x5, 8(x2)
584: 00612623 : sw x6, 12(x2)
588: 00712823 : sw x7, 16(x2)
58C: 00A12A23 : sw x10, 20(x2)
590: 00B12C23 : sw x11, 24(x2)
594: 00C12E23 : sw x12, 28(x2)
598: 02D12023 : sw x13, 32(x2)
59C: 02E12223 : sw x14, 36(x2)
5A0: 02F12423 : sw x15, 40(x2)
5A4: 03012623 : sw x16, 44(x2)
5A8: 03112823 : sw x17, 48(x2)
5AC: 03C12A23 : sw x28, 52(x2)
5B0: 03D12C23 : sw x29, 56(x2)
5B4: 03E12E23 : sw x30, 60(x2)
5B8: 05F12023 : sw x31, 64(x2)
5BC: 34202673 : csrrs x0, x2, 834

5C0: 30702773 : csrrs x0, x7, 775

5C4: 00261613 : slli x12, x12, 2
5C8: 00C70733 : add x14, x14, x12
5C8: 00C70733 : add x14, x14, x12
5CC: 00072703 : lw x14, 0(x14)
5D0: 000700E7 : jalr x1, 0(x14)

14C: FF010113 : addi x2, x2, -16
150: 00112623 : sw x1, 12(x2)
154: 184000EF : jal x1, 388

2D8: 040007B7 : lui x15,  0x4000000
2DC: 0847A503 : lw x15, 132(x10)
2E0: 0FF57513 : andi x10, x10, 255
2E4: 00008067 : jalr x0, 0(x1)

158: 040007B7 : lui x15,  0x4000000
15C: 00A7A223 : sw x10, 4(x15)
160: 04A7A023 : sw x10, 64(x15)
164: 00455513 : srli x10, x10, 4
168: 0FF57513 : andi x10, x10, 255
16C: 04A7A223 : sw x10, 68(x15)
170: 00C12083 : lw x2, 12(x1)
174: 01010113 : addi x2, x2, 16
178: 00008067 : jalr x0, 0(x1)

5D4: 00012083 : lw x2, 0(x1)
5D8: 00412203 : lw x2, 4(x4)
5DC: 00812283 : lw x2, 8(x5)
5E0: 00C12303 : lw x2, 12(x6)
5E4: 01012383 : lw x2, 16(x7)
5E8: 01412503 : lw x2, 20(x10)
5EC: 01812583 : lw x2, 24(x11)
5F0: 01C12603 : lw x2, 28(x12)
5F4: 02012683 : lw x2, 32(x13)
5F8: 02412703 : lw x2, 36(x14)
5FC: 02812783 : lw x2, 40(x15)
600: 02C12803 : lw x2, 44(x16)
604: 03012883 : lw x2, 48(x17)
608: 03412E03 : lw x2, 52(x28)
60C: 03812E83 : lw x2, 56(x29)
610: 03C12F03 : lw x2, 60(x30)
614: 05010113 : addi x2, x2, 80
mret

290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

294: 00008067 : jalr x0, 0(x1)

1AC: FF9FF06F : jal x0, -8

1A4: 06400513 : addi x10, x0, 100
1A8: 0E0000EF : jal x1, 224

288: FFF00793 : addi x15, x0, -1
28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

28C: FFF50513 : addi x10, x10, -1
290: FEF51EE3 : bne x10, x15, -4

