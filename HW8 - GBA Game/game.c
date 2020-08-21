#include "game.h"

#include <stdio.h>
#include <stdlib.h>

#include "gba.h"

#define FALSE 0
#define TRUE 1

#include "images/ballpic.h"
#include "images/titlescreen.h"
#include "images/win.h"
#include "images/lose.h"
#include "images/paddlepic.h"
#include "images/background.h"


int main(void) {
  REG_DISPCNT = MODE3 | BG2_ENABLE;																// Manipulate REG_DISPCNT here to set Mode 3. //


  // Load initial game state
  GBAState state = START;
  
  
  char point_buffer[150];
  Player player = {(HEIGHT/2), PADDLE_START_Y, 2, 0};																			//Initialize our player
  
  Ball ball = {HEIGHT/2, WIDTH/2, randint(-2, 2), randint(-2, 2)};												//Initialize the ball, and have it start in the middle with random movement

  NPC npc = {HEIGHT/2, 240 - PADDLE_START_Y};


  while (1) {
	waitForVBlank();
	getKey();
	sprintf(point_buffer, "Points: %d", player.points);											//Update the point buffer

	if (isKeyDown(BUTTON_SELECT) && wasKeyUp(BUTTON_SELECT)) {
    	state = RESTART;
    }
	
    switch (state) {
		//STATE: DEFAULT LAUNCH
		case START:
			drawImageDMA(0, 0, WIDTH, HEIGHT, titlescreen);							// Draw title screen
			drawString((HEIGHT >> 1) + 5, (WIDTH >> 1) - 40, "Press START", BLACK);	// Press start to play :)
			
			state = STARTPART2;
			break;

		//STATE: DEFAULT LAUNCH BEFORE START IS PRESSED
		case STARTPART2:
			if (isKeyDown(BUTTON_START) && wasKeyUp(BUTTON_START)) {
    				state = DRAW_APP;
    		}
			break;
		
		//STATE: DRAWING GAME
		case DRAW_APP:
			//Draw the background 
			drawFullScreenImageDMA(background);
			
			//Draw the point counter
			drawRectDMA(POINT_COUNTER_X, POINT_COUNTER_Y, CHAR_X, CHAR_Y, BLACK);
    		drawString(POINT_COUNTER_X, POINT_COUNTER_Y, point_buffer, WHITE);

			//Draw the two players and the ball to the screen
			drawImageDMA(ball.x, ball.y, BALL_WIDTH, BALL_HEIGHT, ballpic);
			drawImageDMA(player.x, player.y, PADDLE_WIDTH, PADDLE_HEIGHT, paddlepic);
			drawImageDMA(npc.x, npc.y, PADDLE_WIDTH, PADDLE_HEIGHT, paddlepic);
			
			state = PLAY;
			break;
			
		//STATE: MAIN GAME FUNCTIONALITY
		case PLAY:
			//If the ball's dy is 0, the game will softlock
			if(ball.dy == 0) {
				ball.dy = 1;
			}
			
			//Draw over the old paddle and ball positions
			drawRectDMA(ball.x, ball.y, BALL_WIDTH, BALL_HEIGHT, BLACK);
			drawRectDMA(player.x, player.y, PADDLE_WIDTH, PADDLE_HEIGHT, BLACK);
			drawRectDMA(npc.x, npc.y, PADDLE_WIDTH, PADDLE_HEIGHT, BLACK);

			
			//Check if the player won
			if(player.points >= 5) {
				state = WIN;
			}
			
			//Find the movements of each object
			
					//Player
			if(isKeyDown(BUTTON_UP)&& player.x > 20) {
				player.x-=player.dx;
			} else if (isKeyDown(BUTTON_DOWN) && player.x < 90) {
				player.x+=player.dx;
			}
					
					
					//ball
			BallState bs = ballChecks(ball, player, npc);
			if (bs == OUTOFBOUNDS) {
				state = LOSE;
			} else if (bs == HITWALL) {
				//ball.dy = -ball.dy;
				ball.dx = -ball.dx;
			} else if (bs == HITBYPLAYER) {
				ball.dy = -ball.dy;
				ball.dx = -ball.dx + randint(-2, 1);
				player.points++;
				updatePointBuffer(player, point_buffer);
			} else if(bs == HITBYNPC) {
				ball.dy = -ball.dy;
				ball.dx = -ball.dx;
			}
			ball.x+=ball.dx;
			ball.y+=ball.dy;

					//NPC
			npc.x = ball.x - 25;
					

					
			//Draw the images based on the x, y of this cycle
			drawImageDMA(ball.x, ball.y, BALL_WIDTH, BALL_HEIGHT, ballpic);
			drawImageDMA(player.x, player.y, PADDLE_WIDTH, PADDLE_HEIGHT, paddlepic);
			drawImageDMA(npc.x, npc.y, PADDLE_WIDTH, PADDLE_HEIGHT, paddlepic);
			
			
			
			break;
			
		//STATE: PLAYER WINS
		case WIN:
			//draw the win screen 
			drawFullScreenImageDMA(win);
			//sleep(5000);
			state = EXIT;
			
			break;
		
		//STATE: PLAYER LOSES
		case LOSE:
			//draw the lose screen
			drawFullScreenImageDMA(lose);
			//sleep(5000);
			state = EXIT;
			break;
		
		//STATE: WAITING FOR PLAYER TO RESTART
		case EXIT:
			if (isKeyDown(BUTTON_START) && wasKeyUp(BUTTON_START)) {
				state = RESTART;
			}
			break;
			
		//STATE: RESET GAME 
		case RESTART:
			player.points = 0;
			player.x = HEIGHT/2;
			player.y = PADDLE_START_Y;
			npc.x = HEIGHT/2;
			npc.y = 240 - PADDLE_START_Y;
			ball.x = BALL_START_X;
			ball.y = BALL_START_Y;
			ball.dy = randint(-2, 2);
			ball.dx = randint(-2, 2);

			state = START;
			break;
    }
	/*
    previousButtons = currentButtons;  // Store the current state of the buttons
	*/
  }
  /*
  UNUSED(previousButtons);  // You can remove this once previousButtons is used
  */

  return 0;
}

BallState ballChecks(Ball ball, Player player, NPC npc) {
	UNUSED(player);
	UNUSED(npc);
	if (ball.x < 21 || ball.x > 139) {
		return HITWALL;
	} else if (ball.y < 20) {
		return OUTOFBOUNDS;
	} else if (ball.y <= 25 && (ball.x >= player.x) && (ball.x - player.x <= 50)) {
	//ball.x >= player.x) {
		return HITBYPLAYER;
	} else if (ball.y >= 220) {
		return HITBYNPC;
	}
	return NORMAL;
	
}


void updatePointBuffer(Player player, char point_buffer[]) {
	sprintf(point_buffer, "Points: %d", player.points);
	drawRectDMA(POINT_COUNTER_X, POINT_COUNTER_Y, 100, 100, BLACK);
    drawString(POINT_COUNTER_X, POINT_COUNTER_Y, point_buffer, WHITE);
}
	




