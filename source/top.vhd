--------------------------------------------------------------------------------
-- PROJECT: PIPE MANIA - GAME FOR FPGA
--------------------------------------------------------------------------------
-- NAME:    TOP
-- AUTHORS: Jakub Cabal <xcabal05@stud.feec.vutbr.cz>
-- LICENSE: The MIT License, please read LICENSE file
-- WEBSITE: https://github.com/jakubcabal/pipemania-fpga-game
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;

entity TOP is
    Generic(
        SOUND_ENABLE : boolean := false -- Enable / disable sound
    );
    Port(
        CLK    : in  std_logic; -- Main CLK - 50 MHz
        RST    : in  std_logic; -- Main RST
        -- PS2 interface
        PS2C   : in  std_logic; -- PS2 CLK
        PS2D   : in  std_logic; -- PS2 serial data
        -- VGA interface
        RGB    : out std_logic_vector(2 downto 0); -- VGA RGB
        H_SYNC : out std_logic; -- VGA h-sync
        V_SYNC : out std_logic; -- VGA v-sync
        -- Sound output
        SOUND  : out std_logic; -- Sound output
        -- CTRL LEDS
        WINLED : out std_logic; -- LED game win
        FAILED : out std_logic  -- LED game over
    );
end TOP;

architecture FULL of TOP is

    -- keys signals
    signal sig_key_w            : std_logic;
    signal sig_key_s            : std_logic;
    signal sig_key_a            : std_logic;
    signal sig_key_d            : std_logic;
    signal sig_key_space        : std_logic;

    -- pixels signals
    signal pix_x                : std_logic_vector(9 downto 0);
    signal pix_y                : std_logic_vector(9 downto 0);
    signal pix_x1               : std_logic_vector(9 downto 0);
    signal pix_y1               : std_logic_vector(9 downto 0);
    signal pix_x2               : std_logic_vector(9 downto 0);
    signal pix_y2               : std_logic_vector(9 downto 0);

    -- cell ctrl signals
    signal sig_pix_set_x        : std_logic;
    signal sig_pix_set_y        : std_logic;
    signal sig_komp_set_x       : std_logic;
    signal sig_komp_set_y       : std_logic;
    signal sig_komp_on          : std_logic;
    signal sig_komp_out         : std_logic_vector(5 downto 0);

    -- video signals
    signal sig_video_on         : std_logic;
    signal sig_hsync            : std_logic;
    signal sig_vsync            : std_logic;
    signal sig_hsync1           : std_logic;
    signal sig_vsync1           : std_logic;
    signal sig_hsync2           : std_logic;
    signal sig_vsync2           : std_logic;
    signal sig_rgb              : std_logic_vector(2 downto 0);

    -- memory signals
    signal sig_addr_cell_ctrl   : std_logic_vector(7 downto 0);
    signal sig_addr_cell_ctrl_2 : std_logic_vector(8 downto 0);
    signal sig_dout_cell_gen    : std_logic_vector(31 downto 0);

    signal sig_we_hub           : std_logic;
    signal sig_addr_hub         : std_logic_vector(7 downto 0);
    signal sig_addr_hub_2       : std_logic_vector(8 downto 0);
    signal sig_dout_hub         : std_logic_vector(31 downto 0);
    signal sig_din_hub          : std_logic_vector(31 downto 0);

    -- memory hub signals
    signal hub_we_a             : std_logic;
    signal hub_en_a             : std_logic;
    signal hub_addr_a           : std_logic_vector(7 downto 0);
    signal hub_din_a            : std_logic_vector(31 downto 0);
    signal hub_dout_a           : std_logic_vector(31 downto 0);
    signal hub_ack_a            : std_logic;

    signal hub_we_b             : std_logic;
    signal hub_en_b             : std_logic;
    signal hub_addr_b           : std_logic_vector(7 downto 0);
    signal hub_din_b            : std_logic_vector(31 downto 0);
    signal hub_dout_b           : std_logic_vector(31 downto 0);
    signal hub_ack_b            : std_logic;

    -- kurzor signals
    signal sig_kurzor           : std_logic;
    signal sig_kurzor_addr      : std_logic_vector(7 downto 0);

    -- roura generator signals
    signal sig_komp0            : std_logic_vector(5 downto 0);
    signal sig_komp1            : std_logic_vector(5 downto 0);
    signal sig_komp2            : std_logic_vector(5 downto 0);
    signal sig_komp3            : std_logic_vector(5 downto 0);
    signal sig_komp4            : std_logic_vector(5 downto 0);
    signal sig_gen_new          : std_logic;
    signal sig_gen_five         : std_logic;

    -- sounds signals
    signal sound_place_pipe     : std_logic;
    signal sound_cant_place     : std_logic;
    signal sound_win            : std_logic;
    signal sound_lose           : std_logic;

    -- game ctrl
    signal sig_lvl1             : std_logic;
    signal sig_lvl2             : std_logic;
    signal sig_lvl3             : std_logic;
    signal sig_lvl4             : std_logic;
    signal sig_game_on          : std_logic;
    signal sig_main_sc          : std_logic;
    signal sig_lvl2_sc          : std_logic;
    signal sig_lvl3_sc          : std_logic;
    signal sig_lvl4_sc          : std_logic;
    signal sig_win_sc           : std_logic;
    signal sig_lose_sc          : std_logic;
    signal sig_win              : std_logic;
    signal sig_lose             : std_logic;
    signal sig_load_water       : std_logic_vector(7 downto 0);
    signal rst_wtr_ctrl         : std_logic;
    signal wtr_ctrl_start       : std_logic;

