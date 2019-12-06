module find_references;
	wire [7:0] data_out;
	wire [7:0] data_in;
	wire valid;
	wire start;
	wire clk;
	wire rst;
	
	// TODO "Find references"
	//      Right click on `data_out` and click "Find references". Do this for
	//      both the **port** (left) and local **wire** (right) and notice how
	//      Sigasi Studio shows the correct results in the **Search View**. In
	//      the Search view, you can press the [+]-icon to expand all search
	//      results.
	
	dut dut_instance (
		.data_out(data_out),
		.data_in(data_in),
		.valid(valid),
		.start(start),
		.clk(clk),
		.rst(rst)
	);
endmodule
