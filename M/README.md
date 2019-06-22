# “M” Standard Extension for Integer Multiplication and Division, Version 2.0

```VHDL
rd(63 downto 0) <= rs2(31 downto 0) * rs1(31 downto 0) 

rs2(31 downto 0) <= rs2_7(3 downto 0)*(2^28) + 
 				    rs2_6(3 downto 0)*(2^24) + 
 				    rs2_5(3 downto 0)*(2^20) + 
 				    rs2_4(3 downto 0)*(2^16) + 
 				    rs2_3(3 downto 0)*(2^12) + 
 				    rs2_2(3 downto 0)*(2^08) + 
 				    rs2_1(3 downto 0)*(2^04) + 
 				    rs2_0(3 downto 0); 

rs1(31 downto 0) <= rs1_7(3 downto 0)*(2^28) + 
 				    rs1_6(3 downto 0)*(2^24) + 
 				    rs1_5(3 downto 0)*(2^20) + 
 				    rs1_4(3 downto 0)*(2^16) + 
 				    rs1_3(3 downto 0)*(2^12) + 
 				    rs1_2(3 downto 0)*(2^08) + 
 				    rs1_1(3 downto 0)*(2^04) + 
 				    rs1_0(3 downto 0); 
```

```VHDL
rd(63 downto 0) <= rs2(31 downto 0) * rs1(31 downto 0) 

rs2(31 downto 0) <= rs2_7(3 downto 0)*(2^28) + 
 				    rs2_6(3 downto 0)*(2^24) + 
 				    rs2_5(3 downto 0)*(2^20) + 
 				    rs2_4(3 downto 0)*(2^16) + 
 				    rs2_3(3 downto 0)*(2^12) + 
 				    rs2_2(3 downto 0)*(2^08) + 
 				    rs2_1(3 downto 0)*(2^04) + 
 				    rs2_0(3 downto 0); 

rs1(31 downto 0) <= rs1_7(3 downto 0)*(2^28) + 
 				    rs1_6(3 downto 0)*(2^24) + 
 				    rs1_5(3 downto 0)*(2^20) + 
 				    rs1_4(3 downto 0)*(2^16) + 
 				    rs1_3(3 downto 0)*(2^12) + 
 				    rs1_2(3 downto 0)*(2^08) + 
 				    rs1_1(3 downto 0)*(2^04) + 
 				    rs1_0(3 downto 0); 
```

```
rd <= rs2 * rs1 

rs2 <=	rs2_7*(2^28) + rs2_6*(2^24) + rs2_5*(2^20) + rs2_4*(2^16) + rs2_3*(2^12) + rs2_2*(2^08) + rs2_1*(2^04) + rs2_0; 

rs1(31 downto 0) <= rs1_7(3 downto 0)*(2^28) + 
 				    rs1_6(3 downto 0)*(2^24) + 
 				    rs1_5(3 downto 0)*(2^20) + 
 				    rs1_4(3 downto 0)*(2^16) + 
 				    rs1_3(3 downto 0)*(2^12) + 
 				    rs1_2(3 downto 0)*(2^08) + 
 				    rs1_1(3 downto 0)*(2^04) + 
 				    rs1_0(3 downto 0); 
```


![](./img/mul_machine_state.png)