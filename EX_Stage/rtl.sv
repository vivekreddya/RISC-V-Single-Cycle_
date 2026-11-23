module ex_stage (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm_out,
    input  logic [31:0] address,      // current PC
    input  logic        branch,
    input  logic        alu_src,      // 0 = rs2_data, 1 = imm_out
    input  logic        fn7_5,
    input  logic        mux_inp,      // 1 = JALR
    input  logic [2:0]  fn3,
    input  logic [6:0]  imm11_5,
    input  logic [2:0]  aluop,
    input  logic [6:0]  opcode,
    output logic        and_out_ex,   // branch / jump taken
    output logic [31:0] alu_out,
    output logic [31:0] pc_ex_out     // branch / jump target
);

    logic [4:0]  alu_ctrl;
    logic [31:0] alu_in1;
    logic [31:0] alu_in2;
    logic        zero;
    logic        is_jump;

    // Operand A selection: AUIPC (7'b0010111) adds imm_out to PC, otherwise rs1_data
    assign alu_in1 = (opcode == 7'b0010111) ? address : rs1_data;

    // Operand B selection: 0 = rs2_data, 1 = imm_out
    assign alu_in2 = alu_src ? imm_out : rs2_data;

    // Instantiate ALU Control
    alu_control u_alu_control (
        .alu_op      (aluop),
        .fn3         (fn3),
        .imm11_5     (imm11_5),
        .fn7_5       (fn7_5),
        .control_out (alu_ctrl)
    );

    // Instantiate ALU
    alu #(.DATA_WIDTH(32)) u_alu (
        .alu_control (alu_ctrl),
        .rs1_data    (alu_in1),
        .rs2_data    (alu_in2),
        .alu_out     (alu_out),
        .zero        (zero)
    );

    // Unconditional jumps: JAL (1101111) or JALR (1100111)
    assign is_jump = (opcode == 7'b1101111) || (opcode == 7'b1100111);

    // Branch / Jump taken decision
    assign and_out_ex = (branch && zero) || is_jump;

    // Target address calculation:
    // JALR (mux_inp = 1) uses (rs1 + imm) with LSB zeroed; Branch/JAL uses PC + imm
    assign pc_ex_out = mux_inp ? {alu_out[31:1], 1'b0} : (address + imm_out);

endmodule
