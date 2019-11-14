`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:07:49 12/22/2017 
// Design Name: 
// Module Name:    top 
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
/*
	background 288 * 512
	land 336 * 112
	bird 48 * 48
	pipe 52 * 320

*/

module top(
	input clk,
	input rstn,
	inout [4:0]BTN_X,
	inout [3:0]BTN_Y,
	input wire [15:0] SW,
	output hs,
	output vs,
	output [3:0] r,
	output [3:0] g,
	output [3:0] b,
	output [3:0] AN,
	output [7:0] SEGMENT,
	output buzzer
    );
	 
	 assign buzzer = 1'b1;
	 
	 //clock division
	 reg [31:0] clkdiv;
	 always @(posedge clk) begin
		clkdiv <= clkdiv + 1'b1;
	 end
	 
	 //register to store status
	 reg game_status;
	 reg trigger_start;
	 reg Lose;
	 
	 //the x,y number in VGA screen (640px * 480px)
	 wire [9:0] x;
	 wire [8:0] y;

	 //the RGBA of background
	 wire [15:0] bk_color;
	 
	 //the pretreatment of switch
	 wire [15:0] switch;
	 AntiJitter #(4) a0[15:0](.clk(clkdiv[0]), .I(SW), .O(switch));
	 
	 //set the button and pretreatment
	 wire start;
	 wire fly;
	 wire [4:0] keyCode;
	 wire keyReady;
	 Keypad k0 (.clk(clkdiv[15]), .keyX(BTN_Y), .keyY(BTN_X), .keyCode(keyCode), .ready(keyReady));
	 
	 assign start = keyReady;
	 assign fly = keyReady;
	 
	 //set reset button	
	 wire RESET;
	 assign RESET = switch[15];
	 

	 //VGA controller module
	 wire vga_vedio_on;
	 Vga (clkdiv[1] , switch[0], y, x, vga_vedio_on, hs, vs);
	 
	 //count the score
	 wire score_out;
	 reg [15:0] score;
	 always@(posedge RESET or negedge score_out)begin
		if(RESET == 1'b1) begin
			score <= 16'b0;
		end else begin
			score <= score + 1'b1;
		end
	 end
	 
	 //set a var to store whether such pixel(x,y) is near the top of screen
	 wire is_top;
	 assign is_top = (y <= 9'd8) ? 1'b1 : 1'b0;

	 //set a var to monitor whether the bird has been crashed
	 wire trigger_stop;
     assign trigger_stop = ((is_bird && bird_color[15:12] != 4'b0000) && is_column_down) || ((is_bird && bird_color[15:12] != 4'b0000) && is_column_up) || ((is_bird && bird_color[15:12] != 4'b0000) && is_ground) || (is_bird && is_top);
	 
	 //Controller of the whole game status
     always @(posedge clk) begin
        if (start) begin //if button START is pressed
            if(game_status==1'b0)begin
                trigger_start<=1'b1;
            end
        end

        if (trigger_stop) begin
            game_status<=1'b0;
				Lose <= 1'b1;
        end

        //only start the game in the blanking period
        if (vs==1'b0) begin
            if (trigger_start==1'b1) begin
                if (game_status==1'b0) begin
                    game_status<=1'b1;//begin the game
                end else begin
                    trigger_start<=1'b0;
                end
            end
        end

        //reset the game
        if (RESET) begin//if button RESET is pressed
            game_status<=1'b0;
            trigger_start<=1'b0;
				Lose <= 1'b0;
        end
     end
	 
	 //Every 16 frames, the counter will plus one and be used to make dynamic effect
	 reg [1:0] counter;
	 reg [3:0] cnt = 0; //count 16 times to let &cnt == 1
	 always@(negedge vs)begin
		if (&cnt) begin	//every 16 frames
			cnt <= 1'b0;
			if(Lose == 1'b0)begin
				if(counter < 2'b10) begin
					counter <= counter + 1'b1;
				end
				else begin
					counter <= 2'b0;
				end
			end
		end
		cnt <= cnt + 1'b1;
	 end

	 //Bird Controller Module
	 wire [15:0]bird_color;
	 wire is_bird;
	 parameter bird_x = 10'd120;
	 wire [8:0] bird_y;
	 
	 Bird bird(
		.fresh(vs),
		.x(x),
		.y(y),
		.fly_button(fly),
		.RESET(RESET),
		.START(start),
		.Lose(Lose),
		.game_status(game_status),
		.clkdiv(clkdiv),
		.is_bird(is_bird),
		.bird_y(bird_y)
	 );
	 
	 //Ground Controller module
	 wire [15:0] ground_color;
	 wire [3:0] speed;
	 wire is_ground;
	 wire [9:0] ground_position;
	 Ground ground(
		clkdiv, vs, x, y, game_status, ground_position, speed, is_ground
	 );
	 
	 //Pipe Controller module
	 wire [15:0] pipe_up_color;
	 wire [15:0] pipe_down_color;
	 wire is_column_up;
	 wire is_column_down;
	 wire [9:0] pipe_x;
	 wire [8:0] pipe_y;
	 Column column(vs, clkdiv, x, y, RESET, start, game_status, speed, score_out, is_column_up, is_column_down, pipe_x, pipe_y);
	 
	 //Extract the RGBA data of such pixel 
	 background b6(.clka(clk), .addra(y * 288 + (x%288)), .douta(bk_color));
	 birdrom birdrom(.clka(clk), .addra((48*48)*counter - 1 + (y-bird_y) * 48 + (x-bird_x)), .douta(bird_color));
	 land_rom landrom(.clka(clk), .addra((y-10'd425)*336 + ((x+ground_position)%336)), .douta(ground_color));
	 pipe_up_rom pipeup(.clka(clk), .addra((y-pipe_y)*52 + x - pipe_x), .douta(pipe_up_color));
	 pipe_down_rom pipedown(.clka(clk), .addra(16639 - ((pipe_y - 90) * 52) + y * 52 + x - pipe_x + 1), .douta(pipe_down_color));
	 
	 //use multiplexer to set the r, g, b for every pixel; [3:0] of every 16bit color var is the A (transparency) of such pixel
	 assign r =  vga_vedio_on ? 4'h0 : 
						(is_bird && bird_color[15:12] != 4'b0000) ? bird_color[3:0] :						//if pixel belongs to bird block and its transparency is not 0
						(is_ground && ground_color[15:12] != 4'b0000) ? ground_color[3:0] :					//if pixel belongs to ground block and its transparency is not 0
						(is_column_up && pipe_up_color[15:12] != 4'b0000) ? pipe_up_color[3:0] :			//if pixel belongs to pipe_up block and its transparency is not 0
						(is_column_down && pipe_down_color[15:12] != 4'b0000) ? pipe_down_color[3:0] :		//if pixel belongs to pipe_down block and its transparency is not 0
									bk_color[3:0]; 															// otherwise it belongs to background
     
	 assign g = vga_vedio_on ? 4'h0 : 
						(is_bird && bird_color[15:12] != 4'b0000) ? bird_color[7:4] :
						(is_ground && ground_color[15:12] != 4'b0000) ? ground_color[7:4] :
						(is_column_up && pipe_up_color[15:12] != 4'b0000) ? pipe_up_color[7:4] :
						(is_column_down && pipe_down_color[15:12] != 4'b0000) ? pipe_down_color[7:4] :
								bk_color[7:4];
     
	 assign b = vga_vedio_on ? 4'h0 : 
						(is_bird && bird_color[15:12] != 4'b0000) ? bird_color[11:8] :
						(is_ground && ground_color[15:12] != 4'b0000) ? ground_color[11:8] :
						(is_column_up && pipe_up_color[15:12] != 4'b0000) ? pipe_up_color[11:8] :
						(is_column_down && pipe_down_color[15:12] != 4'b0000) ? pipe_down_color[11:8] :
								bk_color[11:8];

	 //display the score number on the board
	 ScoreBoard scoreboard(.clk_100mhz(clk), 
                 .HEXS(score), 
                 .LES(4'b1111), 
                 .points(0), 
                 .RSTN(0), 
                 .AN(AN), 
                 .SEGMENT(SEGMENT));
					  

endmodule
