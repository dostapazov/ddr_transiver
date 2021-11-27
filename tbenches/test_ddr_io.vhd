library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library vunit_lib;
    context vunit_lib.vunit_context;  

entity test_ddr_io is
  generic (
    runner_cfg : string ;
    DATA_WIDTH  : positive := 4
  );

  use work.alt_ddr_in;
  use work.alt_ddr_out;
end entity;

architecture rtl of test_ddr_io is
signal  test_active : boolean := true;
signal  aclr		: std_logic;
signal  datain_h	: std_logic_vector(DATA_WIDTH-1 downto 0);
signal  datain_l	: std_logic_vector(DATA_WIDTH-1 downto 0);
signal  oe			: std_logic;
signal  outclock	: std_logic;
signal  outclocken	: std_logic;
signal  dataout		: std_logic_vector(DATA_WIDTH-1 downto 0);

constant CLOCK_PERIOD : time := 20 ps;

procedure gen_clk is
begin
    outclock <= '0';
    while(test_active) loop
        wait for CLOCK_PERIOD/2;
        outclock <= not outclock;
    end loop;
end procedure;


begin
    ddr_out : entity work.alt_ddr_out
    generic map
    (
        DATA_WIDTH => DATA_WIDTH
    )
    port map
    (
   		aclr		=> aclr		,
		datain_h	=> datain_h	,
		datain_l	=> datain_l	,
		oe			=> oe		,	
		outclock	=> outclock	,
		outclocken	=> outclocken,	
		dataout		=> dataout		
    );

    main: process
        procedure reset is
        begin
            aclr <= '0';
            datain_l    <= (others => '0');
            datain_h    <= (others => '0');
        end procedure;
    begin
        test_runner_setup(runner, runner_cfg);
        while(test_suite) loop
            if run("test") then
              wait for 10 * CLOCK_PERIOD;
            end if;
        end loop;
        test_runner_cleanup(runner);
        wait for 3 * CLOCK_PERIOD;
        test_active <= false;
    end process;
  ckl : gen_clk;  
end architecture;
