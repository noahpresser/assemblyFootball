*-----------------------------------------------------------
* Title      : Drawing
* Written by : Noah Presser
* Date       : Slightly after when Tom assigned this
* Description: Contains Draw Functions that reference 'noahBitmap.x68'
*-----------------------------------------------------------

;sets coordinates for being used with draw bitmap background
;d1 is xPos, d2 yPos, d3 width, d4 height
setPieceCoordinates
    lsr.l   #8, d1
    move.l  d1, xPosOfPiece
    move.w  d1, screenX
    lsr.l   #8, d2 
    move.l  d2, yPosOfPiece
    move.w  d2, screenY
    move.l  d3, widthOfPiece
    move.l  d4, heightOfPiece
    rts
    
;draws a piece of the bitmap given
;d1 xpos, d2 ypos, d3 width, d4 height
drawAPiece
    jsr     setPieceCoordinates
    jsr     drawBitmapPiece
    rts
    
;draws a piece of the bitmap given parameters for a player/receiver
;d1 xpos, d2 ypos, d3 width, d4 height
drawAPlayer
    jsr     setPieceCoordinates
    jsr     drawPlayerBitmap
    rts
    
;draws a bitmap at x, y space given
;d1 xpos, d2 ypos, d3 width, d4 height    
drawAMenu
    jsr     setPieceCoordinates
    move.l  #0, xPosOfPiece
    move.l  #0, yPosOfPiece
    jsr     drawMenuBitmap
    rts

;d1 x1, d2 y1, d3 x2, d4 y2
drawLine
    cmp.l   #TOP_RECEIVER_MAX_POS, d2
    bge normalLine1
    move.l  #TOP_RECEIVER_MAX_POS, d2
normalLine1
    cmp.l   #TOP_RECEIVER_MAX_POS, d4
    bge     normalLine
    move.l  #TOP_RECEIVER_MAX_POS, d4
normalLine
    move.l  #DRAW_LINE_COMMAND, d0
    trap    #15
    rts

;draws a path given receiver patterns from the file
;d0 xpos, d1 ypos, d2 turnpos, d3 xvel, d4 yvel
drawPath
    move.l  d0, d5
    move.l  d1, d6
    move.l  d2, d7
    jsr     getXCoordAtYFromVelocity
    
    move.l  d5, d1
    asr.l   #8, d1
    move.l  d6, d2
    asr.l   #8, d2
  
    asr.l   #8, d3
    move.l  d7, d4
    asr.l   #8, d4
    
    jsr     drawLine
    rts

;draws all receiver paths 
drawPaths
    move.l  #SET_PEN_WIDTH_COMMAND, d0
    move.l  #LINE_OF_SCRIMMAGE_HEIGHT, d1
    trap    #15
    
    move.l  #SET_PEN_COLOR_COMMAND, d0
    move.l  #PATH_COLOR, d1
    trap    #15
    
    
    movem.l d5-d7, -(sp)
    ;receiver1 path1 
    move.l  receiver1Xpos, d0
    move.l  receiver1Ypos, d1
    move.l  receiver1YTurnPos, d2
    move.l  receiver1XVel1, d3
    move.l  receiver1YVel1,  d4
    
    ;move to player middle
    move.l  #(PLAYER_WIDTH)<<8, d5
    lsr.l   #1, d5
    add.l   d5, d0
            
    move.l  #(PLAYER_HEIGHT)<<8, d5
    lsr.l   #1, d5
    add.l   d5, d1
    add.l   d5, d2
    jsr     drawPath
    
    move.l  d1, path1X1
    move.l  d2, path1Y1
    move.l  d3, path1X2
    move.l  d4, path1Y2
    
    lsl.l   #8, d3
    move.l  d3, d0
    move.l  receiver1YTurnPos, d1
    move.l  d1, d2

    move.l  #(PLAYER_HEIGHT)<<8, d5
    lsr.l   #1, d5
    add.l   d5, d1
    add.l   d5, d2

    ;determine if the receiver is going up or down
    move.l  receiver1YVel2, d3
    asl.l   #7, d3                          ;get the line direction
    add.l   d3, d2

    move.l  receiver1XVel2, d3
    move.l  receiver1YVel2,  d4

    jsr     drawPath
    
    move.l  d3, path1X3
    move.l  d4, path1Y3
    
    
    ;receiver 2 paths
    move.l  receiver2Xpos, d0
    move.l  receiver2Ypos, d1
    move.l  receiver2YTurnPos, d2
    move.l  receiver2XVel1, d3
    move.l  receiver2YVel1,  d4
    
    ;move to player middle
    move.l  #(PLAYER_WIDTH)<<8, d5
    lsr.l   #1, d5
    add.l   d5, d0
            
    move.l  #(PLAYER_HEIGHT)<<8, d5
    lsr.l   #1, d5
    add.l   d5, d1
    add.l   d5, d2
    jsr     drawPath
    
    move.l  d1, path2X1
    move.l  d2, path2Y1
    move.l  d3, path2X2
    move.l  d4, path2Y2
    
    lsl.l   #8, d3
    move.l  d3, d0
    move.l  receiver2YTurnPos, d1
    move.l  d1, d2

    move.l  #(PLAYER_HEIGHT)<<8, d5
    lsr.l   #1, d5
    add.l   d5, d1
    add.l   d5, d2

    ;determine if the receiver is going up or down
    move.l  receiver2YVel2, d3
    asl.l   #7, d3                          ;get the line direction
    add.l   d3, d2
    
    move.l  receiver2XVel2, d3
    move.l  receiver2YVel2,  d4

    jsr     drawPath
    
    move.l  d3, path2X3
    move.l  d4, path2Y3
    
    movem.l (sp)+,d5-d7
    rts

