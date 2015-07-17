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
 
ENTITY MEM_HUB_TB IS
END MEM_HUB_TB;
 
ARCHITECTURE behavior OF MEM_HUB_TB IS 

   -- CLK and RST
   signal CLK                : STD_LOGIC := '0';
   signal RST                : STD_LOGIC := '0';

   -- Memory signals
   signal sig_we_hub         : STD_LOGIC;
   signal sig_addr_hub       : STD_LOGIC_VECTOR (8 downto 0);
   signal sig_dout_hub       : STD_LOGIC_VECTOR (31 downto 0);
   signal sig_din_hub        : STD_LOGIC_VECTOR (31 downto 0);

   -- MEM_HUB signals
   signal hub_we_a           : STD_LOGIC;
   signal hub_en_a           : STD_LOGIC;
   signal hub_addr_a         : STD_LOGIC_VECTOR (8 downto 0);
   signal hub_din_a          : STD_LOGIC_VECTOR (31 downto 0);
   signal hub_dout_a         : STD_LOGIC_VECTOR (31 downto 0);
   signal hub_ack_a          : STD_LOGIC;

   signal hub_we_b           : STD_LOGIC;
   signal hub_en_b           : STD_LOGIC;
   signal hub_addr_b         : STD_LOGIC_VECTOR (8 downto 0);
   signal hub_din_b          : STD_LOGIC_VECTOR (31 downto 0);
   signal hub_dout_b         : STD_LOGIC_VECTOR (31 downto 0);
   signal hub_ack_b          : STD_LOGIC;
	
   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
  -- Instantiate the Unit Under Test (UUT)
   uut: entity work.MEM_HUB
   port map(
      CLK    => CLK,
      RST    => RST,
      -- Port A
      EN_A   => hub_en_a,
      WE_A   => hub_we_a,
      ADDR_A => hub_addr_a,
      DIN_A  => hub_din_a,
      DOUT_A => hub_dout_a,
      ACK_A  => hub_ack_a,
      -- Port B
      EN_B   => hub_en_b,
      WE_B   => hub_we_b,
      ADDR_B => hub_addr_b,
      DIN_B  => hub_din_b,
      DOUT_B => hub_dout_b,
      ACK_B  => hub_ack_b,
      -- Port to memory
      WE     => sig_we_hub,
      ADDR   => sig_addr_hub,
      DIN    => sig_din_hub,
      DOUT   => sig_dout_hub
   );


	-- Instantiate the Unit Under Test (UUT)
   mem: entity work.RAM_BRAM_2P
   port map(
      -- Port A
      CLK       => CLK,
      WE_A      => sig_we_hub,
      ADDR_A    => sig_addr_hub,
      DATAIN_A  => sig_din_hub,
      DATAOUT_A => sig_dout_hub,
      -- Port B
      ADDR_B    => "000000000",
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
      hub_en_a <= '1';
	   hub_we_a <= '1';
      hub_addr_a <= "000000001";
      hub_din_a <= "11111111110000001111111111000000";
	wait until rising_edge(CLK);
      hub_en_a <= '1';
      hub_we_a <= '1';
      hub_addr_a <= "000000010";
      hub_din_a <= "11111111111111111111111111111111";
	wait until rising_edge(CLK);
      hub_en_a <= '1';
      hub_we_a <= '1';
      hub_addr_a <= "000000011";
      hub_din_a <= "00000001111111111100000000011111";
   wait until rising_edge(CLK);
      hub_en_a <= '1';
      hub_we_a <= '0';
      hub_addr_a <= "000000001";
      hub_din_a <= "00000000000000000000000000000000";
   wait until rising_edge(CLK);
      hub_en_a <= '0';
      hub_we_a <= '0';
      hub_addr_a <= "000000000";
	wait until rising_edge(CLK);
      hub_en_a <= '1';
      hub_we_a <= '0';
      hub_addr_a <= "000000000";
   wait until rising_edge(CLK);
      hub_en_a <= '1';
      hub_we_a <= '0';
      hub_addr_a <= "000000001";
	wait until rising_edge(CLK);
      hub_en_a <= '1';
      hub_we_a <= '0';
      hub_addr_a <= "000000010";
	wait until rising_edge(CLK);
      hub_en_a <= '1';
      hub_we_a <= '0';
      hub_addr_a <= "000000011";
	wait until rising_edge(CLK);
      hub_en_a <= '0';
      hub_we_a <= '0';
      hub_addr_a <= "000000000";
   wait;
   end process;

END;