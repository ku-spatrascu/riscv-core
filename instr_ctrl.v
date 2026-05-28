`timescale 1ns/1ps
// again could change to repsonse/request (true)
module instr_ctrl (
    input  wire        clk_i,
    input  wire        rst_ni,

    input  wire        stall_i,
    input  wire        flush_i,

    input  wire        pc_write_i,
    input  wire [31:0] pc_if_i,
    input  wire [31:0] imem_rd_data_i,

    output reg  [31:0] pc_id_o,
    output reg  [31:0] instr_id_o,
    output reg         instr_valid_o
);

    // PC requested last cycle - imem_rd_data_i belongs to this PC.
    reg [31:0] requested_pc_q; // store requested pc
    reg        request_valid_q; // is the requested pc needed/valid

    // One-entry buffer for an instruction that returns while there is stall.
    // needs to hold for extra cycle basically
    reg [31:0] hold_pc_q;
    reg [31:0] hold_instr_q;
    reg        hold_valid_q;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            requested_pc_q  <= 32'b0;
            request_valid_q <= 1'b0;

            pc_id_o         <= 32'b0;
            instr_id_o      <= 32'b0;
            instr_valid_o   <= 1'b0;

            hold_pc_q       <= 32'b0;
            hold_instr_q    <= 32'b0;
            hold_valid_q    <= 1'b0;
        end

        else if (flush_i) begin
            requested_pc_q  <= 32'b0;
            request_valid_q <= 1'b0;

            pc_id_o         <= 32'b0;
            instr_id_o      <= 32'b0;
            instr_valid_o   <= 1'b0;

            hold_pc_q       <= 32'b0;
            hold_instr_q    <= 32'b0;
            hold_valid_q    <= 1'b0;
        end

        else begin

            if (stall_i) begin
                if (request_valid_q && !hold_valid_q) begin
                    hold_pc_q    <= requested_pc_q;
                    hold_instr_q <= imem_rd_data_i;
                    hold_valid_q <= 1'b1;
                end

                // do not update when stalled
                request_valid_q <= 1'b0; 
            end
            else if (hold_valid_q) begin // start with held values
                pc_id_o       <= hold_pc_q;
                instr_id_o    <= hold_instr_q;
                instr_valid_o <= 1'b1;

                hold_valid_q  <= 1'b0;

                if (pc_write_i) begin
                    requested_pc_q  <= pc_if_i;
                    request_valid_q <= 1'b1;
                end else begin
                    request_valid_q <= 1'b0;
                end
            end
            else begin 
                pc_id_o       <= requested_pc_q;
                instr_id_o    <= imem_rd_data_i;
                instr_valid_o <= request_valid_q;

                if (pc_write_i) begin
                    requested_pc_q  <= pc_if_i;
                    request_valid_q <= 1'b1;
                end else begin
                    request_valid_q <= 1'b0;
                end
            end
        end
    end

endmodule