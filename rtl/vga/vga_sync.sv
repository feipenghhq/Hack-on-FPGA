// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: VGA Controller
// Author: Heqing Huang
// Date Created: 06/20/2025
//
// -------------------------------------------------------------------
// vga sync: Generating the vga sync signal (hsync/vsync)
// -------------------------------------------------------------------

`include "vga.svh"

module vga_sync #(
    parameter GEN_PIXEL_ADDR = 1,   // generate pixel address
    parameter GEN_X_ADDR = 0,       // generate X coordinate
    parameter GEN_Y_ADDR = 0        // generate Y coordinate
)(
    input                       pixel_clk,  // pixel clock
    input                       reset,

    input                       vga_start,  // start the VGA controller

    output logic                vga_hsync,  // hsync output
    output logic                vga_vsync,  // vsync output
    output logic                video_on,   // display video

    output logic [`P_SIZE-1:0]  pixel_addr, // pixel address
    output logic [`H_SIZE-1:0]  x_addr,     // pixel x coordinate
    output logic [`V_SIZE-1:0]  y_addr      // pixel y coordinate
);

    // ------------------------------
    // signal Declaration
    // ------------------------------

    logic [`H_SIZE-1:0]   h_cnt;        // vertical counter
    logic [`V_SIZE-1:0]   v_cnt;        // horizontal counter

    logic                 h_cnt_sat;    // vertical counter saturate
    logic                 v_cnt_sat;    // horizontal counter saturate
    logic                 h_video_on;   // display region
    logic                 v_video_on;   // display region


    // --------------------------------
    // Logic
    // --------------------------------

    // horizontal and vertical counter saturate
    assign h_cnt_sat = (h_cnt == `H_COUNT-1) ? 1'b1 : 1'b0;
    assign v_cnt_sat = (v_cnt == `V_COUNT-1) ? 1'b1 : 1'b0;

    always @(posedge pixel_clk) begin
        if (reset || ~vga_start) begin
            h_cnt <= '0;
            v_cnt <= '0;
            vga_hsync <= '0;
            vga_vsync <= '0;
        end
        else begin
            if (h_cnt_sat) h_cnt <= 'b0;
            else h_cnt <= h_cnt + 1'b1;

            if (h_cnt_sat) begin
                if (v_cnt_sat) v_cnt <= 'b0;
                else v_cnt <= v_cnt + 1'b1;
            end

            // generate hsync/vsync
            vga_hsync <= (h_cnt <= `H_DISPLAY+`H_FRONT_PORCH-1) || (h_cnt >= `H_DISPLAY+`H_FRONT_PORCH+`H_SYNC_PULSE);
            vga_vsync <= (v_cnt <= `V_DISPLAY+`V_FRONT_PORCH-1) || (v_cnt >= `V_DISPLAY+`V_FRONT_PORCH+`V_SYNC_PULSE);
        end
    end

    // display region
    always @(posedge pixel_clk) begin
        if (reset || ~vga_start) begin
            h_video_on <= 0;
            v_video_on <= 0;
        end
        else begin
            h_video_on <= h_cnt <= `H_DISPLAY-1;
            v_video_on <= v_cnt <= `V_DISPLAY-1;
        end
    end
    assign video_on = h_video_on | v_video_on;

    generate

    // generate pixel addr
    if (GEN_PIXEL_ADDR) begin: gen_pixel_addr
        always @(posedge pixel_clk) begin
            if (reset || ~vga_start) begin
                pixel_addr <= 0;
            end
            else begin
                if (h_video_on) begin
                    if (pixel_addr == (`PIXELS-1))  pixel_addr <= 0;
                    else pixel_addr <= pixel_addr + 1;
                end
            end
        end
    end
    else begin: no_pixel_addr
        assign pixel_addr = 0;
    end

    // generate x coordinate
    if (GEN_X_ADDR) begin: gen_x_addr
        always @(posedge pixel_clk) begin
            if (reset || ~vga_start) begin
                x_addr <= 0;
            end
            else begin
                if (h_video_on) begin
                    if (x_addr == (`H_DISPLAY-1))  x_addr <= 0;
                    else x_addr <= x_addr + 1;
                end
            end
        end
    end
    else begin: no_x_addr
        assign x_addr = 0;
    end

    // generate y coordinate
    if (GEN_Y_ADDR) begin: gen_y_addr
        always @(posedge pixel_clk) begin
            if (reset || ~vga_start) begin
                y_addr <= 0;
            end
            else begin
                if (v_video_on && h_cnt_sat) begin
                    if (y_addr == (`V_DISPLAY-1)) y_addr <= 0;
                    else y_addr <= y_addr + 1;
                end
            end
        end
    end
    else begin: no_y_addr
        assign y_addr = 0;
    end

    endgenerate

endmodule
