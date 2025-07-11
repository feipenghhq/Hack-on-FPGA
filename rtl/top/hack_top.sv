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
    parameter RGB_WIDTH = 10   // RGB width
) (
    input logic                     clk,    // Need to be 25.175 as pixel clock use the same clock
    input logic                     rst_n,

    // vga output
    output logic                    hsync,
    output logic                    vsync,
    output logic [RGB_WIDTH-1:0]    r,
    output logic [RGB_WIDTH-1:0]    g,
    output logic [RGB_WIDTH-1:0]    b,

    `ifdef DE2
    // SRAM Interface
    inout  [15:0]                   sram_dq,     // SRAM Data bus 16 Bits
    output [17:0]                   sram_addr,   // SRAM Address bus 18 Bits
    output                          sram_ub_n,   // SRAM High-byte Data Mask
    output                          sram_lb_n,   // SRAM Low-byte Data Mask
    output                          sram_we_n,   // SRAM Write Enable
    output                          sram_ce_n,   // SRAM Chip Enable
    output                          sram_oe_n,   // SRAM Output Enable
    `endif
    // PS/2
    input  logic                    ps2_clk,
    input  logic                    ps2_data,

    // uart_host
    output logic                    uart_txd,
    input  logic                    uart_rxd
);

localparam WIDTH = 16;                  // Hack data width
localparam I_AW  = 15;                  // instruction rom address width - 32K x 16b
localparam D_AW  = 14;                  // data ram address width - 16K x 16b
localparam S_AW  = 13;                  // screen ram address width - 8K x 16b
localparam FREQ  = 25;                  // clock frequency

localparam DATA_ADDR_END     = 16384;   // Data RAM address end (non-inclusive)
localparam SCREEN_ADDR_START = 16384;   // Screen RAM address start
localparam SCREEN_ADDR_END   = 24576;   // Screen RAM address end (non-inclusive)
localparam KEYBOARD_ADDR     = 24576;   // Keyboard address

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
logic [D_AW-1:0]     data_addr;     // data ram size is 16384
logic [WIDTH-1:0]    data_wdata;
logic                data_write;
logic [WIDTH-1:0]    data_rdata;

// Screen RAM
logic                screen_sel;
logic [S_AW-1:0]     screen_addr;   // screen ram size is 8196, only [7:0] will be used
logic [WIDTH-1:0]    screen_wdata;
logic                screen_write;
logic [WIDTH-1:0]    screen_rdata;
logic [S_AW-1:0]     vga_addr;
logic [WIDTH-1:0]    vga_rdata;

// Keyboard
logic                keyboard_sel;
logic [WIDTH-1:0]    keyboard_rdata;

// Data bus Decode
logic [2:0]          read_data_sel;     // Select read from data/screen/keyboard

// Uart Host
logic                uart_rst_n_out;
logic [15:0]         uart_address;
logic                uart_wvalid;
logic [15:0]         uart_wdata;
logic                uart_wready;
logic                uart_rvalid;
logic                uart_rready;
logic                uart_rrvalid;
logic [15:0]         uart_rdata;
logic                uart_host_sel;

// Instruction ROM decode
logic [I_AW-1:0]     rom_address;
logic                rom_write;
logic [WIDTH-1:0]    rom_wdata;
logic                rom_read;

// cpu rst_n
logic                cpu_rst_n;

/////////////////////////////////////////////////
// Logic
/////////////////////////////////////////////////

// cpu reset logic
// both the main reset and the uart reset output controls cpu reset
assign cpu_rst_n = rst_n & uart_rst_n_out;

// Data RAM Decode
// Because FPGA has limited on-chip RAM, we split the Hack RAM to 3 different RAM.
// - Data RAM = RAM[0:16383]. Implemented as 1 RW port RAM
// - Screen RAM = RAM[16384:24566]. Implemented as 2 RW port RAM
// - keyboard register = RAM[24567]. Implemented as a register
// We need a decode logic to decode the bus to the 3 different ram

assign data_sel   = addressM < DATA_ADDR_END;
assign data_wdata = outM;
assign data_addr  = addressM[D_AW-1:0];
assign data_write = writeM & data_sel;

assign screen_sel    = (addressM >= SCREEN_ADDR_START) & (addressM < SCREEN_ADDR_END);
assign screen_wdata  = outM;
assign screen_addr   = (addressM - SCREEN_ADDR_START);
assign screen_write  = writeM & screen_sel;

