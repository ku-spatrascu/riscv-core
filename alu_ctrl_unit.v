`timescale 1ns / 1ps

module alu_ctrl_unit (
    input  wire [6:0] opcode_i,
    input  wire [2:0] funct3_i,
    input wire [6:0] funct7_i,
    output reg [3:0] alu_ctrl_o
);
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_AND  = 4'b0001;
    localparam ALU_OR   = 4'b0010;
    localparam ALU_XOR  = 4'b0011;
    localparam ALU_SLL  = 4'b0100;
    localparam ALU_SRL  = 4'b0101;
    localparam ALU_SRA  = 4'b0110;
    localparam ALU_SUB  = 4'b0111;
    localparam ALU_SLTU = 4'b1000;
    localparam ALU_SLT  = 4'b1001;

    always @(*) begin
        alu_ctrl_o = ALU_ADD;
        case (opcode_i)
            7'b0110011: begin
                case (funct3_i)
                    3'b000: 
                        if (funct7_i == 7'b0100000)
                            alu_ctrl_o = ALU_SUB;
                        else
                            alu_ctrl_o = ALU_ADD;

                    3'b001:
                        alu_ctrl_o = ALU_SLL;
                    3'b010:
                        alu_ctrl_o = ALU_SLT;
                    3'b011:
                        alu_ctrl_o = ALU_SLTU;
                    3'b100:
                        alu_ctrl_o = ALU_XOR;
                    3'b101:
                        if (funct7_i == 7'b0000000)
                            alu_ctrl_o = ALU_SRL;
                        else 
                            alu_ctrl_o = ALU_SRA;
                    3'b110:
                        alu_ctrl_o = ALU_OR;
                    3'b111:
                        alu_ctrl_o = ALU_AND;   
                endcase            
            end

            7'b0010011: begin
                case (funct3_i)
                3'b000: 
                    alu_ctrl_o = ALU_ADD;
                3'b111:
                    alu_ctrl_o = ALU_AND;
                3'b110:
                    alu_ctrl_o = ALU_OR;
                3'b100:
                    alu_ctrl_o = ALU_XOR;
                3'b001:
                    alu_ctrl_o = ALU_SLL;
                3'b101:
                    if (funct7_i == 7'b0000000)
                        alu_ctrl_o = ALU_SRL;
                    else   
                        alu_ctrl_o = ALU_SRA;
                3'b010:
                    alu_ctrl_o = ALU_SLT;
                3'b011:
                    alu_ctrl_o = ALU_SLTU;
                endcase
            end

            7'b1100011: begin
                case (funct3_i)
                3'b000:
                    alu_ctrl_o = ALU_SUB;
                3'b001:
                    alu_ctrl_o = ALU_SUB;
                3'b100:
                    alu_ctrl_o = ALU_SLT;
                3'b101:                     
                    alu_ctrl_o = ALU_SLT;
                endcase
            end

            7'b0100011: alu_ctrl_o = ALU_ADD;
            7'b0000011: alu_ctrl_o = ALU_ADD;
            7'b1100111: alu_ctrl_o = ALU_ADD;
            7'b1101111: alu_ctrl_o = ALU_ADD;
            7'b0010111: alu_ctrl_o = ALU_ADD;
            7'b0110111: alu_ctrl_o = ALU_ADD;
            default: alu_ctrl_o = ALU_ADD;
        
        endcase
    end

endmodule
