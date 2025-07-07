// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: VGA Controller
// Author: Heqing Huang
// Date Created: 06/20/2025
//
// -------------------------------------------------------------------
// Top level for the DE2 FPGA board
// -------------------------------------------------------------------

module top
(
    input         CLOCK_100,    // 100 MHz

    input         RESETn,

    input         UART_RXD,
    output        UART_TXD,

    // VGA
    output        VGA_HS,       // VGA H_SYNC
    output        VGA_VS,       // VGA V_SYNC
    output [3:0]  VGA_R,        // VGA Red[9:0]
    output [3:0]  VGA_G,        // VGA Green[9:0]
    output [3:0]  VGA_B         // VGA Blue[9:0]
);

logic VGA_CLK;

pll
u_pll (
    .clk_in1(CLOCK_100),
    .clk_out1(VGA_CLK)
);

hack_top
    #(.RGB_WIDTH(4))
u_hack_top
(
    .clk        (VGA_CLK),
    .rst_n      (RESETn),     // default is high
    .r          (VGA_R),
    .g          (VGA_G),
    .b          (VGA_B),
    .hsync      (VGA_HS),
    .vsync      (VGA_VS),
    .uart_txd   (UART_TXD),
    .uart_rxd   (UART_RXD)
);

endmodule
