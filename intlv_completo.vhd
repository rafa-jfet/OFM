----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:47:25 07/01/2015 
-- Design Name: 
-- Module Name:    intlv_completo - Behavioral 
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

entity intlv_completo is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           button : in  STD_LOGIC;
           modulation : in  STD_LOGIC_VECTOR (2 downto 0);
           bit_in : in  STD_LOGIC;
           ok_bit_in : in  STD_LOGIC;
           bit_out : out  STD_LOGIC_VECTOR (0 downto 0);
           ok_bit_out : out  STD_LOGIC);
end intlv_completo;

architecture Behavioral of intlv_completo is

-- señales de salida del interleaver, entrada a la memoria
signal write_intlv_mem, bit_out_intlv_mem : STD_LOGIC_VECTOR (0 downto 0);
signal dir_bit_intlv_mem : STD_LOGIC_VECTOR (8 downto 0);

component intlv is
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
end component;

component intlv_mem is
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END component;

begin

interleaver : intlv
    Generic map (	bits_BPSK => 96,
					bits_QPSK => 192,
					bits_8PSK => 288,
					col_BPSK => 12,
					col_QPSK => 12,
					col_8PSK => 18,
					fil_BPSK => 8,
					fil_QPSK => 16,
					fil_8PSK => 16)
					
	 Port map ( clk => clk,
           reset => reset,
           button => button,
           modulation => modulation,
			  bit_in => bit_in,
           ok_bit_in => ok_bit_in,
           bit_out => bit_out_intlv_mem, --
           dir_bit => dir_bit_intlv_mem, --
           write_mem => write_intlv_mem, --
			  ok_bit_out => ok_bit_out
			  );

interleaver_memory : intlv_mem
  PORT map (
    clka => clk,
    wea => write_intlv_mem,
    addra => dir_bit_intlv_mem,
    dina => bit_out_intlv_mem,
    douta => bit_out
  );



end Behavioral;

