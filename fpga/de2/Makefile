
GIT_ROOT 	= $(shell git rev-parse --show-toplevel)
SCRIPT_DIR 	= $(GIT_ROOT)/scripts/quartus

# device part
PART = EP2C35F672C7
# device family
FAMILY = Cyclone II
# project name
PROJECT = hack
# top level name
TOP = top
# verilog source files
VERILOG += $(GIT_ROOT)/rtl/vga/vga_sync.sv
VERILOG += $(GIT_ROOT)/rtl/vga/vga_screen_ctrl.sv
VERILOG += $(GIT_ROOT)/rtl/vga/hack_vga_top.sv
VERILOG += $(GIT_ROOT)/rtl/cpu/hack_alu.sv
VERILOG += $(GIT_ROOT)/rtl/cpu/hack_cpu.sv
VERILOG += $(GIT_ROOT)/rtl/memory/ram_1rw.sv
VERILOG += $(GIT_ROOT)/rtl/memory/ram_2rw.sv
VERILOG += $(GIT_ROOT)/rtl/memory/sram_ctrl.sv
VERILOG += $(GIT_ROOT)/rtl/uart/uart_baud.sv
VERILOG += $(GIT_ROOT)/rtl/uart/uart_tx.sv
VERILOG += $(GIT_ROOT)/rtl/uart/uart_rx.sv
VERILOG += $(GIT_ROOT)/rtl/uart/uart_core.sv
VERILOG += $(GIT_ROOT)/rtl/uart/uart_host.sv
VERILOG += $(GIT_ROOT)/rtl/keyboard/ps2_debounce.sv
VERILOG += $(GIT_ROOT)/rtl/keyboard/ps2_host.sv
VERILOG += $(GIT_ROOT)/rtl/keyboard/ps2_scancode2hack.sv
VERILOG += $(GIT_ROOT)/rtl/keyboard/keyboard.sv
VERILOG += $(GIT_ROOT)/rtl/top/hack_top.sv
VERILOG += $(GIT_ROOT)/fpga/de2/pll.v
VERILOG += $(GIT_ROOT)/fpga/de2/top.sv
# verilog include directory
SEARCH  += $(GIT_ROOT)/rtl/vga
# verilog define
DEFINE = DE2
# sdc files
SDC	= $(PWD)/timing.sdc
# pin assignment files
PIN = $(PWD)/pin.tcl
# project output directory
OUT_DIR ?= outputs

include $(GIT_ROOT)/scripts/quartus/makefile.mk