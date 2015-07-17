-- The MIT License (MIT)
--
-- Copyright (c) 2014 Jakub Cabal
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.      
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY RAM_BRAM_2P_TB IS
END RAM_BRAM_2P_TB;
 
ARCHITECTURE behavior OF RAM_BRAM_2P_TB IS 

   -- CLK and RST
   signal CLK       : STD_LOGIC := '0';
   signal WE_A      : STD_LOGIC := '0';

   -- Block memory signals
   signal ADDR_A    : STD_LOGIC_VECTOR(9 downto 0)  := (others => '0'); 
   signal DATAIN_A  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
   signal DATAOUT_A : STD_LOGIC_VECTOR(15 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
  -- Instantiate the Unit Under Test (UUT)
   uut: entity work.RAM_BRAM_2P
   port map(
      -- Port A
      CLK       => CLK,
      WE_A      => WE_A,
      ADDR_A    => ADDR_A,
      DATAIN_A  => DATAIN_A,
      DATAOUT_A => DATAOUT_A,
      -- Port B (only for read)
      ADDR_B    => open,
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

      wait;

   end process;

END;