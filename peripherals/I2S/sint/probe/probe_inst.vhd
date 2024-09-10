	component probe is
		port (
			probe : in std_logic_vector(95 downto 0) := (others => 'X')  -- probe
		);
	end component probe;

	u0 : component probe
		port map (
			probe => CONNECTED_TO_probe  -- probes.probe
		);

