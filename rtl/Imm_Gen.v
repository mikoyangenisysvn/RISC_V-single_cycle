module Immediate_Generator (
    input wire [31:0] Inst,
    input wire [2:0] ImmSel,
    output reg [31:0] Imm
);
    always @(*) begin
        case (ImmSel)
            3'b000: // I‑type
                Imm = {{20{Inst[31]}}, Inst[31:20]};
            3'b001: // S‑type
                Imm = {{20{Inst[31]}}, Inst[31:25], Inst[11:7]};
            3'b010: // B‑type (offset shifted left by 1)
                Imm = {{19{Inst[31]}}, Inst[31], Inst[7], Inst[30:25], Inst[11:8], 1'b0};
            3'b011: // U‑type
                Imm = {Inst[31:12], 12'b0};
            3'b100: // J‑type (offset shifted left by 1)
                Imm = {{11{Inst[31]}}, Inst[31], Inst[19:12], Inst[20], Inst[30:21], 1'b0};
            default:
                Imm = 32'b0;
        endcase
    end
endmodule
