`include"mydefines.v"
module wr_sdram(
//system
input 				reset_n,
input 				clk,
//5151 RGB input
input		  		vs_neg,
input				vs,
input		  		field,
input 		[8:0]   rdusedw_fifo,
input 		[15:0]  indata,
output 		  		rd_en_fifo,
//sdram write control signal
output reg 			wr_req,
input      			wr_ack,
output 		[15:0] 	burst_data,
output reg 	[8:0]  	burst_length,
output reg 	[21:0] 	burst_address
		);
// state constant
parameter	IDLE			= 6'b000001;
parameter	WR_REQ		= 6'b000010;
parameter	BURST			= 6'b000100;
parameter	STATE_NOP	= 6'b001000;

// variable
reg [5:0] 		state_cur;
reg [5:0]		state_d;

reg [13:0] 		burst_row_addr;

reg	[10:0]		line_cnt;
reg	[2:0]		line_burst_cnt;

wire			line_end;
wire			burst_finish;


assign line_end 	= (line_burst_cnt == 3'b010);//3'b011 whten 720;//3'b100 when 1280

assign burst_finish	= (burst_length == 1);
	
assign rd_en_fifo 	= (state_cur == BURST);

assign burst_data 	= indata;

//=====================================================
//state machine
always @(posedge clk)
begin
	state_d <= state_cur;
end


always @ (posedge clk or negedge reset_n)
begin
	if(~reset_n)
	begin
		state_cur		<= IDLE;
		wr_req 			<= 1'b0;
		burst_address 	<= 22'b0;
	end
	else if(vs_neg == 1'b1)
	begin
		state_cur		<= IDLE;
		wr_req 			<= 1'b0;
		burst_address 	<= 22'b0;
	end
	else
	begin
		case( state_cur )
		IDLE:
		begin
			if(( rdusedw_fifo >= 256 ) ||((vs == 1'b1) && (rdusedw_fifo > 0)))	// 1/4 or 2/4 then write video data to sdram.
			begin
				state_cur 		<= WR_REQ;
				wr_req 			<= 1'b1;
				burst_address	<= {burst_row_addr,8'b0};
			end
			else
				;
		end
		WR_REQ:
		begin
			if(wr_ack==1'b1)
			begin
				state_cur 		<= BURST;
				wr_req 			<= 1'b0;
			end
			else
				state_cur <= WR_REQ;
		end
		BURST:
		begin
			if(burst_finish == 1'b1)
				state_cur <= STATE_NOP;
			else
				state_cur <= BURST;
		end
		STATE_NOP:
		begin
			state_cur <= IDLE;
		end
		default:
		begin
			state_cur <= IDLE;
		end
		endcase
	end
end


/*
always @(posedge clk or negedge reset_n)
begin
	if(reset_n == 1'b0)
		burst_address <= 22'b0;
	else if(state_next==WR_REQ)
		begin
//			if(field == 1'b1)							//
				burst_address <= {burst_row_addr,8'b0};
//			else
//				burst_address <= {burst_row_addr,8'b0} + {14'h2000,8'h00};
		end
end
*/

//==================== burst_length ==========================================================
always @ (posedge clk or negedge reset_n) 
begin
	if (reset_n == 1'b0)
	begin
		burst_length <= 0;
	end
	else if(state_cur == IDLE)	
	begin
		if(line_end == 1'b1)
			burst_length <= 9'd208;	// 32 fifo_burst_length
		else		
			burst_length <= 9'h100;	// 256 fifo_burst_length
	end
	else if(state_cur==BURST )	
	begin
		burst_length <= burst_length - 1'b1;	//
	end
end



//============================== burst_address================================================
always @(posedge clk or negedge reset_n)
begin
	if(reset_n == 1'b0)
	begin
		burst_row_addr	<= 14'b0;
	end
	else
	begin		
		if(vs_neg ==1'b1)
		begin
			burst_row_addr <= 14'b0;
			line_burst_cnt	<=	0;
		end
		else if( (state_d == BURST)&&(state_cur == STATE_NOP) )
		begin
			if(line_burst_cnt == /*3'b100*/3'b010)
				burst_row_addr 	<= burst_row_addr + 3'b010;//3'b100;//
			else
				burst_row_addr 	<= burst_row_addr + 1'b1;

			if(line_burst_cnt == /*3'b101*/3'b011)
				line_burst_cnt	<=	3'b001;
			else
				line_burst_cnt	<=	line_burst_cnt + 1'b1;	
		end
	end
end


endmodule 





