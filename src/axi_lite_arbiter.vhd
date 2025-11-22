-- ----------------------------------------------------------------------------
-- Author     : Michael Jørgensen
-- Platform   : AMD Artix 7
-- ----------------------------------------------------------------------------
-- Description: Arbitrate between two different AXI Lite masters
-- ----------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity axi_lite_arbiter is
  generic (
    G_ADDR_SIZE : natural;
    G_DATA_SIZE : natural
  );
  port (
    clk_i        : in    std_logic;
    rst_i        : in    std_logic;

    -- Input
    s0_awready_o : out   std_logic;
    s0_awvalid_i : in    std_logic;
    s0_awaddr_i  : in    std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    s0_wready_o  : out   std_logic;
    s0_wvalid_i  : in    std_logic;
    s0_wdata_i   : in    std_logic_vector(G_DATA_SIZE - 1 downto 0);
    s0_wstrb_i   : in    std_logic_vector(G_DATA_SIZE / 8 - 1 downto 0);
    s0_bready_i  : in    std_logic;
    s0_bvalid_o  : out   std_logic;
    s0_arready_o : out   std_logic;
    s0_arvalid_i : in    std_logic;
    s0_araddr_i  : in    std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    s0_rready_i  : in    std_logic;
    s0_rvalid_o  : out   std_logic;
    s0_rdata_o   : out   std_logic_vector(G_DATA_SIZE - 1 downto 0);

    s1_awready_o : out   std_logic;
    s1_awvalid_i : in    std_logic;
    s1_awaddr_i  : in    std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    s1_wready_o  : out   std_logic;
    s1_wvalid_i  : in    std_logic;
    s1_wdata_i   : in    std_logic_vector(G_DATA_SIZE - 1 downto 0);
    s1_wstrb_i   : in    std_logic_vector(G_DATA_SIZE / 8 - 1 downto 0);
    s1_bready_i  : in    std_logic;
    s1_bvalid_o  : out   std_logic;
    s1_arready_o : out   std_logic;
    s1_arvalid_i : in    std_logic;
    s1_araddr_i  : in    std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    s1_rready_i  : in    std_logic;
    s1_rvalid_o  : out   std_logic;
    s1_rdata_o   : out   std_logic_vector(G_DATA_SIZE - 1 downto 0);

    -- Output
    m_awready_i  : in    std_logic;
    m_awvalid_o  : out   std_logic;
    m_awaddr_o   : out   std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    m_awid_o     : out   std_logic_vector(7 downto 0);
    m_wready_i   : in    std_logic;
    m_wvalid_o   : out   std_logic;
    m_wdata_o    : out   std_logic_vector(G_DATA_SIZE - 1 downto 0);
    m_wstrb_o    : out   std_logic_vector(G_DATA_SIZE / 8 - 1 downto 0);
    m_bready_o   : out   std_logic;
    m_bvalid_i   : in    std_logic;
    m_bid_i      : in    std_logic_vector(7 downto 0);
    m_arready_i  : in    std_logic;
    m_arvalid_o  : out   std_logic;
    m_araddr_o   : out   std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    m_arid_o     : out   std_logic_vector(7 downto 0);
    m_rready_o   : out   std_logic;
    m_rvalid_i   : in    std_logic;
    m_rdata_i    : in    std_logic_vector(G_DATA_SIZE - 1 downto 0);
    m_rid_i      : in    std_logic_vector(7 downto 0)
  );
end entity axi_lite_arbiter;

architecture synthesis of axi_lite_arbiter is

  signal s0_aw_data : std_logic_vector(G_ADDR_SIZE + 7 downto 0);
  signal s1_aw_data : std_logic_vector(G_ADDR_SIZE + 7 downto 0);
  signal m_aw_data  : std_logic_vector(G_ADDR_SIZE + 7 downto 0);

  signal s0_ar_data : std_logic_vector(G_ADDR_SIZE + 7 downto 0);
  signal s1_ar_data : std_logic_vector(G_ADDR_SIZE + 7 downto 0);
  signal m_ar_data  : std_logic_vector(G_ADDR_SIZE + 7 downto 0);

  signal s0_w_data : std_logic_vector(G_DATA_SIZE + G_DATA_SIZE / 8 - 1 downto 0);
  signal s1_w_data : std_logic_vector(G_DATA_SIZE + G_DATA_SIZE / 8 - 1 downto 0);
  signal m_w_data  : std_logic_vector(G_DATA_SIZE + G_DATA_SIZE / 8 - 1 downto 0);

