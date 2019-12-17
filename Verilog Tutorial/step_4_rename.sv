module clock_generator;
	timeunit 1ns;
	timeprecision 10ps;

	// TODO "Rename a local element"
	//      Click on `PERIOD` and press **Shift+Alt+R** to rename this
	//      parameter to e.g. `PERIOD25`.
	
	localparam PERIOD = 2.5ns;
	bit clk = 0;

	always
	begin: CLOCK_DRIVER
		#(PERIOD) clk=~clk;
	end
endmodule : clock_generator
