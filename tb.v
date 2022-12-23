//2022_10_26 kerong
//sobel tb
//testbench
`timescale 1ns /10ps
`define cycle 10
`define terminateCycle 100000000

`define IN_FILE "./in.txt"

`define DATA_SIZE 3200
`define DATA8_LEN 8

module tb;
reg clk=0;
reg rst;
reg [7:0] indata;
wire [31:0] degree;
wire [1:0] state;
wire [7:0] y_cal;
wire [7:0] x_cal;
wire [6:0] save_x_pos_0;						//存檔的x座標
wire [6:0] save_x_pos_1;
wire [5:0] save_y_pos_0;             	    //存檔的y座標
wire [5:0] save_y_pos_1;				
wire [9:0] sobel_out;
wire [6:0] x_pos;
wire [5:0] y_pos;
wire BW_out;
wire [9:0] bw_take;
wire sobel_check;
integer datCnt;
reg [`DATA8_LEN - 1 : 0] DATA [0 : `DATA_SIZE - 1];

initial begin
	$timeformat(-9, 1, " ns", 9);
	$readmemb(`IN_FILE , DATA);
end

always #(`cycle / 2) clk = ~clk;

Hough U1(.clk(clk), .rst(rst), .indata(indata), .degree(degree), .state(state), .x_cal(x_cal), .y_cal(y_cal), .save_x_pos_0(save_x_pos_0), .save_x_pos_1(save_x_pos_1) , .save_y_pos_0(save_y_pos_0), .save_y_pos_1(save_y_pos_1),.sobel_out(sobel_out),.x_pos(x_pos), .y_pos(y_pos),.BW_out(BW_out),.sobel_check(sobel_check),.bw_take(bw_take));

initial begin
		rst = 1;
	#20 rst = 0;
end

initial begin
	datCnt = 0;
	$display("Start Simulation");
	# `cycle
	# `cycle
	while(datCnt < 9700) begin
		if(datCnt <`DATA_SIZE)begin
			indata	 =  DATA[datCnt];
		end
		# (`cycle)
		if(datCnt>165) begin
			$display("data=%d",datCnt);
		end
		datCnt = datCnt + 1;
	end
	# `cycle
		$display("Simulation is done");
		$finish;
end

endmodule 