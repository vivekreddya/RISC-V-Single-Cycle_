module single_cycle_riscv (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,  // from instruction memory (addressed by `address`)
    input  logic [31:0] mem_out,      // from data memory
    output logic [31:0] rs2_data,     // store data
    output logic [31:0] alu_out,      // data memory address
    output logic        mem_write,
    output logic        mem_read,
    output logic [2:0]  fn3,          // load / store width
    output logic [6:0]  opcode,
    output logic [31:0] address       // PC
);

    // IF stage wires
    logic [31:0] pc_new;
    logic        and_out_ex;
    logic [31:0] pc_ex_out;

    // ID stage wires
    logic [31:0] rs1_data;
    logic [31:0] imm_out;
    logic [6:0]  imm11_5;
    logic        fn7_5;
    logic [2:0]  aluop;
    logic [1:0]  memtoreg;
    logic        branch;
    logic        alu_src;
    logic        mux_inp;

    // WB stage wire
    logic [31:0] wb_data;

    // 1. Instruction Fetch (IF) Stage
    if_stage u_if_stage (
        .clk              (clk),
        .reset            (reset),
        .stall            (stall),
        .and_out          (and_out_ex),
        .pc_signed_offset (pc_ex_out),
        .address          (address),
        .pc_new           (pc_new)
    );

    // 2. Instruction Decode (ID) Stage
    id_stage u_id_stage (
        .clk          (clk),
        .reset        (reset),
        .stall        (stall),
        .instruction  (instruction),
        .wb_data      (wb_data),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .imm_out      (imm_out),
        .opcode_out_d (opcode),
        .imm11_5      (imm11_5),
        .fn3_out_d    (fn3),
        .fn7_5        (fn7_5),
        .aluop        (aluop),
        .memtoreg     (memtoreg),
        .branch       (branch),
        .mem_write    (mem_write),
        .mem_read     (mem_read),
        .alusrc       (alu_src),
        .mux_inp      (mux_inp)
    );

    // 3. Execute (EX) Stage
    ex_stage u_ex_stage (
        .rs1_data   (rs1_data),
        .rs2_data   (rs2_data),
        .imm_out    (imm_out),
        .address    (address),
        .branch     (branch),
        .alu_src    (alu_src),
        .fn7_5      (fn7_5),
        .mux_inp    (mux_inp),
        .fn3        (fn3),
        .imm11_5    (imm11_5),
        .aluop      (aluop),
        .opcode     (opcode),
        .and_out_ex (and_out_ex),
        .alu_out    (alu_out),
        .pc_ex_out  (pc_ex_out)
    );

    // 4. Write Back (WB) Stage
    wb_stage u_wb_stage (
        .alu_out      (alu_out),
        .mem_data_out (mem_out),
        .pc_plus_4    (pc_new),
        .memtoreg     (memtoreg),
        .wb_data      (wb_data)
    );

endmodule
