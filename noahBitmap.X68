*-----------------------------------------------------------
* Title      : Bitmap
* Written by : Noah Presser
* Date       : Quite a while ago
* Description: This is a modified version of my submitted bitmap from our second assignment
*-----------------------------------------------------------
LEFT_X  EQU     0
TOP_Y   EQU     -1

PEN_COLOR_TRAP_CODE     EQU     80
DRAW_PIXEL_TRAP_CODE    EQU     82

RECT_COLOR EQU $00808080

;variables for function
PIECE_WIDTH EQU 4
PIECE_HEIGHT EQU 8
PIECE_XPOS  EQU 12
PIECE_YPOS  EQU 16
SCREEN_X    EQU 20
SCREEN_Y    EQU 24
FILE_ADDRESS    EQU 28


;these vals are same for both 256 and 24bit
OFFSET_TO_PIXEL_OFFSET EQU 10
OFFSET_TO_WIDTH EQU 18
OFFSET_TO_HEIGHT EQU 22
OFFSET_TO_BITS_PER_PIXEL EQU 28 ;if its 8, we have a 8x8x8, else we have a 256
OFFSET_TO_COLOR_TABLE EQU $36

ALL_REG REG D0-D7/A0-A6

    ORG    $1000

RETURN:
    rts
;converts little endian number in d0 to a big endian number
littleEndianToBigEndian:   ;d0=$12345678
    rol.w   #8,d0         ;d0=$12347856
    swap    d0            ;d0=$78561234
    rol.w   #8,d0         ;d0=$78563412
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 24 bit 8x8x8
;sets pixel color given a0 is the pixel in the array  


    
drawBitmap: ;calls either draw256 or draw24bit

    move.l FILE_ADDRESS(sp), a0 ;load the bmp file's starting address
    add.l #OFFSET_TO_PIXEL_OFFSET, a0
    move.l (a0), d0 ;move the little endian offset into d0
    jsr littleEndianToBigEndian
    move.l  FILE_ADDRESS(sp), a0 ;load the bmp file's starting address
    add.l a0, d0 ;get the pixel start location        
    move.l d0, pixelStartAddress ;store the pixel start address
    
    move.l  FILE_ADDRESS(sp), a0 ;load the bmp file's starting address
    add.l #OFFSET_TO_WIDTH, a0
    move.l (a0), d0
    jsr littleEndianToBigEndian
    move.l d0, width ;store the width of the bmp
    
    move.l  FILE_ADDRESS(sp), a0 ;load the bmp file's starting address
    add.l #OFFSET_TO_HEIGHT, a0
    move.l (a0), d0
    jsr littleEndianToBigEndian
    move.l d0, height ;store the height of the bmp
    
    

    ;set the height
    move.l  height, d5
    add.l   d5, d4 ; set the starting y position at the bottom
    
    ;set the width of the piece
    move.l  #LEFT_X, d5
    add.l   width, d5 ;set the rightmost boundary ;REASON 256 BIT ISNT WORKING
    
    ;define the padding
    move.l  width, d0
    muls  #3, d0
    and.l   #$00000003, d0 ;mod 4
    move.l d0, padding ;padding is correct for 256, needs to be fixed for 24 bit
    
    ;determine whether to draw a 24bit or a 256
    move.l  FILE_ADDRESS(sp), a0
    add.l #OFFSET_TO_BITS_PER_PIXEL, a0
    move.l (a0), d0
    jsr littleEndianToBigEndian
    cmp.l #24, d0 ;if its 0, we have an 8x8x8
    bne draw256 ; go draw the 256
draw24bit:
    move.l  pixelStartAddress, a0 ;put our current pixel address in a0
    
    ;fixes padding based on result
    move.l padding, d0
    move.l d0, d1
    and.b #1, d1 ; if the last bit is 1
    cmp.b #1, d1  
    bne dontFlip
    bchg.l #1, d0  ;flip the 2nd to last bit (turns 3 to 1 and 1 to 3) 