;redraws the bitmap over a given line generated by the drawPaths function    
;accounts for the possible orientations of the line
coverPath
    cmp.l   d2, d4
    bge     dontSwapYs
    move.l  d2, d0
    move.l  d4, d2
    move.l  d0, d4
dontSwapYs
    cmp.l   d1, d3
    bge     dontSwapXs
    move.l  d1, d0
    move.l  d3, d1
    move.l  d0, d3
dontSwapXs
    sub.l   d1, d3
    bne     positiveWidth
    move.l  #2, d3
    sub.l   #1, d1
positiveWidth
    sub.l   d2, d4
    bne     positiveHeight
    move.l  #2, d4
    sub.l   #1, d2
    add.l   #1, d3
positiveHeight
    add.l   #1, d4
    add.l   #1, d3  
    lsl.l   #8, d1
    lsl.l   #8, d2
    jsr     drawAPiece
    rts

;covers all receiver paths    
coverPaths
    move.l  path1X1, d1
    move.l  path1Y1, d2
    move.l  path1X2, d3
    move.l  path1Y2, d4
    jsr     coverPath   
    
    move.l  path1X2, d1
    move.l  path1Y2, d2
    move.l  path1X3, d3
    move.l  path1Y3, d4
    jsr     coverPath

    move.l  path2X1, d1
    move.l  path2Y1, d2
    move.l  path2X2, d3
    move.l  path2Y2, d4
    jsr     coverPath
    
    
    
    move.l  path2X2, d1
    move.l  path2Y2, d2
    move.l  path2X3, d3
    move.l  path2Y3, d4
    jsr     coverPath        
    rts
    
;cover various parts of the background during the game's update loop
redrawBackgroundPieces
    cmp.b   #GAMESTATE_PLAY, gameState
    bne     RETURN
    
    lea     backgroundFile, a0
    move.l  a0, fileAddress
    
    ;player
    move.l  d7, d1
    move.l  d6, d2
    move.l  #PLAYER_WIDTH+1, d3
    move.l  #PLAYER_HEIGHT+1, d4 
    jsr     drawAPlayer
        
    ;Receiver1
    move.l  (a1), d1
    move.l  (a2), d2
    jsr     drawAPlayer
  
    ;Receiver2
    move.l  (a3), d1
    move.l  (a4), d2
    jsr     drawAPlayer

    ;Defender1
    move.l  defender1XPos, d1
    move.l  defender1YPos, d2
    jsr     drawAPlayer

    ;Defender2
    move.l  defender2XPos, d1
    move.l  defender2YPos, d2
    jsr     drawAPlayer
    
    ;linebacker
    move.l  linebackerXPos, d1
    move.l  linebackerYPos, d2
    jsr     drawAPlayer
    
    ;Football
    move.l  ballPosX, d1
    add.l   #FOOTBALL_CARRY_OFFSET_X, d1
    move.l  ballPosY, d2
    add.l   #FOOTBALL_CARRY_OFFSET_Y, d2
    move.l  #FOOTBALL_WIDTH+1, d3
    move.l  #FOOTBALL_HEIGHT+1, d4
    jsr     drawAPiece
        
    ;change drawing to green
    move.l  #SET_PEN_COLOR_COMMAND, d0
    move.l  #FIELD_GREEN, d1
    trap    #15
    move.l  #SET_FILL_COLOR_COMMAND, d0
    trap    #15
    
    ;cover timer
    move.l  #TIMER_SECONDS_POSX_1-1, d1
    move.l  #DOWN_POSY-1, d2
    move.l  d1, d3
    add.l   #25, d3
    move.l  d2, d4
    add.l   #40, d4 
    move.l  #DRAW_RECTANGLE_COMMAND, d0
    trap    #15    
    
    ;cover timer
    move.l  #TIMER_SECONDS_POSX_2-1, d1
    move.l  #DOWN_POSY-1, d2
    move.l  d1, d3
    add.l   #25, d3
    move.l  d2, d4
    add.l   #40, d4 
    trap    #15
    
    ;cover timer    
    move.l  #TIMER_MINUTES_POSX-1, d1
    move.l  #DOWN_POSY-1, d2
    move.l  d1, d3
    add.l   #25, d3
    move.l  d2, d4
    add.l   #40, d4 
    trap    #15
    rts

