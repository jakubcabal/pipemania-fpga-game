-- rising_edge_detector.vhd - Modul pro detekci nastupne hrany
-- Autori: Tomas Bannert
-- Posledni zmena: 02.10.2014 21:10
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rising_edge_detector is
    Port ( VSTUP  : in  STD_LOGIC; 	-- VSTUP
           CLK    : in  STD_LOGIC;	-- HODINOVY SIGNAL
           VYSTUP : out  STD_LOGIC);	-- VYSTUP
end rising_edge_detector;

architecture Behavioral of rising_edge_detector is

signal A : STD_LOGIC;			-- POMOCNY SIGNAL
signal B : STD_LOGIC;			-- POMOCNY SIGNAL
signal C : STD_LOGIC;			-- POMOCNY SIGNAL

begin

process(CLK)				-- 2 D FLIP-FLOPS
begin
	if(rising_edge(CLK)) then
		A <= VSTUP;
		VYSTUP <= B;
	end if;
end process;

C <= VSTUP XOR A;			-- XOR GATE
B <= VSTUP AND C;			-- AND GATE

end Behavioral;
