----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:38:07 07/01/2015 
-- Design Name: 
-- Module Name:    intlv - Behavioral 
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

entity intlv is
    Generic (	bits_BPSK : integer := 96;
					bits_QPSK : integer := 192;
					bits_8PSK : integer := 288;
					col_BPSK : integer := 12;
					col_QPSK : integer := 12;
					col_8PSK : integer := 18;
					fil_BPSK : integer := 8;
					fil_QPSK : integer := 16;
					fil_8PSK : integer := 16);
					
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           button : in  STD_LOGIC;
           modulation : in STD_LOGIC_VECTOR (2 downto 0);
			  bit_in : in  STD_LOGIC;
           ok_bit_in : in  STD_LOGIC;
           bit_out : out  STD_LOGIC_VECTOR (0 downto 0);
           dir_bit : out  STD_LOGIC_VECTOR (8 downto 0);
           write_mem : out  STD_LOGIC_VECTOR (0 downto 0);
			  ok_bit_out : out STD_LOGIC
			  );
end intlv;

architecture Behavioral of intlv is

type estado is (	reposo,
						inicio,
						escribe,
						salida,
						salida_ok
						);

signal estado_actual, estado_nuevo : estado;
signal dir, p_dir : STD_LOGIC_VECTOR(8 downto 0);

signal NUM_BITS : integer range 0 to bits_8PSK := 0;
signal NUM_COL : integer range 0 to col_8PSK := 0;
signal BITS_FILA : integer range 0 to 4;

begin

dir_bit <= dir;
bit_out(0) <= bit_in;

initialization : process ( modulation)

begin
			case modulation is
					
				when "100" =>
					NUM_BITS <= bits_BPSK;
					NUM_COL <= col_BPSK;
					BITS_FILA <= 3;
						
				when "010" =>
					NUM_BITS <= bits_QPSK;
					NUM_COL <= col_QPSK;
					BITS_FILA <= 4;
						
				when OTHERS =>
					NUM_BITS <= bits_8PSK;
					NUM_COL <= col_8PSK;
					BITS_FILA <= 4;
						
			end case;
end process;

comb : process ( estado_actual, button, modulation, dir, ok_bit_in, NUM_BITS, BITS_FILA )

--variable BITS_FILA : integer := 0; --bits necesarios para direccionar las filas

begin

	write_mem(0) <= '0';
	ok_bit_out <= '0';
	p_dir <= dir;
	
	estado_nuevo <= estado_actual;
	
	case estado_actual is
		
		when reposo =>
			if ( button = '1' ) then
				p_dir <= (others => '0');
				estado_nuevo <= inicio;
			end if;
			
--			case modulation is
--					
--				when "100" =>
--					NUM_BITS <= bits_BPSK;
--					NUM_COL <= col_BPSK;
--					BITS_FILA := 3;
--						
--				when "010" =>
--					NUM_BITS <= bits_QPSK;
--					NUM_COL <= col_QPSK;
--					BITS_FILA := 4;
--						
--				when OTHERS =>
--					NUM_BITS <= bits_8PSK;
--					NUM_COL <= col_8PSK;
--					BITS_FILA := 4;
--						
--			end case;



		when inicio =>
			if ( ok_bit_in = '1' ) then
				write_mem(0) <= '1';
				estado_nuevo <= escribe;
			end if;
			
			if (dir = NUM_BITS) then
				estado_nuevo <= salida;
				p_dir <= (others => '0');
			end if;
		


		when escribe =>
			p_dir <= dir +1;
			estado_nuevo <= inicio;


		
		when salida =>
			estado_nuevo <= salida_ok;
			


	 	when salida_ok =>
			estado_nuevo <= salida;
			
			ok_bit_out <= '1';
			
			if ( dir = NUM_BITS -1) then -- comprueba si se ha completado un simbolo
				estado_nuevo <= inicio;
				p_dir <= (others => '0');
				
			elsif ( dir(8 downto BITS_FILA) = NUM_COL -1) then -- comprueba si se ha completado una fila
				p_dir(8 downto BITS_FILA) <= (others => '0');
				p_dir(BITS_FILA -1 downto 0) <= dir (BITS_FILA -1 downto 0) +1;
			
			else
				p_dir (8 downto BITS_FILA) <= dir(8 downto BITS_FILA) +1; --pasa a la siguiente columna
			
			end if;
			
	end case;
		
	
end process;



sinc : process (reset, clk)

begin

	if ( reset = '1' ) then
	
		dir <= ( others=>'0' );
		estado_actual <= reposo;
	
	elsif ( rising_edge(clk) ) then
		
		dir <= p_dir;
		estado_actual <= estado_nuevo;
		
	end if;
	
end process;


end Behavioral;

