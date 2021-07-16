module plic_priority_index
(
  input  [44:0] priorityi , //Interrupt Priority
  input  [59:0] idx,
  output [2:0] priority_o,
  output [3:0] idx_o
);
 wire [2:0]compare_level1_pri[6:0];
 wire [3:0]compare_level1_id[6:0];
 wire [2:0]compare_level2_pri[3:0];
 wire [3:0]compare_level2_id[3:0];
 wire [2:0]compare_level3_pri[1:0];
 wire [3:0]compare_level3_id[1:0];
 
genvar i;
generate
for(i=0;i<7;i=i+1)
begin:loop_compare1
compare ni
(.priority_i1(priorityi[((i*2)*3)+2:((i*2)*3)])
,.id_i1(idx[((i*2)*4)+3:((i*2)*4)])
,.priority_i2(priorityi[((i*2+1)*3)+2:((i*2+1)*3)])
,.id_i2(idx[((i*2+1)*4)+3:((i*2+1)*4)])
,.priority_o(compare_level1_pri[i])
,.id_o(compare_level1_id[i]));   
end
endgenerate

genvar j;
generate
for(j=0;j<3;j=j+1)
begin:loop_compare2
compare mi
(.priority_i1(compare_level1_pri[j*2])
,.id_i1(compare_level1_id[j*2])
,.priority_i2(compare_level1_pri[j*2+1])
,.id_i2(compare_level1_id[j*2+1])
,.priority_o(compare_level2_pri[j])
,.id_o(compare_level2_id[j]));   
end
endgenerate

compare m3
(.priority_i1(compare_level1_pri[6])
,.id_i1(compare_level1_id[6])
,.priority_i2(priorityi[44:42])
,.id_i2(idx[59:56])
,.priority_o(compare_level2_pri[3])
,.id_o(compare_level2_id[3])); 

genvar k;
generate
for(k=0;k<2;k=k+1)
begin:loop_compare3
compare xi
(.priority_i1(compare_level2_pri[k*2])
,.id_i1(compare_level2_id[k*2])
,.priority_i2(compare_level2_pri[k*2+1])
,.id_i2(compare_level2_id[k*2+1])
,.priority_o(compare_level3_pri[k])
,.id_o(compare_level3_id[k]));   
end
endgenerate
 
compare f1
(.priority_i1(compare_level3_pri[0])
,.id_i1(compare_level3_id[0])
,.priority_i2(compare_level3_pri[1])
,.id_i2(compare_level3_id[1])
,.priority_o(priority_o)
,.id_o(idx_o));   

endmodule