library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decoder_types.all;

entity csr is
    port(
        clk     : in std_logic;
        rst     : in std_logic;
        pending_inst : in std_logic;                    --! Pending Instruction
        write   : in std_logic;                         --! Write CSR
        next_pc     :in std_logic_vector(31 downto 0);  --! Next pc generate by current Inst
        csr_addr    :in integer;                        --! CSR address from imm_i
        csr_new     :in std_logic_vector(31 downto 0);  --! New value from rs1_data or imm from rs1
        opcodes     :in opcodes_t;                      --! Instruction decoding information. See decoder_types.vhd
        mret        :in  std_logic;                     --! Machine trap return
        interrupts  :in  std_logic_vector(31 downto 0); --! Bit vector of interrupts, according with "vector_base:" on start.S

        csr_value   :out std_logic_vector(31 downto 0); --! CSR value on current csr_addr
        load_mepc   :out std_logic;                     --! load machine exeption program counter
        mepc_out    :out std_logic_vector(31 downto 0)  --! Value of machine exeption program counter
    );
end entity csr;

architecture RTL of csr is

    signal mstatus_mask : std_logic_vector(31 downto 0);        -- Used to modify CSR MSTATUS between process
    signal pending_interrupts : std_logic_vector(31 downto 0);  -- Register of pending interrupts
    signal mip_in: std_logic_vector(31 downto 0);               -- Signal to store on CSR MIP
    signal mcause_in: unsigned(31 downto 0);            -- Signal to store on CSR MCAUSE
    signal load_mepc_reg:std_logic;                             -- Signal to register load_mepc

    type machine_reg is array (7 downto 0) of std_logic_vector(31 downto 0);
    signal mreg : machine_reg;                                  -- Vector containing the CSRs

    -- Machine Trap Setup registers
    constant MSTATUS    : unsigned(15 downto 0) := x"0_300"; -- Machine Status Register   ( Contains global interrupt-enable )
    constant MIE        : unsigned(15 downto 0) := x"1_304"; -- Machine interrupt-enable register
    constant MTVEC      : unsigned(15 downto 0) := x"2_305"; -- Machine trap-vector base-address register
    constant MTVT       : unsigned(15 downto 0) := x"3_307"; -- Machine irq-vector base-address register
    constant MTVT2      : unsigned(15 downto 0) := x"4_7EC"; -- Machine irq-vector handler entry address

    -- Machine Trap Handling
    constant MEPC       : unsigned(15 downto 0) := x"5_341"; -- Machine Exception program counter
    constant MCAUSE     : unsigned(15 downto 0) := x"6_342"; -- Machine trap cause
    constant MIP        : unsigned(15 downto 0) := x"7_344"; -- Machine interrupt-pending register

    -- CSR Bits
        -- MIP
    constant MIP_MSIP        : std_logic_vector(31 downto 0) := x"00000008"; -- Machine Software interrupt-pending
    constant MIP_MTIP        : std_logic_vector(31 downto 0) := x"00000080"; -- Machine Timer    interrupt-pending
    constant MIP_MEIP        : std_logic_vector(31 downto 0) := x"00000800"; -- Machine Extern   interrupt-pending
        -- MSTATUS
    constant MSTATUS_MIE     : std_logic_vector(31 downto 0) := X"00000008"; -- Global Machine interrupt enable bit
    constant MSTATUS_PIE     : std_logic_vector(31 downto 0) := X"00000080"; -- Global Machine interrupt enable bit holder

    -- interrupts masks
    constant EXTI0_IRQ          : integer := 18;
    constant EXTI1_IRQ          : integer := 19;
    constant EXTI2_IRQ          : integer := 20;
    constant EXTI3_IRQ          : integer := 21;
    constant EXTI4_IRQ          : integer := 22;
    constant EXTI5_9_IRQ        : integer := 23;
    constant EXTI10_15_IRQ      : integer := 24;
    constant TIMER0_0A_IRQHandler     : integer := 25;
    constant TIMER0_0B_IRQHandler     : integer := 26;
    constant TIMER0_1A_IRQHandler     : integer := 27;
    constant TIMER0_1B_IRQHandler     : integer := 28;
    constant TIMER0_2A_IRQHandler     : integer := 29;
    constant TIMER0_2B_IRQHandler     : integer := 30;
    constant UART_IRQHandler          : integer := 31;
    -- TODO: Add more IRQ Handlers


