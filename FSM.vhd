----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:21:00 03/23/2015 
-- Design Name: 
-- Module Name:    FSM - Behavioral 
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

entity FSM is
	Generic (ancho_bus_dir:integer:=9;
				VAL_SAT_CONT:integer:=5208;
				ANCHO_CONTADOR:integer:=13;
				ULT_DIR_TX : integer := 420);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           button : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR(31 downto 0);
           direcc : out  STD_LOGIC_VECTOR (ancho_bus_dir -1 downto 0);
           TX : out  STD_LOGIC);
end FSM;

architecture Behavioral of FSM is
type estado is (reposo,
					inicio,
					test_data,
					b_start,
					b_0,
					b_1,
					b_2,
					b_3,
					b_4,
					b_5,
					b_6,
					b_7,
					b_paridad,
					b_stop,
					espera,
					fin);

signal estado_actual: estado;
signal estado_nuevo: estado;
signal dir, p_dir: std_logic_vector (ancho_bus_dir -1 downto 0);
signal cont, p_cont: std_logic_vector (ANCHO_CONTADOR -1 downto 0);

signal byte_tx, p_byte_tx : std_logic_vector (1 downto 0);
signal data, p_data : std_logic_vector (7 downto 0);

begin

direcc <= dir;

maq_estados:process(estado_actual, button, data, cont, dir, byte_tx, data_in)
begin

	p_dir <= dir;
	p_cont <= cont;
	
	p_byte_tx <= byte_tx;
	p_data <= data;
	
	
	TX <= '1';
	
	case estado_actual is
		when reposo =>
			TX <= '1';
			p_dir <= (others => '0');
			p_cont <= (others => '0');
			p_byte_tx <= "00";
			if button = '1' then
				estado_nuevo <= inicio;
			else
				estado_nuevo <= reposo;
			end if;
			
		when inicio =>
			TX <= '1';
			estado_nuevo <= test_data;
			
			case byte_tx is
				when "00" =>
					p_data <= data_in (31 downto 24);
					
				when "01" =>
					p_data <= data_in (23 downto 16);
					
				when "10" => 
					p_data <= data_in (15 downto 8);
				
				when OTHERS =>
					p_data <= data_in (7 downto 0);
			end case;
			
		when test_data =>
			TX <= '1';
			if dir = ULT_DIR_TX then
				estado_nuevo <= fin;
			else 
				estado_nuevo <= b_start;
			end if;
			
		when b_start =>
			TX <= '0';
			p_cont <= cont +1;
			if cont = VAL_SAT_CONT then
				p_cont <= (others => '0');
				estado_nuevo <= b_0;
			else
				estado_nuevo <= b_start;
			end if;
			
		when b_0 =>
			TX <= data(0);
			p_cont <= cont +1;
			if cont = VAL_SAT_CONT then
				p_cont <= (others => '0');
				estado_nuevo <= b_1;
			else
				estado_nuevo <= b_0;
			end if;
		
		when b_1 =>
			TX <= data(1);
			p_cont <= cont +1;
			if cont = VAL_SAT_CONT then
				p_cont <= (others => '0');
				estado_nuevo <= b_2;
			else
				estado_nuevo <= b_1;
			end if;
			
		when b_2 =>
			TX <= data(2);
			p_cont <= cont +1;
			if cont = VAL_SAT_CONT then
				p_cont <= (others => '0');
				estado_nuevo <= b_3;
			else
				estado_nuevo <= b_2;
			end if;
			
		when b_3 =>
			TX <= data(3);
			p_cont <= cont +1;
			if cont = VAL_SAT_CONT then
				p_cont <= (others => '0');
				estado_nuevo <= b_4;
			else
				estado_nuevo <= b_3;
			end if;
			
		when b_4 =>
			TX <= data(4);
			p_cont <= cont +1;
			if cont = VAL_SAT_CONT then
				p_cont <= (others => '0');
				estado_nuevo <= b_5;
			else
				estado_nuevo <= b_4;
			end if;
			
		when b_5 =>
			TX <= data(5);
			p_cont <= cont +1;
			if cont = VAL_SAT_CONT then
				p_cont <= (others => '0');
				estado_nuevo <= b_6;
			else
				estado_nuevo <= b_5;
			end if;
			
		when b_6 =>
			TX <= data(6);
			p_cont <= cont +1;
			if cont = VAL_SAT_CONT then
				p_cont <= (others => '0');
				estado_nuevo <= b_7;
			else
				estado_nuevo <= b_6;
			end if;
			
		when b_7 =>
			TX <= data(7);
			p_cont <= cont +1;
			if cont = VAL_SAT_CONT then
				p_cont <= (others => '0');
				estado_nuevo <= b_paridad;
			else
				estado_nuevo <= b_7;
			end if;
			
		when b_paridad =>
			TX <= data(0) xor data(1) xor data(2) xor data(3) xor data(4) xor data(5) xor data(6) xor data(7);
			p_cont <= cont + 1;
			if cont = VAL_SAT_CONT then
				p_cont <= (others => '0');
				estado_nuevo <= b_stop;
			else
				estado_nuevo <= b_paridad;
			end if;
			
		when b_stop =>
			TX <= '1';
			p_cont <= cont + 1;
			if cont = VAL_SAT_CONT then
				p_cont <= (others => '0');
				estado_nuevo <= espera;
			else
				estado_nuevo <= b_stop;
			end if;
			
		when espera =>
			
			p_byte_tx <= byte_tx +1;
			
			if (byte_tx = "11") then
				p_dir <= dir +1;
			end if;
			
			estado_nuevo <= inicio;
			
		when fin =>
			
				
		
	end case;
end process;

sinc:process(reset, clk)
begin
	if reset = '1' then
		cont <= (others => '0');
		estado_actual <= reposo;
		dir <= (others => '0');
		byte_tx <= (others => '0');
		data <= (others => '0');
	elsif rising_edge(clk) then
		cont <= p_cont;
		estado_actual <= estado_nuevo;
		dir <= p_dir;
		byte_tx <= p_byte_tx;
		data <= p_data;
	end if;

end process;
		
		
end Behavioral;