begin

    WINLED <= sig_win;
    FAILED <= sig_lose;

    ----------------------------------------------------------------------------
    -- PS2 DRIVERS
    ----------------------------------------------------------------------------

    ps2_i: entity work.PS2
    port map(
        CLK       => CLK,
        RST       => RST,
        PS2C      => PS2C,
        PS2D      => PS2D,
        KEY_W     => sig_key_w,
        KEY_S     => sig_key_s,
        KEY_A     => sig_key_a,
        KEY_D     => sig_key_d,
        KEY_SPACE => sig_key_space
    );

    ----------------------------------------------------------------------------
    -- VIDEO GENERATOR
    ----------------------------------------------------------------------------

    -- VGA driver
    vga_sync_i: entity work.VGA_SYNC
    port map(
        CLK      => CLK,
        PIXEL_X  => pix_x,
        PIXEL_Y  => pix_y,
        VIDEO_ON => sig_video_on,
        HSYNC    => sig_hsync,
        VSYNC    => sig_vsync
    );

    cell_ctrl_i: entity work.CELL_CTRL
    port map(
        CLK         => CLK,
        PIXEL_X     => pix_x,
        PIXEL_Y     => pix_y,
        KURZOR_ADDR => sig_kurzor_addr,
        KURZOR      => sig_kurzor,
        PIXEL_SET_X => sig_pix_set_x,
        PIXEL_SET_Y => sig_pix_set_y,
        KOMP_SET_X  => sig_komp_set_x,
        KOMP_SET_Y  => sig_komp_set_y,
        KOMP_ON     => sig_komp_on,
        ADDR        => sig_addr_cell_ctrl,
        KOMP0       => sig_komp0,
        KOMP1       => sig_komp1,
        KOMP2       => sig_komp2,
        KOMP3       => sig_komp3,
        KOMP4       => sig_komp4,
        KOMP_OUT    => sig_komp_out,
        MAIN_SC     => sig_main_sc,
        GAME_SC     => sig_game_on,
        LVL2_SC     => sig_lvl2_sc,
        LVL3_SC     => sig_lvl3_sc,
        LVL4_SC     => sig_lvl4_sc,
        WIN_SC      => sig_win_sc,
        LOSE_SC     => sig_lose_sc
    );

    sig_addr_cell_ctrl_2 <= '0' & sig_addr_cell_ctrl;

    cell_generator_i: entity work.CELL_GENERATOR
    port map(
        CLK            => CLK,
        RST            => RST,
        TYP_ROURY      => sig_dout_cell_gen(3 downto 0),
        NATOCENI_ROURY => sig_dout_cell_gen(5 downto 4),
        ROURA_VODA1    => sig_dout_cell_gen(15 downto 10),
        ROURA_VODA2    => sig_dout_cell_gen(21 downto 16),
        ZDROJ_VODY1    => sig_dout_cell_gen(25 downto 22),
        ZDROJ_VODY2    => sig_dout_cell_gen(29 downto 26),
        KURZOR         => sig_kurzor,
        PIXEL_X2       => pix_x2,
        PIXEL_Y2       => pix_y2,
        PIXEL_SET_X    => sig_pix_set_x,
        PIXEL_SET_Y    => sig_pix_set_y,
        KOMP_SET_X     => sig_komp_set_x,
        KOMP_SET_Y     => sig_komp_set_y,
        KOMP_ON        => sig_komp_on,
        KOMP_IN        => sig_komp_out,
        GAME_ON        => sig_game_on,
        LOAD_WATER     => sig_load_water,
        RGB            => sig_rgb
    );

    -- RGB register
    process (CLK)
    begin
        if rising_edge(CLK) then
            if (sig_video_on = '1') then
                RGB <= sig_rgb;
            else
                RGB <= "000";
            end if;
        end if;
    end process;

    -- pixels and sync shift registers
    process (CLK)
    begin
        if rising_edge(CLK) then
            sig_hsync1 <= sig_hsync;
            sig_hsync2 <= sig_hsync1;
            H_SYNC     <= sig_hsync2;

            sig_vsync1 <= sig_vsync;
            sig_vsync2 <= sig_vsync1;
            V_SYNC     <= sig_vsync2;

            pix_x1 <= pix_x;
            pix_x2 <= pix_x1;

            pix_y1 <= pix_y;
            pix_y2 <= pix_y1;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- OBVODY RIDICI KURZOR A V KLADANI ROUR
    ----------------------------------------------------------------------------

    kurzor_ctrl_i: entity work.KURZOR_CTRL
    port map(
        CLK         => CLK,
        RST         => RST,
        KEY_W       => sig_key_w,
        KEY_S       => sig_key_s,
        KEY_A       => sig_key_a,
        KEY_D       => sig_key_d,
        KEY_SPACE   => sig_key_space,
        KOMP_GEN    => sig_gen_new,
        KURZOR_ADDR => sig_kurzor_addr,
        DATAIN      => hub_dout_a,
        DATAOUT     => hub_din_a,
        ADDR        => hub_addr_a,
        EN          => hub_en_a,
        WE          => hub_we_a,
        ACK         => hub_ack_a,
        KOMP4       => sig_komp4,
        CANT_PLACE  => sound_cant_place,
        CAN_PLACE   => sound_place_pipe,
        GAME_ON     => sig_game_on,
        MAIN_SC     => sig_main_sc,
        LVL2_SC     => sig_lvl2_sc,
        LVL3_SC     => sig_lvl3_sc,
        LVL4_SC     => sig_lvl4_sc
    );

    random_decoder_fifo_i: entity work.random_decoder_fifo
    port map(
        CLK           => CLK,
        RST           => RST,
        GENERATE_NEW  => sig_gen_new,  -- po poslani enable signalu se obevi nova komponenta
        GENERATE_FIVE => sig_gen_five, -- po poslani enable signalu se obevi 5 novych komponent
        KOMP0         => sig_komp0,
        KOMP1         => sig_komp1,
        KOMP2         => sig_komp2,
        KOMP3         => sig_komp3,
        KOMP4         => sig_komp4
    );

    ----------------------------------------------------------------------------
    -- PAMETI
    ----------------------------------------------------------------------------

    -- BRAM pamet pro stavy policek
    bram_i: entity work.RAM_BRAM_2P
    generic map(
        DATA_WIDTH => 32, -- Sirka datoveho vstupu a vystupu
        ADDR_WIDTH => 9   -- Sirka adresove sbernice, urcuje take pocet polozek v pameti (2^ADDR_WIDTH)
    )
    port map(
        CLK       => CLK,
        -- Port A
        WE_A      => sig_we_hub,
        ADDR_A    => sig_addr_hub_2,
        DATAIN_A  => sig_din_hub,
        DATAOUT_A => sig_dout_hub,
        -- Port B - Pouziva ho pouze VGA radic a to poze ke cteni
        ADDR_B    => sig_addr_cell_ctrl_2,
        DATAOUT_B => sig_dout_cell_gen
    );

    -- Rozdvojka pameti
    mem_hub_i: entity work.MEM_HUB
    port map(
        CLK    => CLK,
        RST    => RST,
        -- Port A
        EN_A   => hub_en_a,
        WE_A   => hub_we_a,
        ADDR_A => hub_addr_a,
        DIN_A  => hub_din_a,
        DOUT_A => hub_dout_a,
        ACK_A  => hub_ack_a,
        -- Port B
        EN_B   => hub_en_b,
        WE_B   => hub_we_b,
        ADDR_B => hub_addr_b,
        DIN_B  => hub_din_b,
        DOUT_B => hub_dout_b,
        ACK_B  => hub_ack_b,
        -- Port to memory
        WE     => sig_we_hub,
        ADDR   => sig_addr_hub,
        DIN    => sig_din_hub,
        DOUT   => sig_dout_hub
    );

    sig_addr_hub_2 <= '0' & sig_addr_hub;

    wtr_ctrl_i: entity work.WTR_CTRL
    port map(
        CLK            => CLK,
        RST            => rst_wtr_ctrl,
        ADR            => hub_addr_b,
        CELL_IN        => hub_dout_b,
        CELL_OUT       => hub_din_b,
        WE_OUT         => hub_we_b,
        RE_OUT         => hub_en_b,
        WIN_BIT        => sig_win,
        KNLG_next      => hub_ack_b,
        START          => wtr_ctrl_start,
        fail_out       => sig_lose
    );

    ----------------------------------------------------------------------------
    -- SOUND
    ----------------------------------------------------------------------------

    enable_sound_g: if (SOUND_ENABLE = true) generate
        sound_i: entity work.muzika
        port map(
            CLK        => CLK,
            RST        => RST,
            PLACE_PIPE => sound_place_pipe,
            CANT_PLACE => sound_cant_place,
            WIN_LEVEL  => sound_win,
            GAME_OVER  => sound_lose,
            MUSIC      => SOUND
        );

        rised_sound_1_i: entity work.RISING_EDGE_DETECTOR
        port map(
            CLK    => CLK,
            VSTUP  => sig_win,
            VYSTUP => sound_win
        );

        rised_sound_2_i: entity work.RISING_EDGE_DETECTOR
        port map(
            CLK    => CLK,
            VSTUP  => sig_lose,
            VYSTUP => sound_lose
        );
    end generate;

    disable_sound_g: if (SOUND_ENABLE = false) generate
        SOUND <= '0';
    end generate;

    ----------------------------------------------------------------------------
    -- GAME CTRL
    ----------------------------------------------------------------------------

    game_ctrl_i: entity work.game_ctrl
    port map(
        CLK     => CLK,
        RST     => RST,
        WIN     => sig_win,
        LOSE    => sig_lose,
        KEY_S   => sig_key_s,
        GEN5_EN => sig_gen_five,
        MAIN_SC => sig_main_sc,
        WIN_SC  => sig_win_sc,
        LOSE_SC => sig_lose_sc,
        LVL1    => sig_lvl1,
        LVL2_SC => sig_lvl2_sc,
        LVL2    => sig_lvl2,
        LVL3_SC => sig_lvl3_sc,
        LVL3    => sig_lvl3,
        LVL4_SC => sig_lvl4_sc,
        LVL4    => sig_lvl4,
        WATER   => sig_load_water
    );

    rst_wtr_ctrl <= RST OR sig_win_sc OR sig_lose_sc OR sig_main_sc OR sig_lvl2_sc OR sig_lvl3_sc OR sig_lvl4_sc;
    sig_game_on <= sig_lvl1 OR sig_lvl2 OR sig_lvl3 OR sig_lvl4;

    wtr_ctrl_start <= '1' WHEN (sig_load_water = "11111111") ELSE '0';

end FULL;
