`timescale 1ns/1ps

module program_counter (
    input wire clk_i,
    input wire rst_ni,
    input wire pc_write_i,
    input wire [31:0] pc_next_i,
    output reg [31:0] pc_curr_o
);


always @(posedge clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
        pc_curr_o <= 32'b0; 
    end else if (pc_write_i == 1'b1) begin
        pc_curr_o <= pc_next_i; 
    end
    end

endmodule