module Hough(clk, rst, indata, degree,state, x_cal,y_cal,save_x_pos_0,save_x_pos_1,save_y_pos_0,save_y_pos_1,sobel_out,x_pos,y_pos,BW_out,sobel_check,bw_take);
	input clk;											//輸入訊號
	input rst;											//重製
	input [7:0] indata;								//輸入資料
	output signed [31:0] degree;					//輸出角度
	
	output [9:0] sobel_out;							//sobel 輸出資料
	output sobel_check;									//sobel check
	wire bw_out;										//二值化數值
	
	output reg [1:0] state;
	output reg BW_out;
	reg [1:0] nextstate;
	reg [9:0] save [77:0][37:0];					//sobel面積
	output [9:0] bw_take;
	reg BW_save [77:0][37:0];						//二值化面積
	output reg [6:0] x_pos;									//y位置
	output reg [5:0] y_pos;									//x位置
	//reg right_corner;									//右角
	//reg left_corner;									//左角
	output reg [6:0] save_x_pos_0;						//存檔的x座標
	output reg [6:0] save_x_pos_1;
	output reg [5:0] save_y_pos_0;             	    //存檔的y座標
	output reg [5:0] save_y_pos_1;				
	output reg [7:0] x_cal;                				//計算的y
	output reg [7:0] y_cal;								//計算的x

	parameter SOBEL  = 2'd0;						//邊緣偵測
	parameter  BW    = 2'd1;						//二值化
	parameter SEARCH = 2'd2;						//搜尋
	parameter DEGREE = 2'd3;						//計算角度
	//assign BW_out = BW_save[y_pos][x_pos];
	
	sobel sobel_1(clk, rst, indata, sobel_out, sobel_check);		//引用sobel模組
	arctan arctan_1({x_cal,24'd0},{y_cal,24'd0},degree,state);		//引用actan模組
	
	always @(posedge clk, posedge rst)begin
		if(rst)begin
			state <= SOBEL;
		end
		else begin
			state <= nextstate;
		end
	end
	//================<狀態轉移>=====================
	always @(*)begin
		case(state)
			SOBEL:begin
				if(x_pos==7'd77 && y_pos == 6'd37)begin
					nextstate = BW;
				end
				else begin
					nextstate = SOBEL;
				end
			end
			BW:begin
				if(x_pos==7'd0 && y_pos==7'd0)begin
					nextstate = SEARCH;
				end
				else begin
					nextstate = BW;
				end
			end
			SEARCH:begin
				if(x_pos==7'd76 && y_pos == 6'd37)begin
					nextstate = DEGREE;
				end
				else begin
					nextstate = SEARCH;
				end
			end
			DEGREE:begin
				nextstate = DEGREE;
			end
			default:begin
				nextstate = SOBEL;
			end
		endcase
	end
	
	//==================<計算x跟y座標>================
	always @(*)begin
		x_cal = (save_x_pos_1>=save_x_pos_0) ? {1'b0,save_x_pos_1-save_x_pos_0} : {1'b1,~{save_x_pos_0-save_x_pos_1}+1};
		y_cal = (save_y_pos_1<=save_y_pos_0) ? {2'b0,{save_y_pos_0-save_y_pos_1}} : {2'b11,~{save_y_pos_1-save_y_pos_0}+1};
	end
	
	//================<SOBEL資料>=====================
	integer x,y;
	always @(posedge clk, posedge rst)begin
		if(rst)begin
			for(x=0;x<78;x=x+1)begin
				for(y=0;y<38;y=y+1)begin
					save[x][y] <= 10'd0;
				end
			end
		end
		else begin
			if(state==SOBEL)begin
				save[x_pos][y_pos] <= sobel_out;
			end
		end
	end
	assign bw_take = save[x_pos][y_pos];
	//================<二值化>=====================
	always @(*)begin
		if(rst)begin
			for(x=0;x<78;x=x+1)begin
				for(y=0;y<38;y=y+1)begin
					BW_save[x][y] = 1'd0;
				end
			end
			BW_out = 1'd0; 
		end
		else begin
			if(nextstate==BW)begin
				if(save[x_pos][y_pos] >= 10'd200)begin
					BW_save[x_pos][y_pos] = 1'd0;
					BW_out = 1'd0;
				end
				else begin
					BW_save[x_pos][y_pos] = 1'd1;
					BW_out = 1'd1;
				end
			end
		end
	end
	//================<座標點>=====================
	always @(posedge clk, posedge rst)begin
		if(rst)begin
			x_pos <= 7'd0;
			y_pos <= 6'd0;
			save_x_pos_0 <= 7'b111_1111;
			save_x_pos_1 <= 7'b0;
			save_y_pos_0 <= 7'd0;
			save_y_pos_1 <= 7'b111_1111;
		end
		else begin
			case(state)
				SOBEL:begin
					if(x_pos==7'd77 && y_pos == 6'd37)begin
						x_pos <= 7'd77;
						 y_pos <= 6'd37;
					end
					else begin
						if(sobel_check)begin
							if(x_pos < 77)begin
								x_pos <= x_pos + 7'd1;
							end
							else begin
								x_pos <= 7'd0;
								y_pos <= y_pos + 7'd1;
							end
						end
					end
				end
				BW:begin
					if(x_pos==7'd0 && y_pos == 6'd0)begin
						x_pos <= 7'd1;
						 y_pos <= 6'd1;
					end
					else begin
						if(x_pos >0)begin
							x_pos <= x_pos - 7'd1;
						end
						else begin
							x_pos <= 7'd77;
							y_pos <= y_pos - 7'd1;
						end
					end
				end
				SEARCH:begin
					if(BW_save[x_pos-1][y_pos]==1 && BW_save[x_pos-1][y_pos-1]==1 && BW_save[x_pos-1][y_pos-1]==1 && BW_save[x_pos][y_pos]==0)begin
						if(x_pos<save_x_pos_0)begin
							save_x_pos_0 <= x_pos;
							save_y_pos_0 <= y_pos;
						end
					end
					if(BW_save[x_pos+1][y_pos]==1 && BW_save[x_pos+1][y_pos-1]==1 && BW_save[x_pos][y_pos-1]==1 && BW_save[x_pos][y_pos]==0)begin
						if(y_pos<save_y_pos_1)begin
							save_x_pos_1 <= x_pos;
							save_y_pos_1 <= y_pos;
						end
					end
					if(x_pos < 76)begin
						x_pos <= x_pos + 7'd1;
					end
					else begin
						x_pos <= 7'd1;
						y_pos <= y_pos + 7'd1;
					end
				end
			endcase
		end
	end
	
	
endmodule

//2022_10_26 kerong
//FPGA導論期中報告 C110152338 陳科融 四子二丙
//sobel

module sobel(clk,rst,in,out,check);	//image size = 80*40 (x*y)
	input clk,rst;						    		//計時跟重製
	input [7:0] in;			     					//輸入資料

	output check;							//SOBEL開始輸出
	reg [7:0]  data_counter;					//資料輸出計數
	output reg[9:0] out;						//輸出資料 0~255
	reg [1303:0] data;							//資料暫存
	reg [12:0] cnt;						//資料計數
	reg state, nextstate;
		
	reg [7:0] Gh_pos;					//horizontal posedge
	reg [7:0] Gh_neg;					//horizontal negedge
	reg [7:0] Gv_pos;					//vertical   posedge
	reg [7:0] Gv_neg;					//vertical   negedge
	reg [9:0] Gv_data;					//Gv_ans
	reg [9:0] Gh_data;					//Gh_ans
	//==============<資料讀入和移位>==================
	always @(posedge clk,posedge rst)begin
		if(rst)begin
			data    <= 1304'd0;
			data_counter <= 8'd0;
		end
		else begin
			data<={data[1295:0],in};
			if(cnt>163+2)begin						//163筆資料，165個clk後即可輸出
				if(data_counter<77)begin
					data_counter <= data_counter + 1;
				end
				else begin
					if(data_counter<79)begin
						data_counter <= data_counter + 1;
					end
					else begin
						data_counter <= 8'd0;
					end
				end
			end
		end
	end
	assign check = (cnt>165 && data_counter <=77 ) ? 1'b1 : 1'b0;
	//===============<計算Gh>=======================
	always @(posedge clk,posedge rst)begin
		if(rst)begin
			Gh_pos  <= 7'd0;
			Gh_neg  <= 7'd0;
		end
		else begin
			Gh_pos  <= data[1303:1296] + {data[1295:1288],1'b0} + data[1287:1280];
			Gh_neg  <= data[23:16]     + {data[15:8],1'b0}      + data[7:0];
		end
	end

	//===============<計算Gv>=======================
	always @(posedge clk,posedge rst)begin
		if(rst)begin
			Gv_pos  <= 7'd0;
			Gv_neg  <= 7'd0;
		end
		else begin
			Gv_pos  <= data[1303:1296] + {data[663:656],1'b0}   + data[23:16];
			Gv_neg  <= data[1287:1280] + {data[647:640],1'b0}   + data[7:0];
		end
	end

	//===============<計算G)>====================
	always @(posedge clk,posedge rst)begin
		if(rst)begin
			Gh_data <= 9'd0;
			Gv_data <= 9'd0;
			out <= 9'd0;		//輸出
		end
		else begin
			Gh_data <= (Gh_pos >= Gh_neg) ? (Gh_pos - Gh_neg) : (Gh_neg - Gh_pos);
			Gv_data <= (Gv_pos >= Gv_neg) ? (Gv_pos - Gv_neg) : (Gv_neg - Gv_pos);
			out <=  Gh_data + Gv_data;		//輸出
		end
	end

	//=================<計數>===============================
	always @(posedge clk,posedge rst)begin
		if(rst)begin
			cnt <= 8'd0;
		end
		else begin
			cnt <= cnt + 8'd1;
		end
	end

endmodule 


//2022_10_27 kerong
//arctan
module arctan(inx,iny,out,do_state);
	input signed [31:0] inx,iny;
	input [1:0] do_state;
	output reg signed [31:0] out;
	reg signed [39:0] z;
	reg signed [39:0] x_pos,y_pos;
	reg signed [39:0] set_x,set_y;

	reg signed [39:0] x_cpl,y_cpl;

	wire signed [39:0] atan[0:37];
	assign atan[0]=40'b00101101_00000000000000000000000000000000;	//arctan(1/2^0)
	assign atan[1]=40'b00011010_10010000101001110011000110100110;	//arctan(1/2^1)
	assign atan[2]=40'b00001110_00001001010001110100000001111101;	//arctan(1/2^2)
	assign atan[3]=40'b00000111_00100000000000010001001001001001;	//arctan(1/2^3)
	assign atan[4]=40'b00000011_10010011100010101010011001001100;	//arctan(1/2^4)
	assign atan[5]=40'b00000001_11001010001101111001010011100101;	//arctan(1/2^5)
	assign atan[6]=40'b00000000_11100101001010100001101010110001;	//arctan(1/2^6)
	assign atan[7]=40'b00000000_01110010100101101101011110100001;	//arctan(1/2^7)
	assign atan[8]=40'b00000000_00111001010010111010010100011011;	//arctan(1/2^8)
	assign atan[9]=40'b00000000_00011100101001011101100110110111;	//arctan(1/2^9)
	assign atan[10]=40'b00000000_00001110010100101110110111000000;	//arctan(1/2^10)
	assign atan[11]=40'b00000000_00000111001010010111011011111101;	//arctan(1/2^11)
	assign atan[12]=40'b00000000_00000011100101001011101110000010;	//arctan(1/2^12)
	assign atan[13]=40'b00000000_00000001110010100101110111000001;	//arctan(1/2^13)
	assign atan[14]=40'b00000000_00000000111001010010111011100000;	//arctan(1/2^14)
	assign atan[15]=40'b00000000_00000000011100101001011101110000;	//arctan(1/2^15)
	assign atan[16]=40'b00000000_00000000001110010100101110111000;	//arctan(1/2^16)
	assign atan[17]=40'b00000000_00000000000111001010010111011100;	//arctan(1/2^17)
	assign atan[18]=40'b00000000_00000000000011100101001011101110;	//arctan(1/2^18)
	assign atan[19]=40'b00000000_00000000000001110010100101110111;	//arctan(1/2^19)
	assign atan[20]=40'b00000000_00000000000000111001010010111011;	//arctan(1/2^20)
	assign atan[21]=40'b00000000_00000000000000011100101001011101;	//arctan(1/2^21)
	assign atan[22]=40'b00000000_00000000000000001110010100101110;	//arctan(1/2^22)
	assign atan[23]=40'b00000000_00000000000000000111001010010111;	//arctan(1/2^23)
	assign atan[24]=40'b00000000_00000000000000000011100101001011;	//arctan(1/2^24)
	assign atan[25]=40'b00000000_00000000000000000001110010100101;	//arctan(1/2^25)
	assign atan[26]=40'b00000000_00000000000000000000111001010010;	//arctan(1/2^26)
	assign atan[27]=40'b00000000_00000000000000000000011100101001;	//arctan(1/2^27)
	assign atan[28]=40'b00000000_00000000000000000000001110010100;	//arctan(1/2^28)
	assign atan[29]=40'b00000000_00000000000000000000000111001010;	//arctan(1/2^29)
	assign atan[30]=40'b00000000_00000000000000000000000011100101;	//arctan(1/2^30)
	assign atan[31]=40'b00000000_00000000000000000000000001110010;	//arctan(1/2^31)
	assign atan[32]=40'b00000000_00000000000000000000000000111001;	//arctan(1/2^32)
	assign atan[33]=40'b00000000_00000000000000000000000000011100;	//arctan(1/2^33)
	assign atan[34]=40'b00000000_00000000000000000000000000001110;	//arctan(1/2^34)
	assign atan[35]=40'b00000000_00000000000000000000000000000111;	//arctan(1/2^35)
	assign atan[36]=40'b00000000_00000000000000000000000000000011;	//arctan(1/2^36)
	assign atan[37]=40'b00000000_00000000000000000000000000000001;	//arctan(1/2^37)

	integer x;
	always @(*)begin
		if(do_state==2'd3)begin
			out  = 32'd0;
			y_pos = iny;
			x_pos = inx;
			z = 40'd0;
			out = 32'd0;
			//==========<fill bits to 40>==========
			if(inx[31]==0)begin
				x_pos = {inx[31],8'd0,inx[30:0]};
			end
			else begin
				x_pos = {inx[31],8'b1111_1111,inx[30:0]};
			end
			if(iny[31]==0)begin
				y_pos = {iny[31],8'd0,iny[30:0]};
			end
			else begin
				y_pos = {iny[31],8'b1111_1111,iny[30:0]};
			end
			//==========<cordic>==================
			for(x=0;x<38;x=x+1)begin
				//=====<tan data>==============
				if(x_pos[39]==0)begin
					set_x = x_pos >> x;
				end
				else begin
					x_cpl = ~x_pos;
					x_cpl = x_cpl >> x;
					set_x = ~x_cpl;
				end
				if(y_pos[39]==0)begin
					set_y = y_pos >> x;
				end
				else begin
					y_cpl = ~y_pos;
					y_cpl = y_cpl >> x;
					set_y = ~y_cpl;
				end 
				//=====<condition>==========
				if(y_pos>=0)begin
					x_pos = x_pos + set_y;
					y_pos = y_pos - set_x;
					z = z + atan[x];
				end
				else begin
					x_pos = x_pos - set_y;
					y_pos = y_pos + set_x;
					z = z - atan[x];
				end
			end
			//=========<out>==========
			out = z[39:8];
		end
	end

endmodule

