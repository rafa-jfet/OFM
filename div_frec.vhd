----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:34:40 03/09/2015 
-- Design Name: 
-- Module Name:    DIV_FREC - Behavioral 
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

entity div_frec is
	Generic (	SAT_BPSK : integer := 650;
					SAT_QPSK : integer := 650;
					SAT_8PSK : integer := 650 );

	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           button : in STD_LOGIC;
			  modulation : in STD_LOGIC_VECTOR (2 downto 0);
			  sat : out  STD_LOGIC);
end div_frec;

architecture Behavioral of div_frec is

type estado is (	reposo,
						inicio,
						activo );
						
signal estado_actual : estado;
signal estado_nuevo : estado;

signal cuenta, p_cuenta : integer ;--range 0 to SAT_BPSK;

begin

comb : process ( cuenta, estado_actual, button, modulation )

begin
	
	sat <= '0';
	p_cuenta <= cuenta;
	
	estado_nuevo <= estado_actual;
	
	case estado_actual is
		
		when reposo =>
			
			if ( button = '1' ) then
				estado_nuevo <= inicio;
			
			end if;
		
		when inicio =>
			case modulation is
		
				when "100" =>
					p_cuenta <= SAT_BPSK;
					
				when "010" =>
					p_cuenta <= SAT_QPSK;
					
				when OTHERS =>
					p_cuenta <= SAT_8PSK;
					
			end case;
			
			estado_nuevo <= activo;
			
		when activo =>
			
			if ( cuenta = 0 ) then
				
				estado_nuevo <= inicio;
				sat <= '1';
				
			else
				p_cuenta <= cuenta -1;
				
			end if;
	
	end case;
end process;

sinc : process(clk, reset)

begin

	if ( reset = '1' ) then
		cuenta <= 0;
		estado_actual <= reposo;
		
	elsif ( rising_edge(clk) ) then
		cuenta <= p_cuenta;
		estado_actual <= estado_nuevo;

	end if;
end process;

end Behavioral;