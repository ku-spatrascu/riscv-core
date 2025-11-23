`timescale 1ns/1ps

module lsu (
    input wire signed [31:0] alu_result_i,
    input wire signed [31:0] rs2_dout_i,
    input wire mem_write_i,
    input wire mem_read_i,
    input wire signed [31:0] dmem_rd_data_i,

    output wire signed [31:0] dmem_addr_o,
    output wire signed [31:0] dmem_wr_data_o,
    output wire dmem_write_o,
    output wire dmem_read_o,
    output wire signed [31:0] dmem_rd_data_o
);

assign dmem_addr_o = alu_result_i;

assign dmem_wr_data_o = rs2_dout_i;

assign dmem_rd_data_o = dmem_rd_data_i;

assign dmem_write_o = mem_write_i;

assign dmem_read_o = mem_read_i;


endmodule


