# Makefile for compiling RTL

REPO := $(shell git rev-parse --show-toplevel)

# SystemVerilog Source File
VERILOG_SOURCES = $(shell find $$PWD -name "*.sv")
VERILOG_SOURCES += $(shell find $$PWD -name "*.v")
VERILOG_INCLUDE_DIRS += $(shell dirname $(shell find $(REPO)/rtl -name "*.svh"))

# iverilog option
IVERILOG_FLAG = -g2005-sv
IVERILOG_INCLUDE_DIR := $(addprefix -I, $(VERILOG_INCLUDE_DIRS))

# Compile the RTL using iverilog
compile: $(VERILOG_SOURCES)
	@iverilog $(IVERILOG_FLAG) $(VERILOG_SOURCES) $(IVERILOG_INCLUDE_DIR)

# Lint the RTL using verilator
lint: $(VERILOG_SOURCES)
	@verilator --lint-only -Wall $(VERILOG_SOURCES) $(IVERILOG_INCLUDE_DIR)

# Clean
clean:
	@rm a.out

