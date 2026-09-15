module Data_Memory 
(
    input wire clk,
    input wire MemRW,
    input wire [31:0] addr,
    input wire [31:0] DataW,
    output wire [31:0] DataR
);

    reg [31:0] memory [0:255];

    wire [7:0] ram_addr = addr[9:2];

    assign DataR = memory[ram_addr];

    always @(posedge clk) begin
        if (MemRW)
            memory[ram_addr] <= DataW;
    end
endmodule
