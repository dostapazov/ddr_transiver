
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_arith.all;

library vunit_lib;
    context vunit_lib.vunit_context;  

entity tb_shift_reg_out is
  generic (
    runner_cfg : string;
    IN_WIDTH   : positive := 32
  );
  use work.shift_reg;
end entity;



architecture rtl of tb_shift_reg_out is

    constant OUT_WIDTH  : positive := IN_WIDTH / 8;
    constant CLOCK_PERIOD : time := 20 ps;
    signal test_active : boolean := true;

    signal i_clk, i_rst,i_en, o_rdy , o_busy: std_logic;
       
    signal i_data  : std_logic_vector(IN_WIDTH-1 downto 0);
    signal o_data  : std_logic_vector(OUT_WIDTH-1 downto 0);
    
    procedure gen_clk(signal clk : inout std_logic) is
    begin
        clk <= '0';
        while(test_active) loop
            wait for CLOCK_PERIOD/2;
            clk <= not clk;
        end loop;
    end procedure;
begin
    
 dut : 
 entity work.shift_reg 
  generic map (
    DIN_WITDH  => IN_WIDTH,
    DOUT_WIDTH => OUT_WIDTH
    
  )
  port map(
      i_rst     => i_rst  , 
      i_clk     => i_clk  ,
      i_en      => i_en   ,
      i_data    => i_data ,
      o_data    => o_data ,
      o_rdy     => o_rdy  ,
      o_busy    => o_busy
  );

  main: process
    
    procedure reset is
    begin
        i_rst <= '0';
        i_en  <= '0';
        i_data <= (others => 'Z');  
        wait until rising_edge(i_clk);
        i_rst <= '1';
        wait until rising_edge(i_clk);
        i_rst <= '0';
        wait until rising_edge(i_clk);
    end procedure;

    procedure start_shift(constant value : std_logic_vector(i_data'range) ) is
    begin
      i_data <= value;
      wait until falling_edge(i_clk);
      i_en <= '1';
    end procedure;

    procedure start_shift(constant value : integer ) is
    begin
      start_shift( conv_std_logic_vector(value, i_data'length));
    end procedure;


  begin
        test_runner_setup(runner, runner_cfg);
        while(test_suite) loop
            if run("reset should set up o_rdy to 1") then
              reset;
              check(o_rdy = '1',"Expected o_rdy");
            elsif run("test shift work") then
              reset;
              start_shift(16#12345678#);
              for i in 0 to 7 loop
                wait until falling_edge(o_rdy) for 100*CLOCK_PERIOD;
                wait for 1 ps;
                check(o_rdy = '0',"Expected than rdy is drop down to confirm  data latched");
                wait until rising_edge(i_clk) ;
                wait for 1 ps;
                check(o_rdy = '1',"Expected than rdy is drop down to confirm  data latched");
              end loop;

              wait until rising_edge (i_clk);
              i_en <= '0';
              wait until falling_edge(o_busy) for 100*CLOCK_PERIOD;
              wait for 1 ps;
              check(o_busy = '0',"Expected than o_busy is drop down ");
              
              
            end if;
        end loop;
        wait for 3*CLOCK_PERIOD;
        test_active <= false;
        test_runner_cleanup(runner);
  end process;

    clk : gen_clk(i_clk);
end architecture;
