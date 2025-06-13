// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: Hack on FPGA
// Author: Heqing Huang
// Date Created: 06/11/2025
//
// -------------------------------------------------------------------
// Hack ALU Implementation
// -------------------------------------------------------------------
//
//  ALU (Arithmetic Logic Unit):
//  Computes out = one of the following functions:
//                 0, 1, -1,
//                 x, y, !x, !y, -x, -y,
//                 x + 1, y + 1, x - 1, y - 1,
//                 x + y, x - y, y - x,
//                 x & y, x | y
//  on the 16-bit inputs x, y, according to the input bits zx, nx, zy, ny, f, no.
//  In addition, computes the two output bits:
//  if (out == 0) zr = 1, else zr = 0
//  if (out < 0)  ng = 1, else ng = 0
//
// Implementation: Manipulates the x and y inputs
// and operates on the resulting values, as follows:
// if (zx == 1) sets x = 0        // 16-bit constant
// if (nx == 1) sets x = !x       // bitwise not
// if (zy == 1) sets y = 0        // 16-bit constant
// if (ny == 1) sets y = !y       // bitwise not
// if (f == 1)  sets out = x + y  // integer 2's complement addition
// if (f == 0)  sets out = x & y  // bitwise and
// if (no == 1) sets out = !out   // bitwise not
// -------------------------------------------------------------------

module hack_alu #(
    parameter WIDTH = 16
) (
    input logic [WIDTH-1:0]     x,
    input logic [WIDTH-1:0]     y,
    input logic [5:0]           control,   // alu control

    output logic [WIDTH-1:0]    out,    // 16-bit output
    output logic                zr,     // if (out == 0) equals 1, else 0
    output logic                ng      // if (out < 0)  equals 1, else 0
);

logic zx;     // zero the x input?
logic nx;     // negate the x input?
logic zy;     // zero the y input?
logic ny;     // negate the y input?
logic f;      // compute (out = x + y) or (out = x & y)?
logic no;     // negate the out output?

logic [WIDTH-1:0] x1, y1;       // after xz and zy operation
logic [WIDTH-1:0] x2, y2;       // after nx and ny operation
logic [WIDTH-1:0] fout;         // after f operation

assign zx = control[5];
assign nx = control[4];
assign zy = control[3];
assign ny = control[2];
assign f  = control[1];
assign no = control[0];

assign x1 = zx ?   0 : x;       // if (zx == 1) sets x = 0
assign x2 = nx ? ~x1 : x1;      // if (nx == 1) sets x = !x

assign y1 = zy ?   0 : y;       // if (zy == 1) sets y = 0
assign y2 = ny ? ~y1 : y1;      // if (ny == 1) sets y = !y

assign fout = f ? x2 + y2 : x2 & y2;    // if (f == 1)  sets out = x + y
                                        // if (f == 0)  sets out = x & y

assign out = no ? ~fout : fout;         // if (no == 1) sets out = !out

assign zr = (out == 0);

assign ng = out[WIDTH-1];

endmodule
