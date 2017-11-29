*-----------------------------------------------------------
* Title      : Football Logic
* Written by : Noah Presser
* Date       : October something
* Description: Contains main logic for many football based events
*-----------------------------------------------------------

snapBall
    jsr     playSnapSound
    jsr     coverPaths
    move.l  #SNAP_DEBOUNCE_TIMER, snapDebounceTimer
    move.b  #BALLSTATE_QB, ballState
    move.l  #DROPBACK_VELOCITY_Y, d5
    swap    d5
    rts

throwBall

    move.b  #BALLSTATE_FLY, ballState
    
    ;put ball in air
    jsr     coverBallUI
    jsr     playThrowSound
    move.l  deltaTime, d1                                                                                                          ;move so we get register word properly
    
    move.l  #FASTBALL_SPEED, d3                                                                                      
    move.l  d3, ballSpeedY
    move.w  d5, d2                                                                                                                  ;get xvel of player
    ext.l   d2
    move.l  d2, d3
    asr.l   #1, d2
    muls.w  #3, d3
    add.l   d2, d3
    muls.w  d1, d3
    move.l  d3, ballSpeedX
    rts

    
  
flyBall ; the ball is in the air
    ;input is locked for player as we just branched here
    ;if the ball collides with a player, have that player catch the ball and swap the Player1 with the Receiver
	move.l  (a1), d3 
	move.l  (a2), d4                                                                                                               ;top y pos
    jsr     checkBallCollision
    cmp.b   #0, d0
    beq     noCatch1
    
    ;swap Receiver1 with player control
        
    move.l  (a1), d0
    move.l  d7, (a1)
    move.l  d0, d7
    move.l  (a2), d0
    move.l  d6, (a2)
    move.l  d0, d6
    
    jsr     playCatchSound
    bra     caughtPass   
noCatch1

    ;check collision with receiver2
	move.l  (a3), d3 
	move.l  (a4), d4                                                                                                                ;top y pos
	jsr     checkBallCollision
	cmp.b   #0, d0
    beq     noCatch2
 
    ;swap Receiver2 with player control
    move.l  (a3), d0
    move.l  d7, (a3)
    move.l  d0, d7
    move.l  (a4), d0
    move.l  d6, (a4)
    move.l  d0, d6

    jsr     playCatchSound
    bra     caughtPass
noCatch2

defenderCollisionCheck
    ;interception
    move.l  defender1XPos, d3
    move.l  defender1YPos, d4
    jsr     checkBallCollision
    cmp.b   #1, d0                                                                                                                    ;if collision, there was an interception
    beq interception
    
    ;interception
    move.l  defender2XPos, d3
    move.l  defender2YPos, d4
    jsr     checkBallCollision
    cmp.b   #1, d0                                                                                                                      ;if collision, there was an interception
    beq     interception
    
    ;interception
    move.l  linebackerXPos, d3
    move.l  linebackerYPos, d4
    jsr     checkBallCollision
    cmp.b   #1, d0 ;if collision, there was an interception
    beq     interception
    
ballOutOfPlayCheck
    
    ;out the end 
    cmp.l   #(TOP_OF_FIELD-10)<<8, ballPosY                                                                        
    ble     incompletePass                                                                                                              ;is it above the top of the screen
	
    cmp.l   #(RIGHT_SIDE_OF_FIELD-FOOTBALL_WIDTH*5)<<8, ballPosX
    bge     incompletePass
	
    cmp.l   #(LEFT_SIDE_OF_FIELD-FOOTBALL_WIDTH*2)<<8, ballPosX
    ble     incompletePass
    rts
;in d0
GetLineOfScrimmage 
    move.l  d6, d0
    sub.l   #FOOTBALL_CARRY_OFFSET_Y, d0
    add.l   #(FOOTBALL_HEIGHT)<<7, d0                                                                                                   ;subtract the height over 2 to get the center of the ball
    move.l  d0, lineOfScrimmage
    rts
outOfBounds
    jsr     GetLineOfScrimmage
    bra     checkTurnOverOnDowns
incompletePass
    
    bra     checkTurnoverOnDowns
tackled
    move.l  #(TOUCHBACK_POS)<<8, d0
    move.l  d6, d1
    add.l   #(FOOTBALL_HEIGHT)<<8, d6 
    cmp.l   d0, d6                                                                                                                      ;is the bottom of the ball in the endzone?
    bge     touchback
    jsr     playTackleSound
    jsr     GetLineOfScrimmage    
    bra     checkTurnoverOnDowns
interception
    jsr     playInterceptionSound
    move.l  playerStartYPos, lineOfScrimmage
    move.l  #DOWN_FLASH_TIMER, downFlashDigitTimer
    bra     turnoverOnDowns
touchdown
    move.l  #0, d0
    move.l  #(FIFTY_YARD_LINE_LOCATION)<<8, d1
    move.l  lineOfScrimmage, d2
    cmp.l   d1, d2
    blt     noHailMary
    move.l  #1, d0
noHailMary
    jsr     playTouchdownSound
    jsr     updateScore
