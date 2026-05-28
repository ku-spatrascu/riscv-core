`timescale 1ns/1ps

module ex_wb_pipeline (
    input wire clk_i,
    input wire rst_ni,

    input wire signed [31:0] alu_result_i,
    output reg signed [31:0] alu_result_o,

    input wire [31:0] pc_curr_i,
    output reg [31:0] pc_curr_o,

    input wire signed [31:0] imm_i,
    output reg signed [31:0] imm_o,

    input wire [1:0] mem_to_reg_i,
    output reg [1:0] mem_to_reg_o,

    input wire [4:0] rd_i,
    output reg [4:0] rd_o,
    output reg reg_write_o,
    input wire reg_write_i,

    input wire mr_i,
    input wire mw_i,
    output reg mw_o,
    output reg mr_o,

    input wire signed [31:0] dmem_i,
    output reg signed [31:0] dmem_o



);

always @(posedge clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
        alu_result_o <= 32'b0;
        pc_curr_o <= 32'b0;
        imm_o <= 32'b0;
        mem_to_reg_o <= 2'b0;
        reg_write_o <= 1'b0;
        rd_o <= 5'b0;
        dmem_o <= 32'b0; 
        mw_o <= 1'b0;
        mr_o <= 1'b0;

    end else begin
        alu_result_o <= alu_result_i; 
        pc_curr_o <= pc_curr_i;
        imm_o <= imm_i;
        mem_to_reg_o <= mem_to_reg_i;
        reg_write_o <= reg_write_i;
        rd_o <= rd_i;
        dmem_o <= dmem_i;
        mw_o <= mw_i;
        mr_o <= mr_i;

    end

end 


endmodule