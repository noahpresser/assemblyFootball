*-----------------------------------------------------------
* Title      : Movement
* Written by : Noah Presser
* Date       : Slightly after when Tom assigned this
* Description: Contains the player movement and the AI for the receivers and the defenders
*-----------------------------------------------------------

;takes Pos a0, vel d0, assumes d2 is correct value for deltaTime
moveIndividual
    muls   d2, d0                       ;deltaTime
    add.l  d0, (a0)                     ;add to memorylocation
    rts

;moves receiver and defender 1 along their 1st scripted path    
moveReceiverAndDefender1Path1
    move.l  receiver1YVel1, d0
    move.l  d0, receiver1YVel3
    move.l  a2, a0
    jsr     moveIndividual
 
    move.l  receiver1XVel1, d0
    move.l  a1, a0
    jsr     MoveIndividual
    
    ;also move defender1
    lea     defender1YPos, a0
    move.l  defender1YVel1, d0
    jsr     MoveIndividual
    
    lea     defender1Xpos, a0
    move.l  defender1Xvel1, d0
    jsr     MoveIndividual
    rts
    
;moves receiver and defender 1 along their 2nd scripted path    
moveReceiverAndDefender1Path2
    move.l  receiver1YVel2, d0
    move.l  d0, receiver1YVel3
    move.l  a2, a0
    jsr     moveIndividual
 
    move.l  receiver1XVel2, d0
    move.l  a1, a0
    jsr     MoveIndividual
    
    ;also move defender1
    lea     defender1YPos, a0
    move.l  defender1YVel2, d0
    jsr     MoveIndividual
    
    lea     defender1Xpos, a0
    move.l  defender1Xvel2, d0
    jsr     MoveIndividual    
    rts

;moves receiver and defender 2 along their 1st scripted path    
moveReceiverAndDefender2Path1
    ;also move receiver2
    move.l  receiver2YVel1, d0
    move.l  d0, receiver2YVel3
    move.l  a4, a0
    jsr     moveIndividual
 
    move.l  receiver2XVel1, d0
    move.l  a3, a0
    jsr     MoveIndividual
    
    ;also move defender2
    lea     defender2YPos, a0
    move.l  defender2YVel1, d0
    jsr     MoveIndividual
    
    lea     defender2Xpos, a0
    move.l  defender2Xvel1, d0
    jsr     MoveIndividual
    rts
    
;moves receiver and defender 2 along their 2nd scripted path    
moveReceiverAndDefender2Path2
    ;also move receiver2
    move.l  receiver2YVel2, d0
    move.l  d0, receiver2YVel3
    move.l  a4, a0
    jsr     moveIndividual
 
    move.l  receiver2XVel2, d0
    move.l  a3, a0
    jsr     MoveIndividual
    
    ;also move defender2
    lea     defender2YPos, a0
    move.l  defender2YVel2, d0
    jsr     MoveIndividual
    
    lea     defender2Xpos, a0
    move.l  defender2Xvel2, d0
    jsr     MoveIndividual
    rts

;moves the receiver towards the ball while the ball is in the air
receiverBallMagnetism
    move.l  ballPosX, d0
    move.l  ballPosY, d1
    move.l  receiver1YPos, d2
    move.l  ballSpeedX, d3
    move.l  ballSpeedY, d4
    jsr     getXCoordAtYFromVelocity

    ;receiver1
    move.l  #RECEIVER_SPEED_LEFT, d0            ;assume moving left 
    cmp.l   receiver1XPos, d3 
    ble     dontMoveRightRec1                   ;if the player is to the left of the defender
    move.l  #RECEIVER_SPEED_RIGHT, d0
dontMoveRightRec1
    ;update xpos receiver1
    move.l  deltaTime, d2
    lea     receiver1Xpos, a0
    jsr     moveIndividual
    
    ;update ypos receiver1
    lea     receiver1Ypos, a0
    move.l  receiver1Yvel3, d0
    move.l  (a0), d3
    add.l   d0, d3
    cmp.l   #(TOP_RECEIVER_MAX_POS)<<8-0, d3
    ble     dontChaseBallRec1    
    jsr     moveIndividual
dontChaseBallRec1
    
    move.l  ballPosX, d0
    move.l  ballPosY, d1
    move.l  receiver2YPos, d2
    move.l  ballSpeedX, d3
    move.l  ballSpeedY, d4
    jsr     getXCoordAtYFromVelocity
    
    ;receiver2
    move.l  #RECEIVER_SPEED_LEFT, d0            ;assume moving left
    cmp.l   receiver2XPos, d3
    ble     dontMoveRightRec2                   ;if the player is to the left of the defender
    move.l  #RECEIVER_SPEED_RIGHT, d0
