# Author:  Michael Jørgensen
#
# Description: Makefile for simulating the wbus_axi.vhd file.

# List of source files
SRC += $(SRC_DIR)/axi_wbus.vhd
SRC += $(SRC_DIR)/wbus_axi.vhd

# List of test specific simulation files
SRC += tb_wbus_axi.vhd

# List of generic simulation files
SRC += $(SIM_SRC_DIR)/lfsr.vhd
SRC += $(SIM_SRC_DIR)/random.vhd
SRC += $(SIM_SRC_DIR)/axi_pause.vhd
SRC += $(SIM_SRC_DIR)/axi_lite_pause.vhd
SRC += $(SIM_SRC_DIR)/wbus_master_sim.vhd
SRC += $(SIM_SRC_DIR)/wbus_slave_sim.vhd

# Top level entity
DUT = wbus_axi

# Test bench configuration
GENERIC += -gG_PAUSE_SIZE=3
GENERIC += -gG_ADDR_SIZE=12
GENERIC += -gG_DATA_SIZE=16

# Test duration
STOP_TIME = 1000us

include ../Makefile.inc

