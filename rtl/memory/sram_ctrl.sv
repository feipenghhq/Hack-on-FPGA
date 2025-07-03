// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: Hack on FPGA
// Author: Heqing Huang
// Date Created: 06/25/2025
//
// -------------------------------------------------------------------
// SRAM controller
// Contains input register so the read latency is 1
// -------------------------------------------------------------------

module sram_ctrl #(
    parameter AW = 18,    // Input bus address
    parameter DW = 16     // Input bus data width. Fixed to 16bit
) (
    input                   clk,
    input                   reset,
    // Request interface
    input                   read,
    input                   write,
    input  [AW-1:0]         address,    // the address is the word address instead of byte address
    input  [DW-1:0]         wdata,
    input  [DW/8-1:0]       wstrb,      // write strobe (byte enable)
    output [DW-1:0]         rdata,
    // sram interface
    inout  [15:0]           sram_dq,     // SRAM Data bus 16 Bits
    output [17:0]           sram_addr,   // SRAM Address bus 18 Bits
    output                  sram_ub_n,   // SRAM High-byte Data Mask
    output                  sram_lb_n,   // SRAM Low-byte Data Mask
    output                  sram_we_n,   // SRAM Write Enable
    output                  sram_ce_n,   // SRAM Chip Enable
    output                  sram_oe_n   // SRAM Output Enable
);

    initial begin
        assert(DW == 16);
    end

    ///////////////////////////////////////////////
    //  Signal Declaration
    ///////////////////////////////////////////////

    logic [DW-1:0]    sram_dq_write;
    logic             sram_dq_en;

    reg               read_s0;
    reg               write_s0;
    reg  [AW-1:0]     address_s0;
    reg  [DW-1:0]     wdata_s0;
    reg  [DW/8-1:0]   wstrb_s0;

    ///////////////////////////////////////////////
    //  main logic
    ///////////////////////////////////////////////

    assign sram_dq = sram_dq_en ? sram_dq_write : 'z;

    // register the user bus
    always @(posedge clk) begin
        if (reset) begin
            read_s0 <= 0;
            write_s0 <= 0;
        end
        else begin
            read_s0 <= read;
            write_s0 <= write;
        end
    end

    always @(posedge clk) begin
        address_s0 <= address;
        wdata_s0 <= wdata;
        wstrb_s0 <= wstrb;
    end

    // drive the sram interface
    assign sram_addr = address_s0;
    assign sram_ce_n = ~(read_s0 | write_s0);
    assign sram_oe_n = ~read_s0;
    assign sram_we_n = ~write_s0;
    assign sram_ub_n = wstrb_s0[1];
    assign sram_lb_n = wstrb_s0[0];
    assign sram_dq_write = wdata_s0;
    assign sram_dq_en = write_s0;

    // read data to user bus
    assign rdata = sram_dq;

endmodule
