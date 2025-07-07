// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: Hack on FPGA
// Author: Heqing Huang
// Date Created: 06/11/2025
//
// -------------------------------------------------------------------
// RAM with 1RW port
// -------------------------------------------------------------------

module ram_1rw #(
    parameter DW = 16,      // data width
    parameter AW = 10       // address width
) (
    input logic             clk,
    input logic [AW-1:0]    addr,
    input logic             write,
    input logic [DW-1:0]    wdata,
    output logic [DW-1:0]   rdata
);

localparam DEPTH = 1 << AW;

logic [DW-1:0] ram[0:DEPTH-1];

always @(posedge clk) begin
    if (write) begin
        ram[addr] <= wdata;
    end
    rdata <= ram[addr];
end

// initialize RAM to 0 for FPGA
integer i;
initial begin
    for (i = 0; i < DEPTH; i=i+1)
        ram[i] = 0;
end

endmodule
