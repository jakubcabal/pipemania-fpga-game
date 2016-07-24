--------------------------------------------------------------------------------
-- PROJECT: PIPE MANIA - GAME FOR FPGA
--------------------------------------------------------------------------------
-- NAME:    RISING_EDGE_DETECTOR_TB
-- AUTHORS: Tomáš Bannert <xbanne00@stud.feec.vutbr.cz>
-- LICENSE: The MIT License, please read LICENSE file
-- WEBSITE: https://github.com/jakubcabal/pipemania-fpga-game
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RISING_EDGE_DETECTOR_TB is
end RISING_EDGE_DETECTOR_TB;

architecture behavior of RISING_EDGE_DETECTOR_TB is

    -- Component Declaration for the Unit Under Test (UUT)
    component RISING_EDGE_DETECTOR
    port(
        VSTUP  : in  std_logic;
        CLK    : in  std_logic;
        VYSTUP : out std_logic
    );
    end component;

    -- Inputs
    signal VSTUP  : std_logic := '0';
    signal CLK    : std_logic := '0';

    -- Outputs
    signal VYSTUP : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: RISING_EDGE_DETECTOR
    port map(
        VSTUP  => VSTUP,
        CLK    => CLK,
        VYSTUP => VYSTUP
    );

    -- Stimulus process
    stim_proc: process
    begin
        VSTUP <= '0';
        wait for 100 ns;
        VSTUP <= '1';
        wait for 100 ns;
        VSTUP <= '0';
        wait for 100 ns;
        VSTUP <= '1';
        wait;
    end process;

end;
