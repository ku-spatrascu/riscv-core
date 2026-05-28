`timescale 1ns/1ps

module lsu (
    input  wire        clk_i,
    input  wire        rst_ni,

    // ex stage inputs
    input  wire signed [31:0] alu_result_i,
    input  wire signed [31:0] rs2_dout_i,
    input  wire               mem_write_i,
    input  wire               mem_read_i,

    input  wire [4:0]         rd_addr_i,
    input  wire               reg_write_i,
    input  wire [1:0]         mem_to_reg_i,
    input  wire [31:0]        imm_i,
    input  wire [31:0]        pc_i,

    // Data memory signals
    input  wire signed [31:0] dmem_rd_data_i,

    output wire signed [31:0] dmem_addr_o,
    output wire signed [31:0] dmem_wr_data_o,
    output wire               dmem_write_o,
    output wire               dmem_read_o,

    output wire               lsu_busy_o, // for top level core

    // Final output going to ex/wb pipeline
    output reg  [1:0]         load_mem_to_reg_o,
    output reg  [31:0]        load_alu_result_o,
    output reg  [31:0]        load_imm_o,
    output reg  [4:0]         load_rd_o,
    output reg                load_reg_write_o,
    output reg  [31:0]        load_pc_o,
    output reg  [31:0]        load_dmem_o
);

    reg        load_pending_q;
    reg [4:0]  load_rd_q;
    reg        load_reg_write_q;
    reg [1:0]  load_mem_to_reg_q;
    reg [31:0] load_alu_result_q;
    reg [31:0] load_imm_q;
    reg [31:0] load_pc_q;

    wire load_req;

    assign load_req   = mem_read_i && !load_pending_q;
    assign lsu_busy_o = load_req || load_pending_q;

    assign dmem_addr_o    = alu_result_i;
    assign dmem_wr_data_o = rs2_dout_i;

    // this is for a fixed one-cycle design

    assign dmem_read_o  = load_req;
    assign dmem_write_o = mem_write_i;


    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            load_pending_q    <= 1'b0;
            load_rd_q         <= 5'b0;
            load_reg_write_q  <= 1'b0;
            load_mem_to_reg_q <= 2'b00;
            load_alu_result_q <= 32'b0;
            load_imm_q        <= 32'b0;
            load_pc_q         <= 32'b0;
        end else begin
            if (load_req) begin
                load_pending_q    <= 1'b1;
                load_rd_q         <= rd_addr_i;
                load_reg_write_q  <= reg_write_i;
                load_mem_to_reg_q <= mem_to_reg_i;
                load_alu_result_q <= alu_result_i;
                load_imm_q        <= imm_i;
                load_pc_q         <= pc_i;
            end else begin
                load_pending_q <= 1'b0;
            end
        end
    end

    always @(*) begin
        // default values
        load_mem_to_reg_o = mem_to_reg_i;
        load_alu_result_o = alu_result_i;
        load_imm_o        = imm_i;
        load_rd_o         = rd_addr_i;
        load_reg_write_o  = reg_write_i;
        load_pc_o         = pc_i;
        load_dmem_o       = dmem_rd_data_i;

        // Load request just issued:
        // The load data is not ready yet - bubble
        if (load_req) begin
            load_mem_to_reg_o = 2'b00;
            load_rd_o         = 5'b0;
            load_reg_write_o  = 1'b0;
        end


        // Use saved load metadata and the returned memory data.
        if (load_pending_q) begin
            load_mem_to_reg_o = load_mem_to_reg_q;
            load_alu_result_o = load_alu_result_q;
            load_imm_o        = load_imm_q;
            load_rd_o         = load_rd_q;
            load_reg_write_o  = load_reg_write_q;
            load_pc_o         = load_pc_q;
            load_dmem_o       = dmem_rd_data_i;
        end
    end

endmodule


// NOT SIGNED - PLEASE CHANGE



