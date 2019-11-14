`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:32:39 12/23/2017 
// Design Name: 
// Module Name:    Column 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Column(
	input wire fresh, 
	input wire [31:0] clkdiv, 
	input wire [9:0] x, 
	input wire [8:0] y, 
	input wire RESET, 
	input wire START, 
	input wire game_status, 
	input wire [3:0] speed, 
	output reg score_out, 
	output reg is_column_up,
	output reg is_column_down,
	output reg [9:0] pipe_x,
	output reg [8:0] pipe_y
	);

	//two pairs of pipes in each frame
	reg [9:0] pipe_x1 = 10'd650;
	reg [9:0] pipe_x2 = 10'd970;
	reg [9:0] pipe_y1=10'd315;
	reg [9:0] pipe_y2=10'd145;

	//for every frame
	always@(negedge fresh)begin		//negedge guarantees the operation are done in the blanking period
		if(game_status) begin		//if the game begin
			pipe_x1 <= (pipe_x1 - speed);	//move the pipe
			pipe_x2 <= (pipe_x2 - speed);
			
			if(pipe_x1 > 10'd971) begin		//if No.1 pipe move out of the screen
				pipe_x1 <= 10'd640;

				//set the height of next pipe
				if(pipe_y1 + 9'd73 > 9'd300)begin
					pipe_y1 <= pipe_y1 + 9'd73 - 9'd190;
				end else if(pipe_y1 > 9'd110)begin
					pipe_y1 <= pipe_y1 + 9'd73;
				end else begin
					pipe_y1 <= 9'd315;
				end
			end 
			
			if(pipe_x2 > 10'd971) begin		//if No.1 pipe move out of the screen
				pipe_x2 <= 10'd640;

				//set the height of next pipe
				if(pipe_y2 + 9'd50 > 9'd300)begin
					pipe_y2 <= pipe_y2 + 9'd50 - 9'd190; 
				end else if(pipe_y2 > 9'd110)begin
					pipe_y2 <= pipe_y2 + 9'd50;
				end else begin
					pipe_y2 <= 9'd145;
				end
			end
			
			//score module
			if((pipe_x1 <= 10'd120 + 10'd48 && pipe_x1 > 10'd120) || (pipe_x2 <= 10'd120 + 10'd48 && pipe_x2 > 10'd120))begin
				score_out <= 1;
			end 
			else if(pipe_x1 + 10'd52 <= 10'd120 || pipe_x2 + 10'd52 <= 10'd120) begin
				score_out <= 0;
			end
		end else begin
			if(RESET)begin
				pipe_x1 <= 10'd650;
				pipe_x2 <= 10'd970;
				pipe_y1 <= 10'd315;
				pipe_y2 <= 10'd145;
				score_out <= 0;
			end
		end
	end
	
	//for every pixel
	always @ (posedge clkdiv[0]) begin
		if(x >= pipe_x1 && x < pipe_x1 + 10'd52)begin
			if(y >= pipe_y1 && y < 9'd425)begin					//the up column of No.1 pipe
				is_column_up <= 1;
				is_column_down <= 0;
				pipe_x <= pipe_x1;
				pipe_y <= pipe_y1;
			end
			else if(y >= 9'd0 && y <= pipe_y1 - 9'd90)begin		//the down column of No.1 pipe
				is_column_down <= 1;
				is_column_up <= 0;
				pipe_x <= pipe_x1;
				pipe_y <= pipe_y1;
			end
			else begin
				is_column_down <= 0;
				is_column_up <= 0;
			end
		end else if(x >= pipe_x2 && x < pipe_x2 + 10'd52)begin	//the up column of No.2 pipe
			if(y >= pipe_y2 && y < 9'd425)begin
				is_column_up <= 1;
				is_column_down <= 0;
				pipe_x <= pipe_x2;
				pipe_y <= pipe_y2;
			end
			else if(y >= 9'd0 && y <= pipe_y2 - 9'd90)begin		//the down column of No.2 pipe
				is_column_down <= 1;
				is_column_up <= 0;
				pipe_x <= pipe_x2;
				pipe_y <= pipe_y2;
			end
			else begin
				is_column_down <= 0;
				is_column_up <= 0;
			end
		end else begin
			is_column_down <= 0;
			is_column_up <= 0;
		end
	end
endmodule
