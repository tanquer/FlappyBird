`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:32:25 12/23/2017 
// Design Name: 
// Module Name:    Ground 
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
module Ground (
	input wire [31:0]clkdiv,
	input wire fresh,
	input wire [9:0] x,
	input wire [8:0] y,
	input wire game_status,
	output reg [9:0] ground_position,
	output reg [3:0] speed,
	output reg is_ground
	);

	//for every frame
	always@(negedge fresh)begin	//negedge guarantees the operation are done in the blanking period
		if(game_status)begin
			ground_position <= (ground_position + speed)%10'd336;
		end
	end

	//for every pixel
	always@(posedge clkdiv[0])begin
		if(y >= 9'd425) begin
			is_ground <= 1'b1;
		end
		else begin
			is_ground <= 1'b0;
		end
		
		if(game_status == 1'b0)begin
			speed <= 4'd3;
		end
	end


endmodule
