	component adc is
		port (
			clock_clk                  : in  std_logic                     := 'X';             -- clk
			reset_sink_reset_n         : in  std_logic                     := 'X';             -- reset_n
			adc_pll_clock_clk          : in  std_logic                     := 'X';             -- clk
			adc_pll_locked_export      : in  std_logic                     := 'X';             -- export
			sequencer_csr_address      : in  std_logic                     := 'X';             -- address
			sequencer_csr_read         : in  std_logic                     := 'X';             -- read
			sequencer_csr_write        : in  std_logic                     := 'X';             -- write
			sequencer_csr_writedata    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			sequencer_csr_readdata     : out std_logic_vector(31 downto 0);                    -- readdata
			sample_store_csr_address   : in  std_logic_vector(6 downto 0)  := (others => 'X'); -- address
			sample_store_csr_read      : in  std_logic                     := 'X';             -- read
			sample_store_csr_write     : in  std_logic                     := 'X';             -- write
			sample_store_csr_writedata : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			sample_store_csr_readdata  : out std_logic_vector(31 downto 0);                    -- readdata
			sample_store_irq_irq       : out std_logic                                         -- irq
		);
	end component adc;

	u0 : component adc
		port map (
			clock_clk                  => CONNECTED_TO_clock_clk,                  --            clock.clk
			reset_sink_reset_n         => CONNECTED_TO_reset_sink_reset_n,         --       reset_sink.reset_n
			adc_pll_clock_clk          => CONNECTED_TO_adc_pll_clock_clk,          --    adc_pll_clock.clk
			adc_pll_locked_export      => CONNECTED_TO_adc_pll_locked_export,      --   adc_pll_locked.export
			sequencer_csr_address      => CONNECTED_TO_sequencer_csr_address,      --    sequencer_csr.address
			sequencer_csr_read         => CONNECTED_TO_sequencer_csr_read,         --                 .read
			sequencer_csr_write        => CONNECTED_TO_sequencer_csr_write,        --                 .write
			sequencer_csr_writedata    => CONNECTED_TO_sequencer_csr_writedata,    --                 .writedata
			sequencer_csr_readdata     => CONNECTED_TO_sequencer_csr_readdata,     --                 .readdata
			sample_store_csr_address   => CONNECTED_TO_sample_store_csr_address,   -- sample_store_csr.address
			sample_store_csr_read      => CONNECTED_TO_sample_store_csr_read,      --                 .read
			sample_store_csr_write     => CONNECTED_TO_sample_store_csr_write,     --                 .write
			sample_store_csr_writedata => CONNECTED_TO_sample_store_csr_writedata, --                 .writedata
			sample_store_csr_readdata  => CONNECTED_TO_sample_store_csr_readdata,  --                 .readdata
			sample_store_irq_irq       => CONNECTED_TO_sample_store_irq_irq        -- sample_store_irq.irq
		);