begin


    interrupt_pending_control : process (clk, rst) is
    begin
        if rst = '1' then
            pending_interrupts<=x"0000_0000";
            mip_in<=x"0000_0000";
            mcause_in<=x"0000_0000";

        elsif rising_edge(clk) then
            pending_interrupts<=interrupts or pending_interrupts; -- Register interrupts
            if(mret = '1')then  -- when mret, the previous pending interrupt is cleared
                pending_interrupts <= pending_interrupts and not std_logic_vector(to_unsigned(1,32) sll to_integer(unsigned(mcause_in)-1));
            end if;

            if((mreg(To_integer(MSTATUS   (15 downto 12))) AND MSTATUS_MIE)/=x"00000000")then -- Check if Global Interrupts are Enabled

                if((mreg(To_integer(MIE   (15 downto 12))) and MIP_MTIP ) /=x"0000_0000" and                        -- Check if Timer Interrupts are Enabled
                   (pending_interrupts(TIMER0_2B_IRQHandler downto TIMER0_0A_IRQHandler))/="000000" -- Check if Timer IRQs are Pending
                    )then
                    mip_in<=MIP_MTIP;   --   Set Timer interrupt Pending
                    if(pending_interrupts(TIMER0_0A_IRQHandler)/='0')then
                        mcause_in <= to_unsigned(TIMER0_0A_IRQHandler + 1,32);  -- Set mcause to TIMER0_0A_IRQHandler vector_base address
                    elsif(pending_interrupts(TIMER0_0B_IRQHandler)/='0')then
                        mcause_in <= to_unsigned(TIMER0_0B_IRQHandler + 1,32);
                    elsif(pending_interrupts(TIMER0_1A_IRQHandler)/='0')then
                        mcause_in <= to_unsigned(TIMER0_1A_IRQHandler + 1,32);
                    elsif(pending_interrupts(TIMER0_1B_IRQHandler)/='0')then
                        mcause_in <= to_unsigned(TIMER0_1B_IRQHandler + 1,32);
                    elsif(pending_interrupts(TIMER0_2A_IRQHandler)/='0')then
                        mcause_in <= to_unsigned(TIMER0_2A_IRQHandler + 1,32);
                    elsif(pending_interrupts(TIMER0_2B_IRQHandler)/='0')then
                        mcause_in <= to_unsigned(TIMER0_2B_IRQHandler + 1,32);
                    end if;

                elsif((mreg(To_integer(MIE   (15 downto 12))) and MIP_MEIP ) /=x"0000_0000" and                     -- Check if External Interrupts are Enabled
                      (pending_interrupts(EXTI10_15_IRQ downto EXTI0_IRQ))/="0000000" -- Check if External IRQs are Pending
                    )then
                    mip_in<=MIP_MEIP;   --   Set External interrupt Pending
                    if(pending_interrupts(EXTI0_IRQ)/='0')then
                        mcause_in <= to_unsigned(EXTI0_IRQ + 1,32); -- Set mcause to EXTI0_IRQ vector_base address
                    elsif(pending_interrupts(EXTI1_IRQ)/='0')then
                        mcause_in <= to_unsigned(EXTI1_IRQ + 1,32);
                    elsif(pending_interrupts(EXTI2_IRQ)/='0')then
                        mcause_in <= to_unsigned(EXTI2_IRQ + 1,32);
                    elsif(pending_interrupts(EXTI3_IRQ)/='0')then
                        mcause_in <= to_unsigned(EXTI3_IRQ + 1,32);
                    elsif(pending_interrupts(EXTI4_IRQ)/='0')then
                        mcause_in <= to_unsigned(EXTI4_IRQ + 1,32);
                    elsif(pending_interrupts(EXTI5_9_IRQ)/='0')then
                        mcause_in <= to_unsigned(EXTI5_9_IRQ + 1,32);
                    elsif(pending_interrupts(EXTI10_15_IRQ)/='0')then
                        mcause_in <= to_unsigned(EXTI10_15_IRQ + 1,32);
                    end if;
                  elsif ((mreg(To_integer(MIE   (15 downto 12))) and MIP_MEIP ) /=x"0000_0000" and                     -- Check if External Interrupts are Enabled
                        (pending_interrupts(UART_IRQHandler))/='0' -- Check if External IRQs are Pending
                      ) then
                    mip_in<=MIP_MEIP;
                    mcause_in <= to_unsigned(UART_IRQHandler + 1, 32);
                end if;
            end if;


            if (load_mepc_reg='1' or mret ='1' OR (pending_inst='0' and  ((mreg(To_integer(MIP   (15 downto 12))) and mreg(To_integer(MIE   (15 downto 12)))) /=x"00000000"))) then
                mip_in<=x"0000_0000"; -- Clearing MIP when get in the interrupt
            end if;

        end if;
    end process interrupt_pending_control;






    mstatus_control : process (clk, rst) is
    begin
        if rst = '1' then
            mstatus_mask <= x"00000000";
        elsif rising_edge(clk) then

            -- Register load_mepc value
            case((mret ='1' OR (pending_inst='0' and  ((mreg(To_integer(MIP   (15 downto 12))) and mreg(To_integer(MIE   (15 downto 12)))) /=x"00000000"))))is
                when true => load_mepc_reg <= '1';
                when others => load_mepc_reg <='0';
            end case;

            -- Control mstatus_mask
            if((mreg(To_integer(unsigned(MSTATUS   (15 downto 12)))) AND MSTATUS_MIE)/=x"00000000")then     -- test if global interrupts are enabled
                if((mreg(To_integer(unsigned(MIE   (15 downto 12)))) AND mreg(To_integer(unsigned(MIP   (15 downto 12))))) /= x"00000000")then  -- test if Software|Timer|Extern interrupts are enabled
                    mstatus_mask <= (MSTATUS_MIE or MSTATUS_PIE) xor mstatus_mask;  -- Set MSTATUS_MIE to '0' and MSTATUS_PIE to '1'
                end if;
            elsif (mret='1') then
                mstatus_mask <= (MSTATUS_MIE or MSTATUS_PIE) xor mstatus_mask;  -- Set MSTATUS_MIE to '1' and MSTATUS_PIE to '0'
            else
                mstatus_mask <=x"00000000";
            end if;

        end if;
    end process mstatus_control;





    registers_control : process(clk, rst) is
        variable mrindex: integer range 0 to 31;
        variable protect_mask:std_logic_vector(31 downto 0);    -- Protect read-only bits on registers
    begin
        mrindex:=0;
        protect_mask:=x"00000000";
        if rst = '1' then
            csr_value <= (others=>'0');
            -- Clear all CSR cells
            mreg(0) <=  (others => '0');
            mreg(1) <=  (others => '0');
            mreg(2) <=  (others => '0');
            mreg(3) <=  (others => '0');
            mreg(4) <=  (others => '0');
            mreg(5) <=  (others => '0');
            mreg(6) <=  (others => '0');
            mreg(7) <=  (others => '0');

        elsif rising_edge(clk) then
            -- Get index and protect_mask from CSR of csr_addr
            case (to_unsigned(csr_addr,12)) is
                    when MSTATUS (11 downto 0) =>
                        mrindex:=To_integer(MSTATUS(15 downto 12));
                        protect_mask:="01111111100000000001111011000100";
                    when MIE     (11 downto 0) =>
                        mrindex:=To_integer(MIE    (15 downto 12));
                        protect_mask:="11111111111111111111010001000100";
                    when MTVEC   (11 downto 0) =>
                        mrindex:=To_integer(MTVEC  (15 downto 12));
                    when MTVT    (11 downto 0) =>
                        mrindex:=To_integer(MTVT   (15 downto 12));
                    when MTVT2   (11 downto 0) =>
                        mrindex:=To_integer(MTVT2  (15 downto 12));
                    when MEPC    (11 downto 0) =>
                        mrindex:=To_integer(MEPC   (15 downto 12));
                        protect_mask:="11111111111111111111111111111111";
                    when MCAUSE  (11 downto 0) =>
                        mrindex:=To_integer(MCAUSE (15 downto 12));
                        protect_mask:="11111111111111111111111111111111";
                    when MIP     (11 downto 0) =>
                        mrindex:=To_integer(MIP    (15 downto 12));
                        protect_mask:="11111111111111111111111111111111";
                    when others =>
                        mrindex:=7;
                        if(write = '1')then
                            report "Not implemented" severity Failure;
                        end if;
                end case;

            -- write the CSR value according with instruction
            if (write = '1') then
                case opcodes.funct3(1 downto 0) is
                    when "01" =>                    -- CSRRW / CSRRWI
                        mreg(mrindex) <= (mreg(mrindex) AND protect_mask) OR (csr_new AND (NOT protect_mask));
                    when "10" =>                    -- CSRRS / CSRRSI
                        mreg(mrindex) <= mreg(mrindex) OR (csr_new AND (NOT protect_mask));
                    when "11" =>                    -- CSRRC / CSRRCI
                        mreg(mrindex) <= mreg(mrindex) AND (NOT (csr_new AND (NOT protect_mask)));
                    when others =>
                        report "Not implemented" severity Failure;
                end case;

            end if;


            csr_value <= mreg(mrindex); -- Read value from CSR of csr_addr

            mreg(To_integer(MIP    (15 downto 12))) <= mip_in;    -- Update MIP
            mreg(To_integer(MCAUSE (15 downto 12))) <= std_logic_vector(mcause_in); -- Update MCAUSE


            if(mrindex /= To_integer(MSTATUS(15 downto 12)))then
                mreg(To_integer(MSTATUS(15 downto 12))) <= mreg(To_integer(MSTATUS (15 downto 12))) xor mstatus_mask; -- Update MSTATUS with mask
            end if;

            if(load_mepc_reg='1')then
                mreg(To_integer(MEPC   (15 downto 12)))<=next_pc;    -- Save MEPC when get in a interrupt
            end if;

        end if;

    end process registers_control;



    with (mret ='1' OR (pending_inst='0' and  ((mreg(To_integer(MIP   (15 downto 12))) and mreg(To_integer(MIE   (15 downto 12)))) /=x"00000000"))) select
            load_mepc<= '1' when true,  -- Set value of load_mepc
                        '0' when others;

    with mret select                    -- Set mepc_out when get in/out a interrupt
        mepc_out <= mreg(To_integer(unsigned(MTVT2   (15 downto 12)))) and x"fffffffC" when '0',
                    mreg(To_integer(unsigned(MEPC   (15 downto 12)))) when '1',
                    x"00000000" when others;

end architecture RTL;
