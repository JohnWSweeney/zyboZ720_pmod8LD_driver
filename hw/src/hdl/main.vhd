library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
	port(
		sysclk    : in std_logic;
		red5      : out std_logic;
		green5    : out std_logic;
		blue5     : out std_logic;
		red6     : out std_logic;
		green6     : out std_logic;
		blue6     : out std_logic;
		led       : out std_logic_vector(3 downto 0);
		------------------------------------------------------------------------
		DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
		DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
		DDR_cas_n : inout STD_LOGIC;
		DDR_ck_n : inout STD_LOGIC;
		DDR_ck_p : inout STD_LOGIC;
		DDR_cke : inout STD_LOGIC;
		DDR_cs_n : inout STD_LOGIC;
		DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
		DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_odt : inout STD_LOGIC;
		DDR_ras_n : inout STD_LOGIC;
		DDR_reset_n : inout STD_LOGIC;
		DDR_we_n : inout STD_LOGIC;
		FIXED_IO_ddr_vrn : inout STD_LOGIC;
		FIXED_IO_ddr_vrp : inout STD_LOGIC;
		FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
		FIXED_IO_ps_clk : inout STD_LOGIC;
		FIXED_IO_ps_porb : inout STD_LOGIC;
		FIXED_IO_ps_srstb : inout STD_LOGIC
	);
end main;

architecture Behavioral of main is
	component bdPlPsTest is
	port (
		DDR_cas_n : inout STD_LOGIC;
		DDR_cke : inout STD_LOGIC;
		DDR_ck_n : inout STD_LOGIC;
		DDR_ck_p : inout STD_LOGIC;
		DDR_cs_n : inout STD_LOGIC;
		DDR_reset_n : inout STD_LOGIC;
		DDR_odt : inout STD_LOGIC;
		DDR_ras_n : inout STD_LOGIC;
		DDR_we_n : inout STD_LOGIC;
		DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
		DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
		DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
		DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
		FIXED_IO_ddr_vrn : inout STD_LOGIC;
		FIXED_IO_ddr_vrp : inout STD_LOGIC;
		FIXED_IO_ps_srstb : inout STD_LOGIC;
		FIXED_IO_ps_clk : inout STD_LOGIC;
		FIXED_IO_ps_porb : inout STD_LOGIC;
		en_tri_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
        dutyCycle_tri_o : out STD_LOGIC_VECTOR ( 7 downto 0 )
        );
	end component bdPlPsTest;

	component pwm is
	port (
		i_clk : in std_logic;
		i_en : in std_logic;
		i_dutyCycle : in std_logic_vector(7 downto 0);
		o_pwm : out std_logic
	);
	end component pwm;
  
    signal  clk				: std_logic:= '0';
    signal  gpioLED   		: std_logic_vector(3 downto 0):=(others=> '0');
	signal	gpioRGB5		: std_logic_vector(2 downto 0):=(others=> '0');
	signal	gpioRGB6		: std_logic_vector(2 downto 0):=(others=> '0');
	signal	gpioDutyCycle	: std_logic_vector(7 downto 0):=(others=> '0');
	signal	gpioEN			: std_logic_vector(2 downto 0):=(others=> '0');
	signal	wRedPWM			: std_logic:= '0';
	signal	wGreenPWM		: std_logic:= '0';
	signal	wBluePWM		: std_logic:= '0';
    
begin
bdPlPsTest_i: component bdPlPsTest
	port map (
		DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
		DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
		DDR_cas_n => DDR_cas_n,
		DDR_ck_n => DDR_ck_n,
		DDR_ck_p => DDR_ck_p,
		DDR_cke => DDR_cke,
		DDR_cs_n => DDR_cs_n,
		DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
		DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
		DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
		DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
		DDR_odt => DDR_odt,
		DDR_ras_n => DDR_ras_n,
		DDR_reset_n => DDR_reset_n,
		DDR_we_n => DDR_we_n,
		FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
		FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
		FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
		FIXED_IO_ps_clk => FIXED_IO_ps_clk,
		FIXED_IO_ps_porb => FIXED_IO_ps_porb,
		FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
		dutyCycle_tri_o(7 downto 0) => gpioDutyCycle,
		en_tri_o(2 downto 0) => gpioEN
    );

red_i: component pwm
	port map (
		i_clk => clk,
		i_en => gpioEN(0),
		i_dutyCycle => gpioDutyCycle,
		o_pwm => wRedPWM
	);

green_i: component pwm
	port map (
		i_clk => clk,
		i_en => gpioEN(1),
		i_dutyCycle => gpioDutyCycle,
		o_pwm => wGreenPWM
	);
	
blue_i: component pwm
	port map (
		i_clk => clk,
		i_en => gpioEN(2),
		i_dutyCycle => gpioDutyCycle,
		o_pwm => wBluePWM
	);
	
	clk <= sysclk;

	red5 <= gpioRGB5(0);
	green5 <= gpioRGB5(1);
	blue5 <= gpioRGB5(2);
	
	red6 <= wRedPWM;
	green6 <= wGreenPWM;
	blue6 <= wBluePWM;
	
	led <= gpioLED;
	--------------------------------------------------------------------------

end Behavioral;
