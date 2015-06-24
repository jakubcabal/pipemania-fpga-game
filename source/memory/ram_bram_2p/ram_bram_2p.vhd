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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM_BRAM_2P is
   Generic (
      DATA_WIDTH : integer := 32; -- Sirka datoveho vstupu a vystupu
      ADDR_WIDTH : integer := 9   -- Sirka adresove sbernice, urcuje take pocet polozek v pameti (2^ADDR_WIDTH)
   );
   Port (
      CLK       : in  STD_LOGIC;
      -- Port A      
      WE_A      : in  STD_LOGIC := '0'; -- Povoluje zapis
      ADDR_A    : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0) := (others => '0');
      DATAIN_A  : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
      DATAOUT_A : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
      -- Port B
      ADDR_B    : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0) := (others => '0'); 
      DATAOUT_B : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0')
   );                    
end RAM_BRAM_2P;

architecture FULL of RAM_BRAM_2P is

   type RamType is array((2**ADDR_WIDTH)-1 downto 0) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
   signal ram : RamType := (others => (others => '0'));

begin

   process (CLK)
   begin
      if rising_edge(CLK) then
            if (WE_A = '1') then
               ram(to_integer(unsigned(ADDR_A))) <= DATAIN_A;
            end if;          
            DATAOUT_A <= ram(to_integer(unsigned(ADDR_A)));
      end if;
   end process;

   process (CLK)
   begin
      if rising_edge(CLK) then
         DATAOUT_B <= ram(to_integer(unsigned(ADDR_B)));  
      end if;
   end process;

end FULL;