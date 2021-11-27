
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY alt_ddr_in IS
GENERIC 
(
    DATA_WIDTH : positive range 0 to 256;
    DEVICE_FAMILY : string :="Cyclone V"
);
	PORT
	(
		aclr		: IN STD_LOGIC ;
		datain		: IN STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
		inclock		: IN STD_LOGIC ;
		inclocken		: IN STD_LOGIC ;
		dataout_h		: OUT STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
		dataout_l		: OUT STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0)
	);
END alt_ddr_in;


ARCHITECTURE SYN OF alt_ddr_in IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);

BEGIN
	dataout_h    <= sub_wire0(DATA_WIDTH-1 DOWNTO 0);
	dataout_l    <= sub_wire1(DATA_WIDTH-1 DOWNTO 0);

	ALTDDIO_IN_component : ALTDDIO_IN
	GENERIC MAP (
		intended_device_family =>  DEVICE_FAMILY, -- "Cyclone V",
		invert_input_clocks => "OFF",
		lpm_hint => "UNUSED",
		lpm_type => "altddio_in",
		power_up_high => "OFF",
		width => 4
	)
	PORT MAP (
		aclr => aclr,
		datain => datain,
		inclock => inclock,
		inclocken => inclocken,
		dataout_h => sub_wire0,
		dataout_l => sub_wire1
	);



END SYN;

