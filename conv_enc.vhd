----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:18:42 04/23/2015 
-- Design Name: 
-- Module Name:    convolutional_encoder - Behavioral 
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
--use IEEE.STD_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity convolutional_encoder is
	Generic (	TAM_REG : integer := 7;
					SAT_ESPERA : integer := 2);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           button : in STD_LOGIC;
			  bit_in : in  STD_LOGIC;
           ok_bit_in : in  STD_LOGIC;
           fin_rx : in  STD_LOGIC;
           sat : in STD_LOGIC;
			  first_bit_out : out  STD_LOGIC;
           second_bit_out : out  STD_LOGIC;
			  ok_bit_out : out  STD_LOGIC;
			  fin_tx : out STD_LOGIC);
end convolutional_encoder;

architecture Behavioral of convolutional_encoder is

type estado is (	reposo,
						normal,
						relleno);
signal estado_actual, estado_nuevo : estado;
--signal estado_nuevo : estado;
signal reg, p_reg : STD_LOGIC_VECTOR (TAM_REG -1 downto 0);
signal cont_relleno, p_cont_relleno : integer range 0 to TAM_REG -1; --contador para ceross de relleno
signal p_ok_bit_out, p_fin_tx : STD_LOGIC;

begin

comb : process(estado_actual, reg, ok_bit_in, bit_in, cont_relleno, fin_rx, button, sat)

begin

	p_reg <= reg;
	p_cont_relleno <= cont_relleno;
	p_ok_bit_out <= '0';
	p_fin_tx <= '0';

	estado_nuevo <= estado_actual;

	first_bit_out <= reg(6) xor reg(5) xor reg(3) xor reg(1) xor reg(0);
	second_bit_out <= reg(6) xor reg(3) xor reg(2) xor reg(0);


	case estado_actual is
		
		when reposo =>
			if ( button = '1' ) then
				estado_nuevo <= normal;
				p_reg <= (others => '0');
			end if;
		
		when normal =>
			
			if ( ok_bit_in = '1' ) then
				p_reg(5 downto 0) <= reg(6 downto 1);
				p_reg(6) <= bit_in;
				p_ok_bit_out <= '1';
			end if;
			
			if ( fin_rx = '1' ) then
				estado_nuevo <= relleno;
				p_cont_relleno <= TAM_REG -1;
			end if;
			
		when relleno =>
			
			if ( cont_relleno = 0 and sat = '1') then
				estado_nuevo <= reposo;
				p_fin_tx <= '1';
			
			elsif ( sat = '1' ) then
				p_cont_relleno <= cont_relleno -1;
				
				p_reg(5 downto 0) <= reg(6 downto 1);
				p_reg(6) <= '0';
				
				p_ok_bit_out <= '1';
				
			end if;
						
	end case;
end process;

sinc : process (clk, reset)

begin
	
	if ( reset = '1' ) then
		reg <= (others => '0'); 
		ok_bit_out <= '0';
		estado_actual <= reposo;
		cont_relleno <= TAM_REG -1;
			
	elsif ( rising_edge(clk) ) then
		cont_relleno <= p_cont_relleno;
		reg <= p_reg;
		fin_tx <= p_fin_tx;
		ok_bit_out <= p_ok_bit_out;
		estado_actual <= estado_nuevo;
			
	end if;

end process;

end Behavioral;

