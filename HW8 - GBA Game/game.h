#ifndef GAME_H
#define GAME_H

#define POINT_COUNTER_X 5
#define POINT_COUNTER_Y 120

#define CHAR_X 32
#define CHAR_Y 80

#define PADDLE_HEIGHT 50
#define PADDLE_WIDTH 5

#define BALL_HEIGHT 5
#define BALL_WIDTH 5

#define BALL_START_X HEIGHT/2
#define BALL_START_Y WIDTH/2

#define PADDLE_START_Y 20


#include "gba.h"
typedef struct {
	int x;
	int y;
	const int dx;
	int points;
} Player;

typedef struct {
	int x;
	int y;
	int dx;
	int dy;
} Ball;

typedef struct {
	int x;
	int y;
} NPC;

typedef enum {
  START,
  STARTPART2,
  DRAW_APP,
  PLAY,
  WIN,
  LOSE,
  EXIT,
  RESTART
} GBAState;

typedef enum {
	HITBYPLAYER,
	HITBYNPC,
	OUTOFBOUNDS,
	HITWALL,
	NORMAL
} BallState;

BallState ballChecks(Ball ball, Player player, NPC npc);
void updatePointBuffer(Player player, char point_buffer[]);
#endif
