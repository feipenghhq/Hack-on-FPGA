// -------------------------------------------------------------------
// Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
// -------------------------------------------------------------------
//
// Project: Hack on FPGA
// Author: Heqing Huang
// Date Created: 06/11/2025
//
// -------------------------------------------------------------------
// Hack CPU Implementation
// -------------------------------------------------------------------

module hack_cpu #(
    parameter WIDTH = 16
) (
    input  logic                clk,
    input  logic                reset,
    input  logic [WIDTH-1:0]    instruction,    // Instruction Input
    input  logic [WIDTH-1:0]    inM,            // Memory Read Data

    output logic [WIDTH-1:0]    pc,             // Program Counter
    output logic [WIDTH-1:0]    addressM,       // Memory Address
    output logic [WIDTH-1:0]    outM,           // Memory Write Data
    output logic                writeM          // Memory Write Enable
);

/////////////////////////////////////////////////
// Signal Declarations
/////////////////////////////////////////////////

// Register
logic [WIDTH-1:0]   A_reg;
logic [WIDTH-1:0]   D_reg;
logic [WIDTH-1:0]   I_reg;

// Instruction Field
logic               opcode;
logic [5:0]         comp;
logic [2:0]         dest;
logic [2:0]         jump;
logic               isM;
logic               isC;
logic               isA;

// ALU
logic [WIDTH-1:0]   alu_x;
logic [WIDTH-1:0]   alu_y;
logic [WIDTH-1:0]   alu_out;
logic               alu_ng;
logic               alu_zr;

logic               condition;

localparam          EXECUTE = 0;
localparam          MEM_READ = 1;
logic               state;
logic               stall;
logic [WIDTH-1:0]   inst_mux;   // instruction after the instruction MUX

/////////////////////////////////////////////////
// Logic
/////////////////////////////////////////////////

// Instruction Decode
/*
C-instruction format
       1  1  1  a c1 c2 c3 c4 c5 c6 d1 d2 d3 j1 j2 j3
       |  |__|  |_________________|  |_____|  |_____|
       |    |             |             |        |
    opcode  not used   comp bits     dest bits jump bits
Note: this representation use big-endian.
*/

assign opcode = inst_mux[15];
assign comp   = inst_mux[11:6];
assign dest   = inst_mux[5:3];
assign jump   = inst_mux[2:0];
assign isM    = inst_mux[12];
assign isA    = opcode == 0;
assign isC    = opcode == 1;

// CPU Control State Machine
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= EXECUTE;
    end
    else begin
        case (state)
            EXECUTE: if (isM) state <= MEM_READ;
            MEM_READ: state <= EXECUTE;
        endcase
    end
end

assign stall = (state == EXECUTE) & isM;    // stall the cpu while waiting for the memory read data

// PC
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc <= 0;
    end
    else begin
        if (!stall) begin
            if (condition && isC) begin
                pc <= A_reg;
            end
            else begin
                pc <= pc + 1;
            end
        end
    end
end

// A Reg
always @(posedge clk) begin
    if (!stall) begin
        if (isA) begin
            A_reg <= inst_mux;
        end
        else if (dest[2] == 1) begin
            A_reg <= alu_out;
        end
    end
end

// D Reg
always @(posedge clk) begin
    if (!stall) begin
        if (dest[1] == 1) begin
            D_reg <= alu_out;
        end
    end
end

// I Reg
always @(posedge clk) begin
    if (stall) begin
        I_reg <= instruction;
    end
end

// Instruction Mux
assign inst_mux = (state == MEM_READ) ? I_reg : instruction;

// Jump Check
assign condition =
            (jump == 3'b111)                         |  // unconditional jump
            (jump == 3'b001 && !(alu_ng || alu_zr))  |  // JGT
            (jump == 3'b010 && alu_zr)               |  // JEQ
            (jump == 3'b011 && !alu_ng)              |  // JGE
            (jump == 3'b100 && alu_ng)               |  // JLT
            (jump == 3'b101 && !alu_zr)              |  // JNE
            (jump == 3'b110 && (alu_ng || alu_zr));     // JLE

// Memory Output
assign outM = alu_out;
assign writeM = isC & dest[0] & ~stall;
assign addressM = A_reg;

// ALU
assign alu_x = D_reg;
assign alu_y = isM ? inM : A_reg;

hack_alu #(WIDTH)
u_hack_alu (
    .x      (alu_x),
    .y      (alu_y),
    .control(comp),
    .out    (alu_out),
    .zr     (alu_zr),
    .ng     (alu_ng)
);


endmodule
