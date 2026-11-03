module imm_generator (
    input  logic [11:0] imm_input,
    input  logic [2:0]  fn3,
    input  logic [6:0]  opcode,
    input  logic [19:0] imm_input_uj,
    output logic [31:0] imm_output
);

    always_comb begin

        case (opcode)

            // Branch
            7'b1100011:
                imm_output = {{19{imm_input[11]}}, imm_input, 1'b0};

            // JAL
            7'b1101111:
                imm_output = {{11{imm_input_uj[19]}}, imm_input_uj, 1'b0};

            // LUI and AUIPC
            7'b0110111,
            7'b0010111:
                imm_output = {imm_input_uj, 12'b0};

            // JALR
            7'b1100111:
                imm_output = {{20{imm_input[11]}}, imm_input};

            // I-type ALU
            7'b0010011: begin
                if (fn3 == 3'b001 || fn3 == 3'b101)
                    imm_output = {27'b0, imm_input[4:0]};
                else
                    imm_output = {{20{imm_input[11]}}, imm_input};
            end

            // Everything else
            default:
                imm_output = {{20{imm_input[11]}}, imm_input};

        endcase

    end

endmodule
