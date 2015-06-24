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

entity MEM_HUB is
   Port (
      CLK    : in   STD_LOGIC; -- Vychozi hodinovy signal
      RST    : in   STD_LOGIC; -- Vychozi synchronni reset
      -- Port A
      EN_A   : in   STD_LOGIC; -- Povoleni prace s portem A
      WE_A   : in   STD_LOGIC; -- Povoleni zapisu
      ADDR_A : in   STD_LOGIC_VECTOR(7 downto 0);  -- Adresa
      DIN_A  : in   STD_LOGIC_VECTOR(31 downto 0); -- Vstupni data
      DOUT_A : out  STD_LOGIC_VECTOR(31 downto 0); -- Vystupni data
      ACK_A  : out  STD_LOGIC; -- Potvrzeni prace s portem A
      -- Port B
      EN_B   : in   STD_LOGIC; -- Povoleni prace s portem B
      WE_B   : in   STD_LOGIC; -- Povoleni zapisu
      ADDR_B : in   STD_LOGIC_VECTOR(7 downto 0);  -- Adresa
      DIN_B  : in   STD_LOGIC_VECTOR(31 downto 0); -- Vstupni data
      DOUT_B : out  STD_LOGIC_VECTOR(31 downto 0); -- Vystupni data  
      ACK_B  : out  STD_LOGIC; -- Potvrzeni prace s portem B
      -- Output port
      WE     : out  STD_LOGIC; -- Povoleni zapisu
      ADDR   : out  STD_LOGIC_VECTOR(7 downto 0);  -- Adresa
      DIN    : out  STD_LOGIC_VECTOR(31 downto 0); -- Vstupni data
      DOUT   : in   STD_LOGIC_VECTOR(31 downto 0)  -- Vystupni data  
   );
end MEM_HUB;

architecture FULL of MEM_HUB is

   signal sig_ack_a      : STD_LOGIC;
   signal sig_ack_b      : STD_LOGIC;
   signal last_ack_a     : STD_LOGIC;
   signal last_ack_b     : STD_LOGIC;

begin

   process (WE_A, WE_B, EN_A, EN_B, ADDR_A, ADDR_B, DIN_A, DIN_B) 
   begin
      if (EN_A = '1') then
         WE        <= WE_A;
         ADDR      <= ADDR_A;
         DIN       <= DIN_A;
         sig_ack_a <= '1';
         sig_ack_b <= '0';
      elsif (EN_B = '1') then
         WE        <= WE_B;
         ADDR      <= ADDR_B;
         DIN       <= DIN_B;
         sig_ack_a <= '0';
         sig_ack_b <= '1';
      else
         WE        <= '0';
         ADDR      <= (others => '0');
         DIN       <= (others => '0');
         sig_ack_a <= '0';
         sig_ack_b <= '0';
      end if;   
   end process;

   ACK_A <= sig_ack_a;
   ACK_B <= sig_ack_b;

   process (last_ack_a, last_ack_b, DOUT) 
   begin
      if (last_ack_a = '1') then
         DOUT_A <= DOUT;
         DOUT_B <= (others => '0');
      elsif (last_ack_b = '1') then
         DOUT_A <= (others => '0');
         DOUT_B <= DOUT;
      else
         DOUT_A <= (others => '0');
         DOUT_B <= (others => '0');
      end if;   
   end process;

   process (CLK) 
   begin
      if (rising_edge(CLK)) then
         if (RST = '1') then
            last_ack_a <= '0';
            last_ack_b <= '0';
         else
            last_ack_a <= sig_ack_a;
            last_ack_b <= sig_ack_b;
         end if;
      end if;   
   end process;

end FULL;