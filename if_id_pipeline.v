`timescale 1ns/1ps

module if_id_pipeline (
    input wire clk_i,
    input wire rst_ni,
    input wire [31:0] instr_i,
    output reg [31:0] instr_o,

    input wire flush_i,
    input wire if_id_write_i,

    input wire [31:0] pc_curr_i,
    output reg [31:0] pc_curr_o

);


always @(posedge clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
        instr_o <= 32'b0;
        pc_curr_o <= 32'b0;
        
    end else if (flush_i) begin
        instr_o <= 32'b0; // I intialized it to 0 for the flush, but could also use a NOP, since this will lead to ADD x0, x0, x0 basically
        pc_curr_o <= 32'b0;
    
    end else if (if_id_write_i == 1'b1) begin
        instr_o <= instr_i;
        pc_curr_o <= pc_curr_i;
       
    end

end 

endmodule