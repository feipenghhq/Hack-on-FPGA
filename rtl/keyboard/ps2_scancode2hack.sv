// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: PS2 Controller
// Author: Heqing Huang
// Date Created: 07/09/2025
//
// -------------------------------------------------------------------
// Map the PS/2 keyboard Scan Code Set 2 to Hack characters set
// Some characters are not supported because they don't exist in keyboard
// -------------------------------------------------------------------

module ps2_scancode2hack (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [7:0]  scan_code,
    input  logic        valid,      // Asserted when scan_code is valid
    output logic        pressed,    // Asserted if the key is pressed. De-assert if the key is released
    output logic [7:0]  hack,
    output logic        hack_valid
);

    localparam BREAK = 8'hF0;
    localparam E0 = 8'hE0;

    logic [7:0] hack_lut;
    logic [7:0] hack_lut_e0;   // LUT for keycode start with E0
    logic       is_break;
    logic       is_e0;

    always_comb begin
        case (scan_code)
            // Alphanumeric
            8'h1C: hack_lut = "a";
            8'h32: hack_lut = "b";
            8'h21: hack_lut = "c";
            8'h23: hack_lut = "d";
            8'h24: hack_lut = "e";
            8'h2B: hack_lut = "f";
            8'h34: hack_lut = "g";
            8'h33: hack_lut = "h";
            8'h43: hack_lut = "i";
            8'h3B: hack_lut = "j";
            8'h42: hack_lut = "k";
            8'h4B: hack_lut = "l";
            8'h3A: hack_lut = "m";
            8'h31: hack_lut = "n";
            8'h44: hack_lut = "o";
            8'h4D: hack_lut = "p";
            8'h15: hack_lut = "q";
            8'h2D: hack_lut = "r";
            8'h1B: hack_lut = "s";
            8'h2C: hack_lut = "t";
            8'h3C: hack_lut = "u";
            8'h2A: hack_lut = "v";
            8'h1D: hack_lut = "w";
            8'h22: hack_lut = "x";
            8'h35: hack_lut = "y";
            8'h1A: hack_lut = "z";

            // Numbers top row
            8'h16: hack_lut = "1";
            8'h1E: hack_lut = "2";
            8'h26: hack_lut = "3";
            8'h25: hack_lut = "4";
            8'h2E: hack_lut = "5";
            8'h36: hack_lut = "6";
            8'h3D: hack_lut = "7";
            8'h3E: hack_lut = "8";
            8'h46: hack_lut = "9";
            8'h45: hack_lut = "0";

            // Space, Enter, etc.
            8'h29: hack_lut = " ";
            8'h5A: hack_lut = 8'h0D;  // Enter
            8'h66: hack_lut = 8'h08;  // Backspace
            8'h0D: hack_lut = 8'h09;  // Tab

            // Punctuation (non-shifted)
            8'h4E: hack_lut = "-";
            8'h55: hack_lut = "=";
            8'h5D: hack_lut = 8'h5C;   // \
            8'h54: hack_lut = "[";
            8'h5B: hack_lut = "]";
            8'h4C: hack_lut = ";";
            8'h52: hack_lut = "'";
            8'h41: hack_lut = ",";
            8'h49: hack_lut = ".";
            8'h4A: hack_lut = "/";

            default: hack_lut = 8'h00;
        endcase

        case(scan_code)
            // Special keys that start with E0
            //8'h11: hack_lut_e0 = 8'hA4; // Right Alt
            //8'h14: hack_lut_e0 = 8'hA3; // Right Ctrl
            8'h70: hack_lut_e0 = 8'd138; // Insert
            8'h71: hack_lut_e0 = 8'd139; // Delete  DEL
            8'h6B: hack_lut_e0 = 8'd130; // Left Arrow
            8'h6C: hack_lut_e0 = 8'd134; // Home
            8'h69: hack_lut_e0 = 8'd135; // End
            8'h75: hack_lut_e0 = 8'd131; // Up Arrow
            8'h72: hack_lut_e0 = 8'd133; // Down Arrow
            8'h7D: hack_lut_e0 = 8'd136; // Page Up
            8'h7A: hack_lut_e0 = 8'd137; // Page Down
            8'h74: hack_lut_e0 = 8'd132; // Right Arrow
            //8'h4A: hack_lut_e0 = "/";   // Keypad '/'
            //8'h5A: hack_lut_e0 = 8'h0D; // Keypad Enter
            default: hack_lut_e0 = 8'h00;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            hack_valid <= 1'b0;
            pressed     <= 1'b1;    // first key must be pressed
            is_break    <= 1'b0;
            is_e0       <= 1'b0;
        end
        else begin
            hack_valid <= 1'b0;
            if (valid) begin
                // E0
                if (scan_code == E0) begin
                    is_e0 <= 1'b1;
                end
                // break code
                else if (scan_code == BREAK) begin
                    is_break <= 1'b1;
                    pressed <= 1'b0;  // first scan code after BREAK code means the key is released
                end
                // Regular code
                else begin
                    hack_valid  <= 1'b1;
                    hack        <= hack_lut;
                    hack        <= is_e0 ? hack_lut_e0 : hack_lut;
                    is_e0       <= 1'b0;
                    is_break    <= 1'b0;
                    pressed     <= ~is_break;
                end
            end
        end
    end

endmodule
