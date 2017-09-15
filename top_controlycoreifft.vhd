----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.06.2015 15:54:30
-- Design Name: 
-- Module Name: IFFT_completa - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

entity IFFT_completa is
    Port ( 
            clk: in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR (15 downto 0);
            address_read : out STD_LOGIC_VECTOR(6 downto 0);
            IfftEnable: in STD_LOGIC;
            reset: in STD_LOGIC;
            address_write :out STD_LOGIC_VECTOR(8 downto 0);
				EnableTxserie :out STD_LOGIC;
            datos_salida :out STD_LOGIC_VECTOR(31 downto 0);
				we :out STD_LOGIC  );
end IFFT_completa;



architecture Behavioral of IFFT_completa is

signal s_start, s_cp_len_we, s_unload,s_fwd_inv, s_fwd_inv_we, s_rfd, s_cpv,s_dv,s_edone: STD_LOGIC;
signal s_cp_len,s_xk_index : STD_LOGIC_VECTOR (6 DOWNTO 0);
signal s_xk_re, s_xk_im : STD_LOGIC_VECTOR (15 downto 0);



COMPONENT ifft is
	PORT (
				clk : IN STD_LOGIC;
				sclr : IN STD_LOGIC;
				start : IN STD_LOGIC;
				unload : IN STD_LOGIC;
				cp_len : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
				cp_len_we : IN STD_LOGIC;
				xn_re : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
				xn_im : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
				fwd_inv : IN STD_LOGIC;
				fwd_inv_we : IN STD_LOGIC;
				rfd : OUT STD_LOGIC;
				xn_index : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				busy : OUT STD_LOGIC;
				edone : OUT STD_LOGIC;
				done : OUT STD_LOGIC;
				dv : OUT STD_LOGIC;
				xk_index : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
				cpv : OUT STD_LOGIC;
				xk_re : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				xk_im : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
				);
END COMPONENT;



COMPONENT ifftcontrol is
	GENERIC (
				CARRIERS : INTEGER :=128 );
	PORT (
				reset : in  STD_LOGIC;
				clk : in  STD_LOGIC;
				IfftEnable: in STD_LOGIC;
				start : out STD_LOGIC;
				cp_len : out STD_LOGIC_VECTOR(6 DOWNTO 0);
				cp_len_we: out STD_LOGIC;
				fwd_inv : out STD_LOGIC;
				fwd_inv_we : out STD_LOGIC;
				unload : out STD_LOGIC;
				rfd : in STD_LOGIC
				);
END COMPONENT;
	
	
COMPONENT guardaifft is
	PORT (
				reset : IN std_logic;
				clk : IN std_logic;
				dv : IN std_logic;
				edone: in STD_LOGIC;
				cpv : IN std_logic;
				xk_index : IN std_logic_vector(6 downto 0);
				xk_re : IN std_logic_vector(15 downto 0);
				xk_im : IN std_logic_vector(15 downto 0);          
				we : OUT std_logic;
				EnableTxserie : OUT std_logic;
				dato_out : OUT std_logic_vector(31 downto 0);
				addresout : OUT std_logic_vector(8 downto 0)
				);
END COMPONENT;



begin



core1 : ifft
PORT MAP (
				clk => clk,
				sclr => reset,
				start => s_start,
				unload => s_unload,
				cp_len => s_cp_len,
				cp_len_we => s_cp_len_we,
				xn_re => data_in (15 downto 8),
				xn_im => data_in (7 downto 0),
				fwd_inv => s_fwd_inv,
				fwd_inv_we => s_fwd_inv_we,
				rfd => s_rfd ,
				xn_index => address_read,
				busy => open,
				edone => open,
				done => s_edone,
				dv => s_dv,
				xk_index => s_xk_index ,
				cpv => s_cpv,
				xk_re => s_xk_re,
				xk_im => s_xk_im
				);
  


control: IfftControl
PORT MAP (
				reset => reset,
				clk => clk,
				IfftEnable => IfftEnable,
				start =>s_start,
				cp_len => s_cp_len ,
				cp_len_we => s_cp_len_we,
				fwd_inv => s_fwd_inv,
				fwd_inv_we=> s_fwd_inv_we ,
				unload => s_unload,
				rfd =>s_rfd
				);  



Inst_guardaifft : guardaifft 
PORT MAP(
				reset => reset ,
				clk => clk ,
				dv => s_dv,
				edone => s_edone,
				cpv =>s_cpv,
				xk_index => s_xk_index,
				we => we ,
				xk_re => s_xk_re,
				xk_im => s_xk_im,
				EnableTxserie => EnableTxserie,
				dato_out => datos_salida,
				addresout => address_write
				);
  
end Behavioral;
