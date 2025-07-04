# -------------------------------------------------------------------
# Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
# -------------------------------------------------------------------
#
# Project: Hack on FPGA
# Author: Heqing Huang
# Date Created: 06/13/2025
#
# -------------------------------------------------------------------
# Basic Test for hack_top
# -------------------------------------------------------------------

import cocotb
import sys
sys.path.append('../../testbench/')

from EnvUart import EnvUart

@cocotb.test()
async def add_test(dut):
    """
    2 + 3. RAM[0] = 5
    """
    golden = {0: 5} # RAM[0] = 5
    env = EnvUart(dut)
    await env.run('hack/Add.hack', golden, cycle=14)

@cocotb.test()
async def max_test(dut):
    """
    RAM[2] = MAX(RAM[0], RAM[1])
    """
    env = EnvUart(dut)
    env.set_ram(0, 10)     # RAM[0] = 10
    env.set_ram(1, 23)     # RAM[1] = 23
    golden = {2: 23}       # RAM[2] = 23
    await env.run('hack/Max.hack', golden, cycle=34)
