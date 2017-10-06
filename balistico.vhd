library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;


ENTITY balistico IS
PORT(
	CLOCK_50: IN STD_LOGIC;
	CLOCK_24	: 	in	STD_LOGIC_VECTOR (1 downto 0);	--	24 MHz
	VGA_HS,VGA_VS:OUT STD_LOGIC;
	LEDG : out std_LOGIC_VECTOR( 7 downto 0);
	SW: STD_LOGIC_VECTOR(2 downto 0);
	KEY: STD_LOGIC_VECTOR(3 DOWNTO 0);
	HEX0 	:		out	STD_LOGIC_VECTOR (6 downto 0);		--	Seven Segment Digit 0
	HEX1 	:		out	STD_LOGIC_VECTOR (6 downto 0);		--	Seven Segment Digit 1
	HEX2 	:		out	STD_LOGIC_VECTOR (6 downto 0);		--	Seven Segment Digit 2
	HEX3 	:		out	STD_LOGIC_VECTOR (6 downto 0);		--	Seven Segment Digit 3
	VGA_R,VGA_B,VGA_G: OUT STD_LOGIC_VECTOR(3 downto 0);
	PS2_DAT 	:		inout	STD_LOGIC;	--	PS2 Data
	PS2_CLK	:		inout	STD_LOGIC		--	PS2 Clock
);
END balistico;


ARCHITECTURE MAIN OF balistico IS
SIGNAL VGACLK,RESET:STD_LOGIC;

	component conv_7seg
		port(
			digit		:		in STD_LOGIC_VECTOR (3 downto 0);
			seg			:		out STD_LOGIC_VECTOR (6 downto 0)
		);
	end component;
	
	 COMPONENT vga_controler IS
	 PORT(
				CLK_24MHz : in STD_LOGIC;
				CLK: IN STD_LOGIC;
				HSYNC: OUT STD_LOGIC;
				VSYNC: OUT STD_LOGIC;
				R: OUT STD_LOGIC_VECTOR(3 downto 0);
				G: OUT STD_LOGIC_VECTOR(3 downto 0);
				B: OUT STD_LOGIC_VECTOR(3 downto 0);
				S: IN STD_LOGIC_VECTOR(2 downto 0);
				angle_sum : in	STD_LOGIC;
				angle_sub : in	STD_LOGIC;
				throw_ball : in STD_LOGIC
		);
	END COMPONENT vga_controler;	 
	 
	component clk_65M is
		port (
			clk_in_clk      : in  std_logic := '0'; --    clk_in.clk
			clk_reset_reset : in  std_logic := '0'; -- clk_reset.reset
			clk_out_clk     : out std_logic         --   clk_out.clk
		);
	end component clk_65M;
	
	--signal CLOCKHZ, resetn 	: std_logic;
	--signal key0 						: std_logic_vector(15 downto 0);
	--signal lights, key_on		: std_logic_vector( 2 downto 0);
	
	signal angle_sum : std_logic;
	signal angle_sub : std_logic;
	signal throw_ball : std_logic;
	signal reset_kb 	: std_logic;
	signal key_code 	: std_logic_vector(15 downto 0);
	signal lights, key_on		: std_logic_vector( 2 downto 0);
	
	signal force : std_logic_vector(2 downto 0) := "000";
	signal clock_force : std_logic;
	 
 BEGIN
 
	C: clk_65M PORT MAP (CLOCK_50, RESET, VGACLK);
	C1: vga_controler PORT MAP(CLOCK_50, VGACLK,VGA_HS,VGA_VS,VGA_R,VGA_G,VGA_B,force, angle_sum, angle_sub, throw_ball);
	
	reset_kb <= KEY(0);
 
	kbd_ctrl : kbdex_ctrl generic map(24000) port map(
		PS2_DAT, PS2_CLK, CLOCK_24(0), KEY(1), reset_kb, lights(1) & lights(2) & lights(0),
		key_on, key_code(15 downto 0) => key_code
	);
	
	angle_sub <= '1' when (key_code = x"E072") else '0';
	angle_sum <= '1' when (key_code = x"E075") else '0';
	throw_ball <= '1' when (key_code = x"0029") else '0';
	ledG(0) <= angle_sub;
	ledG(1) <= angle_sum;
	ledG(2) <= throw_ball;
	
	hexseg0 : conv_7seg port map (key_code(3 downto 0), HEX0);
	hexseg1 : conv_7seg port map (key_code(7 downto 4), HEX1);
	hexseg2 : conv_7seg port map (key_code(11 downto 8), HEX2);
	hexseg3 : conv_7seg port map (key_code(15 downto 12), HEX3);
	
	ledg(7 downto 5) <= force;
	clk_1Hz: clock_divider generic map (Freq_Hz => 4) port map (CLOCK_24(0), clock_force);
	process(clock_force)
		variable pressed : std_logic := '0';
	begin
		if (clock_force'event and clock_force = '1') then
			if (key_code = x"E074" and pressed = '0') then
				pressed := '1';
				if (force /= "111") then
					force <= std_logic_vector(unsigned(force) + 1);
				end if;
			elsif (key_code = x"E06B" and pressed = '0') then
				pressed := '1';
				if (force /= "000") then
					force <= std_logic_vector(unsigned(force) - 1);
				end if;
			else
				pressed := '0';
			end if;
		end if;
	end process;
 
 END MAIN;
 
