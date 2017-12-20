----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:15:11 05/08/2015 
-- Design Name: 
-- Module Name:    gray2angleinc - Behavioral 
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

entity gray2angleinc is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  bit_in : in  STD_LOGIC_VECTOR (0 downto 0);
           ok_bit_in : in  STD_LOGIC;
           modulation : in STD_LOGIC_VECTOR (2 downto 0);
			  anginc_out : out  STD_LOGIC_VECTOR (2 downto 0);
           ok_anginc_out : out  STD_LOGIC);
end gray2angleinc;

architecture Behavioral of gray2angleinc is

type estado is (	bit_0,
						bit_1,
						bit_2,
						salida_valida );
signal estado_actual : estado;
signal estado_nuevo : estado;

signal anginc_int, p_anginc_int : STD_LOGIC_VECTOR ( 2 downto 0 );

begin

anginc_out <= anginc_int;

comb : process ( estado_actual, bit_in, ok_bit_in, anginc_int, modulation)

begin
	
	p_anginc_int <= anginc_int;
	ok_anginc_out <= '0';
	
	estado_nuevo <= estado_actual;
	
	case estado_actual is
	
		when bit_0 =>
	
			if ok_bit_in = '1' then
			
				p_anginc_int(2) <= bit_in(0);
					
				if modulation = "100" then
			
					-- gray a decimal multiplicado por 4 (desplazamiento bits izq *2)
--					p_anginc_int(2) <= bit_in; --(gray a decimal) *2
					p_anginc_int ( 1 downto 0 ) <= "00";
					
					estado_nuevo <= salida_valida;
				
				else
					
--					p_anginc_int(0) <= bit_in;
					estado_nuevo <= bit_1;
				
				end if;
			
			end if;
			
		when bit_1 =>
			
			if ok_bit_in = '1' then
			
				p_anginc_int(1) <= anginc_int(2) xor bit_in(0);
			
				if modulation = "010" then
					
					-- gray a decimal multiplicado por 2 (desplazamiento bits izq)
----					p_anginc_int(2) <= anginc_int(0);
--					p_anginc_int(1) <= anginc_int(0) xor bit_in;

					p_anginc_int(0) <= '0';
			
					estado_nuevo <= salida_valida;
					
				else
					
--					p_anginc_int(1) <= bit_in;
					estado_nuevo <= bit_2;
					
				end if;
			
			end if;
				
		when bit_2 =>
			
			p_anginc_int(0) <= anginc_int(1) xor bit_in(0);
			
			if ok_bit_in = '1' then
			
				-- gray a decimal
--				p_anginc_int(2) <= bit_in; --bin2 = gray2
--				p_anginc_int(1) <= anginc_int(1) xor bit_in; --bin1 = gray1 xor bin2(=gray2)
--				p_anginc_int(0) <= anginc_int(0) xor anginc_int(1) xor bit_in; --bin0 = gray0 xor bin1(=gray1 xor bin2) 
					
				estado_nuevo <= salida_valida;
			
			end if;
			
		when salida_valida =>
			
			ok_anginc_out <= '1';
			estado_nuevo <= bit_0;
			
	end case;

end process;

sinc : process ( reset, clk )

begin

	if ( reset = '1' ) then
		
		anginc_int <= "000";
		estado_actual <= bit_0;

	elsif ( rising_edge(clk) ) then
	
		anginc_int <= p_anginc_int;
		estado_actual <= estado_nuevo;
		
	end if;

end process;

end Behavioral;

