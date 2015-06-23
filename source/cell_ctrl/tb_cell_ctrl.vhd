LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

 
ENTITY tb_cell_ctrl IS
END tb_cell_ctrl;
 
ARCHITECTURE behavior OF tb_cell_ctrl IS 
 
    -- Component Declaration for the Unit Under Test (UUT)

   --Inputs
   signal CLK       : std_logic := '0';
   signal PIXEL_X : std_logic_vector(9 downto 0) := (others => '0');
   signal PIXEL_Y : std_logic_vector(9 downto 0) := (others => '0');
   signal sig_main_sc        : STD_LOGIC := '1';
   signal sig_kurzor_addr    : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
   signal sig_komp0          : STD_LOGIC_VECTOR (5 downto 0) := (others => '1');
   signal sig_komp1          : STD_LOGIC_VECTOR (5 downto 0) := (others => '1');
   signal sig_komp2          : STD_LOGIC_VECTOR (5 downto 0) := (others => '1');
   signal sig_komp3          : STD_LOGIC_VECTOR (5 downto 0) := (others => '1');
   signal sig_komp4          : STD_LOGIC_VECTOR (5 downto 0) := (others => '1');

 	--Outputs
   signal sig_pix_set_x      : STD_LOGIC;
   signal sig_pix_set_y      : STD_LOGIC;
   signal sig_komp_set_x     : STD_LOGIC;
   signal sig_komp_set_y     : STD_LOGIC;
   signal sig_komp_on        : STD_LOGIC;
   signal sig_komp_out       : STD_LOGIC_VECTOR (5 downto 0);
   signal sig_addr_cell_ctrl : STD_LOGIC_VECTOR (8 downto 0);
   signal sig_kurzor         : STD_LOGIC;
 
    -- Clock period definitions
   constant CLK_period : time := 10 ns;


BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.CELL_CTRL
    PORT MAP (
      CLK         => CLK,
      PIXEL_X     => PIXEL_X,
      PIXEL_Y     => PIXEL_Y,
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
      MAIN_SC     => sig_main_sc
        );


    -- Clock process definitions
   CLK_process :process
   begin
    CLK <= '0';
    wait for CLK_period/2;
    CLK <= '1';
    wait for CLK_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      for i in 0 to 525 loop
         for j in 0 to 800 loop
				    wait until rising_edge(CLK);
            PIXEL_X <= std_logic_vector(to_unsigned(j,PIXEL_X'length));
            wait until rising_edge(CLK);
         end loop;
			   PIXEL_Y <= std_logic_vector(to_unsigned(i,PIXEL_Y'length));
      end loop;

      -- insert stimulus here 

      wait;
   end process;

END;
