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
    input                           pixel_clk,
    input                           reset,

    output logic                    hsync,
    output logic                    vsync,
    output logic [RGB_WIDTH-1:0]    r,
    output logic [RGB_WIDTH-1:0]    g,
    output logic [RGB_WIDTH-1:0]    b,

    output logic [15:0]             ram_addr,
    input  logic [15:0]             ram_rdata
);


logic                vga_hsync;
logic                vga_vsync;

logic [`H_SIZE-1:0]  x_addr;
logic [`V_SIZE-1:0]  y_addr;

`include "vga.svh"

vga_sync #(
    .GEN_PIXEL_ADDR(0),
    .GEN_X_ADDR(1),
    .GEN_Y_ADDR(1)
)
u_vga_sync(
    .pixel_clk  (pixel_clk),
    .reset      (reset),
    .vga_start  (1'b1),
    .vga_hsync  (vga_hsync),
    .vga_vsync  (vga_vsync),
/* verilator lint_off PINCONNECTEMPTY */
    .video_on   (),
    .pixel_addr (),
/* verilator lint_on PINCONNECTEMPTY */
    .x_addr     (x_addr),
    .y_addr     (y_addr)
);

vga_screen_ctrl #(
    .RGB_WIDTH(RGB_WIDTH)
)
u_vga_screen_ctrl(
    .pixel_clk  (pixel_clk),
    .reset      (reset),
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
