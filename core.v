`timescale 1ns/1ps

// I had chatGPT restyle the file and adjust the naming of the internal signals so it is easier to read (no logic changes),
// but if you want to add more comments let me know
// or you can always call or text me with any questions 
// I'll mention any concerns or thoughts I have in the GitHub

module core (
    input  wire                 clk_i,
    input  wire                 rst_ni,

    output wire [31:0]          imem_addr_o,
    input  wire signed [31:0]   imem_rd_data_i,
    output wire                 imem_read_o,

    output wire signed [31:0]   dmem_addr_o,
    output wire signed [31:0]   dmem_wr_data_o,
    input  wire signed [31:0]   dmem_rd_data_i,
    output wire                 dmem_write_o,
    output wire                 dmem_read_o
);

    wire stall;
    wire flush;
    wire flush_ex;
    
    wire pc_write;
    wire if_id_write;
    wire id_ex_write;
    wire branch_taken;
    wire [31:0] pc_branch;
    wire is_load_hazard;    // load hazard detection signal

    // stall/flush logic
    assign pc_write    = ~stall;
    assign if_id_write = ~stall;
    assign id_ex_write = ~stall;

    assign flush       = branch_taken;
    assign flush_ex    = flush || stall; // for the id/ex pipeline, with flush on a flush or a stall



    wire [31:0] pc_curr_if;
    wire [31:0] pc_next;
    
    assign pc_next     = pc_curr_if + 32'd4;
    assign imem_addr_o = pc_curr_if;
    assign imem_read_o = 1'b1;

    fetch instr_f (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .pc_write_i     (pc_write),
        .pc_next_i      (pc_next),
        .branch_taken_i (branch_taken),
        .pc_branch_i    (pc_branch),
        
        .pc_curr_o      (pc_curr_if)
    );


    wire [31:0] pc_curr_id;
    wire [31:0] instr_id;
    wire [31:0] imem_data;
    
    assign imem_data = imem_rd_data_i;

    if_id_pipeline if_id (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .flush_i        (flush),
        .if_id_write_i  (if_id_write),
        
        .pc_curr_i      (pc_curr_if),
        .instr_i        (imem_data),
        
        .pc_curr_o      (pc_curr_id),
        .instr_o        (instr_id)
    );


    // signals recieved from the wb stage and/or the ex/wb pipeline
    wire [4:0]  rd_addr_wb;
    wire        reg_write_wb;
    wire [31:0] rd_data_wb;

    wire [4:0]  rd_addr_ex;   // receieved from ex stage (for hazarding)

    wire signed [31:0] imm_id;
    wire [2:0]  funct3_id;
    wire [6:0]  funct7_id;
    wire [6:0]  opcode_id;
    wire signed [31:0] rs1_data_id;
    wire signed [31:0] rs2_data_id;
    wire [4:0]  rs1_addr_id;
    wire [4:0]  rs2_addr_id;
    wire [4:0]  rd_addr_id;
    
    wire        mem_read_id;
    wire        mem_write_id;
    wire [1:0]  mem_to_reg_id;
    wire        reg_write_id;
    wire        is_load_id_pipe; // sent to id/ex pipeline

    core_id_stage core_ID (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .instr_i            (instr_id),

        .rd_din_i           (rd_data_wb),
        .wb_rd_i            (rd_addr_wb),
        .wb_reg_write_i     (reg_write_wb),

        // for the hazard unit 
        .rd_id_ex_i         (rd_addr_ex),
        .is_load_i          (is_load_hazard), 
        .is_load_pipeline_o (is_load_id_pipe),
        .stall_o            (stall),

        .imm_o              (imm_id),
        .funct3_o           (funct3_id),
        .funct7_o           (funct7_id),
        .opcode_o           (opcode_id),
        .rs1_dout_o         (rs1_data_id),
        .rs2_dout_o         (rs2_data_id),
        .rs1_o              (rs1_addr_id),
        .rs2_o              (rs2_addr_id),
        .mem_read_o         (mem_read_id),
        .mem_write_o        (mem_write_id),
        .mem_to_reg_o       (mem_to_reg_id),
        .rd_o               (rd_addr_id),
        .reg_write_o        (reg_write_id)
    );


    wire [31:0] pc_curr_ex;
    wire        reg_write_ex;
    wire [4:0]  rs1_addr_fwd; // for forwarding unit
    wire [4:0]  rs2_addr_fwd; // for forwarding unit
    
    wire signed [31:0] imm_ex;
    wire [2:0]  funct3_ex;
    wire [6:0]  funct7_ex;
    wire [6:0]  opcode_ex;
    wire signed [31:0] rs1_data_ex;
    wire signed [31:0] rs2_data_ex;
    
    wire        mem_read_ex;
    wire        mem_write_ex;
    wire [1:0]  mem_to_reg_ex;

    id_ex_pipeline id_ex (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .flush_i        (flush_ex),
        .id_ex_write_i  (id_ex_write),

        .rd_i           (rd_addr_id),
        .reg_write_i    (reg_write_id),
        .rs1_i          (rs1_addr_id),
        .rs2_i          (rs2_addr_id),
        .is_load_i      (is_load_id_pipe),
        .imm_i          (imm_id),
        .funct3_i       (funct3_id),
        .funct7_i       (funct7_id),
        .opcode_i       (opcode_id),
        .rs1_dout_i     (rs1_data_id),
        .rs2_dout_i     (rs2_data_id),
        .mem_read_i     (mem_read_id),
        .mem_write_i    (mem_write_id),
        .mem_to_reg_i   (mem_to_reg_id),
        .pc_curr_i      (pc_curr_id),

        .rd_o           (rd_addr_ex),
        .reg_write_o    (reg_write_ex),
        .rs1_o          (rs1_addr_fwd),
        .rs2_o          (rs2_addr_fwd),
        .is_load_o      (is_load_hazard), // sent back to id stage
        .pc_curr_o      (pc_curr_ex),
        .opcode_o       (opcode_ex),
        .funct3_o       (funct3_ex),
        .funct7_o       (funct7_ex),
        .rs1_dout_o     (rs1_data_ex),
        .rs2_dout_o     (rs2_data_ex),
        .imm_o          (imm_ex),
        .mem_read_o     (mem_read_ex),
        .mem_write_o    (mem_write_ex),
        .mem_to_reg_o   (mem_to_reg_ex)
    );

    wire        alu_zero;
    wire        alu_lt;
    wire signed [31:0] alu_result_ex;
    
    wire        fwd_a_sel;
    wire        fwd_b_sel;

    branch_unit branch_u (
        .opcode_i       (opcode_ex),
        .funct3_i       (funct3_ex),
        .alu_zero_i     (alu_zero),
        .pc_i           (pc_curr_ex),
        .rs1_dout_i     (rs1_data_ex),
        .imm_i          (imm_ex),
        .lt_flag_i      (alu_lt),
        
        .branch_taken_o (branch_taken),
        .pc_branch_o    (pc_branch)
    );

    forwarding_unit for_u (
        .rs1_i          (rs1_addr_fwd),
        .rs2_i          (rs2_addr_fwd),
        .wb_reg_write_i (reg_write_wb),
        .wb_rd_i        (rd_addr_wb),
        
        .forward_a_o    (fwd_a_sel),
        .forward_b_o    (fwd_b_sel)
    );

    core_ex_stage core_EX (
        .opcode_i       (opcode_ex),
        .funct3_i       (funct3_ex),
        .funct7_i       (funct7_ex),
        .rs1_dout_i     (rs1_data_ex),
        .rs2_dout_i     (rs2_data_ex),
        .imm_i          (imm_ex),
        .pc_i           (pc_curr_ex),
        
        // for forwarding
        .forward_a_i    (fwd_a_sel),
        .forward_b_i    (fwd_b_sel), 
        .wb_data        (rd_data_wb),

        .lt_flag_o      (alu_lt),
        .zero_o         (alu_zero),
        .alu_result_o   (alu_result_ex)
    );


    wire signed [31:0] dmem_addr_int;
    wire signed [31:0] dmem_wr_data_int;
    wire               dmem_write_int;
    wire               dmem_read_int;
    wire signed [31:0] dmem_data_from_lsu;

    assign dmem_read_o    = dmem_read_int;
    assign dmem_addr_o    = dmem_addr_int; 
    assign dmem_wr_data_o = dmem_wr_data_int;
    assign dmem_write_o   = dmem_write_int; 

    lsu lsu_core (
        .alu_result_i   (alu_result_ex),
        .rs2_dout_i     (rs2_data_ex),
        .dmem_rd_data_i (dmem_rd_data_i),
        .mem_write_i    (mem_write_ex),
        .mem_read_i     (mem_read_ex),
    
        .dmem_addr_o    (dmem_addr_int), 
        .dmem_wr_data_o (dmem_wr_data_int),
        .dmem_write_o   (dmem_write_int),
        .dmem_read_o    (dmem_read_int),

        .dmem_rd_data_o (dmem_data_from_lsu)
    );


    wire [1:0]          mem_to_reg_wb;
    wire signed [31:0]  alu_result_wb;
    wire signed [31:0]  imm_wb;
    wire [31:0]         pc_curr_wb;

    ex_wb_pipeline ex_wb(
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),

        .mem_to_reg_i   (mem_to_reg_ex),
        .alu_result_i   (alu_result_ex),
        .imm_i          (imm_ex),
        .rd_i           (rd_addr_ex),
        .reg_write_i    (reg_write_ex),
        .pc_curr_i      (pc_curr_ex),

        .mem_to_reg_o   (mem_to_reg_wb),
        .alu_result_o   (alu_result_wb),
        .imm_o          (imm_wb),
        .rd_o           (rd_addr_wb),
        .reg_write_o    (reg_write_wb),
        .pc_curr_o      (pc_curr_wb)
    );

    core_wb_stage core_WB (
        .alu_result_i   (alu_result_wb),
        .mem_to_reg_i   (mem_to_reg_wb),
        .dmem_rd_data_i (dmem_data_from_lsu),
        .pc_plus_4_i    (pc_curr_wb),
        .imm_i          (imm_wb),

        .rd_din_o       (rd_data_wb) // sent back to id stage
    );

endmodule