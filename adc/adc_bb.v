
module adc (
	clock_clk,
	reset_sink_reset_n,
	adc_pll_clock_clk,
	adc_pll_locked_export,
	sequencer_csr_address,
	sequencer_csr_read,
	sequencer_csr_write,
	sequencer_csr_writedata,
	sequencer_csr_readdata,
	sample_store_csr_address,
	sample_store_csr_read,
	sample_store_csr_write,
	sample_store_csr_writedata,
	sample_store_csr_readdata,
	sample_store_irq_irq);	

	input		clock_clk;
	input		reset_sink_reset_n;
	input		adc_pll_clock_clk;
	input		adc_pll_locked_export;
	input		sequencer_csr_address;
	input		sequencer_csr_read;
	input		sequencer_csr_write;
	input	[31:0]	sequencer_csr_writedata;
	output	[31:0]	sequencer_csr_readdata;
	input	[6:0]	sample_store_csr_address;
	input		sample_store_csr_read;
	input		sample_store_csr_write;
	input	[31:0]	sample_store_csr_writedata;
	output	[31:0]	sample_store_csr_readdata;
	output		sample_store_irq_irq;
endmodule
