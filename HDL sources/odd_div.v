/*
		__|``|__|``|__|``|__|``|__|``|__|``|__|``|__|``|__|``|__|``|__|``|__|``|__|``|__|``|__|``|__|``|__|
		
		__|`````|___________|`````|___________|`````|___________|`````|___________|`````|___________|`````|


		_____|`````|____________|`````|___________|`````|___________|`````|___________|`````|___________|``

		

		
*/
module odd_div #(
parameter DIV_NUM = 5
)
(
clk,
rst_n,
clkout
);

input       	clk;
input				rst_n;
output			clkout;

reg				clkout1;
reg				clkout2;

reg	[31:0]	cnt1;
reg	[31:0]	cnt2;

wire	[31:0]	cnt_loop;
wire	[31:0]	cnt_turn;


assign	cnt_loop	= (DIV_NUM - 1'b1);
assign	cnt_turn	= (DIV_NUM - 1'b1)/2 - 1'b1;

always @(posedge clk)
if(!rst_n)
begin
	 cnt1		<= 0;
	 clkout1	<= 0;
end
else
begin
	if(cnt1 == cnt_loop/*2*/)
		cnt1	<= 0;
	else
		cnt1	<= cnt1 + 1;

	if(cnt1 == 0 || cnt1 == cnt_turn/*1*/)//????1/3?2/3?????
		clkout1	<= ~ clkout1;
end  


always @(negedge clk)
if(!rst_n)
begin
	 cnt2		<= 0;
	 clkout2	<= 0;
end
else
begin
	if(cnt2 == cnt_loop/*2*/)
		cnt2	<= 0;
	else
		cnt2	<= cnt2 + 1;

	if(cnt2 == 0 || cnt2 == cnt_turn/*1*/)//????1/3?2/3?????
		clkout2	<= ~ clkout2;
end  

assign  clkout = clkout1 | clkout2;  //?????50%?3???????6?????

endmodule
