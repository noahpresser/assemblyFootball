*-----------------------------------------------------------
* Title      : Main file for Football Assembly Game
* Written by : Noah Presser
* Date       : When Tom assigned this
* Description: Run this to execute the program
*-----------------------------------------------------------
    ORG    $1000
    include 'constants.x68'
    include 'noahBitmap.x68'
    include 'randomNumbers.x68'
    include 'collision.x68'
    include '7segmentDisplay.x68'
    include 'drawing.x68'
    include 'input.x68'
    include 'movement.x68'
    include 'footballLogic.x68'
    include 'Audio.x68'    
    include 'variables.x68'

    
    
START:              
    
    
    jsr     setScreenResolution
    
    *set double buffered mode
    move.b	#DRAWING_MODE_TRAP_CODE,d0
    move.b	#DOUBLE_BUFFERED_MODE,d1
    trap	#15 
    


    jsr     loadBackground    
    ;jsr     playLevelTheme
    jsr     restartGame

    jsr     seedRandomNumber
    jsr     initTime  
      
GAME_LOOP
    jsr     updateTime
    jsr     redrawBackgroundPieces
    jsr     getInput
    jsr     updateReceivers             ;also calls update player
    jsr     drawStuff
    jsr     swapBuffers
    bra     GAME_LOOP
    
    SIMHALT
   
swapBuffers
    move.b  #REPAINT_SCREEN_TRAP_CODE,d0 
    Trap    #15
    rts        

    
loadBackground:
    ;load variables
    lea     backgroundFile, a0
    move.l  a0, fileAddress
    move.l  #OUTPUT_WIDTH, widthOfPiece
    move.l  #OUTPUT_HEIGHT, heightOfPiece
    move.l  #0, xPosOfPiece
    move.l  #0, yPosOfPiece
    move.w  #0, screenX
    move.w  #0, screenY
    jsr     drawBitmapPiece
    rts
setScreenResolution:
    move.b  #SET_OUTPUT_RESOLUTION_TRAP_CODE,D0
    move.l  #OUTPUT_WIDTH,d1
    swap.w  d1
    move.w  #OUTPUT_HEIGHT,d1
    TRAP    #15    
    rts    
    
initPlayers:
    *initialize x position and x velocity
    move.l  playerStartXPos,d7
    
    *set ball y position and height
    move.l	playerStartYpos, d6
    move.l	d6,d4
    add.l	#PLAYER_HEIGHT,d4
    
    lea     receiver1Xpos, a1
    lea     receiver1Ypos, a2
    lea     receiver2Xpos, a3
    lea     receiver2Ypos, a4
    

    
    ;set football start position
    move.l  ballPosX, d0
    add.l   d7, d0
    move.l  d0, ballPosX
    move.l  ballPosY, d0
    add.l   d6, d0
    move.l  d0, ballPosY
    
    ;reset first down
    move.l  d6, d0
    add.l   #FIRST_DOWN_YARDS, d0
    move.l  d0, firstDownLine
    jsr     resetPlay
    rts
initTime
    move.l  #TIME_SINCE_MIDNIGHT_CODE, d0
    trap    #15
    move.l  d1, lastTime
updateTime
    move.l  #TIME_SINCE_MIDNIGHT_CODE, d0
    trap    #15
    
    ;get the delta time
    move.l  lastTime, d3
    move.l  d1, lastTime 
    sub.l   d3, d1            
    move.l  d1, deltaTime
    cmp.b   #BALLSTATE_TIMEOUT, ballState
    beq     dontTickTimer
    add.l   d1, currentRoundTime 
dontTickTimer
    cmp.l   #0, scoreFlashDigitTimer
    ble     dontUpdateScoreFlashtimer
    sub.l   d1, scoreflashDigitTimer
dontUpdateScoreFlashtimer
    cmp.l   #0, downFlashDigitTimer
    ble     dontUpdateDownFlashtimer
    sub.l   d1, downflashDigitTimer
dontUpdateDownFlashtimer
    cmp.l   #0, timerFlashDigitTimer
    ble     dontUpdateTimerFlashtimer
    sub.l   d1, timerflashDigitTimer
dontUpdatetimerFlashtimer
    sub.l   d1, snapDebounceTimer
    sub.l   d1, resetPlayDebounceTimer

    rts

    
EXIT_GAME:
    SIMHALT             

* Put variables and constants here

          
    END    START      
























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
