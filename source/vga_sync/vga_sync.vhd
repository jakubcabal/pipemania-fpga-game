-- VGA_SYNC.vhd - Modul pro prijem signalu z portu PS2
-- Autori: Vojtech Jerabek
-- Posledni zmena: 16.10.2014
-- Popis: Generator synchronizacnich signalu pro ovladani VGA rozhrani s rozlisenim 640x480
-------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity VGA_SYNC is
    Port ( CLK 		: in  STD_LOGIC;
           PIXEL_X 	: out STD_LOGIC_VECTOR (9 downto 0);		--udava cislo pixelu na radku
           PIXEL_Y 	: out STD_LOGIC_VECTOR (9 downto 0);		--udava cislo pixelu ve sloupci
           VIDEO_ON 	: out STD_LOGIC;									--pokud je 1, jsme v aktivni oblasti monitoru
           HSYNC 		: out STD_LOGIC;									--  \
           VSYNC 		: out	STD_LOGIC);									-- --synchronizacni pulzy. pripojit k VGA vystupu
end VGA_SYNC;

architecture Behavioral of VGA_SYNC is

	 signal pixel_tick 	: std_logic;									-- clk/2, 25 MHz, doba popisovani jednoho pixelu
	 signal h_video_on 	: std_logic;									-- pokud je 1, jsme v aktivni horizontalni oblasti monitoru
	 signal v_video_on 	: std_logic;									-- pokud je 1, jsme v aktivni vertikalni oblasti monitoru
	 signal x				: STD_LOGIC_VECTOR (9 downto 0);			-- udava cislo pixelu na radku
	 signal y				: STD_LOGIC_VECTOR (9 downto 0);			-- udava cislo pixelu ve sloupci

begin
	process(CLK) begin
		if (rising_edge(CLK)) then
			if (pixel_tick='1') then
				pixel_tick <= '0';
			else
				pixel_tick <= '1';
			end if;
		end if;	
	end process;
	
--	vyroba pixel_tick (clk=2)
--------------------------------------------------------	
	
	process(CLK) begin
		if (rising_edge(CLK)) then
			if(pixel_tick='1') then
				if(x=799) then
					x<=(others => '0');
				else	
					x<=x+1;
				end if;			
			end if;			
		end if;	
	end process;
	
-- pocitani na jakem pixelu se na radku nachazime
----------------------------------------------------	
	
	process(CLK) begin
		if (rising_edge(CLK)) then
			if(pixel_tick='1') then
				if(x=799) then
					if(y=524) then
						y<=(others => '0');
					else
						y<=y+1;
					end if;
				end if;			
			end if;			
		end if;	
	end process;

-- pocitani na jakem pixelu se ve sloupci nachazime
-------------------------------------------------
	
	process(CLK) begin
		if (rising_edge(CLK)) then
			if (x<640) then
				h_video_on <= '1';
			else
				h_video_on <= '0';
			end if;
		end if;	
	end process;
	
	process(CLK) begin
		if (rising_edge(CLK)) then
			if (y<480) then
				v_video_on <= '1';
			else
				v_video_on <= '0';
			end if;
		end if;	
	end process;

-- resi, kdy se pohybujeme v aktivni oblasti monitoru
------------------------------------------------

	process(CLK) begin
		if (rising_edge(CLK)) then
			if (x>655 AND x<752) then
				HSYNC <= '0';
			else
				HSYNC <= '1';
			end if;
		end if;	
	end process;
	
	process(CLK) begin
		if (rising_edge(CLK)) then
			if (y>489 AND y<492) then
				VSYNC <= '0';
			else
				VSYNC <= '1';
			end if;
		end if;	
	end process;

-- resi synchronizacni pulzy pro VGA
----------------------------------------------------

	PIXEL_X 	<=	x;
	PIXEL_Y 	<=	y;	
	VIDEO_ON <= v_video_on AND h_video_on;	
	
end Behavioral;