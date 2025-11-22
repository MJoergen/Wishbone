-------------------------------------------------------------------------------
-- Description:
-- This module generates empty cycles in an AXI Lite stream by deasserting
-- m_tready_o and s_tvalid_o at random intervals. The period between the empty
-- cycles can be controlled by the generic G_PAUSE_SIZE:
-- * Setting it to 0 disables the empty cycles.
-- * Setting it to 10 inserts empty cycles approximately every tenth cycle, i.e. 90 % throughput.
-- * Setting it to -10 inserts empty cycles except approximately every tenth cycle, i.e. 10 % throughput.
-- * Etc.
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std_unsigned.all;

entity axi_lite_pause is
  generic (
    G_SEED       : std_logic_vector(63 downto 0) := (others => '0');
    G_ADDR_SIZE  : integer;
    G_DATA_SIZE  : integer;
    G_PAUSE_SIZE : integer
  );
  port (
    clk_i            : in    std_logic;
    rst_i            : in    std_logic;

    -- Input
    s_axil_awready_o : out   std_logic;
    s_axil_awvalid_i : in    std_logic;
    s_axil_awaddr_i  : in    std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    s_axil_wready_o  : out   std_logic;
    s_axil_wvalid_i  : in    std_logic;
    s_axil_wdata_i   : in    std_logic_vector(G_DATA_SIZE - 1 downto 0);
    s_axil_wstrb_i   : in    std_logic_vector(G_DATA_SIZE / 8 - 1 downto 0);
    s_axil_bready_i  : in    std_logic;
    s_axil_bvalid_o  : out   std_logic;
    s_axil_arready_o : out   std_logic;
    s_axil_arvalid_i : in    std_logic;
    s_axil_araddr_i  : in    std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    s_axil_rready_i  : in    std_logic;
    s_axil_rvalid_o  : out   std_logic;
    s_axil_rdata_o   : out   std_logic_vector(G_DATA_SIZE - 1 downto 0);

    -- Output
    m_axil_awready_i : in    std_logic;
    m_axil_awvalid_o : out   std_logic;
    m_axil_awaddr_o  : out   std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    m_axil_wready_i  : in    std_logic;
    m_axil_wvalid_o  : out   std_logic;
    m_axil_wdata_o   : out   std_logic_vector(G_DATA_SIZE - 1 downto 0);
    m_axil_wstrb_o   : out   std_logic_vector(G_DATA_SIZE / 8 - 1 downto 0);
    m_axil_bready_o  : out   std_logic;
    m_axil_bvalid_i  : in    std_logic;
    m_axil_arready_i : in    std_logic;
    m_axil_arvalid_o : out   std_logic;
    m_axil_araddr_o  : out   std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    m_axil_rready_o  : out   std_logic;
    m_axil_rvalid_i  : in    std_logic;
    m_axil_rdata_i   : in    std_logic_vector(G_DATA_SIZE - 1 downto 0)
  );
end entity axi_lite_pause;

architecture simulation of axi_lite_pause is

  signal s_axil_w_data : std_logic_vector(G_DATA_SIZE + G_DATA_SIZE / 8 - 1 downto 0);
  signal m_axil_w_data : std_logic_vector(G_DATA_SIZE + G_DATA_SIZE / 8 - 1 downto 0);

begin

  axi_pause_aw_inst : entity work.axi_pause
    generic map (
      G_SEED       => G_SEED xor X"1234BABECAFEDEAD",
      G_DATA_SIZE  => G_ADDR_SIZE,
      G_PAUSE_SIZE => G_PAUSE_SIZE
    )
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i,
      s_tvalid_i => s_axil_awvalid_i,
      s_tready_o => s_axil_awready_o,
      s_tdata_i  => s_axil_awaddr_i,
      m_tvalid_o => m_axil_awvalid_o,
      m_tready_i => m_axil_awready_i,
      m_tdata_o  => m_axil_awaddr_o
    ); -- axi_pause_aw_inst : entity work.axi_pause

  axi_pause_ar_inst : entity work.axi_pause
    generic map (
      G_SEED       => G_SEED xor X"234BABECAFEDEAD2",
      G_DATA_SIZE  => G_ADDR_SIZE,
      G_PAUSE_SIZE => G_PAUSE_SIZE
    )
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i,
      s_tvalid_i => s_axil_arvalid_i,
      s_tready_o => s_axil_arready_o,
      s_tdata_i  => s_axil_araddr_i,
      m_tvalid_o => m_axil_arvalid_o,
      m_tready_i => m_axil_arready_i,
      m_tdata_o  => m_axil_araddr_o
    ); -- axi_pause_aw_inst : entity work.axi_pause

  axi_pause_w_inst : entity work.axi_pause
    generic map (
      G_SEED       => G_SEED xor X"34BABECAFEDEAD23",
      G_DATA_SIZE  => G_DATA_SIZE + G_DATA_SIZE / 8,
      G_PAUSE_SIZE => G_PAUSE_SIZE
    )
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i,
      s_tvalid_i => s_axil_wvalid_i,
      s_tready_o => s_axil_wready_o,
      s_tdata_i  => s_axil_w_data,
      m_tvalid_o => m_axil_wvalid_o,
      m_tready_i => m_axil_wready_i,
      m_tdata_o  => m_axil_w_data
    ); -- axi_pause_w_inst : entity work.axi_pause

  s_axil_w_data                     <= s_axil_wstrb_i & s_axil_wdata_i;
  (m_axil_wstrb_o , m_axil_wdata_o) <= m_axil_w_data;

  axi_pause_b_inst : entity work.axi_pause
    generic map (
      G_SEED       => G_SEED xor X"4BABECAFEDEAD234",
      G_DATA_SIZE  => 1,
      G_PAUSE_SIZE => G_PAUSE_SIZE
    )
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i,
      s_tvalid_i => m_axil_bvalid_i,
      s_tready_o => m_axil_bready_o,
      s_tdata_i  => "0",
      m_tvalid_o => s_axil_bvalid_o,
      m_tready_i => s_axil_bready_i,
      m_tdata_o  => open
    ); -- axi_pause_b_inst : entity work.axi_pause

  axi_pause_r_inst : entity work.axi_pause
    generic map (
      G_SEED       => G_SEED xor X"BABECAFEDEAD2345",
      G_DATA_SIZE  => G_DATA_SIZE,
      G_PAUSE_SIZE => G_PAUSE_SIZE
    )
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i,
      s_tvalid_i => m_axil_rvalid_i,
      s_tready_o => m_axil_rready_o,
      s_tdata_i  => m_axil_rdata_i,
      m_tvalid_o => s_axil_rvalid_o,
      m_tready_i => s_axil_rready_i,
      m_tdata_o  => s_axil_rdata_o
    ); -- axi_pause_r_inst : entity work.axi_pause

end architecture simulation;

