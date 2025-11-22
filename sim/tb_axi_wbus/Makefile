# Author:  Michael Jørgensen
#
# Description: Makefile for simulating the axi_wbus.vhd file.

# List of source files
SRC += $(SRC_DIR)/axi_lite_arbiter.vhd
SRC += $(SRC_DIR)/axi_arbiter.vhd
SRC += $(SRC_DIR)/axi_distributor.vhd
SRC += $(SRC_DIR)/axi_wbus.vhd
SRC += $(SRC_DIR)/wbus_axi.vhd

# List of test specific simulation files
SRC += tb_axi_wbus.vhd

# List of generic simulation files
SRC += $(SIM_SRC_DIR)/axi_lite_pause.vhd
SRC += $(SIM_SRC_DIR)/axi_pause.vhd
SRC += $(SIM_SRC_DIR)/lfsr.vhd
SRC += $(SIM_SRC_DIR)/random.vhd
SRC += $(SIM_SRC_DIR)/wbus_master_sim.vhd
SRC += $(SIM_SRC_DIR)/wbus_slave_sim.vhd

# Top level entity
DUT = axi_wbus

# Test duration
STOP_TIME = 2000us

# Test bench configuration
GENERIC += -gG_PAUSE_SIZE=3
GENERIC += -gG_ADDR_SIZE=8
GENERIC += -gG_DATA_SIZE=16

# Don't stop on errors
ASSERT_LEVEL = none

include ../Makefile.inc

