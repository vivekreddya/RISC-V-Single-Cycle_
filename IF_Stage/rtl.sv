module if_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic        and_out,
    input  logic [31:0] pc_signed_offset,

    output logic [31:0] address,
    output logic [31:0] pc_new
);

    // PC + 4 is always available
    always_comb begin
        pc_new = address + 32'd4;
    end

    // Program Counter register
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            address <= 32'h8000_0000;
        else if (!stall) begin
            if (and_out)
                address <= pc_signed_offset;
            else
                address <= pc_new;
        end
    end

endmodule
// CI trigger after RISC-n-Roll-CI configuration
