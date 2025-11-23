`timescale 1ns/1ps

module register_file (
    input wire [4:0] rs1_i,
    input wire [4:0] rs2_i,
    input wire [4:0] rd_i,
    input wire [31:0] rd_din_i,
    input wire reg_write_i,
    output reg signed [31:0] rs1_dout_o,
    output reg signed [31:0] rs2_dout_o,
    input wire clk_i,
    input wire rst_ni
);

reg signed [31:0] rf_data [31:0]; 

always @(*) begin
    if (rst_ni == 1'b0) begin
        rs1_dout_o = 32'b0;
        rs2_dout_o = 32'b0;
    end else begin
        if (rs1_i != 5'b0)
            rs1_dout_o = rf_data[rs1_i];
        else
            rs1_dout_o = 32'b0;

        if (rs2_i != 5'b0)
            rs2_dout_o = rf_data[rs2_i];
        else
            rs2_dout_o = 32'b0;
    end
end

always @(posedge clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin 
        for (integer i = 0; i < 32; i++) 
            rf_data[i] <= 32'b0;
    end 
    else if  (reg_write_i == 1'b1 && rd_i != 5'b0) 
        rf_data[rd_i] <= rd_din_i; 
    
    end
endmodule