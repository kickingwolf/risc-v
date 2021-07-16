module compare(
input[2:0]priority_i1,
input[3:0]id_i1,
input[2:0]priority_i2,
input[3:0]id_i2,
output[2:0]priority_o,
output[3:0]id_o);
assign priority_o=(priority_i1 > priority_i2) ? priority_i1 : priority_i2;
assign id_o		 =(priority_i1 > priority_i2)	? id_i1		  :id_i2;
endmodule