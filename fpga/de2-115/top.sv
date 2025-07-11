// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: VGA Controller
// Author: Heqing Huang
// Date Created: 07/07/2025
//
// -------------------------------------------------------------------
// Top level for the DE2-115 FPGA board
// -------------------------------------------------------------------

module top
(
    input         CLOCK_50,     // 50 MHz
    input         KEY,          // Pushbutton[3:0]

    // UART
    input         UART_RXD,
    output        UART_TXD,

    // PS/2
    input         PS2_CLK,
    input         PS2_DAT,

    // VGA
    output        VGA_CLK,      // VGA Clock
    output        VGA_HS,       // VGA H_SYNC
    output        VGA_VS,       // VGA V_SYNC
    output        VGA_BLANK_N,  // VGA BLANK
    output        VGA_SYNC_N,   // VGA SYNC
    output [7:0]  VGA_R,        // VGA Red[7:0]
    output [7:0]  VGA_G,        // VGA Green[7:0]
    output [7:0]  VGA_B        // VGA Blue[7:0]
);

assign VGA_BLANK_N = 1'b1;
assign VGA_SYNC_N  = 1'b0;

pll
u_pll (
    .inclk0 (CLOCK_50),
	.c0     (VGA_CLK)
);

hack_top
    #(.RGB_WIDTH(8))
u_hack_top
(
    .clk        (VGA_CLK),
    .rst_n      (KEY),
    .r          (VGA_R),
    .g          (VGA_G),
    .b          (VGA_B),
    .hsync      (VGA_HS),
    .vsync      (VGA_VS),
    .ps2_clk    (PS2_CLK),
    .ps2_data   (PS2_DAT),
    .uart_txd   (UART_TXD),
    .uart_rxd   (UART_RXD)
);

endmodule
