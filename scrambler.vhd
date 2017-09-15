----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:51:47 04/23/2015 
-- Design Name: 
-- Module Name:    scrambler - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scrambler is
    Generic (	SAT_ESPERA : integer := 7);
	 Port ( 	clk : in  STD_LOGIC;
				reset : in  STD_LOGIC;
				button : in STD_LOGIC;
				first_in : in  STD_LOGIC;
				second_in : in  STD_LOGIC;
				fin_rx : in STD_LOGIC;
				ok_bit_in : in  STD_LOGIC;
				bit_out : out  STD_LOGIC;
				ok_bit_out : out  STD_LOGIC);
end scrambler;

architecture Behavioral of scrambler is

type estado is (	reposo,
						inicio,
						first_input,
						second_input);

signal estado_actual, estado_nuevo : estado;
--signal estado_nuevo : estado;
signal reg, p_reg : STD_LOGIC_VECTOR (6 downto 0);
signal cont, p_cont : integer range 0 to SAT_ESPERA;
signal p_ok_bit_out : STD_LOGIC;

begin

comb : process (estado_actual, first_in, second_in, ok_bit_in, fin_rx, reg, button, cont)

begin

	p_reg <= reg;
	p_cont <= cont -1;
	p_ok_bit_out <= '0';
	bit_out <= reg(0) xor second_in;
	
	estado_nuevo <= estado_actual;
	
	case estado_actual is
	
		when reposo => -- estado inicial de reposo y reset de señales
			bit_out <= '0';
			if ( button = '1' ) then
				p_reg <= (others => '1');
				estado_nuevo <= inicio;
			end if;
			
		when inicio =>
			if ( fin_rx = '1' ) then -- fin de recepcion de datos
				estado_nuevo <= reposo;
			
			elsif ( ok_bit_in = '1' ) then
				estado_nuevo <= first_input;
				
				p_reg(6 downto 1) <= reg(5 downto 0);
				p_reg(0) <= reg(6) xor reg(3);
			
				p_ok_bit_out <= '1';
				
				p_cont <= SAT_ESPERA;
				
			end if;
			
		when first_input => --mantiene la salida con first_in SAT_ESPERA ciclos
			bit_out <= reg(0) xor first_in;
			
			if ( cont = 0 ) then
				estado_nuevo <= second_input;
				
				p_reg(6 downto 1) <= reg(5 downto 0);
				p_reg(0) <= reg(6) xor reg(3);
				
				p_ok_bit_out <= '1';
								
			end if;
			
		when second_input =>
			bit_out <= reg(0) xor second_in;
			
			estado_nuevo <= inicio;
			
	end case;
end process;

sinc : process (clk, reset)

begin

	if ( reset = '1' ) then
		reg <= (others => '1');
		estado_actual <= reposo;
		ok_bit_out <= '0';
		cont <= SAT_ESPERA;
	
	elsif ( rising_edge(clk) ) then
		reg <= p_reg;
		cont <= p_cont;
		ok_bit_out <= p_ok_bit_out;
		estado_actual <= estado_nuevo;
	
	end if;
	
end process;

end Behavioral;

