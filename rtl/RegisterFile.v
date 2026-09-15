module RegisterFile 
(
    input  wire        clk,
    input  wire        reset,
    input  wire [4:0]  addrA,
    input  wire [4:0]  addrB,
    input  wire [4:0]  addrD,
    input  wire [31:0] dataD,
    input  wire        reg_write,
    output wire [31:0] dataA,
    output wire [31:0] dataB
);

    reg [31:0] registers [0:31];
    integer i;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end else if (reg_write && (addrD != 5'd0)) begin
            registers[addrD] <= dataD;
        end
    end

    assign dataA = (addrA == 5'd0) ? 32'b0 : registers[addrA];
    assign dataB = (addrB == 5'd0) ? 32'b0 : registers[addrB];

endmodule
