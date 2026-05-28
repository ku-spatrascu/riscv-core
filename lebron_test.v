`timescale 1ns/1ps

module tb_load_store_hazard;

    reg clk;
    reg rst_n;

    wire [31:0] instr_addr;
    reg  [31:0] instr_rd_data;
    wire        instr_read;

    wire signed [31:0] data_addr;
    wire signed [31:0] data_wr_data;
    reg  signed [31:0] data_rd_data;
    wire               data_write;
    wire               data_read;

    // Memories
    reg [31:0] instr_mem [0:255];
    reg signed [31:0] data_mem [0:255];

    integer i;
    integer failed;

    core uut (
        .clk_i          (clk),
        .rst_ni         (rst_n),

        .imem_addr_o    (instr_addr),
        .imem_rd_data_i (instr_rd_data),
        .imem_read_o    (instr_read),

        .dmem_addr_o    (data_addr),
        .dmem_wr_data_o (data_wr_data),
        .dmem_rd_data_i (data_rd_data),
        .dmem_write_o   (data_write),
        .dmem_read_o    (data_read)
    );

    // Clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // -----------------------------
    // Ideal combinational read memory
    // -----------------------------
    always @(*) begin
        if (instr_read)
            instr_rd_data = instr_mem[instr_addr[11:2]];
        else
            instr_rd_data = 32'b0;

        if (data_read)
            data_rd_data = data_mem[data_addr[11:2]];
        else
            data_rd_data = 32'b0;
    end

    // Synchronous write memory
    always @(posedge clk) begin
        if (data_write) begin
            data_mem[data_addr[11:2]] <= data_wr_data;
            $display("[%0t] DMEM WRITE: addr=%0d word_index=%0d data=0x%08h",
                     $time, data_addr, data_addr[11:2], data_wr_data);
        end
    end

    always @(posedge clk) begin
    if (data_read) begin
        $display("[%0t] DMEM READ : addr=%0d word_index=%0d data=0x%08h",
                 $time, data_addr, data_addr[11:2], data_rd_data);
    end

    if (data_write) begin
        $display("[%0t] DMEM WRITE: addr=%0d word_index=%0d data=0x%08h",
                 $time, data_addr, data_addr[11:2], data_wr_data);
    end
end

always @(posedge clk) begin
    if (data_read) begin
        $display("[%0t] DMEM READ : addr=%0d word_index=%0d data=0x%08h",
                 $time, data_addr, data_addr[11:2], data_rd_data);
    end

    if (data_write) begin
        $display("[%0t] DMEM WRITE: addr=%0d word_index=%0d data=0x%08h",
                 $time, data_addr, data_addr[11:2], data_wr_data);
    end
end

    initial begin
        failed = 0;

        $dumpfile("core_load_store_hazard.vcd");
        $dumpvars(0, tb_load_store_hazard);

        // Clear memories
        for (i = 0; i < 256; i = i + 1) begin
            instr_mem[i] = 32'h00000013; // NOP
            data_mem[i]  = 32'sd0;
        end


        
        // ----------------------------------------------------
        // Data setup
        // x4 will hold byte address 64.
        //
        // data_mem[16] = address 64
        // data_mem[17] = address 68
        // data_mem[18] = address 72
        //
        // We put a known value at data_mem[17].
        // The program should copy data_mem[17] into data_mem[16].
        // ----------------------------------------------------
        data_mem[16] = 32'h00000000; // address 64
data_mem[17] = 32'h06B97B0D; // address 68
data_mem[18] = 32'h00000000; // address 72

        // ----------------------------------------------------
        // Program:
        //
        // 0x00: addi x4, x0, 64       // x4 = base address 64
        // 0x04: lw   x6, 4(x4)        // x6 = data_mem[17]
        // 0x08: sw   x6, 0(x4)        // data_mem[16] = x6
        // 0x0c: lw   x7, 0(x4)        // x7 should load copied value
        //
        // This directly tests:
        //      lw x6 -> sw x6 hazard
        //
        // If stall/forwarding is wrong, sw often writes 0.
        //
        // Then a second test with NOP spacing:
        //
        // 0x10: lw   x6, 4(x4)
        // 0x14: nop
        // 0x18: nop
        // 0x1c: sw   x6, 8(x4)        // data_mem[18] = x6
        // 0x20: lw   x8, 8(x4)
        //
        // If immediate lw->sw fails but NOP-spaced version passes,
        // the issue is hazard/stall timing.
        // If both fail, likely load/WB/regfile issue.
        // ----------------------------------------------------


        instr_mem[0] = 32'h04000213; // addi x4, x0, 64
instr_mem[1] = 32'h00422303; // lw   x6, 4(x4)
instr_mem[2] = 32'h00000013; // nop
instr_mem[3] = 32'h00000013; // nop
instr_mem[4] = 32'h00622023; // sw   x6, 0(x4)
instr_mem[5] = 32'h00022383; // lw   x7, 0(x4)

        // Reset
        rst_n = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        // Run long enough for program to finish
        repeat (40) @(posedge clk);

        

        $display("====================================");
        $display("LOAD -> STORE HAZARD TEST RESULTS");
        $display("data_mem[16] = 0x%08h, expected 0x06B97B0D", data_mem[16]);
        $display("data_mem[17] = 0x%08h, source value", data_mem[17]);
        $display("data_mem[18] = 0x%08h, expected 0x06B97B0D", data_mem[18]);
        $display("====================================");

        if (data_mem[16] !== 32'h06B97B0D) begin
            $display("FAILED: immediate lw -> sw dependency failed.");
            failed = failed + 1;
        end else begin
            $display("PASSED: immediate lw -> sw dependency.");
        end

        if (data_mem[18] !== 32'h06B97B0D) begin
            $display("FAILED: NOP-spaced lw -> sw dependency failed.");
            failed = failed + 1;
        end else begin
            $display("PASSED: NOP-spaced lw -> sw dependency.");
        end

        if (failed == 0) begin
            $display("ALL LOAD/STORE HAZARD TESTS PASSED.");
        end else begin
            $display("FAILED: %0d load/store hazard tests failed.", failed);
        end

        $finish;
    end

endmodule