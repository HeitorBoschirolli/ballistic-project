library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY angle_controler IS
	PORT(
			CLOCK_1Hz: in STD_LOGIC;
			angle_sum, angle_min: in  STD_LOGIC;
			angle: out integer range 0 to 85
);
END angle_controler;


ARCHITECTURE MAIN OF angle_controler IS
begin
	
	process(CLOCK_1Hz)
		variable angle_aux : integer range 0 to 85 := 60;
	begin
	if (CLOCK_1Hz'event and CLOCK_1Hz = '1') then
		if(angle_sum = '1' and angle_aux <= 80) then
			angle_aux := angle_aux + 5;
		elsif (angle_min = '1' and angle_aux >= 5) then
			angle_aux := angle_aux - 5;
		end if;
	end if;
	angle <= angle_aux;
	end process;
	
 END MAIN;

