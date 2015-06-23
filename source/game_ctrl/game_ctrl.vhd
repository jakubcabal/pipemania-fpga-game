-- game_ctrl.vhd
-- Autori: Tomáš Bannert
-- Posledni zmena: 4.12.2014
-- Popis: game control
------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.numeric_std.ALL;


entity game_ctrl is
   Port ( 		 
		RST 	 	: in  STD_LOGIC;  --reset
		CLK 	 	: in  STD_LOGIC;  --clock
		WIN 	 	: in  STD_LOGIC;  --vyhra
		LOSE	 	: in  STD_LOGIC;  --prohra
		KEY_S	 	: in  STD_LOGIC;  --klavesa S
		GEN5_EN	: out  STD_LOGIC;  --enable generace poèáteèních komponent
		MAIN_SC	: out  STD_LOGIC;  --uvodní obrazovka
		WIN_SC 	: out  STD_LOGIC;  --vyherni obrazovka
		LOSE_SC 	: out  STD_LOGIC;  --obrazovka prohry
		LVL1	  	: out  STD_LOGIC;  --pole pro level 1
		LVL2_SC 	: out  STD_LOGIC;  --level 2 obrazovka
		LVL2	  	: out  STD_LOGIC;  --pole pro level 2
		LVL3_SC 	: out  STD_LOGIC;  --level 3 obrazovka
		LVL3	  	: out  STD_LOGIC;  --pole pro level 3
		LVL4_SC 	: out  STD_LOGIC;  --level 4 obrazovka
		LVL4	  	: out  STD_LOGIC;  --pole pro level 4
		WATER		: out  STD_LOGIC_VECTOR (7 downto 0)); --voda co tece v nadrzi pred zacatkem hry
end game_ctrl;

architecture Behavioral of game_ctrl is

   type state is (st0, st2, st3, st4, st5, st6, st7, st8, st11, st12);
   signal present_st 			: state;
   signal next_st    			: state;
	signal water_speed_counter	: STD_logic_vector (24 downto 0);
	signal water_in_progress	: STD_logic_vector (7 downto 0);
	signal start_count			: STD_logic;
	signal next_part_of_water	: STD_logic;

