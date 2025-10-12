module action_vip(

input			clk,
input			reset_n,
input			bt656_clk_27m,
input	[7:0]	bt656_data,

output 	[12:0] 	sdram_addr,//
output 	[1:0] 	sdr_ba,
output 	[0:0] 	sdr_cas,
output 	[0:0] 	sdr_cke,
output 	[0:0] 	sdr_cs,
inout  	[15:0] 	sdram_data,
output 	[1:0] 	sdr_dqm,
output 	[0:0] 	sdr_ras,
output 	[0:0]	sdr_we,
output 	[0:0]	sdr_clk,

output			vga_clk,
output			vga_blank,
output			vga_hs,
output			vga_vs,
output	[15:0]	vga_rgb,

output			i2c_clk,
inout			i2c_data
//output [5:0]	leds

);

wire 				clk_sys;
wire 				clk_sys_p90;
wire 				clk_pixel;
wire				clk_xscale;
wire				clk_24m;
//reg 				clk_pixel;


//pll_xscale	pll_xscale_inst 
pll_27m	pll_xscale_inst 
(
	.inclk0 ( bt656_clk_27m/*clk_0*/ ),
	.c0 ( /*clk_xscale*/clk_pixel ),
	.c1 ( clk_sys ),
	.c2 (clk_sys_p90)
	);

/*
odd_div #(
	.DIV_NUM	(5)
)
odd_div_inst(
	.clk		( clk_sys ),	// input  clk_sig
	.rst_n	( reset_n ),	// input  rst_n_sig
	.clkout	( clk_24m ) 	// output  clkout_sig
);

*/

//assign clk_o = clk;//clk_24m;//

assign sdr_clk = clk_sys_p90;
assign sdram_addr[12] = 1'b0;


video_process TV_Box
(
	.reset_n(reset_n) ,	// input  reset_n_sig
	.clk_sys(clk_sys) ,	// input  clk_sys_sig
	.clk_sdr(clk_sdr) ,	// input  clk_sdr_sig
	.clk_pixel(clk_pixel) ,	// input  clk_pixel_sig
	.bt656_clk_27m(bt656_clk_27m) ,	// input  bt656_clk_27m_sig
	.bt656_data(bt656_data) ,	// input [7:0] bt656_data_sig
	.vga_clk(vga_clk) ,	// output  vga_clk_sig
	.vga_blank(vga_blank) ,	// output  vga_blank_sig
	.vga_hs(vga_hs) ,	// output  vga_hs_sig
	.vga_vs(vga_vs) ,	// output  vga_vs_sig
	.vga_rgb(vga_rgb) ,	// output [23:0] vga_rgb_sig
	.sdr_addr(sdram_addr) ,	// output [11:0] sdr_addr_sig
	.sdr_ba(sdr_ba) ,	// output [1:0] sdr_ba_sig
	.sdr_cas(sdr_cas) ,	// output [0:0] sdr_cas_sig
	.sdr_cke(sdr_cke) ,	// output [0:0] sdr_cke_sig
	.sdr_cs(sdr_cs) ,	// output [0:0] sdr_cs_sig
	.sdr_dq(sdram_data) ,	// inout [15:0] sdr_dq_sig
	.sdr_dqm(sdr_dqm) ,	// output [1:0] sdr_dqm_sig
	.sdr_ras(sdr_ras) ,	// output [0:0] sdr_ras_sig
	.sdr_we(sdr_we)		// output [0:0] sdr_we_sig
//	,.sdr_clk(sdr_clk) 	// output [0:0] sdr_clk_sig
);


I2C_AV_Config I2C_AV_Config_inst(	//	Host Side
	.iCLK(clk),
	.iRST_N(reset_n),
	//	I2C Side
	.I2C_SCLK(i2c_clk),
	.I2C_SDAT(i2c_data)
		);





endmodule
