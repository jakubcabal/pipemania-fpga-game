-- falling_edge_detector.vhd - Modul pro detekci sestupne hrany
-- Autori: Tomáš Bannert
-- Posledni zmena: 02.10.2014 21:20
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

 
ENTITY rising_edge_detector_TB IS
END rising_edge_detector_TB;
 
ARCHITECTURE behavior OF rising_edge_detector_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rising_edge_detector
    PORT(
         VSTUP  : IN  std_logic;
         CLK    : IN  std_logic;
         VYSTUP : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal VSTUP  : std_logic := '0';
   signal CLK    : std_logic := '0';

   --Outputs
   signal VYSTUP : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rising_edge_detector PORT MAP (
          VSTUP => VSTUP,
          CLK => CLK,
          VYSTUP => VYSTUP
        );


   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		wait for 100 ns;	
			VSTUP <= '0';
		wait for 100 ns;
			VSTUP <= '1';
		wait for 100 ns;	
			VSTUP <= '0';
		wait for 100 ns;
			VSTUP <= '1';
      -- insert stimulus here 

      wait;
   end process;

END;