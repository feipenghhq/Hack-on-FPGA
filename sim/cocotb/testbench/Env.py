# -------------------------------------------------------------------
# Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
# -------------------------------------------------------------------
#
# Project: Hack on FPGA
# Author: Heqing Huang
# Date Created: 06/13/2025
#
# -------------------------------------------------------------------
# Environment Class
# -------------------------------------------------------------------

import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb.clock import Clock

from vga import VGA

class Env():

    def __init__(self, dut):
        self.dut = dut
        try:
            self.rom = dut.u_instruction_rom.ram
        except AttributeError:
            pass
        self.ram = dut.u_data_ram.ram
        self.vram = dut.u_screen_ram.ram
        self.pc = dut.u_hack_cpu.pc
        self.commit = dut.u_hack_cpu.commit

        self.period = 10            # clock period
        self.fill_addition = 10     # fill addition rom to be 0

    def load_rom(self, file:str):
        """
        Load the Hack ROM
        """
        with open(file, 'r') as rom:
            lines = rom.readlines()
            for i in range(len(lines)):
                self.rom[i].value = int(lines[i].strip(), 2)
            for i in range(len(lines), len(lines) + self.fill_addition):
                self.rom[i].value = 0

    def set_ram(self, addr:int, value:int):
        """
        Set the Hack ram: RAM[addr] = value
        """
        self.ram[addr].value = value

    def compare_ram(self, golden:dict):
        """
        Compare Hack RAM with golden result

        Args:
            golden (dict): Hash table representing the expected memory data {addr:value}
        """
        for (addr, value) in golden.items():
            try:
                actual = self.ram[addr].value.integer
            except ValueError as e:
                self.dut._log.error(f"ValueError. Expecting {value} at address {addr}")
                raise e
            assert actual == value, f"Wrong memory content on address {addr}. Expecting {value} but get {actual}"


    async def generate_reset(self):
        """
        Generate reset pulses.
        """
        self.dut.rst_n.value = 0
        await Timer(5, units="ns")
        self.dut.rst_n.value = 1
        await RisingEdge(self.dut.clk)

    async def init(self, file:str):
        """
        Initialize the environment: setup clock, load the hack rom and reset the design
        """
        self.load_rom(file)
        cocotb.start_soon(Clock(self.dut.clk, self.period, units = 'ns').start()) # clock
        await self.generate_reset()
        self.fill_vram()

    async def run(self, file:str, golden:dict, cycle:int=0):
        """
        run the test flow and compare with the golden ram result
        """
        await self.init(file)
        if cycle:
            await Timer(cycle * self.period, units = 'ns')
        self.compare_ram(golden)

    def fill_vram(self):
        """
        Fill vram with 0
        """
        size = 1 << 8 # 2^8
        for i in range(size):
            self.vram[i].value = 0

    def print_vram(self):
        print(self.ram[0].value)
        print(self.ram[1].value)
        print(self.ram[2].value)

    async def run_screen(self, file:str):
        """
        run the test flow with screen
        """
        self.fill_vram()
        await self.init(file)
        vga = VGA()
        vga.set_vga_signal(self.dut.clk, self.dut.hsync, self.dut.vsync, self.dut.r, self.dut.g, self.dut.b)
        vga.start_display()
        cocotb.start_soon(vga.monitor_vga())
        while not vga.quit:
            await Timer(10000, units = 'ns')

    async def debug_mem_print(self, name:str, addr:int, pc_range:range):
        """Print RAM[addr] in given PC range

        Args:
            name (str): Variable associated with this RAM address
            addr (int): RAM address
            pc_range (range): PC Range
        """
        while True:
            await FallingEdge(self.dut.clk)
            if self.pc.value.integer in pc_range and self.commit.value.integer:
                print(f"PC = {self.pc.value.integer}: {name} (ram[{addr}]) = {self.ram[addr].value.integer}")
