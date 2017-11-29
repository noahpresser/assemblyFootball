*-----------------------------------------------------------
* Title      : Seven Segment Display
* Written by : Noah Presser
* Date       : October 10th, 2017
* Description: Contains the implementation for the seven segment display
*-----------------------------------------------------------
;takes in d3 as val to draw, 0-9, d1 startXpos, d2 startYPos
DrawSegments
    movem.l ALL_REG, -(sp)
    lea     segmentByteArray, a0
    move.l  #0, d7                          ;counter
    move.l  #0, d6
    move.w  d3, d6
    
    ;store these
    move.l  d1, a3
    move.l  d2, a4
drawSegmentLoop    
    ;move to the next segment
    jsr     drawSegment
    add.b   #1, d7 
    cmp.b   #7, d7
    bne     drawSegmentLoop
doneDrawingSegments
    movem.l (sp)+, ALL_REG
    rts

;takes in d6 as segment to draw, d1 as startXpos, d2 startYPos
DrawSegment
    ;get byte from segmentByteArray
    move.l  #0, d5
    move.b  (a0, d6), d5
    btst    d7, d5
    beq     dontDrawSegment
    
    ;copy the positions before the offset
    move.l  a3, d1
    move.l  a4, d2
    move.l  d1, d3
    move.l  d2, d4
    movem.l d6, -(sp)
    move.l  #0, d6
    
    ;get positions from tables
    move.l  d7, d5
    lea     segmentXStartPositions, a1
    move.b  (a1, d5), d6                    ;set xpos1
    add.w   d6, d1
    
    lea     segmentYStartPositions, a1
    move.b  (a1, d5), d6                    ;set ypos1
    add.w   d6, d2
    
    lea     segmentXEndPositions, a1
    move.b  (a1, d5), d6                    ;set xpos2
    add.w   d6, d3
    
    lea     segmentYEndPositions, a1
    move.b  (a1, d5), d6                    ;set ypos2
    add.w   d6, d4
    
    trap    #15
    movem.l (sp)+, d6 
       
dontDrawSegment
    rts

segmentByteArray        dc.b $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $FF, $6F

segmentXStartPositions  dc.b 3, 18, 18,  3,  0,  0, 3
segmentXEndPositions    dc.b 15, 18, 18,  15,  0,  0, 15
segmentYStartPositions  dc.b 0, 3, 21,  36, 21,  3, 18
segmentYEndPositions    dc.b 0, 15, 33, 36, 33, 15, 18




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
