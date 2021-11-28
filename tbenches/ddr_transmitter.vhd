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
      i_rst     : in  std_logic;

      i_sys_clk : in  std_logic;
      i_data    : in  std_logic_vector(LINES*SYMBOL_WIDTH-1 downto 0);
      i_valid   : in  std_logic;
      o_ack     : out std_logic;

      i_mode    : in  std_logic; -- 0 - tx mode
      i_tx_clk  : in  std_logic;
      o_tx_clk  : out std_logic;
      o_lines   : out std_logic_vector(LINES-1 downto 0);

--  diag signals
      o_busy    : out std_logic
  );

    use work.alt_ddr_out;  
    use work.shift_reg;
end entity;

architecture rtl of ddr_transmitter is

    signal s_sh_en      : std_logic;
    signal s_sh_rdy     : std_logic;
    signal s_sh_data    : std_logic_vector(2*LINES-1 downto 0);
    signal s_sh_busy    : std_logic;
    signal s_out_clk_en : std_logic;

    type TX_STATES  is (TX_IDLE,TX_START, TX_PROCESS, TX_END);
    signal tx_curr_state : TX_STATES := TX_IDLE;
    
begin

       o_busy     <= s_sh_busy;
       o_tx_clk   <= i_tx_clk and s_out_clk_en;
          

       ddr_out : entity work.alt_ddr_out
       generic map
       (
           DATA_WIDTH => LINES
       )
       port map
       (
        aclr		=>  i_rst,
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
        DOUT_WIDTH => s_sh_data'length
       )
       port map
       (
        i_rst     => i_rst,
        i_clk     => i_tx_clk,
        i_en      => s_sh_en,
        i_data    => i_data,
        o_data    => s_sh_data,
        o_rdy     => s_sh_rdy,
        o_busy    => s_sh_busy
       ); 

        s_out_clk_en <= '0' when tx_curr_state = TX_IDLE else '1';

       tx : process (i_rst, i_tx_clk)
       begin
         if(i_rst = '1') then
            tx_curr_state <= TX_IDLE;
        elsif rising_edge(i_tx_clk) then
                case tx_curr_state is
                  when TX_IDLE =>
                       if(i_valid = '1')  then
                          tx_curr_state <= TX_START;
                       end if;
                  when TX_START =>
                        tx_curr_state <= TX_PROCESS;
                  when TX_PROCESS =>
                        tx_curr_state <= TX_END;
                  when TX_END =>
                        tx_curr_state <= TX_IDLE;
                  when others => 
                    tx_curr_state <= TX_IDLE;
                end case;
         end if;
       end process;
end architecture;
