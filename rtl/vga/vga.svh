// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: VGA Controller
// Author: Heqing Huang
// Date Created: 06/20/2025
//
// -------------------------------------------------------------------

`ifndef __VGA__
`define __VGA__

`include "vga_timing.svh"

// Horizontal and vertical counter size
`define H_SIZE  ($clog2(`H_COUNT))
`define V_SIZE  ($clog2(`V_COUNT))

`define PIXELS  (`H_DISPLAY * `V_DISPLAY)
`define P_SIZE  ($clog2(`PIXELS))

`endif
