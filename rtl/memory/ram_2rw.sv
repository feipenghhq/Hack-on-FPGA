// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: Hack on FPGA
// Author: Heqing Huang
// Date Created: 06/11/2025
//
// -------------------------------------------------------------------
// RAM with 2RW port
// -------------------------------------------------------------------

module ram_2rw #(
    parameter DW = 16,      // data width
    parameter AW = 10       // address width
) (
    input logic             clk,
    // port 1
    input logic [AW-1:0]    addr_a,
    input logic             write_a,
    input logic [DW-1:0]    wdata_a,
    output logic [DW-1:0]   rdata_a,
    // port 2
    input logic [AW-1:0]    addr_b,
    input logic             write_b,
    input logic [DW-1:0]    wdata_b,
    output logic [DW-1:0]   rdata_b
);

localparam DEPTH = 1 << AW;

logic [DW-1:0] ram[0:DEPTH-1];

// port A
always @(posedge clk) begin
    if (write_a) begin
        ram[addr_a] <= wdata_a;
    end
    rdata_a <= ram[addr_a];
end

// port B
always @(posedge clk) begin
    if (write_b) begin
        ram[addr_b] <= wdata_b;
    end
    rdata_b <= ram[addr_b];
end

endmodule
