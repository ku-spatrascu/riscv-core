module immediate_generator (
    input  wire [6:0] opcode_i,
    input  wire [4:0] rd_i,
    input  wire [4:0] rs1_i,
    input  wire [4:0] rs2_i,
    input  wire [2:0] funct3_i,
    input  wire [6:0] funct7_i,
    output reg  signed [31:0] imm_o
);

wire signed [31:0] instr = {funct7_i, rs2_i, rs1_i, funct3_i, rd_i, opcode_i}; 

always @(*) begin
    case (opcode_i)
        7'b0010011, 7'b0000011, 7'b1100111: begin
            imm_o = {{20{instr[31]}}, instr[31:20]};
        end
        7'b0100011: begin
            imm_o = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        end

        7'b1100011: begin
        imm_o = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};        
            end

        7'b0110111, 7'b0010111: begin
            imm_o = {instr[31:12], 12'b0};
        end

        7'b1101111: begin
            imm_o = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        end

        default: imm_o = 32'b0;
    endcase
end

endmodule










