///////////////////////////////////////////////////////////////// 
//*************************************************************************\
//Copyright (c) 2008, Lattice Semiconductor Co.,Ltd, All rights reserved
//
//                   File Name  :  mydefines.v
//                Project Name  :  creator lattice
//                      Author  :  cloud
//                       Email  :  cloud.yu@latticesemi.com
//                      Device  :  Lattice XP2 Family
//                     Company  :  Lattice Semiconductor Co.,Ltd
//==========================================================================
//   Description:  xxxx
//
//   Called by  :   XXXX.v
//==========================================================================
//   Revision History:
//	Date		  By			Revision	Change Description
//--------------------------------------------------------------------------
//2008/5/30	 Cloud		   0.5			Original
//*************************************************************************/
`define COLOR_WIDTH 8//-------color width
`define IMGS_WIDTH 10
`define IMGS_HEIGHT 10
`define IMGT_WIDTH 10
`define IMGT_HEIGHT 10
`define	PRECISION 8
`define	BURST_LENGTH 9
`define	BURST_ADD_LENGTH 22//--------address width
`define	BT656_DELAY_NUM 5                                
`define	VGA_DELAY_NUM 10 
//  
`define SDR_WIDTH                   22//---------sdram address width

`define BT_LINE_LENGTH              1728               

`define SRC_WIDTH				 10
`define SRC_HEIGHT			 10
`define TARGET_WIDTH     10
`define TARGET_HEIGHT		 10	
//  SDRAM INTERFACE defines  
`define tRP  2 
`define tRC  7
`define tMRD 2
`define tRCD 2
`define tWR  2
`define CASn 2
`define BURST_LEN_WIDTH  9   //
`define BASE_ADDR_WIDTH  22  //-------address width  
`define OPCODE           {4'b0000, 3'b011, 1'b0, 3'b000}  //  burst length = 1,CL = 3;
//`define OPCODE           {4'b0000, 3'b010, 1'b0, 3'b000}  //  burst length = 1; 
`define SDR_CLK_WIDTH    1      //
`define SDR_CKE_WIDTH    1      //
`define SDR_CSn_WIDTH    1      //
`define SDR_BA_WIDTH     2      //
`define SDR_A_WIDTH      12     //--------sdram address width
//`define SDR_A_WIDTH_EQ11 1      //  SDR_A_WIDTH == 11  
`define SDR_DQM_WIDTH    2      //  
`define SDR_ROW_WIDTH    12     //-------address row width
`define SDR_COL_WIDTH    8     // -------address col width

`define SDR_DQ_WIDTH     16     //32


//  md_ref_buf 

