iram_quartus_inst : iram_quartus PORT MAP (
		address	 => address_sig,
		byteena	 => byteena_sig,
		clock	 => clock_sig,
		data	 => data_sig,
		wren	 => wren_sig,
		q	 => q_sig
	);
