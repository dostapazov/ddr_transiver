-- megafunction wizard: %ALTDDIO_OUT%

LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY alt_ddr_out IS
GENERIC (
    DATA_WIDTH : positive range 1 to  256;
    DEVICE_FAMILY : string :="Cyclone V"
);
	PORT
	(
		aclr		: IN STD_LOGIC ;
		datain_h	: IN STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
		datain_l	: IN STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
		oe			: IN STD_LOGIC ;
		outclock	: IN STD_LOGIC ;
		outclocken	: IN STD_LOGIC ;
		dataout		: OUT STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0)
	);
END alt_ddr_out;

ARCHITECTURE SYN OF alt_ddr_out IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);

BEGIN
	dataout    <= sub_wire0(DATA_WIDTH-1 DOWNTO 0);

	ALTDDIO_OUT_component : ALTDDIO_OUT
	GENERIC MAP (
		extend_oe_disable => "OFF",
		intended_device_family => DEVICE_FAMILY, --"Cyclone V",
		invert_output => "OFF",
		lpm_hint => "UNUSED",
		lpm_type => "altddio_out",
		oe_reg => "UNREGISTERED",
		power_up_high => "OFF",
		width => 4
	)
	PORT MAP (
		aclr => aclr,
		datain_h => datain_h,
		datain_l => datain_l,
		oe => oe,
		outclock => outclock,
		outclocken => outclocken,
		dataout => sub_wire0
	);



END SYN;
