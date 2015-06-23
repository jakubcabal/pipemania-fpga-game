-- ps2_rx.vhd - Modul pro prijem signalu z portu PS2
-- Autori: Jakub Cabal
-- Posledni zmena: 04.10.2014
-- Popis: Tato jednotka zajistuje prijem dat z PS2 portu v cetne kontroly parity
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PS2_RX is
   Port (
      CLK          : in   STD_LOGIC; -- Vychozi hodinovy signal
      RST          : in   STD_LOGIC; -- Vychozi synchronni reset
      PS2C         : in   STD_LOGIC; -- Hodinovy signal z PS2 portu
      PS2D         : in   STD_LOGIC; -- Seriova vstupni data z PS2 portu
      PS2RX_DATA   : out  STD_LOGIC_VECTOR(7 downto 0); -- Vystupni data
      PS2RX_VALID  : out  STD_LOGIC  -- Data jsou pripravena na vycteni
   );
end PS2_RX;

architecture FULL of PS2_RX is

   signal ps2_valid       : STD_LOGIC;
   signal parity_valid    : STD_LOGIC;
   signal parity_ctrl     : STD_LOGIC;
   signal parity_ps2      : STD_LOGIC;
   signal ps2_bit_count   : STD_LOGIC_VECTOR(3 downto 0);
   signal sig_ps2rx_data  : STD_LOGIC_VECTOR(7 downto 0);
   signal sig_ps2rx_data2 : STD_LOGIC_VECTOR(7 downto 0);

   type state is (idle, dps, load);
   signal present_st : state;
   signal next_st    : state;

begin

   -- Detektor sestupne hrany
   falling_edge_detector_1: entity work.FALLING_EDGE_DETECTOR
   port map(
      CLK    => CLK,
      VSTUP  => PS2C,
      VYSTUP => ps2_valid  -- Pri sestupne hrane jsou validni data
   );

   ----------------------------------------------------------------
   -- STAVOVY AUTOMAT
   ----------------------------------------------------------------

   -- Pametova cast stavoveho automatu
   process (CLK) 
   begin
      if (rising_edge(CLK)) then
         if (RST = '1') then
            present_st <= idle;
         else
            present_st <= next_st;
         end if;
      end if;   
   end process;

   -- Rozhodovaci cast stavoveho automatu
   process (present_st, PS2D, ps2_valid, ps2_bit_count)
   begin
      case present_st is
     
         when idle =>
            if (ps2_valid = '1' AND PS2D = '0') then
               next_st <= dps;
            else
               next_st <= idle;
            end if;

         when dps =>
            if (ps2_bit_count = 11) then
               next_st <= load;
            else
               next_st <= dps;
            end if;

         when load =>
            next_st <= idle;
         
      end case;
   end process;

   -- Vystupni cast stavoveho automatu
   process (present_st, parity_valid)
   begin
      case present_st is
     
         when idle =>
            PS2RX_VALID <= '0';

         when dps =>
            PS2RX_VALID <= '0';

         when load =>
            if (parity_valid = '1') then
               PS2RX_VALID <= '1';
            else
               PS2RX_VALID <= '0';
            end if;
         
      end case;
   end process;

   ----------------------------------------------------------------
   -- PREVOD DAT
   ----------------------------------------------------------------

   -- Citac poradi bitu v ramci
   process (CLK) 
   begin
      if (rising_edge(CLK)) then
         if (RST = '1') then 
            ps2_bit_count <= (others => '0');
         elsif (ps2_bit_count = 11) then  
            ps2_bit_count <= (others => '0'); 
         elsif (ps2_valid = '1') then
            ps2_bit_count <= ps2_bit_count + 1;
         end if;
      end if;
   end process; 

   -- Cteni dat z PS2D
   process (CLK) 
   begin
      if (rising_edge(CLK)) then
         if (ps2_valid = '1') then 
            if (ps2_bit_count = 9) then 
               parity_ps2 <= PS2D;
            elsif (ps2_bit_count > 0 AND ps2_bit_count < 9) then 
               sig_ps2rx_data(6 downto 0) <= sig_ps2rx_data(7 downto 1);
               sig_ps2rx_data(7) <= PS2D;
            end if;
         end if;
      end if;
   end process; 

   -- Propagace PS2 dat na vystup
   process (CLK) 
   begin
      if (rising_edge(CLK)) then
         if (RST = '1') then 
            sig_ps2rx_data2 <= (others => '0');
         elsif (ps2_bit_count = 10) then
            sig_ps2rx_data2 <= sig_ps2rx_data;
         end if;
      end if;
   end process;

   PS2RX_DATA <= sig_ps2rx_data2; 
   
   ----------------------------------------------------------------
   -- KONTROLA PARITY
   ----------------------------------------------------------------

   parity_ctrl <= sig_ps2rx_data2(7) xor sig_ps2rx_data2(6) xor sig_ps2rx_data2(5) xor sig_ps2rx_data2(4)
              xor sig_ps2rx_data2(3) xor sig_ps2rx_data2(2) xor sig_ps2rx_data2(1) xor sig_ps2rx_data2(0) xor '1';

   -- Kontrola parity
   process (CLK) 
   begin
      if (rising_edge(CLK)) then
         if (RST = '1') then 
            parity_valid <= '0';
         elsif (parity_ctrl = parity_ps2) then
            parity_valid <= '1';
         else
            parity_valid <= '0';
         end if;
      end if;
   end process;

end FULL;