----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:49:53 06/29/2015 
-- Design Name: 
-- Module Name:    guardaifft - Behavioral 
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity guardaifft is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           dv : in  STD_LOGIC;
           cpv : in  STD_LOGIC;
			  edone : in  STD_LOGIC;
           xk_index : in  STD_LOGIC_VECTOR(6 downto 0);
           we : out  STD_LOGIC;
           xk_re : in  STD_LOGIC_VECTOR (15 downto 0);
           xk_im : in  STD_LOGIC_VECTOR (15 downto 0);
           EnableTxserie : out  STD_LOGIC;
           dato_out : out  STD_LOGIC_VECTOR (31 downto 0);
           addresout : out  STD_LOGIC_VECTOR (8 downto 0));
end guardaifft;

architecture Behavioral of guardaifft is

type estado is (	reposo,
						inicio,
						fin);
						
signal estado_actual, estado_nuevo : estado;
signal dir_actual, dir_nueva: STD_LOGIC_VECTOR(8 downto 0);


begin

sinc :	process(reset, clk)
	begin
		if(reset='1') then
			estado_actual <= reposo;
	      dir_actual <= (others => '0');
		elsif (clk='1' and clk'event) then
			dir_actual <= dir_nueva;
			estado_actual <= estado_nuevo;
		end if;
	end process;
	

addresout <= dir_actual;
dato_out <= xk_re & xk_im;


comb : process (estado_actual, dir_actual, dv, cpv, xk_index, edone)
	
	begin
			
		we <= dv;
		dir_nueva <= dir_actual;
		EnableTxserie <= '0';
		
		case estado_actual is
	
			when reposo =>
				
				if ( dv='1') then

					estado_nuevo <= inicio;
					dir_nueva <=dir_actual+1;
				
				else 
					estado_nuevo <= reposo;
			
				end if;
		
			when inicio =>
				if (dv='1') then
					dir_nueva <= dir_actual+1;
					estado_nuevo <=inicio;

				
				else
					estado_nuevo<= fin;
				
				end if;	
			
			when fin =>	
			  EnableTXserie<='1';
			  estado_nuevo <=reposo;
		
		end case;
end process;

end Behavioral;
