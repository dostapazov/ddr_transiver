library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library vunit_lib;
    context vunit_lib.vunit_context;  

entity tb_shift_reg_out is
  generic (
    runner_cfg : string;
    OUT_WIDTH   : positive := 32
  );
  use work.shift_reg;
end entity;



architecture rtl of tb_shift_reg_out is

    constant IN_WIDTH  : positive := OUT_WIDTH / 8;
    constant CLOCK_PERIOD : time := 20 ps;
    signal test_active : boolean := true;

    signal i_clk, i_rst,i_en, o_rdy : std_logic;
       
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
      o_rdy     => o_rdy  
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

  begin
        test_runner_setup(runner, runner_cfg);
        while(test_suite) loop
            if run("reset should set up o_rdy to zero") then
              reset;
              check(o_rdy = '0',"Expected o_rdy");
            end if;
        end loop;
        wait for 3*CLOCK_PERIOD;
        test_active <= false;
        test_runner_cleanup(runner);
  end process;

    clk : gen_clk(i_clk);
end architecture;
