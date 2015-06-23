-- random_decoder_fifo.vhd
-- Autori: Vojtech Jerabek
-- Posledni zmena: 09.11.2014
-- Popis: nahodne generuje trubky co hraci prijdou
---------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity random_decoder_fifo is
    Port ( CLK 				: in  STD_LOGIC;										--
           RST 				: in  STD_LOGIC;
			  GENERATE_NEW 	: in  STD_LOGIC;										--po poslani enable signalu se obevi nova komponenta
			  GENERATE_FIVE 	: in  STD_LOGIC;										--po poslani enable signalu se obevi 5 novych komponent
           KOMP0 				: out  STD_LOGIC_VECTOR (5 downto 0);			--prvni trubka. (zde se vlozi nahodna)
           KOMP1 				: out  STD_LOGIC_VECTOR (5 downto 0);			--				||
           KOMP2 				: out  STD_LOGIC_VECTOR (5 downto 0);			--		posouva se dolu
           KOMP3 				: out  STD_LOGIC_VECTOR (5 downto 0);			--				\/
           KOMP4 				: out  STD_LOGIC_VECTOR (5 downto 0));			--posledni trubka. (ta co se bude vkladan na hraci plochu)
end random_decoder_fifo;

architecture Behavioral of random_decoder_fifo is

component random_generator
 generic 	(
				Number_of_options 		 	: natural:=10;											
				Flip_Flops						: natural:=4											
				);
					
	Port 		(
				CLK	 			: in  STD_LOGIC;
				RANDOM_PULSE	: in  STD_LOGIC;											--pro provedeni nahodne generace sem privedte enable signal
				RST	 			: in  STD_LOGIC;
				RANDOM_OUT		: out STD_LOGIC_vector (Flip_Flops-1 downto 0);	--zde se objevi nahodna hodnota. vydrzi zde az do dalsiho pulzu
				ENABLE_OUT		: out	STD_LOGIC
				);
end component;				

	signal 	generate_random 		: std_logic;
	signal 	generate_random_1 	: std_logic;
	signal 	generate_random_2 	: std_logic;
	signal 	fifo_move 				: std_logic;
	signal 	generate_random_five : std_logic_vector (11 downto 0);
	signal 	fifo_input				: std_logic_vector (3 downto 0);
	signal  	KOMP0_sig 				: STD_LOGIC_VECTOR (5 downto 0) :=(others=>'0');
	signal  	KOMP1_sig 				: STD_LOGIC_VECTOR (5 downto 0) :=(others=>'0');
	signal  	KOMP2_sig 				: STD_LOGIC_VECTOR (5 downto 0) :=(others=>'0');
	signal  	KOMP3_sig 				: STD_LOGIC_VECTOR (5 downto 0) :=(others=>'0');
	signal  	KOMP4_sig 				: STD_LOGIC_VECTOR (5 downto 0) :=(others=>'0');
	signal  	KOMP_sig 				: STD_LOGIC_VECTOR (5 downto 0) :=(others=>'0');
	
	

begin	
-- vygenerovani 5-ti nahodnych komponent za sebou
------------------------------------------------------------

	process (clk) begin
		if(rising_edge(CLK)) then
			if(RST='1') then
				generate_random_five <= (others=>'0');
				generate_random_1<='0';
			else
				if(GENERATE_FIVE='1') then
					generate_random_five <= "000000000001";
					generate_random_1<='0';
				else
					if(generate_random_five=4096) then
						generate_random_five <= (others=>'0');
						generate_random_1<='0';
					elsif(generate_random_five=0) then
						generate_random_1<='0';
						generate_random_five <= (others=>'0');
					elsif(generate_random_five=237) then
						generate_random_1<='1';
						generate_random_five <= generate_random_five + 1;
					elsif(generate_random_five=1638) then
						generate_random_1<='1';
						generate_random_five <= generate_random_five + 1;
					elsif(generate_random_five=2484) then
						generate_random_1<='1';
						generate_random_five <= generate_random_five + 1;
					elsif(generate_random_five=3186) then
						generate_random_1<='1';
						generate_random_five <= generate_random_five + 1;
					elsif(generate_random_five=4001) then
						generate_random_1<='1';
						generate_random_five <= generate_random_five + 1;
					else
						generate_random_1<='0';
						generate_random_five <= generate_random_five + 1;
					end if;
				end if;	
			end if;	
		end if;
	end process;	
	
	-- vygenerovani 1 nahodne komponenty
------------------------------------------------------------
	process (clk) begin
		if(rising_edge(CLK)) then
			if(RST='1') then
				generate_random_2<='0';
			else
				if(GENERATE_NEW='1') then
					generate_random_2<='1';
				else
					generate_random_2<='0';
				end if;
			end if;
		end if;
	end process;
	
	
		-- vygenerovani prirazeni nahodneho cila na KOMP0_sig a posuv ostatnich. KOPM4_sig zanika
------------------------------------------------------------

	process (clk) begin
		if(rising_edge(CLK)) then
			if(RST='1') then
				KOMP0_sig<=(others=>'0');
				KOMP1_sig<=(others=>'0');
				KOMP2_sig<=(others=>'0');
				KOMP3_sig<=(others=>'0');
				KOMP4_sig<=(others=>'0');
			else
				if(fifo_move='1') then
					KOMP0_sig <= KOMP_sig;									
					KOMP1_sig <= KOMP0_sig;
					KOMP2_sig <= KOMP1_sig;
					KOMP3_sig <= KOMP2_sig;
					KOMP4_sig <= KOMP3_sig;	
				else			
				end if;
			end if;
		end if;
	end process;
	
	--prepocet kombinacni logiky nahodneho cisla
-----------------------------------------------	
	with fifo_input select
	KOMP_sig <= 	"000001" when "0000",
						"000001" when "0001",
						"010001" when "0010",
						"010001" when "0011", --rovne trubky
						
						"000010" when "0100",
						"010010" when "0101",
						"100010" when "0110",
						"110010" when "0111", --zahla trubka
						
						"000011" when "1000",
						"000011" when "1001", --kriz, je 2x kvuli lepsi cetnosti
						
						"111111" when "1111",
						"000000" when others;	
						
						KOMP0 <= KOMP0_sig;									
						KOMP1 <= KOMP1_sig;
						KOMP2 <= KOMP2_sig;
						KOMP3 <= KOMP3_sig;
						KOMP4 <= KOMP4_sig;
	
	------------------------------- upravu provedl J.C.
	--Standard je takovy "XXYYYY", kde bity XX jsou natoceni a bity YYYY jsou typ trubky...
	
	unit1: random_generator
	  generic map (Number_of_options   => 10, Flip_Flops => 4)
	  port map    (CLK=>CLK,RST=>RST,RANDOM_PULSE=>generate_random,RANDOM_OUT=>fifo_input,ENABLE_OUT=>fifo_move);
	  
	generate_random <= generate_random_1 OR generate_random_2;

end Behavioral;

