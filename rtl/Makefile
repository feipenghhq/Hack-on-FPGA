# Makefile for compiling RTL

REPO := $(shell git rev-parse --show-toplevel)

# SystemVerilog Source File
SV_SRC = $(shell find $$PWD -name "*.sv")
SV_SRC += $(shell find $$PWD -name "*.v")

# iverilog option
IVERILOG_FLAG = -g2005-sv

# Compile the RTL using iverilog
compile: $(SV_SRC)
	@iverilog $(IVERILOG_FLAG) $(SV_SRC)

# Lint the RTL using verilator
lint: $(SV_SRC)
	@verilator --lint-only -Wall $(SV_SRC)

# Clean
clean:
	@rm a.out