-- Genetic_divider.vhd
-- Autori: Vojtech Jerabek
-- Posledni zmena: 21.10.2014
-- Popis: deli parametricky clk. parametr "Period" urcuje celkovou periodu enable signalu. 
--			"flip_flops" kolik je potreba decek flip_flops = (log(Period) / log(2)) zaokrouhlujte nahoru 		
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity WTR_CLK is
	generic 	(
													-- kolik clocku bude mit cela periona.
				Flip_flops : natural := 26 -- kolik je na to potreba Decek
								   			   -- flip_flops = (log(Period) / log(2)) zaokrouhlujte nahoru
				);
					
	Port 		(
				CLK	 	  : in  STD_LOGIC;
				RST	 	  : in  STD_LOGIC;
				CLOCK_DEFI : in  STD_LOGIC_VECTOR(Flip_flops-1 downto 0);
				ENABLE_OUT : out STD_LOGIC
				);
			  
end WTR_CLK;

architecture Behavioral of WTR_CLK is

	signal counter_p : STD_LOGIC_VECTOR(Flip_flops-1 downto 0);		

begin
	process(CLK) begin
		if (rising_edge(CLK)) then
			if(RST='1') then
					ENABLE_OUT 	<= '1';
					counter_p <= (others=>'0');
			else
				if (counter_p = clock_defi) then
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