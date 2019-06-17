`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module maze(ClkPort, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b, Sw0, Sw1, btnU, btnL, btnD, btnR,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7);
	input ClkPort, Sw0, btnU, btnL, btnD, btnR, Sw0, Sw1;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	reg vga_r, vga_g, vga_b;

	//////////////////////////////////////////////////////////////////////////////////////////

	/*  LOCAL SIGNALS */
	wire	reset, start, ClkPort, board_clk, clk, button_clk;

	BUF BUF1 (board_clk, ClkPort);
	BUF BUF2 (reset, Sw0);
	BUF BUF3 (start, Sw1);

	reg [27:0]	DIV_CLK;
	always @ (posedge board_clk, posedge reset)
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1'b1;
	end

	assign	button_clk = DIV_CLK[18];
	assign	clk = DIV_CLK[1];
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};

	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;

	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));

	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	reg [9:0] posX;
	reg [9:0] posY;
	reg [9:0] posX_t;
	reg [9:0] posY_t;
	reg [9:0] cntr;
	reg succeed;
	reg [21:0] squared_radius;
	wire [21:0] square_x = (CounterX - posX)*(CounterX - posX);
	wire [21:0] square_y = (CounterY - posY)*(CounterY - posY);
	always @(posedge DIV_CLK[21])
		begin
			if (reset)
			begin
			  	posX <= 80;
				posY <= 32;
				cntr <= 0;
				succeed <= 0;
				squared_radius <= 10000;
			end
			else if (btnD && ~btnU)
			begin
				posY_t = posY + 16;
				posX_t = posX;
				if (isWall == 1'b0)
				begin
				  posY <= posY + 16;
				  cntr <= cntr + 1;
				end
				if (isGoal == 1'b1)
				begin
				  succeed <= 1;
				end
			end
			else if (btnU && ~btnD)
			begin
				posY_t = posY - 16;
				posX_t = posX;
				if (isWall == 1'b0)
				begin
				  posY <= posY - 16;
				  cntr <= cntr + 1;
				end
				if (isGoal == 1'b1)
				begin
				  succeed <= 1;
				end
			end
			else if (btnL && ~btnR)
			begin
			  	posY_t = posY;
				posX_t = posX - 16;
				if (isWall == 1'b0)
				begin
				  posX <= posX - 16;
				  cntr <= cntr + 1;
				end
				if (isGoal == 1'b1)
				begin
				  succeed <= 1;
				end
			end
			else if (btnR && ~btnL)
			begin
			  	posY_t = posY;
				posX_t = posX + 16;
				if (isWall == 1'b0)
				begin
				  posX <= posX + 16;
				  cntr <= cntr + 1;
				end
				if (isGoal == 1'b1)
				begin
				  succeed <= 1;
				end
			end
		end

	wire isWall = (posX_t >= 0 && posX_t <= 15 && posY_t >= 256 && posY_t <= 479)
	|| (posX_t >= 48 && posX_t <= 63 && posY_t >= 0 && posY_t <= 192)
	|| (posX_t >= 48 && posX_t <= 63 && posY_t >= 320 && posY_t <= 479)
	|| (posX_t >= 96 && posX_t <= 111 && posY_t >= 0 && posY_t <= 143)
	|| (posX_t >= 240 && posX_t <= 255 && posY_t >= 192 && posY_t <= 271)
	|| (posX_t >= 240 && posX_t <= 255 && posY_t >= 320 && posY_t <= 399)
	|| (posX_t >= 288 && posX_t <= 303 && posY_t >= 128 && posY_t <= 207)
	|| (posX_t >= 288 && posX_t <= 303 && posY_t >= 256 && posY_t <= 319)
	|| (posX_t >= 480 && posX_t <= 495 && posY_t >= 384 && posY_t <= 479)
	|| (posX_t >= 528 && posX_t <= 543 && posY_t >= 320 && posY_t <= 479)
	|| (posX_t >= 576 && posX_t <= 591 && posY_t >= 0 && posY_t <= 207)
	|| (posX_t >= 624 && posX_t <= 639 && posY_t >= 0 && posY_t <= 255)
	|| (posX_t >= 96 && posX_t <= 303 && posY_t >= 128 && posY_t <= 143)
	|| (posX_t >= 48 && posX_t <= 255 && posY_t >= 192 && posY_t <= 207)
	|| (posX_t >= 288 && posX_t <= 591 && posY_t >= 192 && posY_t <= 207)
	|| (posX_t >= 0 && posX_t <= 255 && posY_t >= 256 && posY_t <= 271)
	|| (posX_t >= 288 && posX_t <= 639 && posY_t >= 256 && posY_t <= 271)
	|| (posX_t >= 48 && posX_t <= 255 && posY_t >= 320 && posY_t <= 335)
	|| (posX_t >= 288 && posX_t <= 543 && posY_t >= 320 && posY_t <= 335)
	|| (posX_t >= 240 && posX_t <= 495 && posY_t >= 384 && posY_t <= 399)
	;

	wire isGoal = posX_t >= 496 && posX_t <= 527 && posY_t >= 464 && posY_t <= 479
	;

	wire G_t = ((CounterX >= 0 && CounterX <= 15 && CounterY >= 256 && CounterY <= 479)
	|| (CounterX >= 48 && CounterX <= 63 && CounterY >= 0 && CounterY <= 192)
	|| (CounterX >= 48 && CounterX <= 63 && CounterY >= 320 && CounterY <= 479)
	|| (CounterX >= 96 && CounterX <= 111 && CounterY >= 0 && CounterY <= 143)
	|| (CounterX >= 240 && CounterX <= 255 && CounterY >= 192 && CounterY <= 271)
	|| (CounterX >= 240 && CounterX <= 255 && CounterY >= 320 && CounterY <= 399)
	|| (CounterX >= 288 && CounterX <= 303 && CounterY >= 128 && CounterY <= 207)
	|| (CounterX >= 288 && CounterX <= 303 && CounterY >= 256 && CounterY <= 319)
	|| (CounterX >= 480 && CounterX <= 495 && CounterY >= 384 && CounterY <= 479)
	|| (CounterX >= 528 && CounterX <= 543 && CounterY >= 320 && CounterY <= 479)
	|| (CounterX >= 576 && CounterX <= 591 && CounterY >= 0 && CounterY <= 207)
	|| (CounterX >= 624 && CounterX <= 639 && CounterY >= 0 && CounterY <= 255)
	|| (CounterX >= 96 && CounterX <= 303 && CounterY >= 128 && CounterY <= 143)
	|| (CounterX >= 48 && CounterX <= 255 && CounterY >= 192 && CounterY <= 207)
	|| (CounterX >= 288 && CounterX <= 591 && CounterY >= 192 && CounterY <= 207)
	|| (CounterX >= 0 && CounterX <= 255 && CounterY >= 256 && CounterY <= 271)
	|| (CounterX >= 288 && CounterX <= 639  && CounterY >= 256 && CounterY <= 271)
	|| (CounterX >= 48 && CounterX <= 255 && CounterY >= 320 && CounterY <= 335)
	|| (CounterX >= 288 && CounterX <= 543 && CounterY >= 320 && CounterY <= 335)
	|| (CounterX >= 240 && CounterX <= 495 && CounterY >= 384 && CounterY <= 399))
	;


	wire R_t = ((CounterX >= 64 && CounterX <= 95 && CounterY >= 0 && CounterY <= 15)
	|| (CounterX >= posX - 8 && CounterX <= posX + 7 && CounterY >= posY && CounterY <= posY + 15))
	;
	wire B_t = (CounterX >= 496 && CounterX <= 527 && CounterY >= 464 && CounterY <= 479)
	;

	wire G = (~R_t) & (~B_t) && ((square_x + square_y <= squared_radius) || succeed);
	wire R = (~G_t) & (~B_t) && ((square_x + square_y <= squared_radius) || succeed);
	wire B = (~G_t) & (~R_t) && ((square_x + square_y <= squared_radius) || succeed);

	always @(posedge clk)
	begin
		vga_r <= R & inDisplayArea;
		vga_g <= G & inDisplayArea;
		vga_b <= B & inDisplayArea;
	end

	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////

	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	`define QI 			2'b00
	`define QGAME_1 	2'b01
	`define QGAME_2 	2'b10
	`define QDONE 		2'b11

	reg [3:0] p2_score;
	reg [3:0] p1_score;
	reg [1:0] state;
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;

	assign LD0 = (p1_score == 4'b1010);
	assign LD1 = (p2_score == 4'b1010);

	assign LD2 = start;
	assign LD4 = reset;

	assign LD3 = (state == `QI);
	assign LD5 = (state == `QGAME_1);
	assign LD6 = (state == `QGAME_2);
	assign LD7 = (state == `QDONE);

	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////

	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;

	assign SSD3 = 4'b1111;
	assign SSD2 = {2'b00, cntr[9:8]};
	assign SSD1 = cntr[7:4];
	assign SSD0 = cntr[3:0];

	// need a scan clk for the seven segment display
	// 191Hz (50MHz / 2^18) works well
	assign ssdscan_clk = DIV_CLK[19:18];
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An2	= !( (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	= !( (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11

	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk)
			2'b00:
					SSD = SSD0;
			2'b01:
					SSD = SSD1;
			2'b10:
					SSD = SSD2;
			2'b11:
					SSD = SSD3;
		endcase
	end

	// and finally convert SSD_num to ssd
	reg [6:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES, 1'b1};
	// Following is Hex-to-SSD conversion
	always @ (SSD)
	begin : HEX_TO_SSD
		case (SSD)
			4'b1111: SSD_CATHODES = 7'b1111111 ; //Nothing
			4'b0000: SSD_CATHODES = 7'b0000001 ; //0
			4'b0001: SSD_CATHODES = 7'b1001111 ; //1
			4'b0010: SSD_CATHODES = 7'b0010010 ; //2
			4'b0011: SSD_CATHODES = 7'b0000110 ; //3
			4'b0100: SSD_CATHODES = 7'b1001100 ; //4
			4'b0101: SSD_CATHODES = 7'b0100100 ; //5
			4'b0110: SSD_CATHODES = 7'b0100000 ; //6
			4'b0111: SSD_CATHODES = 7'b0001111 ; //7
			4'b1000: SSD_CATHODES = 7'b0000000 ; //8
			4'b1001: SSD_CATHODES = 7'b0000100 ; //9
			4'b1010: SSD_CATHODES = 7'b0001000 ; //10 or A
			default: SSD_CATHODES = 7'bXXXXXXX ; // default is not needed as we covered all cases
		endcase
	end

	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
endmodule
