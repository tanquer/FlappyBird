`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:32:11 12/23/2017 
// Design Name: 
// Module Name:    Bird 
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
module Bird(
		input wire fresh,
		input wire [9:0] x,
		input wire [8:0] y,
		input wire fly_button,
		input wire RESET,
		input wire START,
		input wire Lose,
		input wire game_status,
		input wire [31:0] clkdiv,
		output reg is_bird,
		output reg [8:0] bird_y
	 );
	 
	 //fix the x coordinate of bird, just let ground and pipe to run
	 parameter bird_x = 10'd120;
	 
	 //the acceleration of gravity
	 parameter a = 9'b1;
	 
	 //the instantaneous speed
	 reg [8:0] velocity;
	 
	 //for every frame
	 always@(negedge fresh) begin	//negedge guarantees the operation are done in the blanking period
		if(game_status)begin
			if(fly_button)begin		//if the fly button is pressed
				velocity <= -9'd4;
				bird_y <= bird_y + velocity;
			end
			else begin
				velocity <= velocity + a;
				bird_y <= bird_y + velocity;
			end
		end else begin
			if( (~Lose) || RESET)begin	//when begin or reset
				bird_y <= 9'd240;
				velocity <= 9'd0;
			end
		end
	 end
	 
	 //for every pixel, determine whether it belongs to bird block
	 always@(posedge clkdiv[0])begin
		if(x >= bird_x && x < bird_x + 10'd48 && y >= bird_y && y < bird_y + 10'd48)begin
			is_bird <= 1'b1;
		end
		else begin
			is_bird <= 1'b0;
		end
	 end

endmodule
