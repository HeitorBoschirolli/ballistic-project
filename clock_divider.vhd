library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY clock_divider IS
	generic ( Freq_Hz : integer := 1);
	PORT(
			CLOCK_24MHz: IN STD_LOGIC;
			clock_out:OUT STD_LOGIC
);
END clock_divider;


ARCHITECTURE MAIN OF clock_divider IS
begin
	
	process(CLOCK_24MHz)
	
		variable counter : integer := 0;
		
	begin
		if (CLOCK_24MHz'event and CLOCK_24MHz='1') then			
			if(counter <= (24000000/Freq_Hz)/2) then
				clock_out <= '0';
				counter := counter + 1;
			else
				clock_out <= '1';
				counter := counter + 1;
				if(counter = 24000000/Freq_Hz) then
					counter := 0;
				end if;
			end if;
		end if;
	end process;

 END MAIN;