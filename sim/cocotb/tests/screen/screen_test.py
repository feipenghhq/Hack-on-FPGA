# -------------------------------------------------------------------
# Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
# -------------------------------------------------------------------
#
# Project: Hack on FPGA
# Author: Heqing Huang
# Date Created: 06/22/2025
#
# -------------------------------------------------------------------
# Screen Test for hack_top
# -------------------------------------------------------------------

import cocotb
import sys
sys.path.append('../../testbench/')

from Env import Env

@cocotb.test()
async def screen_test(dut):
    """
    Draw a pixel in the screen
    """
    env = Env(dut)
    await env.run_screen('ScreenTest.hack')


