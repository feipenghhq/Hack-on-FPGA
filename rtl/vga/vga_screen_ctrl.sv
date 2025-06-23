// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: Hack on FPGA
// Author: Heqing Huang
// Date Created: 06/21/2025
//
// -------------------------------------------------------------------
// Access screen RAM to get the pixel data. Screen RAM read latency is ONE
//
// Implementation Note:
// The Hack Screen is 512 x 256 while the VGA screen is 640x480.
// The Hack Screen only support black and white color
// -------------------------------------------------------------------

`include "vga.svh"

module vga_screen_ctrl #(
    parameter RGB_WIDTH = 10
) (
    input logic                     pixel_clk,
    input logic                     reset,
    input logic                     vga_hsync,
    input logic                     vga_vsync,

    input logic [`H_SIZE-1:0]       x_addr,     // pixel x coordinate
    input logic [`V_SIZE-1:0]       y_addr,     // pixel y coordinate

    output logic                    hsync,
    output logic                    vsync,
    output logic [RGB_WIDTH-1:0]    r,
    output logic [RGB_WIDTH-1:0]    g,
    output logic [RGB_WIDTH-1:0]    b,

    output logic [15:0]             ram_addr,
    input  logic [15:0]             ram_rdata
);

/////////////////////////////////////////////////
// Signal Declaration
/////////////////////////////////////////////////

logic           in_hack_screen;
logic           in_hack_screen_s1;
logic [15:0]    pixel_addr;         // pixel address for the Hack Screen
logic [3:0]     bit_select;         // select one of the 16 bit from RAM word
logic           color;


/////////////////////////////////////////////////
// Main logic
/////////////////////////////////////////////////

// Delay vga_hsync to match with the read latency
always @(posedge pixel_clk) begin
    if (reset) begin
        hsync <= 1'b0;
        vsync <= 1'b0;
        in_hack_screen_s1 <= 1'b0;
        bit_select <= 0;
    end
    else begin
        hsync <= vga_hsync;
        vsync <= vga_vsync;
        in_hack_screen_s1 <= in_hack_screen;
        bit_select <= pixel_addr[3:0];
    end
end

assign in_hack_screen = (x_addr < 512 && y_addr < 256) ? 1'b1 : 1'b0;

// each 16-bit RAM word stores 16 pixel data
/* verilator lint_off WIDTHEXPAND */
assign pixel_addr = (x_addr + (y_addr << 9));
/* verilator lint_on WIDTHEXPAND */
assign ram_addr = in_hack_screen ? (pixel_addr >> 4) : 16'h0;

// assign RGB color based on the screen ram data.
// each 16-bit RAM word stores 16 pixel data and bit_select indicate the desired bit in the word
// if x, y coordinate is outside of the Hack screen, show black on the screen
assign color = ram_rdata[bit_select];   // 0 - white, 1 - black
assign r = (~in_hack_screen_s1 | color) ? {{RGB_WIDTH{1'b0}}} : {{RGB_WIDTH{1'b1}}};
assign g = (~in_hack_screen_s1 | color) ? {{RGB_WIDTH{1'b0}}} : {{RGB_WIDTH{1'b1}}};
assign b = (~in_hack_screen_s1 | color) ? {{RGB_WIDTH{1'b0}}} : {{RGB_WIDTH{1'b1}}};

endmodule
