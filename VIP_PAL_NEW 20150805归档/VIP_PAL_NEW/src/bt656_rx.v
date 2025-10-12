// ================================================================================
// (c) 2004 Altera Corporation. All rights reserved.
// Altera products are protected under numerous U.S. and foreign patents, maskwork
// rights, copyrights and other intellectual property laws.
// 
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design License
// Agreement (either as signed by you, agreed by you upon download or as a
// "click-through" agreement upon installation andor found at www.altera.com).
// By using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference design
// file and please promptly destroy any copies you have made.
// 
// This reference design file is being provided on an "as-is" basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without limitation,
// warranties of merchantability, non-infringement, or fitness for a particular
// purpose, are specifically disclaimed.  By making this reference design file
// available, Altera expressly does not recommend, suggest or require that this
// reference design file be used in combination with any other product not
// provided by Altera.
// ================================================================================
//---------------------------------------------------------------------------
// BT656 Receiver
//---------------------------------------------------------------------------
`timescale 1ns/1ns

module bt656_rx (
		 clk1,
		 reset_n,
//		 Gclk,
		 din,

		 lcc2,
		 v_blank,
		 field,
		 v,
	     h,
		 y,
		 cb,
		 cr,
		 line
		 );

  input clk1;		// 27 MHz
 // input Gclk;
  input reset_n;

  input [7:0] din;

  output      lcc2;
  output      v_blank;
  output      field;
  output      v;
  output      h;
  output [7:0] y;
  output [7:0] cb;
  output [7:0] cr;
  output [8:0]	    line;
  //---------------------------------------------------------------------------
  // Scan input stream to decode timing reference signals
  //---------------------------------------------------------------------------
  reg [1:0]    time_ref;


  parameter idle	= 2'b00,
	    ff		= 2'b01,
	    ff00	= 2'b10,
	    ff0000	= 2'b11;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      time_ref <= idle;
    else
      case (time_ref)
	idle:
	  if (din == 8'hff)
	    time_ref <= ff;

	ff:
	  if (din == 8'h0)
	    time_ref <= ff00;
	  else
	    time_ref <= idle;

	ff00:
	  if (din == 8'h0)
	    time_ref <= ff0000;
	  else
	    time_ref <= idle;

	ff0000:
	  time_ref <= idle;
      endcase

  wire 	    timing_ref = (time_ref == ff0000);

  reg 	    timing_ref_r;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      timing_ref_r <= 1'b0;
    else
      timing_ref_r <= timing_ref;

   wire   clk = clk1;

  //---------------------------------------------------------------------------
  // blanking flags
  //---------------------------------------------------------------------------
  reg 	    field;
  reg 	    v;
  reg 	    h;
  
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      field <= 1'b0;
    else if (timing_ref)
      field <= din[6];
  
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      v <= 1'b0;
    else if (timing_ref)
      v <= din[5];

  wire 	    v_blank = v;
  
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      h <= 1'b0;
    else if (timing_ref)
      h <= din[4];

  //---------------------------------------------------------------------------
  // Input capture registers
  //---------------------------------------------------------------------------
  reg [1:0] input_phase;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      input_phase <= 2'b0;
    else if (h | v)
      input_phase <= 2'b0;
    else
      input_phase <= input_phase + 2'b01;
      
  reg	    lcc2;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
	  lcc2 <= 1'b0;
    else
	lcc2 <= ~lcc2;
  //
  reg [7:0] y_reg;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      y_reg <= 8'b0;
    else if (input_phase[0])
      y_reg <= din;
  
  reg [7:0] cb_reg;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      cb_reg <= 8'b0;
    else if (input_phase == 2'b00)
      cb_reg <= din;
  
  reg [7:0] cr_reg;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      cr_reg <= 8'b0;
    else if (input_phase == 2'b10)
      cr_reg <= din;

  reg [7:0] y;
  reg 	    sav;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      y <= 8'b0;
    else if (input_phase[0] & ~sav & ~timing_ref)
      y <= y_reg;
  
  reg [7:0] cb;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      cb <= 8'b0;
    else if ((input_phase == 2'b11) & ~timing_ref)
      cb <= cb_reg;
  
  reg [7:0] cr;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      cr <= 8'b0;
    else if ((input_phase == 2'b11) & ~timing_ref)
      cr <= cr_reg;
  //sav
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      sav <= 1'b0;
    else if (timing_ref & ((din == 8'h80) | (din == 8'hc7)))
      sav <= 1'b1;
    else if (input_phase == 2'b10)
      sav <= 1'b0;

  reg [8:0]	    line;
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      line <= 9'b0;
    else if (v)
      line <= 9'b0;
    else if (timing_ref_r & sav)
      line <= line + 9'b1;

  
endmodule	// bt656_rx
