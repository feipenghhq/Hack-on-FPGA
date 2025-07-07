
GIT_ROOT 	= $(shell git rev-parse --show-toplevel)
SCRIPT_DIR 	= $(GIT_ROOT)/scripts/vivado

# FPGA Device
DEVICE ?= xc7a35ticsg324-1L
# project name
PROJECT ?= hack
# top level name
TOP ?= top

# verilog source files
VERILOG += $(GIT_ROOT)/rtl/vga/vga_sync.sv
VERILOG += $(GIT_ROOT)/rtl/vga/vga_screen_ctrl.sv
VERILOG += $(GIT_ROOT)/rtl/vga/hack_vga_top.sv
VERILOG += $(GIT_ROOT)/rtl/uart/uart_baud.sv
VERILOG += $(GIT_ROOT)/rtl/uart/uart_rx.sv
VERILOG += $(GIT_ROOT)/rtl/uart/uart_tx.sv
VERILOG += $(GIT_ROOT)/rtl/uart/uart_core.sv
VERILOG += $(GIT_ROOT)/rtl/uart/uart_host.sv
VERILOG += $(GIT_ROOT)/rtl/cpu/hack_alu.sv
VERILOG += $(GIT_ROOT)/rtl/cpu/hack_cpu.sv
VERILOG += $(GIT_ROOT)/rtl/memory/ram_1rw.sv
VERILOG += $(GIT_ROOT)/rtl/memory/ram_2rw.sv
VERILOG += $(GIT_ROOT)/rtl/top/hack_top.sv
VERILOG += $(GIT_ROOT)/fpga/arty/pll_clk_wiz.v
VERILOG += $(GIT_ROOT)/fpga/arty/pll.v
VERILOG += $(GIT_ROOT)/fpga/arty/top.sv
# verilog include directory
SEARCH  += $(GIT_ROOT)/rtl/vga

# verilog define
DEFINE ?=
# sdc files
XDC += $(PWD)/timing.xdc
# pin assignment files
XDC += $(PWD)/pin.xdc
# project output directory
OUT_DIR ?= outputs

include $(GIT_ROOT)/scripts/vivado/makefile.mk