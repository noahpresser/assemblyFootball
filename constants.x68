*-----------------------------------------------------------
* Title      : Constants
* Written by : Noah Presser
* Date       : When Tom assigned this
* Description: This file contains constants for my football game
*-----------------------------------------------------------

SET_OUTPUT_RESOLUTION_TRAP_CODE     equ  33
OUTPUT_WIDTH                        equ  640 
OUTPUT_HEIGHT                       equ  840

;COMMAND
SET_PEN_COLOR_COMMAND               equ 80
SET_PEN_WIDTH_COMMAND               equ 93
SET_FILL_COLOR_COMMAND              equ 81
DRAW_CIRCLE_COMMAND                 equ 88
TIME_SINCE_MIDNIGHT_CODE            equ 8
DRAW_LINE_COMMAND                   equ 84
DRAW_RECTANGLE_COMMAND              equ 87
CLEAR_SCREEN_COMMAND    		    equ 11
CLEAR_SCREEN_MAGIC_VAL  			equ $FF00
DRAWING_MODE_TRAP_CODE				equ	92
DOUBLE_BUFFERED_MODE				equ	17
REPAINT_SCREEN_TRAP_CODE			equ	94

KEY_SCAN_CODE 						equ 19
WASD_LONG equ  						$57415344 ;this is 'W' = 87 in the top byte, 'A' = 65 in the next byte, etc
SPACEH_LONG equ                     $4A4B4820 ;this is 'J' 'K' 'H' SPACE 

;player vars
PLAYER_WIDTH						equ	30
PLAYER_HEIGHT						equ	30
PLAYER_LEFT_X_POS 					equ $0
PLAYER_TOP_Y_POS					equ	$0
PLAYER_X_ACCELLERATION 				equ $8
PLAYER_Y_ACCELLERATION 				equ $8
PLAYER_X_DRAG 						equ $4
PLAYER_Y_DRAG 						equ $4
PLAYER_MAX_SPEED_X 					equ $0090
PLAYER_MIN_SPEED_X 					equ $FF70
PLAYER_MAX_SPEED_Y 					equ $0078
PLAYER_MIN_SPEED_Y 					equ $FF82 

BALLSTATE_QB 						equ 0
BALLSTATE_FLY 						equ 1
BALLSTATE_CAUGHT 					equ 2
BALLSTATE_TIMEOUT 					equ 3

;for displaying the menu
GAMESTATE_MENU                      equ 0
GAMESTATE_CLEAR_MENU                equ 1
GAMESTATE_PLAY                      equ 2
GAMESTATE_DRAW_MENU                 equ 3

;menu positions
MENU_XPOS                           equ 65
MENU_1_YPOS                         equ 110
MENU_2_YPOS                         equ 468
MENU_WIDTH                          equ 500
MENU_HEIGHT                         equ 310

;highscore positions
YOURSCORE_XPOS                      equ 40
YOURSCORE_YPOS                      equ 385
HIGHSCORE_XPOS                      equ 400
HIGHSCORE_YPOS                      equ 380
HIGHSCORE_WIDTH                     equ 200
HIGHSCORE_HEIGHT                    equ 124
HIGHSCORE_DIGIT_XPOS                equ 500
HIGHSCORE_DIGIT_YPOS                equ 438
YOURSCORE_DIGIT_XPOS                equ 140
YOURSCORE_DIGIT_YPOS                equ 443

;offsets for the player carrying the football
FOOTBALL_CARRY_OFFSET_X 			equ 256*25
FOOTBALL_CARRY_OFFSET_Y 			equ 256*10
FOOTBALL_WIDTH                      equ 9
FOOTBALL_HEIGHT                     equ 21

LINE_OF_SCRIMMAGE_HEIGHT 			equ 2

;create different values for different throw states
FASTBALL_SPEED                      equ $FFFFF900
SLOWBALL_SPEED                      equ $FFFFFB00
BALL_Y_SPEED_BASE					equ -$120
BALL_FLIGHT_DIST 					equ 510
RIGHT_SIDE_OF_FIELD					equ	603
LEFT_SIDE_OF_FIELD 					equ 37
FIFTY_YARD_LINE_LOCATION            equ 444
TOP_OF_FIELD 						equ 69
BOTTOM_OF_FIELD 				    equ 825
TOUCHDOWN_POS 						equ 132
TOUCHBACK_POS 						equ 753
NEAR_ENDZONE_POS                    equ 757
LEFT_RECEIVER_MAX_POS 				equ 595-PLAYER_WIDTH
RIGHT_RECEIVER_MAX_POS 				equ 70
TOP_RECEIVER_MAX_POS 				equ 74

;defender vars
CHASE_SPEED_LEFT    				equ $FFFFFF80
CHASE_SPEED_RIGHT   				equ $00000080
CHASE_SPEED_UP      				equ $FFFFFF85
CHASE_SPEED_DOWN    				equ $00000077
    
LINEBACKER_CHASE_SPEED_LEFT  		equ $FFFFFFF8 ;make it player speed / 2
LINEBACKER_CHASE_SPEED_RIGHT 		equ $00000008 ;make it player speed / 2
LINEBACKER_CHASE_SPEED_UP    		equ $FFFFFFB0
LINEBACKER_CHASE_SPEED_DOWN  		equ $000000B0

RECEIVER_SPEED_RIGHT         		equ $00000100
RECEIVER_SPEED_LEFT          		equ $FFFFFF00

SQUISHPOS_1 						equ 479*256
SQUISHPOS_2 						equ 340*256
SQUISHPOS_3 						equ 190*256
SQUISHPOS_4 						equ 180*256


LINEBACKERSTATE_STRAFE 				equ 0
LINEBACKERSTATE_BLITZ 				equ 1

SHOTGUN_OFFSET_1  					equ $5000
SHOTGUN_OFFSET_2  				    equ $3200
DROPBACK_VELOCITY_Y                 equ $01000000



;number positions
SECOND_NUMBER_OFFSET                equ 30
SCORE_POSX_1         				equ 334
SCORE_POSX_2         				equ 364  
DOWN_POSX            				equ 123
DOWN_POSY            				equ 11
TIMER_SECONDS_POSX_1 				equ 595
TIMER_SECONDS_POSX_2 				equ 565
TIMER_MINUTES_POSX   				equ 530

UI_LENGTH                           equ 30

FIRST_DOWN_YARDS                    equ 62*256*5/2      ;62 is ten yards
INITIAL_FIRST_DOWN                  equ 505*256

;times for timers
ROUND_TIME_IN_HUNDREDTHS        	equ 90*100     
SCORE_FLASH_TIMER                   equ 1*100
DOWN_FLASH_TIMER                    equ 1*100
TIMER_FLASH_TIMER                   equ 1*100
SNAP_DEBOUNCE_TIMER                 equ 35             ;a quarter second after the snap, the player can throw   
;colors
RED                                 equ $000000FF
YELLOW                              equ $0000FFFF
PATH_COLOR      					equ RED
FIELD_GREEN     					equ $0000B05C
WHITE								equ	$00FFFFFF
BLUE      						 	equ $00FF0000
PANTHERS      						equ $00FCBF25
BADGUYS 							equ $000077E0
PIGSKIN 							equ $00080A3A
DONT_DRAW_COLOR                     equ $00C9AEFF












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
