*-----------------------------------------------------------
* Title      : Variables
* Written by : Noah Presser
* Date       : October 10th
* Description: Contains Variables stored in memory throughout the Foorball Game
*-----------------------------------------------------------

backgroundFile              INCBIN "footballfield3.bmp"
veteranRules                INCBIN "veteranRules.bmp"
noobRules                   INCBIN "noobRules.bmp"
highscoreDude               INCBIN "highscoreDude.bmp"
yourscoreDude               INCBIN "yourscoreDude.bmp"
paths1                      INCBIN "paths1.bin"
lastWinput                  dc.b 0
lastAinput                  dc.b 0
lastSinput                  dc.b 0
lastDinput                  dc.b 0

PLAYER_MIN_X_SPEED          dc.l $FFFFFFF0
PLAYER_MIN_Y_SPEED          dc.l $FFFFFFF0

    
playerStartXpos             dc.l $13000
playerStartYpos             dc.l $27600
firstDownLine               dc.l $1F900
oldFirstDownLine            dc.l $1F900
lineOfScrimmage             dc.l $27600
oldLineOfScrimmage          dc.l $28000
    
receiver1XPos               dc.l $8000
receiver1YPos               dc.l $28000

receiver2XPos               dc.l $20000
receiver2YPos               dc.l $28000

receiver1StartXPos          dc.l $6500
receiver1StartYPos          dc.l $28000
receiver1YTurnPos           dc.l $20000
receiver1XVel1              dc.l $00000000
receiver1YVel1              dc.l $FFFFFEFF
receiver1XVel2              dc.l $00000100
receiver1YVel2              dc.l $00000000
receiver1YVel3              dc.l $00000000

receiver2StartXPos          dc.l $20000
receiver2StartYPos          dc.l $28000
receiver2YTurnPos           dc.l $200000
receiver2XVel1              dc.l $00000000
receiver2YVel1              dc.l $FFFFFEFF
receiver2XVel2              dc.l $00000100
receiver2YVel2              dc.l $00000000
receiver2Yvel3              dc.l $00000000

defender1XPos               dc.l $6500
defender1YPos               dc.l $20000
defender1XVel1              dc.l $00000000
defender1YVel1              dc.l $FFFFFEFF
defender1XVel2              dc.l $00000100
defender1YVel2              dc.l $00000000

defender2XPos               dc.l $8000
defender2YPos               dc.l $20000
defender2XVel1              dc.l $00000000
defender2YVel1              dc.l $FFFFFEFF
defender2XVel2              dc.l $00000100
defender2YVel2              dc.l $00000000

linebackerXPos              dc.l $800
linebackerYPos              dc.l $20000
linebackerXVel              dc.l $00000000
linebackerYVel              dc.l $FFFFFEFF

linebackerState             dc.l 0

ballSpeedX                  dc.l  0
ballSpeedY                  dc.l 0

ballPosX                    dc.l 0
ballPosY                    dc.l 0


lastTime                    dc.l 0
deltaTime                   dc.l 0
deltaTimeForMultiplication  dc.l 0

;bytes

;0 carried by qb, 1 thrown, 2 caught by receiver 
ballState                   dc.b 0
gameState                   dc.b 0
downCounter                 dc.b 1
score                       dc.b 0

timerSeconds                dc.b 0
timerMinutes                dc.b 3 

highScore                   dc.b 0
lastScore                   dc.b 0

wWasPressed                 dc.b 0
aWasPressed                 dc.b 0
sWasPressed                 dc.b 0
dWasPressed                 dc.b 0

currentRoundTime            dc.l 0
playTimer                   dc.l 0
pathTimer                   dc.l 0

path1X1                     dc.l 0
path1Y1                     dc.l 0
path1X2                     dc.l 0
path1Y2                     dc.l 0
path1X3                     dc.l 0
path1Y3                     dc.l 0

path2X1                     dc.l 0
path2Y1                     dc.l 0
path2X2                     dc.l 0
path2Y2                     dc.l 0  
path2X3                     dc.l 0  
path2Y3                     dc.l 0

scoreflashDigitTimer        dc.l 0
downflashDigitTimer         dc.l 0
timerflashDigitTimer        dc.l 0
snapDebounceTimer           dc.l 0
resetPlayDebounceTimer      dc.l 0
     
oldUIX1                     dc.l 0
oldUIY1                     dc.l 0
oldUIX2                     dc.l 1
oldUIY2                     dc.l 1       

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