begin

   -- Pametova cast stavoveho automatu
   process (CLK, RST) 
   begin
      if (rising_edge(CLK)) then
         if (RST = '1') then
            present_st <= st0;
         else
            present_st <= next_st;
         end if;
      end if;   
   end process;
	
	-- Rozhodovaci cast stavoveho automatu
   process (present_st, KEY_S, WIN, LOSE, RST)
   begin
      case present_st is
     
         when st0 => --uvodni obrazovka
            if (KEY_S = '1') then
               next_st <= st2;
            else
               next_st <= st0;
            end if;

         when st2 => --level 1
            if (WIN = '1') then
               next_st <= st3;
            elsif (LOSE = '1') then
               next_st <= st12;
				else
	            next_st <= st2;
            end if;

         when st3 => --level 2 obrazovka
            if (KEY_S = '1') then
               next_st <= st4;
            else
               next_st <= st3;
            end if;
				
         when st4 => --level 2
            if (WIN = '1') then
               next_st <= st5;
            elsif (LOSE = '1') then
               next_st <= st12;
				else
               next_st <= st4;
            end if;
				
	 when st5 => --level 3 obrazovka
            if (KEY_S = '1') then
               next_st <= st6;
            else
               next_st <= st5;
            end if;
				
         when st6 => --level 3
            if (WIN = '1') then
               next_st <= st7;
            elsif (LOSE = '1') then
               next_st <= st12;
				else
               next_st <= st6;
            end if;
			
	 when st7 => --level 4 obrazovka
            if (KEY_S = '1') then
               next_st <= st8;
            else
               next_st <= st7;
            end if;
				
         when st8 => --level 4
            if (WIN = '1') then
               next_st <= st11;
            elsif (LOSE = '1') then
               next_st <= st12;
				else
               next_st <= st8;
            end if;
				
         when st11 => --win
            if (KEY_S = '1' OR RST = '1') then
               next_st <= st0;
				else
               next_st <= st11;
            end if;
				
         when st12 => --lose
            if (KEY_S = '1' OR RST = '1') then
               next_st <= st0;
				else
               next_st <= st12;
            end if;
				
         when others =>
            next_st <= st0;
         
      end case;
   end process;
	
	-- Vystupni cast stavoveho automatu
   process (present_st)
   begin
      case present_st is

         		when st0 =>
            			MAIN_SC	<= '1';
				WIN_SC		<= '0';
				LOSE_SC		<= '0';
				GEN5_EN		<= '1';
				LVL1			<= '0';
				LVL2_SC		<= '0';
				LVL2			<= '0';
				LVL3_SC		<= '0';
				LVL3			<= '0';
				LVL4_SC		<= '0';
				LVL4			<= '0';
				start_count	<= '0';

         		when st2 =>
		            	MAIN_SC	<= '0';
				WIN_SC	<= '0';
				LOSE_SC	<= '0';
				GEN5_EN	<= '0';
				LVL1	<= '1';
				LVL2_SC	<= '0';
				LVL2	<= '0';
				LVL3_SC	<= '0';
				LVL3	<= '0';
				LVL4_SC	<= '0';
				LVL4	<= '0';
				start_count	<= '1';

         		when st3 =>
            MAIN_SC	<= '0';
				WIN_SC	<= '0';
				LOSE_SC	<= '0';
				GEN5_EN	<= '1';
				LVL1	<= '0';
				LVL2_SC	<= '1';
				LVL2	<= '0';
				LVL3_SC	<= '0';
				LVL3	<= '0';
				LVL4_SC	<= '0';
				LVL4	<= '0';
				start_count	<= '0';
				
			when st4 =>
            			MAIN_SC	<= '0';
				WIN_SC	<= '0';
				LOSE_SC	<= '0';
				GEN5_EN	<= '0';
				LVL1	<= '0';
				LVL2_SC	<= '0';
				LVL2	<= '1';
				LVL3_SC	<= '0';
				LVL3	<= '0';
				LVL4_SC	<= '0';
				LVL4	<= '0';
				start_count	<= '1';
				
			when st5 =>
            			MAIN_SC	<= '0';
				WIN_SC	<= '0';
				LOSE_SC	<= '0';
				GEN5_EN	<= '1';
				LVL1	<= '0';
				LVL2_SC	<= '0';
				LVL2	<= '0';
				LVL3_SC	<= '1';
				LVL3	<= '0';
				LVL4_SC	<= '0';
				LVL4	<= '0';
				start_count	<= '0';
				
			when st6 =>
            			MAIN_SC	<= '0';
				WIN_SC	<= '0';
				LOSE_SC	<= '0';
				GEN5_EN	<= '0';
				LVL1	<= '0';
				LVL2_SC	<= '0';
				LVL2	<= '0';
				LVL3_SC	<= '0';
				LVL3	<= '1';
				LVL4_SC	<= '0';
				LVL4	<= '0';
				start_count	<= '1';
				
			when st7 =>
            			MAIN_SC	<= '0';
				WIN_SC	<= '0';
				LOSE_SC	<= '0';
				GEN5_EN	<= '1';
				LVL1	<= '0';
				LVL2_SC	<= '0';
				LVL2	<= '0';
				LVL3_SC	<= '0';
				LVL3	<= '0';
				LVL4_SC	<= '1';
				LVL4	<= '0';
				start_count	<= '0';
				
			when st8 =>
            			MAIN_SC	<= '0';
				WIN_SC	<= '0';
				LOSE_SC	<= '0';
				GEN5_EN	<= '0';
				LVL1	<= '0';
				LVL2_SC	<= '0';
				LVL2	<= '0';
				LVL3_SC	<= '0';
				LVL3	<= '0';
				LVL4_SC	<= '0';
				LVL4	<= '1';
				start_count	<= '1';
				
			when st11 =>
            			MAIN_SC	<= '0';
				WIN_SC		<= '1';
				LOSE_SC		<= '0';
				GEN5_EN		<= '0';
				LVL1			<= '0';
				LVL2_SC		<= '0';
				LVL2			<= '0';
				LVL3_SC		<= '0';
				LVL3			<= '0';
				LVL4_SC		<= '0';
				LVL4			<= '0';
				start_count	<= '0';
				
			when st12 =>
            			MAIN_SC	<= '0';
				WIN_SC		<= '0';
				LOSE_SC		<= '1';
				GEN5_EN		<= '0';
				LVL1			<= '0';
				LVL2_SC		<= '0';
				LVL2			<= '0';
				LVL3_SC		<= '0';
				LVL3			<= '0';
				LVL4_SC		<= '0';
				LVL4			<= '0';
				start_count	<= '0';

         when others =>
				MAIN_SC		<= '0';
				WIN_SC		<= '0';
				LOSE_SC		<= '0';
				GEN5_EN		<= '0';
				LVL1			<= '0';
				LVL2_SC		<= '0';
				LVL2			<= '0';
				LVL3_SC		<= '0';
				LVL3			<= '0';
				LVL4_SC		<= '0';
				LVL4			<= '0';			
				start_count	<= '0';
         
      end case;
   end process;
	
	process (clk) begin
      if (rising_edge(CLK)) then
			if (RST= '1') then
				water_speed_counter 	<= (others=>'0');
				next_part_of_water 	<= '0';	
			else			
				if (start_count='1') then
					if (water_speed_counter<10000000) then --uprav, pokud chces jinou rychlost. max 1048575
						water_speed_counter 	<= water_speed_counter + 1;
						next_part_of_water 	<= '0';					
					else
						water_speed_counter 	<= (others=>'0');
						next_part_of_water 	<= '1';
					end if;
				else
					water_speed_counter 	<= (others=>'0');
					next_part_of_water 	<= '0';				
				end if;
			end if;
		end if;	
   end process;
		
	process (clk) begin
      if (rising_edge(CLK)) then
			if (RST= '1') then	
				water_in_progress 	<= (others=>'0');
			else			
				if (start_count='1') then
					if (next_part_of_water = '1') then
						if (water_in_progress < 255) then
							water_in_progress <= water_in_progress + 1;
						else
							water_in_progress <= std_logic_vector(to_unsigned(255,8));
						end if;
					end if;
				else
					water_in_progress <= (others=>'0');
				end if;	
			end if;
		end if;	
   end process;
	
	WATER <= water_in_progress;
	
end Behavioral;

