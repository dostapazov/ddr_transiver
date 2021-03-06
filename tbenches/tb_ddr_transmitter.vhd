library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library vunit_lib;
    context vunit_lib.vunit_context;  


entity tb_ddr_transmitter is
  generic (
    runner_cfg   : string;
    SYMBOL_WIDTH : positive :=32;
    LINES        : positive := 4;
    PRE_CLOCK    : positive range 2 to 16 := 4;
    POST_CLOCK   : positive range 2 to 16 := 4;
    SYS_CLK_PERIOD : time := 10 ps;
    TX_CLK_PERIOD  : time := 20 ps
  );
end entity;

architecture rtl of tb_ddr_transmitter is

    signal i_rst    : std_logic ;
    signal i_sys_clk: std_logic ; 
    signal i_data   : std_logic_vector(LINES*SYMBOL_WIDTH-1 downto 0) ; 
    signal i_valid  : std_logic ; 
    signal o_ack    : std_logic ; 
    signal i_mode   : std_logic ; 
    signal i_tx_clk : std_logic ; 
    signal o_tx_clk : std_logic ; 
    signal o_lines  : std_logic_vector(LINES - 1 downto 0) ; 

    signal test_active: boolean := true;

procedure gen_clk(signal clk : inout std_logic; constant CLOCK_PERIOD : time;  constant EDGE_SHIFT : time := 1 ps ) is
begin
    clk <= '0';
    wait for EDGE_SHIFT;
    while(test_active) loop
        wait for CLOCK_PERIOD/2;
        clk <= not clk;
    end loop;
end procedure;

begin

     dut : entity work.ddr_transmitter
     generic map
     (
         SYMBOL_WIDTH   => SYMBOL_WIDTH,
         LINES  => LINES
     )
      port map(
            i_rst    => i_rst   , 
            i_sys_clk=> i_sys_clk , 
            i_data   => i_data  , 
            i_valid  => i_valid , 
            o_ack    => o_ack   , 
            i_mode   => i_mode  , 
            i_tx_clk => i_tx_clk, 
            o_tx_clk => o_tx_clk, 
            o_lines  => o_lines ,
            o_busy   => open 
        );

  main : process

    procedure reset is
    begin
        i_rst <= '0';
        i_valid <= '0';
        i_mode  <= '0';

        i_data <= (others => 'Z');  
        wait until rising_edge(i_sys_clk);
        i_rst <= '1';
        wait until rising_edge(i_sys_clk);
        i_rst <= '0';
        wait until rising_edge(i_sys_clk);
    end procedure;

  begin
        test_runner_setup(runner, runner_cfg);
        while(test_suite) loop
            if run("reset") then  
            reset;
            end if;
        end loop;
        wait for 3 * TX_CLK_PERIOD;
        test_active <= false;
        test_runner_cleanup(runner);
        wait;
    end process;    

  sys_clk : gen_clk(i_sys_clk,SYS_CLK_PERIOD/2);      
  tx_clk  : gen_clk(i_tx_clk,TX_CLK_PERIOD/2,7 ps);

end architecture;
