library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;
use work.alu_types.all;

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
			opcodes : out opcodes_t;		
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
		
	component decoder
		port(
			clk        : in  std_logic;
			rst        : in  std_logic;
			pc_inc     : out std_logic;
			pc_load    : out std_logic;
			pcMux      : out std_logic;
			opcodes    : in  opcodes_t;
			ulaMuxData : out std_logic_vector(1 downto 0);
			ulaCod     : out std_logic_vector(2 downto 0);
			
			reg_write	: out std_logic
		);
	end component decoder;
	
	component ULA
		port(
			alu_data : in  alu_data_t;
			dataOut  : out integer
		);
	end component ULA;
	
	signal pc : integer range 0 to 31;
	signal opcodes :  opcodes_t;

	signal rd     :  integer range 0 to 31;
	signal rs1    :  integer range 0 to 31;
	signal rs2    :  integer range 0 to 31;
	signal imm_i  :  integer;
	signal imm_s  :  integer;
	signal imm_b  :  integer;
	signal imm_u  :  integer;
	signal imm_j  :  integer;
	
	signal rf_w_ena : std_logic;
	signal rw_data	: std_logic_vector(31 downto 0);
	signal rs1_data	: std_logic_vector(31 downto 0);
	signal rs2_data	: std_logic_vector(31 downto 0);
	
	--! Signals for alu control
	signal alu_data : alu_data_t;
	signal alu_out : integer;
	
	--! Controls signals
	signal pc_inc     : std_logic;
	signal pc_load    : std_logic;
	signal pcMux      : std_logic;
	signal ulaMuxData : std_logic_vector(1 downto 0);
	
	
	signal temp	: std_logic_vector(31 downto 0);
	
begin
	
	pc_blk: block
	begin		
		pc_proc: process (clk, rst)
		begin			
			if rst = '1' then 
				pc <= 0;
			else
				if rising_edge(clk) then
					if pc_inc = '1' then
						pc <= pc + 1;
					end if;
				end if;
			end if;			
		end process;
		
		iaddress <= pc;	
	end block;
		
	ireg: component iregister
		port map(
			clk    => clk,
			rst    => rst,
			data   => idata,
			opcodes => opcodes,
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
			w_data     => rw_data,
			r1_address => rs1,
			r1_data    => rs1_data,
			r2_address => rs2,
			r2_data    => rs2_data
		);
		
	alu_data.a <= to_integer(signed(rs1_data));
	alu_data.b <= to_integer(signed(rs2_data));
	
	rw_data <= (others => '1');
		
	decoder0: component decoder
		port map(
			clk        => clk,
			rst        => rst,
			pc_inc     => pc_inc,
			pc_load    => pc_load,
			pcMux      => pcMux,
			opcodes    => opcodes,
			ulaMuxData => ulaMuxData,
			ulaCod     => alu_data.code,
			reg_write  => rf_w_ena
		);
	
	
	
	alu_0: component ULA
		port map(
			alu_data => alu_data,
			dataOut  => alu_out
		);
		
	

end architecture RTL;

