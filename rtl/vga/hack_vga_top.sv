// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: Hack on FPGA
// Author: Heqing Huang
// Date Created: 06/21/2025
//
// -------------------------------------------------------------------
// Top level for the Hack VGA
// -------------------------------------------------------------------

`include "vga.svh"

module hack_vga_top #(
    parameter RGB_WIDTH = 10
)(
    input                           clk,
    input                           rst_n,

    output logic                    hsync,
    output logic                    vsync,
    output logic [RGB_WIDTH-1:0]    r,
    output logic [RGB_WIDTH-1:0]    g,
    output logic [RGB_WIDTH-1:0]    b,

    output logic [12:0]             ram_addr,
    input  logic [15:0]             ram_rdata
);


logic                vga_hsync;
logic                vga_vsync;
logic                display_on;

logic [`H_SIZE-1:0]  x_addr;
logic [`V_SIZE-1:0]  y_addr;


vga_sync #(
    .GEN_PIXEL_ADDR(0),
    .GEN_X_ADDR(1),
    .GEN_Y_ADDR(1)
)
u_vga_sync(
    .clk        (clk),
    .rst_n      (rst_n),
    .vga_hsync  (vga_hsync),
    .vga_vsync  (vga_vsync),
/* verilator lint_off PINCONNECTEMPTY */
    .display_on (display_on),
    .pixel_addr (),
/* verilator lint_on PINCONNECTEMPTY */
    .x_addr     (x_addr),
    .y_addr     (y_addr)
);

vga_screen_ctrl #(
    .RGB_WIDTH(RGB_WIDTH)
)
u_vga_screen_ctrl(
    .clk  (clk),
    .rst_n      (rst_n),
    .display_on (display_on),
    .vga_hsync  (vga_hsync),
    .vga_vsync  (vga_vsync),
    .x_addr     (x_addr),
    .y_addr     (y_addr),
    .hsync      (hsync),
    .vsync      (vsync),
    .r          (r),
    .g          (g),
    .b          (b),
    .ram_addr   (ram_addr),
    .ram_rdata  (ram_rdata)
);

endmodule
