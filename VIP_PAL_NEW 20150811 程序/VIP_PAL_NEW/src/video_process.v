module video_process(
input			reset_n,
input			clk_sys,
input			clk_sdr,
input			clk_pixel,
input			bt656_clk_27m,
input	[7:0]	bt656_data,

output			vga_clk,
output			vga_blank,
output			vga_hs,
output			vga_vs,
output	[15:0]	vga_rgb,

output 	[11:0] 	sdr_addr,//
output 	[1:0] 	sdr_ba,
output 	[0:0] 	sdr_cas,
output 	[0:0] 	sdr_cke,
output 	[0:0] 	sdr_cs,
inout  	[15:0] 	sdr_dq,
output 	[1:0] 	sdr_dqm,
output 	[0:0] 	sdr_ras,
output 	[0:0]	sdr_we,
output 	[0:0]	sdr_clk

);


//------------------bt656 decoder and 4:2:2 to 4:4:4------------------------//
wire				bt656_hs;
wire				bt656_vs;
wire				bt656_field;
wire				clk_13m5;
wire	[7:0]		y;
wire	[7:0]		cb;
wire	[7:0]		cr;
wire				vga_de;


bt656_rx bt656_rx_inst
(
	.clk1(bt656_clk_27m) ,	// input  clk1_sig
	.reset_n(reset_n) ,	// input  reset_n_sig
	.din(bt656_data/*test_din[9:2]*/) ,	// input [7:0] din_sig
	.lcc2(clk_13m5) ,	// output  lcc2_sig
//	.v_blank(v_blank_sig) ,	// output  v_blank_sig
	.field(bt656_field) ,	// output  field_sig
	.v(bt656_vs) ,	// output  v_sig
	.h(bt656_hs) ,	// output  h_sig
	.y(y) ,	// output [7:0] y_sig
	.cb(cb) ,	// output [7:0] cb_sig
	.cr(cr) 

);

//-------------------------- colour space change ---------------------------//
wire	[7:0]		red;
wire	[7:0]		green;
wire	[7:0]		blue;

csc csc_0(
	.clk(clk_13m5),
	.y(y),
	.cb(cb),
	.cr(cr),

	.r(red),
	.g(green),
	.b(blue)
 );


//----------- X-scale and video buffer before write into sdram -------------//
reg	[10:0]	pixel_cnt;

wire				wr_en_wrbuffer;
wire				rd_en_wrbuffer;

wire	[15:0]	dout_wrbuffer;
wire	[8:0]		rdusedw_wrbuffer;


reg				bt656_vs_r;
reg				bt656_hs_r;

reg 				bt656_vs_r0;
reg 				bt656_vs_r1;
reg 				bt656_vs_neg;
reg	[7:0]		red_r;
reg	[7:0]		green_r;
reg	[7:0]		blue_r;

always @ (posedge clk_sys/*clk_xscale*/ or negedge reset_n)
begin
	if(~reset_n)
	begin
		bt656_vs_r0		<= 1'b0;
		bt656_vs_r1		<= 1'b0;
		bt656_vs_neg	<= 1'b0;
	end
	else
	begin
		bt656_vs_r0		<= bt656_vs;
		bt656_vs_r1		<= bt656_vs_r0;
		if((bt656_vs_r1 == 1'b1) && (bt656_vs_r0 == 1'b0))
			bt656_vs_neg	<= 1'b1;
		else
			bt656_vs_neg	<= 1'b0;
	end
end



