module control_unit (
    input wire [4:0] opcode_eff,
    input wire funct7_fif,
    input wire [2:0] funct3,
    input wire BrEq,
    input wire BrLT,
    output wire PCSel,
    output wire [2:0] ImmSel,
    output wire RegWEn,
    output wire BrUn,
    output wire ASel,
    output wire BSel,
    output wire [3:0] ALUSel,
    output wire MemRW,
    output wire [1:0] WBSel
);

    wire Branch, Jump, Jalr;
    wire main_RegWEn, main_ASel, main_BSel, main_MemRW;
    wire [2:0] main_ImmSel;
    wire [1:0] main_WBSel;

    // Instantiate main decoder
    main_decoder md (
        .opcode (opcode_eff),
        .RegWEn (main_RegWEn),
        .ImmSel (main_ImmSel),
        .ASel   (main_ASel),
        .BSel   (main_BSel),
        .MemRW  (main_MemRW),
        .WBSel  (main_WBSel),
        .Branch (Branch),
        .Jump   (Jump),
        .Jalr   (Jalr)
    );

    // Instantiate ALU decoder
    ALU_decoder ad (
        .opcode      (opcode_eff),
        .funct3      (funct3),
        .funct7_bit  (funct7_fif),
        .ALUSel      (ALUSel)
    );

    // Pass through main decoder outputs
    assign RegWEn = main_RegWEn;
    assign ImmSel = main_ImmSel;
    assign ASel   = main_ASel;
    assign BSel   = main_BSel;
    assign MemRW  = main_MemRW;
    assign WBSel  = main_WBSel;

    // Compute BrUn: set only for unsigned branches (BLTU, BGEU)
    wire is_branch = (opcode_eff == 5'b11000);
    wire unsigned_branch = (funct3 == 3'b110) || (funct3 == 3'b111);
    assign BrUn = is_branch & unsigned_branch;

    reg cond;
    always @(*) begin
        case (funct3)
            3'b000: cond = BrEq;           // BEQ
            3'b001: cond = ~BrEq;          // BNE
            3'b100: cond = BrLT;           // BLT
            3'b101: cond = ~BrLT;          // BGE
            3'b110: cond = BrLT;           // BLTU
            3'b111: cond = ~BrLT;          // BGEU
            default: cond = 1'b0;
        endcase
    end

    // PCSel = 1 for unconditional jumps or taken branches
    assign PCSel = Jump | Jalr | (Branch & cond);

endmodule
