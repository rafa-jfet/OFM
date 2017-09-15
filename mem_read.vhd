----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:23:11 04/14/2015 
-- Design Name: 
-- Module Name:    mem_read - Behavioral 
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
use IEEE.STD_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem_read is
	Generic ( 	ancho_bus_direcc : integer := 4;
					TAM_BYTE : integer := 8;
					bit_DBPSK : integer := 48;
					bit_DQPSK : integer := 96;
					bit_D8PSK : integer := 144);
					
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           button : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
			  modulation : in STD_LOGIC_VECTOR (2 downto 0);
           sat : in STD_LOGIC;
			  direcc : out  STD_LOGIC_VECTOR (ancho_bus_direcc -1 downto 0);
           bit_out : out  STD_LOGIC;
           ok_bit_out : out  STD_LOGIC;
			  fin : out  STD_LOGIC);
end mem_read;

architecture Behavioral of mem_read is

type estado is ( 	reposo,
						inicio,
						test_data,
						b_0,
						b_1,
						b_2,
						b_3,
						b_4,
						b_5,
						b_6,
						b_7,
--						dir_estable,
						rellena);
						
signal estado_actual : estado;
signal estado_nuevo : estado;
signal dir, p_dir : STD_LOGIC_VECTOR ( ancho_bus_direcc -1 downto 0);
signal cont_bit, p_cont_bit : integer range 0 to bit_D8PSK;
signal p_ok_bit_out : STD_LOGIC;

begin

direcc <= dir;

comb : process (estado_actual, button, modulation, data, cont_bit, dir, sat)

begin

	p_dir <= dir;
	p_cont_bit <= cont_bit;
	bit_out <= '0';
	p_ok_bit_out <= '0';
	fin <= '0';

	estado_nuevo <= estado_actual;
	
	case estado_actual is
	
		when reposo => -- espera hasta que se activa "button"
			
			if ( button = '1' ) then
				estado_nuevo <= inicio;

			end if;
			
		when inicio =>
			
			estado_nuevo <= test_data;
			
			if ( cont_bit = 0 ) then

				case modulation is

					when "100" =>
						p_cont_bit <= bit_DBPSK;
						
					when "010" =>
						p_cont_bit <= bit_DQPSK;
						
					when OTHERS =>
						p_cont_bit <= bit_D8PSK;
				
				end case;
			
			end if;
			
		when test_data =>
			
			if ( data = "00000000" ) then
				estado_nuevo <= rellena;

			else
				estado_nuevo <= b_0;
				p_ok_bit_out <= '1';

			end if;
			
		when rellena => --añade los ceros necesarios para completar un simbolo
			
			estado_nuevo <= rellena;
			
			if ( cont_bit -6 = 0 ) then
				estado_nuevo <= reposo;
				fin <= '1';
			
			elsif ( sat = '1' ) then
				p_cont_bit <= cont_bit -1;
				p_ok_bit_out <= '1';
			
			end if;
			
		when b_0 =>

			bit_out <= data(7);

			if ( sat = '1' ) then
				estado_nuevo <= b_1;
				p_ok_bit_out <= '1';
				
			end if;
			
		when b_1 =>

			bit_out <= data(6);

			if ( sat = '1' ) then
				estado_nuevo <= b_2;
				p_ok_bit_out <= '1';
				
			end if;

		when b_2 =>

			bit_out <= data(5);
			
			if ( sat = '1' ) then
				estado_nuevo <= b_3;
				p_ok_bit_out <= '1';
				
			end if;
			
		when b_3 =>

			bit_out <= data(4);

			if ( sat = '1' ) then
				estado_nuevo <= b_4;
				p_ok_bit_out <= '1';

			end if;
			
		when b_4 =>

			bit_out <= data(3);

			if ( sat = '1' ) then
				estado_nuevo <= b_5;
				p_ok_bit_out <= '1';

			end if;
			
		when b_5 =>

			bit_out <= data(2);

			if ( sat = '1' ) then
				estado_nuevo <= b_6;
				p_ok_bit_out <= '1';
				
			end if;

		when b_6 =>

			bit_out <= data(1);

			if ( sat = '1' ) then
				estado_nuevo <= b_7;
				p_ok_bit_out <= '1';

			end if;
			
		when b_7 =>

			bit_out <= data(0);
			
			if ( sat = '1' ) then
				estado_nuevo <= inicio;
				p_dir <= dir +1;
				p_cont_bit <= cont_bit -TAM_BYTE;
				
			end if;
			
--		when dir_estable =>
--			estado_nuevo <= inicio;
	
	end case;
end process;

sinc : process ( reset, clk)

begin
	
	if ( reset = '1' ) then
		cont_bit <= 0;
		dir <= (others => '0');
		ok_bit_out <= '0';
		estado_actual <= reposo;
		
	elsif ( rising_edge(clk) ) then
		ok_bit_out <= p_ok_bit_out;
		cont_bit <= p_cont_bit;
		dir <= p_dir;
		estado_actual <= estado_nuevo;
	
	end if;
	
end process;

end Behavioral;