dontFlip:
    move.l d0, padding
    
    ;set the rightmost boundary for the piece to be drawn
    move.l  PIECE_XPOS(sp), d5
    add.l   PIECE_WIDTH(sp), d5 ;stored in register for fast access
    
    ;set the left piece draw position
    move.l PIECE_XPOS(sp), d1
    add.l d1, d3 ;startXpos is now where it should be for the piece
    muls.w #3, d1 ; 3 colors each for 1 position, add that to the pixel address pointer
    add.l d1, a0 
    
    ;set the draw position
    move.l PIECE_HEIGHT(sp), d4
    move.l PIECE_YPOS(sp), d1
    add.l d1, d4 ;start ypos is now where it should be
    move.l width, d1 ; the length of a line to advance a0
    mulu.w #3, d1 ; 3 colors per line
    add.l padding, d1 ;make sure to account for padding in each row
    move.l height, d2
    sub.l d4, d2 ;height - (yPos + pieceHeight)
    mulu.w d2, d1 ;the number of rows we are skipping up * width (move that many pixels)
    add.l d1, a0  ;increment the pointer
    sub.l #1, d4 ;correct for being offscreen
    
    ;correct for piece offset
    sub.l  PIECE_XPOS(sp), d3 ;correct for the offset caused when drawing pixel
    sub.l  PIECE_XPOS(sp), d5 ;correct rightmost barrier
    sub.l  PIECE_YPOS(sp), d4 ;correct for offset caused when drawing the pixel
    
    ;add in screen offset
    add.w SCREEN_X(sp), d3 ;correct for screenX positioning
    add.w SCREEN_X(sp), d5 ;correct rightmost barrier
    add.w SCREEN_Y(sp), d4 ;correct for screenY positioning
    
    ;set topmost barrier
    move.l #-1, d6
    move.l #0, d0
    move.w SCREEN_Y(sp), d0
    add.l d0, d6 
    move.l d6, topPieceDrawBarrier 
    
    move.l d4, d2 ;use d2 as currentY instead of d4
    move.l #0, d0 ;clear this for the loop so we can use byte operations
    
    ;set this number for speed
    move.l #PEN_COLOR_TRAP_CODE, d4
    move.l #DRAW_PIXEL_TRAP_CODE, d6
    
    cmp.b #1, d7
    beq hilariousOptomization
    cmp.b #2, d7
    beq continueRowMenu
    
    ;patch for crash
    cmp.l   #0, d2
    ble     DONE
;beginning of drawing a row
continueRow24: ;d3 is currentX, d2 d4 is currentY
    ;get the proper color from a0
    
    
    move.l #0, d1    ;clear d1
    
    ;working
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    ;test new row
    addi.w #1,d3 ;increase xPos
    cmp.w  d5,d3 ;compare d3 with the rightmost boundary in d5 (xpos + widthOfPiece)
    bne     continueRow24
    ;END ROW
    
    
    
    ;move the pointer to the end of the row of colors in the file
    move.l width, d0
    sub.l PIECE_WIDTH(sp), d0 ;get the value of width - piecewidth
    sub.l PIECE_XPOS(sp), d0 ;get the value from the end of the piece to the end of the bmp
    muls.w #3, d0
    add.l d0, a0
    
    ;add the padding at the end of the row
    add.l padding, a0
    
    move.l #0, d3 ;reset xPos
    add.w  SCREEN_X(sp), d3 ;correct for screenX
    
    ;set the left piece draw position
    move.l PIECE_XPOS(sp), d1
    muls.w #3, d1 ; 3 colors each for 1 position, add that to the pixel address pointer
    add.l d1, a0
    and.b #1, d0         
    ;check if we're done with the loop (hit top draw pos)
    sub.l  #1,d2
    
    move.l topPieceDrawBarrier, d0
    cmp.l d0 , d2 ;check topMost Barrier
    bne     continueRow24 ;LOOP back to drawing the next row
    jmp DONE

;beginning of drawing a row
continueRowMenu: ;d3 is currentX, d2 d4 is currentY
    ;get the proper color from a0
    
    
    move.l #0, d1    ;clear d1
    
    ;working
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    cmp.l   #DONT_DRAW_COLOR, d1
    beq     dontDrawPixel
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15
dontDrawPixel
    ;test new row
    addi.w #1,d3 ;increase xPos
    cmp.w  d5,d3 ;compare d3 with the rightmost boundary in d5 (xpos + widthOfPiece)
    bne     continueRowMenu
    ;END ROW
    
    
    
    ;move the pointer to the end of the row of colors in the file
    move.l width, d0
    sub.l PIECE_WIDTH(sp), d0 ;get the value of width - piecewidth
    sub.l PIECE_XPOS(sp), d0 ;get the value from the end of the piece to the end of the bmp
    muls.w #3, d0
    add.l d0, a0
    
    ;add the padding at the end of the row
    add.l padding, a0
    
    move.l #0, d3 ;reset xPos
    add.w  SCREEN_X(sp), d3 ;correct for screenX
    
    ;set the left piece draw position
    move.l PIECE_XPOS(sp), d1
    muls.w #3, d1 ; 3 colors each for 1 position, add that to the pixel address pointer
    add.l d1, a0
    and.b #1, d0         
    ;check if we're done with the loop (hit top draw pos)
    sub.l  #1,d2
    
    move.l topPieceDrawBarrier, d0
    cmp.l d0 , d2 ;check topMost Barrier
    bne     continueRowMenu ;LOOP back to drawing the next row
    jmp DONE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 256     

     
