module ALU
(
input [31:0]rs1_data,
input [31:0]rs2_data,
input [4:0]shamt,
input [2:0]funct3,
input subright,
output[31:0]ALU_result
);
wire [31:0] rb = {32{subright}}^rs2_data;
wire [31:0] result;
wire [31:0] sra_result;

math umath(.funct3(funct3),
            .rs1(rs1_data),
			.rb(rb),
			.shamt(shamt),
			.cin(subright),
			.result(result)
);

wire [5:0] shift_n;
assign shift_n =  6'd32-shamt;
assign sra_result = ({32{rs1_data[31]}}<<shift_n) | result;//算术右移 
assign ALU_result =  subright?sra_result:result;
endmodule
