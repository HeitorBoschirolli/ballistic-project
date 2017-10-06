library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE MY IS

	function straight_line (X, Y, X1, Y1, X2, Y2 : in integer) return std_logic;
	function circle(X, Y, X1, Y1, R : in integer) return std_logic;
	function rectangle(X, Y, X1, Y1, X2, Y2 : in integer)	return std_logic;
	function calculate_opposite( HIP, ANGLE_DEGREES : in integer) return integer;
	function calculate_adjacent( HIP, ANGLE_DEGREES : in integer) return integer;

END MY;

PACKAGE BODY MY IS
	
	-- This function 
	function straight_line(X, Y, X1, Y1, X2, Y2 : in integer)
	return std_logic is
	variable line_width : integer := 100;
	variable draw : std_logic;
	variable greaterX, lowerX, greaterY, lowerY : integer;
	variable x1_aux, y1_aux, x2_aux, y2_aux : integer;
	begin
	
		if ((X1 < 0 and X2 < 0) or (Y1 < 0 and Y2 < 0)) then
			draw := '0';

		else			
		
			if (X1 > X2) then
				greaterX := X1;
				lowerX := X2;
			else
				greaterX := X2;
				lowerX := X1;
			end if;

			if (Y1 > Y2) then
				greaterY := Y1;
				lowerY := Y2;
			else
				greaterY := Y2;
				lowerY := Y1;
			end if;

			if ((X >= lowerX and X <= greaterX) and (Y >= lowerY and Y <= greaterY)) then
			
				if (X1 = X2) then
					if (X = X1) then
						draw := '1';
					else
						draw := '0';
					end if;				
				else	
					if (((Y2-Y1)*(x-X1) >= (X2-X1)*(y-Y1) - line_width)
						and ((Y2-Y1)*(x-X1) <= (X2-X1)*(y-Y1) + line_width)) then
						draw := '1';
					else
						draw := '0';
					end if;
				end if;

			else
				draw := '0';
			end if;
			
		end if;

		return std_logic(draw);
	end function;
	
	function circle(X, Y, X1, Y1, R : in integer)
	return std_logic is
	variable draw : std_logic;
	begin

		if ((X1-X)**2 + (Y1-Y)**2 <= R**2) then
			draw := '1';
		else
			draw := '0';
		end if;
			
		return std_logic(draw);
		
	end function;
	
	
	function rectangle(X, Y, X1, Y1, X2, Y2 : in integer)
	return std_logic is
	variable draw : std_logic;
	begin

		if ((X1 <= X and X <= X2) and (Y1 <= Y and Y <= Y2)) then
			draw := '1';
		else
			draw := '0';
		end if;
			
		return std_logic(draw);
		
	end function;
	
	function calculate_opposite( HIP, ANGLE_DEGREES : in integer)
	return integer is
	variable ret : integer;
	variable aux1, aux2 : integer;
	begin
		aux1 := (HIP * 4 * ANGLE_DEGREES * (180-ANGLE_DEGREES));
		aux2 := (40500 - ANGLE_DEGREES*(180-ANGLE_DEGREES));
		ret := aux1/aux2;
		return integer(ret);
	end function;
	
	function calculate_adjacent( HIP, ANGLE_DEGREES : in integer)
	return integer is
	variable ret : integer;
	begin
		ret := calculate_opposite(HIP, 90- ANGLE_DEGREES);
		return integer(ret);
	end function;	
	
END MY;