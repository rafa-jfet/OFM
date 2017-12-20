----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:26:24 07/04/2015 
-- Design Name: 
-- Module Name:    mapper_completo - Behavioral 
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

entity mapper_completo is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           bit_in : in  STD_LOGIC_VECTOR (0 downto 0);
           ok_bit_in : in  STD_LOGIC;
           modulation : in  STD_LOGIC_VECTOR (2 downto 0);
           dir_data : out  STD_LOGIC_VECTOR (6 downto 0);
           write_data : out  STD_LOGIC_VECTOR (0 downto 0);
           data_out : out  STD_LOGIC_VECTOR (15 downto 0);
           ok_data : out  STD_LOGIC);
end mapper_completo;

architecture Behavioral of mapper_completo is

-- señales de salida del gray2angleinc, entrada al mapper 
signal ang_inc : STD_LOGIC_VECTOR (2 downto 0);
signal ok_ang_inc : STD_LOGIC;


component gray2angleinc is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  bit_in : in  STD_LOGIC_VECTOR (0 downto 0);
           ok_bit_in : in  STD_LOGIC;
           modulation : in STD_LOGIC_VECTOR (2 downto 0);
			  anginc_out : out  STD_LOGIC_VECTOR (2 downto 0);
           ok_anginc_out : out  STD_LOGIC);
end component;



component mapper is
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
end component;


begin

conv_gray_to_ang : gray2angleinc
    Port map ( clk => clk,
           reset => reset,
			  bit_in => bit_in,
           ok_bit_in => ok_bit_in,
           modulation => modulation,
			  anginc_out => ang_inc, --
           ok_anginc_out => ok_ang_inc); --
			  
			  
mapp : mapper 
	Generic map(	DIR_INICIAL => "0010000", -- 16
					DIR_FINAL => 112,
					pos_A2 => "01100100", -- 100
					pos_A1 => "01000111", -- 71
					A0 => "00000000", -- 0
					neg_A1 => "10111001", -- -71
					neg_A2 => "10011100") -- -100
					
    Port map ( clk => clk,
           reset => reset,
           anginc => ang_inc, --
           ok_anginc => ok_ang_inc, --
			  dir_data => dir_data,
			  write_data => write_data,
			  Q_data => data_out(7 downto 0),
           I_data => data_out(15 downto 8),
			  ok_data => ok_data);



end Behavioral;

