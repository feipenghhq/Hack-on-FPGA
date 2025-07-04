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
from Env import Env
from UartBFM import UartBFM
from UartHostBFM import UartHostBFM


class EnvUart(Env):

    def __init__(self, dut, period=40):
        super().__init__(dut)
        self.period = period            # clock period
        self.fill_addition = 10         # fill addition rom to be 0
        self.uart_bfm = UartBFM(115200)
        self.uart_bfm.set_uart_signal(dut.clk, dut.uart_txd, dut.uart_rxd)
        self.dut.uart_rxd.value = 1

    async def load_rom(self, file:str):
        """
        Load the Hack ROM to SRAM.
        """
        self.dut._log.info(f"Load hack file {file}")
        await UartHostBFM.rst_cmd(self.uart_bfm, rst=True)
        with open(file, 'r') as rom:
            addr = 0
            lines = rom.readlines()
            for line in lines:
                data = int(line.strip(), 2)
                await UartHostBFM.write_cmd(self.uart_bfm, addr, data, debug=True)
                addr = addr + 2
            for _ in range(self.fill_addition):
                await UartHostBFM.write_cmd(self.uart_bfm, addr, 0, debug=True)
                addr = addr + 2
        await UartHostBFM.rst_cmd(self.uart_bfm, rst=False)

    async def sram_model(self):
        sram = {}
        self.dut._log.info(f"[SRAM] Start SRAM model")
        while True:
            await FallingEdge(self.dut.clk)
            if (self.dut.sram_ce_n.value.integer == 0):
                if (self.dut.sram_we_n.value.integer == 0): # write
                    addr = self.dut.sram_addr.value.integer
                    data = self.dut.sram_dq.value.integer
                    sram[addr] = data
                    self.dut._log.info(f"[SRAM] Write to SRAM. Address {hex(addr)}. Data {hex(data)}")
                else:                                       # read
                    addr = self.dut.sram_addr.value.integer
                    try:
                        self.dut.sram_dq.value = sram[addr]
                    except KeyError:
                        self.dut.sram_dq.value = 0

    async def init(self, file:str):
        """
        Initialize the environment: setup clock, load the hack rom and reset the design
        """
        cocotb.start_soon(Clock(self.dut.clk, self.period, units = 'ns').start()) # clock
        cocotb.start_soon(self.sram_model())
        await self.generate_reset()
        await self.load_rom(file)
        self.fill_vram()
