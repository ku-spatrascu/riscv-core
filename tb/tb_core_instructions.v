`timescale 1ns/1ps

// This is the instruction test bench, so it basically tests various instructions to make sure they work.
// This test bench passes all tests, but I still refer to it from time to time to make sure any changes I make doesn't affect
// the ability of the core to execute these instructions. This doesn't test branching or forwarding.

// NOTE: there are other testbenches for the specific modules (for example a decoder test bench to make sure the decoder works), 
// they all pass, but if you want them let me know and I can add them. 



`define assert(signal, value, err) begin \
    if ((signal) !== (value)) begin \
        $display("ASSERTION FAILED at %0t: %m | Expected: 0x%08x, Got: 0x%08x", $time, value, signal); \
        err = err + 1; \
    end \
end

module tb_core;

    reg clk, rst_n;

    wire [31:0] instr_addr;
    reg  [31:0] instr_rd_data;
    wire [31:0] data_addr;
    reg  [31:0] data_rd_data;
    wire [31:0] data_wr_data;
    wire [3:0] instr_size, data_size;
    wire instr_read, instr_write;
    wire data_read, data_write;

    reg [31:0] instr_mem [0:1023];
    reg [31:0] data_mem  [0:1023];

    core dut (
        .clk_i(clk),
        .rst_ni(rst_n),
        .imem_addr_o(instr_addr),
        .imem_rd_data_i(instr_rd_data),
        .imem_read_o(instr_read),
        .dmem_addr_o(data_addr),
        .dmem_rd_data_i(data_rd_data),
        .dmem_wr_data_o(data_wr_data),
        .dmem_read_o(data_read),
        .dmem_write_o(data_write)
    );

    always #5 clk = ~clk;

    always @ (posedge clk) begin
        if (instr_read)
            instr_rd_data <= instr_mem[instr_addr[11:2]];
        if (data_read)
            data_rd_data <= data_mem[data_addr[11:2]];
        if (data_write)
            data_mem[data_addr[11:2]] <= data_wr_data;
    end

    integer i;
    integer err;

    task check;
        input [4:0] rd;
        input [31:0] expected;
        input [31*8-1:0] name; // 31*8 bits
        begin
            /* PLEASE MAKE SURE THE INSTANCE NAME IS IDENTICAL*/
            $display("%-20s | x%0d = 0x%08x (expected: 0x%08x)", name, rd, dut.core_ID.rf.rf_data[rd], expected);
            `assert(dut.core_ID.rf.rf_data[rd], expected, err)
        end
    endtask

    initial begin
        $dumpfile("core.vcd");
        $dumpvars(0, tb_core);
    end

    initial begin

        clk = 0; rst_n = 0; err = 0;

        for (i = 0; i < 1024; i = i + 1) begin
            instr_mem[i] = 32'h00000013;
            data_mem[i]  = 0;
        end

        // Independent RV32I instructions
        instr_mem[0]  = 32'h00500093; // ADDI   x1,  x0, 5
        instr_mem[1]  = 32'h00102113; // SLTI   x2,  x0, 1
        instr_mem[2]  = 32'h00304193; // XORI   x3,  x0, 3
        instr_mem[3]  = 32'h00806213; // ORI    x4,  x0, 8
        instr_mem[4]  = 32'h00f00293; // ANDI   x5,  x0, 0xf
        instr_mem[5]  = 32'h00101313; // SLLI   x6,  x0, 1
        instr_mem[6]  = 32'h00105393; // SRLI   x7,  x0, 1
        instr_mem[7]  = 32'h40105413; // SRAI   x8,  x0, 1
        instr_mem[8]  = 32'h001004b3; // ADD    x9,  x0, x1 
        instr_mem[9]  = 32'h402185b3; // SUB    x11, x3, x2
        instr_mem[10] = 32'h00311733; // SLL    x14, x2, x3
        instr_mem[11] = 32'h003128b3; // SLT    x17, x2, x3
        instr_mem[12] = 32'h0021b933; // SLTU   x18, x3, x2
        instr_mem[13] = 32'h00314a33; // XOR    x20, x2, x3
        instr_mem[14] = 32'h0020db33; // SRL    x22, x1, x2
        instr_mem[15] = 32'h4020dc33; // SRA    x24, x1, x2
        instr_mem[16] = 32'h12345d37; // LUI    x26,     0x12345
        instr_mem[17] = 32'h00001d97; // AUIPC  x27,     0x1
        instr_mem[18] = 32'h04000e13; // ADDI   x28, x0, 64
        instr_mem[19] = 32'h00502223; // SW     x5,      4(x0)
        instr_mem[20] = 32'h00402f03; // LW     x30,     4(x0)

        #10 rst_n = 1;
        repeat (60) @ (posedge clk);

        check(1,  5,                "ADDI x1, x0, 5");
        check(2,  1,                "SLTI x2, x0, 1");
        check(3,  3,                "XORI x3, x0, 3");
        check(4,  8,                "ORI  x4, x0, 8");
        check(5,  15,               "ANDI x5, x0, 0xf");
        check(6,  0,                "SLLI x6, x0, 1");
        check(7,  0,                "SRLI x7, x0, 1");
        check(8,  0,                "SRAI x8, x0, 1");
        check(9,  5,                "ADD x9, x0, x1");
        check(11, 2,                "SUB x11, x11, x13");
        check(14, 8,                "SLL x14, x0, x15");
        check(17, 1,                "SLT x17, x0, x17");
        check(18, 0,                "SLTU x18, x0, x19");
        check(20, 2,                "XOR x20, x0, x21");
        check(22, 2,                "SRL x22, x0, x23");
        check(24, 2,                "SRA x24, x0, x25");
        check(26, 32'h12345000,     "LUI x26");
        check(27, 32'h00001044,     "AUIPC x27");
        check(28, 64,               "ADDI x28, x0, 64");
        check(30, 32'h0000000f,     "LW x30, 0(x28)");

        $display("===== TEST RESULTS =====");
        if (err == 0)
            $display("All tests PASSED successfully!");
        else
            $display("FAILED: %d tests failed!", err);

        $finish;
    end

endmodule
