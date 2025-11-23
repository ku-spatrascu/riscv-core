`timescale 1ns/1ps


// this is a load hazard unit, so if the previous instruction is a load that used one of the registers, we stall the pipeline
module hazard_unit (
    input wire [4:0] rd_id_ex_i, 
    input wire [4:0] rs1_if_id_i,
    input wire [4:0] rs2_if_id_i,
    input wire is_load_i,

    output reg stall_o


);


always @(*) begin
    stall_o = 1'b0;

if (is_load_i == 1'b1 && rd_id_ex_i != 5'b0) begin
    if ((rd_id_ex_i == rs1_if_id_i) || (rd_id_ex_i == rs2_if_id_i) ) begin
        stall_o = 1'b1; 
    end
end

end





endmodule