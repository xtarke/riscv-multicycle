architecture STR of testbench is
	signal data_out : unsigned(7 downto 0);
	signal data_in  : unsigned(7 downto 0);
	signal valid    : std_logic;
	signal start    : std_logic;
	signal clk      : std_logic;
	signal rst      : std_logic;

	---------------------------------------------------------------------------
	-- TODO "Hover"
	--      In the line below, hover your mouse over the word MAX_COUNT.
	--      Notice how the data type and value show up in a pop-up.  
	--      Go ahead and hover over other things too!
	---------------------------------------------------------------------------

	constant iterations : integer := MAX_COUNT - 4; -- iterations constant

begin
	---------------------------------------------------------------------------
	-- TODO "Open declaration"
	--      In the line below, place your cursor on the word `dut` and press
	--      **F3**. This takes you to the declaration of the entity `dut`.
	---------------------------------------------------------------------------

	dut_instance : entity work.dut(RTL)
		generic map(
			iterations => iterations
		)
		port map(
			data_out => data_out,
			data_in  => data_in,
			valid    => valid,
			start    => start,
			clk      => clk,
			rst      => rst
		);

	assert valid = '0' or data_out /= "00000000";

end architecture STR;