draw256:


    ;get the color table's starting address
    move.l  FILE_ADDRESS(sp), a0
    move.l a0, d0
    add.l #OFFSET_TO_COLOR_TABLE, d0
    move.l d0, colorTableStartAddress ;store this for later

    move.l  pixelStartAddress, a0 ;put our current pixel address in a0


    
  

  
    ;set the left piece draw position
    move.l PIECE_XPOS(sp), d3 ;startXpos is now where it should be for the piece
    add.l d3, a0
    add.l padding, d0
    
    ;set the rightmost barrier draw position (xPos + width)
    move.l  PIECE_XPOS(sp), d5
    add.l   PIECE_WIDTH(sp), d5 ;stored in register for fast access
    
    ;set the draw position
    move.l PIECE_HEIGHT(sp), d4
    move.l PIECE_YPOS(sp), d1
    add.l d1, d4 ;start ypos is now where it should be
    move.l width, d1 ; the length of a line to advance a0 
    add.l padding, d1 
    move.l height, d2
    sub.l d4, d2 ;height - (yPos + pieceHeight)
    mulu.w d2, d1 ;the number of rows we are skipping up
    add.l d1, a0  ;increment the pointer
    sub.l #1, d4 ;correct for being offscreen
    
    ;correct for piece offset
    sub.l  PIECE_XPOS(sp), d3 ;correct for the offset caused when drawing pixel
    sub.l  PIECE_XPOS(sp), d5 ;correct rightmost barrier
    sub.l  PIECE_YPOS(sp), d4 ;correct for offset caused when drawing the pixel
    
    ;add in screen offset
    add.w SCREEN_X(sp), d3 ;correct for screenX positioning
    add.w SCREEN_X(sp), d5 ;correct rightmost barrier
    add.w SCREEN_Y(sp), d4 ;correct for screenY positioning
    
    ;set topmost barrier
    move.l #-1, d6
    move.l #0, d0
    move.w SCREEN_Y(sp), d0
    add.l d0, d6 
    move.l d6, topPieceDrawBarrier
    
    move.l d4, d2 ;use d2 as currentY instead of d4

    
    ;save for fast access
    move.l colorTableStartAddress, a2
    
    ;clear for the loop
    move.l #0, d0 
    
    ;set this number for speed
    move.l #PEN_COLOR_TRAP_CODE, d4
    move.l #DRAW_PIXEL_TRAP_CODE, d6
    
continueRow256: ;d3 is currentX, d2 is currentY
    ;sets pixel color given a0 is pixel in array    
    move.b  (a0)+, d0
     
    ;go inside color table, get color in d1
    move.l a2, a1
    lsl.w #2, d0 ;expand for a 4 byte color (multiply by 4)
    add.l d0, a1 ;add the offset to the value
    move.l (a1), d1
   
    lsr.l #8, d1 ; shift it right to get the correct format

    move.l  d4, d0 ;set the proper trap code to set the pen color
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1
    move.b  d6,d0
    trap    #15
            
    ;compare d3 with the rightmost boundary in d5 (are we done with this row)
    addi.w  #1,d3
    cmp.w  d5,d3 
    bne     continueRow256
    ;END LOOP       
    
    ;move the pointer to the end of the row of colors in the file
    move.l width, d0
    sub.l PIECE_WIDTH(sp), d0 ;get the value of width - piecewidth
    sub.l PIECE_XPOS(sp), d0 ;get the value from the end of the piece to the end of the bmp
    add.l d0, a0
    
    ;add the padding to the image
    add.l padding, a0 
    
    ;reset xPos
    move.l #0, d3 ;reset xPos
    add.w  SCREEN_X(sp), d3 ;correct for screenX
    ;add the left piece draw position
    move.l PIECE_XPOS(sp), d1
    add.l d1, a0 ;increment the color pointer
    
    ;check if we have reached the last row to be drawn (top of piece)
    sub.w  #1,d2
    cmp.w  topPieceDrawBarrier, d2
    bne    continueRow256
    jmp DONE