;covers the UI drawn for the ball aiming
coverBallUI
    ;cover old UI
    move.l  oldUIX1, d1
    move.l  oldUIY1, d2
    move.l  oldUIX2, d3
    move.l  oldUIY2, d4
    cmp.l   #1, d4
    ble     dontApplyUIFix1
    sub.l   #1, d4
dontApplyUIFix1
    sub.l   #1, d3
    cmp.l   d1, d3 
    blt     dontApplyUIFix2
    add.l   #2, d3
dontApplyUIFix2
    jsr     coverPath
    rts

;draw ball UI for aiming
DrawBallUI 
    jsr     coverBallUI
    move.l  #SET_PEN_COLOR_COMMAND, d0
    move.l  #WHITE, d1
    trap    #15
    
    move.l  d5, d2
    ext.l   d2
    move.l  d2, d3
    asl.l   #2, d3

    move.l  d7, d0
    add.l   #(PLAYER_WIDTH/2)<<8, d0
    move.l  d6, d1
    move.l  d6, d2
    sub.l   #(UI_LENGTH)<<8, d2
    
    move.l  #FASTBALL_SPEED, d4
    jsr     getXCoordAtYFromVelocity
    move.l  d7, d1
    add.l   #(PLAYER_WIDTH/2)<<8, d1
    move.l  d6, d2
    move.l  d2, d4
    sub.l   #(UI_LENGTH)<<8, d4
       
    asr.l   #8, d1
    asr.l   #8, d2
    asr.l   #8, d3
    asr.l   #8, d4
    
    move.l  d1, oldUIX1
    move.l  d2, oldUIY1
    move.l  d3, oldUIX2
    move.l  d4, oldUIY2
    
    jsr     drawLine
    rts

;covers a previously drawn first down line
coverFirstDownLine
    move.l  #(LEFT_SIDE_OF_FIELD)<<8, d1
    move.l  firstDownLine, d2
    sub.l   #256, d2                                                                                                                                                    ;ACCOUNT FOR RIGHT SHIFT
    move.l  #RIGHT_SIDE_OF_FIELD, d3
    sub.l   #LEFT_SIDE_OF_FIELD-1, d3                                                                                                                                   ;get the width
    move.l  #LINE_OF_SCRIMMAGE_HEIGHT+10, d4 
    jsr     drawAPiece
    rts
    
;draws time at set position
drawTime
    move.l  currentRoundTime, d1
    move.l  #ROUND_TIME_IN_HUNDREDTHS, d3
    sub.l   d1, d3
    cmp.l   #0, d3
    bgt     dontSetTimeZero
    move.l  #0, d3
dontSetTimeZero
    divu    #100, d3                                                                                                                                                    ;gets seconds
    ext.l   d3
    move.l  #0, d4
calculateMinutes
    cmp.w   #59, d3
    ble     doneGettingMinutes
    add.l   #1, d4                                                                                                                                                      ;increase minutes
    sub.w   #60, d3
    bra     calculateMinutes 
doneGettingMinutes
    
    divu    #10, d3
    move.l  #TIMER_SECONDS_POSX_2, d1
    move.l  #DOWN_POSY, d2
    jsr     DrawSegments
    
    move.l  #TIMER_SECONDS_POSX_1, d1
    swap    d3
    jsr     DrawSegments

    
    cmp     #0, d4
    beq     dontDraw10s
    move.l  #TIMER_MINUTES_POSX, d1
    move.l  d4, d3
    jsr     drawSegments  
    rts
    
