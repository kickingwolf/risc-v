module BIT(
         input [31:0] BIT_rs1_data,
			input [31:0] BIT_rd_data,
			input [4:0] BIT_imm2_rs2,
			input [4:0] BIT_imm3_rs2,
			input [2:0] BIT_funct3,
			output reg [31:0]BIT_result
);


 
 

wire 		[31:0]extract_stage = (BIT_rs1_data & ((1<<BIT_imm3_rs2)-1)<<BIT_imm2_rs2);
wire 		[6:0]signed_counter= 6'd32-BIT_imm2_rs2;
wire	 	[31:0]extract_unsigned = extract_stage>>BIT_imm2_rs2;
wire	 	[31:0]extract_signed = ({32{extract_stage[31]}}<<signed_counter)| extract_unsigned;

wire		 [5:0]insert_counter=5'd31-BIT_imm3_rs2;
wire		[31:0]insert=(BIT_rd_data & ~( ((1<<BIT_imm3_rs2)-1)<<BIT_imm2_rs2)) | ((({32{1'b1}}>>insert_counter)|BIT_rs1_data)<<BIT_imm2_rs2);

wire 		[31:0]bclr= BIT_rs1_data & ~(((1<<(BIT_imm3_rs2+1))-1)<<BIT_imm2_rs2);

wire 		[31:0]bset= BIT_rs1_data | ~(((1<<(BIT_imm3_rs2+1))-1)<<BIT_imm2_rs2);



always@(*)
begin

    case(BIT_funct3)
	  3'b000: BIT_result=extract_unsigned;
	  3'b001: BIT_result=extract_signed;
	  3'b010: BIT_result=insert;
	  3'b011: BIT_result=bclr;
	  3'b100: BIT_result=bset;
	default: BIT_result=32'b0;
	endcase
	
end

endmodule