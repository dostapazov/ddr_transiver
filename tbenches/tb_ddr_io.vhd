library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library vunit_lib;
    context vunit_lib.vunit_context;  

entity tb_ddr_io is
  generic (
    runner_cfg : string ;
    DATA_WIDTH  : positive := 4
  );

  use work.alt_ddr_in;
  use work.alt_ddr_out;
end entity;

architecture rtl of tb_ddr_io is
signal  test_active : boolean := true;
signal  aclr		: std_logic;
signal  rx_h	    : std_logic_vector(DATA_WIDTH-1 downto 0);
signal  rx_l	    : std_logic_vector(DATA_WIDTH-1 downto 0);
signal  tx_h	    : std_logic_vector(DATA_WIDTH-1 downto 0);
signal  tx_l	    : std_logic_vector(DATA_WIDTH-1 downto 0);
signal  oe			: std_logic;
signal  outclock	: std_logic;
signal  outclocken	: std_logic;
signal  inclocken	: std_logic;
signal  dataline	: std_logic_vector(DATA_WIDTH-1 downto 0);

constant CLOCK_PERIOD : time := 20 ps;

procedure gen_clk(signal clk : inout std_logic) is
begin
    clk <= '0';
    while(test_active) loop
        wait for CLOCK_PERIOD/2;
        clk <= not clk;
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
		datain_h	=> tx_h	,
		datain_l	=> tx_l	,
		oe			=> oe		,	
		outclock	=> outclock	,
		outclocken	=> outclocken,	
		dataout		=> dataline		
    );

    ddr_in : entity work.alt_ddr_in
    generic map
    (
        DATA_WIDTH => DATA_WIDTH
    )
    port map
    (
   		aclr		=> aclr		,
		datain	    => dataline	,
		inclock	    => outclock	,
		inclocken	=> inclocken,	
		dataout_h	=> rx_h,
        dataout_l	=> rx_l
    );

    main: process
        procedure reset is
        begin
            aclr <= '0';
            inclocken <= '0';

            tx_l    <= (others => '0');
            tx_h    <= (others => '0');
            outclocken  <= '0';
            oe          <= '0';

            wait until rising_edge(outclock);
            aclr <= '1';
            wait until falling_edge(outclock);
            aclr <= '0';
            wait until rising_edge(outclock);
        end procedure;

        procedure enable_clock(en : boolean ) is
        begin
            if(en) then
            outclocken <= '1';
            inclocken <= '1';
           else
            outclocken <= '0';
            inclocken <= '0';
           end if; 
        end procedure;

        procedure enable_output(en : boolean ) is
        begin
            if(en) then
            oe <= '1';
           else
            oe <= '0';
           end if; 
        end procedure;
    begin
        test_runner_setup(runner, runner_cfg);
        while(test_suite) loop
            if run("test") then
              reset;
              enable_output(true); 
              wait for CLOCK_PERIOD;
              enable_clock(true);
              tx_h <= "0101";
              tx_l <= "1010";
              for i in 1 to 10 loop
                wait until rising_edge(outclock);
                tx_h <= not tx_h;
                tx_l <= not tx_l;
              end loop;
              
              enable_clock(false);
              enable_output(false); 
              
            end if;
        end loop;

        wait for 3 * CLOCK_PERIOD;
        test_active <= false;
        test_runner_cleanup(runner);
        
    end process;
  ckl : gen_clk(outclock);  
end architecture;