dontMoveRightRec2
    ;update xpos receiver2
    move.l  deltaTime, d2
    lea     receiver2Xpos, a0
    jsr     moveIndividual
    
    ;update ypos receiver2
    lea     receiver2Ypos, a0
    move.l  receiver2Yvel3, d0
    move.l  (a0), d3
    add.l   d0, d3
    cmp.l   #(TOP_RECEIVER_MAX_POS)<<8, d3
    ble     dontChaseBallRec2    
    jsr     moveIndividual
dontChaseBallRec2
   
    ;move defenders
    jsr     defendersChaseBall
    bra     donePathMoving
    rts
    
;x1 is d0, d1 is y1, d2 is y2, xvel is d3, yvel is d4. return val x2 in d3
getXCoordAtYFromVelocity
    cmp.l   #0, d4
    beq     returnX
    sub.l   d1, d2                          ;y2 - y1
    divs    d4, d2                          ; / yvel
    muls    d2, d3                          ; * xvel
    add.l   d0, d3                          ; + x1
    rts
returnX
    asl.l   #7, d3                          ;get the movement direction
    add.l   d3, d0
    move.l  d0, d3
    rts
    
updateReceivers
    cmp.b   #GAMESTATE_PLAY, gameState
    bne     RETURN
    cmp.b   #BALLSTATE_TIMEOUT, ballState
    bne     continueUpdating
    
    
    rts
continueUpdating  
    
    cmp.b   #BALLSTATE_CAUGHT, ballState          ;if the ball has been thrown and caught, skip to defenders chasing player
    beq     defendersChasePlayer
    
    move.l  deltaTime, d2

    cmp.b   #BALLSTATE_FLY, ballState
    beq     receiverBallMagnetism

    ;check the turn point
    move.l  (a2), d1
    move.l  receiver1YTurnPos, d0        
    cmp.l   d0, d1
    ble     Rec1SecondVel                       ;if the receiver has posY above yTurnPos
Rec1FirstVel    
    jsr     moveReceiverAndDefender1Path1
    bra     movePath2
Rec1SecondVel
    jsr     moveReceiverAndDefender1Path2
movePath2
    ;check the turn point
    move.l  (a4), d1
    move.l  receiver2YTurnPos, d0        
    cmp.l   d0, d1
    ble     Rec2SecondVel                       ;if the receiver has posY above yTurnPos
Rec2FirstVel    
    jsr     moveReceiverAndDefender2Path1
    bra     donePathMoving
Rec2SecondVel
    jsr     moveReceiverAndDefender2Path2
    
donePathMoving
    jsr     updateLineBacker
    bra     checkReceiverAndDefenderBounds
defendersChaseBall
    move.l  ballPosX, d3
    move.l  ballPosY, d4
    bra defendersChaseObject
linebackerChasePlayer
    ;defender1
    move.l  #CHASE_SPEED_LEFT, d0               ;assume moving left
    cmp.l   linebackerXPos, d3
    ble     dontMoveRightLB                       ;if the player is to the left of the defender
    move.l  #CHASE_SPEED_RIGHT, d0
dontMoveRightLB
    move.l  #CHASE_SPEED_DOWN, d1               ;assume moving down
    cmp.l   linebackerYPos, d4
    bge     dontMoveUpLB                          ;if the player is above (less than) the defender
    move.l  #CHASE_SPEED_UP, d1
dontMoveUpLB
    move.l  deltaTime, d2
    ;update xpos linebacker
    lea     linebackerXpos, a0
    jsr     moveIndividual
    
    ;update ypos linebacker
    lea     linebackerYpos, a0
    move.l  d1, d0
    jsr     moveIndividual
    rts
receiversChasePlayer
    ;receiver1
    move.l  #CHASE_SPEED_LEFT, d0               ;assume moving left
    cmp.l   receiver1XPos, d3
    ble     dontMoveRight3                      ;if the player is to the left of the receiver
    move.l  #CHASE_SPEED_RIGHT, d0
dontMoveRight3
    move.l  #LINEBACKER_CHASE_SPEED_DOWN, d1    ;assume moving down
    cmp.l   receiver1YPos, d4
    bge     dontMoveUp3                         ;if the player is above (less than) the receiver
    move.l  #LINEBACKER_CHASE_SPEED_UP, d1