;given d3 as number, d1 xpos, d2 ypos
draw2Numbers

    divu    #10, d3
    
    swap    d3
    move.b  #DRAW_LINE_COMMAND, d0
    jsr     drawSegments
    
    swap    d3
    cmp.w   #0, d3
    beq     dontDraw10s
    sub.l   #SECOND_NUMBER_OFFSET, d1
    jsr     drawSegments
dontDraw10s
    rts


;draws the score and covers the old score at the same time
drawScore   
    move.l  #SET_PEN_COLOR_COMMAND, d0
    move.l  #FIELD_GREEN, d1
    trap    #15
    move.l  #SET_FILL_COLOR_COMMAND, d0
    trap    #15

    ;cover old score
    move.l  #SCORE_POSX_1-1, d1
    move.l  #DOWN_POSY-1, d2
    move.l  d1, d3
    add.l   #25, d3
    move.l  d2, d4
    add.l   #40, d4                                                                                                                                                     ;highest height in display
    move.l  #DRAW_RECTANGLE_COMMAND, d0
    trap    #15    
    
    move.l  #SCORE_POSX_2-1, d1
    move.l  #DOWN_POSY-1, d2
    move.l  d1, d3
    add.l   #25, d3
    move.l  d2, d4
    add.l   #40, d4                                                                                                                                                     ;highest height in display  
    trap    #15
    
  
    move.b  #SET_PEN_WIDTH_COMMAND, d0
	move.b  #LINE_OF_SCRIMMAGE_HEIGHT, d1
	trap    #15
	
	
	move.l  #RED, d1
    cmp.l   #0, scoreFlashDigitTimer
    bgt     flashRed
    move.l  #WHITE, d1
flashRed
    move.l  #SET_PEN_COLOR_COMMAND, d0 
    trap    #15
    
    move.l  #0, d3
    move.b  score, d3
    move.l  #SCORE_POSX_2, d1
    move.l  #DOWN_POSY, d2
    jsr     draw2Numbers
    rts

;handles clearing menu and drawing menu functions
drawMenu
    cmp.b   #GAMESTATE_DRAW_MENU, gameState
    bne     clearMenu
    lea     veteranRules, a0
    move.l  a0, fileAddress
    move.l  #(MENU_XPOS)<<8, d1
    move.l  #(MENU_1_YPOS)<<8, d2
    move.l  #MENU_WIDTH, d3
    move.l  #MENU_HEIGHT, d4
    jsr     drawAMenu
    
    lea     noobRules, a0
    move.l  a0, fileAddress
    move.l  #(MENU_XPOS)<<8, d1
    move.l  #(MENU_2_YPOS)<<8, d2
    jsr     drawAMenu
    
    
    lea     highscoreDude, a0
    move.l  a0, fileAddress
    move.l  #(HIGHSCORE_XPOS)<<8, d1
    move.l  #(HIGHSCORE_YPOS)<<8, d2
    move.l  #(HIGHSCORE_WIDTH), d3
    move.l  #(HIGHSCORE_HEIGHT), d4
    jsr     drawAMenu
    
    lea     yourScoreDude, a0
    move.l  a0, fileAddress
    move.l  #(YOURSCORE_XPOS)<<8, d1
    move.l  #(YOURSCORE_YPOS)<<8, d2
    move.l  #(HIGHSCORE_WIDTH), d3
    move.l  #(HIGHSCORE_HEIGHT), d4
    jsr     drawAMenu
    move.b  #GAMESTATE_MENU, gameState
    
    move.l  #WHITE, d1
    move.l  #SET_PEN_COLOR_COMMAND, d0 
    trap    #15
    
    
    move.l  #HIGHSCORE_DIGIT_XPOS, d1
    move.l  #HIGHSCORE_DIGIT_YPOS, d2
    move.l  #0, d3
    move.b  highscore, d3
    jsr     draw2Numbers
    
    move.l  #YOURSCORE_DIGIT_XPOS, d1
    move.l  #YOURSCORE_DIGIT_YPOS, d2
    move.l  #0, d3
    move.b  lastScore, d3
    jsr     draw2Numbers
    rts