always @ (posedge clk_13m5 or negedge reset_n)
begin
	if(~reset_n)
	begin
		pixel_cnt	<= 11'b0;
	end
	else if((bt656_vs == 1'b1) || (bt656_hs == 1'b1) || (bt656_field == 1'b1))
	begin
		pixel_cnt	<= 11'b0;
	end
	else
	begin
		pixel_cnt	<= pixel_cnt + 1'b1;
	end
end

assign wr_en_wrbuffer = /*(!bt656_vs_r) && (!bt656_hs_r) && (!bt656_field)
									&& */(pixel_cnt >= 7) && (pixel_cnt <= 706);

									
fifo_wrbuffer_512x16	fifo_wrbuffer_512x16_inst (
	.aclr 	( bt656_vs_neg ),
	.data 	( {red[7:3],green[7:2],blue[7:3]}/*16'b1111100000000000*/ ),
	.rdclk 	( clk_sys ),
	.rdreq 	( rd_en_wrbuffer ),
	.wrclk 	( /*clk_xscale */clk_13m5),
	.wrreq 	( wr_en_wrbuffer ),
	.q 		( dout_wrbuffer ),
//	.rdempty ( rdempty_sig ),
//	.wrfull 	( wrfull_sig ),
	.rdusedw ( rdusedw_wrbuffer )

	);
//----------------------- video write to sdram logic -----------------------//

wr_sdram wr_sdram_inst
(
	.reset_n(reset_n) ,	// input  reset_n_sig
	.clk(clk_sys) ,	// input  clk_sig
	.vs_neg(bt656_vs_neg) ,	// input  vs_sig
	.vs(bt656_vs),
	.field(bt656_field) ,	// input  field_sig
	.rdusedw_fifo(rdusedw_wrbuffer) ,	// input [9:0] rdusedw_fifo_sig
	.indata(dout_wrbuffer) ,	// input [15:0] indata_sig
	.rd_en_fifo(rd_en_wrbuffer) ,	// output  rd_en_fifo_sig
	.wr_req(wr_req) ,	// output  wr_req_sig
	.wr_ack(wr_req_ack) ,	// input  wr_ack_sig
	.burst_data(wr_data) ,	// output [15:0] burst_data_sig
	.burst_length(wr_data_length) ,	// output [8:0] burst_length_sig
	.burst_address(wr_addr_base), 	// output [21:0] burst_address_sig
	.xscale_param(20'h00E00)
);

//----------------------------- sdram controller ---------------------------//
wire				wr_req;
wire				wr_req_ack;
wire	[15:0]	wr_data;
wire	[21:0]	wr_addr_base;
wire	[8:0]		wr_data_length;

	sdram_if sdram_if_0(
		//  system
		.RST				(	~reset_n		),
		.CLK				(	clk_sys		),
		//  write
		.WR_RQ_i			(	wr_req/*1'b0	*/	),		 	//  write request
		.WR_DATA_i		(	wr_data/*16'h0f0f*/			),       	//  write data
		.WR_DATA_LEN_i	(	wr_data_length	),   		//  write data length, ahead of WR_RQ_i
		.WR_ADDR_BASE_i(	wr_addr_base/*22'b0*/	),  		//  write base address of sdram write buffer
		.WR_DATA_RQ_o	(	wr_req_ack		),    		//  wrtie data request, 2 clock ahead
//		.WR_DATA_EN_o	(						),    		//  write data enable now
//		.WR_DATA_END_o	(						),   		//  write data is end
		//  read
		.RD_RQ_i			(	rd_req/*1'b0	*/		),		 	//  read request
		.RD_DATA_LEN_i	(	rd_data_length	),   		//  read data length, ahead of RD_RQ_i
		.RD_ADDR_BASE_i(	rd_addr_base/*wr_addr_base*/	),  		//  read base address of sdram read buffer
		.RD_DATA_o		(	rd_data			),      	//  read data to internal
		.RD_DATA_EN_o	(	rd_data_valid	),    		//  read data enable (valid)
		.RD_DATA_END_o	(						),	 		//  read data is end

		//==============================================
		//  sdram interface
//		.SDRAM_CLK_o	(	clk_sys		),
		.SDRAM_CKE_o	(	sdr_cke		),
		.SDRAM_CSn_o	(	sdr_cs		),
		.SDRAM_RASn_o	(	sdr_ras		),
		.SDRAM_CASn_o	(	sdr_cas		),
		.SDRAM_WEn_o	(	sdr_we		),
		.SDRAM_BA_o		(	sdr_ba		),
		.SDRAM_A_o		(	sdr_addr/*[11:0]*/		),
		.SDRAM_DQM_o	(	sdr_dqm		),
		.SDRAM_DQ_io	(	sdr_dq		)		
		);

//--------------------- video read from sdram and Y-scale -----------------//
wire	[15:0]	rd_data;
wire				rd_data_valid;
wire				rd_req;
wire	[8:0]		rd_data_length;
wire	[21:0]	rd_addr_base;
wire				wr_en_disbuffer;


rd_sdram rd_sdram_inst
(
	.clk_sdram		(clk_sys) ,	// input  clk_108m_sig
	.reset_n			(reset_n/*1'b1*/) ,	// input  reset_n_sig
	.rd_data			(rd_data) ,	// input [15:0] rd_data_sig
	.rd_data_valid	(rd_data_valid) ,	// input  rd_data_valid_sig
	.vs				(vga_vs) ,	// input  vs_sig
	.rd_req			(rd_req) ,	// output  rd_req_sig
	.rd_data_length(rd_data_length) ,	// output [8:0] rd_data_length_sig
	.rd_addr_base	(rd_addr_base) ,	// output [21:0] rd_addr_base_sig
	.wrusedw_fifo	(wrusedw_disbuffer) ,	// input [9:0] wrusedw_fifo_sig
	.wr_en_fifo		(wr_en_disbuffer) ,	// output  wr_en_fifo_sig
	.din_fifo		(din_disbuffer), 	// output [15:0] din_fifo_sig
	.yscale_param	(20'h00666)//20'h003c0 for 240 up to 1024//20'h000666 for 240 up to 600
);


//----------------------------- video display -----------------------------//
wire	[15:0]	din_disbuffer;
wire	[9:0]		wrusedw_disbuffer;

reg				vga_vs_pos;
reg				vga_vs_r0;
reg				vga_vs_r1;

always @ (posedge clk_sys or negedge reset_n)
begin
	if(~reset_n)
	begin
		vga_vs_r0	<= 1'b0;
		vga_vs_r1	<= 1'b0;
		vga_vs_pos	<= 1'b0;
	end
	else
	begin
		vga_vs_r0	<= vga_vs;
		vga_vs_r1	<= vga_vs_r0;
		if((vga_vs_r0 == 1'b1) && (vga_vs_r1 == 1'b0))
			vga_vs_pos	<= 1'b1;
		else
			vga_vs_pos	<= 1'b0;
	end
end

wire	[15:0]		vga_rgb_w;

fifo_display_1024x16	fifo_display_1024x16_inst (
	.aclr ( vga_vs_pos ),
	.data ( din_disbuffer/*16'b1111100000000000*/ ),
	.rdclk ( clk_pixel ),
	.rdreq ( vga_de ),
	.wrclk ( clk_sys ),
	.wrreq ( wr_en_disbuffer ),
	.q ( vga_rgb_w ),
//	.rdempty ( rdempty_sig ),
//	.wrfull ( wrfull_sig ),
	.wrusedw ( wrusedw_disbuffer )
	);
 


assign vga_clk = ~ clk_pixel;


//---------------------------------------------------------------------//
assign vga_rgb =vga_rgb_w;// {vga_rgb_w[15:11],3'b011,vga_rgb_w[10:5],2'b01,vga_rgb_w[4:0],3'b011};//24'hff0000;
assign vga_blank = vga_de;
assign	vga_hs = ~ hs_w;
assign	vga_vs = ~ vs_w;


wire	hs_w;
wire	vs_w;

vga vga_inst
(
	.reset_n(reset_n) ,	// input  reset_n_sig
	.pixel_clock(clk_pixel) ,	// input  pixel_clock_sig
	.hs(hs_w/*vga_hs*/) ,	// output  hs_sig
	.vs(vs_w/*vga_vs*/) ,	// output  vs_sig
//	.blank(vga_blank) ,	// output  blank_sig
//	.rgb(vga_rgb), 	// output [23:0] rgb_sig
	.de(vga_de) 	// output  de_sig
);


endmodule
