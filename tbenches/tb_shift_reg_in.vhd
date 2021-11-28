library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_arith.all;

library vunit_lib;
    context vunit_lib.vunit_context;  

entity tb_shift_reg_in is
  generic (
    runner_cfg : string;
    IN_WIDTH   : positive := 4
  );
  use work.shift_reg;
end entity;

architecture rtl of tb_shift_reg_in is

    constant OUT_WIDTH  : positive := IN_WIDTH * 8;
    constant CLOCK_PERIOD : time := 20 ps;
    signal test_active : boolean := true;

    signal i_clk, i_rst,i_en, o_rdy, o_busy : std_logic;
       
    signal i_data  : std_logic_vector(IN_WIDTH-1 downto 0);
    signal o_data  : std_logic_vector(OUT_WIDTH-1 downto 0);
    
    procedure gen_clk(signal clk : inout std_logic) is
    begin
        clk <= '0';
        while(test_active) loop
            wait for CLOCK_PERIOD/2;
            clk <= not clk;
        end loop;
        wait;
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


    procedure check_shift(constant value : integer ) is
    begin
      start_shift(value);
      wait until rising_edge(o_rdy) for 100*CLOCK_PERIOD;
      wait for 1 ps;
      check(o_rdy = '1', "Expected that o_rdy become 1");
      for i in 0 to OUT_WIDTH/IN_WIDTH-1 loop
        check(o_data( i*IN_WIDTH + IN_WIDTH-1  downto i*IN_WIDTH) = i_data,"Expected that all output same  as input");
      end loop;
    end procedure;

    procedure check_word(constant value: integer)
    is
      variable src : std_logic_vector(o_data'range);
      variable idx : integer;
    begin
      idx := OUT_WIDTH/IN_WIDTH-1;
      src := conv_std_logic_vector(value,src'length);
      for i in 0 to OUT_WIDTH/IN_WIDTH-1  loop
        start_shift( src( idx*IN_WIDTH + IN_WIDTH-1  downto idx*IN_WIDTH));
        idx := idx -1;
        wait until rising_edge(i_clk) ;
      end loop;
      i_en <= '0';
      wait until rising_edge(o_rdy) for 100*CLOCK_PERIOD;
      wait for 1 ps;
      check (src = o_data, "Expected o_data equal source");
      
    end procedure;


  begin
        test_runner_setup(runner, runner_cfg);
        while(test_suite) loop
            if run("reset shuold drop o_ready to zero") then
              reset;
              check(o_rdy = '0' ,"expect reset drop o_rdy to zero");
            elsif run("shift enable should rize o_rdy") then  
              reset; 
              start_shift(16#A#);
              wait until rising_edge(o_rdy) for 100*CLOCK_PERIOD;
              wait for 1 ps;
              check(o_rdy = '1', "Expected that o_rdy become 1");
            elsif run("shift should fill d_output") then    
              reset;
              check_shift(16#C#);
            elsif run("shift should rize o_rdy each time until i_en active") then    
              reset;
              check_shift(16#C#);
              check_shift(16#A#);
              check_shift(16#7#);
            elsif run("test full word") then      
              reset;
              check_word(16#12345678#);
            end if;
        end loop;
        wait for 3*CLOCK_PERIOD;
        test_active <= false;
        test_runner_cleanup(runner);
  end process;

    clk : gen_clk(i_clk);
end architecture;
