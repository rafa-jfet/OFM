----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:54:31 06/24/2015 
-- Design Name: 
-- Module Name:    asd - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity IfftControl is
	generic(
		CARRIERS : INTEGER :=128    --
   );
    Port ( 
			  reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  IfftEnable: in STD_LOGIC;
			  start : out STD_LOGIC;
			  cp_len : out STD_LOGIC_VECTOR(6 DOWNTO 0);
			  cp_len_we : out STD_LOGIC;
			  unload : out STD_LOGIC;
			  fwd_inv : out STD_LOGIC;
			  fwd_inv_we : out STD_LOGIC;
			  rfd : in STD_LOGIC);
end IfftControl;

architecture Behavioral of IfftControl is
	--declaracion de estados
	type estado is (reposo, 
--		leyendo, 
		inicio, 
		activo);  
	--señales 
	signal estado_actual, estado_nuevo: estado;
--	signal datoIn : STD_LOGIC_VECTOR (15 downto 0);
--	signal outReal, outImag : STD_LOGIC_VECTOR (7 downto 0);
--	signal dire_actual, dire_nuevo: STD_LOGIC_VECTOR(6 downto 0);
--	signal addra, p_addra : INTEGER RANGE 0 to CARRIERS; -- deberia ser carriers -1 pero sino no detectamos que es mayor por que desborda
begin
	cp_len<="0001100"; --configuracion prefijo ciclico
	fwd_inv <='0'; -- inversa ifft
	
	--proceso sincrono
sinc:	process(reset, clk)
	begin
		if(reset='1') then
	
			estado_actual <= reposo;			
		elsif (clk='1' and clk'event) then
			
			estado_actual <= estado_nuevo;
		end if;
	end process;


comb: process (estado_actual, ifftEnable, rfd)
	begin
		estado_nuevo<= estado_actual;
		start <='0';
		cp_len_we <='0';
		unload <='1';
		fwd_inv_we<='0';
		case estado_actual is

			when reposo =>
				
				if ifftEnable='1'  then
					estado_nuevo<= inicio;
				else
					estado_nuevo <=reposo;
				end if;			

			when inicio =>
			  --Conexiones con el core de FFT
				start <='1';
				cp_len_we <='1';
				fwd_inv_we<='1';
				--saltamos a otro estado 

				estado_nuevo<= activo;
			
			when activo =>

			start <='0';
				--saltamos a otro estado 
				if rfd='1' then
					estado_nuevo<= activo;
				else 
				  estado_nuevo <= reposo;
				end if;			

					
				
		end case;
	end process;
end Behavioral;

