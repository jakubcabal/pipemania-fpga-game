-- random_generator.vhd
-- Autori: Vojtech Jerabek
-- Posledni zmena: 9.11.2014
-- Popis: Generuje nahodna cisla od 0 do 10. Lze genericky menit. !!!! zmenit i hodnotu "Flip_Flops" NUTNE !!!!!
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity random_generator is
	generic 	(
				Number_of_options 		 	: natural:=12; 	--z kolika nahodnych moznosti chete vybirat.
				Flip_Flops						: natural:=4		--pocet Decek k tomu nutnych. Flip_flops = (log(Number_of_options) / log(2)) zaokrouhlujte nahoru
				);

	Port 		(
				CLK	 			: in  STD_LOGIC;
				RANDOM_PULSE	: in  STD_LOGIC;											--pro provedeni nahodne generace sem privedte enable signal
				RST	 			: in  STD_LOGIC;
				RANDOM_OUT		: out STD_LOGIC_vector (Flip_Flops-1 downto 0);	--zde se objevi nahodna hodnota. vydrzi zde az do dalsiho pulzu
				ENABLE_OUT		: out	STD_LOGIC
				);

end random_generator;

architecture Behavioral of random_generator is
	signal 	counter	 		: std_logic_vector(Flip_flops-1 downto 0);		--citac pro vyber nahodneho cisla
	signal 	divider2	 		: std_logic;												--zde je clk/2
	
begin
-----------------------------------------------------------
--vydeleni CLK dvema---
	process(CLK) begin
		if (falling_edge(CLK)) then
			if(RST='1') then
				divider2 <= '0';
			else	
				if (divider2='0') then
					divider2 <= '1';
				elsif (divider2='1') then
					divider2 <= '0';
				end if;
			end if;
		end if;
	end process;
	
-----------------------------------------------------------
--na counteru se pocita od nuly do (Flip_Flops-1)---

	process(CLK) begin
		if (rising_edge(CLK)) then
			if(RST='1') then
				counter <= (others=>'0');
			else
				if (divider2='1') then
					if(counter=(number_of_options-1)) then
						counter <= (others=>'0');
					else
						counter <= counter + 1;
					end if;
				end if;
			end if;
		end if;
	end process;
	
-----------------------------------------------------------
--pokud je na RANDOM_PULSE log. 1, objevi se na RANDOM_OUT aktualni hodnota counteru---
	
	process(CLK) begin
		if (rising_edge(CLK)) then
			if(RST='1') then
				RANDOM_OUT 	<= (others=>'0');
			else
				if (RANDOM_PULSE='1') then
					RANDOM_OUT <= counter;	
					ENABLE_OUT <='1';
				else
					ENABLE_OUT <='0';
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;