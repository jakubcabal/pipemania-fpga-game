-- falling_edge_detector.vhd - Modul pro detekci sestupne hrany
-- Autori: Jakub Cabal
-- Posledni zmena: 02.10.2014 19:45
-- Popis: Tato jednotka detekuje sestupnou hranu vstupniho signalu
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FALLING_EDGE_DETECTOR is
   Port (
      CLK    : in   STD_LOGIC; -- Vychozi hodinovy signal
      VSTUP  : in   STD_LOGIC; -- Vstup na detekci sestupne hrany
      VYSTUP : out  STD_LOGIC  -- Vystup je aktivni pokud byla detekovana sestupna hrana
   );
end FALLING_EDGE_DETECTOR;

architecture FULL of FALLING_EDGE_DETECTOR is

   signal predchozi_vstup : STD_LOGIC;
	signal sig_vystup      : STD_LOGIC;

begin
   
   -- Registr, ktery uchovava hodnotu vstupu z predchoziho taktu
   process(CLK)
   begin
      if(rising_edge(CLK)) then
         predchozi_vstup <= VSTUP;
			VYSTUP          <= sig_vystup;
      end if;
   end process;

   sig_vystup <= NOT vstup AND predchozi_vstup;

end FULL;