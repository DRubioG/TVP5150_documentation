//*************************************************************************\
//20150426
//tvp5150 测试 ok


//20150811 完善
//1、vip 板卡测试ok
//2、ep4ce6+sdram+vga
//3、qii 14.1
//4、编译好的jic或sof可以直接子啊vip101上使用
//参考博客地址 http://www.cnblogs.com/ccjt/p/4456474.html
//店铺地址 https://ccjt.taobao.com/
// 主营：摄像头、视频采集、视频处理、fpga、usb等评估套件、高速相机、物联网周边
// 技术交流qq群：层层惊涛 26210916
// 群主：奇迹再现


//
//                   File Name  :  csc.v
//                Project Name  :  action_vip_video_capture
//                      Author  :  Action
//                       Email  :  
//                      Device  :  EP2C5Q208C8N
//                     Company  :  
//==========================================================================
//   Description:  colour space change from YUV ro RGB
//   Called by  :  csc.v
//==========================================================================
//   Revision History:
//	 Date		   By			Revision	Change Description
//--------------------------------------------------------------------------
//  2009/11/30	  Action		      01			Original
//*************************************************************************/
`timescale 1ps/1ps

module csc (
		clk,
	    y,
	    cb,
	    cr,

	    r,
	    g,
	    b
    );
  input clk;
  input [7:0] y;
  input [7:0] cb;
  input [7:0] cr;

  output [7:0] r;
  output [7:0] g;
  output [7:0] b;
//	output [23:0] rgb;

  //---------------------------------------------------------------------------
  // Equations for YCbCr to RGB
  //
  // R = 1.164(Y-16) + 1.596(Cr-128)
  // G = 1.164(Y-16) - 0.813(Cr-128) - 0.392(Cb-128)
  // B = 1.164(Y-16) + 1.017(Cb-128) + (Cb-128)
  //
  // The fractional multipliers are converted to 8-bit binary fractions with an
  // implied binary point between bits 7 and 6. Multiplying by the inputs gives
  // a 16 bit result with an implied binary point between bits 7 and 6. The
  // results of the multiplications are added/subtracted, together with the
  // constant terms giving a signed 18 bit result. The integer part of the
  // result is selected, truncating the two lsbs as we want a 6 bit output. A
  // negative result is replaced by zero. Anything greater than 63 is set to
  // 63.
  //---------------------------------------------------------------------------
//  
//  wire [15:0] mul1 = y * 8'b10010101;	// Y*1.164
//  wire [15:0] mul2 = cr * 8'b11001100;	// Cr*1.596
//  wire [15:0] mul3 = cr * 8'b01101000;	// Cr*0.813
//  wire [15:0] mul4 = cb * 8'b00110010;	// Cb*0.392
//  wire [15:0] mul5 = cb * 8'b10000010;	// Cb*1.017
  
  wire [15:0] mul1;	// Y*1.164
  wire [15:0] mul2;	// Cr*1.596
  wire [15:0] mul3;	// Cr*0.813
  wire [15:0] mul4;	// Cb*0.392
  wire [15:0] mul5;	// Cb*1.017

  mult6x6 mult1 (
		     .clock	( clk ),
		     .dataa	( y ),
		     .datab	( 8'b10010101 ),
		     
		     .result( mul1 )
		     );		     	  
  mult6x6 mult2 (
		     .clock	( clk ),
		     .dataa	( cr ),
		     .datab	( 8'b11001100 ),
		     
		     .result( mul2 )
		     );
  mult6x6 mult3 (
		     .clock	( clk ),
		     .dataa	( cr ),
		     .datab	( 8'b01101000 ),
		     
		     .result( mul3 )
		     );
  mult6x6 mult4 (
		     .clock	( clk ),
		     .dataa	( cb ),
		     .datab	( 8'b00110010 ),
		     
		     .result( mul4 )
		     );		     
  mult6x6 mult5 (
		     .clock	( clk ),
		     .dataa	( cb ),
		     .datab	( 8'b10000010 ),
		     
		     .result( mul5 )
		     );		     
		     
  wire [17:0] red 	= (mul1 + mul2) - {10'd222, 7'b0};//
  wire [17:0] green = (mul1 + {10'd136, 7'b0}) - (mul3 + mul4);//
  wire [17:0] blue 	= (mul1 + mul5) - ({10'd277, 7'b0} - {cb, 7'b0});//

  wire [10:0] red_int 	= red[17:7];
  wire [10:0] green_int = green[17:7];
  wire [10:0] blue_int 	= blue[17:7];
/*
  wire [5:0]  r = red_int[10] ? 6'b0 : ((|red_int[9:8]) ? 6'h3f : red_int[7:2]);
  wire [5:0]  g = green_int[10] ? 6'b0 : ((|green_int[9:8]) ? 6'h3f : green_int[7:2]);
  wire [5:0]  b = blue_int[10] ? 6'b0 : ((|blue_int[9:8]) ? 6'h3f : blue_int[7:2]);
*/  
  wire [7:0] r = red_int[10] 	? 8'b0 : ((|red_int[9:8]) 	? 8'hff : red_int[7:0]);
  wire [7:0] g = green_int[10] 	? 8'b0 : ((|green_int[9:8]) ? 8'hff : green_int[7:0]);
  wire [7:0] b = blue_int[10] 	? 8'b0 : ((|blue_int[9:8]) 	? 8'hff : blue_int[7:0]);
  
  //assign rgb = {r,g,b};
  
endmodule
