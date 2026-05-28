`timescale 1ns/1ps

module fetch (
    input wire clk_i,
    input wire rst_ni,
    input wire pc_write_i,
    output wire [31:0] pc_curr_o,
    input wire [31:0] pc_next_i,

    //instr ctrl stuff
    input wire stall_i,
    input wire flush_i,
    input wire [31:0] imem_rd_data_i,
    output wire [31:0] pc_id_o,
    output wire [31:0] instr_if_aligned_o,
    output wire instr_valid_if_o,



    input wire branch_taken_i,
    input wire [31:0] pc_branch_i
);
// could change to avoid declaring register
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

instr_ctrl imem_align (
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),

    .stall_i        (stall_i),
    .flush_i        (flush_i),

    .pc_write_i     (pc_write_i),

    .pc_if_i        (pc_curr_o),
    .imem_rd_data_i (imem_rd_data_i),

    .pc_id_o        (pc_id_o),
    .instr_id_o     (instr_if_aligned_o),
    .instr_valid_o  (instr_valid_if_o)
);

endmodule



// output wire        imem_req_valid_o;
// input  wire        imem_req_ready_i;
// output wire [31:0] imem_req_addr_o;

// input  wire        imem_resp_valid_i;
// output wire        imem_resp_ready_o;
// input  wire [31:0] imem_resp_data_i;