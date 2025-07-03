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
    output logic [`H_SIZE-1:0]  y_addr      // pixel y coordinate
);

    // ------------------------------
    // signal Declaration
    // ------------------------------

    logic [`H_SIZE-1:0]   h_count;
    logic [`H_SIZE-1:0]   h_count_next;
    logic [`V_SIZE-1:0]   v_count;
    logic [`V_SIZE-1:0]   v_count_next;

    logic                 h_count_sat;
    logic                 v_count_sat;
    logic                 h_video_on;
    logic                 v_video_on;

    logic                 h_display;
    logic                 v_display;

    // --------------------------------
    // Logic
    // --------------------------------

    // horizontal and vertical counter saturate
    assign h_count_sat = (h_count == `H_COUNT-1) ? 1'b1 : 1'b0;
    assign v_count_sat = (v_count == `V_COUNT-1) ? 1'b1 : 1'b0;

    always @(*) begin
        h_count_next = h_count;
        if (h_count_sat) h_count_next = 'b0;
        else h_count_next = h_count + 1'b1;

        // vertical counter only update when one line complete
        v_count_next = v_count;
        if (h_count_sat) begin
            if (v_count_sat) v_count_next = 'b0;
            else v_count_next = v_count_next + 1'b1;
        end

    end

    assign h_display = (h_count_next <= `H_DISPLAY-1);
    assign v_display = (v_count_next <= `V_DISPLAY-1);

    always @(posedge pixel_clk) begin
        if (reset || ~vga_start) begin
            h_count <= '0;
            v_count <= '0;
            vga_hsync <= '0;
            vga_vsync <= '0;
            h_video_on <= 0;
            v_video_on <= 0;
        end
        else begin
            h_count <= h_count_next;
            v_count <= v_count_next;

            vga_hsync <= (h_count_next < `H_DISPLAY+`H_FRONT_PORCH) |
                         (h_count_next >= `H_DISPLAY+`H_FRONT_PORCH+`H_SYNC_PULSE);

            vga_vsync <= (v_count_next < `V_DISPLAY+`V_FRONT_PORCH) |
                         (v_count_next >= `V_DISPLAY+`V_FRONT_PORCH+`V_SYNC_PULSE);

            h_video_on <= h_display;
            v_video_on <= v_display;
        end
    end

    assign video_on = h_video_on | v_video_on;

    generate

    // generate pixel addr
    if (GEN_PIXEL_ADDR) begin: gen_pixel_addr
        // use a dedicated counter for pixel_addr to avoid slow * operation
        always @(posedge pixel_clk) begin
            if (reset || ~vga_start) begin
                pixel_addr <= 0;
            end
            else begin
                if (h_display) begin
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
        assign x_addr = h_display ? h_count : 0;
    end
    else begin: no_x_addr
        assign x_addr = 0;
    end

    // generate y coordinate
    if (GEN_Y_ADDR) begin: gen_y_addr
        assign y_addr = v_display ? v_count : 0;
    end
    else begin: no_y_addr
        assign y_addr = 0;
    end

    endgenerate

endmodule
