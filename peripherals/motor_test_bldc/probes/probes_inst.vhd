	component probes is
		port (
			source : out std_logic_vector(19 downto 0);                    -- source
			probe  : in  std_logic_vector(19 downto 0) := (others => 'X')  -- probe
		);
	end component probes;

	u0 : component probes
		port map (
			source => CONNECTED_TO_source, -- sources.source
			probe  => CONNECTED_TO_probe   --  probes.probe
		);

