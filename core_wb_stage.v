`timescale 1ns/1ps

module core_wb_stage #(
    parameter XLEN = 32
)(
    input wire [1:0] mem_to_reg_i,
    input wire signed [XLEN-1:0] dmem_rd_data_i,
    input wire signed [XLEN-1:0] imm_i,
    input wire [XLEN-1:0] pc_plus_4_i,
    input wire signed [XLEN-1:0] alu_result_i,

    output reg signed [XLEN-1:0] rd_din_o
);

always @(*) begin

    case (mem_to_reg_i)
        2'b00:
            rd_din_o = alu_result_i;
        2'b01:
            rd_din_o = dmem_rd_data_i;
        2'b10:
            rd_din_o = pc_plus_4_i;
        2'b11:
            rd_din_o = imm_i;

        default:
            rd_din_o = 32'hdeadbeef;

    endcase
end

endmodule