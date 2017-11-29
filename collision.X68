*-----------------------------------------------------------
* Title      : Collision
* Written by : Noah Presser
* Date       : A little while after Tom assigned this
* Description: This file contains collision logic. It uses Axis Aligned Bounding Boxes
*-----------------------------------------------------------

;defenderXPos is d2, defenderYPos is d3
checkCollisionWithPlayer
    ;check defender1 collision (x first)
    move.l d7, d0 ;get the left side of the player
    move.l d2, d1 
    add.l #(PLAYER_WIDTH)<<8, d1 ;get the right side of the defender
    cmp.l d1, d0 ;is the left side of the player to the right of the right side of the defender
    bge noCollision
    add.l #(PLAYER_WIDTH)<<8,d0 ;get the left side of the player
    cmp.l d2,d0 ;is the right side of the player less than the left side of the defender
	ble	noCollision
	
	;y collision
	move.l d6, d0
	move.l d3, d1
	add.l #(PLAYER_HEIGHT)<<8, d1 ;get the bottom of the player
	cmp.l d1, d0 ;is the top of the player below (greater than) the bottom of the receiver
	bge noCollision
	add.l #(PLAYER_HEIGHT)<<8, d0
	cmp.l d3, d0 ;is the bottom of the player above (less than) the top of the receiver
    ble noCollision
    
    move.b #1, d0 ;yes collision
    rts


    ;TODO   
;XPos is d3, YPos is d4
checkBallCollision 
    move.l ballPosX, d0 ;leftX of ball
    add.l #FOOTBALL_CARRY_OFFSET_X, d0 ;account for the draw position
    move.l d0, d2
    add.l #(FOOTBALL_WIDTH)<<8, d2 ;rightX of ball
    move.l ballPosY, d1
    add.l #FOOTBALL_CARRY_OFFSET_Y, d1 
    
    ;check collision with receiver1
    ;check y bounds
    cmp.l	d4, d1 ;is ballPosY < Receiver1YPos
	blt noCollision	 ;is it above the top of the receiver
	add.l   #(PLAYER_HEIGHT)<<8,d4
    cmp.l	d4, d1 ;is ballPosY  > Receiver1YPos + Player_Height
    bgt noCollision ;is it below the bottom of the receiver
    ;check x bounds
    cmp.l	d3, d2 ;is right edge ballPosX < Receiver1XPos
	blt noCollision	 ;is it to the left of the receiver
	add.l   #(PLAYER_WIDTH)<<8,d3
    cmp.l	d3, d0 ;is left edge ballPosX > Receiver1XPos + player_width
    bgt noCollision ;is it below the bottom of the receiver

    move.b #1, d0
    rts
noCollision
    move.b #0, d0 ;no collision
    rts
    



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