clearMenu
    cmp.b   #GAMESTATE_CLEAR_MENU, gameState
    bne     dontClearMenu
    lea     backgroundFile, a0
    move.l  a0, fileAddress
    move.l  #(MENU_XPOS)<<8, d1
    move.l  #(MENU_1_YPOS)<<8, d2
    move.l  #MENU_WIDTH, d3
    move.l  #MENU_HEIGHT, d4
    jsr     drawAPiece
    
    move.l  #(MENU_XPOS)<<8, d1
    move.l  #(MENU_2_YPOS)<<8, d2
    jsr     drawAPiece
    
    move.l  #(HIGHSCORE_XPOS)<<8, d1
    move.l  #(HIGHSCORE_YPOS)<<8, d2
    move.l  #(HIGHSCORE_WIDTH), d3
    move.l  #(HIGHSCORE_HEIGHT), d4
    jsr     drawAPiece
    
    move.l  #(YOURSCORE_XPOS)<<8, d1
    move.l  #(YOURSCORE_YPOS)<<8, d2
    move.l  #(HIGHSCORE_WIDTH), d3
    move.l  #(HIGHSCORE_HEIGHT), d4
    jsr     drawAPiece
    
    ;cover old score
    move.l  #(HIGHSCORE_XPOS-1)<<8, d1
    move.l  #(HIGHSCORE_YPOS-1)<<8, d2
    move.l  #25, d3
    move.l  #40, d4                                                                                                                                                     ;highest height in display
    jsr     drawAPiece    

    
    move.b  #GAMESTATE_PLAY, gamestate
dontClearMenu
    rts
        
coverOldLineOfScrimmage 
    move.l  #(LEFT_SIDE_OF_FIELD)<<8, d1
    move.l  oldLineOfScrimmage, d2
    sub.l   #256, d2                                                                                                                                                    ;ACCOUNT FOR RIGHT SHIFT
    move.l  #RIGHT_SIDE_OF_FIELD, d3
    sub.l   #LEFT_SIDE_OF_FIELD-1, d3                                                                                                                                   ;get the width
    move.l  #LINE_OF_SCRIMMAGE_HEIGHT+10, d4 
    jsr     drawAPiece
    rts

;main draw loop
drawStuff

    jsr     drawMenu
    
    ;set pen width 
	move.b  #SET_PEN_WIDTH_COMMAND, d0
	move.b  #LINE_OF_SCRIMMAGE_HEIGHT, d1
	trap    #15
    
    ;draw seven segment display
    move.l  #RED, d1
    cmp.l   #0, downFlashDigitTimer
    bgt     flashRedDown
    move.l  #WHITE, d1
flashRedDown
    move.l  #SET_PEN_COLOR_COMMAND, d0 
    trap    #15
    
	move.b  #DRAW_LINE_COMMAND, d0 
    
    move.l  #DOWN_POSX, d1
    move.l  #DOWN_POSY, d2
    move.l  #0, d3
    move.b  downCounter, d3
    jsr     DrawSegments
    
    
    
    move.l  #RED, d1
    cmp.l   #0, timerFlashDigitTimer
    bgt     flashRedTimer
    move.l  #WHITE, d1
flashRedTimer
    move.l  #SET_PEN_COLOR_COMMAND, d0 
    trap    #15
    move.b  #DRAW_LINE_COMMAND, d0 
    jsr     drawTime
    
    ;cmp.l   #0, scoreFlashDigitTimer
    ;blt     dontDrawScore
    jsr     drawScore
    
    cmp.b   #GAMESTATE_PLAY, gameState
    bne     RETURN
    
    cmp.b   #BALLSTATE_QB, ballState
    bne     dontDrawUI
    jsr     drawBallUI
dontDrawUI    
    
    ;set pen color
	move.l  #BLUE, d1
	move.b  #SET_PEN_COLOR_COMMAND, d0
	trap    #15
	
	
    ;draw lineOfScrimmage
	move.b  #DRAW_LINE_COMMAND, d0 
	move.w  #LEFT_SIDE_OF_FIELD, d1
	move.l  lineOfScrimmage, d2
	lsr.l   #8, d2
	move.w  #RIGHT_SIDE_OF_FIELD-1, d3
	move.w  d2, d4
	trap    #15
	
	;set pen color
	move.l  #YELLOW, d1
	move.b  #SET_PEN_COLOR_COMMAND, d0
	trap    #15
	
	cmp.l   #(TOUCHDOWN_POS)<<8, firstDownLine
	ble     dontDrawFirstDownLine
	;draw firstDownLine
	move.b  #DRAW_LINE_COMMAND, d0 
	move.w  #LEFT_SIDE_OF_FIELD, d1
	move.l  firstDownLine, d2
	lsr.l   #8, d2
	move.w  #RIGHT_SIDE_OF_FIELD-1, d3
	move.w  d2, d4
	trap    #15
