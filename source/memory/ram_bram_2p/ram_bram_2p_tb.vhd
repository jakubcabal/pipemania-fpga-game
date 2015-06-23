-- ram_bram_2p_tb.vhd
-- Autori: Jakub Cabal
-- Posledni zmena: 20.10.2014
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY RAM_BRAM_2P_TB IS
END RAM_BRAM_2P_TB;
 
ARCHITECTURE behavior OF RAM_BRAM_2P_TB IS 

   --Inputs
   signal CLK       : std_logic := '0';
   signal WE_A      : std_logic := '0';
   signal ADDR_A    : STD_LOGIC_VECTOR(9 downto 0) := (others => '0'); 
   signal DATAIN_A  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

   --Outputs
   signal DATAOUT_A : STD_LOGIC_VECTOR(15 downto 0);

      -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
  -- Instantiate the Unit Under Test (UUT)
   uut: entity work.RAM_BRAM_2P
   port map(
      -- Port A
      CLK_A     => CLK,
      WE_A      => WE_A,
      ADDR_A    => ADDR_A,
      DATAIN_A  => DATAIN_A,
      DATAOUT_A => DATAOUT_A,
      -- Port B - Pouziva ho pouze VGA radic a to poze ke cteni
      CLK_B     => CLK,
      WE_B      => open,
      ADDR_B    => open,
      DATAIN_B  => open,
      DATAOUT_B => open
   );


   -- Clock process definitions
   CLK_process :process
   begin
    CLK <= '0';
    wait for CLK_period/2;
    CLK <= '1';
    wait for CLK_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin    
      -- hold reset state for 100 ns.
    wait for 100 ns;  
    wait until rising_edge(CLK);
    WE_A <= '1';
    ADDR_A <= "0000011111";
    DATAIN_A <= "1111111111000000";
    wait until rising_edge(CLK);
    WE_A <= '0';
    ADDR_A <= "0000011110";
    wait until rising_edge(CLK);
    WE_A <= '0';
    ADDR_A <= "0000011111";
      -- insert stimulus here 

      wait;
   end process;

END;