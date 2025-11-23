`timescale 1ns/1ps

// forwarding logic was given from our lab instructions

module forwarding_unit (
    input wire [4:0] rs1_i, // ID/EX
    input wire [4:0] rs2_i, // ID/EX
    input wire wb_reg_write_i, // EX/WB 
    input wire [4:0] wb_rd_i, // EX/WB

    output reg forward_a_o,
    output reg forward_b_o
);


always @(*) begin
    forward_a_o = 1'b0;
    forward_b_o = 1'b0;

    if (wb_reg_write_i == 1'b1 && wb_rd_i != 5'b0 && (wb_rd_i == rs1_i))
        forward_a_o = 1'b1; 
    if (wb_reg_write_i == 1'b1 && wb_rd_i != 5'b0 && (wb_rd_i == rs2_i))
        forward_b_o = 1'b1;


end 

endmodule
