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
	  
	  -- debug-- remove it later
	 debug_idle_flag : buffer std_logic;
	 debug_tx_flag   : buffer std_logic;
	 debug_end_flag  : buffer std_logic
	 );
end SPI;


architecture rtl of SPI is
	type spi_state_t is (ST_IDLE,ST_TRANSFER,ST_END);
	signal state           : spi_state_t;
	signal next_state      : spi_state_t;
	
	signal counter_clock        : integer range 0 to n_bits*2;
	signal counter_clock_en     : std_logic;
	signal counter_bits         : integer range 0 to n_bits;
	signal tx_start_flag        : std_logic;  						    -- start TX on serial line
	signal tx_finish_flag       : std_logic;  						    -- finish TX on serial line
	signal tx_data              : std_logic_vector(n_bits-1 downto 0);  -- data to sent
	signal rx_data              : std_logic_vector(n_bits-1 downto 0);  -- received data
	signal counter_data_flag    : std_logic;	
	signal cpol 				: std_logic;
		
begin
	cpol  <= '0';
	
	--- FSM sinc Update
	sinc : process(i_clk,i_rst)
	begin
	  if(i_rst='0') then
	    state <= ST_IDLE;
	  elsif(rising_edge(i_clk)) then
	  	state <= next_state;
	  end if;
	end process ;

 o_sclk           <= i_clk;

	-- FSM check next state
	fsm : process(state, tx_start_flag, tx_finish_flag)
	               
	begin
		case state is
			
		when  ST_IDLE  =>  -- RESET / IDLE
	      if(tx_start_flag='1') then   
	     	  next_state  <= ST_TRANSFER ;
	      else                      
	      	  next_state  <= ST_IDLE ; 
	      end if;
	      
	    when  ST_TRANSFER  => 
	      if (tx_finish_flag = '1') then  
	     	next_state  <= ST_END;
	      else                                                         
	      	next_state  <= ST_TRANSFER;
	      end if;
	      
	    when  ST_END => 					
	      if (tx_start_flag = '0') then
	         next_state  <= ST_IDLE;  
	      else
	         next_state  <= ST_END;  
	     end if;
	     
	    when  others  =>  next_state  <= ST_IDLE;
	  end case;
	end process ;


	-- Update values according to the state
	state_out : process(i_clk,i_rst)
	begin
	  if(i_rst='0') then
	    tx_start_flag      <= '0';
	    tx_data            <= (others=>'0');
	    rx_data            <= (others=>'0');
	    o_tx_end           <= '0';
	    o_data             <= (others=>'0');
	    counter_bits       <= n_bits-1;
	    counter_clock_en   <= '0';
--	    o_sclk             <= cpol;
	    o_ss               <= '1';
	    o_mosi             <= '0';
	   
	   -- Debug
	   debug_idle_flag  <= '1';
	   debug_tx_flag    <= '0';
	   debug_end_flag   <= '0';
	    
	  elsif(rising_edge(i_clk)) then
	  	tx_start_flag <= i_tx_start;
	  	
	  	case state is
	  		
	  	when ST_IDLE =>  -- ST_RESET	  		
	        tx_data          <= i_data;          
	        o_tx_end         <= '0';
	        counter_bits     <=  n_bits-1;
	        counter_clock_en <= '0';
--	        o_sclk           <= cpol;
	        o_ss             <= '1';
	        o_mosi           <= '0';
	        o_data  		 <=  x"00";
	        
	        -- Debug
	        debug_idle_flag  <= '1';
	   		debug_tx_flag    <= '0';
	  		debug_end_flag   <= '0';
	  		
	  	when ST_TRANSFER =>	   
--	        o_tx_end         <= '0';
--	        o_sclk           <= i_clk;    
			o_mosi                <= tx_data(counter_bits);
			rx_data(counter_bits) <= i_miso;
--	        counter_clock_en <= '1';			
	        o_ss             <= '0';	  		
	        
	    	if counter_bits > 0 then 
	    		counter_bits <= counter_bits -1;
	    	else 
	    		tx_finish_flag  <= '1';
	    		 o_data         <=  rx_data;
	    	end if;    
	        
	        -- Debug
	        debug_idle_flag  <= '0';
	   		debug_tx_flag    <= '1';
	  		debug_end_flag   <= '0';
	        
	    when ST_END =>	   
	        o_tx_end         <= '1';
	        counter_clock_en <= '0';
--	        o_data <=  rx_data;
	        o_ss             <= '1';
	        
	        -- Debug
	        debug_idle_flag  <= '0';
	   		debug_tx_flag    <= '0';
	   		debug_end_flag   <= '1';
	              
	        when others  => 
	    end case;
	  end if;
	end process state_out;
	
	
--	-- Clock  Counter
--	count_clock : process(i_clk,i_rst)
--	begin
--	  if(i_rst='0') then
--	    counter_bits       <=  n_bits-1;
--	    
--	  elsif(rising_edge(i_clk)) then
--	    if(counter_clock_en='1') then        
--	    	if counter_bits > 0 then 
--	    		counter_bits <= counter_bits -1;
--	    	else 
--	    		counter_data_flag  <= '1';
--	    		tx_finish_flag     <= '1';
--	    		counter_bits       <=  n_bits-1;
--	    	end if;
--	    else
--	    	  counter_bits <=  n_bits-1;
--	    end if;
--	  end if;
--	end process ;
end rtl;