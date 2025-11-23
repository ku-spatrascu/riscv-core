`timescale 1ns/1ps

module branch_unit (
    input wire [6:0] opcode_i,
    input wire [2:0] funct3_i,
    input wire alu_zero_i,
    input wire [31:0] pc_i,
    input wire signed [31:0] rs1_dout_i,
    input wire signed [31:0] imm_i,
    input wire lt_flag_i,

    output reg branch_taken_o,
    output reg [31:0] pc_branch_o
);

    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;

    localparam FUNCT3_BEQ  = 3'b000;
    localparam FUNCT3_BNE  = 3'b001;
    localparam FUNCT3_BLT  = 3'b100;
    localparam FUNCT3_BGE  = 3'b101;

    always @(*) begin
        branch_taken_o = 1'b0;
        pc_branch_o = 32'b0;

        case (opcode_i)
            OP_BRANCH: begin
                pc_branch_o = $signed(pc_i) + imm_i;
                case (funct3_i)
                    FUNCT3_BEQ: begin
                        if (alu_zero_i) branch_taken_o = 1'b1;
                    end

                    FUNCT3_BNE: begin
                        if (!alu_zero_i) branch_taken_o = 1'b1;
                    end

                   FUNCT3_BLT: begin
                        if (lt_flag_i)
                    branch_taken_o = 1'b1;
                    end

                    FUNCT3_BGE: begin
                        if (!lt_flag_i)
                    branch_taken_o = 1'b1;
            end
                default: branch_taken_o = 1'b0; 
                endcase
            end

            OP_JAL: begin
                branch_taken_o = 1'b1;
                pc_branch_o = $signed(pc_i) + imm_i;
            end

            OP_JALR: begin
                branch_taken_o = 1'b1;
                pc_branch_o = (rs1_dout_i + imm_i) & ~32'd1;
            end

            default: begin
                branch_taken_o = 1'b0;
                pc_branch_o = 32'b0;
            end
        endcase
    end

endmodule
