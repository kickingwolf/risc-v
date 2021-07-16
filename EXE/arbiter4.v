module  arbiter4( clk, rst,req, result);
  input clk,rst;
  input[3:0] req;
  output[3:0] result;
  reg[3:0] result;
  reg req1_reg2,req1_reg3,req1_reg4;
  reg req2_reg1,req2_reg3,req2_reg4;
  reg req3_reg1,req3_reg2,req3_reg4;
  reg req4_reg1,req4_reg2,req4_reg3;
  
  
  always @ (posedge clk or negedge rst)
   begin
   if (!rst) 
    begin
     req1_reg2 <=1'b0; req1_reg3 <=1'b0; req1_reg4 <=1'b0;
     req2_reg1 <=1'b1;  req2_reg3 <=1'b0; req2_reg4 <=1'b0;
     req3_reg1 <=1'b1; req3_reg2 <=1'b1;  req3_reg4 <=1'b0;
     req4_reg1 <=1'b1; req4_reg2 <=1'b1;  req4_reg3 <=1'b1; 
    end
   else begin 
    case (result)
     4'b0001: begin
               req1_reg2 <=1'b1; req1_reg3 <=1'b1; req1_reg4 <=1'b1;
               req2_reg1 <=1'b0; //req2_reg2 <=1'b0; req2_reg3 <=1'b0; req2_reg4 <=1'b0;
               req3_reg1 <=1'b0; //req3_reg2 <=1'b1; req3_reg3 <=1'b0; req3_reg4 <=1'b0;
               req4_reg1 <=1'b0; //req4_reg2 <=1'b1; req4_reg3 <=1'b1; req4_reg4 <=1'b0; 
              end
    4'b0010:  begin
               /*req1_reg1 <=1'b0;*/ req1_reg2 <=1'b0; //req1_reg3 <=1'b1; req1_reg4 <=1'b1;
                 req2_reg1 <=1'b1;  req2_reg3 <=1'b1; req2_reg4 <=1'b1;
               /*req3_reg1 <=1'b0;*/ req3_reg2 <=1'b0; //req3_reg3 <=1'b0; req3_reg4 <=1'b0;
               /*req4_reg1 <=1'b0;*/ req4_reg2 <=1'b0; //req4_reg3 <=1'b1; req4_reg4 <=1'b0; 
              end                                      //
    4'b0100:  begin
              /*req1_reg1 <=1'b0; req1_reg2 <=1'b1;*/ req1_reg3 <=1'b0; //req1_reg4 <=1'b1;
              /*req2_reg1 <=1'b0; req2_reg2 <=1'b0;*/ req2_reg3 <=1'b0; //req2_reg4 <=1'b0;
                req3_reg1 <=1'b1; req3_reg2 <=1'b1;    req3_reg4 <=1'b1;
              /*req4_reg1 <=1'b0; req4_reg2 <=1'b1;*/ req4_reg3 <=1'b0; //req4_reg4 <=1'b0; 
              end
    4'b1000:  begin
              /*req1_reg1 <=1'b0; req1_reg2 <=1'b1; req1_reg3 <=1'b1;*/ req1_reg4 <=1'b0;
              /*req2_reg1 <=1'b0; req2_reg2 <=1'b0; req2_reg3 <=1'b0;*/ req2_reg4 <=1'b0;
              /*req3_reg1 <=1'b0; req3_reg2 <=1'b1; req3_reg3 <=1'b0;*/ req3_reg4 <=1'b0;
                req4_reg1 <=1'b1; req4_reg2 <=1'b1; req4_reg3 <=1'b1; 
              end
   endcase
   end
   end
   
 always @ *
  begin
    result[0]= req[0] & (~(req1_reg2&req[1]))&(~(req1_reg3&req[2]))&(~(req1_reg4&req[3]));
    result[1]= req[1] & (~(req2_reg1&req[0]))&(~(req2_reg3&req[2]))&(~(req2_reg4&req[3]));
    result[2]= req[2] & (~(req3_reg1&req[0]))&(~(req3_reg2&req[1]))&(~(req3_reg4&req[3]));
    result[3]= req[3] & (~(req4_reg1&req[0]))&(~(req4_reg2&req[1]))&(~(req4_reg3&req[2]));
  end
 endmodule