drawMenuBitmap:
    MOVEM.l ALL_REG, -(sp)
    jsr CLEARREG
    move.l #2, d7 ;for special case
    ;add variables to stack
    move.l #28, d0 ;store room for stack increase
    sub.l  d0, sp
    move.l  widthOfPiece, (sp)
    move.l  heightOfPiece, 4(sp)
    move.l  xPosOfPiece, 8(sp)
    move.l  yPosOfPiece, 12(sp)
    move.w  screenX, 16(sp)
    move.w  screenY, 20(sp)
    move.l fileAddress, a0
    move.l  a0, 24(sp)
    jsr    drawBitmap
drawPlayerBitmap:
    MOVEM.l ALL_REG, -(sp)
    jsr CLEARREG
    move.l #1, d7 ;for special case
    ;add variables to stack
    move.l #28, d0 ;store room for stack increase
    sub.l  d0, sp
    move.l  widthOfPiece, (sp)
    move.l  heightOfPiece, 4(sp)
    move.l  xPosOfPiece, 8(sp)
    move.l  yPosOfPiece, 12(sp)
    move.w  screenX, 16(sp)
    move.w  screenY, 20(sp)
    move.l fileAddress, a0
    move.l  a0, 24(sp)
    jsr    drawBitmap
;main function to be called    
drawBitmapPiece:
    MOVEM.l ALL_REG, -(sp)
    jsr CLEARREG
    move.l  #0, d7 ;for special case
    ;add variables to stack
    move.l  #28, d0 ;store room for stack increase
    sub.l   d0, sp
    move.l  widthOfPiece, (sp)
    move.l  heightOfPiece, 4(sp)
    move.l  xPosOfPiece, 8(sp)
    move.l  yPosOfPiece, 12(sp)
    move.w  screenX, 16(sp)
    move.w  screenY, 20(sp)
    move.l fileAddress, a0
    move.l  a0, 24(sp)
    jsr    drawBitmap
DONE:
    add.l #32, sp ;move stack back to where it was
    MOVEM.l (sp)+, ALL_REG
    rts
    
CLEARREG:
    move.l #0, d1
    move.l #0, d2
    move.l #0, d3
    move.l #0, d4
    move.l #0, d5
    move.l #0, d6
    move.l #0, d7
    move.l #0, a1
    move.l #0, a2
    move.l #0, a3
    move.l #0, a4
    move.l #0, a5
    move.l #0, a6
    rts
;beginning of drawing a row, draws 31 times
hilariousOptomization: ;d3 is currentX, d2 d4 is currentY
    ;get the proper color from a0
    
    
    move.l #0, d1    ;clear d1
    
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15
    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15
    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    add.w #1, d3
    move.l #0, d1
    move.b (a0)+, d1 ;000000bb
    swap d1          ;00bb0000
    move.b (a0)+, d1 ;00bb00gg
    lsl.w #8, d1     ;00bbgg00
    move.b (a0)+, d1 ;00bbggrr
    ;;;;;;;    
    
    ;set the proper trap code to set the pen color
    move.b  d4, d0         
    trap    #15
    
    ;draw the pixel
    move.w  d3, d1 ;can use word because trap 82 only uses d1.w
    move.b  d6 ,d0
    trap    #15

    
    

    
    
    ;END ROW
    
    
    
    ;move the pointer to the end of the row of colors in the file
    move.l width, d0
    sub.l PIECE_WIDTH(sp), d0 ;get the value of width - piecewidth
    sub.l PIECE_XPOS(sp), d0 ;get the value from the end of the piece to the end of the bmp
    muls.w #3, d0
    add.l d0, a0
    
    ;add the padding at the end of the row
    add.l padding, a0
    
    move.l #0, d3 ;reset xPos
    add.w  SCREEN_X(sp), d3 ;correct for screenX
    
    ;set the left piece draw position
    move.l PIECE_XPOS(sp), d1
    muls.w #3, d1 ; 3 colors each for 1 position, add that to the pixel address pointer
    add.l d1, a0
    and.b #1, d0         
    ;check if we're done with the loop (hit top draw pos)
    sub.l  #1,d2
    
    move.l topPieceDrawBarrier, d0
    cmp.l d0 , d2 ;check topMost Barrier
    bne hilariousOptomization ;LOOP back to drawing the next row
    jmp DONE


        
* Put variables and constants here


fileAddress dc.l 0 
widthOfPiece dc.l  640
heightOfPiece   dc.l    480
xPosOfPiece dc.l    0
yPosOfPiece dc.l  0
screenX dc.w 0
screenY dc.w 0

pixelStartAddress    dc.l    1
colorTableStartAddress dc.l 1
width    dc.l    1
height    dc.l    1
padding dc.b 1
rightPieceDrawBarrier dc.l 1
topPieceDrawBarrier dc.l 1
bottomPieceBoundary dc.l 1









        










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
