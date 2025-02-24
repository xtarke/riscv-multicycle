	component rotacao is
		port (
			source : out std_logic_vector(31 downto 0)   -- source
		);
	end component rotacao;

	u0 : component rotacao
		port map (
			source => CONNECTED_TO_source  -- sources.source
		);

