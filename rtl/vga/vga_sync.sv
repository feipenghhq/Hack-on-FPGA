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
    parameter GEN_X_ADDR = 1,       // generate X coordinate
    parameter GEN_Y_ADDR = 1        // generate Y coordinate
)(
    input                       clk,        // pixel clock
    input                       rst_n,

    output logic                vga_hsync,  // hsync output
    output logic                vga_vsync,  // vsync output
    output logic                display_on,   // display video

    output logic [`P_SIZE-1:0]  pixel_addr, // pixel address
    output logic [`H_SIZE-1:0]  x_addr,     // pixel x coordinate
    output logic [`V_SIZE-1:0]  y_addr      // pixel y coordinate
);

    // ------------------------------
    // signal Declaration
    // ------------------------------

    logic [`H_SIZE-1:0]   h_count;
    logic [`H_SIZE-1:0]   h_count_next;
    logic [`V_SIZE-1:0]   v_count;
    logic [`V_SIZE-1:0]   v_count_next;

    logic                 h_count_end;
    logic                 v_count_end;

    logic                 h_display;
    logic                 v_display;

    // --------------------------------
    // Logic
    // --------------------------------

    // horizontal and vertical counter end
    assign h_count_end = (h_count == `H_COUNT-1) ? 1'b1 : 1'b0;
    assign v_count_end = (v_count == `V_COUNT-1) ? 1'b1 : 1'b0;

    // horizontal and vertical counter
    always @(*) begin

        if (h_count_end) h_count_next = 'b0;
        else             h_count_next = h_count + 1'b1;

        // vertical counter only update when one line complete
        v_count_next = v_count;
        if (h_count_end) begin
            if (v_count_end) v_count_next = 'b0;
            else             v_count_next = v_count + 1'b1;
        end

    end

    assign h_display = (h_count_next <= `H_DISPLAY-1);
    assign v_display = (v_count_next <= `V_DISPLAY-1);

    always @(posedge clk) begin
        if (!rst_n) begin
            h_count <= '0;
            v_count <= '0;
            vga_hsync <= 1'b0;
            vga_vsync <= 1'b0;
            display_on <= 1'b0;
        end
        else begin
            h_count <= h_count_next;
            v_count <= v_count_next;
            vga_hsync <= (h_count_next < `H_DISPLAY+`H_FRONT_PORCH) |
                         (h_count_next > `H_DISPLAY+`H_FRONT_PORCH+`H_SYNC_PULSE-1);

            vga_vsync <= (v_count_next < `V_DISPLAY+`V_FRONT_PORCH) |
                         (v_count_next > `V_DISPLAY+`V_FRONT_PORCH+`V_SYNC_PULSE-1);
            display_on <= h_display & v_display;
        end
    end


    generate

        // generate pixel addr
        if (GEN_PIXEL_ADDR) begin: gen_pixel_addr
            // use a dedicated counter for pixel_addr to avoid slow * operation
            always @(posedge clk) begin
                if (!rst_n) begin
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
            assign x_addr = h_display ? h_count : '0;
        end
        else begin: no_x_addr
            assign x_addr = 0;
        end

        // generate y coordinate
        if (GEN_Y_ADDR) begin: gen_y_addr
            assign y_addr = v_display ? v_count : '0;
        end
        else begin: no_y_addr
            assign y_addr = 0;
        end

    endgenerate

endmodule
