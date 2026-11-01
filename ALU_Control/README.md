# ALU Control

Design the ALU control decoder. It turns the operation class from Main Control, plus the instruction's `fn3` / `fn7_5` / `imm11_5` bits, into the ALU's 5-bit `alu_control` code.

### Module Specification

```SystemVerilog
module alu_control (
    input  logic [2:0]  alu_op,
    input  logic [2:0]  fn3,
    input  logic [6:0]  imm11_5,
    input  logic        fn7_5,
    output logic [4:0]  control_out
);

    always_comb begin
        control_out = 5'b00000;
        case (alu_op)
            3'b000: control_out = 5'b00000; // Addition (loads, stores, JALR)
            3'b001: begin                   // Branch comparisons
                case (fn3)
                    3'b000: control_out = 5'b01010; // BEQ
                    3'b001: control_out = 5'b01011; // BNE
                    3'b100: control_out = 5'b01100; // BLT
                    3'b101: control_out = 5'b01101; // BGE
                    3'b110: control_out = 5'b01110; // BLTU
                    3'b111: control_out = 5'b01111; // BGEU
                    default: control_out = 5'b00000;
                endcase
            end
            3'b010: begin                   // R-type / I-type ALU
                case (fn3)
                    3'b000: control_out = (fn7_5 && (alu_op == 3'b010)) ? 5'b00001 : 5'b00000; // SUB / ADD
                    3'b111: control_out = 5'b00010; // AND
                    3'b110: control_out = 5'b00011; // OR
                    3'b100: control_out = 5'b00100; // XOR
                    3'b001: control_out = 5'b00101; // SLL
                    3'b101: control_out = fn7_5 ? 5'b00111 : 5'b00110; // SRA / SRL
                    3'b010: control_out = 5'b01000; // SLT
                    3'b011: control_out = 5'b01001; // SLTU
                    default: control_out = 5'b00000;
                endcase
            end
            default: control_out = 5'b00000;
        endcase
    end
endmodule
```

### Working

| alu_op | Class | control_out |
|---|---|---|
| `000` | R-type | by `fn3`: `000` ADD (SUB if `fn7_5`), `001` SLL, `010` SLT, `011` SLTU, `100` XOR, `101` SRL (SRA if `fn7_5`), `110` OR, `111` AND |
| `001` | I-type ALU | same `fn3` mapping, no SUB; `fn3 = 101` is SRAI if `imm11_5 == 7'h20`, else SRLI |
| `010` | Load | ADD |
| `011` | Store | ADD |
| `100` | Branch | by `fn3`: `000` BEQ, `001` BNE, `100` BLT, `101` BGE, `110` BLTU, `111` BGEU (other `fn3`: ADD) |
| `110` | JAL / LUI | ADD |
| other | - | ADD |

The output codes are the ALU's control table (`00000` ADD, `00001` SUB, `00010` XOR, `00011` OR, `00100` AND, `00101` SLL, `00110` SRL, `00111` SRA, `01000` SLT, `01001` SLTU, `01010`-`01111` BEQ BNE BLT BGE BLTU BGEU).

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
