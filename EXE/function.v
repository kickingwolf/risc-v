module math(  input [2:0]funct3,
                  input [31:0]rs1,
				  input [31:0]rb,
				  input [4:0] shamt,
				  input cin,
				output reg [31:0] result
);

wire signed [31:0] sign_rs1;
wire signed [31:0] sign_rb;

assign sign_rs1 = rs1;
assign sign_rb = rb;

always@(*) begin
   case(funct3) 
       3'b000:result<=rs1+rb+cin;
	   3'b001:result<=rs1<<shamt;
	   3'b010:if(sign_rs1<sign_rb) result <=32'd1;
	          else result<=32'd0;
	   3'b011:if(rs1<rb) result<= 32'd1;
	          else result <= 32'd0;
	   3'b100:result<=rs1 ^ rb;
	   3'b101:result<=rs1>>shamt;
	   3'b110:result<=rs1 | rb;
	   3'b111:result<=rs1 & rb;
   endcase

end	
endmodule
