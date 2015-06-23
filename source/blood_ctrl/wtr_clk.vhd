-- The MIT License (MIT)
--
-- Copyright (c) 2014 Ondřej Dujíček, Vojtěch Jeřábek
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity WTR_CLK is
    generic (
        Flip_flops : natural := 26 -- flip_flops = (log(Period) / log(2)) zaokrouhlujte nahoru
    );					
	Port (
        CLK        : in  STD_LOGIC;
        RST        : in  STD_LOGIC;
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