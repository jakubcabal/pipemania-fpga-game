--------------------------------------------------------------------------------
-- PROJECT: PIPE MANIA - GAME FOR FPGA
--------------------------------------------------------------------------------
-- NAME:    GAME_CTRL
-- AUTHORS: Tomáš Bannert <xbanne00@stud.feec.vutbr.cz>
-- LICENSE: The MIT License, please read LICENSE file
-- WEBSITE: https://github.com/jakubcabal/pipemania-fpga-game
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GAME_CTRL is
    Port (
        CLK         : in  std_logic; -- clock
        RST         : in  std_logic; -- reset
        WIN         : in  std_logic; -- vyhra
        LOSE        : in  std_logic; -- prohra
        KEY_S       : in  std_logic; -- klavesa S
        GEN5_EN	    : out std_logic; -- vygenerovani pocatecnich komponent
        SCREEN_CODE	: out std_logic_vector(2 downto 0); -- game screen code
        GAME_ON     : out std_logic; -- in game or in screen
        WATER		: out std_logic_vector(7 downto 0) -- voda co tece v nadrzi pred zacatkem hry
    );
end GAME_CTRL;

architecture Behavioral of GAME_CTRL is

    type state is (st0, st2, st3, st4, st5, st6, st7, st8, win_sc, lose_sc);
    signal present_st 			: state;
    signal next_st    			: state;

    signal water_speed_counter	: unsigned(24 downto 0);
    signal water_in_progress	: unsigned(7 downto 0);
    signal game_en              : std_logic;
    signal next_part_of_water	: std_logic;

begin

    -- Pametova cast stavoveho automatu
    process (CLK, RST)
    begin
        if (RST = '1') then
            present_st <= st0;
        elsif (rising_edge(CLK)) then
            present_st <= next_st;
        end if;
    end process;

    -- Rozhodovaci cast stavoveho automatu
    process (present_st, KEY_S, WIN, LOSE)
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
                    next_st <= lose_sc;
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
                    next_st <= lose_sc;
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
                    next_st <= lose_sc;
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
                    next_st <= win_sc;
                elsif (LOSE = '1') then
                    next_st <= lose_sc;
                else
                    next_st <= st8;
                end if;

            when win_sc => --win
                if (KEY_S = '1') then
                    next_st <= st0;
                else
                    next_st <= win_sc;
                end if;

            when lose_sc => --lose
                if (KEY_S = '1') then
                    next_st <= st0;
                else
                    next_st <= lose_sc;
                end if;

            when others =>
                next_st <= st0;

        end case;
    end process;

    -- Vystupni cast stavoveho automatu
    process (present_st)
    begin
        case present_st is

            when st0 => -- start screen
                GEN5_EN		<= '1';
                SCREEN_CODE	<= "000";
                game_en	    <= '0';

            when st2 => -- lvl 1
                GEN5_EN	    <= '0';
                SCREEN_CODE	<= "001";
                game_en	    <= '1';

            when st3 => -- lvl 2 screen
                GEN5_EN		<= '1';
                SCREEN_CODE	<= "100";
                game_en	    <= '0';

            when st4 => -- lvl 2
                GEN5_EN	    <= '0';
                SCREEN_CODE	<= "001";
                game_en	    <= '1';

            when st5 => -- lvl 3 screen
                GEN5_EN		<= '1';
                SCREEN_CODE	<= "101";
                game_en	    <= '0';

            when st6 => -- lvl 3
                GEN5_EN	    <= '0';
                SCREEN_CODE	<= "001";
                game_en	    <= '1';

            when st7 => -- lvl 4 screen
                GEN5_EN		<= '1';
                SCREEN_CODE	<= "110";
                game_en	    <= '0';

            when st8 => -- lvl 4
                GEN5_EN	    <= '0';
                SCREEN_CODE	<= "001";
                game_en	    <= '1';

			when win_sc => -- win screen
                GEN5_EN		<= '0';
                SCREEN_CODE	<= "010";
                game_en	    <= '0';

			when lose_sc => -- game over screen
                GEN5_EN		<= '0';
                SCREEN_CODE	<= "011";
                game_en	    <= '0';

            when others =>
                GEN5_EN	    <= '0';
                SCREEN_CODE	<= "000";
                game_en	    <= '0';

        end case;
    end process;

    process (CLK, RST)
    begin
        if (RST = '1') then
            water_speed_counter <= (others=>'0');
            next_part_of_water  <= '0';
        elsif (rising_edge(CLK)) then
            if (game_en = '1') then
                if (water_speed_counter < 10000000) then -- uprav, pokud chces jinou rychlost. max 1048575
                    water_speed_counter <= water_speed_counter + 1;
                    next_part_of_water  <= '0';
                else
                    water_speed_counter <= (others=>'0');
                    next_part_of_water  <= '1';
                end if;
            else
                water_speed_counter <= (others=>'0');
                next_part_of_water  <= '0';
            end if;
        end if;
    end process;

    process (CLK, RST)
    begin
        if (RST = '1') then
            water_in_progress <= (others=>'0');
        elsif (rising_edge(CLK)) then
            if (game_en = '1') then
                if (next_part_of_water = '1') then
                    if (water_in_progress < 255) then
                        water_in_progress <= water_in_progress + 1;
                    else
                        water_in_progress <= to_unsigned(255,8);
                    end if;
                end if;
            else
                water_in_progress <= (others=>'0');
            end if;
        end if;
    end process;

	WATER   <= std_logic_vector(water_in_progress);
    GAME_ON <= game_en;

end Behavioral;
