module BTYPE_compare
(
 input BTYPE_vld,
 input [31:0] BTYPE_OPRA,
 input [31:0] BTYPE_OPRB,
 input [2:0]  funct3,
 input [31:0] BTYPE_offset,
 input [31:0] PC,
 input [31:0] exePC,
 output BTYPE_FLUSH,
 output [31:0]BTYPE_REAL_ADDR    
);

wire [31:0] rb =~BTYPE_OPRB;
wire [31:0] diff;
assign {carry,diff} = BTYPE_OPRA + rb + 1'b1;

wire beq = ~(|diff);
wire bne = 	 |diff;
wire blt = (BTYPE_OPRA[31] & ~BTYPE_OPRB[31]) |
           (BTYPE_OPRA[31] & BTYPE_OPRB[31] & diff[31]) | 
		   (~BTYPE_OPRA[31] & ~BTYPE_OPRB[31] & diff[31]) ;
wire bge = (~BTYPE_OPRA[31] & BTYPE_OPRB[31]) |
           (BTYPE_OPRA[31] & BTYPE_OPRB[31] & ~diff[31]) |
		   (~BTYPE_OPRA[31] & ~BTYPE_OPRB[31] & ~diff[31]) | beq; 
wire bltu = carry;
wire bgeu = ~carry | beq;

wire beq_bne   = (funct3[0])?bne:beq;
wire blt_bge   = (funct3[0])?bge:blt;
wire bltu_bgeu = (funct3[0])?bgeu:bltu;

assign result  = ((funct3[2:1]==2'b00) &beq_bne)|
                 ((funct3[2:1]==2'b10) &blt_bge)|
				 ((funct3[2:1]==2'b11) &bltu_bgeu);
					 
assign BTYPE_REAL_ADDR = result ? (exePC + BTYPE_offset) : (exePC + 4);
assign BTYPE_FLUSH	  = BTYPE_vld & (|(BTYPE_REAL_ADDR^PC));

endmodule