module ALU_decoder 
(
    input wire [4:0] opcode,
    input wire [2:0] funct3,
    input wire funct7_bit,      // bit 30 of instruction (funct7[5])
    output reg [3:0] ALUSel
);

    localparam ADD     = 4'h0;
    localparam SUB     = 4'h1;
    localparam AND_OP  = 4'h2;
    localparam OR_OP   = 4'h3;
    localparam XOR_OP  = 4'h4;
    localparam SLL_OP  = 4'h5;
    localparam SRL_OP  = 4'h6;
    localparam SRA_OP  = 4'h7;
    localparam SLT_OP  = 4'h8;
    localparam SLTU_OP = 4'h9;
    localparam PASS_B  = 4'hA;

    always @(*) begin
        case (opcode)
            5'b00100: begin // I‑type ALU (ADDI, SLTI, etc.)
                case (funct3)
                    3'b000: ALUSel = ADD;       // ADDI
                    3'b010: ALUSel = SLT_OP;    // SLTI
                    3'b011: ALUSel = SLTU_OP;   // SLTIU -- FIX: was SLT_OP (signed)
                    3'b100: ALUSel = XOR_OP;    // XORI
                    3'b110: ALUSel = OR_OP;     // ORI
                    3'b111: ALUSel = AND_OP;    // ANDI
                    3'b001: ALUSel = SLL_OP;    // SLLI
                    3'b101: begin
                        if (funct7_bit == 1'b0)
                            ALUSel = SRL_OP;    // SRLI
                        else
                            ALUSel = SRA_OP;    // SRAI
                    end
                    default: ALUSel = ADD;
                endcase
            end

            5'b01100: begin // R‑type (ADD, SUB, etc.)
                case (funct3)
                    3'b000: begin
                        if (funct7_bit == 1'b0)
                            ALUSel = ADD;
                        else
                            ALUSel = SUB;       // SUB
                    end
                    3'b001: ALUSel = SLL_OP;    // SLL
                    3'b010: ALUSel = SLT_OP;    // SLT
                    3'b011: ALUSel = SLTU_OP;   // SLTU -- FIX: was SLT_OP (signed)
                    3'b100: ALUSel = XOR_OP;    // XOR
                    3'b101: begin
                        if (funct7_bit == 1'b0)
                            ALUSel = SRL_OP;    // SRL
                        else
                            ALUSel = SRA_OP;    // SRA
                    end
                    3'b110: ALUSel = OR_OP;     // OR
                    3'b111: ALUSel = AND_OP;    // AND
                    default: ALUSel = ADD;
                endcase
            end

            5'b01101: ALUSel = PASS_B;          // LUI -- FIX: result = Imm exactly,
                                                  // ignores whatever garbage RegisterFile
                                                  // returns for Inst[19:15]

            // Load, store, branch, JAL, JALR, AUIPC all use ADD
            default: ALUSel = ADD;
        endcase
    end

endmodule
