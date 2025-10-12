//`include"mydefines.v"

module rd_sdram(
	clk_sdram,		//Global signal
	reset_n,
	rd_data,		//sdram read opreation, from sdram
	rd_data_valid,
	vs,
	rd_req,			// request sdram 
	rd_data_length,
	rd_addr_base,
	yscale_param,
	wrusedw_fifo,
	wr_en_fifo,
	din_fifo
	);
	/********************************************\
	Port Declare
	\********************************************/
	//input	port
	input					clk_sdram;					//	????
	input					reset_n;						//  ????
	input	[15:0]		rd_data;					//  RGB????
	input					rd_data_valid;				//  ?RGB??FIFo??
	input					vs;
	//====================================================
	input	[9:0]			wrusedw_fifo;
	input	[19:0]		yscale_param;
	//output port FIFO
	output	reg		wr_en_fifo;
	
	output	[15:0]	din_fifo;
	//output port
	output	reg				rd_req;					//	?SDRAM??
	output	reg	[8 :0]	rd_data_length;			//	?SDRAM????
	output	reg	[21:0]	rd_addr_base;			//	?SDRAM??
	//output port 

	//********************************************
	//Signal Declare
	//********************************************


	//Parameter Define
	//********************************************
//	parameter	INTTIAL		= 5'b10000;
	parameter	IDLE			= 5'b00001;
	parameter	RD_REQ		= 5'b00010;
	parameter	RD_BURST		= 5'b00100;
	parameter	FSM_AROUND	= 5'b01000;

	//********************************************
	reg	[4:0]	curr_state;
	reg	[4:0]	state_d;
//	reg	[4:0]	state_d1;
	
	
	reg	[7:0]	pixel_cnt;
	reg			v_synch_posedge;
	reg			v_synch_negedge;
	reg	[13:0]	rd_row_addr;

	
	assign   	din_fifo = rd_data;


//=========================================================================================
//	check posedge vs signal
//=========================================================================================
	reg			lcd_v_sync_d1;
	reg 			lcd_v_sync_d2;
	reg			vs_pos;
	always @( posedge clk_sdram or negedge reset_n )
	begin
		if(~reset_n)
		begin
			vs_pos	<=	1'b0;
			lcd_v_sync_d1	<=	1'b0;
			lcd_v_sync_d2	<=	1'b0;
		end
		else
		begin
			lcd_v_sync_d1	<=	vs;
			lcd_v_sync_d2	<=	lcd_v_sync_d1;
			if((lcd_v_sync_d1==1'b1)&&(lcd_v_sync_d2==1'b0))
				vs_pos	<=	1'b1;
			else
				vs_pos	<=	1'b0;
		end
	end
