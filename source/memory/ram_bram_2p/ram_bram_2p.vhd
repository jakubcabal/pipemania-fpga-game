-- ram_bram_2p.vhd
-- Autori: Jakub Cabal
-- Posledni zmena: 20.10.2014
-- Popis: Dvouportova blokova RAM pamet s genericky volitelnou sirkou datové a adresove sbernice
------------------------------------------------------------------------------------------------
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
      EN_A      : in  STD_LOGIC := '0'; -- Povoluje praci s pameti
      WE_A      : in  STD_LOGIC := '0'; -- Povoluje zapis
      ADDR_A    : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0) := (others => '0');
      DATAIN_A  : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
      DATAOUT_A : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
      -- Port B
      EN_B      : in  STD_LOGIC := '0'; -- Povoluje praci s pameti
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
         if(EN_A = '1') then
            if (WE_A = '1') then
               ram(to_integer(unsigned(ADDR_A))) <= DATAIN_A;
            else
               DATAOUT_A <= ram(to_integer(unsigned(ADDR_A)));
            end if;
         end if; 
      end if;
   end process;

   process (CLK)
   begin
      if rising_edge(CLK) then
         if (EN_B = '1') then
            DATAOUT_B <= ram(to_integer(unsigned(ADDR_B)));  
         end if;
      end if;
   end process;

end FULL;