touchback
turnoverOnDowns
    move.b  #1, downCounter
    move.l  playerStartYPos, lineOfScrimmage
    move.l  lineOfScrimmage, d0
    add.l   #FIRST_DOWN_YARDS, d0
    jsr     coverFirstDownLine 
    move.l  d0, firstDownLine
    bra     resetPlay

checkTurnoverOnDowns
    move.l  #DOWN_FLASH_TIMER, downFlashDigitTimer
    add.b   #1, downCounter
    jsr     checkFirstDown
    cmp.b   #4, downCounter
    bgt     turnoverOnDowns
    bra     resetPlay

checkFirstDown
    cmp.l   firstDownLine, d6
    bgt     RETURN
    move.l  #DOWN_FLASH_TIMER, downFlashDigitTimer
    move.b  #1, downCounter
    jsr     coverFirstDownLine
    move.l  lineOfScrimmage, d0
    sub.l   #FIRST_DOWN_YARDS, d0
    move.l  d0, firstDownLine
    

    rts
resetPlay    
    cmp.l   #ROUND_TIME_IN_HUNDREDTHS-100, currentRoundTime
    bge     whistleRestart
    jsr     coverBallUI
    
    ;set hike debounce
    move.l  #SNAP_DEBOUNCE_TIMER, resetPlayDebounceTimer
    
    ;change drawing to green
    move.l  #SET_PEN_COLOR_COMMAND, d0
    move.l  #FIELD_GREEN, d1
    trap    #15
    move.l  #SET_FILL_COLOR_COMMAND, d0
    trap    #15
    
    ;cover downCounter
    move.l  #DOWN_POSX-1, d1
    move.l  #DOWN_POSY-1, d2
    move.l  d1, d3
    add.l   #25, d3
    move.l  d2, d4
    add.l   #40, d4                                                                                                                                             ;highest height in display 
    
     
    
    move.l  #DRAW_RECTANGLE_COMMAND, d0
    trap    #15
    
    ;reset the ball state
    move.b  #BALLSTATE_TIMEOUT, ballState
    move.b  #LINEBACKERSTATE_STRAFE, linebackerState
    ;set all players on offense to line of scrimmage
    move.l  lineOfScrimmage, d6
    move.l  playerStartXpos, d7
    move.l  d6, (a2)
    move.l  receiver2StartXpos, (a3)
    move.l  d6, (a4)
    move.l  #33, d0
    jsr     checkFirstDown
    lea     backgroundFile, a0
    move.l  a0, fileAddress
    jsr     coverOldLineOfScrimmage
    move.l  lineOfScrimmage, oldLineOfScrimmage
    
    ;grab the play from the paths.bin
    lea     paths1, a0
    
    ;get random play in file (offset a0 by this)
    jsr     getRandomByteIntoD3
    lsr.l   #4, d3                                                                                                                                               ;get 1-16    
    muls    #$30, d3
    add.l   d3, a0                                                                                                                                              ;add the proper offset
    
    
    ;update the receiver1 start xpos
    move.l  receiver1StartXPos, d0
    add.l   (a0), d0                                                                                                                                              ;grab the receiver x offset
    move.l  d0, (a1)
    
    ;update the turnPosY for rec
    move.l  d6, d0                                                                                                                                                 ;grab line of scrimmage
    sub.l   4(a0), d0                                                                                                                                               ;add the position offset (it's positive in the file)
    move.l  d0, receiver1YTurnPos
    
    ;update the receiver velocities
    move.l  8(a0), receiver1XVel1
    move.l  12(a0), receiver1YVel1
    move.l  16(a0), receiver1XVel2
    move.l  20(a0), receiver1YVel2
    
    ;update the defender position offsets
    move.l  receiver1StartXPos, d0
    add.l   24(a0), d0
    move.l  d0, defender1XPos
    move.l  d6, d0                                                                                                                                               ;grab line of scrimmage
    sub.l   28(a0), d0                                                                                                                                            ;add the position offset (it's positive in the file)
    move.l  d0, defender1YPos
    
    ;update the defender velocities
    move.l  32(a0), defender1XVel1
    move.l  36(a0), defender1YVel1
    move.l  40(a0), defender1XVel2
    move.l  44(a0), defender1YVel2
    
    
    ;get random play in file (offset a0 by this)
    lea     paths1, a0
    jsr     getRandomByteIntoD3
    lsr.l   #4, d3                                                                                                                                                  ;get 1-16
    
    ;move.l #4, d3
    muls    #$30, d3
    add.l   d3, a0                                                                                                                                                  ;add the proper offset
    
    
    ;update the receiver2 start xpos
    move.l  receiver2StartXPos, d0
    sub.l   (a0), d0                                                                                                                                                ;grab the receiver2 x offset
    move.l  d0, (a3)
    
    ;update the turnPosY for rec
    move.l  d6, d0                                                                                                                                                  ;grab line of scrimmage
    sub.l   4(a0), d0                                                                                                                                               ;add the position offset (it's positive in the file)
    move.l  d0, receiver2YTurnPos
    
    ;update the receiver velocities
    move.l  8(a0), d0
    neg.l   d0
    move.l  d0, receiver2XVel1
    move.l  12(a0), receiver2YVel1
    move.l  16(a0), d0
    neg.l   d0
    move.l  d0, receiver2XVel2
    move.l  20(a0), receiver2YVel2
    
    ;update the defender2 position offsets
    move.l  receiver2StartXPos, d0
    sub.l   24(a0), d0
    move.l  d0, defender2XPos
    move.l  d6, d0                                                                                                                                                  ;grab line of scrimmage
    sub.l   28(a0), d0                                                                                                                                              ;add the position offset (it's positive in the file) 
    move.l  d0, defender2YPos
    
    ;update the defender velocities
    move.l  32(a0), d0
    neg.l   d0
    move.l  d0, defender2XVel1
    move.l  36(a0), defender2YVel1
    move.l  40(a0), d0
    neg.l   d0
    move.l  d0, defender2XVel2
    move.l  44(a0), defender2YVel2
    
    
    
    ;update the linebacker position and velocity
    
    jsr     getRandomByteIntoD3                                                                                                                                     ;get a random offset
    lsl.l   #8, d3                                                                                                                                                  ;make it a bigger offset
    cmp.l   #SQUISHPOS_1, lineOfScrimmage
    bgt     doneSquishing
    lsr.l   #1, d3 ;127 max
    cmp.l   #SQUISHPOS_2, lineOfScrimmage
    bgt     doneSquishing
    lsr.l   #1, d3 ;63 max
    cmp.l   #SQUISHPOS_3, lineOfScrimmage
    bgt     doneSquishing
    lsr.l   #1, d3 ;31 max
    cmp.l   #SQUISHPOS_4, lineOfScrimmage
    bgt     doneSquishing
    lsr.l   #3, d3
doneSquishing    
    
    add.l   #SHOTGUN_OFFSET_1, d3
    
    move.l  lineOfScrimmage, d4
    sub.l   d3, d4                                                                                                                                                  ;move the linebacker off of the offset
    move.l  d4, lineBackerYPos
    move.l  d7, linebackerXPos
    
    move.l  #0, linebackerXVel
    move.l  #0, linebackerYVel
    
    
    
    ;move the QB back a bit
    add.l   #SHOTGUN_OFFSET_1, d6
    move.l  d6, d0
    cmp.l   #(TOUCHBACK_POS)<<8, d0
    blt     normalOffset
    sub.l   #SHOTGUN_OFFSET_2, d6
normalOffset

    ;reset player velocities
    move.l  #DROPBACK_VELOCITY_Y, d5
    cmp.l   #(NEAR_ENDZONE_POS)<<8, d6    
    blt     dontDropback
    move.l  #0, d5
dontDropback
    
    ;reset football position
    move.l  #0, ballSpeedX
    move.l  #0, ballSpeedY
    move.l  d7, ballPosX
    move.l  d6, ballPosY
    rts
startGame   
    jsr     stopAllSoundsNonTrap
    jsr     playWhistleSound
    jsr     playLevelTheme
    move.l  #0, currentRoundTime
    move.l  #DOWN_FLASH_TIMER, downFlashDigitTimer
    move.l  #SCORE_FLASH_TIMER, scoreFlashDigitTimer
    move.l  #TIMER_FLASH_TIMER, timerFlashDigitTimer
    lea     backgroundFile, a0
    move.l  a0, fileAddress
    jsr     initPlayers
    move.l  playerStartYPos, oldLineOfScrimmage    
    jsr     resetPlay
    move.b  #0, score  
    cmp.b   #0, highscore  
    bne     dontResetHighScore
    move.b  #0, highscore
dontResetHighscore
    cmp.b   #0, lastScore
    bne     dontResetLastScore
    move.b  #0, lastScore
dontResetLastScore
    move.b  #GAMESTATE_CLEAR_MENU, gameState
    jsr drawScore
    rts
whistleRestart
restartGame 
    jsr     stopAllSoundsNonTrap
    jsr     playWhistleSound
    jsr     playMenuTheme
    move.l  #0, d0
    move.b  highscore, d0
    cmp.b   score, d0
    bgt     dontSetHighscore
    move.b  score, highScore
dontSetHighScore    
    move.b  score, lastScore
    move.b  #0, score
    move.l  #0, currentRoundTime
    move.l  playerStartYPos, lineOfScrimmage
    move.l  #DOWN_FLASH_TIMER, downFlashDigitTimer
    move.l  #SCORE_FLASH_TIMER, scoreFlashDigitTimer
    move.l  #TIMER_FLASH_TIMER, timerFlashDigitTimer
    jsr     coverFirstDownLine
    jsr     initPlayers
    jsr     resetPlay
    move.b  #GAMESTATE_DRAW_MENU, gameState
    jsr drawScore
    rts
caughtPass
    ;set ball state
    jsr     coverBallUI
    move.b  #BALLSTATE_CAUGHT, ballState
    move.l  #0, ballSpeedX
    move.l  #0, ballSpeedY
    rts 


updateScore
    move.l  #0, d3
    move.b  score, d3
    add.b   #7, d3    
    move.b  d3, score
    move.l  #SCORE_FLASH_TIMER, scoreFlashDigitTimer
    jsr     drawScore
    rts






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
