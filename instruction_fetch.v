`timescale 1ns/1ps

module fetch (
    input wire clk_i,
    input wire rst_ni,
    input wire pc_write_i,
    output wire [31:0] pc_curr_o,
    input wire [31:0] pc_next_i,

    input wire branch_taken_i,
    input wire [31:0] pc_branch_i
);

reg [31:0] real_pc_next;

always @(*) begin // decides between the calculated pc branch address and the next pc address
    if (branch_taken_i == 1'b1) begin
        real_pc_next = pc_branch_i;
    end else begin
        real_pc_next = pc_next_i;
    end
end

program_counter pc (
    .clk_i (clk_i),
    .rst_ni (rst_ni),
    .pc_write_i (pc_write_i),
    .pc_next_i (real_pc_next),
    .pc_curr_o (pc_curr_o)
);


endmodule