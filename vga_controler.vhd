library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my.all;
use work.all;

--link VGA: http://tinyvga.com/vga-timing/1280x1024@60Hz

ENTITY vga_controler IS
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
END vga_controler;


ARCHITECTURE MAIN OF vga_controler IS

	-- Program constants
	constant radius : integer := 10;	
	constant base_length : integer := 100;
	constant base_width : integer := 10;	
	constant cannon_length : integer := 160;
	constant cannon_width : integer := 30;

	-- VGA information
	constant H_visible : integer := 1024;
	constant H_front_porch : integer := 24;
	constant H_sync_pulse : integer := 136;
	constant H_back_porch : integer := 160;
	constant H_total : integer := 1344;
	constant H_control : integer := 320;	
	constant V_visible : integer := 768;
	constant V_front_porch : integer := 3;
	constant V_sync_pulse : integer := 6;
	constant V_back_porch : integer := 29;
	constant V_total : integer := 806;
	constant V_control : integer := 38;

	constant h_start : integer := H_control;
	constant v_start : integer := V_control;
	constant h_length : integer := H_visible;
	constant v_length : integer := V_visible;
	
	constant base_h_start : integer := h_start;
	constant base_v_start : integer := v_start+v_length-base_width;
	constant base_h_end : integer := h_start+base_length;
	constant base_v_end : integer := v_start+v_length;
	constant cannon_h_start : integer := h_start;
	constant cannon_v_start : integer := v_start + v_length;

	-- Obstacle constants
	constant obstacle_h_start : integer := h_start + (h_length/2)- 20;
	constant obstacle_v_start : integer := v_start + v_length - 200;
	constant obstacle_h_end : integer := h_start + h_length/2 + 20;
	constant obstacle_v_end : integer := v_start + v_length;
	
-----1280x1024 @ 60 Hz pixel clock 108 MHz
	SIGNAL RGB: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL RGB2: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL DRAW1,DRAW2:STD_LOGIC:='0';
	SIGNAL HPOS: INTEGER RANGE 0 TO 1688:=0;
	SIGNAL VPOS: INTEGER RANGE 0 TO 1066:=0;
	
	signal angle : integer range 0 to 85;
	
	signal clock_angle : std_logic;
	
	signal reset_kb 	: std_logic;
	signal key_code 						: std_logic_vector(15 downto 0);
	signal lights, key_on		: std_logic_vector( 2 downto 0);

