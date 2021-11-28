library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ddr_transmitter is
  generic (
    SYMBOL_WIDTH    : positive :=32;
    LINES           : positive :=3;
    PRE_CLOCK       : positive range 2 to 16 := 4;
    POST_CLOCK      : positive range 2 to 16 := 4
  );
  port (
      i_rst     : std_logic;

      i_sys_clk     : std_logic;
      i_data    : std_logic_vector(LINES*SYMBOL_WIDTH-1 downto 0);
      i_valid   : std_logic;
      o_ack     : std_logic;

      i_mode    : std_logic; -- 0 - tx
      i_tx_clk  : std_logic;
      o_tx_clk  : std_logic;
      o_lines   : std_logic_vector(LINES-1 downto 0);

--  diag signals
      o_busy    : std_logic
  );

    use work.alt_ddr_out;  
    use work.shift_reg;
end entity;

architecture rtl of ddr_transmitter is

    signal s_tx_reset : std_logic;
    signal s_sh_en   : std_logic;
    signal s_sh_rdy  : std_logic;
    signal s_sh_data : std_logic_vector(2*LINES-1 downto 0);
    signal s_sh_busy : std_logic;
    
begin

       
       ddr_out : entity work.alt_ddr_out
       generic map
       (
           DATA_WIDTH => LINES
       )
       port map
       (
        aclr		=>  s_tx_reset,
        datain_h	=>  s_sh_data(s_sh_data'high  downto LINES),
        datain_l	=>  s_sh_data(LINES-1  downto  0),
        oe			=>  not i_mode,
        outclock	=>  i_tx_clk,
        outclocken	=>  s_out_clk_en,
        dataout		=>  o_lines
       );

       sh_reg : entity work.shift_reg
       generic map
       (
        DIN_WITDH => i_data'length,
        DOUT_WIDTH => LINES
       )
       port map
       (
        i_rst     => s_tx_reset,
        i_clk     => i_tx_clk,
        i_en      => s_sh_en,
        i_data    => i_data,
        o_data    => s_sh_data,
        o_rdy     => s_sh_rdy,
        o_busy    => s_sh_busy
       ); 
end architecture;
