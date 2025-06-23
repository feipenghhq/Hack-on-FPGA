// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: Hack on FPGA
// Author: Heqing Huang
// Date Created: 06/11/2025
//
// -------------------------------------------------------------------
// Hack Platform Top
// -------------------------------------------------------------------

module hack_top #(
    parameter RGB_WIDTH = 10,   // RGB width
    parameter WIDTH = 16,       // data width
    parameter I_AW = 16,        // instruction rom address width
    parameter D_AW = 16,        // data ram address width
    parameter S_AW = 16         // screen ram address width
)
(
    input logic                     clk,    // Need to be 27.175 as pixel clock use the same clock
    input logic                     reset,

    // vga output
    output logic                    hsync,
    output logic                    vsync,
    output logic [RGB_WIDTH-1:0]    r,
    output logic [RGB_WIDTH-1:0]    g,
    output logic [RGB_WIDTH-1:0]    b,

    // error reporting
    output logic        invalid_addressM        // invalid memory address
);

localparam DATA_ADDR_END     = 16384;           // Data RAM address end (non-inclusive)
localparam SCREEN_ADDR_START = 16384;           // Screen RAM address start
localparam SCREEN_ADDR_END   = 24567;           // Screen RAM address end (non-inclusive)
localparam KEYBOARD_ADDR     = 24567;           // Keyboard address

/////////////////////////////////////////////////
// Signal Declaration
/////////////////////////////////////////////////

// CPU
logic [WIDTH-1:0]    instruction;
logic [WIDTH-1:0]    inM;

logic [WIDTH-1:0]    pc;
logic [WIDTH-1:0]    addressM;
logic [WIDTH-1:0]    outM;
logic                writeM;

// Data RAM
logic                data_sel;
logic [WIDTH-1:0]    data_addr;
logic [WIDTH-1:0]    data_wdata;
logic                data_write;
logic [WIDTH-1:0]    data_rdata;

// Screen RAM
logic                screen_sel;
logic [WIDTH-1:0]    screen_addr;
logic [WIDTH-1:0]    screen_wdata;
logic                screen_write;
logic [WIDTH-1:0]    screen_rdata;
logic [WIDTH-1:0]    vga_addr;
logic [WIDTH-1:0]    vga_rdata;

// Keyboard
logic                keyboard_sel;
logic [WIDTH-1:0]    keyboard_rdata;

// Data bus Decode
logic [2:0]          read_data_sel;     // Select read from data/screen/keyboard

/////////////////////////////////////////////////
// Logic
/////////////////////////////////////////////////

// Hack CPU
hack_cpu #(.WIDTH(WIDTH))
u_hack_cpu(
    .clk            (clk),
    .reset          (reset),
    .instruction    (instruction),
    .inM            (inM),
    .pc             (pc),
    .addressM       (addressM),
    .outM           (outM),
    .writeM         (writeM)
);

// Data Bus Decode
assign data_sel   = addressM < DATA_ADDR_END;
assign data_wdata = outM;
assign data_addr  = addressM;
assign data_write = writeM & data_sel;

assign screen_sel     = (addressM >= SCREEN_ADDR_START) & (addressM < SCREEN_ADDR_END);
assign screen_wdata   = outM;
assign screen_addr    = addressM;
assign screen_write   = writeM & screen_sel;

assign keyboard_sel       = (addressM == KEYBOARD_ADDR) ? 1'b1 : 1'b0;

assign invalid_addressM   = ~(data_sel | screen_sel | keyboard_sel);

always @(posedge clk) begin
    read_data_sel <= {data_sel, screen_sel, keyboard_sel};
end

assign inM = ({WIDTH{read_data_sel[0]}} & keyboard_rdata) |
             ({WIDTH{read_data_sel[1]}} & screen_rdata)   |
             ({WIDTH{read_data_sel[2]}} & data_rdata);


// VGA controller
hack_vga_top #(.RGB_WIDTH(RGB_WIDTH))
u_hack_vga_top (
    .pixel_clk  (clk),
    .reset      (reset),
    .hsync      (hsync),
    .vsync      (vsync),
    .r          (r),
    .g          (g),
    .b          (b),
    .ram_addr   (vga_addr),
    .ram_rdata  (vga_rdata)
);

// Instruction ROM
ram_1rw #(
    .DW(WIDTH),
    .AW(I_AW)
)
u_instruction_rom(
    .clk    (clk),
    .addr   (pc),
    .write  (1'b0),
    .wdata  (16'b0),
    .rdata  (instruction)
);


// Data RAM
ram_1rw #(
    .DW(WIDTH),
    .AW(D_AW)
)
u_data_ram(
    .clk        (clk),
    .addr       (data_addr),
    .write      (data_write),
    .wdata      (data_wdata),
    .rdata      (data_rdata)
);

// Screen RAM
ram_2rw #(
    .DW(WIDTH),
    .AW(S_AW)
)
u_screen_ram(
    .clk        (clk),
    // port a - cpu access
    .addr_a     (screen_addr),
    .write_a    (screen_write),
    .wdata_a    (screen_wdata),
    .rdata_a    (screen_rdata),
    // port b - vga access - TBD
    .addr_b     (vga_addr),
    .write_b    (1'b0),
    .wdata_b    (16'b0),
    /* verilator lint_off PINCONNECTEMPTY */
    .rdata_b    (vga_rdata)
    /* verilator lint_on PINCONNECTEMPTY */
);

// Keyboard Register
// TBD
assign keyboard_rdata = 0;

endmodule
