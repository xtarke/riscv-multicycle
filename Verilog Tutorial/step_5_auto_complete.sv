// TODO: "Auto complete to create a module"
//       Press **Ctrl+Space** behind `mod` to create a module.
//
// You can use **Ctrl+Space** in different contexts to get different autocompletes.
mod

typedef struct {
	bit INITIALIZED;
	bit NOT_INITIALIZED;
} state;

module mod2;
	state state_f;
	always_ff @(*) begin
		// TODO "Autocomplete structs"
		//      Press Ctrl+Space after "." to get autocomplete suggestions
		//      for the enum values of state_f. Type "IN" to filter the list
		//      of suggestions down to "INITIALIZED".
		if (state_f.)
			$display("Initialized");
		else
			$display("Not initialized");
	end
endmodule