dontMoveUp3
    move.l  deltaTime, d2
    ;update xpos receiver1
    lea     receiver1Xpos, a0
    jsr     moveIndividual
    
    ;update ypos receiver1
    lea     receiver1Ypos, a0
    move.l  d1, d0
    jsr     moveIndividual

    ;defender2
    move.l  #CHASE_SPEED_LEFT, d0           ;assume moving left
    cmp.l   receiver2XPos, d3
    ble     dontMoveRight4                  ;if the player is to the left of the receiver
    move.l  #CHASE_SPEED_RIGHT, d0
dontMoveRight4
    move.l  #CHASE_SPEED_DOWN, d1           ;assume moving down
    cmp.l   receiver2YPos, d4
    bge     dontMoveUp4                     ;if the player is above (less than) the receiver
    move.l  #CHASE_SPEED_UP, d1
dontMoveUp4
    move.l  deltaTime, d2
    ;update xpos receiver2
    lea     receiver2Xpos, a0
    jsr     moveIndividual
    
    ;update ypos receiver2
    lea     receiver2Ypos, a0
    move.l  d1, d0
    jsr     moveIndividual
    rts
    
defendersChasePlayer
    move.l  d7, d3
    move.l  d6, d4
    jsr     linebackerChasePlayer
    jsr     receiversChasePlayer
defendersChaseObject
    
    ;defender1
    move.l  #CHASE_SPEED_LEFT, d0               ;assume moving left
    cmp.l   defender1XPos, d3
    ble     dontMoveRight                       ;if the player is to the left of the defender
    move.l  #CHASE_SPEED_RIGHT, d0
dontMoveRight
    move.l  #LINEBACKER_CHASE_SPEED_DOWN, d1    ;assume moving down
    cmp.l   defender1YPos, d4
    bge     dontMoveUp                          ;if the player is above (less than) the defender
    move.l  #LINEBACKER_CHASE_SPEED_UP, d1
dontMoveUp
    move.l  deltaTime, d2
    ;update xpos def1
    lea     defender1Xpos, a0
    jsr     moveIndividual
    
    ;update ypos rec1
    lea     defender1Ypos, a0
    move.l  d1, d0
    jsr     moveIndividual

    ;defender2
    move.l  #CHASE_SPEED_LEFT, d0           ;assume moving left
    cmp.l   defender2XPos, d3
    ble     dontMoveRight2                  ;if the player is to the left of the defender
    move.l  #CHASE_SPEED_RIGHT, d0
dontMoveRight2
    move.l  #CHASE_SPEED_DOWN, d1           ;assume moving down
    cmp.l   defender2YPos, d4
    bge     dontMoveUp2                     ;if the player is above (less than) the defender
    move.l  #CHASE_SPEED_UP, d1
dontMoveUp2
    move.l  deltaTime, d2
    ;update xpos def1
    lea     defender2Xpos, a0
    jsr     moveIndividual
    
    ;update ypos rec1
    lea     defender2Ypos, a0
    move.l  d1, d0
    jsr     moveIndividual
checkReceiverAndDefenderBounds
    ;check if they are going into the sidelines
    cmp.l   #(LEFT_RECEIVER_MAX_POS)<<8, (a1)
    ble     checkRec1RightBounds
    move.l  #CHASE_SPEED_LEFT, receiver1XVel1
    move.l  #CHASE_SPEED_LEFT, receiver1XVel2 ;set the receiver to go across the field
checkRec1RightBounds
    cmp.l   #(RIGHT_RECEIVER_MAX_POS-PLAYER_WIDTH)<<8, (a1)
    bge     checkRec1TopBounds
    move.l  #CHASE_SPEED_RIGHT, receiver1Xvel1
    move.l  #CHASE_SPEED_RIGHT, receiver1XVel2
checkRec1TopBounds
    cmp.l   #(TOP_RECEIVER_MAX_POS)<<8, (a2)
    bge     checkDef1LeftBounds
    move.l  #0, receiver1YVel1
    move.l  #0, receiver1Yvel2
    move.l  receiver1XVel2, receiver1XVel1 
    move.l  receiver1XVel2, receiver1XVel2 
checkDef1LeftBounds
    cmp.l   #(LEFT_RECEIVER_MAX_POS)<<8, defender1XPos
    ble     checkDef1RightBounds
    move.l  #CHASE_SPEED_LEFT, defender1XVel1
    move.l  #CHASE_SPEED_LEFT, defender1XVel2 ;set the receiver to go across the field
checkDef1RightBounds
    cmp.l   #(RIGHT_RECEIVER_MAX_POS-PLAYER_WIDTH)<<8, defender1XPos
    bge     checkDef1TopBounds
    move.l  #CHASE_SPEED_RIGHT, defender1Xvel1
    move.l  #CHASE_SPEED_RIGHT, defender1XVel2
