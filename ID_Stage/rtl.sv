module id_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] wb_data,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] imm_out,
    output logic [6:0]  opcode_out_d,
    output logic [6:0]  imm11_5,
    output logic [2:0]  fn3_out_d,
    output logic        fn7_5,
    output logic [2:0]  aluop,
    output logic [1:0]  memtoreg,
    output logic        branch,
    output logic        mem_write,
    output logic        mem_read,
    output logic        alu_src,
    output logic        mux_inp
);

    // Internal signals
    logic [4:0] rs1_sel;
    logic [4:0] rs2_sel;
    logic [4:0] rd_sel;

    logic [11:0] imm_input;
    logic [19:0] imm_input_uj;

    logic reg_write;
    logic reg_write_final;

    // 1. Instruction Decoder
    decoder dec (
        .instruction(instruction),
        .rs1(rs1_sel),
        .rs2(rs2_sel),
        .rd(rd_sel),
        .opcode(opcode_out_d),
        .imm11_5(imm11_5),
        .fn3(fn3_out_d),
        .imm(imm_input),
        .imm_u_j(imm_input_uj),
        .fn7_5(fn7_5)
    );

    // 2. Immediate Generator
    imm_generator imm_gen (
        .imm_input(imm_input),
        .fn3(fn3_out_d),
        .opcode(opcode_out_d),
        .imm_input_uj(imm_input_uj),
        .imm_output(imm_out)
    );

    // 3. Register File
    assign reg_write_final = reg_write && !stall;

    register_file rf (
        .rs1_sel(rs1_sel),
        .rs2_sel(rs2_sel),
        .reg_write(reg_write_final),
        .clk(clk),
        .reset(reset),
        .wb_data(wb_data),
        .rd_sel(rd_sel),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // 4. Main Control
    main_control control (
        .opcode(opcode_out_d),
        .fn3(fn3_out_d),
        .memtoreg(memtoreg),
        .branch(branch),
        .mux_inp(mux_inp),
        .memread(mem_read),
        .memwrite(mem_write),
        .alusrc(alu_src),
        .reg_write(reg_write),
        .aluop(aluop)
    );

endmodule
