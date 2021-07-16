
module gateway 
(input rst_n,
input clk,
input src,
input edge_lvl,
input claim,
input complete,
output ip
);
parameter LEVEL =1'b0;
parameter EDGE  =1'b1;
reg src_dly,src_edge;
reg [3:0]nxt_pending_cnt,pending_cnt;
reg decr_pending;
reg [1:0]ip_state;

always@(posedge clk or negedge rst_n)
	if(!rst_n)
	begin
		src_dly<=1'b0;
		src_edge<=1'b0;
	end
	else
	begin
		src_dly <=src;
		src_edge<=src & ~src_dly;
	end


always@*
	case({decr_pending,src_edge})
		2'b00:nxt_pending_cnt=pending_cnt;
		2'b01:if(pending_cnt<=3'd7)
				nxt_pending_cnt=pending_cnt+1'b1;
				else
				nxt_pending_cnt=pending_cnt;
		2'b10:if(pending_cnt>0)
				nxt_pending_cnt=pending_cnt-1'b1;
				else
				nxt_pending_cnt=pending_cnt;
		2'b11: nxt_pending_cnt=pending_cnt;
		default:nxt_pending_cnt=pending_cnt;
	endcase

always@(posedge clk or negedge rst_n)
	if(!rst_n) pending_cnt<=3'b0;
	else if(edge_lvl != EDGE)pending_cnt<=3'b0;
	else pending_cnt<=nxt_pending_cnt;
	
always@(posedge clk or negedge rst_n)
	if(!rst_n)
		begin
			ip_state<=2'b00;
			decr_pending<=1'b0;
		end
	else
		begin
			decr_pending<=1'b0;
			case(ip_state)
			2'b00:if ((edge_lvl == EDGE  && |nxt_pending_cnt) ||
                       (edge_lvl == LEVEL && src             ))
				begin
					ip_state<=2'b01;
					decr_pending<=1'b1;
				end
			2'b01  : if (claim   ) ip_state <= 2'b10;
			2'b10  : if (complete) ip_state <= 2'b00;
			 default: ip_state <= 2'b00;
			 endcase
		end

assign ip =ip_state[0];
endmodule