dontDrawFirstDownLine
	
    move.b  #SET_PEN_WIDTH_COMMAND, d0
    move.b  #1, d1
    trap    #15
    ;set pen color for offense
	move.l	#PANTHERS,d1
	move.b	#SET_PEN_COLOR_COMMAND,d0
	trap	#15
	move.b	#SET_FILL_COLOR_COMMAND,d0
	trap	#15
	
	;draw player 1
	move.b	#DRAW_CIRCLE_COMMAND,d0
	move.l	d7,d1
	asr.l	#8,d1
	move.l  d6, d2
	asr.l   #8,d2
	move.l	d1,d3
	add.l	#PLAYER_WIDTH,d3		
	move.l  d2, d4
    add.l   #PLAYER_HEIGHT,d4
    trap	#15  
    
    ;draw receiver1
    move.l	(a1),d1
	asr.l	#8,d1
	move.l  (a2), d2
	asr.l   #8,d2
	move.l	d1,d3
	add.l	#PLAYER_WIDTH,d3		
	move.l  d2, d4
    add.l   #PLAYER_HEIGHT,d4
    trap	#15
    
    ;draw receiver2
    move.l	(a3),d1
	asr.l	#8,d1
	move.l  (a4), d2
	asr.l   #8,d2
	move.l	d1,d3
	add.l	#PLAYER_WIDTH,d3		
	move.l  d2, d4
    add.l   #PLAYER_HEIGHT,d4
    trap	#15

	
    ;set pen color for defense
	move.l	#BADGUYS,d1
	move.b	#SET_PEN_COLOR_COMMAND,d0
	trap	#15
	move.b	#SET_FILL_COLOR_COMMAND,d0
	trap	#15

    ;draw defender1
	move.b	#DRAW_CIRCLE_COMMAND,d0
	move.l	defender1XPos,d1
	asr.l	#8,d1
	move.l  defender1YPos, d2
	asr.l   #8,d2
	move.l	d1,d3
	add.l	#PLAYER_WIDTH,d3		
	move.l  d2, d4
    add.l   #PLAYER_HEIGHT,d4
    trap	#15  
    
    ;draw defender2
	move.b	#DRAW_CIRCLE_COMMAND,d0
	move.l	defender2XPos,d1
	asr.l	#8,d1
	move.l  defender2YPos, d2
	asr.l   #8,d2
	move.l	d1,d3
	add.l	#PLAYER_WIDTH,d3		
	move.l  d2, d4
    add.l   #PLAYER_HEIGHT,d4
    trap	#15  
    
    ;draw linebacker
	move.b	#DRAW_CIRCLE_COMMAND,d0
	move.l	linebackerXPos,d1
	asr.l	#8,d1
	move.l  linebackerYPos, d2
	asr.l   #8,d2
	move.l	d1,d3
	add.l	#PLAYER_WIDTH,d3		
	move.l  d2, d4
    add.l   #PLAYER_HEIGHT,d4
    trap	#15  
    
          
	;set pen color
    move.l	#WHITE,d1
	move.b	#SET_PEN_COLOR_COMMAND,d0
	trap	#15
    move.l	#PIGSKIN,d1
	move.b	#SET_FILL_COLOR_COMMAND,d0
	trap	#15
	
	;draw football
	move.b	#DRAW_CIRCLE_COMMAND,d0
	move.l	ballPosX,d1
    add.l   ballSpeedX, d1
    move.l  d1, ballPosX 
	add.l   #FOOTBALL_CARRY_OFFSET_X, d1
	asr.l	#8,d1
	move.l  ballPosY, d2
    add.l   ballSpeedY, d2
    move.l  d2, ballPosY 
    add.l   #FOOTBALL_CARRY_OFFSET_Y, d2
	asr.l   #8,d2
	move.l	d1,d3
	add.l	#FOOTBALL_WIDTH,d3		
	move.l  d2, d4
    add.l   #FOOTBALL_HEIGHT,d4
    trap   	#15

    cmp.b   #BALLSTATE_TIMEOUT, ballState
    bne     return
    jsr     drawPaths
    rts	


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