//*********************************************
// state machine: Read frame data from sdram
//*********************************************
always @( posedge clk_sdram or negedge reset_n )
begin
	if(~reset_n )
	begin
		curr_state		<= IDLE;//INTTIAL;//
		rd_data_length	<= 9'd256;
		rd_req			<= 1'b0;
		rd_addr_base	<= 22'b0;
	end
	else if(vs_pos==1'b1/*~vs*/)
	begin
		curr_state		<= IDLE;//INTTIAL;//
		rd_data_length	<= 9'd256;
		rd_req			<= 1'b0;
		rd_addr_base	<= 22'b0;
	end
	else
	begin
		case( curr_state )
		IDLE:			//1
		begin
			if( wrusedw_fifo < 256)//512					//	??previous field??FIFO???????
			begin
				curr_state 		<= RD_REQ;
				if(line_last_burst == 1'b1)
					rd_data_length	<= 9'd32;
				else
					rd_data_length	<= 9'd256;
			end
			else
				;
		end
		RD_REQ: //2  first to request		//	?????????
		begin
			curr_state	<= RD_BURST;
			rd_req		<= 1'b1;
			rd_addr_base	<= {rd_row_addr, 8'b0 };// + 22'h000000;//video addr odd;						
		end
		RD_BURST:		//4					//	???256???
		begin
			if( rd_data_valid == 1'b1 )		// 0 when ack, others rd_req keep 1
				rd_req	<= 1'b0;
			else
				;
				
			if( (pixel_cnt == /*8'd255*/burst_length[7:0]))		//ff reach one bank, 180 of 256 data
				curr_state	<= FSM_AROUND;
			else
				;
		end

		FSM_AROUND:
		begin
			rd_req	<= 1'b0;
			curr_state		<= IDLE;
		end
		default:curr_state	<= IDLE;
		endcase
	end
end
//***********************************************\
//Generate the  bank counter
//***********************************************/

reg	[2:0]		burst_cnt;
reg	[19:0]	yscale_factor;
reg	[19:0]	yscale_factor_d;

wire	[7:0]		factor_int_diff;
wire	[8:0]		burst_length;
wire				line_last_burst;

assign line_last_burst  = (burst_cnt == /*3'b100*/3'b011);
assign burst_length		= rd_data_length - 1'b1;
assign factor_int_diff	= yscale_factor[19:12] - yscale_factor_d[19:12];



always @( posedge clk_sdram/* or negedge reset_n*/ )
begin
		state_d <= curr_state;
//		state_d1 <= state_d;
end



always @( posedge clk_sdram or negedge reset_n )
begin
	if( ~reset_n )
	begin
		burst_cnt			<= 3'b0;
		yscale_factor		<= 20'b0;
		yscale_factor_d	<= 20'b0;
	end
	else
	begin
		if(vs_pos==1'b1)
		begin
			burst_cnt			<= 3'b0;
			yscale_factor		<= 20'b0;
			yscale_factor_d	<= 20'b0;
		end	
		else if( (curr_state==FSM_AROUND)/*&&(state_d==RD_BURST) */)
		begin
				if(burst_cnt == /*3'b101*/3'b100)
				begin
					burst_cnt			<=	3'b001;
//					yscale_factor 		<= yscale_factor + yscale_param;
//					yscale_factor_d		<= yscale_factor;
				end
				else
				begin
					burst_cnt    		<=	burst_cnt + 1'b1;
//					yscale_factor 		<= yscale_factor;
//					yscale_factor_d		<= yscale_factor_d;
				end
			
				if(burst_cnt == /*3'b100*/3'b011)//the last burst in each line has finish
				begin
					yscale_factor 		<= yscale_factor + yscale_param;
					yscale_factor_d	<= yscale_factor;
				end
				else
				begin
					yscale_factor 		<= yscale_factor;			//keep
					yscale_factor_d	<= yscale_factor_d;		//keep
				end
		end
		else
			;
	end
end

always @ (posedge clk_sdram or negedge reset_n )
begin
	if( ~ reset_n )
	begin
		rd_row_addr <= 14'b0;
	end
	else
	begin
		if(vs_pos==1'b1)
			rd_row_addr <= 14'b0;
		else 
		begin
			if((curr_state == IDLE) && (state_d == FSM_AROUND))// && (state_d1 == RD_BURST))
				if((factor_int_diff >= 1) && (burst_cnt == /*3'b101*/3'b100))
					rd_row_addr  <= rd_row_addr + /*3'b100*/3'd1;//next line
				else if(burst_cnt == /*3'b101*/3'b100)
					rd_row_addr  <= rd_row_addr - /*3'b100*/3'b011;//
				else
					rd_row_addr  <= rd_row_addr + 1'b1;
			else
				;	
		end
	end
end
//***********************************************\
//Generate the col counter
//***********************************************/
always @(posedge clk_sdram or negedge reset_n )
begin
	if( ~ reset_n )
	begin
		pixel_cnt <= 8'b0;
	end
	else
	begin
		if((curr_state==RD_REQ)||(vs_pos==1'b1)/*(vs==1'b0)*/)
		begin
			pixel_cnt <= 8'b0;
		end
		else if( (rd_data_valid==1'b1)&&(curr_state==RD_BURST) )
		begin
			pixel_cnt <= pixel_cnt + 1'b1;
		end
		else
		;
	end
end

//***********************************************\
//????????FIFO????
//***********************************************/
always @( posedge clk_sdram or negedge reset_n )
begin
	if( ~ reset_n ) 
	begin
		wr_en_fifo	<=  1'b0;
	end
	else
	begin							
		if( curr_state == RD_BURST )
		begin
			wr_en_fifo  <= rd_data_valid;
		end
		else
		begin
			wr_en_fifo	<=  1'b0;
		end
	end
end

endmodule






