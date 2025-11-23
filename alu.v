`timescale 1ns / 1ps

module alu (
    input wire clk_i,
    input wire rst_ni,
    
    input  wire signed [31:0] in1_i,
    input  wire signed [31:0] in2_i,
    input  wire [3:0]         ctrl_i,
    output reg  signed [31:0] result_o,
    output reg                zero_o
);

    always @(*) begin
    
        case (ctrl_i)
            4'b0000: result_o = in1_i + in2_i;
            4'b0001: result_o = in1_i & in2_i;
            4'b0010: result_o = in1_i | in2_i;
            4'b0011: result_o = in1_i ^ in2_i;
            4'b0100: result_o = in1_i << in2_i;
            4'b0101: result_o = in1_i >> in2_i;
            4'b0110: result_o = in1_i >>> in2_i;
            4'b0111: result_o = in1_i - in2_i;
            4'b1000: result_o = ($unsigned(in1_i) < $unsigned(in2_i)) ? 1 : 0;
            4'b1001: result_o = (in1_i < in2_i) ? 1 : 0;
            default: result_o = 32'b0;
        endcase
        zero_o = (result_o == 32'b0) ? 1'b1 : 1'b0;
        end
    

endmodule
