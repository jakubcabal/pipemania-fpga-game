-- ps2_debouncer.vhd - PS2 Debouncer
-- Autori: Jakub Cabal
-- Posledni zmena: 16.10.2014
-- Popis: Tato jednotka zajistuje ochranu pred zakmity na PS2C
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PS2_DEBOUNCER is
   Port (
      CLK      : in   STD_LOGIC; -- Vychozi hodinovy signal
      PS2C     : in   STD_LOGIC; -- Hodinovy signal z PS2 portu
      PS2C_DEB : out  STD_LOGIC  -- Osetreny vystupni signal PS2C
   );
end PS2_DEBOUNCER;

architecture FULL of PS2_DEBOUNCER is

   signal sig_d       : STD_LOGIC_VECTOR (7 downto 0);

begin

   process(CLK)
   begin
      if(rising_edge(CLK)) then
         sig_d <= sig_d(6 downto 0) & PS2C;
      end if;
   end process;

   PS2C_DEB <= sig_d(0) AND sig_d(1) AND sig_d(2) AND sig_d(3) AND sig_d(4) AND sig_d(5) AND sig_d(6) AND sig_d(7);

end FULL;