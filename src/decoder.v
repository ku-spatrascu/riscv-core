`timescale 1ns / 1ps

module decoder (
    input  wire [6:0] opcode_i,
    output reg reg_write_o,
    output reg [1:0] mem_to_reg_o,
    output reg mem_write_o,
    output reg mem_read_o
);

    localparam SRC_ALU        = 2'b00;
    localparam SRC_DMEM       = 2'b01;
    localparam SRC_PC_PLUS_4  = 2'b10;
    localparam SRC_IMM        = 2'b11;

    always @(*) begin

        reg_write_o = 1'b0; 
        mem_write_o = 1'b0;
        mem_read_o = 1'b0;
        mem_to_reg_o = SRC_ALU;

        case (opcode_i)
            7'b0110011: begin
                reg_write_o  = 1'b1;
                mem_to_reg_o = SRC_ALU;
            end

            7'b0010011: begin 
                reg_write_o = 1'b1;
                mem_to_reg_o = SRC_ALU;
            end


            7'b1100011: begin
                mem_to_reg_o = SRC_ALU;
            end


            7'b0100011: begin
                mem_to_reg_o = SRC_ALU;
                mem_write_o = 1'b1;
                reg_write_o = 1'b0;
            end


            7'b0000011: begin
                reg_write_o = 1'b1;
                mem_to_reg_o = SRC_DMEM;
                mem_read_o = 1'b1;
            end


            7'b1100111: begin
                reg_write_o = 1'b1;
                mem_to_reg_o = SRC_PC_PLUS_4;
            end

            7'b1101111: begin
                reg_write_o = 1'b1;
                mem_to_reg_o = SRC_PC_PLUS_4;
            end

            7'b0010111: begin
                reg_write_o = 1'b1;
                mem_to_reg_o = SRC_ALU;
            end

            7'b0110111: begin 
                reg_write_o = 1'b1;
                mem_to_reg_o = SRC_IMM;
            end

            
            
        endcase
    end

endmodule


