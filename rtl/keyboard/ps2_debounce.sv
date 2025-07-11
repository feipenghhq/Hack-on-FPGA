// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: PS2 Controller
// Author: Heqing Huang
// Date Created: 07/09/2025
//
// -------------------------------------------------------------------
// PS2 debounce module.
// 1. Synchronize the input
// 2. Debounce and glitch filter for the ps2 signal
// -------------------------------------------------------------------

module ps2_debounce #(
    parameter DEPTH = 8
) (
    input  logic clk,
    input  logic rst_n,
    input  logic in,
    output logic out
);

logic [DEPTH-1:0] sample;
logic [1:0]       in_dsync;
logic             in_sync;

always @(posedge clk) begin
    if (!rst_n) begin
        in_dsync <= 2'b11;
    end
    else begin
        in_dsync <= {in_dsync[0], in};
    end
end

assign in_sync = in_dsync[1];

always @(posedge clk) begin
    if (!rst_n) begin
        sample <= {DEPTH{1'b1}};    // ps2 signal park at hight level
        out <= 1'b1;
    end
    else begin
        sample <= {sample[DEPTH-2:0], in_sync};
        if (&sample) out <= 1'b1;               // change out to 1 if all samples are 1
        else if (!(|sample)) out <= 1'b0;       // change out to 0 if all samples are 0
                                                // otherwise, keep the current out value
    end
end

endmodule
