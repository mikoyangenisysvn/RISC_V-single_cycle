module Branch_Comp (
    input wire [31:0] operand_0,
    input wire [31:0] operand_1,
    input wire BrUn,
    output wire BrEq,
    output wire BrLT
);
    assign BrEq = (operand_0 == operand_1);
    assign BrLT = BrUn ? ($unsigned(operand_0) < $unsigned(operand_1))
                       : ($signed(operand_0) < $signed(operand_1));
endmodule
