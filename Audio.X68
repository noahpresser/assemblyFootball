*-----------------------------------------------------------
* Title      : Audio
* Written by : Noah Presser
* Date       : Before the project was assigned
* Description: This file contains sounds for my football project
*-----------------------------------------------------------
    ;ORG $1000
LEVEL_THEME_SOUND_REF   equ 0
SOUND_1_REF             equ 1
MENU_THEME_SOUND_REF    equ 2
TOUCHDOWN_SOUND_REF     equ 3
SNAP_SOUND_REF          equ 4
CATCH_SOUND_REF         equ 5
FIRST_DOWN_SOUND_REF    equ 6
INTERCEPTION_SOUND_REF  equ 7
THROW_SOUND_REF         equ 8
TACKLE_SOUND_REF        equ 9
HAIL_MARY_SOUND_REF     equ 10
WHISTLE_SOUND_REF       equ 10
NUM_SOUNDS              equ 12           
* Put program code here
;requires a1, d0-d2
PlaySound1:                             ;nonLooping
    movem.l D0-D2/A1, -(sp)    
    move.b  soundMemoryAddress, d1      ;store memory location of sound in d1

    lea     sound1, a1
    move.b  #74, d0
    trap    #15         
    
    move.b  #77, d0                     ;control directX player
    move.b  #0, d2                      ;play looping sound (1), play nonLooping sound (0)
    trap    #15                         ;play sound at d1
        
    movem.l (sp)+, D0-D2/A1    
    rts

playNonLoopingSound:
    movem.l a1, -(sp)
    move.l  a0, a1
    move.l  #74, d0
    trap    #15
   
    move.l  #77, d0                     ;control directX player
    move.l  #0, d2                      ;play looping sound (1), play nonLooping sound (0)
    trap    #15                         ;play sound at d1
    movem.l (sp)+, a1 
    rts

;takes in a0 as the theme, d1 as memory ref 
playLoopingSound:
    movem.l a1, -(sp)
    move.l  a0, a1
    move.l  #74, d0
    trap    #15
   
    move.l  #77, d0                     ;control directX player
    move.l  #1, d2                      ;play looping sound (1), play nonLooping sound (0)
    trap    #15                         ;play sound at d1
    movem.l (sp)+, a1    
    rts

;d1 as memory ref
stopSound
    move.l  #77, d0                     ;control directX player
    move.l  #2, d2                      ;stop sound (1), play nonLooping sound (0)
    trap    #15                         ;play sound at d1
    rts

stopAllSoundsNonTrap
    movem.l d0-d2, -(sp)
    move.l  #0, d3
loopStopSounds
    move.l  #77, d0
    move.l  d3, d1
    move.l  #2, d2
    trap    #15
    add.l   #1, d3
    cmp.l   #NUM_SOUNDS, d3
    bne     loopStopSounds
    movem.l (sp)+, d0-d2
    rts
stopAllSounds
    movem.l d0-d2, -(sp)
    move.l  #77, d0
    move.l  #0, d1
    move.l  #3, d2
    trap    #15
    
    movem.l (sp)+, d0-d2
    rts
stopLevelTheme
    movem.l d0-d2, -(sp)
    move.l  #LEVEL_THEME_SOUND_REF, d1
    jsr     stopSound
    movem.l (sp)+, d0-d2
    rts
stopMenuTheme
    movem.l d0-d2, -(sp)
    move.l  #MENU_THEME_SOUND_REF, d1
    jsr     stopSound
    movem.l (sp)+, d0-d2
    rts
playTouchdownSound
    jsr     stopThrowSound
    cmp.l   #1, d0
    bne     noHailMarySound
    jsr     playHailMarySound
    rts
noHailMarySound
    move.l  #TOUCHDOWN_SOUND_REF, d1
    lea     touchdownSound, a0
    jsr     playNonLoopingSound
    rts
playSnapSound
    move.l  #SNAP_SOUND_REF, d1
    lea     snapSound, a0
    jsr     playNonLoopingSound
    rts
playCatchSound
    jsr     stopThrowSound
    move.l  #CATCH_SOUND_REF, d1
    lea     catchSound, a0
    jsr     playNonLoopingSound
    rts
playFirstDownSound
    move.l  #FIRST_DOWN_SOUND_REF, d1
    lea     firstDownSound, a0
    jsr     playNonLoopingSound
    rts
playInterceptionSound
    jsr     stopThrowSound
    jsr     playCatchSound
    move.l  #INTERCEPTION_SOUND_REF, d1
    lea     interceptionSound, a0
    jsr     playNonLoopingSound
    rts
playMenuTheme
    move.l  #MENU_THEME_SOUND_REF, d1
    lea     menuTheme, a0
    jsr     PlayLoopingSound
    rts
playLevelTheme
    move.l  #LEVEL_THEME_SOUND_REF, d1   ;store memory location of sound in d1
    lea     levelTheme, a0
    jsr     PlayLoopingSound
    rts
playThrowSound
    move.l  #THROW_SOUND_REF, d1
    lea     throwSound, a0
    jsr     playNonLoopingSound
    rts
playTackleSound
    move.l  #TACKLE_SOUND_REF, d1
    lea     tackleSound, a0
    jsr     playNonLoopingSound
    rts
playHailMarySound
    move.l  #HAIL_MARY_SOUND_REF, d1
    lea     hailMarySound, a0
    jsr     playNonLoopingSound
    rts
playWhistleSound
    move.l  #WHISTLE_SOUND_REF, d1
    lea     whistleSound, a0
    jsr     playNonLoopingSound
    rts
stopThrowSound
    movem.l d0-d2, -(sp)
    move.l  #THROW_SOUND_REF, d1
    jsr     stopSound
    movem.l (sp)+, d0-d2
    rts

menuTheme	        dc.b	'menuTheme.wav', 0
levelTheme	        dc.b	'crowd.wav', 0
sound1              dc.b    'mushroom.wav', 0
touchdownSound      dc.b    'touchdown.wav', 0
throwSound          dc.b    'throw.wav', 0
tackleSound         dc.b    'tackle.wav', 0
snapSound           dc.b    'hike.wav', 0
firstDownSound      dc.b    'mushroom.wav', 0
catchSound          dc.b    'catch.wav', 0
interceptionSound   dc.b    'interception.wav', 0
hailMarySound       dc.b    'hailMary.wav', 0
whistleSound        dc.b    'whistle.wav', 0
soundMemoryAddress  dc.b    0
dummyByte           dc.b    0











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