begin

  axi_arbiter_aw_inst : entity work.axi_arbiter
    generic map (
      G_DATA_SIZE => G_ADDR_SIZE + 8
    )
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i,
      s0_ready_o => s0_awready_o,
      s0_valid_i => s0_awvalid_i,
      s0_data_i  => s0_aw_data,
      s1_ready_o => s1_awready_o,
      s1_valid_i => s1_awvalid_i,
      s1_data_i  => s1_aw_data,
      m_ready_i  => m_awready_i,
      m_valid_o  => m_awvalid_o,
      m_data_o   => m_aw_data
    ); -- axi_arbiter_aw_inst : entity work.axi_arbiter

  s0_aw_data              <= x"00" & s0_awaddr_i;
  s1_aw_data              <= x"01" & s1_awaddr_i;
  (m_awid_o , m_awaddr_o) <= m_aw_data;


  axi_arbiter_ar_inst : entity work.axi_arbiter
    generic map (
      G_DATA_SIZE => G_ADDR_SIZE + 8
    )
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i,
      s0_ready_o => s0_arready_o,
      s0_valid_i => s0_arvalid_i,
      s0_data_i  => s0_ar_data,
      s1_ready_o => s1_arready_o,
      s1_valid_i => s1_arvalid_i,
      s1_data_i  => s1_ar_data,
      m_ready_i  => m_arready_i,
      m_valid_o  => m_arvalid_o,
      m_data_o   => m_ar_data
    ); -- axi_arbiter_ar_inst : entity work.axi_arbiter

  s0_ar_data              <= x"00" & s0_araddr_i;
  s1_ar_data              <= x"01" & s1_araddr_i;
  (m_arid_o , m_araddr_o) <= m_ar_data;


  axi_arbiter_w_inst : entity work.axi_arbiter
    generic map (
      G_DATA_SIZE => G_DATA_SIZE + G_DATA_SIZE / 8
    )
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i,
      s0_ready_o => s0_wready_o,
      s0_valid_i => s0_wvalid_i,
      s0_data_i  => s0_w_data,
      s1_ready_o => s1_wready_o,
      s1_valid_i => s1_wvalid_i,
      s1_data_i  => s1_w_data,
      m_ready_i  => m_wready_i,
      m_valid_o  => m_wvalid_o,
      m_data_o   => m_w_data
    ); -- axi_arbiter_aw_inst : entity work.axi_arbiter

  s0_w_data              <= s0_wstrb_i & s0_wdata_i;
  s1_w_data              <= s1_wstrb_i & s1_wdata_i;
  (m_wstrb_o, m_wdata_o) <= m_w_data;


  axi_distributor_b_inst : entity work.axi_distributor
    generic map (
      G_DATA_SIZE => 1
    )
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i,
      s_ready_o  => m_bready_o,
      s_valid_i  => m_bvalid_i,
      s_data_i   => "0",
      s_dst_i    => m_bid_i(0),
      m0_ready_i => s0_bready_i,
      m0_valid_o => s0_bvalid_o,
      m0_data_o  => open,
      m1_ready_i => s1_bready_i,
      m1_valid_o => s1_bvalid_o,
      m1_data_o  => open
    ); -- axi_distributor_b_inst : entity work.axi_distributor

  axi_distributor_r_inst : entity work.axi_distributor
    generic map (
      G_DATA_SIZE => G_DATA_SIZE
    )
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i,
      s_ready_o  => m_rready_o,
      s_valid_i  => m_rvalid_i,
      s_data_i   => m_rdata_i,
      s_dst_i    => m_rid_i(0),
      m0_ready_i => s0_rready_i,
      m0_valid_o => s0_rvalid_o,
      m0_data_o  => s0_rdata_o,
      m1_ready_i => s1_rready_i,
      m1_valid_o => s1_rvalid_o,
      m1_data_o  => s1_rdata_o
    ); -- axi_distributor_b_inst : entity work.axi_distributor

end architecture synthesis;

