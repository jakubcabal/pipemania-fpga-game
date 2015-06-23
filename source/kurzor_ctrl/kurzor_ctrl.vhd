-- kurzor_ctrl.vhd
-- Autori: Jakub Cabal, Ondrej Dujicek
-- Posledni zmena: 04.12.2014
-- Popis: Tato jednotka zajistuje vsechny operace provadene kurzorem
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity KURZOR_CTRL is
   Port (
      CLK          : in   STD_LOGIC; -- Vychozi hodinovy signal
      RST          : in   STD_LOGIC; -- Vychozi synchronni reset
      KEY_W        : in   STD_LOGIC; -- Signal znacici zmacknuti tlacitka W
      KEY_S        : in   STD_LOGIC; -- Signal znacici zmacknuti tlacitka S
      KEY_A        : in   STD_LOGIC; -- Signal znacici zmacknuti tlacitka A
      KEY_D        : in   STD_LOGIC; -- Signal znacici zmacknuti tlacitka D
      KEY_SPACE    : in   STD_LOGIC; -- Signal znacici zmacknuti tlacitka SPACE
      KOMP_GEN     : out  STD_LOGIC; -- Generuj novou nahodnou komponentu
      KURZOR_ADDR  : out  STD_LOGIC_VECTOR(7 downto 0);  -- Adresa pozice kurzoru
      DATAIN       : in   STD_LOGIC_VECTOR(31 downto 0); -- Vstupni data
      DATAOUT      : out  STD_LOGIC_VECTOR(31 downto 0); -- Vystupni data
      ADDR         : out  STD_LOGIC_VECTOR(7 downto 0);  -- Vystupni data
      WE           : out  STD_LOGIC; -- Write enable
      EN           : out  STD_LOGIC; -- Enable pameti
      ACK          : in   STD_LOGIC; -- Potvrzeni zapisoveho nebo cteciho prikazu
      KOMP4        : in   STD_LOGIC_VECTOR (5 downto 0);
      CANT_PLACE   : out  STD_LOGIC;
      CAN_PLACE    : out  STD_LOGIC;
      GAME_ON      : in   STD_LOGIC;
      MAIN_SC      : in   STD_LOGIC;
      LVL2_SC      : in   STD_LOGIC;
      LVL3_SC      : in   STD_LOGIC;
      LVL4_SC      : in   STD_LOGIC
   ); 
end KURZOR_CTRL;

architecture FULL of KURZOR_CTRL is

   signal sig_kurzor_addr : STD_LOGIC_VECTOR(7 downto 0);
   signal reset_addr      : STD_LOGIC_VECTOR(7 downto 0);
   signal kurzor_x        : STD_LOGIC_VECTOR(3 downto 0) := "0000";
   signal kurzor_y        : STD_LOGIC_VECTOR(3 downto 0) := "0000";
   signal uprdownl        : STD_LOGIC_VECTOR(3 downto 0);
   signal reset_en        : STD_LOGIC;
   signal reset_ok        : STD_LOGIC;

   signal lvl2_addr      : STD_LOGIC_VECTOR(7 downto 0);
   signal lvl2_addr_next : STD_LOGIC_VECTOR(7 downto 0);
   signal lvl2_en        : STD_LOGIC;
   signal lvl2_ok        : STD_LOGIC;
   signal lvl2_komp      : STD_LOGIC_VECTOR(1 downto 0);

   signal lvl3_addr      : STD_LOGIC_VECTOR(7 downto 0);
   signal lvl3_addr_next : STD_LOGIC_VECTOR(7 downto 0);
   signal lvl3_en        : STD_LOGIC;
   signal lvl3_ok        : STD_LOGIC;
   signal lvl3_komp      : STD_LOGIC_VECTOR(1 downto 0);

   signal lvl4_addr      : STD_LOGIC_VECTOR(7 downto 0);
   signal lvl4_addr_next : STD_LOGIC_VECTOR(7 downto 0);
   signal lvl4_en        : STD_LOGIC;
   signal lvl4_ok        : STD_LOGIC;
   signal lvl4_komp      : STD_LOGIC_VECTOR(1 downto 0);

   type state is (st0, st1, st2, st3, st4, st5, st6, st7);
   signal present_st : state;
   signal next_st    : state;

   constant zeros_22 : STD_LOGIC_VECTOR(21 downto 0) := (others => '0'); -- Konstanta 22 nul

