-- Genetic_divider.vhd
-- Autori: Vojtech Jerabek
-- Posledni zmena: 21.10.2014
-- Popis: deli parametricky clk. parametr "Period" urcuje celkovou periodu enable signalu. 
--			"flip_flops" kolik je potreba decek flip_flops = (log(Period) / log(2)) zaokrouhlujte nahoru 		
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity Genetic_divider is
	generic 	(
				Period 		 	: natural:=2;											--kolik clocku bude mit cela periona. takze napr pri Period=
				Flip_flops		: natural:=30											--kolik je na to potreba Decek (defaultni hodnota je 30 z cehoz date asi 21 sekund, ale zbytecne tim berete Decka, takze pokud chcete jenom overit funkcnost, nemusite se s tim jebat)
																								--flip_flops = (log(Period) / log(2)) zaokrouhlujte nahoru
				);
					
	Port 		(
				CLK	 			: in  STD_LOGIC;
				RST	 			: in  STD_LOGIC;
				ENABLE_OUT		: out  STD_LOGIC
				);
			  
end Genetic_divider;

architecture Behavioral of Genetic_divider is

	signal 	counter_p 		: std_logic_vector(Flip_flops-1 downto 0);		

begin
	process(CLK) begin
		if (rising_edge(CLK)) then
			if(RST='1') then
					ENABLE_OUT 	<= '1';
					counter_p <= (others=>'0');
			else
				if (counter_p = Period) then
					ENABLE_OUT 	<= '1';
					counter_p <= (others=>'0');
				else
					ENABLE_OUT 	<= '0';
					counter_p 	<= counter_p+1;
				end if;
			end if;
		end if;
	end process;
end Behavioral;

-- priklad uziti komponenty
------------------------------------------------------------
--component Genetic_divider?
-- generic 	(
--				Period 		 	: natural:=2;											
--				flip_flops		: natural:=30											
--				);
--					
--	Port 		(
--				clk	 			: in  STD_LOGIC;
--				enable_out 		: out  STD_LOGIC
--				);
--				
--end component;
--
--unit1: Genetic_divider
--  generic map (Period   => 10, flip_flops => 4)
--  port map    (
--					...
--					...
--					);