-- ----------------------------------------------------------------------------
-- Author     : Michael Jørgensen
-- Platform   : AMD Artix 7
-- ----------------------------------------------------------------------------
-- Description: Arbitrate between two different AXI masters
-- ----------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity axi_arbiter is
  generic (
    G_DATA_SIZE : natural
  );
  port (
    clk_i      : in    std_logic;
    rst_i      : in    std_logic;

    s0_ready_o : out   std_logic;
    s0_valid_i : in    std_logic;
    s0_data_i  : in    std_logic_vector(G_DATA_SIZE - 1 downto 0);

    s1_ready_o : out   std_logic;
    s1_valid_i : in    std_logic;
    s1_data_i  : in    std_logic_vector(G_DATA_SIZE - 1 downto 0);

    m_ready_i  : in    std_logic;
    m_valid_o  : out   std_logic;
    m_data_o   : out   std_logic_vector(G_DATA_SIZE - 1 downto 0)
  );
end entity axi_arbiter;

architecture synthesis of axi_arbiter is

  type   state_type is (SLAVE_0_ST, SLAVE_1_ST);
  signal state : state_type := SLAVE_0_ST;

begin

  s0_ready_o <= (m_ready_i or not m_valid_o) when state = SLAVE_0_ST else
                '0';
  s1_ready_o <= (m_ready_i or not m_valid_o) when state = SLAVE_1_ST else
                '0';

  fsm_proc : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if m_ready_i = '1' then
        m_valid_o <= '0';
      end if;

      case state is

        when SLAVE_0_ST =>
          if s0_valid_i = '1' and s0_ready_o = '1' then
            m_data_o  <= s0_data_i;
            m_valid_o <= '1';
          end if;

          if s1_valid_i = '1' then
            state <= SLAVE_1_ST;
          end if;

        when SLAVE_1_ST =>
          if s1_valid_i = '1' and s1_ready_o = '1' then
            m_data_o  <= s1_data_i;
            m_valid_o <= '1';
          end if;

          if s0_valid_i = '1' then
            state <= SLAVE_0_ST;
          end if;

      end case;

      if rst_i = '1' then
        m_valid_o <= '0';
        state     <= SLAVE_0_ST;
      end if;
    end if;
  end process fsm_proc;

end architecture synthesis;

