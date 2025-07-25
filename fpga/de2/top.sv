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
    input         CLOCK_50,    // 50 MHz
    input         KEY,          // Pushbutton[3:0]

    // VGA
    output        VGA_CLK,     // VGA Clock
    output        VGA_HS,      // VGA H_SYNC
    output        VGA_VS,      // VGA V_SYNC
    output        VGA_BLANK,   // VGA BLANK
    output        VGA_SYNC,    // VGA SYNC
    output [9:0]  VGA_R,       // VGA Red[9:0]
    output [9:0]  VGA_G,       // VGA Green[9:0]
    output [9:0]  VGA_B,       // VGA Blue[9:0]

    // UART
    input         UART_RXD,
    output        UART_TXD,

    // PS/2
    input         PS2_CLK,
    input         PS2_DAT,

    // SRAM Interface
    inout  [15:0] SRAM_DQ,     // SRAM Data bus 16 Bits
    output [17:0] SRAM_ADDR,   // SRAM Address bus 18 Bits
    output        SRAM_UB_N,   // SRAM High-byte Data Mask
    output        SRAM_LB_N,   // SRAM Low-byte Data Mask
    output        SRAM_WE_N,   // SRAM Write Enable
    output        SRAM_CE_N,   // SRAM Chip Enable
    output        SRAM_OE_N    // SRAM Output Enable
);

assign VGA_BLANK = 1'b1;
assign VGA_SYNC  = 1'b0;

pll
u_pll (
    .inclk0 (CLOCK_50),
	.c0     (VGA_CLK)
);

hack_top
    #(.RGB_WIDTH(10))
u_hack_top
(
    .clk        (VGA_CLK),
    .rst_n      (KEY),
    .r          (VGA_R),
    .g          (VGA_G),
    .b          (VGA_B),
    .hsync      (VGA_HS),
    .vsync      (VGA_VS),
    .sram_dq    (SRAM_DQ  ),
    .sram_addr  (SRAM_ADDR),
    .sram_ub_n  (SRAM_UB_N),
    .sram_lb_n  (SRAM_LB_N),
    .sram_we_n  (SRAM_WE_N),
    .sram_ce_n  (SRAM_CE_N),
    .sram_oe_n  (SRAM_OE_N),
    .ps2_clk    (PS2_CLK),
    .ps2_data   (PS2_DAT),
    .uart_txd   (UART_TXD),
    .uart_rxd   (UART_RXD)
);

endmodule
