----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:29:35 04/24/2015 
-- Design Name: 
-- Module Name:    mapper - Behavioral 
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
use IEEE.std_logic_signed.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mapper is
	Generic (	DIR_INICIAL : STD_LOGIC_VECTOR (6 downto 0) := "0010000"; -- 16
					DIR_FINAL : INTEGER := 112;
					pos_A2 : STD_LOGIC_VECTOR (7 downto 0) := "01100100"; -- 100
					pos_A1 : STD_LOGIC_VECTOR (7 downto 0) := "01000111"; -- 71
					A0 : STD_LOGIC_VECTOR (7 downto 0) := "00000000"; -- 0
					neg_A1 : STD_LOGIC_VECTOR (7 downto 0) := "10111001"; -- -71
					neg_A2 : STD_LOGIC_VECTOR (7 downto 0) := "10011100"); -- -100
					
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           anginc : in  STD_LOGIC_VECTOR (2 downto 0);
           ok_anginc : in  STD_LOGIC;
			  dir_data : out STD_LOGIC_VECTOR (6 downto 0);
			  write_data : out STD_LOGIC_VECTOR (0 downto 0);
			  Q_data : out  STD_LOGIC_VECTOR (7 downto 0) := A0;
           I_data : out  STD_LOGIC_VECTOR (7 downto 0) := neg_A2;
			  ok_data : out STD_LOGIC);
end mapper;

architecture Behavioral of mapper is

signal ang, p_ang : STD_LOGIC_VECTOR (2 downto 0) := "100";
signal dir, p_dir : STD_LOGIC_VECTOR (6 downto 0) := DIR_INICIAL;
signal p_write_data : STD_LOGIC_VECTOR (0 downto 0);

begin

dir_data(6) <= not(dir(6));
dir_data(5 downto 0) <= dir(5 downto 0);

comb : process(anginc, ok_anginc, ang, dir)

begin

	ok_data <= '0';

	p_write_data(0) <= '0';
	p_dir <= dir;
	p_ang <= ang;
	
	if ( ok_anginc = '1' ) then

		p_ang <= ang + anginc;
		p_write_data(0) <= '1';
		p_dir <= dir +1;
		
		if ( dir = DIR_FINAL -1 ) then
			ok_data <= '1';
			
		elsif ( dir = DIR_FINAL ) then
			p_dir <= DIR_INICIAL +1;
			p_ang <= "100" + anginc;
		
		end if;
		
	end if;
	
	case ang is
					
		when "000" =>
		
			Q_data <= A0;
			I_data <= pos_A2;
					
		when "001" =>
		
			Q_data <= pos_A1;
			I_data <= pos_A1;
			
		when "010" =>
		
			Q_data <= pos_A2;
			I_data <= A0;
			
		when "011" =>
		
			Q_data <= pos_A1;
			I_data <= neg_A1;
			
		when "100" =>
		
			Q_data <= A0;
			I_data <= neg_A2;
			
		when "101" =>
		
			Q_data <= neg_A1;
			I_data <= neg_A1;
			
		when "110" =>
		
			Q_data <= neg_A2;
			I_data <= A0;
			
		when OTHERS =>
		
			Q_data <= neg_A1;
			I_data <= pos_A1;
		
	end case;
	
end process;

sinc : process (reset, clk)

begin

	if ( reset = '1' ) then

		ang <= "100";
		dir <= DIR_INICIAL;
		write_data(0) <= '0';
	
	elsif ( rising_edge(clk) ) then
	
		ang <= p_ang;
		dir <= p_dir;
		write_data(0) <= p_write_data(0);
		
	end if;

end process;

end Behavioral;

