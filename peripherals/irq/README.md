# Como Adicionar Novos Perifericos ao Tratador de Interrupções.

1. Adicionar o simbolo da função IRQHandler, no arquivo `/software/_core/start.S`.

```
.section .init
	
    .weak  EXTI0_IRQHandler
    .weak  EXTI1_IRQHandler
    .weak  EXTI2_IRQHandler
    .weak  EXTI3_IRQHandler
    .weak  EXTI4_IRQHandler
    .weak  EXTI5_9_IRQHandler
    .weak  EXTI10_15_IRQHandler
    .weak  TIMER0_0A_IRQHandler
    .weak  TIMER0_0B_IRQHandler
    .weak  TIMER0_1A_IRQHandler
    .weak  TIMER0_1B_IRQHandler
    .weak  TIMER0_2A_IRQHandler
    .weak  TIMER0_2B_IRQHandler
// TODO: Add more IRQ Handlers 
//    .weak  UART0_IRQHandler           
//    .weak  SPI0_IRQHandler           
//    .weak  I2C0_IRQHandler           
//    .weak  ADC0_IRQHandler   
```

2. Adicionar simbolo da função IRQHandler no vetor de ponteiros de funçôes, no arquivo `/software/_core/start.S`.
```
vector_base:
    j _start
    .align    2
    .word     0
    ... 
    .word  	  0       
    .word     EXTI0_IRQHandler          // 18
    .word     EXTI1_IRQHandler          // 19
    .word     EXTI2_IRQHandler          // 20
    .word     EXTI3_IRQHandler          // 21
    .word     EXTI4_IRQHandler          // 22
    .word     EXTI5_9_IRQHandler        // 23
    .word     EXTI10_15_IRQHandler      // 24
    .word     TIMER0_0A_IRQHandler      // 25
    .word     TIMER0_0B_IRQHandler      // 26
    .word     TIMER0_1A_IRQHandler      // 27
    .word     TIMER0_1B_IRQHandler      // 28
    .word     TIMER0_2A_IRQHandler      // 29
    .word     TIMER0_2B_IRQHandler      // 30
// TODO: Add more IRQ Handlers 
//    .word     UART0_IRQHandler          // 31    
//    .word     SPI0_IRQHandler           // 32
//    .word     I2C0_IRQHandler           // 33
//    .word     ADC0_IRQHandler           // 34
```

3. Adicionar a posição do simbolo da função IRQHandler no arquivo `/core/csr.vhd`
```
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
    -- TODO: Add more IRQ Handlers 
```
4. Adicionar a condição que altera o `mcause_in` para o simbolo da função IRQHandler no arquivo `/core/csr.vhd`.
```
if((mreg(To_integer(MSTATUS   (15 downto 12))) AND MSTATUS_MIE)/=x"00000000")then -- Check if Global Interrupts are Enabled 
    ...
    ...
    elsif((mreg(To_integer(MIE   (15 downto 12))) and MIP_MEIP ) /=x"0000_0000" and -- Check if External Interrupts are Enabled 
      (pending_interrupts(UART0_IRQHandler))/='0' -- Check if UART0 IRQ is Pending
      )then
        mip_in<=MIP_MEIP;   --   Set External interrupt Pending
        if(pending_interrupts(EXTI0_IRQ)/='0')then
          mcause_in <= to_unsigned(UART0_IRQHandler + 1,32); -- Set mcause to EXTI0_IRQ vector_base address
          end if;
    end if;    
end if;
```

5. Adicionar ao periferio um bit de sinalização para a interrupção, que deve ser acionado por um ciclo e retornado a zero, exemplo em `/peripherals/gpio/gpio.vhd`
![Bilby Stampede](https://i.imgur.com/xSS6Ud4.png)

6. Conectar o bit de sinalização do item 5 ao barramento "interrupts" do 'core'. exemplo em `/peripherals/irq/de10_lite.vhd`.
```
  interrupts(17 downto 0)<= (others => '0');
		interrupts(24 downto 18)<=gpio_interrupts(6 downto 0);
		interrupts(30 downto 25) <= timer_interrupt;
		interrupts(31)<='0';
	-- Softcore instatiation
	myRiscv : entity work.core
		generic map(
			IMEMORY_WORDS => IMEMORY_WORDS,
			DMEMORY_WORDS => DMEMORY_WORDS
		)
		port map(
			clk      => clk,
			rst      => rst,
			iaddress => iaddress,
			idata    => idata,
			daddress => daddress,
			ddata_r  => ddata_r,
			ddata_w  => ddata_w,
			d_we     => d_we,
			d_rd     => d_rd,
			d_sig	 => d_sig,
			dcsel    => dcsel,
			dmask    => dmask,
			interrupts=>interrupts,
			state    => state
		);
```
7. Adicionar no software a função a ser chamada pela interrupção, exemplo em `/software/irq/irq_example.c`.
```
void EXTI0_IRQHandler(void)
{
	OUTBUS = 0x52;
}
```
8. Adicionar no software a hablitação das interrupções globais e externas, exemplo em `/software/irq/irq_example.c`.
```
int main(){

	extern_interrupt_enable(true);
	global_interrupt_enable(true);
	
	while (1){
        ...
	}

	return 0;
}


```


