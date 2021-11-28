library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity shift_reg is
  generic (
    DIN_WITDH  : positive := 1;
    DOUT_WIDTH : positive := 8
  );
  port (
      i_rst     : in    std_logic;
      i_clk     : in    std_logic;
      i_en      : in    std_logic;
      i_data    : in    std_logic_vector(DIN_WITDH -1 downto 0);
      o_data    : out   std_logic_vector(DOUT_WIDTH - 1 downto 0);
      o_rdy     : out   std_logic;

      o_busy    : out   std_logic
      
  );
end entity;

architecture rtl of shift_reg is
  type   FSM_STATE is (IDLE, SHIFT, VALID);
  signal curr_state : FSM_STATE :=IDLE;

  signal s_idata  : std_logic_vector(i_data'range);
  signal s_odata  : std_logic_vector(o_data'range);
  signal s_rdy    : std_logic;
begin

  o_rdy   <= s_rdy;
  o_data  <= s_odata;
  o_busy  <= '0' when curr_state = IDLE else '1';

  shift_gen:
  if DIN_WITDH < DOUT_WIDTH generate
   -- section shift from in
    s_rdy <= '1' when curr_state = VALID else '0';
    s_idata <= i_data;

    sh : process(i_rst, i_clk) is
      constant SHIFT_COUNT: positive   := DOUT_WIDTH / DIN_WITDH-1;
      variable v_counter  : positive range 1 to SHIFT_COUNT;
      procedure do_load is
      begin 
        if(i_en = '1') then
          curr_state <= SHIFT;
          s_odata(s_idata'range) <= s_idata;
          v_counter := 1;
        else
          curr_state <= IDLE;
        end if;
      end procedure;

      procedure do_shift is
      begin 
        s_odata<=s_odata(s_odata'high - s_idata'length downto 0) &s_idata;
        
        if(v_counter < SHIFT_COUNT) then
          v_counter := v_counter + 1;
        else
          curr_state <= VALID;
        end if;
      end procedure;

    begin 
      if i_rst = '1' then
        curr_state <= IDLE;
      elsif rising_edge(i_clk) then
        case curr_state is
          when IDLE | VALID =>
              do_load;
          when SHIFT =>
            do_shift;
          when others =>
            curr_state <= IDLE;
        end case;
      end if;
    end process;

  else generate
    -- section shift from 
    s_rdy <= '0' when curr_state = VALID and i_en = '1' else '1';
    s_odata <= s_idata(s_idata'high downto s_idata'high - s_odata'high);

    sh : process(i_rst , i_clk)
      constant SHIFT_COUNT : positive := DIN_WITDH / DOUT_WIDTH - 1;
      variable v_counter : positive range 1 to SHIFT_COUNT;
      constant v_zero : std_logic_vector(o_data'range) := (others=>'0');
    begin
      if(i_rst = '1') then
        curr_state <= IDLE;
      elsif rising_edge(i_clk) then
        case curr_state is
          when IDLE =>
              if(i_en = '1') then
                curr_state <= VALID;
              end if;
          when VALID=>
               if(i_en = '1')  then
                curr_state <= SHIFT;
                s_idata <= i_data;
                v_counter := 1;
               else
                 curr_state <=IDLE;
               end if;
          when SHIFT =>
              s_idata <= s_idata(s_idata'high - s_odata 'length downto 0) & v_zero;
              if(v_counter < SHIFT_COUNT) then
                  v_counter := v_counter + 1;
              elsif(i_en = '1') then
                curr_state <= VALID;
              else 
                curr_state <= VALID;   
              end if;

          when others =>
          curr_state <= IDLE;
          
        end case;
      end if;
    end process;


  end generate;
  
end architecture;
