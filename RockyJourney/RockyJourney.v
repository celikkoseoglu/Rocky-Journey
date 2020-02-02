module RockyJourney(DP, DISPLAY_POWER, DISPLAY_GROUND, DISPLAY_ENABLED, CLEAR_DISPLAY, DP, RESET_GAME, moveUP, moveDOWN, CLK, OE, SH_CP, ST_CP, reset, DS, KATOT); //here is the port list

input CLK;
input RESET_GAME;
input CLEAR_DISPLAY;
input DISPLAY_ENABLED;

output [3:0] DISPLAY_GROUND;
output [6:0] DISPLAY_POWER;
output DP;
reg [3:0] obstacleCounter;

display_controller display_controller(CLK, CLEAR_DISPLAY, DISPLAY_ENABLED, obstacleCounter, 0, 0, 0, DISPLAY_GROUND, DISPLAY_POWER, DP);

output reg OE;
output reg SH_CP;
output reg ST_CP;
output reg reset;
output reg DS;
output reg [7:0] KATOT;

reg [23:0] colors;
reg [7:0] red;
reg [7:0] blue;
//reg [7:0] green;

reg e;
reg f;

reg [7:0] counter;
reg [24:0] gameClock; //game event tick
reg speed;

reg [8:0] i;
reg [2:0] a;


//GAME LOGIC
reg [2:0] obstacle1CTR, obstacle2CTR, obstacle3CTR;
reg [7:0] obstacleCenter1, obstacleCenter2, obstacleCenter3;
reg [2:0] location;
reg [2:0] tempLocation;
input moveUP, moveDOWN;

initial begin
	location <= 2;
	speed <= 0;
	obstacleCenter1 <= 8'b11100000;
	obstacleCenter2 <= 8'b00011100;
	obstacleCenter3 <= 8'b00000111;
end

always @ (posedge gameClock[24-speed]) begin
	obstacle1CTR <= obstacle1CTR + 1;
	obstacle2CTR <= obstacle2CTR + 1;
	obstacle3CTR <= obstacle3CTR + 1;
	
	tempLocation <= location;
	
	if(obstacleCenter1[tempLocation] == 0 && obstacle1CTR == 6) begin
		obstacleCenter1 <= 8'b00000000;
		obstacleCounter <= 0;
	end
	else if(obstacleCenter2[tempLocation] == 0 && obstacle2CTR == 3) begin
		obstacleCenter2 <= 8'b00000000;
		obstacleCounter <= 0;
	end
	else if(obstacleCenter3[tempLocation] == 0 && obstacle3CTR == 0) begin
		obstacleCenter3 <= 8'b00000000;
		obstacleCounter <= 0;
	end
	else if (obstacle1CTR != 5 && obstacle2CTR != 2 && obstacle3CTR != 7)
		obstacleCounter <= obstacleCounter;
	else
		obstacleCounter <= obstacleCounter + 1;
	
	if (obstacleCounter == 15)
		if (speed < 1)
			speed <= speed + 1;
	
	//RANDOM GENERATION
	if (RESET_GAME)begin
		if (obstacle1CTR == 0) begin
			if (a == 0) begin
				obstacleCenter1 <= 8'b11100000;
			end
			else if (a == 1) begin
				obstacleCenter1 <= 8'b01110000;
			end
			else if (a == 2) begin
				obstacleCenter1 <= 8'b00111000;
			end
			else if (a == 3) begin
				obstacleCenter1 <= 8'b00011100;
			end
			else if (a == 4) begin
				obstacleCenter1 <= 8'b00001110;
			end
			else if (a == 5) begin
				obstacleCenter1 <= 8'b00000111;
			end
		end
		
		if (obstacle2CTR == 0) begin
			if(a == 0) begin
				obstacleCenter2 <= 8'b01110000;
			end
			else if (a == 1) begin
				obstacleCenter2 <= 8'b11100000;
			end
			else if (a == 2) begin
				obstacleCenter2 <= 8'b00111000;
			end
			else if (a == 3) begin
				obstacleCenter2 <= 8'b00001110;
			end
			else if (a == 4) begin
				obstacleCenter2 <= 8'b00011100;
			end
			else if (a == 5) begin
				obstacleCenter2 <= 8'b00000111;
			end
		end
			
		if (obstacle3CTR == 0) begin
			if (a == 0) begin
				obstacleCenter3 <= 8'b11100000;
			end
			else if (a == 1) begin
				obstacleCenter3 <= 8'b00011100;
			end
			else if (a == 2) begin
				obstacleCenter3 <= 8'b00000111;
			end
			else if (a == 3) begin
				obstacleCenter3 <= 8'b01110000;
			end
			else if (a == 4) begin
				obstacleCenter3 <= 8'b00001110;
			end
			else if (a == 5) begin
				obstacleCenter3 <= 8'b00111000;
			end
		end
	end
end

