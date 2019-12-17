////////////////////////////////////////////////////////////////////////////////
// Welcome!
////////////////////////////////////////////////////////////////////////////////
// You made a great choice installing Sigasi Studio, and now you are ready to
// unlock its power.
//
// This demo file will guide you on your first steps. In about five minutes
// you will have learned the basics of how Sigasi helps you work
// with SystemVerilog files.
//
// TODO In the SystemVerilog files of this project, follow the comments that
//      are marked 'TODO'.
////////////////////////////////////////////////////////////////////////////////

// TODO "Format"
//      Sigasi Studio can format your SystemVerilog code. This can greatly
//      enhance the readability of your code.
//      Press **Shift+Ctrl+F** to format the current file.

module testbench;

localparam half_iterations = 50;

// TODO "Block select mode"
//      Press Shift+Alt+A to activate block selection mode. Then, select both
//      numbers '7' on the lines below. Type to change several lines at once.
//
//      Press Shift+Alt+A again, to exit block selection mode.

wire [7:0] data_out; // more info about data_out
wire [7:0] data_in;

// TODO "Move lines around"
//      Place your cursor on the line below and press **Alt+Down** or
//      **Alt+Up** to move the line
wire valid; // more info about valid
wire start;
wire clk;
wire rst;

// TODO "Hover to see documentation"
//      On the statement below, hover your mouse over the words `valid` and
//      `data_out`. A pop-up window will appear and show you the documentation
//      for the two wires.

	always_ff @(valid or data_out)
		if ((valid == 1) || (data_out != 0)
			////////////////////////////////////////////////////////////////////
			// TODO "Fix syntax issue"
			//      Add the closing parenthesis ")" on the previous line to fix
			//      the syntax issue.
			////////////////////////////////////////////////////////////////////
			$stop; 

// TODO "Open your own file"
//      Now that you know the first basics about editing in Sigasi Studio, open
//      your own (System)Verilog file in single file mode: 
//      **Drag and drop** your file into this editor from your file explorer,
//      or click **File > Open File ...**

// TODO "Navigate to module"
//      If you don't have a Sigasi Studio license,
//      request your trial license at http://www.sigasi.com/try
//
// Next, on the line below, hold the **Ctrl** key and click on the word `dut`.
// This will open the file and declaration of that module.

	dut #(half_iterations * 2) dut_instance(
		.data_out(data_out),
		.data_in(data_in),
		.valid(valid),
		.start(start),
		.clk(clk),
		.rst(rst));
endmodule
