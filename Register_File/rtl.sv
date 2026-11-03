module register_file (
    input  logic [4:0]  rs1_sel,
    input  logic [4:0]  rs2_sel,
    input  logic        reg_write,
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] wb_data,
    input  logic [4:0]  rd_sel,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    logic [31:0] registers [0:31];

    integer i;

    // Asynchronous active-high reset and register write
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
        else if (reg_write && (rd_sel != 5'd0)) begin
            registers[rd_sel] <= wb_data;
        end
    end

    // Combinational read ports
    always_comb begin
        if (rs1_sel == 5'd0)
            rs1_data = 32'b0;
        else
            rs1_data = registers[rs1_sel];

        if (rs2_sel == 5'd0)
            rs2_data = 32'b0;
        else
            rs2_data = registers[rs2_sel];
    end

endmodule
