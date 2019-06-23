# “M” Standard Extension for Integer Multiplication and Division, Version 2.0

```VHDL
rd(63 downto 0) <= rs2(31 downto 0) * rs1(31 downto 0) 

a7(3 downto 0) <= rs1(31 downto 28); 
a6(3 downto 0) <= rs1(27 downto 24); 
a5(3 downto 0) <= rs1(23 downto 20); 
a4(3 downto 0) <= rs1(19 downto 16); 
a3(3 downto 0) <= rs1(15 downto 12); 
a2(3 downto 0) <= rs1(11 downto 8); 
a1(3 downto 0) <= rs1(7 downto 4); 
a0(3 downto 0) <= rs1(3 downto 0); 

b7(3 downto 0) <= rs2(31 downto 28); 
b6(3 downto 0) <= rs2(27 downto 24); 
b5(3 downto 0) <= rs2(23 downto 20); 
b4(3 downto 0) <= rs2(19 downto 16); 
b3(3 downto 0) <= rs2(15 downto 12); 
b2(3 downto 0) <= rs2(11 downto 8); 
b1(3 downto 0) <= rs2(7 downto 4); 
b0(3 downto 0) <= rs2(3 downto 0); 

a(31 downto 0) <= a7*(2^28) + 
 				  a6*(2^24) + 
 				  a5*(2^20) + 
 				  a4*(2^16) + 
 				  a3*(2^12) + 
 				  a2*(2^08) + 
 				  a1*(2^04) + 
 				  a0;

b(31 downto 0) <= b7*(2^28) + 
 				  b6*(2^24) + 
 				  b5*(2^20) + 
 				  b4*(2^16) + 
 				  b3*(2^12) + 
 				  b2*(2^08) + 
 				  b1*(2^04) + 
 				  b0;

rd <= ab7*(2^28) + ab6*(2^24) + ab5*(2^20) + ab4*(2^16) + ab3*(2^12) + ab2*(2^08) + ab1*(2^04) + ab0; 
rd <= a*b

```

![](./img/mul_machine_state.png)