begin

   ----------------------------------------------------------------
   -- RIZENI KURZORU
   ----------------------------------------------------------------

   -- Rizeni kurzoru
   process (CLK) 
   begin
      if (rising_edge(CLK)) then
         if (RST = '1' OR GAME_ON = '0') then 
            kurzor_x <= "0000";
            kurzor_y <= "0000";
         elsif (GAME_ON = '1') then
            if (KEY_W = '1' AND kurzor_y > 0) then
               kurzor_y <= kurzor_y - 1;
            elsif (KEY_S = '1' AND kurzor_y < 12) then
               kurzor_y <= kurzor_y + 1;
            elsif (KEY_A = '1' AND kurzor_x > 0) then
               kurzor_x <= kurzor_x - 1;
            elsif (KEY_D = '1' AND kurzor_x < 13) then
               kurzor_x <= kurzor_x + 1;
            end if;
         end if;
      end if;
   end process;

   sig_kurzor_addr <= kurzor_y & kurzor_x;
   KURZOR_ADDR     <= sig_kurzor_addr;

   ----------------------------------------------------------------
   -- VKLADANI ROUR - STAVOVY AUTOMAT
   ----------------------------------------------------------------

   -- Pametova cast stavoveho automatu
   process (CLK) 
   begin
      if (rising_edge(CLK)) then
         if (RST = '1' OR MAIN_SC = '1') then
            present_st <= st4;
         else
            present_st <= next_st;
         end if;
      end if;   
   end process;

   -- Rozhodovaci cast stavoveho automatu
   process (present_st, KEY_SPACE, ACK, DATAIN, reset_ok, GAME_ON, LVL2_SC, LVL3_SC, LVL4_SC, lvl2_ok, lvl3_ok, lvl4_ok)
   begin
      case present_st is
     
         when st0 => -- cekani na stisk klavesy
            if (KEY_SPACE = '1' AND GAME_ON = '1') then
               next_st <= st1;
            elsif (LVL2_SC = '1') then
               next_st <= st5;
            elsif (LVL3_SC = '1') then
               next_st <= st6;
            elsif (LVL4_SC = '1') then
               next_st <= st7;
            else
               next_st <= st0;
            end if;

         when st1 => -- vycteni dat o vybranem policku
            if (ACK = '1') then
               next_st <= st2;
            elsif (LVL2_SC = '1') then
               next_st <= st5;
            elsif (LVL3_SC = '1') then
               next_st <= st6;
            elsif (LVL4_SC = '1') then
               next_st <= st7;
            else
               next_st <= st1;
            end if;

         when st2 => -- kontrola vyctenych dat
            if (DATAIN(3 downto 0) = "0000") then
               next_st <= st3;
            elsif (LVL2_SC = '1') then
               next_st <= st5;
            elsif (LVL3_SC = '1') then
               next_st <= st6;
            elsif (LVL4_SC = '1') then
               next_st <= st7;
            else
               next_st <= st0;
            end if;

         when st3 => -- vlozeni trubky (zapis dat do pameti)
            if (ACK = '1') then
               next_st <= st0;
            elsif (LVL2_SC = '1') then
               next_st <= st5;
            elsif (LVL3_SC = '1') then
               next_st <= st6;
            elsif (LVL4_SC = '1') then
               next_st <= st7;
            else
               next_st <= st3;
            end if;

         when st4 => -- resetovani pameti
            if (reset_ok = '1') then
               next_st <= st0;
            else
               next_st <= st4;
            end if;

         when st5 => -- generovani lvl2
            if (lvl2_ok = '1') then
               next_st <= st0;
            else
               next_st <= st5;
            end if;

         when st6 => -- generovani lvl3
            if (lvl3_ok = '1') then
               next_st <= st0;
            else
               next_st <= st6;
            end if;

         when st7 => -- generovani lvl4
            if (lvl4_ok = '1') then
               next_st <= st0;
            else
               next_st <= st7;
            end if;

         when others =>
            next_st <= st0;
         
      end case;
   end process;

   -- Vystupni cast stavoveho automatu
   process (present_st, KOMP4, sig_kurzor_addr, uprdownl, reset_addr, DATAIN, lvl2_komp, lvl2_addr, lvl3_addr, lvl3_komp, lvl4_addr, lvl4_komp)
   begin
      case present_st is

         when st0 =>
            EN       <= '0';
            WE       <= '0';
            ADDR     <= (others=>'0');
            DATAOUT  <= (others=>'0');
            KOMP_GEN <= '0';
            reset_en <= '0';
            lvl2_en  <= '0';
            lvl3_en  <= '0';
            lvl4_en  <= '0';
            CANT_PLACE <= '0';
            CAN_PLACE  <= '0';

         when st1 =>
            EN       <= '1';
            WE       <= '0';
            ADDR     <= sig_kurzor_addr;
            DATAOUT  <=  (others=>'0');
            KOMP_GEN <= '0';
            reset_en <= '0';
            lvl2_en  <= '0';
            lvl3_en  <= '0';
            lvl4_en  <= '0';
            CANT_PLACE <= '0';
            CAN_PLACE  <= '0';

        when st2 =>
            EN       <= '0';
            WE       <= '0';
            ADDR     <= (others=>'0');
            DATAOUT  <= (others=>'0');
            KOMP_GEN <= '0';
            reset_en <= '0';
            lvl2_en  <= '0';
            lvl3_en  <= '0';
            lvl4_en  <= '0';
            CAN_PLACE  <= '0';
            if (DATAIN(3 downto 0) = "0000") then
               CANT_PLACE <= '0';
            else
               CANT_PLACE <= '1';
            end if;

         when st3 =>
            EN       <= '1';
            WE       <= '1';
            ADDR     <= sig_kurzor_addr;
            DATAOUT  <=  zeros_22 & uprdownl & KOMP4;
            KOMP_GEN <= '1';
            reset_en <= '0';
            lvl2_en  <= '0';
            lvl3_en  <= '0';
            lvl4_en  <= '0';
            CANT_PLACE <= '0';
            CAN_PLACE  <= '1';

         when st4 =>
            EN       <= '1';
            WE       <= '1';
            ADDR     <= reset_addr;
            DATAOUT  <= (others=>'0');
            KOMP_GEN <= '0';
            reset_en <= '1';
            lvl2_en  <= '0';
            lvl3_en  <= '0';
            lvl4_en  <= '0';
            CANT_PLACE <= '0';
            CAN_PLACE  <= '0';

         when st5 => -- generovani levlu 2
            EN       <= '1';
            WE       <= '1';
            ADDR     <= lvl2_addr;
            DATAOUT  <= "0000000000000000000000000000" & lvl2_komp & "00";
            KOMP_GEN <= '0';
            reset_en <= '0';
            lvl2_en  <= '1';
            lvl3_en  <= '0';
            lvl4_en  <= '0';
            CANT_PLACE <= '0';
            CAN_PLACE  <= '0';

         when st6 => -- generovani levlu 3
            EN       <= '1';
            WE       <= '1';
            ADDR     <= lvl3_addr;
            DATAOUT  <= "0000000000000000000000000000" & lvl3_komp & "00";
            KOMP_GEN <= '0';
            reset_en <= '0';
            lvl2_en  <= '0';
            lvl3_en  <= '1';
            lvl4_en  <= '0';
            CANT_PLACE <= '0';
            CAN_PLACE  <= '0';

         when st7 => -- generovani levlu 4
            EN       <= '1';
            WE       <= '1';
            ADDR     <= lvl4_addr;
            DATAOUT  <= "0000000000000000000000000000" & lvl4_komp & "00";
            KOMP_GEN <= '0';
            reset_en <= '0';
            lvl2_en  <= '0';
            lvl3_en  <= '0';
            lvl4_en  <= '1';
            CANT_PLACE <= '0';
            CAN_PLACE  <= '0';

         when others =>
            EN      <= '0';
            WE      <= '0';
            ADDR    <= (others=>'0');
            DATAOUT <= (others=>'0');
            KOMP_GEN <= '0';
            reset_en <= '0';
            lvl2_en <= '0';
            lvl3_en  <= '0';
            lvl4_en  <= '0';
            CANT_PLACE <= '0';
            CAN_PLACE  <= '0';
         
      end case;
   end process;

   ------------------------------------------

   with KOMP4 select
   uprdownl <= "0011" when "100010", -- zahnuta zprava nahoru
               "1100" when "000010", -- zahnuta zleva dolu
               "1001" when "010010", -- zahnuta zleva nahoru
               "0110" when "110010", -- zahnuta zprava dolu
               "1010" when "000001", -- rovna zleva doprava
               "0101" when "010001", -- rovna zhora dolu
               "1111" when "000011", -- krizova
               "0000" when others;
              --LDRU

   -- mazani herniho pole
   process (CLK)
   begin
      if rising_edge(CLK) then
         if (RST = '1') then
            reset_addr <= (others=>'0');
            reset_ok   <= '0';
         elsif(reset_addr = "11111111")then
            reset_addr <= (others=>'0');
            reset_ok   <= '1';
         elsif(reset_en = '1') then
            reset_addr <= reset_addr + 1;
            reset_ok   <= '0';
         end if;
      end if;
   end process;

   -- generovani levelu 2
   process (CLK)
   begin
      if rising_edge(CLK) then
         if (RST = '1') then
            lvl2_addr_next <= (others=>'0');
            lvl2_addr <= (others=>'0');
            lvl2_ok   <= '0';
            lvl2_komp <= (others=>'0');
         elsif(lvl2_addr = "11111111")then
            lvl2_addr_next <= (others=>'0');
            lvl2_addr <= (others=>'0');
            lvl2_ok   <= '1';
            lvl2_komp <= (others=>'0');
         elsif(lvl2_en = '1') then
            if (lvl2_addr(3 downto 0) = "0100" AND (lvl2_addr(7 downto 4) >= "0000" AND lvl2_addr(7 downto 4) <= "0111")) then
               lvl2_addr_next <= lvl2_addr + 1;
               lvl2_addr <= lvl2_addr_next;
               lvl2_ok   <= '0';
               lvl2_komp <= "11";
            elsif (lvl2_addr(3 downto 0) = "1001" AND (lvl2_addr(7 downto 4) >= "0101" AND lvl2_addr(7 downto 4) <= "1100")) then
               lvl2_addr_next <= lvl2_addr + 1;
               lvl2_addr <= lvl2_addr_next;
               lvl2_ok   <= '0';
               lvl2_komp <= "11";
            else
               lvl2_addr_next <= lvl2_addr + 1;
               lvl2_addr <= lvl2_addr_next;
               lvl2_ok   <= '0';
               lvl2_komp <= (others=>'0');
            end if;
         end if;
      end if;
   end process; 

   -- generovani levelu 3
   process (CLK)
   begin
      if rising_edge(CLK) then
         if (RST = '1') then
            lvl3_addr_next <= (others=>'0');
            lvl3_addr <= (others=>'0');
            lvl3_ok   <= '0';
            lvl3_komp <= (others=>'0');
         elsif(lvl3_addr = "11111111")then
            lvl3_addr_next <= (others=>'0');
            lvl3_addr <= (others=>'0');
            lvl3_ok   <= '1';
            lvl3_komp <= (others=>'0');
         elsif(lvl3_en = '1') then
            if (lvl3_addr(7 downto 4) = "0100" AND (lvl3_addr(3 downto 0) >= "0000" AND lvl3_addr(3 downto 0) <= "0111")) then
               lvl3_addr_next <= lvl3_addr + 1;
               lvl3_addr <= lvl3_addr_next;
               lvl3_ok   <= '0';
               lvl3_komp <= "11";
            elsif (lvl3_addr(7 downto 4) = "1000" AND (lvl3_addr(3 downto 0) >= "0110" AND lvl3_addr(3 downto 0) <= "1101")) then
               lvl3_addr_next <= lvl3_addr + 1;
               lvl3_addr <= lvl3_addr_next;
               lvl3_ok   <= '0';
               lvl3_komp <= "11";
            else
               lvl3_addr_next <= lvl3_addr + 1;
               lvl3_addr <= lvl3_addr_next;
               lvl3_ok   <= '0';
               lvl3_komp <= (others=>'0');
            end if;
         end if;
      end if;
   end process;

   -- generovani levelu 4
   process (CLK)
   begin
      if rising_edge(CLK) then
         if (RST = '1') then
            lvl4_addr_next <= (others=>'0');
            lvl4_addr <= (others=>'0');
            lvl4_ok   <= '0';
            lvl4_komp <= (others=>'0');
         elsif(lvl4_addr = "11111111")then
            lvl4_addr_next <= (others=>'0');
            lvl4_addr <= (others=>'0');
            lvl4_ok   <= '1';
            lvl4_komp <= (others=>'0');
         elsif(lvl4_en = '1') then
            if (lvl4_addr(3 downto 0) = "0100" AND (lvl4_addr(7 downto 4) >= "0000" AND lvl4_addr(7 downto 4) <= "0110")) then
               lvl4_addr_next <= lvl4_addr + 1;
               lvl4_addr <= lvl4_addr_next;
               lvl4_ok   <= '0';
               lvl4_komp <= "11";
            elsif (lvl4_addr(3 downto 0) = "1001" AND (lvl4_addr(7 downto 4) >= "0110" AND lvl4_addr(7 downto 4) <= "1100")) then
               lvl4_addr_next <= lvl4_addr + 1;
               lvl4_addr <= lvl4_addr_next;
               lvl4_ok   <= '0';
               lvl4_komp <= "11";
            elsif (lvl4_addr(7 downto 4) = "1000" AND (lvl4_addr(3 downto 0) >= "0001" AND lvl4_addr(3 downto 0) <= "0110")) then
               lvl4_addr_next <= lvl4_addr + 1;
               lvl4_addr <= lvl4_addr_next;
               lvl4_ok   <= '0';
               lvl4_komp <= "11";
            elsif (lvl4_addr(7 downto 4) = "0100" AND (lvl4_addr(3 downto 0) >= "0111" AND lvl4_addr(3 downto 0) <= "1100")) then
               lvl4_addr_next <= lvl4_addr + 1;
               lvl4_addr <= lvl4_addr_next;
               lvl4_ok   <= '0';
               lvl4_komp <= "11";
            else
               lvl4_addr_next <= lvl4_addr + 1;
               lvl4_addr <= lvl4_addr_next;
               lvl4_ok   <= '0';
               lvl4_komp <= (others=>'0');
            end if;
         end if;
      end if;
   end process; 

end FULL;