checkDef1TopBounds
    cmp.l   #(TOP_RECEIVER_MAX_POS)<<8, defender1YPos
    bge     doneFirstBoundsChecks
    move.l  #0, defender1YVel1
    move.l  #0, defender1Yvel2
doneFirstBoundsChecks
    ;rec2 and def2
    cmp.l   #(LEFT_RECEIVER_MAX_POS)<<8, (a3)
    ble     checkRec2RightBounds
    move.l  #CHASE_SPEED_LEFT, receiver2XVel1
    move.l  #CHASE_SPEED_LEFT, receiver2XVel2 ;set the receiver to go across the field
checkRec2RightBounds
    cmp.l   #(RIGHT_RECEIVER_MAX_POS-PLAYER_WIDTH)<<8, (a3)
    bge     checkRec2TopBounds
    move.l  #CHASE_SPEED_RIGHT, receiver2Xvel1
    move.l  #CHASE_SPEED_RIGHT, receiver2XVel2
checkRec2TopBounds
    cmp.l   #(TOP_RECEIVER_MAX_POS)<<8, (a4)
    bge     checkDef2LeftBounds
    move.l  #0, receiver2YVel1
    move.l  #0, receiver2Yvel2
    move.l  receiver2XVel2, receiver2XVel1 
    move.l  receiver2XVel2, receiver2XVel2 
checkDef2LeftBounds
    cmp.l   #(LEFT_RECEIVER_MAX_POS)<<8, defender2XPos
    ble     checkDef2RightBounds
    move.l  #CHASE_SPEED_LEFT, defender2XVel1
    move.l  #CHASE_SPEED_LEFT, defender2XVel2                                                   ;set the receiver to go across the field
checkDef2RightBounds
    cmp.l   #(RIGHT_RECEIVER_MAX_POS-PLAYER_WIDTH)<<8, defender2XPos
    bge     checkDef2TopBounds
    move.l  #CHASE_SPEED_RIGHT, defender2Xvel1
    move.l  #CHASE_SPEED_RIGHT, defender2XVel2
checkDef2TopBounds
    cmp.l   #(TOP_RECEIVER_MAX_POS)<<8, defender2YPos
    bge     doneSecondBoundsChecks
    move.l  #0, defender2YVel1
    move.l  #0, defender2Yvel2
doneSecondBoundsChecks
    bra     updatePlayer1

updateLinebacker
    cmp.l   #LINEBACKERSTATE_STRAFE, linebackerState
    bne     doneBlitzChecking
                                                                                                ;check if we should blitz
    move.l  #0, d3
    move.l  #0, d1
    jsr     getRandomByteIntoD3
    lsr.l   #1, d3
    cmp.b   #0, d3                                                                              ;checking something on a random chance 1/255
    bne     doneBlitzChecking
    move.b  #LINEBACKERSTATE_BLITZ, linebackerState
doneBlitzChecking
    ;linebacker pathing
    
    move.l  #0, d0
    cmp.l   linebackerXPos, d7
    beq     dontMoveLinebackerRight                                                             ;if equal dont move
    move.l  #LINEBACKER_CHASE_SPEED_LEFT, d0                                                    ;assume moving left
    cmp.l   linebackerXPos, d7
    ble     dontMoveLinebackerRight                                                             ;if the player is to the left of the defender
    move.l  #LINEBACKER_CHASE_SPEED_RIGHT, d0
    
dontMoveLinebackerRight
    cmp.b   #BALLSTATE_FLY, ballState
    beq     blitz    
    cmp.b   #LINEBACKERSTATE_BLITZ, linebackerState
    beq     blitz
    cmp.b   #BALLSTATE_CAUGHT, ballstate
    bne     dontBlitz
blitz
    move.l  #LINEBACKER_CHASE_SPEED_DOWN, d1                                                    ;assume moving down
    cmp.l   linebackerYPos, d6
    bge     blitzHorz                                                                           ;if the player is above (less than) the defender
    move.l  #LINEBACKER_CHASE_SPEED_UP, d1
blitzHorz    
    move.l  #CHASE_SPEED_LEFT, d0                                                               ;assume moving left
    cmp.l   linebackerXPos, d7
    ble     dontBlitz                                                                           ;if the player is to the left of the defender
    move.l  #CHASE_SPEED_RIGHT, d0
dontBlitz
    
    move.l  deltaTime, d2
    ;update xpos linebacker
    lea     linebackerXpos, a0
    jsr     moveIndividual
    
    
    ;update ypos linebacker
    lea     linebackerYPos, a0
    move.l  d1, d0
    jsr     moveIndividual
    rts
