# Makefile

REPO = $(shell git rev-parse --show-toplevel)

# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
#WAVES = 1

VERILOG_SOURCES += $(shell find $(REPO)/rtl -name "*.sv")
VERILOG_INCLUDE_DIRS += $(shell dirname $(shell find $(REPO)/rtl -name "*.svh"))

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = hack_top

# MODULE is the basename of the Python test file
MODULE = screen_test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim