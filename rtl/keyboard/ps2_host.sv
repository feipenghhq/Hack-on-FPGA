// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: PS2 Controller
// Author: Heqing Huang
// Date Created: 07/09/2025
//
// -------------------------------------------------------------------
// PS2 Host module.
// Receives PS2 transactions from the device
// -------------------------------------------------------------------


module ps2_host (
    input logic         clk,
    input logic         rst_n,

    // PS2 interface
    input logic         ps2_clk,
    input logic         ps2_data,

    output logic        valid,
    output logic [7:0]  scan_code,
    output logic        parity_err,
    output logic        frame_err
);

///////////////////////////////////////
// Signal Declaration
///////////////////////////////////////

// state machine
localparam  IDLE   = 0,     // IDLE state, wait for start condition
            PARITY = 9,     // Parity state, receive parity
            STOP   = 10;    // Stop state, receive stop
                            // 1 ~ 8: Data state, receive data


logic [3:0] state;      // state counter
logic       parity;

logic       ps2_clk_sync;
logic       ps2_data_sync;

logic       ps2_clk_sync_q;
logic       ps2_clk_fall;

///////////////////////////////////////
// Main logic
///////////////////////////////////////

// synchronize and debounce the ps2_clk and ps2_data
ps2_debounce u_ps2_clk_debounce
(
    .clk    (clk),
    .rst_n  (rst_n),
    .in     (ps2_clk),
    .out    (ps2_clk_sync)
);

ps2_debounce u_ps2_data_debounce
(
    .clk    (clk),
    .rst_n  (rst_n),
    .in     (ps2_data),
    .out    (ps2_data_sync)
);

// detect falling edge of the ps2_clk
always @(posedge clk) begin
    if (!rst_n) ps2_clk_sync_q <= 1'b1;
    else        ps2_clk_sync_q <= ps2_clk_sync;
end

assign ps2_clk_fall = ~ps2_clk_sync & ps2_clk_sync_q;

// ps2 main control state and logic
always @(posedge clk) begin
    if (!rst_n) begin
        state <= IDLE;
        valid <= 1'b0;
    end
    else begin

        valid <= 1'b0;
        parity_err <= 1'b0;
        frame_err <= 1'b0;

        // data is sampled at ps2_clk falling edge
        if (ps2_clk_fall) begin
            case (state)
                IDLE: begin
                    scan_code <= 0;
                    if (!ps2_data_sync) state <= state + 1; // start condition
                end
                PARITY: begin
                    state <= state + 1;
                    parity <= ps2_data_sync;
                end
                STOP: begin
                    // go back to IDLE state
                    state <= 0;
                    // output result
                    parity_err <= ~((^scan_code) ^ parity);
                    valid <= 1'b1;
                    frame_err <= ~ps2_data_sync; // not getting a stop condition
                end
                // default will be data state
                default: begin
                    state <= state + 1;
                    scan_code <= {ps2_data_sync, scan_code[7:1]}; // LSb is received first
                end
            endcase
        end
    end
end

endmodule
