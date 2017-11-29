*-----------------------------------------------------------
* Title      : Input
* Written by : Noah Presser
* Date       : Slightly after when Tom assigned this
* Description: Handles input for the football game
*-----------------------------------------------------------

getInput
    cmp.b   #GAMESTATE_MENU, gameState
    bne     doneMenuInput
    
    ;get input from keys jkl 
    move.b  #KEY_SCAN_CODE, d0
    move.l  #SPACEH_LONG, d1
    trap    #15
    
    ;check space input
    btst    #0, d1 
    bne     startGame    
doneMenuInput
    cmp.b   #GAMESTATE_PLAY, gameState
    bne     RETURN
    
    cmp.b   #BALLSTATE_TIMEOUT, ballState
    bne     continueInput
    
    ;get input from keys jkl 
    move.b  #KEY_SCAN_CODE, d0
    move.l  #SPACEH_LONG, d1
    trap    #15
    
    
    ;check space input
    cmp.l   #0, resetPlayDebounceTimer
    bgt     RETURN
    btst    #0, d1 
    bne     snapBall                                                                            ;the ball was snapped
    rts
    
continueInput
    ;get player input
    cmp.b   #BALLSTATE_FLY, ballState
    beq     RETURN  
    move.b  #KEY_SCAN_CODE, d0
    cmp.b   #BALLSTATE_CAUGHT, ballState
    beq     doneSpaceInput                                                                     ;caught ball
    
    ;waits for a quarter second after snap to get space again
    cmp.l   #0, snapDebounceTimer
    bgt     doneSpaceInput
    ;get input from key SPACE
    move.l  #SPACEH_LONG, d1
    trap    #15
checkSpaceinput
    btst    #0, d1                                                                              ;is k input
    beq     doneSpaceInput
    move.l  #1, d0                                                                              ;k was pressed
    jmp     throwBall
    ;set to be thrown, ignore input

doneSpaceInput
    ;get input from keys wasd
    move.l  #WASD_LONG, d1
    trap    #15
    move.l  #0, wWasPressed                                                                     ;clears aWas, sWas and dWas sneakily
checkAinput
    btst    #16, d1                                                                             ;is A input
    beq     checkDInput
    sub.w   #PLAYER_X_ACCELLERATION, d5
    move.b  #1, aWAsPressed
checkDinput
    btst    #0, d1
    beq     checkWInput
    add.w   #PLAYER_X_ACCELLERATION, d5
    move.b  #1, dWAsPressed
checkWinput
    swap    d5                                                                                  ;yx velocity
    btst    #24, d1                                                                             ;is W 
    beq     checkSInput                                                                         ;branch if z flag not set
    sub.w   #PLAYER_Y_ACCELLERATION, d5
    move.b  #1, wWAsPressed
checkSinput
    btst    #8, d1
    beq     doneWASD
    add.w   #PLAYER_Y_ACCELLERATION, d5
    move.b  #1, sWAsPressed
doneWASD
    rts


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
