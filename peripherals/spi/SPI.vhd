library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPI is
	generic(
	  n_bits      : integer := 8   );  
	port (
	  i_clk         : in  std_logic;
	  i_rst         : in  std_logic;
	  
	  i_tx_start    : in  std_logic;  							 
	  i_data    	: in  std_logic_vector(n_bits-1 downto 0);  
	  o_data    	: out std_logic_vector(n_bits-1 downto 0)  :=  x"00";  
	  o_tx_end      : out std_logic;  							 
	 
	  i_miso        : in  std_logic  := '0';
	  o_sclk        : out std_logic;
	  o_ss          : out std_logic;
	  o_mosi        : out std_logic;
	  
	  -- debug-- remover depois
	 debug_idle_flag : buffer std_logic;
	 debug_tx_flag   : buffer std_logic;
	 debug_end_flag  : buffer std_logic
	 );
end SPI;


architecture rtl of SPI is
	type spi_state_t is (ST_IDLE,ST_TRANSFER,ST_END);
	signal state           : spi_state_t;
	signal next_state      : spi_state_t := ST_IDLE;
	
	signal counter_bits    : integer range 0 to n_bits;
	signal tx_start_flag   : std_logic;  						  
	signal tx_finish_flag  : std_logic;  						 
	signal cpol 		   : std_logic;
	signal ss        	   : std_logic  := '1';
		
begin
	cpol  <= '0';
	o_ss  <= ss;
	
	fsm : process(i_rst,i_clk,cpol,i_tx_start,ss,next_state)
	               
	begin
		 tx_start_flag <= i_tx_start;
		 state <= next_state;
		 
		if	ss = '0' then
			o_sclk <= i_clk;
		else
			o_sclk <= cpol;
		end if;
		
	    if(i_rst='0') then
		    tx_start_flag  <= '0';
		    o_tx_end       <= '0';
		    o_data         <= (others=>'1');
		    counter_bits   <= n_bits-1;
			ss             <= '1';
		    o_mosi         <= '0';
		   
		   -- Debug
		   debug_idle_flag <= '1';
		   debug_tx_flag   <= '0';
		   debug_end_flag  <= '0';
		    
		elsif(rising_edge(i_clk)) then
		
			case state is
				
				when  ST_IDLE  =>  -- RESET / IDLE
					-- Debug ---------------
			        debug_idle_flag  <= '1';
			   		debug_tx_flag    <= '0';
			  		debug_end_flag   <= '0';
			  		------------------------
			  		
			        o_tx_end         <= '0';
			        counter_bits     <=  n_bits-1;
			        ss               <= '1';
			        o_mosi           <= '0';
			        
			        if(tx_start_flag='1') then   
			     	  next_state  <= ST_TRANSFER ;
			        end if;
		      
		 		when  ST_TRANSFER  => 
		 			-- Debug ---------------
			        debug_idle_flag  <= '0';
			   		debug_tx_flag    <= '1';
			  		debug_end_flag   <= '0';
			  		------------------------
			  		
		  			ss                    <= '0'; 
					o_mosi                <= i_data(counter_bits);		
					o_data(counter_bits)  <= i_miso;		
			        
			    	if counter_bits > 0 then 
			    		counter_bits <= counter_bits - 1;
			    	else 
			    		tx_finish_flag <= '1';
			    		next_state     <= ST_END;
					end if;    
			       
		  	
			    when  ST_END =>
			    	-- Debug ---------------
			        debug_idle_flag  <= '0';
			   		debug_tx_flag    <= '0';
			   		debug_end_flag   <= '1';
			   		------------------------
			   		
			        counter_bits     <=  0;
			        o_tx_end         <= '1';
			        ss               <= '1';
			        o_mosi  		 <= '0';
			        next_state  <= ST_IDLE;  
			     
			    when  others  =>  next_state  <= ST_IDLE;
		  end case;
	 end if;
	end process ;

end rtl;