assign keyboard_sel  = (addressM == KEYBOARD_ADDR) ? 1'b1 : 1'b0;

always @(posedge clk) begin
    read_data_sel <= {data_sel, screen_sel, keyboard_sel};
end

assign inM = ({WIDTH{read_data_sel[0]}} & keyboard_rdata) |
             ({WIDTH{read_data_sel[1]}} & screen_rdata)   |
             ({WIDTH{read_data_sel[2]}} & data_rdata);

// Instruction ROM Decode
assign uart_host_sel = uart_wvalid;
assign uart_rready  = 1'b1;
assign uart_rdata   = instruction;
assign uart_wready = uart_host_sel;
always @(posedge clk) begin
    if (rst_n) uart_rrvalid <= 1'b0;
    else uart_rrvalid <= uart_rvalid;   // read latency = 1
end

assign rom_address = uart_host_sel ? {uart_address[15:1]} : pc[I_AW-1:0]; // uart_address is byte address
assign rom_write   = uart_wvalid;
assign rom_wdata   = uart_wdata;
assign rom_read    = ~uart_wvalid;

// Hack CPU
hack_cpu #(.WIDTH(WIDTH))
u_hack_cpu(
    .clk            (clk),
    .rst_n          (cpu_rst_n),
    .instruction    (instruction),
    .inM            (inM),
    .pc             (pc),
    .addressM       (addressM),
    .outM           (outM),
    .writeM         (writeM)
);

// VGA controller
hack_vga_top #(.RGB_WIDTH(RGB_WIDTH))
u_hack_vga_top (
    .clk        (clk),
    .rst_n      (rst_n),
    .hsync      (hsync),
    .vsync      (vsync),
    .r          (r),
    .g          (g),
    .b          (b),
    .ram_addr   (vga_addr),
    .ram_rdata  (vga_rdata)
);

// Uart Host
uart_host
#(
    .ADDR_BYTE(2),
    .DATA_BYTE(2),
    .BAUD_RATE(115200),
    .CLK_FREQ(FREQ)
)
u_uart_host(
    .clk        (clk),
    .rst_n      (rst_n),
    .uart_txd   (uart_txd),
    .uart_rxd   (uart_rxd),
    .enable     (1'b1),
    .rst_n_out  (uart_rst_n_out),
    .address    (uart_address),
    .wvalid     (uart_wvalid ),
    .wdata      (uart_wdata  ),
    .wready     (uart_wready ),
    .rvalid     (uart_rvalid ),
    .rready     (uart_rready ),
    .rrvalid    (uart_rrvalid),
    .rdata      (uart_rdata  )
);

// Instruction ROM

`ifdef DE2 // For DE2 FPGA Board, Using onboard SRAM as instruction rom.

sram_ctrl #(
    .AW(18),
    .DW(16)
)
u_instruction_rom (
    .clk        (clk),
    .rst_n      (rst_n),
    .read       (rom_read),
    .write      (rom_write),
    .address    ({2'b0, rom_address}),
    .wdata      (rom_wdata),
    .strobe     (2'b11),
    .rdata      (instruction),
    .sram_dq    (sram_dq  ),
    .sram_addr  (sram_addr),
    .sram_ub_n  (sram_ub_n),
    .sram_lb_n  (sram_lb_n),
    .sram_we_n  (sram_we_n),
    .sram_ce_n  (sram_ce_n),
    .sram_oe_n  (sram_oe_n)
);

`else // Using FPGA on-chip RAM

ram_1rw #(
    .DW(WIDTH),
    .AW(I_AW)
)
u_instruction_rom(
    .clk    (clk),
    .addr   (rom_address),
    .write  (rom_write),
    .wdata  (rom_wdata),
    .rdata  (instruction)
);

`endif

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
    // port b - vga access
    .addr_b     (vga_addr),
    .write_b    (1'b0),
    .wdata_b    (16'b0),
    .rdata_b    (vga_rdata)
);

// Keyboard Register
keyboard
u_keyboard(
    .clk        (clk),
    .rst_n      (rst_n),
    .ps2_clk    (ps2_clk),
    .ps2_data   (ps2_data),
    .value      (keyboard_rdata)
);

endmodule