;gets input and moves the player or throws the ball  
updatePlayer1
    cmp.b   #BALLSTATE_FLY, ballState
    beq     flyBall 
    ;cap the accelleration Y
    cmp.w   #PLAYER_MAX_SPEED_Y, d5
    bgt     dontAccellerateYPos
    cmp.w   #PLAYER_MIN_SPEED_Y, d5
    blt     dontAccellerateYNeg

doAccelleratey
    cmp.b   #0, wWasPressed
    bne     dontKillMomentumYUp
    cmp.w   #0, d5
    bge     dontKillMomentumYUp
    add.w   #PLAYER_Y_DRAG, d5
dontKillMomentumYUp

    cmp.b   #0, sWasPressed
    bne     dontKillMomentumYDown
    cmp.w   #0, d5
    ble     dontKillMomentumYDown
    sub.w   #PLAYER_Y_DRAG, d5
dontKillMomentumYDown
    move.w  d5, d0                                                                              ;get the y accelleration
    ext.l   d0
    move.l   deltaTime,d1
    muls    d1, d0
    add.l   d0, d6                                                                              ;add y accelleration
    
    ;cap the accelleration X
    swap    d5                                                                                  ;restore to xy
    cmp.w   #PLAYER_MAX_SPEED_X, d5
    bgt     dontAccellerateXPos                                                                 ;should we cap?    
    cmp.w   #PLAYER_MIN_SPEED_X, d5
    blt     dontAccellerateXNeg                                                                 ;should we cap?
    
    
doAccellerateX
    cmp.b   #0, dWasPressed
    bne     dontKillMomentumXRight
    cmp.w   #0, d5
    ble     dontKillMomentumXRight
    sub.w   #PLAYER_X_DRAG, d5
dontKillMomentumXRight

    cmp.b   #0, aWasPressed
    bne     dontKillMomentumXLeft
    cmp.w   #0, d5
    bge     dontKillMomentumXLeft
    add.w   #PLAYER_X_DRAG, d5
dontKillMomentumXLeft
    
    move.w  d5, d0                                                                              ;get the x accelleration
    ext.l   d0 
    move.l  deltaTime,d1
    muls    d1, d0
    add.l   d0, d7                                                                              ;add x accelleration
    
    ;attach the football to the runner
    move.l  d7, ballPosX
    move.l  d6, ballPosY

updatePlayer
    ;check x bounds
    cmpi.l	#(RIGHT_SIDE_OF_FIELD-PLAYER_WIDTH)<<8,d7
    bge	    outOfBounds
    cmpi.l	#(LEFT_SIDE_OF_FIELD)<<8,d7
    ble     outOfBounds
    ;didn't go out of bounds
    
    ;safety
    cmpi.l  #(BOTTOM_OF_FIELD-PLAYER_HEIGHT)<<8, d6
    bge     touchback
    
    ;touchdown
    move.l  #(TOUCHDOWN_POS)<<8, d0
    sub.l   #FOOTBALL_CARRY_OFFSET_Y, d0
    cmp.l   d0, d6
    ble     touchdown
    
    ;defender1Collision
    move.l  defender1XPos, d2
    move.l  defender1YPos, d3
    jsr     checkCollisionWithPlayer
    cmp.b   #1, d0
    beq     tackled                                                                             ;if there was a collision
    
    ;defender2Collision
    move.l  defender2XPos, d2
    move.l  defender2YPos, d3
    jsr     checkCollisionWithPlayer
    cmp.b   #1, d0
    beq     tackled                                                                             ;if there was a collision
    
    ;linebackerCollision
    move.l  linebackerXPos, d2
    move.l  linebackerYPos, d3
    jsr     checkCollisionWithPlayer
    cmp.b   #1, d0
    beq     tackled                                                                             ;if there was a collision


;TODO
noCollisionWithTD

;TODO
noCollisionWithTouchBack
    ;line of scrimmage collision
    cmp.l   lineOfScrimmage, d6
    blt     caughtPass
    rts 

    
dontAccellerateXNeg
    move.w  #PLAYER_MIN_SPEED_X, d5
    bra     doAccellerateX
dontAccellerateXPos  
    move.w  #PLAYER_MAX_SPEED_X, d5
    bra     doAccellerateX
dontAccellerateYNeg
    move.w  #PLAYER_MIN_SPEED_Y, d5
    bra     doAccellerateY
dontAccellerateYPos
    move.w  #PLAYER_MAX_SPEED_Y, d5
    bra     doAccellerateY
    
    
	
noPositiveSet
	rts

    
   
    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
