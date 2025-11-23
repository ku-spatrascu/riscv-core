`timescale 1ns/1ps

module core_id_stage #(
    parameter XLEN = 32
)(
    input wire [XLEN-1:0] instr_i,
    input wire clk_i,
    input wire rst_ni,
    input wire signed [XLEN-1:0] rd_din_i,
    input wire [4:0] wb_rd_i,
    input wire wb_reg_write_i,
    
    output wire [4:0] rs1_o,
    output wire [4:0] rs2_o,
    output wire signed [31:0] imm_o,
    output wire [2:0] funct3_o,
    output wire [6:0] funct7_o,
    output wire [4:0] rd_o,
    output wire [6:0] opcode_o,
    output wire reg_write_o,
    output wire mem_read_o,
    output wire mem_write_o,
    output wire [1:0] mem_to_reg_o,
    output wire signed [XLEN-1:0] rs1_dout_o,
    output wire signed [XLEN-1:0] rs2_dout_o,


    // hazard unit inputs/output: 
    input wire [4:0] rd_id_ex_i, 
    input wire is_load_i, 

    output wire is_load_pipeline_o,
    output wire stall_o
    
);
    // internal wiring for the hazard unit inputs rs1 and rs2
    wire [4:0] rs1_id;
    wire [4:0] rs2_id;

    assign rs1_id = rs1_o;
    assign rs2_id = rs2_o;
    // 

    assign opcode_o = instr_i[6:0];
    assign rd_o = instr_i[11:7];
    assign funct3_o = instr_i[14:12];
    assign rs1_o = instr_i[19:15];
    assign rs2_o = instr_i[24:20];
    assign funct7_o = instr_i[31:25];

    assign is_load_pipeline_o = (opcode_o == 7'b0000011); // we pipeline this value instead of inputting it to the hazard unit, so we can use the previous instruction's result

    decoder deco (
       .opcode_i (opcode_o),
       .reg_write_o (reg_write_o),
       .mem_to_reg_o (mem_to_reg_o),
       .mem_write_o (mem_write_o),
       .mem_read_o (mem_read_o)
    );

    immediate_generator imm_gen(
        .opcode_i (opcode_o),
        .funct7_i (funct7_o),
        .funct3_i (funct3_o),
        .rs1_i (rs1_o),
        .rs2_i (rs2_o),
        .rd_i (rd_o),
        .imm_o (imm_o)
    );

    register_file rf (
        .clk_i (clk_i),
        .rst_ni (rst_ni),
        .rs1_i (rs1_o),
        .rs2_i (rs2_o),
        .rd_i (wb_rd_i),
        .rd_din_i (rd_din_i),
        .reg_write_i (wb_reg_write_i),
        .rs1_dout_o (rs1_dout_o),
        .rs2_dout_o (rs2_dout_o)
    );

    hazard_unit haz_u (
        .rd_id_ex_i (rd_id_ex_i),
        .rs1_if_id_i (rs1_id),
        .rs2_if_id_i (rs2_id),

        .is_load_i (is_load_i),

        .stall_o (stall_o)
    );

endmodule
