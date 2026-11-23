module alu_control (
    input  logic [2:0] alu_op,
    input  logic [2:0] fn3,
    input  logic [6:0] imm11_5,
    input  logic       fn7_5,
    output logic [4:0] control_out
);

    // Matching ALU operation codes
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
    localparam logic [4:0] ALU_PASSB = 5'b10000;

    always_comb begin
        case (alu_op)
            // Load, Store, JALR -> Address addition
            3'b000: control_out = ALU_ADD;

            // Branch instructions
            3'b001: begin
                case (fn3)
                    3'b000:  control_out = ALU_BEQ;
                    3'b001:  control_out = ALU_BNE;
                    3'b100:  control_out = ALU_BLT;
                    3'b101:  control_out = ALU_BGE;
                    3'b110:  control_out = ALU_BLTU;
                    3'b111:  control_out = ALU_BGEU;
                    default: control_out = ALU_BEQ;
                endcase
            end

            // R-Type ALU instructions
            3'b010: begin
                case (fn3)
                    3'b000:  control_out = fn7_5 ? ALU_SUB : ALU_ADD;
                    3'b001:  control_out = ALU_SLL;
                    3'b010:  control_out = ALU_SLT;
                    3'b011:  control_out = ALU_SLTU;
                    3'b100:  control_out = ALU_XOR;
                    3'b101:  control_out = fn7_5 ? ALU_SRA : ALU_SRL;
                    3'b110:  control_out = ALU_OR;
                    3'b111:  control_out = ALU_AND;
                    default: control_out = ALU_ADD;
                endcase
            end

            // I-Type ALU instructions (no SUBI in RV32I, only SRAI uses fn7_5)
            3'b011: begin
                case (fn3)
                    3'b000:  control_out = ALU_ADD;
                    3'b001:  control_out = ALU_SLL;
                    3'b010:  control_out = ALU_SLT;
                    3'b011:  control_out = ALU_SLTU;
                    3'b100:  control_out = ALU_XOR;
                    3'b101:  control_out = fn7_5 ? ALU_SRA : ALU_SRL;
                    3'b110:  control_out = ALU_OR;
                    3'b111:  control_out = ALU_AND;
                    default: control_out = ALU_ADD;
                endcase
            end

            // LUI -> Pass immediate directly through ALU
            3'b100: control_out = ALU_PASSB;

            default: control_out = ALU_ADD;
        endcase
    end

endmodule
