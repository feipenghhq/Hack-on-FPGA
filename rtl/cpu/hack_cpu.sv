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
    input  logic                rst_n,
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

localparam          IDLE  = 0;
localparam          FETCH = 1;
localparam          EXEC  = 2;
logic [1:0]         state;
logic               commit;

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

assign opcode = instruction[15];
assign comp   = instruction[11:6];
assign dest   = instruction[5:3];
assign jump   = instruction[2:0];
assign isM    = instruction[12];
assign isA    = opcode == 0;
assign isC    = opcode == 1;

// CPU Control State Machine
always @(posedge clk) begin
    if (!rst_n) begin
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE:  state <= FETCH;
            FETCH: state <= EXEC;
            EXEC:  state <= FETCH;
        endcase
    end
end

assign commit = (state == EXEC) ? 1'b1 : 1'b0;              // complete in EXEC1 state

// PC
always @(posedge clk) begin
    if (!rst_n) begin
        pc <= 0;
    end
    else begin
        if (commit) begin
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
    if (commit) begin
        if (isA) begin
            A_reg <= instruction;
        end
        else if (dest[2] == 1) begin
            A_reg <= alu_out;
        end
    end
end

// D Reg
always @(posedge clk) begin
    if (commit) begin
        if (isC && (dest[1] == 1)) begin
            D_reg <= alu_out;
        end
    end
end

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
assign writeM = isC & dest[0] & commit;
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
