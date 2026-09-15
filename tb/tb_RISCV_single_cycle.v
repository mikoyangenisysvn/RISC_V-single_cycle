`timescale 1ns/1ps

module tb_RISCv_Single_Cycle;

    reg clk;
    reg rst_n;

    integer timeout_cnt;
    integer err_count;
    integer r;

    localparam TIMEOUT_CYCLES = 3000;
    localparam RESULT_WORD    = 0;        // DMEM word index for byte addr 0x400
    localparam PASS_CODE      = 32'h0000_0001;

    RISCv_Single_Cycle dut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_RISCv_Single_Cycle);

        $readmemh("./mem/imem.hex", dut.IMEM_inst.memory);
        $readmemh("./mem/dmem_init.hex", dut.DMEM_inst.memory);

        clk         = 0;
        rst_n       = 0;
        timeout_cnt = 0;
        err_count   = 0;

        #20;
        rst_n = 1;

        while ((dut.DMEM_inst.memory[RESULT_WORD] == 32'h0) &&
               (timeout_cnt < TIMEOUT_CYCLES)) begin
            @(posedge clk);
            timeout_cnt = timeout_cnt + 1;
        end
        @(posedge clk);

        if (timeout_cnt >= TIMEOUT_CYCLES) begin
            $display("[TB] TIMEOUT after %0d cycles: result word never written", TIMEOUT_CYCLES);
            err_count = err_count + 1;
        end else if (dut.DMEM_inst.memory[RESULT_WORD] !== PASS_CODE) begin
            $display("[TB] FAIL: result word = 0x%08h | dec=%0d | bin=%032b (expected 0x%08h)",
                       dut.DMEM_inst.memory[RESULT_WORD],
                       dut.DMEM_inst.memory[RESULT_WORD],
                       dut.DMEM_inst.memory[RESULT_WORD],
                       PASS_CODE);
            err_count = err_count + 1;
        end else begin
            $display("[TB] result word = 0x%08h | dec=%0d | bin=%032b as expected",
                       dut.DMEM_inst.memory[RESULT_WORD],
                       dut.DMEM_inst.memory[RESULT_WORD],
                       dut.DMEM_inst.memory[RESULT_WORD]);
        end

        // ---- Dump all 32 architectural registers: hex / unsigned dec / signed dec / bin ----
        $display("[TB] ---- Register file dump ----");
        for (r = 0; r < 32; r = r + 1) begin
            $display("x%2d = 0x%08h | udec=%0d | sdec=%0d | bin=%032b",
                       r,
                       dut.Reg_inst.registers[r],
                       dut.Reg_inst.registers[r],
                       $signed(dut.Reg_inst.registers[r]),
                       dut.Reg_inst.registers[r]);
        end

        if (err_count == 0)
            $display("[TB] ==== ALL TESTS PASSED ====");
        else
            $display("[TB] ==== %0d CHECK(S) FAILED ====", err_count);

        $finish;
    end

endmodule
