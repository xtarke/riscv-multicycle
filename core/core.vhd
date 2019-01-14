library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core is
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		iaddress  : out  integer range 0 to 31;
		idata	  : in 	std_logic_vector(31 downto 0)
		
	);
end entity core;

architecture RTL of core is
	
	component iregister
		port(
			clk    : in  std_logic;
			rst    : in  std_logic;
			data   : in  std_logic_vector(31 downto 0);
			opcode : out std_logic_vector(6 downto 0);
			funct3 : out std_logic_vector(2 downto 0);
			funct7 : out std_logic_vector(6 downto 0);
			rd     : out integer range 0 to 31;
			rs1    : out integer range 0 to 31;
			rs2    : out integer range 0 to 31;
			imm_i  : out integer;
			imm_s  : out integer;
			imm_b  : out integer;
			imm_u  : out integer;
			imm_j  : out integer
		);
	end component iregister;
	
	component register_file
	port(
		clk        : in  std_logic;
		rst        : in  std_logic;
		w_ena      : in  std_logic;
		w_address  : in  integer range 0 to 31;
		w_data     : in  std_logic_vector(31 downto 0);
		r1_address : in  integer range 0 to 31;
		r1_data    : out std_logic_vector(31 downto 0);
		r2_address : in  integer range 0 to 31;
		r2_data    : out std_logic_vector(31 downto 0)
	);
	end component register_file;
	
	
	signal opcode :  std_logic_vector(6 downto 0);
	signal funct3 :  std_logic_vector(2 downto 0);
	signal funct7 :  std_logic_vector(6 downto 0);
	signal rd     :  integer range 0 to 31;
	signal rs1    :  integer range 0 to 31;
	signal rs2    :  integer range 0 to 31;
	signal imm_i  :  integer;
	signal imm_s  :  integer;
	signal imm_b  :  integer;
	signal imm_u  :  integer;
	signal imm_j  :  integer;
	
	signal rf_w_ena : std_logic;
	signal rd_data	: std_logic_vector(31 downto 0);
	signal rs1_data	: std_logic_vector(31 downto 0);
	signal rs2_data	: std_logic_vector(31 downto 0);
	
	
begin
	
	rf_w_ena <= '1';
	rd_data <= (others => '1');
	
	ireg: component iregister
		port map(
			clk    => clk,
			rst    => rst,
			data   => idata,
			opcode => opcode,
			funct3 => funct3,
			funct7 => funct7,
			rd     => rd,
			rs1    => rs1,
			rs2    => rs2,
			imm_i  => imm_i,
			imm_s  => imm_s,
			imm_b  => imm_b,
			imm_u  => imm_u,
			imm_j  => imm_j
		);
		
	registers: component register_file
		port map(
			clk        => clk,
			rst        => rst,
			w_ena      => rf_w_ena,
			w_address  => rd,
			w_data     => rd_data,
			r1_address => rs1,
			r1_data    => rs1_data,
			r2_address => rs2,
			r2_data    => rs2_data
		);

end architecture RTL;
