module alu #(parameter int DATA_WIDTH = 32)(
    input  logic [4:0]            alu_control,
    input  logic [DATA_WIDTH-1:0] rs1_data,
    input  logic [DATA_WIDTH-1:0] rs2_data,
    output logic [DATA_WIDTH-1:0] alu_out,
    output logic                  zero         // branch condition true
);

    // 16 Operations Encoding
    localparam logic [4:0] ALU_ADD   = 5'b00000;
    localparam logic [4:0] ALU_SUB   = 5'b00001;
    localparam logic [4:0] ALU_SLL   = 5'b00010;
    localparam logic [4:0] ALU_SLT   = 5'b00011;
    localparam logic [4:0] ALU_SLTU  = 5'b00100;
    localparam logic [4:0] ALU_XOR   = 5'b00101;
    localparam logic [4:0] ALU_SRL   = 5'b00110;
    localparam logic [4:0] ALU_SRA   = 5'b00111;
    localparam logic [4:0] ALU_OR    = 5'b01000;
    localparam logic [4:0] ALU_AND   = 5'b01001;
    localparam logic [4:0] ALU_BEQ   = 5'b01010;
    localparam logic [4:0] ALU_BNE   = 5'b01011;
    localparam logic [4:0] ALU_BLT   = 5'b01100;
    localparam logic [4:0] ALU_BGE   = 5'b01101;
    localparam logic [4:0] ALU_BLTU  = 5'b01110;
    localparam logic [4:0] ALU_BGEU  = 5'b01111;
    localparam logic [4:0] ALU_PASSB = 5'b10000; // For LUI (passes imm_out)

    always_comb begin
        alu_out = '0;
        zero    = 1'b0;

        case (alu_control)
            // Arithmetic & Logical
            ALU_ADD:   alu_out = rs1_data + rs2_data;
            ALU_SUB:   alu_out = rs1_data - rs2_data;
            ALU_SLL:   alu_out = rs1_data << rs2_data[4:0];
            ALU_SLT:   alu_out = ($signed(rs1_data) < $signed(rs2_data)) ? 32'd1 : 32'd0;
            ALU_SLTU:  alu_out = (rs1_data < rs2_data) ? 32'd1 : 32'd0;
            ALU_XOR:   alu_out = rs1_data ^ rs2_data;
            ALU_SRL:   alu_out = rs1_data >> rs2_data[4:0];
            ALU_SRA:   alu_out = $signed(rs1_data) >>> rs2_data[4:0];
            ALU_OR:    alu_out = rs1_data | rs2_data;
            ALU_AND:   alu_out = rs1_data & rs2_data;
            ALU_PASSB: alu_out = rs2_data;

            // Branch Comparisons (zero = 1 when branch condition is true)
            ALU_BEQ:   zero = (rs1_data == rs2_data);
            ALU_BNE:   zero = (rs1_data != rs2_data);
            ALU_BLT:   zero = ($signed(rs1_data) < $signed(rs2_data));
            ALU_BGE:   zero = ($signed(rs1_data) >= $signed(rs2_data));
            ALU_BLTU:  zero = (rs1_data < rs2_data);
            ALU_BGEU:  zero = (rs1_data >= rs2_data);

            default: begin
                alu_out = '0;
                zero    = 1'b0;
            end
        endcase
    end

endmodule