BEGIN
	
	clk_1Hz: clock_divider generic map (Freq_Hz => 5) port map (CLK_24MHz, clock_angle);
	angle_control : angle_controler port map (clock_angle, angle_sum, angle_sub, angle);

	PROCESS(CLK)
	
		variable tst : std_logic;
		variable tst2 : std_logic;
		variable tst3 : std_logic;
		variable tst4 : std_logic;
		variable tst5 : std_logic;
		variable tst6 : std_logic;
		variable tst7 : std_logic;
		variable tst8 : std_logic;
		variable tst9 : std_logic;

		variable positionX : integer := h_start + radius;
		variable positionY : integer := v_start + v_length - radius;
		variable systemTime : integer := 0;
		variable counter : integer := 0;
		variable running : integer := 0;
		variable velocityX : integer := 0;
		variable velocityY : integer := 0;
		variable oldPositionX : integer := 0;
		variable oldPositionY : integer := 0;
		variable velocity : integer := 40;
		variable delay : integer := 0;
		variable sightX : integer := h_start + 200;
		variable sightY : integer := v_start + v_length - 200;
		variable cannon_x : integer;
		variable cannon_y : integer;
		variable cannon_x11 : integer;
		variable cannon_y11 : integer;
		variable cannon_x12 : integer;
		variable cannon_y12 : integer;
		variable cannon_x21 : integer;
		variable cannon_y21 : integer;
		variable cannon_x22 : integer;
		variable cannon_y22 : integer;
		variable read_button_counter : integer range 0 to 65000000;
		variable velocityLevel: integer range 0 to 8 := 0;
		variable targetRandom: integer range 1 to 9 := 1;
		variable windVelocity : integer range -2 to 2 := 0;
		
	BEGIN
		IF(CLK'EVENT AND CLK='1')THEN
		
			R<=(others=>'1');
			G<=(others=>'1');
			B<=(others=>'1');
			
			cannon_x := cannon_h_start + calculate_adjacent(cannon_length, angle);
			cannon_y := cannon_v_start - calculate_opposite(cannon_length, angle);
			
			cannon_x11 := cannon_h_start;
			cannon_y11 := cannon_v_start - (calculate_opposite(cannon_width*1000, angle)/(1000*2));			
			cannon_x12 := cannon_x - (calculate_opposite(cannon_width, angle)/2);
			cannon_y12 := cannon_y - (calculate_adjacent(cannon_width, angle)/2);
			
			cannon_x21 := cannon_h_start + (calculate_opposite(cannon_width*1000, angle)/(1000*2));
			cannon_y21 := cannon_v_start;			
			cannon_x22 := cannon_x + (calculate_opposite(cannon_width, angle)/2);
			cannon_y22 := cannon_y + (calculate_adjacent(cannon_width, angle)/2);
			
		
			R<=(others=>'1');
			G<=(others=>'1');
			B<=(others=>'1');
						
			-- Round shot
			tst := circle(hpos, vpos, positionX, positionY, radius);			
			if (tst='1') then
				R<=("0001");
				G<=("0001");
				B<=("0001");
			end if;
			
			-- Cannon base
			tst2 := circle(hpos, vpos, h_start, v_total, 100);			
			if (tst2='1') then
				R<=("0000");
				G<=("0000");
				B<=("0000");
			end if;
			
			-- Cannon center
			tst3 := straight_line(hpos, vpos, cannon_h_start, cannon_v_start, cannon_x, cannon_y);
			if (tst3='1') then
				R<=(others=>'0');
				G<=(others=>'0');
				B<=(others=>'0');
			end if;
			
			-- Cannon left
			tst4 := straight_line(hpos, vpos, cannon_x11, cannon_y11, cannon_x12, cannon_y12);
			if (tst4='1') then
				R<=(others=>'0');
				G<=(others=>'0');
				B<=(others=>'0');
			end if;
			
			-- Cannon right
			tst5 := straight_line(hpos, vpos, cannon_x21, cannon_y21, cannon_x22, cannon_y22);
			if (tst5='1') then
				R<=(others=>'0');
				G<=(others=>'0');
				B<=(others=>'0');
			end if;
			
			-- Target
			tst6 := rectangle(hpos, vpos, h_start + h_length - 40, v_start + 50 * targetRandom, h_start + h_length, v_start + 50 * targetRandom + 60);
			if (tst6='1') then
				R<=(others=>'1');
				G<=(others=>'0');
				B<=(others=>'0');
			end if;
			-- end target
			
			-- Obstacle
			tst7 := rectangle(hpos, vpos, obstacle_h_start, obstacle_v_start, obstacle_h_end, obstacle_v_end);
			if (tst7='1') then
				R<=(others=>'1');
				G<=(others=>'0');
				B<=(others=>'0');
			end if;
			
			-- Empty velocity meter
			tst8:= rectangle(hpos, vpos, h_start, v_start, h_start + 400, v_start + 50);
			if (tst8='1') then
				R<=(others=>'0');
				G<=(others=>'0');
				B<=(others=>'0');
			end if;
			
			-- draw velocity meter
			tst9:= rectangle(hpos, vpos, h_start, v_start, h_start + 50, v_start + 50);
			if (tst9='1' and velocityLevel >= 1) then
				R<=("1111");
				G<=("1111");
				B<=("0000");
			end if;

			tst:= rectangle(hpos, vpos, h_start + 50, v_start, h_start + 100, v_start + 50);
			if (tst='1' and velocityLevel >= 2) then
				R<=("1111");
				G<=("1110");
				B<=("0000");
			end if;
			
			tst:= rectangle(hpos, vpos, h_start + 100, v_start, h_start + 150, v_start + 50);
			if (tst='1' and velocityLevel >= 3) then
				R<=("1111");
				G<=("1101");
				B<=("0000");
			end if;
			
			tst:= rectangle(hpos, vpos, h_start + 150, v_start, h_start + 200, v_start + 50);
			if (tst='1' and velocityLevel >= 4) then
				R<=("1111");
				G<=("1100");
				B<=("0000");
			end if;
			
			tst:= rectangle(hpos, vpos, h_start + 200, v_start, h_start + 250, v_start + 50);
			if (tst='1' and velocityLevel >= 5) then
				R<=("1111");
				G<=("1011");
				B<=("0000");
			end if;
			
			tst:= rectangle(hpos, vpos, h_start + 250, v_start, h_start + 300, v_start + 50);
			if (tst='1' and velocityLevel >= 6) then
				R<=("1111");
				G<=("1010");
				B<=("0000");
			end if;
			
			tst:= rectangle(hpos, vpos, h_start + 300, v_start, h_start + 350, v_start + 50);
			if (tst='1' and velocityLevel >= 7) then
				R<=("1111");
				G<=("1001");
				B<=("0000");
			end if;
			
			tst:= rectangle(hpos, vpos, h_start + 350, v_start, h_start + 400, v_start + 50);
			if (tst='1' and velocityLevel >= 8) then
				R<=("1111");
				G<=("1000");
				B<=("0000");
			end if;
			-- end draw velocity meter
			
			-- Empty wind meter
			tst8:= rectangle(hpos, vpos, h_start, v_start + 75, h_start + 250, v_start + 125);
			if (tst8='1') then
				R<=(others=>'0');
				G<=(others=>'0');
				B<=(others=>'0');
			end if;
			
			-- draw velocity meter
			tst9:= rectangle(hpos, vpos, h_start, v_start + 75, h_start + 50, v_start + 125);
			if (tst9='1' and windVelocity <= -1) then
				R<=("0000");
				G<=("0000");
				B<=("0100");
			end if;
			
			tst9:= rectangle(hpos, vpos, h_start + 50, v_start + 75, h_start + 100, v_start + 125);
			if (tst9='1' and windVelocity <= -2) then
				R<=("0000");
				G<=("0000");
				B<=("1000");
			end if;
			
			tst9:= rectangle(hpos, vpos, h_start + 200, v_start + 75, h_start + 250, v_start + 125);
			if (tst9='1' and windVelocity >= 1) then
				R<=("0000");
				G<=("0000");
				B<=("0100");
			end if;
			
			tst9:= rectangle(hpos, vpos, h_start + 150, v_start + 75, h_start + 200, v_start + 125);
			if (tst9='1' and windVelocity >= 2) then
				R<=("0000");
				G<=("0000");
				B<=("1000");
			end if;
			-- end draw velocity meter
			
			IF(HPOS<H_total)THEN
				HPOS<=HPOS+1;
			ELSE
				HPOS<=0;
				IF(VPOS<V_total)THEN
					VPOS<=VPOS+1;
				ELSE
					VPOS<=0; 
					-- Set angle
					-- Set velocity
					if (S(2) = '0' and S(1) = '0' and S(0) = '0') then
						velocityLevel := 1;
						velocity := 35 - 3 * windVelocity;
					elsif (S(2) = '0' and S(1) = '0' and S(0) = '1') then
						velocityLevel := 2;
						velocity := 37 - 3 * windVelocity;
					elsif (S(2) = '0' and S(1) = '1' and S(0) = '0') then
						velocityLevel := 3;
						velocity := 39 - 3 * windVelocity;
					elsif (S(2) = '0' and S(1) = '1' and S(0) = '1') then
						velocityLevel := 4;
						velocity := 41 - 3 * windVelocity;
					elsif (S(2) = '1' and S(1) = '0' and S(0) = '0') then
						velocityLevel := 5;
						velocity := 43 - 3 * windVelocity;
					elsif (S(2) = '1' and S(1) = '0' and S(0) = '1') then
						velocityLevel := 6;
						velocity := 45 - 3 * windVelocity;
					elsif (S(2) = '1' and S(1) = '1' and S(0) = '0') then
						velocityLevel := 7;
						velocity := 47 - 3 * windVelocity;
					elsif (S(2) = '1' and S(1) = '1' and S(0) = '1') then
						velocityLevel := 8;
						velocity := 49 - 3 * windVelocity;
					end if;

					-- Set X and Y velocities
					if (running = 0) then
						velocityX := calculate_adjacent(velocity, angle);
						velocityY := calculate_opposite(velocity, angle);
					end if;
					-- Update position here
					if ((throw_ball = '1') or (running = 1)) then
						running := 1;
						counter := counter + 1;

						-- Check if the ball hit the obstacle
						if	(positionX >= obstacle_h_start -15 and positionX <= obstacle_h_end and positionY >= obstacle_v_start and positionY <= obstacle_v_end and velocityX > 0) then
							velocityX := -velocityX;
						end if;
						
						-- Check if the ball hit the target
						if	(positionX >= h_start + h_length - 40 and positionX <= h_start + h_length and positionY >= v_start + 50 * targetRandom and positionY <= v_start + 50 * targetRandom + 60) then
							velocityX := 0;
						end if;
						
						if (counter > 1) then
							systemTime := systemTime + 1;
							oldPositionX := positionX;
							
							positionY := v_start + v_length - radius - velocityY * systemTime + 1*(systemTime*systemTime)/2; -- velocidade inicial nula e aceleracao 1
							positionX := oldPositionX + velocityX;
							
							-- Set a limit for the positions
							if (positionX > h_start + h_length + 10) then
								running := 0;
								positionX := h_start + radius;
								positionY := v_start + v_length - radius;
								systemTime := 0;
								targetRandom := targetRandom + 1;
								windVelocity := windVelocity + 1;
							end if;
							if (positionY > v_start + v_length + 10) then
								running := 0;
								positionX := h_start + radius;
								positionY := v_start + v_length - radius;
								systemTime := 0;
								targetRandom := targetRandom + 1;
								windVelocity := windVelocity + 1;
							end if;
							
							counter := 0;
						end if;
					END IF;
				END IF;
			end if;
			
			-- VGA control
			IF((HPOS>=0 AND HPOS<H_control) OR (VPOS>=0 AND VPOS<V_control))THEN
				R<=(others=>'0');
				G<=(others=>'0');
				B<=(others=>'0');
			END IF;
			IF(HPOS>=H_front_porch AND HPOS<H_front_porch + H_sync_pulse)THEN----HSYNC
				HSYNC<='0';
			ELSE
				HSYNC<='1';
			END IF;
			IF(VPOS>=V_front_porch AND VPOS<V_front_porch + V_sync_pulse)THEN----------vsync
				VSYNC<='0';
			ELSE
				VSYNC<='1';
			END IF;
		END IF;
	END PROCESS;
END MAIN;
