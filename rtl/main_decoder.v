module main_decoder (
    input wire [4:0] opcode,
    output reg RegWEn,
    output reg [2:0] ImmSel,
    output reg ASel,
    output reg BSel,
    output reg MemRW,
    output reg [1:0] WBSel,
    output reg Branch,
    output reg Jump,
    output reg Jalr
);
    always @(*) begin
        // Default values
        RegWEn = 1'b0;
        ImmSel = 3'b000;
        ASel   = 1'b0;
        BSel   = 1'b0;
        MemRW  = 1'b0;
        WBSel  = 2'b01;      // default: ALU result
        Branch = 1'b0;
        Jump   = 1'b0;
        Jalr   = 1'b0;

        case (opcode)
            5'b01101: begin // LUI
                RegWEn = 1'b1;
                ImmSel = 3'b011;
                ASel   = 1'b0;
                BSel   = 1'b1;
                WBSel  = 2'b01;
            end

            5'b00101: begin // AUIPC
                RegWEn = 1'b1;
                ImmSel = 3'b011;
                ASel   = 1'b1;
                BSel   = 1'b1;
                WBSel  = 2'b01;
            end

            5'b11011: begin // JAL
                RegWEn = 1'b1;
                ImmSel = 3'b100;
                ASel   = 1'b1;
                BSel   = 1'b1;
                WBSel  = 2'b10;   // PC+4
                Jump   = 1'b1;
            end

            5'b11001: begin // JALR
                RegWEn = 1'b1;
                ImmSel = 3'b000;
                ASel   = 1'b0;
                BSel   = 1'b1;
                WBSel  = 2'b10;   // PC+4
                Jalr   = 1'b1;
            end

            5'b11000: begin // Branch
                RegWEn = 1'b0;
                ImmSel = 3'b010;
                ASel   = 1'b1;
                BSel   = 1'b1;
                MemRW  = 1'b0;
                WBSel  = 2'b00;
                Branch = 1'b1;
            end

            5'b00000: begin // Load
                RegWEn = 1'b1;
                ImmSel = 3'b000;
                ASel   = 1'b0;
                BSel   = 1'b1;
                MemRW  = 1'b0;
                WBSel  = 2'b00;   // data memory read
            end

            5'b01000: begin // Store
                RegWEn = 1'b0;
                ImmSel = 3'b001;
                ASel   = 1'b0;
                BSel   = 1'b1;
                MemRW  = 1'b1;
                WBSel  = 2'b00;
            end

            5'b00100: begin // ALU immediate
                RegWEn = 1'b1;
                ImmSel = 3'b000;
                ASel   = 1'b0;
                BSel   = 1'b1;
                MemRW  = 1'b0;
                WBSel  = 2'b01;
            end

            5'b01100: begin // ALU register
                RegWEn = 1'b1;
                ImmSel = 3'b000;   // don't care
                ASel   = 1'b0;
                BSel   = 1'b0;
                MemRW  = 1'b0;
                WBSel  = 2'b01;
            end

            default: ; // keep defaults
        endcase
    end
endmodule
