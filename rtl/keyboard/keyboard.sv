// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: Hack on FPGA
// Author: Heqing Huang
// Date Created: 07/10/2025
//
// -------------------------------------------------------------------
// Hack Keyboard
// -------------------------------------------------------------------

module keyboard (
    input  logic            clk,
    input  logic            rst_n,
    input  logic            ps2_clk,
    input  logic            ps2_data,
    output logic [15:0]     value
);

logic [7:0] scan_code;
logic       valid;
logic       pressed;
logic [7:0] hack;
logic       hack_valid;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        value <= 0;
    end
    else begin
        if      (hack_valid && pressed)  value <= {8'b0, hack};
        else if (hack_valid && !pressed) value <= 0;
    end
end

ps2_host
u_ps2_host(
    .clk        (clk),
    .rst_n      (rst_n),
    .ps2_clk    (ps2_clk),
    .ps2_data   (ps2_data),
    .valid      (valid),
    .scan_code  (scan_code)
);

ps2_scancode2hack
u_ps2_scancode2hack (
    .clk            (clk),
    .rst_n          (rst_n),
    .scan_code      (scan_code),
    .valid          (valid),
    .pressed        (pressed),
    .hack           (hack),
    .hack_valid     (hack_valid)
);

endmodule