always @ (posedge gameClock[21]) begin
	if(moveUP) begin
		case(location)
			0: location <= 1;
			1: location <= 2;
			2: location <= 3;
			3: location <= 4;
			4: location <= 5;
			5: location <= 6;
			6: location <= 7;
			7: location <= 0;
			default: location <= 0;
		endcase
	end
	else if(moveDOWN) begin
		case(location)
			0: location <= 7;
			1: location <= 0;
			2: location <= 1;
			3: location <= 2;
			4: location <= 3;
			5: location <= 4;
			6: location <= 5;
			7: location <= 6;
			default: location <= 0;
		endcase
	end
end

//END OF GAME LOGIC

always @ (posedge CLK) begin
	counter <= counter + 1;
		  gameClock <= gameClock + 1;
end

always @(posedge e) begin
	if (i < 419)
		i = i + 1;
	else
		i = 9'b000000000;
end

always @ (*) begin
	colors[23:16] <= red;
	//colors[15:8] <= green;
	colors[7:0] <= blue;

	f <= counter[7];
	e <= ~f;

	if (i < 3)
		reset <= 1'b0;
	else
		reset <= 1'b1;

	if (i > 2 && i < 27)
		DS <= colors[i-3];
	else
		DS <= 1'b0;

	if (i < 27) begin
		SH_CP <= f;
		ST_CP <= e;
	end
	else begin
		SH_CP <= 1'b0;
		ST_CP <= 1'b1;
	end

	if (a == 0)
		KATOT <= 8'b10000000;
	else if (a == 1)
		KATOT <= 8'b01000000;
	else if (a == 2)
		KATOT <= 8'b00100000;
	else if (a == 3)
		KATOT <= 8'b00010000;
	else if (a == 4)
		KATOT <= 8'b00001000;
	else if (a == 5)
		KATOT <= 8'b00000100;
	else if (a == 6)
		KATOT <= 8'b00000010;
	else
		KATOT <= 8'b00000001;

end

always @ (posedge f) begin
	if (i > 27 && i < 408)
		OE <= 1'b0;
	else
		OE <= 1'b1;

	if (i == 409)
		if (a < 8)
			a <= a + 1;
		else
			a <= 3'b000;
end

always @ (*) begin
	
	if (a == 0) begin
		if(obstacle1CTR == 7)
			red <= ~obstacleCenter1;
		else if (obstacle2CTR == 4)
			red <= ~obstacleCenter2;
		else if (obstacle3CTR == 1)
			red <= ~obstacleCenter3;
		else
			red <= 8'b00000000;
	end
	else if (a == 1) begin
		if(obstacle1CTR == 6)
			red <= ~obstacleCenter1;
		else if (obstacle2CTR == 3)
			red <= ~obstacleCenter2;
		else if (obstacle2CTR == 0)
			red <= ~obstacleCenter3;
		else
			red <= 8'b00000000;
		case(location)
			0: blue <= 8'b00000001;
			1: blue <= 8'b00000010;
			2: blue <= 8'b00000100;
			3: blue <= 8'b00001000;
			4: blue <= 8'b00010000;
			5: blue <= 8'b00100000;
			6: blue <= 8'b01000000;
			7: blue <= 8'b10000000;
			default: blue <= 8'b00000000;
		endcase
	end
	else if (a == 2) begin
		if(obstacle1CTR == 5)
			red <= ~obstacleCenter1;
		else if (obstacle2CTR == 2)
			red <= ~obstacleCenter2;
		else if (obstacle2CTR == 7)
			red <= ~obstacleCenter3;
		else
			red <= 8'b00000000;
	end
	else if (a == 3) begin
		if(obstacle1CTR == 4)
			red <= ~obstacleCenter1;
		else if (obstacle2CTR == 1)
			red <= ~obstacleCenter2;
		else if (obstacle2CTR == 6)
			red <= ~obstacleCenter3;
		else
			red <= 8'b00000000;
	end
	else if (a == 4) begin
		if(obstacle1CTR == 3)
			red <= ~obstacleCenter1;
		else if (obstacle2CTR == 0)
			red <= ~obstacleCenter2;
		else if (obstacle2CTR == 5)
			red <= ~obstacleCenter3;
		else
			red <= 8'b00000000;
	end
	else if (a == 5) begin
		if(obstacle1CTR == 2)
			red <= ~obstacleCenter1;
		else if (obstacle2CTR == 7)
			red <= ~obstacleCenter2;
		else if (obstacle2CTR == 4)
			red <= ~obstacleCenter3;
		else
			red <= 8'b00000000;
	end
	else if (a == 6) begin
		if(obstacle1CTR == 1)
			red <= ~obstacleCenter1;
		else if (obstacle2CTR == 6)
			red <= ~obstacleCenter2;
		else if (obstacle2CTR == 3)
			red <= ~obstacleCenter3;
		else
			red <= 8'b00000000;
	end
	else begin
		if(obstacle1CTR == 0)
			red <= ~obstacleCenter1;
		else if (obstacle2CTR == 5)
			red <= ~obstacleCenter2;
		else if (obstacle2CTR == 2)
			red <= ~obstacleCenter3;
		else
			red <= 8'b00000000;
	end
end

endmodule
