	adc u0 (
		.clock_clk                  (<connected-to-clock_clk>),                  //            clock.clk
		.reset_sink_reset_n         (<connected-to-reset_sink_reset_n>),         //       reset_sink.reset_n
		.adc_pll_clock_clk          (<connected-to-adc_pll_clock_clk>),          //    adc_pll_clock.clk
		.adc_pll_locked_export      (<connected-to-adc_pll_locked_export>),      //   adc_pll_locked.export
		.sequencer_csr_address      (<connected-to-sequencer_csr_address>),      //    sequencer_csr.address
		.sequencer_csr_read         (<connected-to-sequencer_csr_read>),         //                 .read
		.sequencer_csr_write        (<connected-to-sequencer_csr_write>),        //                 .write
		.sequencer_csr_writedata    (<connected-to-sequencer_csr_writedata>),    //                 .writedata
		.sequencer_csr_readdata     (<connected-to-sequencer_csr_readdata>),     //                 .readdata
		.sample_store_csr_address   (<connected-to-sample_store_csr_address>),   // sample_store_csr.address
		.sample_store_csr_read      (<connected-to-sample_store_csr_read>),      //                 .read
		.sample_store_csr_write     (<connected-to-sample_store_csr_write>),     //                 .write
		.sample_store_csr_writedata (<connected-to-sample_store_csr_writedata>), //                 .writedata
		.sample_store_csr_readdata  (<connected-to-sample_store_csr_readdata>),  //                 .readdata
		.sample_store_irq_irq       (<connected-to-sample_store_irq_irq>)        // sample_store_irq.irq
	);

