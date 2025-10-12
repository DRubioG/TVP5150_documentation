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
`include "svga_defines.v"
module vga
(
input reset_n,
input pixel_clock,

output reg hs,
output reg vs,
output reg blank,
output reg de,
output reg [23:0] rgb

);

reg [10:0] pixel_count;
reg [10:0] line_count;
reg h_blank;
reg v_blank;
reg de_d;

// CREATE THE HORIZONTAL LINE PIXEL COUNTER
always @ (posedge pixel_clock or negedge reset_n) begin
	if (!reset_n)
 		begin						// on reset_n set pixel counter to 0
			pixel_count <= 11'h000;
		end
	else if (pixel_count == (`H_TOTAL - 1))
 		begin							// last pixel in the line
			pixel_count <= 11'h000;		// reset_n pixel counter
		end
	else 	
		begin
			pixel_count <= pixel_count + 1'b1;		
		end
	end

// CREATE THE HORIZONTAL SYNCH PULSE
always @ (posedge pixel_clock or negedge reset_n) begin
	if (!reset_n)
 		begin						// on reset_n
			hs <= 1'b0;		// remove h_synch
		end

	else if (pixel_count == (`H_ACTIVE + `H_FRONT_PORCH -1)) 
	  	begin					// start of h_synch
			hs <= 1'b1;
		end

	else if (pixel_count == (`H_TOTAL - `H_BACK_PORCH -1))
 	 	begin					// end of h_synch
			hs <= 1'b0;
		end
	end


// CREATE THE VERTICAL FRAME LINE COUNTER
always @ (posedge pixel_clock or negedge reset_n) begin
	if (!reset_n)
 		begin							// on reset_n set line counter to 0
			line_count <= 10'h000;
		end

	else if ((line_count == (`V_TOTAL - 1))&& (pixel_count == (`H_TOTAL - 1)))
		begin							// last pixel in last line of frame 
			line_count <= 10'h000;		// reset_n line counter
		end

	else if ((pixel_count == (`H_TOTAL - 1)))
		begin							// last pixel but not last line
			line_count <= line_count + 1'b1;// increment line counter
		end
	end

// CREATE THE VERTICAL SYNCH PULSE
always @ (posedge pixel_clock or negedge reset_n) begin
	if (!reset_n)
 		begin							// on reset_n
			vs = 1'b0;				// remove v_synch
		end

	else if ((line_count == (`V_ACTIVE + `V_FRONT_PORCH -1) &&
		   (pixel_count == `H_TOTAL - 1))) 
	  	begin							// start of v_synch
			vs = 1'b1;
		end
	
	else if ((line_count == (`V_TOTAL - `V_BACK_PORCH - 1))	&&
		   (pixel_count == (`H_TOTAL - 1)))
	 	begin							// end of v_synch
			vs = 1'b0;
		end
	end

// CREATE THE VERTICAL BLANKING SIGNAL
always @ (posedge pixel_clock or negedge reset_n) begin
	if (!reset_n)
 		begin					// on reset
			de <= 1'b0;	//
			de_d <= 1'b0;
		end
	else 
	  	begin					//
				de_d <= !blank;
				de <= de_d;
		end
	end
	
always @ (posedge pixel_clock or negedge reset_n) begin
	if (!reset_n)
 		begin					// on reset
			h_blank <= 1'b0;	// remove the h_blank
		end

	else if (pixel_count == (`H_ACTIVE -2)) 
	  	begin					// start of HBI
			h_blank <= 1'b1;
		end
	
	else if (pixel_count == (`H_TOTAL -2))
 	 	begin					// end of HBI
			h_blank <= 1'b0;
		end
	end


// CREATE THE VERTICAL BLANKING SIGNAL
// the "-2" is used instead of "-1"  in the horizontal factor because of the extra
// register delay for the composite blanking signal 
always @ (posedge pixel_clock or negedge reset_n) begin
	if (!reset_n)
 		begin						// on reset
			v_blank <= 1'b0;			// remove v_blank
		end

	else if ((line_count == (`V_ACTIVE - 1) &&
		   (pixel_count == `H_TOTAL - 2))) 
	  	begin						// start of VBI
			v_blank <= 1'b1;
		end
	
	else if ((line_count == (`V_TOTAL - 1)) &&
		   (pixel_count == (`H_TOTAL - 2)))
	 	begin						// end of VBI
			v_blank <= 1'b0;
		end
	end
	
// CREATE THE COMPOSITE BANKING SIGNAL
always @ (posedge pixel_clock or negedge reset_n) begin
	if (!reset_n)
		begin						// on reset
			blank <= 1'b0;			// remove blank
		end

	else if (h_blank || v_blank)			// blank during HBI or VBI
		 begin
			blank <= 1'b1;
		end
	else begin
			blank <= 1'b0;			// active video do not blank
		end
	end
	
// CREATE THE COLOUR BAR SIGNAL

always @(posedge pixel_clock or negedge reset_n) begin
	if(!reset_n)
		begin
			rgb <= 24'b0;
		end
//	else if(line_count == 1)
//		begin
//			rgb <= 24'hff00ff;
//		end
//	else if(pixel_count == 0)
//		begin
//			rgb <= 24'hffffff;
//		end
	else if(pixel_count	<= 100)
		begin
			rgb <= 24'b0;
		end
	else if(pixel_count	> 100 && pixel_count <= 200)
		begin
			rgb <= 24'hffffff;
		end
	else if(pixel_count	> 200 && pixel_count <= 300)
		begin
			rgb <= 24'hff00ff;
		end			
	else if(pixel_count	> 300 && pixel_count <= 400)
		begin
			rgb <= 24'hff0000;
		end
	else if(pixel_count	> 400 && pixel_count <= 500)
		begin
			rgb <= 24'h00ff00;
		end
	else if(pixel_count	> 500 && pixel_count <= 600)
		begin
			rgb <= 24'h0000ff;
		end
	else if(pixel_count	> 600 && pixel_count <= 700)
		begin
			rgb <= 24'hffff00;
		end
	else if(pixel_count	> 700 && pixel_count <= 800)
		begin
			rgb <= 24'h00ffff;
		end
	else
		begin
			rgb <= 24'b0;
		end
	end

//always @(posedge pixel_clock or negedge reset_n) begin
//	if(!reset_n)
//		begin
//			rgb <= 24'b0;
//		end
//	else
//		begin
//			rgb <= {pixel_count[10:3],8'b0,pixel_count[10:3]};
//		end
////	else
////		begin
////			rgb <= 24'b0;
////		end
//	end

endmodule 