----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:51:35 06/30/2015 
-- Design Name: 
-- Module Name:    TX_OFDM - Behavioral 
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

entity TX_OFDM is
	 Generic ( 	BUS_DIR_ROM : integer := 6
					);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           button : in  STD_LOGIC;
			  modulation : in STD_LOGIC_VECTOR (2 downto 0);
--			  bit_in : in std_logic;
--			  ok_bit_in : in std_logic;
--			  fin_rx : in std_logic;
--			  dir_out : in STD_LOGIC_VECTOR (8 downto 0);
			  bit_out : out STD_LOGIC
--			  EnableTXserie : out STD_LOGIC
				);
end TX_OFDM;

architecture Behavioral of TX_OFDM is



-- señales de salida correspondientes al divisor de frecuencia
signal sat_div : STD_LOGIC;

-- señales de salida correspondientes al mux de memoria
signal bit_mem_enc, ok_bit_mem_enc, fin_mem_enc : STD_LOGIC;
signal data_read : STD_LOGIC_VECTOR (7 downto 0);
signal dir_read : STD_LOGIC_VECTOR (BUS_DIR_ROM -1 downto 0);

-- señales de salida correspondientes al convolutional encoder
signal first_bit_enc_scr, second_bit_enc_scr, ok_bit_enc_scr, fin_enc_scr : STD_LOGIC;

-- señales de salida correspondientes al scrambler
signal bit_scr_intlv, ok_bit_scr_intlv : STD_LOGIC;

-- señales de salida correspondientes al interleaver
signal bit_intlv_map : STD_LOGIC_VECTOR (0 downto 0);
signal ok_bit_intlv_map : STD_LOGIC;

-- señales de salida correspondientes al mapper
signal write_map_ifftmem : STD_LOGIC_VECTOR (0 downto 0);
signal dir_map_ifftmem : STD_LOGIC_VECTOR (6 downto 0);
signal data_map_ifftmem : STD_LOGIC_VECTOR (15 downto 0);
signal ok_data_map_ifft : STD_LOGIC;

-- señales de salida correspondientes a la memoria mapper > IFFT
signal data_mem_ifft : STD_LOGIC_VECTOR (15 downto 0);

-- señales de salida correspondientes a la IFFT
signal dir_ifft_mem : STD_LOGIC_VECTOR (6 downto 0);
signal dir_ifft_memTX : STD_LOGIC_VECTOR (8 downto 0);
signal EnableTXserie : STD_LOGIC; 
signal datos_ifft_memTX : STD_LOGIC_VECTOR (31 downto 0);
signal write_ifft_memTX : STD_LOGIC_VECTOR (0 downto 0);

-- señales de salida correspondientes a la memoria de salida
signal data_mem_TXserie : std_logic_vector (31 downto 0);

-- señales de salida correspondientes al transmisor serie
signal dir_TXserie_mem : std_logic_vector (8 downto 0);



component miBlockRAM IS
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END component;



component mem_read is
	Generic ( 	ancho_bus_direcc : integer := 6;
					TAM_BYTE : integer := 8;
					bit_DBPSK : integer := 48;
					bit_DQPSK : integer := 96;
					bit_D8PSK : integer := 144);
					
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           button : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
			  modulation : in STD_LOGIC_VECTOR (2 downto 0);
           sat : in STD_LOGIC;
			  direcc : out  STD_LOGIC_VECTOR (ancho_bus_direcc -1 downto 0);
           bit_out : out  STD_LOGIC;
           ok_bit_out : out  STD_LOGIC;
			  fin : out  STD_LOGIC);
end component;



component div_frec is
	Generic (	SAT_BPSK : integer := 30;
					SAT_QPSK : integer := 20;
					SAT_8PSK : integer := 10 );
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           button : in STD_LOGIC;
			  modulation : in STD_LOGIC_VECTOR (2 downto 0);
			  sat : out  STD_LOGIC);
end component;



component convolutional_encoder is
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
end component;



component scrambler is
    Generic (	SAT_ESPERA : integer := 7);
	 Port ( 	clk : in  STD_LOGIC;
				reset : in  STD_LOGIC;
				button : in STD_LOGIC;
				first_in : in  STD_LOGIC;
				second_in : in  STD_LOGIC;
				fin_rx : in STD_LOGIC;
				ok_bit_in : in  STD_LOGIC;
				bit_out : out  STD_LOGIC;
				ok_bit_out : out  STD_LOGIC);
end component;



component intlv_completo is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           button : in  STD_LOGIC;
           modulation : in  STD_LOGIC_VECTOR (2 downto 0);
           bit_in : in  STD_LOGIC;
           ok_bit_in : in  STD_LOGIC;
           bit_out : out  STD_LOGIC_VECTOR (0 downto 0);
           ok_bit_out : out  STD_LOGIC);
end component;



component mapper_completo is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           bit_in : in  STD_LOGIC_VECTOR ( 0 downto 0);
           ok_bit_in : in  STD_LOGIC;
           modulation : in  STD_LOGIC_VECTOR (2 downto 0);
           dir_data : out  STD_LOGIC_VECTOR (6 downto 0);
           write_data : out  STD_LOGIC_VECTOR (0 downto 0);
           data_out : out  STD_LOGIC_VECTOR (15 downto 0);
           ok_data : out  STD_LOGIC);
