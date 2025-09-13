library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm is
	port(
		i_clk : in std_logic;
		i_en : in std_logic;
		i_dutyCycle : in std_logic_vector(7 downto 0);
		o_pwm : out std_logic
	);
end pwm;

architecture Behavioral of pwm is
	signal  clk         : std_logic;
	signal	en			: std_logic;
	signal	period		: integer range 0 to 125000:= 0;
	signal	periodMAX	: integer:= 125000;
	signal	pulseWidth	: integer range 0 to 125000:= 0;
	signal	dutyCycle	: integer range 0 to 100:= 1;
	signal	pwm			: std_logic;

begin
	----------------------------------------------------------------------------
	clk <= i_clk;
	en <= i_en;
	dutyCycle <= to_integer(unsigned(i_dutyCycle));
	o_pwm <= pwm;
	----------------------------------------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
			if en = '1' then
				----------------------------------------------------------------
				if period < periodMAX - 1 then
					period <= period + 1;
				else
					pulseWidth <= periodMAX * dutyCycle / 100;
					period <= 0;
				end if;
				----------------------------------------------------------------
				if period < pulseWidth - 1 then
					pwm <= '1';
				else
					pwm <= '0';
				end if;
				----------------------------------------------------------------
			end if;	
		end if;
	end process;
	
end Behavioral;
