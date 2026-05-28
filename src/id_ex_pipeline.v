`timescale 1ns/1ps

module id_ex_pipeline (
    input wire clk_i,
    input wire rst_ni,

    input wire signed [31:0] imm_i,
    input wire signed [31:0] rs1_dout_i,
    input wire signed [31:0] rs2_dout_i,
    input wire [6:0] opcode_i,
    input wire [2:0] funct3_i,
    input wire [6:0] funct7_i,
    input wire mem_read_i,
    input wire mem_write_i,
    input wire [1:0] mem_to_reg_i,
    input wire reg_write_i,

    input wire [31:0] pc_curr_i,
    output reg [31:0] pc_curr_o,

    input wire is_load_i,
    output reg is_load_o,
    
    input wire [4:0] rs1_i,
    input wire [4:0] rs2_i,
    output reg [4:0] rs1_o,
    output reg [4:0] rs2_o, 


    input wire [4:0] rd_i,
    output reg [4:0] rd_o,
    output reg reg_write_o,
    input wire flush_i,
    input wire id_ex_write_i, 

    output reg [6:0] opcode_o,
    output reg [2:0] funct3_o,
    output reg [6:0] funct7_o,
    output reg signed [31:0] rs1_dout_o,
    output reg signed [31:0] rs2_dout_o,
    output reg signed [31:0] imm_o,
    output reg mem_read_o,
    output reg mem_write_o,
    output reg [1:0] mem_to_reg_o


);

always @(posedge clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
        opcode_o <= 7'b0;
        funct3_o <= 3'b0;
        funct7_o <= 7'b0;
        rs1_dout_o <= 32'b0;
        rs2_dout_o <= 32'b0;
        imm_o <= 32'b0;
        mem_write_o <= 1'b0;
        mem_read_o <= 1'b0;
        mem_to_reg_o <= 2'b0;
        reg_write_o <= 1'b0;
        pc_curr_o <= 32'b0;
        rd_o <= 5'b0;
        rs1_o <= 5'b0;
        rs2_o <= 5'b0;
        is_load_o <= 1'b0;

    end else if (flush_i) begin
        opcode_o <= 7'b0;
        funct3_o <= 3'b0;
        funct7_o <= 7'b0;
        rs1_dout_o <= 32'b0;
        rs2_dout_o <= 32'b0;
        imm_o <= 32'b0;
        mem_write_o <= 1'b0;
        mem_read_o <= 1'b0;
        mem_to_reg_o <= 2'b0;
        reg_write_o <= 1'b0;
        pc_curr_o <= 32'b0;
        rd_o <= 5'b0;
        rs1_o <= 5'b0;
        rs2_o <= 5'b0;
        is_load_o <= 1'b0;

    end else if (id_ex_write_i == 1'b1) begin
        opcode_o <= opcode_i;
        funct3_o <= funct3_i;
        funct7_o <= funct7_i;
        rs1_dout_o <= rs1_dout_i;
        rs2_dout_o <= rs2_dout_i;
        imm_o <= imm_i;
        mem_write_o <= mem_write_i;
        mem_read_o <= mem_read_i;
        mem_to_reg_o <= mem_to_reg_i;
        reg_write_o <= reg_write_i;
        pc_curr_o <= pc_curr_i;
        rd_o <= rd_i;
        rs1_o <= rs1_i;
        rs2_o <= rs2_i;
        is_load_o <= is_load_i;
   
    end

end 


endmodule