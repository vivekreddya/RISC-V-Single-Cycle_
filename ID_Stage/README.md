# ID Stage (Instruction Decode)

Design the decode stage by connecting the **Decoder**, **Immediate Generator**, **Register File** and **Main Control**.

### Module Specification

```SystemVerilog
module id_stage(
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] wb_data,            // data to write back (from WB stage)
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
    output logic        alusrc,
    output logic        mux_inp
);

    logic [4:0]  rs1, rs2, rd;
    logic [11:0] imm;
    logic [19:0] imm_uj;
    logic        reg_write_ctrl;

    decoder dec (
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .opcode(opcode_out_d),
        .imm11_5(imm11_5),
        .fn3(fn3_out_d),
        .imm(imm),
        .imm_uj(imm_uj),
        .fn7_5(fn7_5)
    );

    main_control ctrl (
        .opcode(opcode_out_d),
        .fn3(fn3_out_d),
        .memtoreg(memtoreg),
        .branch(branch),
        .mux_inp(mux_inp),
        .memread(mem_read),
        .memwrite(mem_write),
        .alusrc(alusrc),
        .reg_write(reg_write_ctrl),
        .aluop(aluop)
    );

    register_file rf (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write_ctrl & ~stall),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wb_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    imm_generator imm_gen (
        .imm_input(imm),
        .fn3(fn3_out_d),
        .opcode(opcode_out_d),
        .imm_input_uj(imm_uj),
        .imm_output(imm_out)
    );

endmodule
```

### Working

- `instruction` goes through the **Decoder**; its `imm` / `imm_uj` / `fn3` / `opcode` feed the **Immediate Generator** (`imm_out`).
- The decoder's `rs1`, `rs2` select the Register File read ports; its `rd` is the write address.
- **Main Control** produces `branch`, `memtoreg`, `aluop`, `mem_write`, `alu_src`, `mem_read`, `mux_inp` and the register write enable.
- The register write enable is gated: **`reg_write && !stall`** (no register is written while stalled).
- `opcode_out_d`, `fn3_out_d`, `fn7_5`, `imm11_5` are the decoder's outputs, passed on.

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
