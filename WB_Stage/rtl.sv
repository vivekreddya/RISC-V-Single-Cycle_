module wb_stage (
    input  logic [31:0] alu_out,
    input  logic [31:0] mem_data_out,
    input  logic [31:0] pc_plus_4,
    input  logic [1:0]  memtoreg,
    output logic [31:0] wb_data
);

    always_comb begin
        unique case (memtoreg)
            2'b00:   wb_data = alu_out;
            2'b01:   wb_data = mem_data_out;
            2'b10:   wb_data = pc_plus_4;
            default: wb_data = alu_out;
        endcase
    end

endmodule
