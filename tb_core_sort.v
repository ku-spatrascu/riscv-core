`timescale 1ns/1ps

// This is the bubble sort test bench for signed numbers

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

    initial begin
        $dumpfile("core.vcd");
        $dumpvars(0, tb_core);
    end

    initial begin
        
        repeat(20) begin
        clk = 0; rst_n = 0; err = 0;
            for (i = 0; i < 1024; i = i + 1) begin
                instr_mem[i] = 32'h00000013; // NOP
                data_mem[i]  = 0;
            end

            // ===== [DATA] initial: {5, 2, 9, 1, 3} =====
            data_mem[0] = $random % $random;
            data_mem[1] = $random % $random;
            data_mem[2] = $random % $random;
            data_mem[3] = $random % $random;
            data_mem[4] = $random % $random;

            $display("===== BUBBLE SORT START =====");
            $display("dmem[0] = %d", $signed(data_mem[0]));
            $display("dmem[1] = %d", $signed(data_mem[1]));
            $display("dmem[2] = %d", $signed(data_mem[2]));
            $display("dmem[3] = %d", $signed(data_mem[3]));
            $display("dmem[4] = %d", $signed(data_mem[4]));

            instr_mem[0] = 32'h00000093; 
            instr_mem[1] = 32'h00000113; 
            instr_mem[2] = 32'h00400193; 
            instr_mem[3] = 32'h02315263;  
            instr_mem[4] = 32'h00211213; 
            instr_mem[5] = 32'h00022283; 
            instr_mem[6] = 32'h00422303; 
            instr_mem[7] = 32'h0062c663; 
            instr_mem[8] = 32'h00622023; 
            instr_mem[9] = 32'h00522223; 
            instr_mem[10] = 32'h00110113;
            instr_mem[11] = 32'hfddff06f;
            instr_mem[12] = 32'h00108093;
            instr_mem[13] = 32'h00500193;
            instr_mem[14] = 32'hfc3096e3;
            instr_mem[15] = 32'h0000006f;
            
            #10 rst_n = 1;
            repeat (600) @ (posedge clk);

            $display("===== BUBBLE SORT RESULT =====");
            $display("dmem[0] = %d", $signed(data_mem[0]));
            $display("dmem[1] = %d", $signed(data_mem[1]));
            $display("dmem[2] = %d", $signed(data_mem[2]));
            $display("dmem[3] = %d", $signed(data_mem[3]));
            $display("dmem[4] = %d", $signed(data_mem[4]));

            if (($signed(data_mem[0]) <= $signed(data_mem[1])) &&
                ($signed(data_mem[1]) <= $signed(data_mem[2])) &&
                ($signed(data_mem[2]) <= $signed(data_mem[3])) &&
                ($signed(data_mem[3]) <= $signed(data_mem[4]))) begin
                err = err + 0;
            end else begin
                err = err + 1;
                $finish;
            end
        end

        if (err == 0)
            $display("All sorting tests passed!");
        else
            $display("FAILED: %d mismatches", err);

        $finish;
    end


endmodule
