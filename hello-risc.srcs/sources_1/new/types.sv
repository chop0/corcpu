package types;
typedef enum logic [1:0] {
        R_FORMAT, I_FORMAT, S_FORMAT, B_FORMAT
} e_instruction_format;

typedef enum {
    ALU, BU, LSU
} e_functional_unit;
endpackage