end component;



component mem_ifft IS
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END component;



component IFFT_completa is
    Port ( 
            clk : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR (15 downto 0);
            address_read : out STD_LOGIC_VECTOR(6 downto 0);
            IfftEnable : in STD_LOGIC;
            reset : in STD_LOGIC;
            address_write : out STD_LOGIC_VECTOR(8 downto 0);
				EnableTxserie : out STD_LOGIC;
            datos_salida : out STD_LOGIC_VECTOR(31 downto 0);
				we : out STD_LOGIC  );
end component;



component memTX IS
  PORT (
				clka : IN STD_LOGIC;
				wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
				addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
				dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
				clkb : IN STD_LOGIC;
				addrb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
				doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
				);
END component;



component FSM is
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
end component;

begin



memoria : miBlockRAM
  PORT map(
    clka => clk,
    addra => dir_read,
    douta => data_read
  );



mux8a1 : mem_read 
	Generic map ( 	ancho_bus_direcc => BUS_DIR_ROM,
					TAM_BYTE => 8,
					bit_DBPSK => 48,
					bit_DQPSK => 96,
					bit_D8PSK => 144)
					
    Port map ( clk => clk,
           reset => reset,
           button => button,
           data => data_read, --
			  modulation => modulation,
           sat => sat_div,
			  direcc => dir_read, --
           bit_out => bit_mem_enc, --
           ok_bit_out => ok_bit_mem_enc, --
			  fin => fin_mem_enc); --



divisor_frecuencia : div_frec
	Generic map (	SAT_BPSK => 2333,
						SAT_QPSK => 1167,
						SAT_8PSK => 778 )
	 Port map (	clk => clk,
					reset => reset,
					button => button,
					modulation => modulation,
					sat => sat_div);



conv_encoder : convolutional_encoder
	Generic map (	TAM_REG => 7,
						SAT_ESPERA => 2)
    Port map ( clk => clk,
					reset => reset,
					button => button,
					bit_in => bit_mem_enc, --
					ok_bit_in => ok_bit_mem_enc, --
					fin_rx => fin_mem_enc, --
					sat => sat_div,
					first_bit_out => first_bit_enc_scr, --
					second_bit_out => second_bit_enc_scr, --
					ok_bit_out => ok_bit_enc_scr, --
					fin_tx => fin_enc_scr); --


					
scr : scrambler
    Generic map (	SAT_ESPERA => 7)
	 Port map ( clk => clk,
					reset => reset,
					button => button,
					first_in => first_bit_enc_scr, --
					second_in => second_bit_enc_scr, --
					fin_rx => fin_enc_scr, --
					ok_bit_in => ok_bit_enc_scr, --
					bit_out => bit_scr_intlv, --
					ok_bit_out => ok_bit_scr_intlv);



interleaver : intlv_completo
    Port map (	clk => clk,
					reset => reset,
					button => button,
					modulation => modulation,
					bit_in => bit_scr_intlv, --
					ok_bit_in => ok_bit_scr_intlv, --
					bit_out => bit_intlv_map, --
					ok_bit_out => ok_bit_intlv_map); --



mapp_comp : mapper_completo
    Port map ( clk => clk,
					reset => reset,
					bit_in => bit_intlv_map, --
					ok_bit_in => ok_bit_intlv_map, --
					modulation => modulation,
					dir_data => dir_map_ifftmem, --
					write_data => write_map_ifftmem, --
					data_out => data_map_ifftmem, --
					ok_data => ok_data_map_ifft); --
					
					
					
memory_ifft : mem_ifft
	PORT map (
					clka => clk,
					wea => write_map_ifftmem, --
					addra => dir_map_ifftmem, --
					dina => data_map_ifftmem, --
					clkb => clk,
					addrb => dir_ifft_mem, --
					doutb => data_mem_ifft --
					);



IFFT : IFFT_completa
    Port map ( 
					clk => clk,
					data_in => data_mem_ifft, --
					address_read => dir_ifft_mem, --
					IfftEnable => ok_data_map_ifft, --
					reset => reset,
					address_write => dir_ifft_memTX, --
					EnableTxserie => EnableTXserie, 
					datos_salida => datos_ifft_memTX, --
					we => write_ifft_memTX(0) --
					);



memoria_tx : memTX
	PORT MAP(
					clka => clk,
					wea => write_ifft_memTX, --
					addra => dir_ifft_memTX, --
					dina => datos_ifft_memTX, --
					clkb => clk,
					addrb => dir_TXserie_mem, --
					doutb => data_mem_TXserie --
					);



tx_serie : FSM 
	Generic map (ancho_bus_dir => 9,
				VAL_SAT_CONT => 5208,
				ANCHO_CONTADOR => 13,
				ULT_DIR_TX => 420) -- transmision de 3 simbolos
    Port map ( clk => clk,
           reset => reset,
           button => EnableTXserie, --
           data_in => data_mem_TXserie, --
           direcc => dir_TXserie_mem, --
           TX => bit_out);


end Behavioral;

