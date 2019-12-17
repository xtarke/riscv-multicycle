// TODO "Navigate to include file"
//      Hold the Ctrl key and click on the filename `constants.vh` below
`include "constants.svh"

typedef int unused_type;

// TODO "Hover on preprocessor directive"
//      Hovering over "`MAGIC_NUMBER" shows the initialization of the macro!
//
//      Click on the link at the bottom of the hover to open the preprocessor view.
//      This shows what the file looks like after macro expansion.

/* This is the device under test "dut" */
module dut#(iterations = `MAGIC_NUMBER)(output logic valid, logic[7:0] data_out, input logic start, clk, rst, [7:0] data_in);

	logic [7:0] count;
	logic [7:0] result;

	always_ff @(count)
	// TODO "Navigate to declaration"
	//      Click on `MAX_COUNT and press **F3** (or **Ctrl+Left click**) to
	//      go to the declaration of the macro.
	//
	//      Go ahead and F3 on count and other things as well.
	if (count >= `MAX_COUNT)
		begin
			$display ("count out of range");
			$stop;
		end

	typedef enum {idle, preparing, running, ready} states_t;
	states_t state;

	always_ff @(posedge rst or posedge clk) begin
		if (rst)
			begin
				state = idle;
				count <= 0;
				valid <= 0;
				result <= 0;
			end
		else
			case (state)
				// TODO "Auto complete state"
				//      Press **Ctrl+Space** before the `:` and start typing
				//      `idle`. The missing state will be suggested.
				:
				begin
					// TODO "Navigate using Quick Outline"
					//      Press **Ctrl+O** and type `valid` to find the
					//      declaration of `valid`
					valid <= 1'b0;
					result <= {8{1'b0}};
				end
				preparing:
				if (start == 1'b1)
					begin
						count <= 0;
						state = running;
					end
				running:
				begin
					if (count == iterations)
						begin
							state = ready;
							result <= result * data_in;
						end
					count <= count + 1;
				end
				ready:
				begin
					data_out <= result;
					valid <= 1'b1;
					state = idle;
				end
			endcase
	end
endmodule
