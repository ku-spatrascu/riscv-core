`timescale 1ns/1ps

module core_ex_stage #(
    parameter XLEN = 32
)(
    input wire [6:0] opcode_i,
    input wire [2:0] funct3_i,
    input wire [6:0] funct7_i,
    input wire signed [XLEN-1:0] rs1_dout_i, 
    input wire signed [XLEN-1:0] rs2_dout_i, 
    input wire signed [XLEN-1:0] imm_i,
    input wire [XLEN-1:0] pc_i,
    output wire zero_o, 

    input wire signed [XLEN-1:0] wb_data, 

    input wire forward_a_i,
    input wire forward_b_i,

    output wire lt_flag_o, 

    output wire signed [XLEN-1:0] alu_result_o 
);
    wire [3:0] alu_ctrl;
    wire signed [XLEN-1:0]  alu_in1;
    wire signed [XLEN-1:0]  alu_in2;      
    wire signed [XLEN-1:0]  alu_res_int;
    wire  z_flag;

    localparam OPCODE_RTYPE = 7'b0110011;
    localparam OPCODE_AUIPC = 7'b0010111;
    localparam OPCODE_BRANCH = 7'b1100011;


    // forwarding logic, decides if we should use the wb data or the current rs1/rs2 data based on the forward bits
    wire signed [31:0] op_a;
    wire signed [31:0] op_b;
    assign op_a = (forward_a_i == 1'b1) ? wb_data : rs1_dout_i;
    assign op_b = (forward_b_i == 1'b1) ? wb_data : rs2_dout_i;
    // 
    
    assign alu_in1 = (opcode_i == OPCODE_AUIPC) ? ($signed(pc_i) - 32'd4)  : op_a; // this could probably be written a little better, but it passes
    assign alu_in2 = (opcode_i == OPCODE_RTYPE || opcode_i == OPCODE_BRANCH) ? op_b : imm_i;

    alu_ctrl_unit alu_ctrl_u (
        .opcode_i   (opcode_i),
        .funct3_i   (funct3_i),
        .funct7_i   (funct7_i),
        .alu_ctrl_o (alu_ctrl)
    );

    alu alu_u ( // previously the alu had clock logic, but I took it out to fix a timing issue
        .in1_i      (alu_in1),
        .in2_i      (alu_in2),
        .ctrl_i     (alu_ctrl),     
        .result_o   (alu_res_int),  
        .zero_o     (z_flag)
    );

 
    assign alu_result_o = alu_res_int;
    assign zero_o = z_flag;
    assign lt_flag_o = ($signed(alu_in1) < $signed(alu_in2)); // used in branch unit (less than flag)


endmodule